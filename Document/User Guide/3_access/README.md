[userguide]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide#-%EB%AA%A9%EC%B0%A8
[ohpc]: http://openhpc.community/
[slurm]: https://slurm.schedmd.com/
[3]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide/3_access

# [# 3.   접속 방법][userguide]

안녕하세요 다산데이타 입니다.  
HPC 클러스터 로그인 노드 에 접속하는 방법을 알아 보겠습니다.  

## [## 3.1  윈도우즈용 Mobaxterm][3]

윈도우즈의 경우 SSH 접속과 SCP를 통한 파일전송,  
그리고 X11Forwading 기능을 한번에 사용할 수 있는 **mobaxterm** 을 사용 하는 것을 권장 하고 있습니다.  
<br>
아래 링크에서 다운로드 받아 사용할 수 있습니다.  

### https://mobaxterm.mobatek.net/download.html  
(Home Edition / Installer edition 으로 설치)  

설치가 끝나면 **"Start local terminal"** 버튼을 클릭하여 터미널 창을 열 수 있습니다.  
터미널 창이 열리면 아래와 같은 형식으로 사용자 ID 와 IP 주소를 입력하고 로그인 노드에 접속합니다.  
패스워드는 자릿수 유출방지를 위해 입력 중 표시되지 않습니다.  

```bash
ssh  -XCY  <USER ID>@<IP ADDRESS>

# Exmple
ssh -XCY  honggildong@192.168.0.55
```

## [## 3.2  Mac OS Terminal][3]

Mac OS 는 terminal 프로그램이 기본적으로 제공되지만  
X11Forwading 기능을 사용하기 위해 **xquartz** 가 설치되고 실행중이어야 합니다.  

### https://www.xquartz.org/

xquartz 설치가 완료 되었다면 실행 한 후 mac os 의 terminal 을 열고  
아래와 같은 형식으로 사용자 ID 와 IP를 입력하고 클러스터에 접속합니다.  
패스워드는 자릿수 유출방지를 위해 입력 중 표시되지 않습니다.  

```bash
ssh  -XCY  <USER ID>@<IP ADDRESS>

# Exmple
ssh -XCY  honggildong@192.168.0.55
```

## [## 3.3  Linux 의 Terminal][3]

Linux 는 별도의 프로그램 설치 없이도 X11Forwading 을 사용할 수 있습니다.  

terminal 을 열고 아래와 같은 형식으로 사용자 ID 와 IP를 입력하고 클러스터에 접속합니다.  
패스워드는 자릿수 유출방지를 위해 입력 중 표시되지 않습니다.  

```bash
ssh  -XCY  <USER ID>@<IP ADDRESS>

# Exmple
ssh -XCY  honggildong@192.168.0.55
```

## [## 3.4 클러스터 접속 후 확인 사항][3]

클러스터의 로그인 노드에 접속 되었다면 아래 명령을 통해  
현재 접속자 목록, 노드의 cpu 사용률, GPU 사용률,  
현재 디렉토리의 위치, home 디렉토리의 사용량 등을 확인할 수 있습니다.  

```bash
# Show who is logged on and what they are doing.
w

# Tell how long the system has been running & CPU load average
uptime

# provides monitoring and management capabilities for each of NVIDIA's devices
nvidia-smi

# print name of current/working directory
pwd

# estimate file space usage
echo ~  # ~ == home 디렉토리
du --human-readable  --max-depth=0  ~

```

***
## [## 끝][userguide]
