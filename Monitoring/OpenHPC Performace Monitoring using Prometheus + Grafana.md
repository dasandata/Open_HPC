
# # OpenHPC Performace Monitoring using Prometheus + Grafana

[contents]: OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#%EB%AA%A9%EC%B0%A8
[1]: OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-1-prometheus-install-in-master
[2]: OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-2-Install-prometheus-node-expoter
[3]: OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-3-add-scrape-node-info-to-master
[4]: OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-4-Install-prometheus-nvidia-dcgm-expoter-prometheus-dcgm
[5]: OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-5-prometheus-slurm-exporter--for-centos7-only-master-
[6]: OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-6-prometheus-ipmi-exporter--for-centos7-only-master-
[7]: OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-7-grafana-install-on-master
[8]: OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-8-grafana-report-to-pdf
[9]: OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-9-grafana-report-pdf-gen-cli
[grafanadashboards]: OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#grafana-dashboardshttpsgrafanacomgrafanadashboards

## ## Requirements  
 - openhpc node staeful setup  # docker image in physical disk and save docker config on nodes.

## 목차  

### [1. Prometheus install in master.][1]
### [2. Install prometheus-node-expoter][2]
### [3. add scrape node info to master][3]
### [4. Install prometheus nvidia dcgm expoter (prometheus-dcgm)][4]
### [5. Prometheus-slurm exporter ( For Centos7, Only Master )][5]
### [6. Prometheus-ipmi exporter ( For Centos7, Only Master )][6]
### [7. Grafana Install (on Master)][7]
### [8. Grafana Report to PDF][8]
### [9. Grafana Report PDF Gen cli][9]
### [Grafana dashboards][grafanadashboards]

### [END.][contents]

***

## ## [1. Prometheus install in master.][contents]
```bash
# Make Prometheus Config file (yaml).

mkdir /etc/prometheus

cat << EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label \`job=<job_name>\` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9090']
EOF


# Make Prometheus Data folder.
adduser --uid 9090 --no-create-home  --shell /sbin/nologin   prometheus
mkdir   /var/lib/prometheus/
mkdir   /usr/local/bin/prometheus
chown   prometheus:prometheus    /var/lib/prometheus/


# prometheus download
# https://prometheus.io/download/
cd /usr/local/bin
wget https://github.com/prometheus/prometheus/releases/download/v2.37.3/prometheus-2.37.3.linux-amd64.tar.gz
tar xvfz prometheus-*.tar.gz -C /usr/local/bin/prometheus --strip-components 1
chown  -R prometheus:prometheus    /usr/local/bin/prometheus

# prometheus service add
## ExecStart, web.console은 바이너리 파일 디렉토리 위치에 맞게 변경합니다.
## config 파일 위치 및 Data 존재하는 디렉토리는 위치에 맞게 변경합니다.
## storage.tsdb.retention.time=1y 옵션으로 데이터 저장기간을 정할 수 있습니다.
cat << EOF > /usr/lib/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/usr/local/bin/prometheus/consoles \
    --web.console.libraries=/usr/local/bin/prometheus/console_libraries \
    --storage.tsdb.retention.time=1y
[Install]
WantedBy=multi-user.target
EOF

chmod +x /lib/systemd/system/prometheus.service
systemctl  daemon-reload
systemctl  enable   prometheus.service
systemctl  start    prometheus.service
systemctl  status   prometheus.service

#(제외) Firewall Port Open 9090
#firewall-cmd --list-all | grep 9090
#firewall-cmd --add-port=9090/tcp
#firewall-cmd --add-port=9090/tcp --permanent
#firewall-cmd --list-all | grep 9090

# Open Broser to http://localhost:9090

```



