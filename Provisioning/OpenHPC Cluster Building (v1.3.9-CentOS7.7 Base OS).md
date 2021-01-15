# Dasandata Standard Recipes of OpenHPC Cluster Building (v1.3.9-centos7.7 Base OS)[2020.03]

\# 참조 링크 : http://openhpc.community/  
\# Root 로 로그인 하여 설치를 시작 합니다.  
![Cluster Architecture](https://image.slidesharecdn.com/schulz-mug-17-170930151325/95/openhpc-project-overview-and-updates-8-638.jpg?cb=1506784595)

![Dasandata Logo](http://dasandata.co.kr/wp-content/uploads/2019/05/%EB%8B%A4%EC%82%B0%EB%A1%9C%EA%B3%A0_%EC%88%98%EC%A0%951-300x109.jpg)

## #목차
[1. Introduction ](https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.7%20Base%20OS).md#-1-introduction)
<br>[2. Network and Firewall Setup to Base Operating System (BOS) ](https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.7%20Base%20OS).md#-2-network-and-firewall-setup-to-base-operating-system-bos)
<br>[3. Install OpenHPC Components ](https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.7%20Base%20OS).md#-3-install-openhpc-components)
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[3-4. A (Slurm) Resource Management Services Install.](https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.7%20Base%20OS).md#-34-a-slurm-resource-management-services-install)
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[3-4. B (PBS Pro) Resource Management Services Install](https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.7%20Base%20OS).md#-34-b-pbs-pro-resource-management-services-install)
<br>&nbsp;&nbsp;&nbsp;&nbsp;[3-5 Optionally add InfiniBand support services on master node](https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.7%20Base%20OS).md#-35-optionally-add-infiniband-support-services-on-master-node)
<br>[4. Install OpenHPC Development Components ](https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.7%20Base%20OS).md#-4-install-openhpc-development-components)
<br>[5. Resource Manager Startup ](https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.7%20Base%20OS).md#-5-resource-manager-startup)
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[5-A. Start munge and slurm controller on master host](https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.7%20Base%20OS).md#-5-a-start-munge-and-slurm-controller-on-master-host)
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[5-B. Start pbspro daemons on master host](https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.7%20Base%20OS).md#-5-b-start-pbspro-daemons-on-master-host)
<br>[6. Run a Test Job ](https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.7%20Base%20OS).md#-6-run-a-test-job)
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[6-A. Slurm Submit interactive job request and use prun to launch executable](https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.7%20Base%20OS).md#-6-a-slurm-submit-interactive-job-request-and-use-prun-to-launch-executable)
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[6-B. PBS Pro Submit interactive job request and use prun to launch executable](https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.7%20Base%20OS).md#-6-b-pbs-pro-submit-interactive-job-request-and-use-prun-to-launch-executable)





***

# # [1. Introduction](#목차)
안녕하세요?  
다산데이타 입니다.  

저희가 지원해 드리고 있는 HPC Cluster Tool 중 하나인   
OpenHPC Cluster 의 설치 방법 입니다.  

대부분의 내용은 공식 메뉴얼의 순서에 맞추어 작성 하였으며,  
편의상 필요한 부분들을 제외/추가/수정 하였습니다.   

자세한 내용은 공식 Install Recipe 를 참조 하시면 좋습니다 :)  
http://openhpc.community/downloads/  

궁금하신 점이나 오류, 오탈자 등을 발견 하시면 아래 주소로 메일 부탁 드립니다 ^^;  
mail@dasandata.co.kr  

감사합니다.  

### # Root 로 로그인하여 진행.

## # 1.3 Inputs - 변수 정의 및 적용 (파일로 작성)

```bash
cd
pwd

vi /root/dasan_ohpc_variable.sh  
```

\# '/root/dasan_ohpc_variable.sh' 파일 내용.
```bash
#!/bin/bash

# 클러스터 이름.
export CLUSTER_NAME=OpenHPC_Dasandata # 변경 필요

# 노드 배포 이미지 경로 (chroot)
export CHROOT=/opt/ohpc/admin/images/centos7.7

# MASTER 의 이름 과 IP.
export MASTER_HOSTNAME=$(hostname -s)
export MASTER_IP=10.1.1.200
export MASTER_PREFIX=24

# 인터페이스 이름.
export EXT_NIC=em2 # 외부망.
export INT_NIC=em1 # 내부망.
export NODE_INT_NIC=eth0  # node 들의 내부망 인터페이스 명.

# NODE 의 이름, 수량, 사양.
export NODE_NAME=node
export NODE_NUM=<전체 노드 수>
export NODE_RANGE="[1-3]"  # 전체 노드가 3개일 경우 1-3 / 5대 일 경우 [1-5]

export sms_ipoib="10.1.1.201"
export ipoib_netmask="255.255.255.0"

# NODE 의 CPU 사양에 맞게 조정. - Slurm.conf 용
# 물리 CPU가 2개 이고, CPU 당 코어가 10개, 하이퍼스레딩은 켜진(Enable) 상태 인 경우.  
export SOCKETS=2          ## 물리 CPU 2개
export CORESPERSOCKET=10  ## CPU 당 코어 10개
export THREAD=2           ## 하이퍼스레딩 Enable

# end of file.
```

### # 변수 적용.
```bash
source  ~/dasan_ohpc_variable.sh
```

***

# # 2. [Network and Firewall Setup to Base Operating System (BOS)](#목차)

## # 2.1 외부망 및 내부망 인터페이스 설정.

```bash
ip a    # 인터페이스 목록 확인  
```
*output example>*
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1  
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00  
    inet 127.0.0.1/8 scope host lo  
       valid_lft forever preferred_lft forever  
2: em1: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN qlen 1000  
    link/ether ================ brd ff:ff:ff:ff:ff:ff  
3: *em2*: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000  
    link/ether ================ brd ff:ff:ff:ff:ff:ff  
    inet *192.168.0.116/24* brd 192.168.0.255 scope global em2  
       valid_lft forever preferred_lft forever  
4: em3: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN qlen 1000  
    link/ether ================ brd ff:ff:ff:ff:ff:ff  
5: em4: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN qlen 1000  
    link/ether ================ brd ff:ff:ff:ff:ff:ff  
6: *p1p1*: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000  
    link/ether ================ brd ff:ff:ff:ff:ff:ff  
7: p1p2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000  
    link/ether ================ brd ff:ff:ff:ff:ff:ff  

## # 2.2 Master 의 외부/내부 인터페이스 설정내용 확인
```bash
cat /etc/sysconfig/network-scripts/ifcfg-${EXT_NIC}
```
*output example>*
>NAME=*em2*  
ONBOOT=yes  
BOOTPROTO=none  
IPADDR=192.168.0.116  
PREFIX=24  
GATEWAY=192.168.0.1  
DNS1=168.126.63.1  
DNS2=8.8.8.8  
DEFROUTE=yes  
<일부 값 생략>  

```bash
cat /etc/sysconfig/network-scripts/ifcfg-${INT_NIC}
```
*output example>*
>NAME=*p1p1*  
ONBOOT=no  
BOOTPROTO=dhcp  
<일부 값 생략>  

## # 2.3 가독성 향상을 위해, 불 필요한 IPV6 항목 삭제.
```bash
sed -i '/IPV6/d' /etc/sysconfig/network-scripts/ifcfg-${EXT_NIC}
sed -i '/IPV6/d' /etc/sysconfig/network-scripts/ifcfg-${INT_NIC}
```

## # 2.4 Master 의 내부망 인터페이스의 설정 변경.
```bash
sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/' /etc/sysconfig/network-scripts/ifcfg-${INT_NIC}
sed -i 's/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-${INT_NIC}
```

## # 2.5 Master 의 내부망 ip 설정
```bash
echo "IPADDR=${MASTER_IP}"  >>  /etc/sysconfig/network-scripts/ifcfg-${INT_NIC}
echo "PREFIX=${MASTER_PREFIX}"  >>  /etc/sysconfig/network-scripts/ifcfg-${INT_NIC}

cat /etc/sysconfig/network-scripts/ifcfg-${INT_NIC}
```

## # 2.6 ip 변경 설정 적용
```bash
ifdown ${INT_NIC} && ifup ${INT_NIC}
ip a
```
*output example>*
>1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1  
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00  
    inet 127.0.0.1/8 scope host lo  
       valid_lft forever preferred_lft forever  
2: em1: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN qlen 1000  
    link/ether ================= brd ff:ff:ff:ff:ff:ff  
3: em2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000  
    link/ether ================= brd ff:ff:ff:ff:ff:ff  
    inet 192.168.0.116/24 brd 192.168.0.255 scope global em2  
       valid_lft forever preferred_lft forever  
4: em3: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN qlen 1000  
    link/ether ================= brd ff:ff:ff:ff:ff:ff  
5: em4: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN qlen 1000  
    link/ether ================= brd ff:ff:ff:ff:ff:ff  
6: *p1p1*: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state *UP* qlen 1000  
    link/ether ================= brd ff:ff:ff:ff:ff:ff  
    *inet 10.1.1.1/24* brd 10.1.1.255 scope global p1p1  
       valid_lft forever preferred_lft forever  
7: p1p2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000  
    link/ether ================= brd ff:ff:ff:ff:ff:ff  

## # 2.7 방화벽 zone 설정 변경
```bash
firewall-cmd --change-interface=${EXT_NIC}  --zone=external  --permanent
firewall-cmd --change-interface=${INT_NIC}  --zone=trusted   --permanent

firewall-cmd --reload
systemctl restart firewalld
```

### # 방화벽 설정 변경 확인.

```bash
firewall-cmd --list-all --zone=external
firewall-cmd --list-all --zone=trusted
```
*output example>*
>*external* (active)  
target: *default*  
icmp-block-inversion: no  
interfaces: *em2*  

*output example>*
>*trusted* (active)  
  target: ACCEPT  
  icmp-block-inversion: no  
  interfaces: em1 *p1p1*  

## # 2.8 클러스터 마스터 IP 와 HOSTNAME 을 hosts 에 등록.
```bash
echo "${MASTER_IP}      ${MASTER_HOSTNAME}"  >>  /etc/hosts
cat /etc/hosts
```
*output example>*
>127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4  
::1          localhost localhost.localdomain localhost6 localhost6.localdomain6  
*10.1.1.1    master*  

***

# # 3. [Install OpenHPC Components](#목차)

## # 3.1 Enable OpenHPC repository for local use
### # Check current repolist
```bash
yum repolist
```

*output example>*  
>Loaded plugins: fastestmirror, langpacks, priorities  
Loading mirror speeds from cached hostfile  
 \* base: data.nicehosting.co.kr  
 \* epel: mirror01.idc.hinet.net  
 \* extras: data.nicehosting.co.kr  
 \* updates: data.nicehosting.co.kr  
116 packages excluded due to repository priority protections  
repo id             repo name                                         status  
base/7/x86_64       CentOS-7 - Base                                       10,097
\*epel/x86_64        Extra Packages for Enterprise Linux 7 - x86_64    13,045+165
extras/7/x86_64     CentOS-7 - Extras                                        335
updates/7/x86_64    CentOS-7 - Updates                                     1,487
repolist: 26,102


### # Install to OpenHPC repository.
```bash
yum -y install \
http://build.openhpc.community/OpenHPC:/1.3/CentOS_7/x86_64/ohpc-release-1.3-1.el7.x86_64.rpm \
>> ~/dasan_log_ohpc_openhpc_repository.txt 2>&1  

tail ~/dasan_log_ohpc_openhpc_repository.txt
```

*output example>*  
> Running transaction test  
Transaction test succeeded  
Running transaction  
  Installing : ohpc-release-1.3-1.el7.x86_64                                1/1   
  Verifying  : ohpc-release-1.3-1.el7.x86_64                                1/1   
Installed:  
  ohpc-release.x86_64 0:1.3-1.el7                                               
Complete!  

### # Check added repolist

```bash
yum repolist
```
*output example>*
>Loaded plugins: fastestmirror, langpacks, priorities  
OpenHPC                                                  | 1.6 kB     00:00     
OpenHPC-updates                                          | 1.2 kB     00:00     
(1/3): OpenHPC/group_gz                                    | 1.7 kB   00:00     
(2/3): OpenHPC/primary                                     | 155 kB   00:01     
(3/3): OpenHPC-updates/primary                             | 192 kB   00:01     
Loading mirror speeds from cached hostfile  
 \* base: data.nicehosting.co.kr  
 \* epel: mirror.rise.ph  
 \* extras: data.nicehosting.co.kr  
 \* updates: data.nicehosting.co.kr  
OpenHPC                                                                 821/821  
OpenHPC-updates                                                       1010/1010  
139 packages excluded due to repository priority protections  
repo id             repo name                                         status  
OpenHPC             OpenHPC-1.3 - Base                                   321+500
OpenHPC-updates     OpenHPC-1.3 - Updates                              817+1,113
base/7/x86_64       CentOS-7 - Base                                       10,097
\*epel/x86_64        Extra Packages for Enterprise Linux 7 - x86_64    13,045+165
extras/7/x86_64     CentOS-7 - Extras                                        335
updates/7/x86_64    CentOS-7 - Updates                                     1,487
repolist: 26,102


## # 3.3 Add provisioning services on master node

### # Install base meta-packages

```bash
yum -y install ohpc-base ohpc-warewulf  >>  ~/dasan_log_ohpc_base,warewulf.txt 2>&1
tail ~/dasan_log_ohpc_base,warewulf.txt  
```
*output example>*  
>  warewulf-common-ohpc.x86_64 0:3.8.1-14.2.ohpc.1.3.6                           
  warewulf-ipmi-ohpc.x86_64 0:3.8.1-12.3.ohpc.1.3.6                             
  warewulf-provision-initramfs-x86_64-ohpc.noarch 0:3.8.1-56.1.ohpc.1.3.9       
  warewulf-provision-ohpc.x86_64 0:3.8.1-56.1.ohpc.1.3.9                        
  warewulf-provision-server-ipxe-x86_64-ohpc.noarch 0:3.8.1-56.1.ohpc.1.3.9     
  warewulf-provision-server-ohpc.x86_64 0:3.8.1-56.1.ohpc.1.3.9                 
  warewulf-vnfs-ohpc.x86_64 0:3.8.1-33.1.ohpc.1.3.7                             
  xinetd.x86_64 2:2.3.15-13.el7                                               
Complete!  


### # NTP Server 설정

```bash
cat /etc/ntp.conf | grep -v "#\|^$"
```
*output example>*
>driftfile /var/lib/ntp/drift  
restrict default nomodify notrap nopeer noquery  
restrict 127.0.0.1   
restrict ::1  
server 0.centos.pool.ntp.org iburst  
server 1.centos.pool.ntp.org iburst  
server 2.centos.pool.ntp.org iburst  
server 3.centos.pool.ntp.org iburst  
includefile /etc/ntp/crypto/pw  
keys /etc/ntp/keys  
disable monitor  

```bash
echo "server time.bora.net" >> /etc/ntp.conf

cat /etc/ntp.conf | grep -v "#\|^$"

systemctl enable ntpd.service && systemctl restart ntpd
```


## # 3.4 Add resource management services on master node
\# **주의!** Resource Manager는 Slurm 과 PBS Pro 중 선택하여 진행 합니다.  
\# GPU Cluster 의 경우 3.4-A. Slurm 을 설치해야 합니다.  

## # [3.4-A (Slurm) Resource Management Services Install.](#목차)
\# 참조 링크: https://slurm.schedmd.com/

### # Install slurm server meta-package
```bash
yum -y install ohpc-slurm-server slurm-sview-ohpc slurm-torque-ohpc  \
  >> ~/dasan_log_ohpc_resourcemanager_slurm.txt 2>&1
tail ~/dasan_log_ohpc_resourcemanager_slurm.txt  
```
*output example>*
>  pdsh-mod-slurm-ohpc.x86_64 0:2.33-97.1.ohpc.1.3.7                             
  pmix-ohpc.x86_64 0:2.2.2-9.1.ohpc.1.3.7                                       
  slurm-devel-ohpc.x86_64 0:18.08.8-4.1.ohpc.1.3.8.1                            
  slurm-example-configs-ohpc.x86_64 0:18.08.8-4.1.ohpc.1.3.8.1                  
  slurm-ohpc.x86_64 0:18.08.8-4.1.ohpc.1.3.8.1                                  
  slurm-perlapi-ohpc.x86_64 0:18.08.8-4.1.ohpc.1.3.8.1                          
  slurm-slurmctld-ohpc.x86_64 0:18.08.8-4.1.ohpc.1.3.8.1                        
  slurm-slurmdbd-ohpc.x86_64 0:18.08.8-4.1.ohpc.1.3.8.1                                          
Complete!  

### # Identify resource manager hostname on master host

\# ClusterName 과 ControlMachine 변경
```bash
grep 'ClusterName\|ControlMachine' /etc/slurm/slurm.conf

```
*output example>*
>ClusterName=linux  
ControlMachine=linux0   

```bash
sed -Ei "s/ClusterName=\S+/ClusterName=${CLUSTER_NAME}/"  /etc/slurm/slurm.conf
sed -Ei "s/ControlMachine=\S+/ControlMachine=${MASTER_HOSTNAME}/" /etc/slurm/slurm.conf
grep 'ClusterName\|ControlMachine' /etc/slurm/slurm.conf

```
*output example>*
>ClusterName=*OpenHPC-Dasandata*  
ControlMachine=*master*  

### # NodeName, CPU & Memory 속성 설정
\# slurm.conf 파일의 NodeName을 클러스터 노드의 Hostname 과 동일하게 변경하고,  
\# 사양에 맞추어 Sockets, Cores, Thread, RealMemory 값을 변경 합니다.  
\# Sockets = 노드의 물리적인 CPU 갯수.  
\# CoresPerSocket = 각 물리 CPU의 논리적 코어 갯수.  
\# Thread = 하이퍼스레딩 사용 여부. (사용시 2, 미사용시 1)  
\# RealMemory = 노드의 실제 메모리 보다 약간 작게 합니다.
\# 메모리 단위는 megabyte (예를 들어 64GB 라면 60GB = 60000)  

### # NodeName 설정
```bash
echo "NodeName=${NODE_NAME}${NODE_RANGE} " # 선언 되어 있는 변수 확인
grep NodeName= /etc/slurm/slurm.conf          # slurm 설정 파일의 기본 값 확인.
```
*output example>*
>NodeName=node[1-3]  
NodeName=c[1-4] Sockets=2 CoresPerSocket=8 ThreadsPerCore=2 State=UNKNOWN  

```bash
perl -pi -e "s/NodeName=\S+/NodeName=${NODE_NAME}${NODE_RANGE}/" /etc/slurm/slurm.conf
grep NodeName= /etc/slurm/slurm.conf
```
*output example>* **노드 이름이 'node' 이고, 총 수량은 3대 일 경우**
>NodeName=*node[1-3]* Sockets=2 CoresPerSocket=8 ThreadsPerCore=2 State=UNKNOWN  

### # Node CPU, Memory 속성 설정

\# 앞서 정의한 변수 값을 다시 한번 검토 한 후 진행 합니다.
```bash
cat ~/dasan_ohpc_variable.sh
bash ~/dasan_ohpc_variable.sh
```

\# slurm 설정파일(slurm.conf)의  기존 설정 값 확인.
```bash
grep NodeName= /etc/slurm/slurm.conf
```
*output example>*
>NodeName=node[1-3] Sockets=2 CoresPerSocket=8 ThreadsPerCore=2 State=UNKNOWN  

```bash
perl -pi -e "s/Sockets=\S+/Sockets=${SOCKETS}/"  /etc/slurm/slurm.conf
perl -pi -e "s/CoresPerSocket=\S+/CoresPerSocket=${CORESPERSOCKET}/"  /etc/slurm/slurm.conf
perl -pi -e "s/ThreadsPerCore=\S+/ThreadsPerCore=${THREAD}/"  /etc/slurm/slurm.conf

grep NodeName= /etc/slurm/slurm.conf  
```
*output example>*
>NodeName=node[1-3] Sockets=*2* CoresPerSocket=*10* ThreadsPerCore=*2* State=UNKNOWN  


## # [3.4-B (PBS Pro) Resource Management Services Install](https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.7%20Base%20OS).md#%EB%AA%A9%EC%B0%A8)

### # Install to pbspro-server-ohpc
```bash
yum -y install pbspro-server-ohpc >> ~/dasan_log_ohpc_resourcemanager_pbspro.txt 2>&1
tail -1 ~/dasan_log_ohpc_resourcemanager_pbspro.txt
```
***

## # [3.5 Optionally add InfiniBand support services on master node](https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.7%20Base%20OS).md#%EB%AA%A9%EC%B0%A8)

### # 3.5.1 Install InfiniBand support on master node

```bash
yum -y groupinstall "InfiniBand Support" >> ~/dasan_log_ohpc_IBSupport.txt 2>&1
tail -1 ~/dasan_log_ohpc_IBSupport.txt

yum -y install infinipath-psm opensm libibverbs-utils >> ~/dasan_log_ohpc_IBSupport.txt 2>&1
tail -1 ~/dasan_log_ohpc_IBSupport.txt

```

### # 3.5.2 Load InfiniBand drivers
```bash
systemctl enable opensm
systemctl start opensm

systemctl start rdma
systemctl enable rdma

```

### # 3.5.3 Copy ib0 template to master for IPoIB(IP Over InfiniBand)
```bash
cp  /opt/ohpc/pub/examples/network/centos/ifcfg-ib0   /etc/sysconfig/network-scripts

```

### # 3.5.4 Define local IPoIB(IP Over InfiniBand) address and netmask
```bash
sed -i "s/master_ipoib/${sms_ipoib}/"      /etc/sysconfig/network-scripts/ifcfg-ib0
sed -i "s/ipoib_netmask/${ipoib_netmask}/" /etc/sysconfig/network-scripts/ifcfg-ib0

echo  “MTU=4096”  >>  /etc/sysconfig/network-scripts/ifcfg-ib0

```

### # 3.5.5 Initiate ib0 (InfiniBand Interface 0)
```bash
ifup ib0

ibstat

ibhosts
```
*output example>*
>CA 'mlx4_0'  
	CA type: MT4099  
	Number of ports: 1  
	Firmware version: 2.31.5050  
	Hardware version: 1  
	Node GUID: 0x0002c90300197120  
	System image GUID: 0x0002c90300197123  
	Port 1:  
		State: Active  
		Physical state: LinkUp  
		Rate: 56  
		Base lid: 1  
		LMC: 0  
		SM lid: 1  
		Capability mask: 0x0259486a  
		Port GUID: 0x0002c90300197121  
		Link layer: InfiniBand  


### # 3.5.6 ib 방화벽 zone 설정 변경
```bash
firewall-cmd --change-interface=ib0  --zone=trusted   --permanent

firewall-cmd --reload && systemctl restart firewalld

firewall-cmd --list-all --zone=trusted

```

## # 3.7 Complete basic Warewulf setup for master node

### # Configure Warewulf provisioning to use desired internal interface
\# 내부망 인터페이스 설정 내용 확인.  
```bash
echo ${INT_NIC}

ifconfig ${INT_NIC}
```
*output example>*
>p1p1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500  
        inet 10.1.1.1  netmask 255.255.255.0  broadcast 10.1.1.255  
        ether ================  txqueuelen 1000  (Ethernet)  
        RX packets 12612  bytes 3974604 (3.7 MiB)  
        RX errors 0  dropped 0  overruns 0  frame 0  
        TX packets 29576  bytes 1362244 (1.2 MiB)  
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0  

\# warewulf provision.conf 파일의 기본값 확인.  
```bash
grep device /etc/warewulf/provision.conf
```
*output example>*
>\# What is the default network device that the master will use to  
network device = **eth1**  

\# 인터페이스 명 변경
```bash

sed -i "s/device = eth1/device = ${INT_NIC}/" /etc/warewulf/provision.conf
grep device /etc/warewulf/provision.conf
```

*output example>*
>\# What is the default network device that the master will use to  
network device = **p1p1**  

### # Enable tftp service for compute node image distribution
```bash
grep disable /etc/xinetd.d/tftp
perl -pi -e "s/^\s+disable\s+= yes/ disable = no/" /etc/xinetd.d/tftp
grep disable /etc/xinetd.d/tftp
```

*output example>*
>[root@master:\~]# grep disable /etc/xinetd.d/tftp  
	disable			= yes  
[root@master:\~]# perl -pi -e "s/^\s+disable\s+= yes/ disable = no/" /etc/xinetd.d/tftp  
[root@master:\~]# grep disable /etc/xinetd.d/tftp  
 disable = no  
[root@master:\~]#   

### # Restart/enable relevant services to support provisioning
```bash
echo "
systemctl enable  dhcpd
systemctl restart xinetd
systemctl enable  mariadb
systemctl restart mariadb
systemctl enable  httpd
systemctl restart httpd
" > /tmp/provisioning_service_run.sh

bash /tmp/provisioning_service_run.sh
```

## # 3.8 Define compute image for provisioning

### # Check chroot location.
\# chroot 작업을 하기 전에 항상, ${CHROOT} 변수가 알맞게 선언 되어 있는지 확인하는 것을 권장합니다.
```bash
echo ${CHROOT}
```
*output example>*
>/opt/ohpc/admin/images/centos7.7

### # 3.8.1 Build initial BOS (Base OS) image
```bash
wwmkchroot centos-7 ${CHROOT} >> ~/dasan_log_ohpc_initial-BaseOS.txt 2>&1
tail ~/dasan_log_ohpc_initial-BaseOS.txt
```
*output example>*
>  sqlite.x86_64 0:3.7.17-8.el7                                                                
  systemd.x86_64 0:219-67.el7                                                                 
  systemd-libs.x86_64 0:219-67.el7                                                            
  systemd-sysv.x86_64 0:219-67.el7                                                            
  sysvinit-tools.x86_64 0:2.88-14.dsf.el7                                                     
  tcp_wrappers-libs.x86_64 0:7.6-77.el7                                                       
  ustr.x86_64 0:1.0.4-16.el7                                                                  
  xz.x86_64 0:5.2.2-1.el7                                                                     
  xz-libs.x86_64 0:5.2.2-1.el7  
Complete!  


#### # Build 된 node image 와 master 의 kernel version 비교.

```bash
uname -r

chroot ${CHROOT} uname -r
```
*output example>*
```
[root@master:~]#
[root@master:~]# uname -r
3.10.0-1062.12.1.el7.x86_64
[root@master:~]#
[root@master:~]# chroot ${CHROOT}  uname -r
3.10.0-1062.12.1.el7.x86_64
```

#### # Build 된 node provision image 의 업데이트
```bash
yum -y --installroot=${CHROOT} update  >> ~/dasan_log_ohpc_update_nodeimage.txt 2>&1
tail ~/dasan_log_ohpc_update_nodeimage.txt
```

### # 3.8.2 Add OpenHPC components
#### # 3.8.2.1 Install compute node base meta-package.
\# 기본 적으로 필요한 패키지를 node image 에 설치 합니다.
```bash
yum -y --installroot=${CHROOT} install \
 ohpc-base-compute kernel kernel-headers kernel-devel kernel-tools parted \
 xfsprogs python-devel yum htop ipmitool glibc* perl perl-CPAN perl-CPAN \
 sysstat gcc make xauth firefox >> ~/dasan_log_ohpc_meta-package.txt 2>&1

tail ~/dasan_log_ohpc_meta-package.txt  

```
*output example>*
>  pyxattr.x86_64 0:0.5.1-5.el7                                                  
  rpm-build-libs.x86_64 0:4.11.3-40.el7                                         
  rpm-python.x86_64 0:4.11.3-40.el7                                             
  systemtap-sdt-devel.x86_64 0:4.0-10.el7_7                                     
  xorg-x11-proto-devel.noarch 0:2018.4-1.el7                                    
  yum-metadata-parser.x86_64 0:1.1.4-10.el7                                     
  yum-plugin-fastestmirror.noarch 0:1.1.31-52.el7                               
  zlib-devel.x86_64 0:1.2.7-18.el7                                             
Complete!  


#### # 3.8.2.2 updated to enable DNS resolution.
```bash
cat /etc/resolv.conf
cp -p /etc/resolv.conf ${CHROOT}/etc/resolv.conf  
```

***

#### # 3.8.2.3-A Add Slurm client support meta-package
\# **주의!** - Resource Manager 로 **Slurm** 을 사용하는 경우에만 실행 합니다.
```bash
yum -y --installroot=${CHROOT} install ohpc-slurm-client >> ~/dasan_log_ohpc_slurmclient.txt 2>&1
tail -1 ~/dasan_log_ohpc_slurmclient.txt

chroot ${CHROOT} systemctl enable slurmd
```

***

#### # 3.8.2.3-B Add PBS Professional client support
\# **주의!** - Resource Manager 로 **PBS** 를 사용하는 경우에만 실행 합니다.
```bash
yum -y --installroot=${CHROOT} install pbspro-execution-ohpc >> ~/dasan_log_ohpc_pbsprolient.txt 2>&1
tail -1 ~/dasan_log_ohpc_pbsprolient.txt

```

```bash
# pbs client 설정 파일 수정.
grep PBS_SERVER ${CHROOT}/etc/pbs.conf
perl -pi -e "s/PBS_SERVER=\S+/PBS_SERVER=${MASTER_HOSTNAME}/" ${CHROOT}/etc/pbs.conf
grep PBS_SERVER ${CHROOT}/etc/pbs.conf

echo "PBS_LEAF_NAME=${MASTER_HOSTNAME}" >> /etc/pbs.conf
```


```bash
# 현재 구성 검사 (오류발생).
chroot ${CHROOT} /opt/pbs/libexec/pbs_habitat

# 추가 설정 수정.
grep clienthost ${CHROOT}/var/spool/pbs/mom_priv/config
perl -pi -e "s/\$clienthost \S+/\$clienthost ${MASTER_HOSTNAME}/" ${CHROOT}/var/spool/pbs/mom_priv/config
grep clienthost ${CHROOT}/var/spool/pbs/mom_priv/config

echo "\$usecp *:/home /home" >> ${CHROOT}/var/spool/pbs/mom_priv/config
cat    ${CHROOT}/var/spool/pbs/mom_priv/config

# 다시 검사.
chroot ${CHROOT} /opt/pbs/libexec/pbs_habitat

chroot ${CHROOT} systemctl enable pbs
```

#### # 3.8.2.4 Add Network Time Protocol (NTP) support, kernel drivers, modules user environment.
```bash
yum -y --installroot=${CHROOT} install ntp kernel lmod-ohpc \
 >> ~/dasan_log_ohpc_ntp,kernel,modules.txt 2>&1
tail ~/dasan_log_ohpc_ntp,kernel,modules.txt  
```

***

### # 3.8.3 Customize system configuration

#### # Initialize warewulf database and ssh_keys
```bash
wwinit database && wwinit ssh_keys
```
*output example>*
>[root@master:\~]# wwinit database && wwinit ssh_keys
database:     Checking to see if RPM 'mysql-server' is installed             NO
database:     Checking to see if RPM 'mariadb-server' is installed           OK
database:     Activating Systemd unit: mariadb
database:      + /bin/systemctl -q enable mariadb.service                    OK
database:      + /bin/systemctl -q restart mariadb.service                   OK
database:     Database version: 1
database:      + mysql --defaults-extra-file=/tmp/0.Yy6oMadA3BQa/my.cnf ware OK
database:      + mysql --defaults-extra-file=/tmp/0.Yy6oMadA3BQa/my.cnf ware OK
database:     Checking binstore kind                                    SUCCESS
Done.
ssh_keys:     Checking ssh keys for root                                     OK
ssh_keys:     Checking root's ssh config                                     OK
ssh_keys:     Checking for default RSA host key for nodes                    NO
ssh_keys:     Creating default node ssh_host_rsa_key:
ssh_keys:      + ssh-keygen -q -t rsa -f /etc/warewulf/vnfs/ssh/ssh_host_rsa OK
ssh_keys:     Checking for default DSA host key for nodes                    NO
ssh_keys:     Creating default node ssh_host_dsa_key:
ssh_keys:      + ssh-keygen -q -t dsa -f /etc/warewulf/vnfs/ssh/ssh_host_dsa OK
ssh_keys:     Checking for default ECDSA host key for nodes                  NO
ssh_keys:     Creating default node ssh_host_ecdsa_key:
                                                                             OK
ssh_keys:     Checking for default Ed25519 host key for nodes                NO
ssh_keys:     Creating default node ssh_host_ed25519_key:
                                                                             OK
Done.

#### # Add NFS client mounts of /home and /opt/ohpc/pub and /{ETC} to base image.

```bash
df -hT | grep -v tmpfs
echo ${MASTER_HOSTNAME}
cat  ${CHROOT}/etc/fstab

echo "${MASTER_HOSTNAME}:/home         /home         nfs nfsvers=3,nodev,nosuid 0 0" >> ${CHROOT}/etc/fstab
echo "${MASTER_HOSTNAME}:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3,nodev 0 0" >> ${CHROOT}/etc/fstab

# 아래는 data 디렉토리를 별도로 구성하는 경우에만.
#echo "${MASTER_HOSTNAME}:/data /data nfs nfsvers=3,nodev 0 0" >> ${CHROOT}/etc/fstab
cat  ${CHROOT}/etc/fstab  
```

*output example>*
>[root@master:\~]# df -hT | grep -v tmpfs  
Filesystem                     Type      Size  Used Avail Use% Mounted on  
/dev/mapper/centos_master-root xfs       898G  9.6G  889G   2% /  
/dev/sda1                      xfs      1014M  189M  826M  19% /boot  
/dev/mapper/vg_home-lv_home    xfs        39T   55M   39T   1% /home  
[root@master:\~]#  
[root@master:\~]# cat  ${CHROOT}/etc/fstab  
\#GENERATED_ENTRIES#  
tmpfs /dev/shm tmpfs defaults 0 0  
devpts /dev/pts devpts gid=5,mode=620 0 0  
sysfs /sys sysfs defaults 0 0  
proc /proc proc defaults 0 0  
master:/home /home nfs nfsvers=3,nodev,nosuid 0 0  
master:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3,nodev 0 0  
[root@master:\~]#  


#### # Export /home and OpenHPC public packages from master server.

```bash
cat /etc/exports

echo "/home         *(rw,no_subtree_check,no_root_squash)"  >> /etc/exports
echo "/opt/ohpc/pub *(ro,no_subtree_check)"                 >> /etc/exports

# 아래는 data 디렉토리를 별도로 구성하는 경우에만.  
#echo "/data *(rw,no_subtree_check,no_root_squash)" >> /etc/exports
#mkdir ${CHROOT}/data

cat /etc/exports
```

*output example>*
>/home \*(rw,no_subtree_check,no_root_squash)  
/opt/ohpc/pub \*(ro,no_subtree_check)  


```bash
systemctl enable  nfs-server && systemctl restart nfs-server && exportfs
```

*output example>*
```
/home           <world>  
/opt/ohpc/pub   <world>  
```

#### # (Optional) nfs by IPoIB with RDMA
```bash

echo rdma 20049 > /proc/fs/nfsd/portlist
echo "echo rdma 20049 > /proc/fs/nfsd/portlist" >> /etc/rc.local

vi ${CHROOT}/etc/fstab

master:/home         /home         nfs  nfsvers=3,nodev,proto=rdma,port=20049,nosuid  0 0
master:/opt/ohpc/pub /opt/ohpc/pub nfs  nfsvers=3,nodev,proto=rdma,port=20049         0 0
master:/data         /data         nfs  nfsvers=3,nodev,proto=rdma,port=20049,nosuid  0 0

systemctl enable  nfs-server && systemctl restart nfs-server && exportfs
```


#### # Enable NTP time service on computes and identify master host as local NTP server.

```bash
chroot ${CHROOT} systemctl enable ntpd
echo "server ${MASTER_HOSTNAME}" >> ${CHROOT}/etc/ntp.conf
```

***

### # 3.8.4 Additional Customization (Optional)

#### # 3.8.4.1 Enable InfiniBand drivers

##### # Add IB support and enable on nodes
```bash
yum -y --installroot=${CHROOT} groupinstall "InfiniBand Support" >> ~/dasan_log_ohpc_nodeIBSupport.txt 2>&1
tail  -1 ~/dasan_log_ohpc_nodeIBSupport.txt

yum -y --installroot=${CHROOT} install infinipath-psm  libibverbs-utils >> ~/dasan_log_ohpc_nodeIBSupport.txt 2>&1
tail  -1 ~/dasan_log_ohpc_nodeIBSupport.txt

chroot ${CHROOT} systemctl enable rdma
```

##### # Import File for IPoIB Interfaces
```bash
wwsh    file import /opt/ohpc/pub/examples/network/centos/ifcfg-ib0.ww
wwsh -y file set ifcfg-ib0.ww  --path=/etc/sysconfig/network-scripts/ifcfg-ib0

```

#### # 3.8.4.3 Increase locked memory limits

##### # Update memlock settings on master
```bash
perl -pi -e 's/# End of file/\* soft memlock unlimited\n$&/s' /etc/security/limits.conf
perl -pi -e 's/# End of file/\* hard memlock unlimited\n$&/s' /etc/security/limits.conf

tail /etc/security/limits.conf
```
##### # Update memlock settings on compute nodes  
```bash
perl -pi -e 's/# End of file/\* soft memlock unlimited\n$&/s' ${CHROOT}/etc/security/limits.conf
perl -pi -e 's/# End of file/\* hard memlock unlimited\n$&/s' ${CHROOT}/etc/security/limits.conf

tail ${CHROOT}/etc/security/limits.conf
```


#### # 3.8.4.5 Add Lustre client

##### # Add Lustre client software to master host
```bash
yum -y install lustre-client-ohpc
```

##### # Add Lustre client software in compute image
```bash
yum -y --installroot=$CHROOT install lustre-client-ohpc
```

##### # Include mount point and file system mount in compute image
```bash
mkdir $CHROOT/lustre

echo "10.xx.xx.x:/lustre  /lustre  lustre  defaults,localflock,noauto,x-systemd.automount 0 0" \
>> $CHROOT/etc/fstab
```

##### # Make file of lustre.conf (lnet config)
```bash
echo "options lnet networks=o2ib(ib0)" >> /etc/modprobe.d/lustre.conf
echo "options lnet networks=o2ib(ib0)" >> $CHROOT/etc/modprobe.d/lustre.conf
```

##### # Lustre Mount test.
```bash
mkdir /lustre

mount -t lustre -o localflock 10.xx.xx.x:/lustre /lustre
```

#### # 3.8.4.8  Add Ganglia monitoring
\# Ganglia Monitoring System : https://en.wikipedia.org/wiki/Ganglia_(software)

##### # Install Ganglia meta-package on master
```bash
yum -y install ohpc-ganglia >> ~/dasan_log_ohpc_ganglia.txt 2>&1
tail -1 ~/dasan_log_ohpc_ganglia.txt
```
#### # Install Ganglia compute node daemon
```bash
yum -y --installroot=${CHROOT} install ganglia-gmond-ohpc >> ~/dasan_log_ohpc_ganglia-node.txt 2>&1
tail -1 ~/dasan_log_ohpc_ganglia-node.txt
```

#### # Use example configuration script to enable unicast receiver on master host
```bash
/usr/bin/cp  /opt/ohpc/pub/examples/ganglia/gmond.conf  /etc/ganglia/gmond.conf

grep 'host =' /etc/ganglia/gmond.conf
sed -i "s/<sms>/${MASTER_HOSTNAME}/" /etc/ganglia/gmond.conf
grep 'host ='  /etc/ganglia/gmond.conf

grep OpenHPC /etc/ganglia/gmond.conf
sed -i "s/OpenHPC/${CLUSTER_NAME}/" /etc/ganglia/gmond.conf
grep ${CLUSTER_NAME} /etc/ganglia/gmond.conf

```
#### # Add configuration to compute image and provide gridname
```bash
/usr/bin/cp   /etc/ganglia/gmond.conf  ${CHROOT}/etc/ganglia/gmond.conf
echo "gridname ${CLUSTER_NAME}" >> /etc/ganglia/gmetad.conf

grep gridname /etc/ganglia/gmetad.conf
```
#### # Start and enable Ganglia services
```bash
echo "
systemctl enable gmond
systemctl enable gmetad
systemctl start gmond
systemctl start gmetad
chroot ${CHROOT} systemctl enable gmond
" > /tmp/start_ganglia_service.sh

bash /tmp/start_ganglia_service.sh
```
#### # php TimeZone setup
```bash
grep "^date.timezone =" /etc/php.ini
echo "date.timezone = Asia/Seoul" >> /etc/php.ini
grep "^date.timezone =" /etc/php.ini
```
#### # Restart web server
```bash
systemctl try-restart httpd
```
#### Change firewall settings to Allow ganglia access with external IP.
```bash
firewall-cmd --list-all

firewall-cmd --add-port=80/tcp  --permanent
firewall-cmd --reload
```
\# Open to http://localhost/ganglia or http://<expternal ip address>/ganglia


### # 3.8.5 Import files
The Warewulf system includes functionality to import arbitrary files from the provisioning server for distribution to managed hosts. This is one way to distribute user credentials to compute nodes.  
To import local file-based credentials, issue the following:  

#### # Default files
```bash
wwsh file list

wwsh file import /etc/passwd
wwsh file import /etc/group
wwsh file import /etc/shadow

wwsh file list
```

#### # (Optional) Files for Slurm Resource Manager
\# Slurm 을 사용하는 경우에만 실행 합니다.
```bash
wwsh file import /etc/slurm/slurm.conf
wwsh file import /etc/munge/munge.key
```

## # 3.9 Finalizing provisioning configuration


### # 3.9.0 /etc/warewulf/vnfs.conf 수정.

```bash
cat /etc/warewulf/vnfs.conf  | grep -v "^$\|^#"

cat /etc/warewulf/vnfs.conf  | grep -v "^$\|^#" | wc -l
```

*output example>*
```
gzip command = /usr/bin/pigz -9
cpio command = cpio --quiet -o -H newc
build directory = /var/tmp/
exclude += /tmp/*
exclude += /var/log/*
exclude += /var/chroots/*
exclude += /var/cache
exclude += /usr/src
hybridize += /usr/X11R6
hybridize += /usr/lib/locale
hybridize += /usr/lib64/locale
hybridize += /usr/include
hybridize += /usr/share/man
hybridize += /usr/share/doc
hybridize += /usr/share/locale

15
```
***

```bash
sed -i "s#hybridize += /usr/lib/locale#\#hybridize += /usr/lib/locale#"     /etc/warewulf/vnfs.conf
sed -i "s#hybridize += /usr/lib64/locale#\#hybridize += /usr/lib64/locale#" /etc/warewulf/vnfs.conf
sed -i "s#hybridize += /usr/include#\#hybridize += /usr/include#"           /etc/warewulf/vnfs.conf
sed -i "s#hybridize += /usr/share/locale#\#hybridize += /usr/share/locale#" /etc/warewulf/vnfs.conf

cat /etc/warewulf/vnfs.conf  | grep -v "^$\|^#"

cat /etc/warewulf/vnfs.conf  | grep -v "^$\|^#" | wc -l
```
*output example>*
```
gzip command = /usr/bin/pigz -9
cpio command = cpio --quiet -o -H newc
build directory = /var/tmp/
exclude += /tmp/*
exclude += /var/log/*
exclude += /var/chroots/*
exclude += /var/cache
exclude += /usr/src
hybridize += /usr/X11R6
hybridize += /usr/share/man
hybridize += /usr/share/doc

11
```

### # 3.9.1 Assemble bootstrap image

#### # Include drivers from kernel updates; needed if enabling additional kernel modules on computes

```bash
export WW_CONF=/etc/warewulf/bootstrap.conf
echo "drivers += updates/kernel/" >> $WW_CONF
```

#### # Build bootstrap image
```bash
wwbootstrap  `uname -r`
```
*output example>*
> Number of drivers included in bootstrap: 540
Number of firmware images included in bootstrap: 99
Building and compressing bootstrap
Integrating the Warewulf bootstrap: 3.10.0-1062.12.1.el7.x86_64
Including capability: provision-adhoc
Including capability: provision-files
Including capability: provision-selinux
Including capability: provision-vnfs
Including capability: setup-filesystems
Including capability: setup-ipmi
Including capability: transport-http
Compressing the initramfs
Locating the kernel object
Bootstrap image '3.10.0-1062.12.1.el7.x86_64' is ready
Done.

#### # check bootstrap list
'''bash
[root@master:~]# wwsh bootstrap list
BOOTSTRAP NAME            SIZE (M)      ARCH
3.10.0-1062.12.1.el7.x86_64 30.2          x86_64
'''

### # 3.9.2 Assemble Virtual Node File System (VNFS) image

```bash
echo ${CHROOT}
```
*output example>*
>/opt/ohpc/admin/images/centos7.7

```bash
wwvnfs --chroot ${CHROOT}
# or wwvnfs --chroot /opt/ohpc/admin/images/centos7.7
```

*output example>*
>Using 'centos7.7' as the VNFS name  
Creating VNFS image from centos7.7  
Compiling hybridization link tree                           : 0.12 s  
Building file list                                          : 0.24 s  
Compiling and compressing VNFS                              : 6.03 s  
Adding image to datastore                                   : 51.45 s  
Wrote a new configuration file at: /etc/warewulf/vnfs/centos7.7.conf  
Total elapsed time   

### # Check vnfs List
```bash
wwsh vnfs list
```
*output example>*
>VNFS NAME            SIZE (M)   ARCH       CHROOT LOCATION
centos7.7            425.3      x86_64     /opt/ohpc/admin/images/centos7.7

### # 3.9.3 Register nodes for provisioning

#### # Set provisioning interface as the default networking device
```bash
echo "GATEWAYDEV=${NODE_INT_NIC}" > /etc/network.wwsh
wwsh -y file import /etc/network.wwsh --name network
wwsh -y file set network --path /etc/sysconfig/network --mode=0644 --uid=0
```

#### # Add new nodes to Warewulf data store
```bash
wwsh node new ${NODE_NAME}${NEW_NODE_NUM}
wwsh node new node1  
wwsh node new n1
```

```bash
wwsh node set ${NODE_NAME}${NEW_NODE_NUM} --netdev ${NODE_INT_NIC} \
--ipaddr=10.1.1.10 --hwaddr=<기입> --netmask=255.255.255.0 --gateway ${MASTER_IP}
```

```bash
wwsh node set node1 --netdev eth0 \
--ipaddr=10.1.1.10 --hwaddr=<기입> --netmask=255.255.255.0 --gateway ${MASTER_IP}
```

```bash
wwsh node list
```

#### # (Optional)
#### # Additional step required if desiring to use predictable network interface
#### # naming schemes (e.g. en4s0f0). Skip if using eth# style names.
#### # "이것을 적용하면 네트워크 인터페이스 명이 ens4s0f0 과 같은 형태로 표시됩니다."
#### # "eth0 과 같은 형식의 인터페이스명을 사용하려면 적용하지 않습니다."
```bash
export kargs="${kargs} net.ifnames=1,biosdevname=1"

wwsh -y provision set node1   --kargs="${kargs}"
wwsh -y provision set --postnetdown=1  node1
```

#### # Define provisioning image for hosts
```bash
wwsh -y provision set node1 --vnfs=centos7.7 --bootstrap=`uname -r ` \
--files=dynamic_hosts,passwd,group,shadow,network
```
\# Slurm 을 사용할 경우 - files= 에 slurm.conf,munge.key 도 추가.


#### # Restart dhcp / update PXE

```bash
systemctl restart dhcpd && wwsh pxe update
```


#### # 노드를 더 추가할 경우 'Set New node Number 부터 반복 합니다.'
***
#### # 노드 여러대를 한꺼번에 추가할 경우 의 예제 입니다.
#### # 배열 변수에 mac address 와 ip 할당.
```bash
node_mac[1]=aa:aa:aa:aa:aa:aa
node_mac[2]=bb:bb:bb:bb:bb:bb
node_mac[3]=cc:cc:cc:cc:cc:cc
node_mac[4]=dd:dd:dd:dd:dd:dd

node_ip[1]=10.1.1.10
node_ip[2]=10.1.1.20
node_ip[3]=10.1.1.30
node_ip[4]=10.1.1.40
```
#### # for 문을 이용해서 반복 수행
```bash
# for문 출력 예제.
for NEW_NODE_NUM in $(seq 1 4) ;  # 1~4 까지 순차적으로 수행.
do echo "";
echo node${NEW_NODE_NUM} mac = ${node_mac[NEW_NODE_NUM]} ;  # 배열 변수 사용시 중괄호{} 가 필요함.
echo node${NEW_NODE_NUM} ip = ${node_ip[NEW_NODE_NUM]} ;
echo "" ;
done
```

#### # 4x Add new nodes to Warewulf data store
```bash
for NEW_NODE_NUM in $(seq 1 4) ;
do echo "" ;
wwsh -y node new ${NODE_NAME}${NEW_NODE_NUM} --netdev ${NODE_INT_NIC} \
--ipaddr=${node_ip[NEW_NODE_NUM]} --hwaddr=${node_mac[NEW_NODE_NUM]} \
--gateway ${MASTER_IP} --netmask=255.255.255.0 ;
done
```

#### # 4x Define provisioning image for hosts
```bash
for NEW_NODE_NUM in $(seq 1 4) ;
do echo "" ;
wwsh -y provision set ${NODE_NAME}${NEW_NODE_NUM} --vnfs=centos7.7 \
--bootstrap=`uname -r `  --kargs="${kargs}" \
--files=dynamic_hosts,passwd,group,shadow,network ;
done
```


#### # define IPoIB network settings (if planning to mount NFS by IPoIB)
```bash
wwsh -y node set ${NODE_NAME}${NEW_NODE_NUM} -D ib0 --ipaddr=${c_ipoib[$i]} \
 --netmask=${ipoib_netmask}

wwsh -y provision set ${NODE_NAME}${NEW_NODE_NUM} --fileadd=ifcfg-ib0.ww
```
***

### # 3.7.5 configure stateful provisioning

#### # Add GRUB2 bootloader and re-assemble VNFS image
```bash
yum -y --installroot=${CHROOT} install grub2
wwvnfs --chroot ${CHROOT}
```

#### # Select (and customize) appropriate parted layout example
```bash
cp /root/Open_HPC/Provisioning/gpu.cmds /etc/warewulf/filesystem/
wwsh provision set --filesystem=gpt  node1
wwsh provision set --bootloader=sda  node1
```

#### # gpt.cmds Example

```bash
# BIOS / GPT Example

ll /etc/warewulf/filesystem/examples/gpt_example.cmds

# Parted specific commands
\select /dev/sda
mklabel gpt
mkpart primary 1MiB 3MiB
mkpart primary ext4 3MiB 513MiB
mkpart primary linux-swap 513MiB 33GiB
mkpart primary ext4 33Gib 100%
name 1 grub
name 2 boot
name 3 swap
name 4 root
set 1 bios_grub on
set 2 boot on

# mkfs NUMBER FS-TYPE [ARGS...]
mkfs 2 ext4 -L boot
mkfs 3 swap
mkfs 4 ext4 -L root

# fstab NUMBER fs_file fs_vfstype fs_mntops fs_freq fs_passno
fstab 4 / ext4 defaults 0 0
fstab 2 /boot ext4 defaults 0 0
fstab 3 swap swap defaults 0 0
```

#### In UEFI, Add GRUB2 bootloader and re-assemble VNFS image
```bash
yum -y --installroot=${CHROOT} install grub2 grub2-efi grub2-efi-modules
wwvnfs --chroot $CHROOT

cp /root/Open_HPC/Provisioning/efi.cmds /etc/warewulf/filesystem/
wwsh provision set --filesystem=efi  node1
wwsh provision set --bootloader=sda  node1
```

#### # Optionally Configure local boot (after successful provisioning)
```bash
wwsh provision set --bootlocal=normal  node1
```

#### # Configure PXE boot (Disk ReFormat)
```bash
wwsh -y provision set --bootlocal=FALSE
wwsh provision print  | grep "BOOTLOCAL"
```

#### # Remove Stateful config.
```bash
wwsh object modify -s FS=           -t node   n1
wwsh object modify -s BOOTLOADER=   -t node   n1
wwsh object modify -s BOOTLOCAL=    -t node   n1
```

## # 3.8 Boot compute nodes
### # 노드를 부팅 한 후 o/s 가 설치 되는지 확인 하고 새 노드에 접속해 봅니다.

```bash
ping -c 4 ${NODE_NAME}${NEW_NODE_NUM}
ping -c 4 node1

ssh ${NODE_NAME}${NEW_NODE_NUM}
ssh node1

df -hT | grep -v tmpfs
```

*output example>*
>[root@master:\~]# ping -c 4 ${NODE_NAME}${NEW_NODE_NUM}  
PING node1.localdomain (10.1.1.10) 56(84) bytes of data.  
64 bytes from node1.localdomain (10.1.1.10): icmp_seq=1 ttl=64 time=0.132 ms  
64 bytes from node1.localdomain (10.1.1.10): icmp_seq=2 ttl=64 time=0.119 ms  
64 bytes from node1.localdomain (10.1.1.10): icmp_seq=3 ttl=64 time=0.096 ms  
64 bytes from node1.localdomain (10.1.1.10): icmp_seq=4 ttl=64 time=0.119 ms  
--- node1.localdomain ping statistics ---  
4 packets transmitted, 4 received, 0% packet loss, time 2999ms  
rtt min/avg/max/mdev = 0.096/0.116/0.132/0.016 ms  
[root@master:\~]# ssh ${NODE_NAME}${NEW_NODE_NUM}  
[root@node1 \~]#   
[root@node1 \~]#   
[root@node1 \~]# df -hT  
Filesystem           Type      Size  Used Avail Use% Mounted on  
tmpfs                tmpfs      55G  647M   55G   2% /  
devtmpfs             devtmpfs   55G     0   55G   0% /dev  
tmpfs                tmpfs      55G     0   55G   0% /dev/shm  
tmpfs                tmpfs      55G  9.2M   55G   1% /run  
tmpfs                tmpfs      55G     0   55G   0% /sys/fs/cgroup  
master:/home         nfs        39T   55M   39T   1% /home  
master:/opt/ohpc/pub nfs       898G   12G  886G   2% /opt/ohpc/pub  
tmpfs                tmpfs      11G     0   11G   0% /run/user/0  
[root@node1 \~]#   

***

### # Command List of Checking Warewulf configuration
```bash
wwsh  file list

wwsh  bootstrap list

wwsh  vnfs list

wwsh  node list

wwsh  node print

wwsh  object  print  -p :all
```

***

# # 4. [Install OpenHPC Development Components](#목차)

## # 4.1 Development Tools

### # Install autotools meta-package (Default)
```bash
yum -y install  ohpc-autotools EasyBuild-ohpc hwloc-ohpc spack-ohpc valgrind-ohpc \
>> ~/dasan_log_ohpc_autotools,meta-package.txt 2>&1
tail -1 ~/dasan_log_ohpc_autotools,meta-package.txt
```

## # 4.2 Compilers (gcc ver 8, 7 and 5.4)
```bash
yum -y install  gnu8-compilers-ohpc gnu7-compilers-ohpc gnu-compilers-ohpc  \
 >> ~/dasan_log_ohpc_Compilers.txt 2>&1
tail -1 ~/dasan_log_ohpc_Compilers.txt
```

## # 4.3 MPI Stacks (for gnu7, gnu8)
```bash
yum -y install  openmpi-gnu7-ohpc openmpi3-gnu7-ohpc mvapich2-gnu7-ohpc mpich-gnu7-ohpc \
 >> ~/dasan_log_ohpc_MPI-Stacks_gnu7.txt 2>&1
tail -1 ~/dasan_log_ohpc_MPI-Stacks_gnu7.txt

yum -y install  openmpi3-gnu8-ohpc mpich-gnu8-ohpc mvapich2-gnu8-ohpc \
 >> ~/dasan_log_ohpc_MPI-Stacks_gnu8.txt 2>&1
tail -1 ~/dasan_log_ohpc_MPI-Stacks_gnu8.txt
```

## # 4.4 Performance Tools
### # Install perf-tools meta-package
```bash
yum -y install ohpc-gnu8-perf-tools >> ~/dasan_log_ohpc_perf-tools-gnu8.txt 2>&1
tail -1 ~/dasan_log_ohpc_perf-tools-gnu8.txt
```

***

## # 4.5 Setup default development environment

```bash
yum -y install  lmod-defaults-gnu7-openmpi3-ohpc  >> ~/dasan_log_ohpc_lmod-gnu7.txt 2>&1
tail -1 ~/dasan_log_ohpc_lmod-gnu7.txt

# Optionally
# yum -y install  lmod-defaults-gnu8-openmpi3-ohpc  >> ~/dasan_log_ohpc_lmod-gnu8.txt 2>&1
# tail -1 ~/dasan_log_ohpc_lmod-gnu8.txt
```

## # 4.6 3rd Party Libraries and Tools
### # Install 3rd party libraries/tools meta-packages built with GNU toolchain
```bash
yum -y install ohpc-gnu8-serial-libs ohpc-gnu8-io-libs ohpc-gnu8-python-libs \
 ohpc-gnu8-runtimes >> ~/dasan_log_ohpc_3rdPartyLib.txt 2>&1
tail -1 ~/dasan_log_ohpc_3rdPartyLib.txt
```

### # Install parallel lib meta-packages for all available MPI toolchains
```bash
yum -y install  ohpc-gnu8-mpich-parallel-libs ohpc-gnu8-openmpi3-parallel-libs \
  >> ~/dasan_log_ohpc_parallellib.txt 2>&1
tail -1 ~/dasan_log_ohpc_parallellib.txt
````

### # Install gnu5 MPI Stacks & lib & meta-packages
```bash
yum -y groupinstall  ohpc-io-libs-gnu ohpc-parallel-libs-gnu ohpc-parallel-libs-gnu-mpich \
 ohpc-python-libs-gnu ohpc-runtimes-gnu ohpc-serial-libs-gnu >> ~/dasan_log_ohpc_gnu5MPI.txt 2>&1
tail -1 ~/dasan_log_ohpc_gnu5MPI.txt
```

## # 4.7 Optional Development Tool Builds

### # Install OpenHPC compatibility packages (requires prior installation of Parallel Studio)
```bash
yum -y install intel-compilers-devel-ohpc intel-mpi-devel-ohpc >> ~/dasan_log_ohpc_compatibility.txt 2>&1
tail -1  ~/dasan_log_ohpc_compatibility.txt
```

### # Fast way ;)  (use script)
```bash
cd ~
git clone https://github.com/dasandata/Open_HPC
cat ./Open_HPC/Provisioning/4_Install_OpenHPC_Development_Components_1.3.6.sh

bash ./Open_HPC/Provisioning/4_Install_OpenHPC_Development_Components_1.3.6.sh
```
***



# # 5. [Resource Manager Startup](#목차)
\# **주의!** Resource Manager는 Slurm 과 PBSPro 중 선택하여 진행 합니다.  

## # [5-A. Start munge and slurm controller on master host](#목차)
\# 참조 링크: https://slurm.schedmd.com/
```bash

echo "
systemctl enable munge
systemctl enable slurmctld

systemctl start munge
systemctl start slurmctld

systemctl status munge
systemctl status slurmctld
" > /tmp/slurm_service.sh

bash /tmp/slurm_service.sh

```
\# slurmctld 의 상태가 failed 인 경우 /etc/slurm/slurm.conf 파일 설정상태를 점검해야 합니다.

### # sinfo
```bash
sinfo --long
sinfo -R
```
*output example>*
>PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST  
normal*      up 1-00:00:00      1  **drain** node1  
==========   
REASON               USER      TIMESTAMP           NODELIST  
Low socket*core*thre slurm     2018-02-25T11:45:44 node1  

\# 위와같이 PARTITION 의 STATE 가 drain 상태 일 경우 scontrol 명령을 사용해 node 의 상태를 resume 로 변경합니다.
```bash
scontrol  update  nodename=node1  state=resume
sinfo --long
```

## # [5-B. Start pbspro daemons on master host](#목차)
```bash
systemctl enable pbs
systemctl start pbs
```
### # initialize PBS path
```bash
source  /etc/profile.d/pbs.sh

# enable user environment propagation (needed for modules support)
qmgr -c "set server default_qsub_arguments= -V"
# enable uniform multi-node MPI task distribution
qmgr -c "set server resources_default.place=scatter"
# enable support for job accounting
qmgr -c "set server job_history_enable=True"
```

### # register compute hosts with pbspro (single node)
```bash
qmgr -c "create node node1"
```

### # x4 register compute hosts with pbspro
```bash
for NEW_NODE_NUM in "$(seq 1 4)"; do
qmgr -c "create node ${NODE_NAME}${NEW_NODE_NUM}"
done
```

### # check pbspro status

```bash
pbsnodes -aSj

qstat -q

qstat -ans
```

## # 6. [Run a Test Job](#목차)
```bash
wwsh file list
wwsh file resync
```

```bash
pdsh -w node1 uptime
pdsh -w node1 'rm -rf /tmp/.wwgetfile*  &&  /warewulf/bin/wwgetfiles'

# pbspro 인 경우
pdsh -w node1 systemctl status pbs | grep active

# slurm 인 경우
pdsh -w node1 systemctl status slurmd | grep active

# node가 여러대 인 경우
pdsh -w node[1-4] uptime
pdsh -w node[1-4] 'rm -rf /tmp/.wwgetfile*  &&  /warewulf/bin/wwgetfiles'
pdsh -w node[1-4] systemctl status pbs | grep active
```

### # 6.1 Interactive execution
#### # Switch to normal user
```bash
su - sonic   # sonic is dasandata's normal user name.
```
*output example>*
>[root@master:\~]#  
[root@master:\~]# su - sonic  
Last login: Sun Feb 25 11:28:01 KST 2018 from 192.168.0.152 on pts/0  
[sonic@master:\~]$  
[sonic@master:\~]$  

#### # Compile MPI "hello world" example
```bash
cd
pwd

mpicc -O3 /opt/ohpc/pub/examples/mpi/hello.c
ls
```
*output example>*
>[sonic@master:\~]$ mpicc -O3 /opt/ohpc/pub/examples/mpi/hello.c  
[sonic@master:\~]$ ls  
**a.out**  Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos  

#### # [(6-A. Slurm) Submit interactive job request and use prun to launch executable](#목차)
```bash
srun --help | grep 'ntasks\|nodes=N'

srun -n 8 -N 1 --pty /bin/bash
```
*output example>*
>[sonic@master:\~]$  
[sonic@master:\~]$ srun -n 8 -N 1 --pty /bin/bash  
[user@node1:\~]$  
[user@node1:\~]$  

```bash
squeue
```
*output example>*
>             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)  
                 5    normal     bash     user  R       3:58      1 node1  

```bash
prun ./a.out
```

*output example>*
>[prun] Master compute host = node1  
[prun] Resource manager = slurm  
[prun] Launch cmd = mpirun ./a.out (family=openmpi)  
 Hello, world (8 procs total)  
    --> Process #   0 of   8 is alive. -> node1  
    --> Process #   2 of   8 is alive. -> node1  
    --> Process #   3 of   8 is alive. -> node1  
    --> Process #   4 of   8 is alive. -> node1  
    --> Process #   5 of   8 is alive. -> node1  
    --> Process #   6 of   8 is alive. -> node1  
    --> Process #   7 of   8 is alive. -> node1  
    --> Process #   1 of   8 is alive. -> node1  

```bash
exit

srun -n 32 -N 1 --pty /bin/bash

prun ./a.out
```

*output example>*
>[prun] Master compute host = node1  
[prun] Resource manager = slurm  
[prun] Launch cmd = mpirun ./a.out (family=openmpi)  
 Hello, world (32 procs total)  
    --> Process #   0 of  32 is alive. -> node1  
    --> Process #   7 of  32 is alive. -> node1  
    --> Process #   8 of  32 is alive. -> node1  
    --> Process #   9 of  32 is alive. -> node1  
    --> Process #  10 of  32 is alive. -> node1  
    --> Process #  11 of  32 is alive. -> node1  
    --> Process #  12 of  32 is alive. -> node1  
    --> Process #  13 of  32 is alive. -> node1  
    --> Process #  14 of  32 is alive. -> node1  
    --> Process #  15 of  32 is alive. -> node1  
    --> Process #  16 of  32 is alive. -> node1  
    --> Process #  17 of  32 is alive. -> node1  
    --> Process #  18 of  32 is alive. -> node1  
    --> Process #  19 of  32 is alive. -> node1  
    --> Process #  20 of  32 is alive. -> node1  
    --> Process #  21 of  32 is alive. -> node1  
    --> Process #  22 of  32 is alive. -> node1  
    --> Process #  23 of  32 is alive. -> node1  
    --> Process #  24 of  32 is alive. -> node1  
    --> Process #  25 of  32 is alive. -> node1  
    --> Process #  26 of  32 is alive. -> node1  
    --> Process #  27 of  32 is alive. -> node1  
    --> Process #  28 of  32 is alive. -> node1  
    --> Process #  29 of  32 is alive. -> node1  
    --> Process #  30 of  32 is alive. -> node1  
    --> Process #  31 of  32 is alive. -> node1  
    --> Process #   1 of  32 is alive. -> node1  
    --> Process #   2 of  32 is alive. -> node1  
    --> Process #   3 of  32 is alive. -> node1  
    --> Process #   4 of  32 is alive. -> node1  
    --> Process #   5 of  32 is alive. -> node1  
    --> Process #   6 of  32 is alive. -> node1  

```bash
squeue

exit

squeue
```
*output example>*
>[user@node1:\~]$ squeue   
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)  
                 5    normal     bash     user  R       3:58      1 node1  
[user@node1:\~]$   
[user@node1:\~]$ exit  
exit  
[sonic@master:\~]$   
[sonic@master:\~]$ squeue   
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)  
[sonic@master:\~]$   

#### # [(6-B. PBS Pro) Submit interactive job request and use prun to launch executable](#목차)

```bash
qsub -I -l select=1:mpiprocs=4  # select = node 갯수 / mpiprocs = cpu 갯수

qstat
```
*output example>*
```
[dasan@master:~]$
[dasan@master:~]$ qsub -I -l select=1:mpiprocs=4
qsub: waiting for job 3.master to start
qsub: job 3.master ready

[dasan@node12:~]$
[dasan@node12:~]$ qstat
Job id            Name             User              Time Use S Queue
----------------  ---------------- ----------------  -------- - -----
3.master          STDIN            dasan             00:00:00 R workq           
[dasan@node12:~]$
```
***
```bash
prun ./a.out
```
*output example>*
```
[dasan@node12:~]$
[dasan@node12:~]$ prun ./a.out
[prun] Master compute host = node12
[prun] Resource manager = pbspro
[prun] Launch cmd = mpiexec -x LD_LIBRARY_PATH --prefix /opt/ohpc/pub/mpi/openmpi-gnu7/1.10.7 --hostfile /var/spool/pbs/aux/3.master ./a.out (family=openmpi)

 Hello, world (4 procs total)
    --> Process #   0 of   4 is alive. -> node12
    --> Process #   1 of   4 is alive. -> node12
    --> Process #   2 of   4 is alive. -> node12
    --> Process #   3 of   4 is alive. -> node12
[dasan@node12:~]$
```
***
```bash
qstat

exit

qstat
```
*output example>*
```
[dasan@node12:~]$
[dasan@node12:~]$ qstat
Job id            Name             User              Time Use S Queue
----------------  ---------------- ----------------  -------- - -----
3.master          STDIN            dasan             00:00:00 R workq           
[dasan@node12:~]$
[dasan@node12:~]$ exit
logout

qsub: job 3.master completed
[dasan@master:~]$
[dasan@master:~]$ qstat
[dasan@master:~]$
```
***
### # 6.2-A (Slurm) Batch execution
#### # Copy example job script
```bash
[sonic@master:~]$ cd ~
[sonic@master:~]$ pwd
/home/user
[sonic@master:~]$ cp /opt/ohpc/pub/examples/slurm/job.mpi .
[sonic@master:~]$ cat job.mpi
#!/bin/bash

#SBATCH -J test               # Job name
#SBATCH -o job.%j.out         # Name of stdout output file (%j expands to jobId)
#SBATCH -N 2                  # Total number of nodes requested
#SBATCH -n 16                 # Total number of mpi tasks requested
#SBATCH -t 01:30:00           # Run time (hh:mm:ss) - 1.5 hours

# Launch MPI-based executable

prun ./a.out
[sonic@master:~]$
[sonic@master:~]$
```

#### # Examine contents (and edit to set desired job sizing characteristics)
```bash
[sonic@master:~]$
[sonic@master:~]$ sed -i 's/#SBATCH -N 2/#SBATCH -N 1/'   job.mpi
[sonic@master:~]$
[sonic@master:~]$ grep '#SBATCH -N'  job.mpi
#SBATCH -N 1                  # Total number of nodes requested
[sonic@master:~]$
```

#### # Submit job for batch execution Example
```bash
[sonic@master:~]$ sbatch job.mpi
Submitted batch job 6
[sonic@master:~]$
[sonic@master:~]$ squeue
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
[sonic@master:~]$
[sonic@master:~]$ ls
a.out  Desktop  Documents  Downloads  job.6.out  job.mpi  Music  Pictures  Public  Templates  Videos
[sonic@master:~]$
[sonic@master:~]$ cat job.6.out
[prun] Master compute host = node1
[prun] Resource manager = slurm
[prun] Launch cmd = mpirun ./a.out (family=openmpi)

 Hello, world (16 procs total)
    --> Process #   0 of  16 is alive. -> node1
    --> Process #   1 of  16 is alive. -> node1
    --> Process #   2 of  16 is alive. -> node1
    --> Process #   3 of  16 is alive. -> node1
    --> Process #   4 of  16 is alive. -> node1
    --> Process #   5 of  16 is alive. -> node1
    --> Process #   6 of  16 is alive. -> node1
    --> Process #   7 of  16 is alive. -> node1
    --> Process #   8 of  16 is alive. -> node1
    --> Process #   9 of  16 is alive. -> node1
    --> Process #  10 of  16 is alive. -> node1
    --> Process #  11 of  16 is alive. -> node1
    --> Process #  12 of  16 is alive. -> node1
    --> Process #  13 of  16 is alive. -> node1
    --> Process #  14 of  16 is alive. -> node1
    --> Process #  15 of  16 is alive. -> node1
[sonic@master:~]$
```

### # 6.2-B (PBS Pro) Batch execution

#### # Copy example job script
```bash
[sonic@master:~]$ cd ~
[sonic@master:~]$ pwd
/home/user
[sonic@master:~]$ cp /opt/ohpc/pub/examples/pbspro/job.mpi .
[sonic@master:~]$ cat job.mpi
#!/bin/bash
#----------------------------------------------------------
# Job name
#PBS -N test

# Name of stdout output file
#PBS -o job.out

# Total number of nodes and MPI tasks/node requested
#PBS -l select=2:mpiprocs=4

# Run time (hh:mm:ss) - 1.5 hours
#PBS -l walltime=01:30:00
#----------------------------------------------------------

# Change to submission directory
cd $PBS_O_WORKDIR

# Launch MPI-based executable
prun ./a.out
[sonic@master:~]$
[sonic@master:~]$
```

#### # Examine contents (and edit to set desired job sizing characteristics)
```bash
[sonic@master:~]$
[sonic@master:~]$ sed -i 's/#PBS -l select=2/#PBS -l select=1/'   job.mpi
[sonic@master:~]$
[sonic@master:~]$ grep '#PBS -l select='  job.mpi
#PBS -l select=1:mpiprocs=4
[sonic@master:~]$
```

#### # Submit job for batch execution Example
```bash
[sonic@master:~]$ qsub job.mpi
7.master
[sonic@master:~]$
[sonic@master:~]$ qstat
[sonic@master:~]$
[sonic@master:~]$ ls
a.out    Documents  job.mpi  Music  Pictures  Templates  Videos
Desktop  Downloads  job.out  perl5  Public    test.e7
[sonic@master:~]$
[sonic@master:~]$ cat job.out
[prun] Master compute host = node12
[prun] Resource manager = pbspro
[prun] Launch cmd = mpiexec -x LD_LIBRARY_PATH --prefix /opt/ohpc/pub/mpi/openmpi-gnu7/1.10.7 --hostfile /var/spool/pbs/aux/7.coffee ./a.out (family=openmpi)

 Hello, world (4 procs total)
    --> Process #   0 of   4 is alive. -> node12
    --> Process #   2 of   4 is alive. -> node12
    --> Process #   1 of   4 is alive. -> node12
    --> Process #   3 of   4 is alive. -> node12
[sonic@master:~]$
```



```bash
[sonic@Master:~]$ cp /opt/ohpc/pub/examples/pbspro/job.mpi .
[sonic@Master:~]$ vi job.mpi
[sonic@Master:~]$
[sonic@Master:~]$
[sonic@Master:~]$ cat job.mpi
#!/bin/bash
#----------------------------------------------------------
# Job name
#PBS -N test-job

# Merge output and error files
#PBS -j oe

# Name of stdout output file
#PBS -o out.test-job.\$PBS_JOBID

# Total number of nodes and MPI tasks/node requested
#PBS -l select=1:mpiprocs=4:ncpus=4

# Run time (hh:mm:ss) - 1.5 hours
#PBS -l walltime=01:30:00
#----------------------------------------------------------

# Change to submission directory
cd $PBS_O_WORKDIR

# Launch MPI-based executable
date
prun ./a.out
hostname
date

[sonic@Master:~]$
[sonic@Master:~]$ qsub job.mpi
22.Master
[sonic@Master:~]$ qsub job.mpi
23.Master
[sonic@Master:~]$ qsub job.mpi
24.Master
[sonic@Master:~]$ qsub job.mpi
25.Master
[sonic@Master:~]$
[sonic@Master:~]$
[sonic@Master:~]$ qstat -ans

Master:
                                                            Req'd  Req'd   Elap
Job ID          Username Queue    Jobname    SessID NDS TSK Memory Time  S Time
--------------- -------- -------- ---------- ------ --- --- ------ ----- - -----
22.Master       sonic    workq    test         6229   1   4    --  01:30 R 00:00
   node1/0*4
   Job run at Thu Apr 26 at 20:44 on (node1:ncpus=4)
23.Master       sonic    workq    test         6263   1   4    --  01:30 R 00:00
   node1/1*4
   Job run at Thu Apr 26 at 20:44 on (node1:ncpus=4)
24.Master       sonic    workq    test         6297   1   4    --  01:30 R 00:00
   node1/2*4
   Job run at Thu Apr 26 at 20:44 on (node1:ncpus=4)
25.Master       sonic    workq    test         6331   1   4    --  01:30 R 00:00
   node1/3*4
   Job run at Thu Apr 26 at 20:44 on (node1:ncpus=4)
[sonic@Master:~]$
[sonic@Master:~]$ pbsnodes -aSj
                                                        mem       ncpus   nmics   ngpus
vnode           state           njobs   run   susp      f/t        f/t     f/t     f/t   jobs
--------------- --------------- ------ ----- ------ ------------ ------- ------- ------- -------
node1           free                 4     4      0      1tb/1tb 112/128     0/0     0/0 22,23,24,25
[sonic@Master:~]$
[sonic@Master:~]$ qsub job.mpi
26.Master
[sonic@Master:~]$
[sonic@Master:~]$ pbsnodes -aSj
                                                        mem       ncpus   nmics   ngpus
vnode           state           njobs   run   susp      f/t        f/t     f/t     f/t   jobs
--------------- --------------- ------ ----- ------ ------------ ------- ------- ------- -------
node1           free                 5     5      0      1tb/1tb 108/128     0/0     0/0 22,23,24,25,26
[sonic@Master:~]$
[sonic@Master:~]$ cat out.job
Thu Apr 26 20:44:34 KST 2018
[prun] Master compute host = node1
[prun] Resource manager = pbspro
[prun] Launch cmd = mpiexec -x LD_LIBRARY_PATH --prefix /opt/ohpc/pub/mpi/openmpi-gnu7/1.10.7 --hostfile /var/spool/pbs/aux/26.Master ./a.out (family=openmpi)

 Hello, world (4 procs total)
    --> Process #   0 of   4 is alive. -> node1
    --> Process #   2 of   4 is alive. -> node1
    --> Process #   1 of   4 is alive. -> node1
    --> Process #   3 of   4 is alive. -> node1
node1
Thu Apr 26 20:45:34 KST 2018
[sonic@Master:~]$
```

```
[sonic@Master:~]$ cat pbstest.sh
#!/bin/bash
#----------------------------------------------------------
# Job name
#PBS -N pbs-test

# Merge output and error files
#PBS -j oe

# Name of stdout output file
#PBS -o out.pbs-test

### Total number of nodes and core(cpu)
###PBS -l select=1::ncpus=4

# Run time (hh:mm:ss) - 1.5 hours
#PBS -l walltime=01:30:00
#----------------------------------------------------------

# Change to submission directory
cd $PBS_O_WORKDIR

# Launch executabled
date
hostname
sleep 20
echo ${PBS_JOBID}
date

# End of File.
[sonic@Master:~]$
[sonic@Master:~]$ qsub pbstest.sh
37.Master
[sonic@Master:~]$
[sonic@Master:~]$ cat out.pbs-test
Thu Apr 26 21:44:59 KST 2018
node1
37.Master
Thu Apr 26 21:45:19 KST 2018
[sonic@Master:~]$
[sonic@Master:~]$



```

#### # https://www0.sun.ac.za/hpc/index.php?title=HOWTO_submit_jobs
```bash
[sonic@Master:~]$
[sonic@Master:~]$ vi pbstest.sh
[sonic@Master:~]$
[sonic@Master:~]$ cat pbstest.sh
#!/bin/bash
#----------------------------------------------------------
# Job name
#PBS -N pbs-test

# Merge output and error files
#PBS -j oe

# Name of stdout output file
#PBS -o out.pbs-test

# Total number of nodes and core(cpu)
#PBS -l select=1:ncpus=8:mpiprocs=8

# Run time (hh:mm:ss) - 1.5 hours
#PBS -l walltime=01:30:00
#----------------------------------------------------------

# Change to submission directory
cd $PBS_O_WORKDIR

# Launch executabled
date
hostname
sleep 20
echo
echo "The nodefile for this job is stored at ${PBS_NODEFILE}"
cat ${PBS_NODEFILE}
np=$(wc -l < ${PBS_NODEFILE})
echo "Cores assigned: ${np}"
date
echo
# End of File.
[sonic@Master:~]$
[sonic@Master:~]$
[sonic@Master:~]$ qsub pbstest.sh
41.Master
[sonic@Master:~]$
[sonic@Master:~]$ qsub pbstest.sh
42.Master
[sonic@Master:~]$
[sonic@Master:~]$ pbsnodes -aSj ; echo ; qstat -ans
                                                        mem       ncpus   nmics   ngpus
vnode           state           njobs   run   susp      f/t        f/t     f/t     f/t   jobs
--------------- --------------- ------ ----- ------ ------------ ------- ------- ------- -------
node1           free                 2     2      0      1tb/1tb 112/128     0/0     0/0 41,42


Master:
                                                            Req'd  Req'd   Elap
Job ID          Username Queue    Jobname    SessID NDS TSK Memory Time  S Time
--------------- -------- -------- ---------- ------ --- --- ------ ----- - -----
41.Master       sonic    workq    pbs-test     7464   1   8    --  01:30 R 00:00
   node1/0*8
   Job run at Thu Apr 26 at 22:05 on (node1:ncpus=8)
42.Master       sonic    workq    pbs-test     7485   1   8    --  01:30 R 00:00
   node1/1*8
   Job run at Thu Apr 26 at 22:05 on (node1:ncpus=8)
[sonic@Master:~]$
[sonic@Master:~]$
```


# END.
