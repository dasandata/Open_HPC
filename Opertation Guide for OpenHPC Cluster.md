# Opertation Guide for OpenHPC Cluster
\# 참조 링크 : http://openhpc.community/  
\# OpenHPC Cluster를 운영 하면서 필요한 명령어들 입니다.  

***
## # 목차
[1. 사용자 계정 관리 (추가 및 제거)][1]  
[2. 계산 노드에 프로그램 추가 (Install App on nodes)][2]  
[3. 네트워크 마운트 포인트 추가 (Add NFS Mount on nodes)][3]  
[4. Example to Add Python3 Module on OpenHPC][4]  
[5. Nodes Power On / Off][5]  
[6. 마스터(로그인) 노드의 hostname or IP Address 변경.][6]  
[7. 계산 노드 추가 및 변경 (mac address)][7]  

[1]: https://github.com/dasandata/Open_HPC/blob/master/Opertation%20Guide%20for%20OpenHPC%20Cluster.md#1-%EC%82%AC%EC%9A%A9%EC%9E%90-%EA%B3%84%EC%A0%95-%EA%B4%80%EB%A6%AC-%EC%B6%94%EA%B0%80-%EB%B0%8F-%EC%A0%9C%EA%B1%B0
[2]: https://github.com/dasandata/Open_HPC/blob/master/Opertation%20Guide%20for%20OpenHPC%20Cluster.md#2-%EA%B3%84%EC%82%B0-%EB%85%B8%EB%93%9C%EC%97%90-%ED%94%84%EB%A1%9C%EA%B7%B8%EB%9E%A8-%EC%B6%94%EA%B0%80-install-app-on-nodes
[3]: https://github.com/dasandata/Open_HPC/blob/master/Opertation%20Guide%20for%20OpenHPC%20Cluster.md#3-%EB%84%A4%ED%8A%B8%EC%9B%8C%ED%81%AC-%EB%A7%88%EC%9A%B4%ED%8A%B8-%ED%8F%AC%EC%9D%B8%ED%8A%B8-%EC%B6%94%EA%B0%80-add-nfs-mount-on-nodes
[4]: https://github.com/dasandata/Open_HPC/blob/master/Opertation%20Guide%20for%20OpenHPC%20Cluster.md#4-example-to-add-python3-module-on-openhpc
[5]:
[6]:
[7]:



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

[root@master:~]# wwsh file resync group passwd shadow
[root@master:~]#
```
#### 1-2. 사용자 계정 제거
더이상 사용되지 않는 사용자 계정을 제거 합니다.  
```
# testuser 사용자 제거
[root@master:~]# userdel testuser

# testuser 사용자 home 디렉토리 제거
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

#### 3-1. master 의 nfs 설정 파일 위 및 현재 nfs 로 서비스 중인 경로 확인.
```
[root@master:~]# cat /etc/exports
/home *(rw,no_subtree_check,no_root_squash)
/opt/ohpc/pub *(ro,no_subtree_check)
[root@master:~]#
[root@master:~]#
[root@master:~]# exportfs
/home         	<world>
/opt/ohpc/pub 	<world>
[root@master:~]#
```

#### 3-2. 현재 node에서 nfs로 마운트 된 상태 확인. (pdsh 명령 이용)
```
[root@master:~]# pdsh -w node[1-2]  "df -hT | grep nfs"
node2: master:/home         nfs       932G  2.8G  929G   1% /home
node2: master:/opt/ohpc/pub nfs       899G   34G  865G   4% /opt/ohpc/pub
node1: master:/home         nfs       932G  2.8G  929G   1% /home
node1: master:/opt/ohpc/pub nfs       899G   34G  865G   4% /opt/ohpc/pub
[root@master:~]#
```