## ## [2. install prometheus-node-expoter][contents]
```bash

# node-exporter folder add
mkdir   /usr/local/bin/node_exporter

# node-exporter download
# https://prometheus.io/download/
wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz
tar zxvf node_exporter-*.tar.gz -C /usr/local/bin/node_exporter --strip-components 1

# node-exporter service add
cat << EOF > /usr/lib/systemd/system/node-exporter.service
[Unit]
Description=Node Exporter
[Service]
ExecStart=/usr/local/bin/node_exporter/node_exporter
[Install]
WantedBy=multi-user.target
EOF

# node-exporter service start
chmod +x /lib/systemd/system/node-exporter.service
systemctl  daemon-reload
systemctl  enable   node-exporter.service
systemctl  start    node-exporter.service
systemctl  status   node-exporter.service

# ohpc-node
cp  -r  /usr/local/bin/node_exporter                   ${CHROOT}/usr/local/bin/
cp      /usr/lib/systemd/system/node-exporter.service  ${CHROOT}/usr/lib/systemd/system/node-exporter.service

chroot  ${CHROOT}   systemctl  enable   node-exporter.service

```

## ## [3. add scrape node info to master][contents]

```bash
# on master, add scrape node info. * targets is node ip address.
cat << EOF >> /etc/prometheus/prometheus.yml

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['10.1.1.200:9100']
        labels:
          note: 'master-node'
      - targets: ['10.1.1.1:9100','10.1.1.2:9100','10.1.1.3:9100','10.1.1.4:9100']
        labels:
          note: 'compute-node'

EOF

systemctl  restart  prometheus.service

```


## ## [4. Install prometheus nvidia dcgm expoter (prometheus-dcgm)][contents]
```bash

# go install
cd /tmp
export VERSION=1.15 OS=linux ARCH=amd64
wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz
tar -xzf go$VERSION.$OS-$ARCH.tar.gz
export PATH=$PWD/go/bin:$PATH

# dcgm install
yum-config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
yum clean expire-cache
yum install -y datacenter-gpu-manager
systemctl --now enable nvidia-dcgm

# dcgm-exporter install
cd /usr/local/src/
git clone https://github.com/NVIDIA/dcgm-exporter.git
cd dcgm-exporter

make binary
make install

cat << EOF > /usr/lib/systemd/system/dcgm-exporter.service
[Unit]
Description=DCGM Exporter
[Service]
ExecStart=/usr/bin/dcgm-exporter
[Install]
WantedBy=multi-user.target
EOF

# 기본으로 주석 처리된 부분 제거
grep   DCGM_FI_DEV_GPU_UTIL                               /etc/dcgm-exporter/default-counters.csv
sed -i 's/# DCGM_FI_DEV_GPU_UTIL/DCGM_FI_DEV_GPU_UTIL/g'  /etc/dcgm-exporter/default-counters.csv

# dcgm-exporter service start
chmod +x /lib/systemd/system/dcgm-exporter.service
systemctl  daemon-reload
systemctl  enable   dcgm-exporter.service
systemctl  start    dcgm-exporter.service
systemctl  status   dcgm-exporter.service

# gpu info check
curl localhost:9400/metrics
# HELP DCGM_FI_DEV_SM_CLOCK SM clock frequency (in MHz).
# TYPE DCGM_FI_DEV_SM_CLOCK gauge
# HELP DCGM_FI_DEV_MEM_CLOCK Memory clock frequency (in MHz).
# TYPE DCGM_FI_DEV_MEM_CLOCK gauge
# HELP DCGM_FI_DEV_MEMORY_TEMP Memory temperature (in C).
# TYPE DCGM_FI_DEV_MEMORY_TEMP gauge
...
DCGM_FI_DEV_SM_CLOCK{gpu="0", UUID="GPU-604ac76c-d9cf-fef3-62e9-d92044ab6e52"} 139
DCGM_FI_DEV_MEM_CLOCK{gpu="0", UUID="GPU-604ac76c-d9cf-fef3-62e9-d92044ab6e52"} 405
DCGM_FI_DEV_MEMORY_TEMP{gpu="0", UUID="GPU-604ac76c-d9cf-fef3-62e9-d92044ab6e52"} 9223372036854775794
...

# ohpc-node

yum install -y  --installroot=${CHROOT} datacenter-gpu-manager
chroot  ${CHROOT}   systemctl enable nvidia-dcgm

cp  -r  /etc/dcgm-exporter                             ${CHROOT}/etc/
cp      /usr/bin/dcgm-exporter                         ${CHROOT}/usr/bin/
cp      /usr/lib/systemd/system/dcgm-exporter.service  ${CHROOT}/usr/lib/systemd/system/dcgm-exporter.service

chroot  ${CHROOT}   systemctl  enable   dcgm-exporter.service

# prometheus.yml gpu node add
cat << EOF >> /etc/prometheus/prometheus.yml

  - job_name: 'dcgm-exporter'
    static_configs:
      - targets: ['10.1.1.200:9400']
        labels:
          note: 'master-node'
      - targets: ['10.1.1.1:9400','10.1.1.2:9400','10.1.1.3:9400','10.1.1.4:9400']
        labels:
          note: 'compute-node'
EOF

systemctl  restart  prometheus.service

```

