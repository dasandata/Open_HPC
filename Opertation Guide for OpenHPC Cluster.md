# Guide of Opertation for OpenHPC Cluster
\# 참조 링크 : http://openhpc.community/  
\# OpenHPC Cluster를 운영 하면서 필요한 명령어들 입니다.  

***
## # 목차
[1. 사용자 추가 (add user)](http://warewulf.lbl.gov/trac)  
[2. 계산 노드에 프로그램 추가 (Install App on nodes)](http://warewulf.lbl.gov/trac)  
[3. 네트워크 마운트 포인트 추가 (Add NFS Mount on nodes)]  
[4. Add Module Example]  
[5. Nodes Power On / Off]  
[6. 마스터(로그인) 노드의 hostname or IP Address 변경.]  
[7. 계산 노드 추가 및 변경 (mac address)]  

***

### 1. 사용자 계정 관리 (추가 및 제거)
#### 1-1. 사용자 계정 추가  
클러스터에 새로운 사용자가 추가된 경우 아래와 같은 작업을 수행하여  
새로운 사용자가 계산 노드들을 사용할 수 있게 합니다.  
```
# testuser 계정 추가.
[root@master:~]# wwuseradd testuser
Adding user to this master
Syncing user data to Warewulf
Updating nodes...

[root@master:~]# passwd testuser
Changing password for user testuser.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.

```
#### 1-2. 사용자 계정 제거
더이상 사용되지 않는 사용자 계정을 제거 합니다.  
```
# testuser 사용자 제거
[root@master:~]# userdel testuser

# testuser 사용자 디렉토리 제거
[root@master:~]# rm -rf /home/testuser/
```

#### 1-3. wwgetfiles error 가 발생한 경우
```
# error 발생한노드 접속
[root@master:~]# ssh node1

# wwgetfiles  확인
[root@node1 ~]# ls -l /tmp/wwgetfiles.lock

# wwgetfiles 지우기
[root@node1 ~]# rm -rf /tmp/wwgetfiles.lock

# wwgetfiles 생성
[root@node1 ~]# /warewulf/bin/wwgetfiles
```


### 2. 계산 노드에 프로그램 추가 (Install App on nodes)
OpenHPC 는 [Warewulf](http://warewulf.lbl.gov/trac) 의 [DiskLess](https://en.wikipedia.org/wiki/Diskless_node) 방식을 기반으로 구성 되어 있어 (재 부팅시 배포 이미지를 내려 받음)  
계산노드에 패키지(프로그램) 를 설치하는 경우 실행되고 있는 계산노드에 설치하는 것 뿐만 아니라  
노드 재부팅후 또는 추가 되는 노드에 동일한 상태가 적용 되도록 노드의 배포 이미지에도 설치 되어야 합니다.  

#### 2-1. 우선 현재 동작중인 노드에 yum 명령을 이용하여 프로그램 을 설치 합니다.
```
** 아래 예제는 git 을 설치 합니다.
** 여러 노드에 명령을 한꺼번에 전달하기 위해 pdsh 를 사용 합니다.
** 노드의 범위는 [ ] 사이에 넣습니다.
** node[1-2] 의 경우 node1 과 node2 를 뜻합니다.

[root@Master:~]# pdsh -w node[1-2] 'yum install -y git'
node1: Loaded plugins: fastestmirror
node1: Loading mirror speeds from cached hostfile
node1:  * base: data.nicehosting.co.kr
node1:  * epel: mirrors.ustc.edu.cn
node1:  * extras: data.nicehosting.co.kr
node1:  * updates: data.nicehosting.co.kr
node2: Loaded plugins: fastestmirror
node1: Resolving Dependencies
node1: --> Running transaction check
node1: ---> Package git.x86_64 0:1.8.3.1-12.el7_4 will be installed

<생략>

node2:
node2: Installed:
node2:   git.x86_64 0:1.8.3.1-12.el7_4                                                 
node2:
node2: Dependency Installed:
node2:   libgnome-keyring.x86_64 0:3.12.0-1.el7  perl-Error.noarch 1:0.17020-2.el7     
node2:   perl-Git.noarch 0:1.8.3.1-12.el7_4      perl-TermReadKey.x86_64 0:2.30-20.el7
node2:
node2: Complete!
[root@Master:~]#
```
#### 2-2. 노드의 부팅 이미지에도 yum 명령을 이용하여 프로그램을 설치 합니다.

```
[root@Master:~]#
[root@Master:~]# yum --installroot=/opt/ohpc/admin/images/centos7.4/  install  -y  git
Loaded plugins: fastestmirror, langpacks, priorities
OpenHPC                                                      | 1.6 kB  00:00:00     
OpenHPC-updates                                                                                    | 1.2 kB  00:00:00     
base                                                         | 3.6 kB  00:00:00     
epel/x86_64/metalink                                         | 5.4 kB  00:00:00     
epel                                                         | 4.7 kB  00:00:00     
extras                                                       | 3.4 kB  00:00:00     
updates                                                      | 3.4 kB  00:00:00     
(1/2): epel/x86_64/primary_db                                | 6.4 MB  00:00:01     
(2/2): epel/x86_64/updateinfo                                | 919 kB  00:00:02     
Determining fastest mirrors
 * base: ftp.kaist.ac.kr
 * epel: mirrors.ustc.edu.cn
 * extras: ftp.kaist.ac.kr
 * updates: ftp.kaist.ac.kr
139 packages excluded due to repository priority protections
Resolving Dependencies
--> Running transaction check
---> Package git.x86_64 0:1.8.3.1-12.el7_4 will be installed

<생략>

Installed:
  git.x86_64 0:1.8.3.1-12.el7_4                                                                                           

Dependency Installed:
  libgnome-keyring.x86_64 0:3.12.0-1.el7     perl-Error.noarch 1:0.17020-2.el7     perl-Git.noarch 0:1.8.3.1-12.el7_4    
  perl-TermReadKey.x86_64 0:2.30-20.el7     

Complete!
[root@Master:~]#
[root@Master:~]#
```

#### 2-3. 노드의 부팅 이미를 갱신 시킵니다.
```
[root@Master:~]# wwvnfs --chroot /opt/ohpc/admin/images/centos7.4
Using 'centos7.4' as the VNFS name
Creating VNFS image from centos7.4
Compiling hybridization link tree                           : 2.88 s
Building file list                                          : 2.11 s
Compiling and compressing VNFS                              : 53.87 s
Adding image to datastore                                   : 60.00 s
Total elapsed time                                          : 118.87 s
[root@Master:~]#
[root@Master:~]#
```

***


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
이제 계산노드의 전원을 켜서 확인 합니다.   
(부팅순서 1순위가 네트워크 - pxe - 로 설정 되었는지 확인 합니다.)  




## End.
