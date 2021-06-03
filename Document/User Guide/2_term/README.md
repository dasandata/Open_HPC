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
| alias         | 별칭, 자주 사용하는 명령어를 특정 문자로 입력해두고 간편하게 사용하기 위한 것으로 command alias 라고도 합니다. <br> 시스템에 기본으로 설정된 alias 가 몇개 있으며, 필요한 명령을 추가 할 수 있습니다. |

## [## 2.2  PATH, ENV(Environment)][userguide]
| 용어         |  내용|
|-------------|------|
| PATH        | 프로그램의 실행파일이나 실행에 필요한 라이브러리 경로를 정의하는 환경변수, <br> 어떤 PATH 가 정의되어 있는가에 따라 같은 명령어라도 다른 버젼이 실행될 수 있다.|
| ENV(Environment) | 현재 정의되어 있는 모든 환경변수 통해 구성되어 있는 현재 환경 |
| Module      | 관리자에 의해 사전에 설치된 프로그램을 사용하기 위해서 <br> 사전에 정의된 환경변수(PATH)를 불러오거나(load) 전환(swap) 할 수 있는 도구 |
| Anaconda    | 사용자의 Home 디렉토리에 설치해서 다양한 버젼의 Python 을 설치하고 전환하며 사용할 수 있게 해주는 도구 |
| Container   | 운영체제 수준의 가상화 기술로 리눅스 커널을 공유하면서 프로세스를 격리된 환경에서 실행하는 기술입니다. <br> 하드웨어를 가상화 하는 가상 머신과 달리 커널을 공유하는 방식이기 때문에 <br> 실행 속도가 빠르고, 성능 상의 손실이 거의 없습니다. <br> <br> 컨테이너로 실행된 프로세스는 커널을 공유하지만, <br> 리눅스 네임스페이스 (Linux namespaces), 컨트롤 그룹 (cgroup), 루트 디렉터리 격리 (chroot) 등의  <br> 커널 기능을 활용해 격리되어 실행됩니다. <br> 이러한 격리 기술 덕분에 호스트 머신에게는 프로세스로 인식되지만, <br> 컨테이너 관점에서는 마치 독립적인 환경을 가진 가상 머신처럼 보입니다. |
| Docker      | 닷클라우드 dotCloud 의 솔로몬 하이크가 파이콘 2013 USPyCon 2013 US에서 처음 발표한 컨테이너 런타임 <br> Docker 공개 저장소 (http://dockerhub.com) 을 통해서 다양한 컨테이너 이미지를 내려받아 사용할 수 있습니다. |
| Singularity | 과학 및 애플리케이션 기반 워크로드 와 HPC 클러스터 환경에 최적화 된 컨테이너 솔루션 입니다. <br> Docker 저장소의 컨테이너 이미지를 내려받아 사용할 수 있습니다. |

## [## 2.3  Resource Manager][userguide]
| 용어         |  내용    |
|-------------|----------|
| OpenPBS     | Portable Batch System - OpenSource |
| PBSPro      | Portable Batch System - Altair Engineering |
| Torque      | Terascale Open-source Resource and QUEue Manager - Adaptive Computing Enterprises |
| SLURM       | Simple Linux Utility Resource Management -schedmd |
| Resource    | CPU, Memory, GRES(GPU)등 애플리케이션의 작업에 활용되는 하드웨어 구성요소, node 의 집합체 |
| node        | 작업이 수행되는 컴퓨터 또는 서버 |
| submit      | 작업 제출 (Resource 요청) |
| job         | node 에서 수행되는 작업 |
| interactive job | 명령 한줄씩 입력하고 결과를 확인하는 **대화형** 작업 |
| batch job       | 명령어 모음을 스크립트 파일로 작성되어 제출되고 결과가 파일로 저장되는 **일괄형** 작업 |
| queue       | 클러스터 내의 모든 Resource 가 사용중인 경우 제출된 작업이 대기하는 줄  |
| Partition   | node 들을 종류별, 용도별로 구분하여 나누어 둔 논리 그룹  |
| QoS         | Quality of Service / 특정한 작업(Job)에 대해 우선순위/제한 을 적용하기 위한 지정 값  |
| GRES         | Generic Resource / 보통, node 에 장착된 GPU 를 뜻 합니다. |
| TRES         | Trackable RESources / node 에서 사용중인 Resource 사용현황 추적 및 사용률 계산  |

## [## 2.4 Linux Bash 정규 표현식(Regular Expressions) 및 File stream][userguide]
| 용 어           |  내 용   |
|-----------------|---------|
| ~               |  사용자의 HOME Directory |
| $VAR_NAME       |  변수(variable)  |
| #               |  주석   |
| \|              |  표준 출력을 표준 입력으로 보냄  |
| >               |  표준 출력을 파일로 저장 (덮어쓰기)  |
| >>              |  표준 출력을 파일로 저장 (끝에 추가하기)  |
| ;               |  줄넘김 (enter 와 같은기능), 한줄에 여러개의 명령을 사용할 수 있음.  |
| \               |  다음줄로 넘기고 이어서 실행 (한줄로 실행), 명령이 길어져서 알아보기 힘들때 사용.|
| <명령> && <명령> |  앞서 실행한 명령이 잘 실행 되면 다음 명령을 실행  |
| <명령> \|\| <명령> |  앞서 실행한 명령이 실패하면, 다음 명령을 실행  |

***
## [## 끝][userguide]