## ## [5. Prometheus-slurm exporter ( For Centos7, Only Master )][contents]
```bash
# only master.

cd /tmp/

# Donwload go 1.15
export VERSION=1.15 OS=linux ARCH=amd64
wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz

tar -xzf go$VERSION.$OS-$ARCH.tar.gz
export PATH=$PWD/go/bin:$PATH

cd /usr/local/src/
git clone https://github.com/vpenso/prometheus-slurm-exporter.git

# Change listen on for HTTP requests.
grep -n -r 8080          prometheus-slurm-exporter/main.go
sed -i 's/:8080/:9800/'  prometheus-slurm-exporter/main.go
grep -n -r 9800          prometheus-slurm-exporter/main.go

# make slurm expoter
cd prometheus-slurm-exporter
pwd
export GOPATH=$PWD/go/modules

go mod download
go test -v *.go
go build -o bin/slurm-exporter {main,accounts,cpus,gpus,partitions,node,nodes,queue,scheduler,sshare,users}.go

# copy make file
cp bin/slurm-exporter  /usr/local/sbin/slurm-exporter

# for test.
/usr/local/sbin/slurm-exporter

# (제외) Firewall port add
#firewall-cmd --add-port=9800/tcp --permanent
#firewall-cmd --reload
#firewall-cmd --list-all

# Prometheus-slurm service add
cat << EOF > /lib/systemd/system/slurm-exporter.service
[Unit]
Description=Prometheus SLURM Exporter

[Service]
ExecStart=/usr/local/sbin/slurm-exporter
Restart=always
RestartSec=15

[Install]
WantedBy=multi-user.target
EOF

ll        /lib/systemd/system/slurm-exporter.service
chmod +x  /lib/systemd/system/slurm-exporter.service

systemctl  daemon-reload
systemctl  enable   slurm-exporter.service
systemctl  start    slurm-exporter.service
systemctl  status   slurm-exporter.service

netstat -tnlp | grep 9800

# Prometheus-config file Modified
ll -ld /etc/prometheus/prometheus.yml
cp    /etc/prometheus/prometheus.yml{,.bak}

cat << EOF >> /etc/prometheus/prometheus.yml

  - job_name: 'slurm-exporter'
    scrape_interval:  5s
    scrape_timeout:   5s

    static_configs:
      - targets: ['10.1.1.200:9800']
EOF

# restart prometheus
systemctl  restart  prometheus.service
```

### etc (systemd service PATH)

```bash
systemctl show-environment

which sinfo

# slurm-exporter.service
# [Service]
# Environment=PATH=/usr/local/slurm/bin:$PATH
```


