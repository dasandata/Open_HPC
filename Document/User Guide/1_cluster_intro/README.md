# [1. 클러스터 개요][1]

안녕하세요 다산데이타 입니다.   
클러스터를 왜 구축하고 어떤 구성요소로 되어 있는지 알아 보겠습니다.  


## [1.1.  클러스터 구축 목적][1]

|구 분|내  용|
|:-:|---|
| 1 | 다수의 사용자가 다수의 시스템을 사용하기 위해서.|
| 2 | 운영체제 설치, 응용프로그램 및 라이브러리 설치, <br> 사용자 계정 동기화 등 시스템 사용환경을 구축하는 작업을 간소화.  |
| 3 | 시스템을 좀더 효율적으로 사용.   


***

아래 표와 같이 네 가지 상황을 살펴 보겠습니다.  

<img src="https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/dasandata_cluster_keymap1.png" width="600">  

***

시스템의 수가 많아질 경우  
OS 와 프로그램 설치 작업이 반복되며,  
변경사항이 발생할 때마다 모든 시스템에 반영하기 위한 작업도 반복적으로 해야 합니다.  

사용자의 수가 많아지는 경우  
다른 사용자가 시스템을 사용중인지, 언제까지 사용하는지 확인하고,
끝나기를 기다렸다가 작업을 시작해야 하는 상황이 발생 합니다.  

이러한 문제를 해결하기 위해 **배포 및 관리도구**를  
그리고 자원을 효율적으로 분배하기 위한 **리소스 매니저**를 사용하게 됩니다.  

<img src="https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/dasandata_cluster_keymap2.png" width="600">  


<img src="https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/dasandata_cluster_keymap3.png" width="600">  


<img src="https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/dasandata_cluster_keymap4.png" width="600">  

***

저희는 배포 및 관리도구 와 리소스 매니저를 손쉽게 설치하고 구성할 수 있는 구성도구인  
**[OpenHPC][2]** 를 이용하여 **[Slurm][3]** 과 함께 클러스터를 구성하고 있습니다.

***

## [1.2. 클러스터의 구성 요소][1]

HPC 클러스터는 다음과 같은 요소들로 구성되어 있습니다.  

|구분 | 요소                         | 종류|
|:---:|-----------------------------|-------|
| H/W | 독립된 전용(내부) 네트워크    | Ethernet, InfiniBand|
| H/W | 공유 저장소(스토리지)        | NFS(Network File Sytem), <br> PFS(Parallel File System), DFS(Distributed File System)|
| H/W | 자원(Resource)              | CPU, Memory(RAM), GPU(VGA Card)|
| S/W | 응용프로그램 실행환경 관리도구 | Anaconda, Module, Container (Docker, Singularity) |
| S/W | 응용프로그램                 | C, Python, Pytorch, Tensorflow|
| S/W | 자원 관리자(Resource Manager) | SLURM(Simple Linux Utility Resource Management), <br> PBS(Portable Batch System)|

<img src="https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/openhpc-project-overview-and-updates-8-638.jpg">  

***

이러한 구성요소중 자원관리자(Resource Manager) 는
보통 HPC 클러스터 환경에서만 접할 수 있는 도구로,

기본적으로 아래 그림과 같이(Backfil) 작업의 크기에 따라 가용한 자원에 작업을 분배하고  
자원이 모두 사용중일 때는 대기열(queue) 에 작업을 쌓아 두었다가  
사용가능한 자원이 확보되면 대기하고 있던 작업을 시작시켜주는 역할을 하게 됩니다.

### [Resource Manager 의 Backfill][1]

<img src="https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/backfill.gif" width="600">  

또한 무분별한 자원 점유를 방지하고 공평한 자원분배 하거나   
특정 사용자나 사용자 그룹의 작업을 우선 배정하는  
작업배정 우선순위(Priority) 조정 기능도 제공 합니다.  

[SLURM Priority_and_Fair_Trees](https://slurm.schedmd.com/SLUG19/Priority_and_Fair_Trees.pdf)

<img src="https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/SLURM_Priority_and_Fair_Trees.png" width="600">


***


[1]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide#-%EB%AA%A9%EC%B0%A8
[2]: http://openhpc.community/
[3]: https://slurm.schedmd.com/
