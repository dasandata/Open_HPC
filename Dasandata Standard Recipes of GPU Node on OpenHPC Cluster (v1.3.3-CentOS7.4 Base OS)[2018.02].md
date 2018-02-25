# Dasandata Standard Recipes of GPU Node on OpenHPC Cluster (v1.3.3-CentOS7.4 Base OS)[2018.02]


## # Check dasan_ohpc_variable.sh
```bash
[root@master:~]#
[root@master:~]# pwd
/root
[root@master:~]#
[root@master:~]# cat dasan_ohpc_variable.sh
#!/bin/bash

# 클러스터 이름.
export CLUSTER_NAME=OpenHPC-Dasandata

# MASTER 의 이름 과 IP.
export MASTER_HOSTNAME=$(hostname)
export MASTER_IP=10.1.1.1
export MASTER_PREFIX=24

# 인터페이스 이름.
export EXT_NIC=em2 # 외부망.
export INT_NIC=p1p1 # 내부망.
export NODE_INT_NIC=p1p1 # node 들의 내부망 인터페이스 명.

# NODE 의 이름, 수량, 사양.
export NODE_NAME=node
export NODE_NUM=3
export NODE_RANGE="[1-3]"  # 전체 노드가 3개일 경우 1-3 / 5대 일 경우 [1-5]

# NODE 의 CPU 사양에 맞게 조정.
# 물리 CPU가 2개 이고, CPU 당 코어가 10개, 하이퍼스레딩은 켜진(Enable) 상태 인 경우.  
export SOCKETS=2          ## 물리 CPU 2개
export CORESPERSOCKET=6  ## CPU 당 코어 10개
export THREAD=2           ## 하이퍼스레딩 Enable

# 노드 배포 이미지 경로.
export CHROOT=/opt/ohpc/admin/images/centos7.4

# end of file.
[root@master:~]#
[root@master:~]#
```
## # Load to $CHROOT variable

```bash
[root@master:~]# source dasan_ohpc_variable.sh
[root@master:~]#
[root@master:~]# echo $CHROOT
/opt/ohpc/admin/images/centos7.4
[root@master:~]#

```

## # Install cuda-repo on node vnfs images
```bash
curl  -L -o  cuda-repo-rhel7-8.0.61-1.x86_64.rpm \
 http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-8.0.61-1.x86_64.rpm

yum -y install --installroot ${CHROOT} cuda-repo-rhel7-8.0.61-1.x86_64.rpm \
 >> dasan_log_ohpc_cudarepo-on-node.txt
tail dasan_log_ohpc_cudarepo-on-node.txt

cat ${CHROOT}/etc/yum.repos.d/cuda.repo

```
*output example>*
```
[root@master:~]# curl  -L -o  cuda-repo-rhel7-8.0.61-1.x86_64.rpm \
>  http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-8.0.61-1.x86_64.rpm
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  6363  100  6363    0     0  21969      0 --:--:-- --:--:-- --:--:-- 22248
[root@master:~]#
[root@master:~]# yum -y install --installroot ${CHROOT} cuda-repo-rhel7-8.0.61-1.x86_64.rpm \
>  >> dasan_log_ohpc_cudarepo-on-node.txt
[root@master:~]#
[root@master:~]# tail dasan_log_ohpc_cudarepo-on-node.txt
Running transaction test
Transaction test succeeded
Running transaction
  Installing : cuda-repo-rhel7-8.0.61-1.x86_64                              1/1
  Verifying  : cuda-repo-rhel7-8.0.61-1.x86_64                              1/1

Installed:
  cuda-repo-rhel7.x86_64 0:8.0.61-1                                             

Complete!
[root@master:~]#
[root@master:~]# cat ${CHROOT}/etc/yum.repos.d/cuda.repo
[cuda]
name=cuda
baseurl=http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64
enabled=1
gpgcheck=1
gpgkey=http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/7fa2af80.pub
[root@master:~]#
```
## # Check to available list cuda repo on node vnfs image
```bash
chroot ${CHROOT} yum --disablerepo="*" --enablerepo="cuda" list available
```
*output example>*
```bash
[root@master:~]# chroot ${CHROOT} yum --disablerepo="*" --enablerepo="cuda" list available
Loaded plugins: fastestmirror
cuda                                                     | 2.5 kB     00:00     
cuda/primary_db                                            | 125 kB   00:00     
Loading mirror speeds from cached hostfile
Available Packages
cuda.x86_64                                      9.1.85-1                   cuda
cuda-7-0.x86_64                                  7.0-28                     cuda
cuda-7-5.x86_64                                  7.5-18                     cuda
cuda-8-0.x86_64                                  8.0.61-1                   cuda
cuda-9-0.x86_64                                  9.0.176-1                  cuda
cuda-9-1.x86_64                                  9.1.85-1                   cuda
cuda-command-line-tools-7-0.x86_64               7.0-28                     cuda
cuda-command-line-tools-7-5.x86_64   
<일부 생략>
```





# END.