## ## [6. Prometheus-ipmi exporter ( For Centos7, Only Master )][contents]
```bash
# only master.

cd /tmp/

# Donwload go 1.15
export VERSION=1.15 OS=linux ARCH=amd64
wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz

tar -xzf go$VERSION.$OS-$ARCH.tar.gz
export PATH=$PWD/go/bin:$PATH

cd /usr/local/src/
git clone https://github.com/soundcloud/ipmi_exporter

# make slurm expoter
cd ipmi_exporter/
pwd
make

# copy make file
cp ./ipmi_exporter   /usr/local/sbin/ipmi_exporter
/usr/local/sbin/ipmi_exporter  --version

# for test.
/usr/local/sbin/ipmi_exporter

# (제외) Firewall port add
#firewall-cmd --add-port=9290/tcp --permanent
#firewall-cmd --reload
#firewall-cmd --list-all

# Prometheus-slurm service add
cat << EOF > /lib/systemd/system/ipmi-exporter.service
[Unit]
Description=Prometheus IPMI Exporter

[Service]
ExecStart=/usr/local/sbin/ipmi_exporter
Restart=always
RestartSec=15

[Install]
WantedBy=multi-user.target
EOF

ll /lib/systemd/system/ipmi-exporter.service
chmod +x /lib/systemd/system/ipmi-exporter.service

systemctl daemon-reload
systemctl enable ipmi-exporter.service
systemctl start  ipmi-exporter.service
systemctl status ipmi-exporter.service
netstat -tnlp | grep 9290


cat << EOF >> /etc/prometheus/prometheus.yml

  - job_name: 'ipmi-exporter'
    scrape_interval:  5s
    scrape_timeout:   5s

    static_configs:
      - targets: ['10.1.1.200:9290']
EOF

# restart prometheus
systemctl  restart  prometheus.service
```


## ## [7. Grafana Install (on Master)][contents]

```bash
# https://grafana.com/grafana/download?pg=get&plcmt=selfmanaged-box1-cta1  

yum -y install  https://dl.grafana.com/enterprise/release/grafana-enterprise-9.2.6-1.x86_64.rpm

which grafana-server
which grafana-cli

systemctl daemon-reload
systemctl enable grafana-server.service

grafana-cli plugins install grafana-clock-panel
systemctl   restart   grafana-server.service

# Firewall Port Open 3000
firewall-cmd --list-all | grep 3000
firewall-cmd --add-port=3000/tcp
firewall-cmd --add-port=3000/tcp --permanent
firewall-cmd --list-all | grep 3000

# Open Broser to http://localhost:3000
# id : admin / pass : admin
```

## ## [8. Grafana Report to PDF][contents]

```bash
# pdf 를 생성시키는데 필요한 패키지 설치.
yum -y  install  texmaker texlive texlive-*.noarch

which pdflatex

### 그라파나가 패널을 이미지로 렌더링 하기위해 필요한 패키지 설치.
# https://grafana.com/docs/grafana/latest/administration/image_rendering/  

grafana-cli plugins install grafana-image-renderer

systemctl   restart   grafana-server

yum -y  install libXcomposite libXdamage libXtst cups libXScrnSaver pango atk \
adwaita-cursor-theme adwaita-icon-theme at at-spi2-atk at-spi2-core cairo-gobject \
colord-libs dconf desktop-file-utils ed emacs-filesystem gdk-pixbuf2 glib-networking \
gnutls gsettings-desktop-schemas gtk-update-icon-cache gtk3 hicolor-icon-theme \
jasper-libs json-glib libappindicator-gtk3 libdbusmenu libdbusmenu-gtk3 libepoxy \
liberation-fonts liberation-narrow-fonts liberation-sans-fonts liberation-serif-fonts \
libgusb libindicator-gtk3 libmodman libproxy libsoup libwayland-cursor libwayland-egl \
libxkbcommon m4 mailx nettle patch psmisc redhat-lsb-core redhat-lsb-submod-security \
rest spax time trousers xdg-utils xkeyboard-config


### grafana-reporter 설치.

cd /tmp/

# Donwload go 1.15
export VERSION=1.15 OS=linux ARCH=amd64
wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz

tar -xzf go$VERSION.$OS-$ARCH.tar.gz
export PATH=$PWD/go/bin:$PATH
export GOPATH=/tmp/GOPATH

go get github.com/IzakMarais/reporter/...
go install -v github.com/IzakMarais/reporter/cmd/grafana-reporter

ll ${GOPATH}/bin/grafana-reporter

# Firewall Port Open 8686
firewall-cmd --list-all | grep 8686
firewall-cmd --add-port=8686/tcp
firewall-cmd --add-port=8686/tcp --permanent
firewall-cmd --list-all | grep 8686

# test.
${GOPATH}/bin/grafana-reporter

# grafana-reporter service add

cp ${GOPATH}/bin/grafana-reporter  /usr/local/sbin/grafana-reporter
cat << EOF > /lib/systemd/system/grafana-reporter.service
[Unit]
Description=Grafana-Reporter

[Service]
ExecStart=/usr/local/sbin/grafana-reporter
Restart=always
RestartSec=15

[Install]
WantedBy=multi-user.target
EOF

ll       /lib/systemd/system/grafana-reporter.service
chmod +x /lib/systemd/system/grafana-reporter.service

systemctl daemon-reload
systemctl enable grafana-reporter.service
systemctl start  grafana-reporter.service
systemctl status grafana-reporter.service

netstat -tnlp | grep   grafana-repo

```
### ### apitoken, PDF Gen Link
- http://localhost:8686/api/v5/report/{dashboardUID}?apitoken=12345&var-host=devbox  
- apitoken : Configuration => API Keys => Add API Key  
- dashboard settings => Links => Add Dashboard Link => Type Link...   

