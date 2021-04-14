# [1. 클러스터 개요][1]

안녕하세요 다산데이타 입니다.   
클러스터를 왜 구축하고 어떤 구성요소로 되어 있는지 알아 보겠습니다.  


## [1.1.  클러스터 구축 목적][1]

첫째) 다수의 사용자가 다수의 시스템을 사용하기 위해서.  

둘째) 운영체제 설치, 응용프로그램 및 라이브러리 설치,  
사용자 계정 동기화 등 시스템 사용환경을 구축하는 작업을 간소화.  

셋째) 시스템을 좀더 효율적으로 사용.   

***

아래 표와 같이 네 가지 상황을 살펴 보겠습니다.  

<img src="https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/dasandata_cluster_keymap1.png" width="600">  

***

시스템의 수가 많아질 경우  
OS 와 프로그램 설치 작업이 반복되며, 변경사항이 발생할 때마다  
모든 시스템에 반영하기 위한 작업도 반복 됩니다.   

사용자의 수가 많아지는 경우  
여러 사람들이 동시에 사용하게 되기 때문에 다른 사용자가 시스템을 사용중인지,  
언제까지 사용하는지 확인하고, 끝나기를 기다렸다가 작업을 시작해야 하는 상황이 발생 합니다.  

이러한 문제를 해결하기 위해 **배포 및 관리도구**를  
그리고 자원을 효율적으로 분배하기 위한 **리소스 매니저**를 사용하게 됩니다.  

<img src="https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/dasandata_cluster_keymap2.png" width="600">  


<img src="https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/dasandata_cluster_keymap3.png" width="600">  


<img src="https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/dasandata_cluster_keymap4.png" width="600">  

### [Resource Manager 의 Backfill][1]

![Backfill](https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/backfill.gif)

***

저희는 배포 및 관리도구 와 리소스 매니저를 손쉽게 설치하고 구성할 수 있는 구성도구인  
**[OpenHPC][2]** 를 통해 클러스터를 구성하고 있습니다.



***

## [1.2. 클러스터의 구성 요소][1]

  클러스터의 구성요소





[1]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide#-%EB%AA%A9%EC%B0%A8
[2]: http://openhpc.community/
