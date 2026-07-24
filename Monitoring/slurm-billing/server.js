const express = require('express');
const path = require('path');
const fs = require('fs');
const { exec } = require('child_process');
const os = require('os');
const app = express();
const PORT = 3030;

// JSON 요청 바디 파싱을 위한 미들웨어
app.use(express.json());

// 단가 정보를 저장할 파일 경로
const RATES_FILE_PATH = path.join(__dirname, 'rates.json');

// 기본 단가 설정 (rates.json 파일이 없을 경우 사용)
const DEFAULT_UNIT_PRICES = {
    'cpu': 10,
    'gres/gpu:rtx3090': 500,
    'gres/gpu:a100': 2000,
    'gres/gpu:a6000': 1200,
    'gres/gpu:rtx4090': 700,
    'gres/gpu:rtx6000ada': 1500,
    'gres/gpu:a5000': 400,
    'gres/gpu:rtxpro6000': 1000
};

// 1. 단가 읽어오기 함수 (파일에서 읽거나 기본값 사용)
function getUnitPrices() {
    try {
        if (fs.existsSync(RATES_FILE_PATH)) {
            const data = fs.readFileSync(RATES_FILE_PATH, 'utf8');
            return JSON.parse(data);
        }
    } catch (err) {
        console.error("단가 파일 읽기 실패, 기본값을 사용합니다:", err);
    }
    return { ...DEFAULT_UNIT_PRICES };
}

// 2. 단가 저장하기 함수
function saveUnitPrices(prices) {
    try {
        fs.writeFileSync(RATES_FILE_PATH, JSON.stringify(prices, null, 2), 'utf8');
        return true;
    } catch (err) {
        console.error("단가 파일 저장 실패:", err);
        return false;
    }
}

// sreport 파싱 함수 (동적 단가 반영)
function parseSreport(rawData, unitPrices) {
    if (!rawData || !rawData.trim()) return [];

    const lines = rawData.trim().split('\n');
    const userMap = {};

    lines.forEach(line => {
        const cleanLine = line.trim();
        if (!cleanLine || cleanLine.toLowerCase().startsWith('cluster') ||
            cleanLine.toLowerCase().startsWith('usage') || cleanLine.startsWith('-')) return;

        const parts = cleanLine.split('|');
        if (parts.length < 6) return;

        const login = parts[1].trim();
        const account = parts[3].trim();
        const tresName = parts[4].trim();
        const usedMinsStr = parts[5].trim();

        if (!login || login.toLowerCase() === 'login') return;

        const usedMinutes = parseInt(usedMinsStr, 10) || 0;
        const usedHours = usedMinutes / 60;

        // 동적 단가 사용
        const unitPrice = unitPrices[tresName.toLowerCase()] || 0;
        const cost = usedHours * unitPrice;

        const userKey = `${login}_${account}`;

        if (!userMap[userKey]) {
            userMap[userKey] = { login, account, totalCost: 0, tresUsage: {} };
        }

        if (!userMap[userKey].tresUsage[tresName]) {
            userMap[userKey].tresUsage[tresName] = { minutes: 0, hours: 0, cost: 0 };
        }

        userMap[userKey].tresUsage[tresName].minutes += usedMinutes;
        userMap[userKey].tresUsage[tresName].hours += parseFloat(usedHours.toFixed(2));
        userMap[userKey].tresUsage[tresName].cost += Math.round(cost);
        userMap[userKey].totalCost += cost;
    });

    return Object.values(userMap).map(user => {
        user.totalCost = Math.round(user.totalCost);
        return user;
    });
}

// --- API 엔드포인트 ---

// [GET] 단가 조회 API
app.get('/api/rates', (req, res) => {
    res.json(getUnitPrices());
});

// [POST] 단가 저장 및 추가 API
app.post('/api/rates', (req, res) => {
    const newRates = req.body;
    if (!newRates || typeof newRates !== 'object') {
        return res.status(400).json({ success: false, message: '유효하지 않은 데이터입니다.' });
    }

    if (saveUnitPrices(newRates)) {
        res.json({ success: true, message: '단가 설정이 성공적으로 저장되었습니다.' });
    } else {
        res.status(500).json({ success: false, message: '단가 저장 중 오류가 발생했습니다.' });
    }
});

// [GET] 과금 데이터 조회 API
app.get('/api/billing', (req, res) => {
    const startDate = req.query.start || '2026-07-01';
    let endDate = req.query.end || '2026-07-14';

    const todayStr = new Date().toISOString().split('T')[0];
    if (endDate >= todayStr) {
        endDate = 'now';
    } else {
        endDate = `${endDate}T23:59:59`;
    }

    // 최신 단가 파일에서 TRES 목록 추출
    const currentRates = getUnitPrices();
    const tresList = Object.keys(currentRates).join(',');

    const command = `sreport cluster UserUtilizationByAccount Start=${startDate} End=${endDate} -T ${tresList} -P`;
    const currentHostname = os.hostname();

    exec(command, (error, stdout, stderr) => {
        if (error) {
            console.error("Slurm 실행 에러:", stderr);
            return res.json({ period: `${startDate} ~ ${req.query.end}`, users: [], hostname: currentHostname, error: true });
        }

        const billingData = parseSreport(stdout, currentRates);
        res.json({
            period: `${startDate} ~ ${req.query.end}`,
            users: billingData,
            hostname: currentHostname,
            isMock: false
        });
    });
});

app.use(express.static(path.join(__dirname, 'public')));

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});