## ## [9. Grafana Report PDF Gen cli][contents]
#### #### CLI 모드에서 Report 파일 만드는 방법으로 API Key 값과  Dashboard UUID가 필요합니다.  
#### #### Report 범위 지정 시 사용되는 시간은 Unix Time을 사용하기 때문에 변환 해야 합니다.    

```bash
# 기본API KEY 값, 대시보드 UUID 변수 선언
GRAFANA_API_KEY="여기에 키값을 입력"
DAILY_BOARD_UUID="대시보드 UUID 입력"
WEEKL_BOARD_UUID="대시보드 UUID 입력"
MONTH_BOARD_UUID="대시보드 UUID 입력"

# DAILY Report 생성할 경우
# grafana는 시간 단위가 밀리세컨드 3자리까지 표기
STA_DAY=$(date -d "2021-05-01" +%s%3N)
END_DAY=$(date -d "2021-05-02" +%s%3N)

# Weekly Report 생성할 경우
# grafana는 시간 단위가 밀리세컨드 3자리까지 표기
STA_DAY=$(date -d "2021-05-01" +%s%3N)
END_DAY=$(date -d "2021-05-08" +%s%3N)

# Monthly Report 생성할 경우
# grafana는 시간 단위가 밀리세컨드 3자리까지 표기
STA_DAY=$(date -d "2021-05-01" +%s%3N)
END_DAY=$(date -d "2021-06-01" +%s%3N)

# 보고서 출력시 파일 이름 설정
OUTFILE="Daily_Output"
OUTFILE="Weekl_Output"
OUTFILE="Month_Output"

grafana-reporter -cmd_enable=1 -cmd_apiKey $GRAFANA_API_KEY -ip localhost:3000 -cmd_dashboard $DAILY_BOARD_UUID -cmd_ts "from=$STA_DAY&to=$END_DAY" -cmd_o $OUTFILE.pdf

```

***

### [Grafana dashboards][https://grafana.com/grafana/dashboards]

#### Node Exporter for Prometheus Dashboard EN v20201010
https://grafana.com/grafana/dashboards/11074

#### Prometheus Node Exporter Full
https://grafana.com/grafana/dashboards/1860

#### Node Exporter Full with Node Name
https://grafana.com/grafana/dashboards/10242

#### Node Exporter Server Metrics
https://grafana.com/grafana/dashboards/405

#### GPU Nodes v2
https://grafana.com/grafana/dashboards/11752

#### NVIDIA DCGM Exporter Dashboard
https://grafana.com/grafana/dashboards/12239

#### slurm
https://grafana.com/grafana/dashboards/4323

***



## ## [END.][contents]
