[userguide]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide#-%EB%AA%A9%EC%B0%A8
[ohpc]: http://openhpc.community/
[slurm]: https://slurm.schedmd.com/

# [# 2.   용어][userguide]

## [## 2.1  ssh, scp, x11forwading 등][userguide]
| 용어           |  내용|
|---------------|------|
| ssh           | Secure Shell Protocol |
| scp           | Secure Copy Protocol |
| X11 Forwading | ssh로 접속한 서버의 GUI 어플리케이션을 내 컴퓨터의 화면으로 전송하는 기술 |

## [## 2.2  PATH, ENV(Environment)][userguide]
| 용어         |  내용|
|-------------|------|
| PATH        | 프로그램의 실행파일이나 실행에 필요한 라이브러리 경로를 정의하는 환경변수, <br> 어떤 PATH 가 정의되어 있는가에 따라 같은 명령어라도 다른 버젼이 실행될 수 있다.|
| ENV(Environment) | 현재 정의되어 있는 모든 환경변수 통해 구성되어 있는 현재 환경 |
| Module      | 관리자에 의해 사전에 설치된 프로그램을 사용하기 위해서 사전에 정의된 환경변수(PATH)를 불러오거나(load) 전환(swap) 할 수 있는 도구 |
| Anaconda    | 사용자의 Home 디렉토리에 설치해서 다양한 버젼의 Python 을 설치하고 전환하며 사용할 수 있게 해주는 도구 |
| Container   | 운영체제 수준의 가상화 기술로 리눅스 커널을 공유하면서 프로세스를 격리된 환경에서 실행하는 기술입니다. <br> 하드웨어를 가상화하는 가상 머신과 달리 커널을 공유하는 방식이기 때문에 실행 속도가 빠르고, <br> 성능 상의 손실이 거의 없습니다. <br> 컨테이너로 실행된 프로세스는 커널을 공유하지만, 리눅스 네임스페이스Linux namespaces, <br> 컨트롤 그룹cgroup, 루트 디렉터리 격리 등의 커널 기능을 활용해 격리되어 실행됩니다. <br> 이러한 격리 기술 덕분에 호스트 머신에게는 프로세스로 인식되지만, <br> 컨테이너 관점에서는 마치 독립적인 환경을 가진 가상 머신처럼 보입니다. |
| Docker      | 닷클라우드 dotCloud 의 솔로몬 하이크가 파이콘 2013 USPyCon 2013 US에서 처음 발표한 컨테이너 런타임 |
| Singularity | 과학 및 애플리케이션 기반 워크로드의 필요성에 의해 생성 된 컨테이너 솔루션 <br> Docker 저장소의 이미지를 내려받을 수 있다. |

## [## 2.3  Resource Manager][userguide]
| 용어         |  내용|
|-------------|------|
| OpenPBS     | Portable Batch System - OpenSource |
| PBSPro      | Portable Batch System - Altair Engineering |
| Torque      | Terascale Open-source Resource and QUEue Manager - Adaptive Computing Enterprises |
| SLURM       | Simple Linux Utility Resource Management -schedmd |

## [## 2.4 Linux File stream][userguide]
| 용 어            |  내 용   |
|----------------|---------|
| \|              |  표준 출력을 표준 입력으로 보냄  |
| ;              |  줄넘김 (enter 와 같은기능)  |
| >   |  표준 출력을 파일로 저장 (덮어쓰기)  |
| >>   |  표준 출력을 파일로 저장 (끝에 추가하기)  |
| **추가예정**    |          |

***
## [## 끝][userguide]