#### 3-3. master 에 /DATA1 이라는 nfs 서비스 경로 추가 및 설정 적용
```
[root@master:~]# cat /etc/exports
/home *(rw,no_subtree_check,no_root_squash)
/opt/ohpc/pub *(ro,no_subtree_check)
[root@master:~]#
[root@master:~]# echo "/DATA1 *(rw,no_subtree_check,no_root_squash)"  >>  /etc/exports
[root@master:~]#
[root@master:~]# cat /etc/exports
/home *(rw,no_subtree_check,no_root_squash)
/opt/ohpc/pub *(ro,no_subtree_check)
/DATA1 *(rw,no_subtree_check,no_root_squash)
[root@master:~]#
[root@master:~]# systemctl restart nfs-server.service
[root@master:~]#
[root@master:~]# exportfs
/home         	<world>
/opt/ohpc/pub 	<world>
/DATA1        	<world>
[root@master:~]#
```

#### 3-4. node 에 nfs 의 fstab 수정
```
[root@master:~]# pwd
/root
[root@master:~]#
[root@master:~]# chroot /opt/ohpc/admin/images/centos7.4
[root@master:/]# pwd
/
[root@master:/]#
[root@master:/]#
[root@master:/]# cat /etc/fstab
#GENERATED_ENTRIES#
tmpfs /dev/shm tmpfs defaults 0 0
devpts /dev/pts devpts gid=5,mode=620 0 0
sysfs /sys sysfs defaults 0 0
proc /proc proc defaults 0 0
master:/home /home nfs nfsvers=3,rsize=1024,wsize=1024,cto 0 0
master:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3 0 0
[root@master:/]#
[root@master:/]# echo "master:/DATA1 /DATA1 nfs nfsvers=3 0 0"   >> /etc/fstab   
[root@master:/]#
[root@master:/]# cat /etc/fstab
#GENERATED_ENTRIES#
tmpfs /dev/shm tmpfs defaults 0 0
devpts /dev/pts devpts gid=5,mode=620 0 0
sysfs /sys sysfs defaults 0 0
proc /proc proc defaults 0 0
master:/home /home nfs nfsvers=3,rsize=1024,wsize=1024,cto 0 0
master:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3 0 0
master:/DATA1 /DATA1 nfs nfsvers=3 0 0
[root@master:/]#
[root@master:/]# mkdir /DATA1
[root@master:/]# exit
exit
[root@master:~]#
[root@master:~]# pwd
/root
[root@master:~]#
[root@master:~]#
[root@master:~]# wwvnfs --chroot /opt/ohpc/admin/images/centos7.4  
Using 'centos7.4' as the VNFS name
Creating VNFS image from centos7.4
Compiling hybridization link tree                           : 0.33 s
Building file list                                          : 0.54 s
Compiling and compressing VNFS                              : 29.60 s
Adding image to datastore                                   : 24.16 s
Total elapsed time                                          : 54.63 s
[root@master:~]#
[root@master:~]#

** node 가 재부팅 된 후 새로운 경로가 잘 마운트 되었는지 확인 합니다.

[root@master:~]# pdsh -w node[1-2]  "reboot"

[root@master:~]#
[root@master:~]# pdsh -w node[1-2]  "df -hT | grep nfs"
node1: master:/home         nfs       932G  2.8G  929G   1% /home
node1: master:/opt/ohpc/pub nfs       899G   34G  865G   4% /opt/ohpc/pub
node1: master:/DATA1        nfs       3.7T  1.4G  3.7T   1% /DATA1
node2: master:/home         nfs       932G  2.8G  929G   1% /home
node2: master:/opt/ohpc/pub nfs       899G   34G  865G   4% /opt/ohpc/pub
node2: master:/DATA1        nfs       3.7T  1.4G  3.7T   1% /DATA1
[root@master:~]#
```


### 4. Example to Add Python3 Module on OpenHPC
Python 3.5.x 을 nfs 공유 디렉토리에 컴파일 하여 설치 하고,  
모듈(module) 파일을 생성하여 node 에서 사용하는 방법 입니다.  

