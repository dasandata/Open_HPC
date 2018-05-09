# Dasandata Opertation Guide of OpenHPC Cluster
\# 참조 링크 : http://openhpc.community/  
\# OpenHPC Cluster를 운영 하면서 필요한 명령어들 입니다.  

용어  
마스터(로그인) 노드 :  
계산노드          :  

***
## # 목차
[1. 사용자 추가 (add user)](http://warewulf.lbl.gov/trac)  
[2. 계산 노드에 프로그램 추가 (Install App on nodes)](http://warewulf.lbl.gov/trac)  

***

### 1. 사용자 추가 (add user)
클러스터에 새로운 사용자가 추가된 경우 아래와 같은 작업을 수행하여
새로운 사용자가 계산 노드들을 사용할 수 있게 합니다.
```bash

wwshuseradd

```


### 2. 계산 노드에 프로그램 추가 (Install App on nodes)
OpenHPC 는 [Warewulf](http://warewulf.lbl.gov/trac) 의 [DiskLess](https://en.wikipedia.org/wiki/Diskless_node) 방식을 기반으로 구성 되어 있어 (재부팅시 배포이미지를 내려 받음)  
계산노드에 패키지(프로그램) 를 설치하는 경우 실행되고 있는 계산노드에 설치하는 것 뿐만 아니라  
노드 재부후 또는 추가 되는 노드에 동일한 상태가 적용 되도록 노드의 배포 이미지에도 설치 되어야 합니다.  
```bash

```

### 3. 네트워크 마운트 포인트 추가 (Add NFS Mount on nodes)
하드디스크 또는 스토리지를 추가로 장착하게 되어, 계산 노드들에서 사용할 수 있는 공유 저장 공간이  
추가로 확보된 경우 마스터(로그인) 노드에 공유 설정을 추가하고, 노드에서 mount 하는 방법 입니다.  
```bash

```

### 4. Add Module Example
Python 3.5.x 와 Python 3.6.x 버젼을 nfs 공유 디렉토리에 컴파일 하여 설치 하고,  
모듈(module) 파일을 생성하여 사용하는 방법을 설명 합니다.  

#### 4.1 Install Python
Python 다운받고 컴파일 하여 설치 합니다.  
```bash

```


### 5. Nodes Power On / Off
#### Power On
- ipmi (iDrac)
- WOL (Wake On Lan)

#### Power Off
- ipmi (iDrac)
- pdsh -w

```bash

```


### 6. 마스터(로그인) 노드의 hostname or IP Address 변경.

```bash

grep -r ${OLD_HOSTNAME} /etc/


```


### 7. 계산 노드 추가 및 변경 (mac address)
새로운 계산노드가 추가 되거나, 고장 등으로 노드를 교체해야 할 때   
마스터(로그인) 노드에 새로운 노드 정보를 추가 / 변경하는 방법 입니다.   
```bash

wwsh node add


wwsh node set

wwsh pxe update
systemctl restart dhcpd

```



## End.