#### 4-1. Module 명령어 사용 및 경로 확인
```
[root@Master:~]#
[root@Master:~]# module --version

Modules based on Lua: Version 7.7.14  2017-11-16 16:23 -07:00
    by Robert McLay mclay@tacc.utexas.edu

[root@Master:~]#
[root@Master:~]#
[root@Master:~]# ml --version

Modules based on Lua: Version 7.7.14  2017-11-16 16:23 -07:00
    by Robert McLay mclay@tacc.utexas.edu

[root@Master:~]#
[root@Master:~]# module list
No modules loaded
[root@Master:~]#
[root@Master:~]# ml list
No modules loaded
[root@Master:~]#

[root@Master:~]#
[root@Master:~]# ml av

-------------------------------------- /opt/ohpc/admin/modulefiles ---------------------------------------
   spack/0.11.2

--------------------------------------- /opt/ohpc/pub/modulefiles ----------------------------------------
   EasyBuild/3.5.3    cmake/3.10.2    gnu7/7.3.0      ohpc          prun/1.2             valgrind/3.13.0
   autotools          gnu/5.4.0       hwloc/1.11.9    papi/5.6.0    singularity/2.4.5

Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".

[root@Master:~]#
[root@Master:~]#
[root@Master:~]#
[root@Master:~]# ls -l /opt/ohpc/admin/modulefiles/
total 4
drwxr-xr-x 2 root root 4096 Apr 26 18:18 spack
[root@Master:~]#
[root@Master:~]# ls -l /opt/ohpc/pub/modulefiles/
total 44
-rw-r--r-- 1 root root  606 Nov  2  2017 autotools
drwxr-xr-x 2 root root 4096 Apr 26 16:50 cmake
drwxr-xr-x 2 root root 4096 Apr 26 18:18 EasyBuild
drwxr-xr-x 2 root root 4096 Apr 26 18:18 gnu
drwxr-xr-x 2 root root 4096 Apr 26 18:19 gnu7
drwxr-xr-x 2 root root 4096 Apr 26 18:18 hwloc
-rw-r--r-- 1 root root  754 Jun 15  2017 ohpc
drwxr-xr-x 2 root root 4096 Apr 26 18:20 papi
drwxr-xr-x 2 root root 4096 Apr 26 18:19 prun
drwxr-xr-x 2 root root 4096 Apr 26 18:22 singularity
drwxr-xr-x 2 root root 4096 Apr 26 18:18 valgrind
[root@Master:~]#
```


#### 4-2. Install Python 3.5
Python 다운받고 컴파일 하여 설치 합니다.  

##### # 현재 파이썬 버젼 확인
```bash
[root@Master:~]# python3 -V
Python 3.4.8
[root@Master:~]#
[root@Master:~]# which python3
/bin/python3
[root@Master:~]#
```

##### # Pre installation package for python3 compile.
```
yum -y install zlib-devel bzip2-devel sqlite sqlite-devel openssl-devel
```

##### # Download & Install Python 3.5.4
```bash
cd /root
PYTHON_VERSION=3.5.4

wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz

tar  xvzf  Python-${PYTHON_VERSION}.tgz

cd ~/Python-${PYTHON_VERSION}

./configure --enable-optimizations --with-ensurepip=install --enable-shared \
--prefix=/opt/ohpc/pub/apps/python3/${PYTHON_VERSION}

make -j$(nproc) ; make install
```

##### # Add Python Module
```bash
cd /root
PYTHON_VERSION=3.5.4

git clone https://github.com/dasandata/Open_HPC
cd /root/Open_HPC
git pull

cat /root/Open_HPC/Module_Template/python3.txt
echo ${PYTHON_VERSION}

mkdir /opt/ohpc/pub/modulefiles/python3
cp -a /root/Open_HPC/Module_Template/python3.txt  /opt/ohpc/pub/modulefiles/python3/${PYTHON_VERSION}
sed -i "s/{VERSION}/${PYTHON_VERSION}/"                  /opt/ohpc/pub/modulefiles/python3/${PYTHON_VERSION}

cat /opt/ohpc/pub/modulefiles/python3/${PYTHON_VERSION}

rm -rf  ~/.lmod.d/.cache

ml list
ml av

ml load python3/${PYTHON_VERSION}
ml list

python3 -V
which python3
```
##### # Verification
node 에 로그인 하여 python3.5.4 module load 해 봅니다.   
```

```

***


### 5. Nodes Power On / Off
#### # Power On
- ipmi (iDrac)
- WOL (Wake On Lan)

#### # Power Off
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
