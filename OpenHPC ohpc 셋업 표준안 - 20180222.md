# 다산데이타 OpenHPC 1.3 (Centos 7.4) 셋업 표준안 (2018-02)
***
\# Root 로 로그인하여 설치를 시작 합니다.  
\# 참조 링크 : http://openhpc.community/downloads/  

***
## # 1. 변수 정의 및 선언 (파일로 작성)

```bash
vi ~/dasan_ohpc_variable.sh

```

\# '~/dasan_ohpc_variable.sh' 파일 내용.
```bash
#!/bin/bash

# 클러스터 이름.
CLUSTER_NAME=OpenHPC-Dasandata # 변경 필요

# MASTER 의 이름 과 IP.
MASTER_HOSTNAME=$(hostname)
MASTER_IP=10.1.1.1
MASTER_PREFIX=24

# 인터페이스 이름.
EXT_NIC=em2 # 외부망.
INT_NIC=p1p1 # 내부망.

# NODE 의 이름, 수량, 사양.
NODE_NAME=node
NODE_NUM=${전체 노드 수}
NODE_RANGE="[1-3]"  # 전체 노드가 3개일 경우 1-3 / 5대 일 경우 [1-5]

# NODE 의 CPU 사양에 맞게 조정.
# 물리 CPU가 2개 이고, CPU 당 코어가 10개, 하이퍼스레딩은 켜진(Enable) 상태 인 경우.  
SOCKETS=2          ## 물리 CPU 2개
CORESPERSOCKET=10  ## CPU 당 코어 10개
THREAD=2           ## 하이퍼스레딩 Enable

# 노드 배포 이미지 경로.
export CHROOT=/opt/ohpc/admin/images/centos7.4

# end of file.
```

\# 변수 적용.
```bash
source  ~/dasan_ohpc_variable.sh

```

***

## # 2. Network, Firewall Setup.

### # 외부망 및 내부망 인터페이스 설정.

```bash
ip a    # 인터페이스 목록 확인

```
출력 예)
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

#### # Master 의 외부/내부 인터페이스 설정내용 확인
```bash
cat /etc/sysconfig/network-scripts/ifcfg-${EXT_NIC}

```
출력 예)
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
출력 예)
>NAME=*p1p1*  
ONBOOT=no  
BOOTPROTO=dhcp  
<일부 값 생략>  

### # 가독성 향상을 위해, 불 필요한 IPV6 항목 삭제.
```bash
sed -i '/IPV6/d' /etc/sysconfig/network-scripts/ifcfg-${EXT_NIC}
sed -i '/IPV6/d' /etc/sysconfig/network-scripts/ifcfg-${INT_NIC}

```

### # Master 의 내부망 인터페이스의 설정 변경.
```bash
perl -pi -e 's/BOOTPROTO=dhcp/BOOTPROTO=none/' /etc/sysconfig/network-scripts/ifcfg-${INT_NIC}
perl -pi -e 's/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-${INT_NIC}
```

### # Master 의 내부망 ip 설정
```bash
echo "IPADDR=${MASTER_IP}"  >>  /etc/sysconfig/network-scripts/ifcfg-${INT_NIC}
echo "PREFIX=${MASTER_PREFIX}"  >>  /etc/sysconfig/network-scripts/ifcfg-${INT_NIC}

cat /etc/sysconfig/network-scripts/ifcfg-${INT_NIC}

```

### # ip 변경 설정 적용
```bash
ifdown ${INT_NIC} && ifup ${INT_NIC}

ip a

```
출력 예)
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

### # 방화벽 설정 변경
```bash
firewall-cmd --change-interface=${EXT_NIC}  --zone=external  --permanent
firewall-cmd --change-interface=${INT_NIC}  --zone=trusted   --permanent
firewall-cmd --reload

firewall-cmd --list-all --zone=external
```
출력 예)
>*external* (active)  
target: *default*  
icmp-block-inversion: no  
interfaces: *em2*  

```bash
firewall-cmd --list-all --zone=trusted

```
출력 예)
>*trusted* (active)  
  target: ACCEPT  
  icmp-block-inversion: no  
  interfaces: em1 *p1p1*  

***

## # 3. Install OpenHPC Components
### # 3.1 Enable OpenHPC repository for local use

### # 현재 repolist 확인
```bash
yum repolist

```

출력 예)  
>Loaded plugins: fastestmirror, langpacks, priorities  
Loading mirror speeds from cached hostfile  
 * base: data.nicehosting.co.kr  
 * epel: mirror01.idc.hinet.net  
 * extras: data.nicehosting.co.kr  
 * updates: data.nicehosting.co.kr  
116 packages excluded due to repository priority protections  
repo id             repo name                                         status  
!base/7/x86_64      CentOS-7 - Base                                        9,591  
!epel/x86_64        Extra Packages for Enterprise Linux 7 - x86_64    12,182+116  
!extras/7/x86_64    CentOS-7 - Extras                                        388  
!updates/7/x86_64   CentOS-7 - Updates                                     1,929  
repolist: 24,090  

### # Install to OpenHPC repository.
```bash
yum -y install \
http://build.openhpc.community/OpenHPC:/1.3/CentOS_7/x86_64/ohpc-release-1.3-1.el7.x86_64.rpm \
>> ~/dasan_log_ohpc_openhpc_repository.txt

tail ~/dasan_log_ohpc_openhpc_repository.txt
```

출력 예)  
> Running transaction test  
Transaction test succeeded  
Running transaction  
  Installing : ohpc-release-1.3-1.el7.x86_64                                1/1   
  Verifying  : ohpc-release-1.3-1.el7.x86_64                                1/1   
Installed:  
  ohpc-release.x86_64 0:1.3-1.el7                                               
Complete!  

### # repolist 확인
```

```bash
yum repolist

```
출력 예)
>Loaded plugins: fastestmirror, langpacks, priorities  
OpenHPC                                                  | 1.6 kB     00:00     
OpenHPC-updates                                          | 1.2 kB     00:00     
(1/3): OpenHPC/group_gz                                    | 1.7 kB   00:00     
(2/3): OpenHPC/primary                                     | 155 kB   00:01     
(3/3): OpenHPC-updates/primary                             | 192 kB   00:01     
Loading mirror speeds from cached hostfile  
 * base: data.nicehosting.co.kr  
 * epel: mirror.rise.ph  
 * extras: data.nicehosting.co.kr  
 * updates: data.nicehosting.co.kr  
OpenHPC                                                                 821/821  
OpenHPC-updates                                                       1010/1010  
139 packages excluded due to repository priority protections  
repo id             repo name                                         status  
OpenHPC             OpenHPC-1.3 - Base                                   321+500  
OpenHPC-updates     OpenHPC-1.3 - Updates                                428+582  
base/7/x86_64       CentOS-7 - Base                                        9,591  
epel/x86_64         Extra Packages for Enterprise Linux 7 - x86_64    12,182+116  
extras/7/x86_64     CentOS-7 - Extras                                        388  
updates/7/x86_64    CentOS-7 - Updates                                     1,929  
repolist: 24,839  


### # NTP Server 설정

```bash
cat /etc/ntp.conf | grep -v "#\|^$"

```
출력 예)
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

systemctl enable ntpd.service
systemctl restart ntpd

```

## # 4. OpenHPC base, Resource Management Services Install.

### # 클러스터 마스터 IP 와 HOSTNAME 을 hosts 에 등록.
```bash
echo "${MASTER_IP}     ${MASTER_HOSTNAME}"  >>  /etc/hosts
cat /etc/hosts
```
출력 예)
>127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4  
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6  
*10.1.1.1    master*  

### # openhpc base 설치

```bash
yum -y install ohpc-base ohpc-warewulf  >>  ~/dasan_log_ohpc_base,warewulf.txt
tail ~/dasan_log_ohpc_base,warewulf.txt

```
출력 예)  
>  tftp-server.x86_64 0:5.2-13.el7                     
  warewulf-cluster-ohpc.x86_64 0:3.8pre-9.2                                     
  warewulf-common-ohpc.x86_64 0:3.8pre-11.1                                     
  warewulf-ipmi-ohpc.x86_64 0:3.8pre-9.1                                        
  warewulf-provision-ohpc.x86_64 0:3.8pre-28.1                                  
  warewulf-provision-server-ohpc.x86_64 0:3.8pre-28.1                           
  warewulf-vnfs-ohpc.x86_64 0:3.8pre-19.1                                       
  xinetd.x86_64 2:2.3.15-13.el7                                                 
Complete!  



## # 4번 항목중 , Resource Manager는 Slurm 과 PBS Pro 중 선택하여 진행 합니다.
\# GPU Cluster 의 경우 63-A. Slurm 을 설치해야 합니다.

## # 4-A. (Slurm) resource management services Install
### # Install to ohpc-slurm-server
```bash
yum -y install ohpc-slurm-server  >> ~/dasan_log_ohpc_resourcemanager_slurm.txt
tail ~/dasan_log_ohpc_resourcemanager_slurm.txt
```
출력 예)
>  pmix-ohpc.x86_64 0:1.2.3-20.1                                                 
  slurm-devel-ohpc.x86_64 0:17.02.9-69.2                                        
  slurm-munge-ohpc.x86_64 0:17.02.9-69.2                                        
  slurm-ohpc.x86_64 0:17.02.9-69.2                                              
  slurm-perlapi-ohpc.x86_64 0:17.02.9-69.2                                      
  slurm-plugins-ohpc.x86_64 0:17.02.9-69.2                                      
  slurm-slurmdbd-ohpc.x86_64 0:17.02.9-69.2                                     
  slurm-sql-ohpc.x86_64 0:17.02.9-69.2                                          
Complete!  

### # Slurm config file 설정 (/etc/slurm/slurm.conf)

#### # ClusterName 변경
```bash
grep ClusterName /etc/slurm/slurm.conf

```
출력 예)
>ClusterName=linux  

```bash
perl -pi -e "s/ClusterName=\S+/ClusterName=${CLUSTER_NAME}/"  /etc/slurm/slurm.conf

grep ClusterName /etc/slurm/slurm.conf

```
출력 예)
>ClusterName=*OpenHPC-Dasandata*

#### # ControlMachine 이름 변경
```bash
grep ControlMachine /etc/slurm/slurm.conf

```
출력 예)
>ControlMachine=linux0   

```bash
perl -pi -e "s/ControlMachine=\S+/ControlMachine=${MASTER_HOSTNAME}/" /etc/slurm/slurm.conf

grep ControlMachine /etc/slurm/slurm.conf

```
출력 예)
>ControlMachine=*master*

#### # NodeName, CPU & Memory 속성 설정

\# slurm.conf 파일의 NodeName을 클러스터 노드의 Hostname 과 동일하게 변경하고,
\# 사양에 맞추어 Sockets, Cores, Thread, RealMemory 값을 변경 합니다.
\# Sockets = 노드의 물리적인 CPU 갯수.
\# CoresPerSocket = 각 물리 CPU의 논리적 코어 갯수.
\# Thread = 하이퍼스레딩 사용 여부. (사용시 2, 미사용시 1)
\# RealMemory = 노드의 실제 메모리 보다 약간 작게 합니다. 단위는 megabyte (예를 들어 64GB 라면 60GB = 60000)

##### # NodeName 설정
```bash
echo "NodeName="${NODE_NAME}${NODE_RANGE} &&  # 선언 되어 있는 변수 확인
grep NodeName= /etc/slurm/slurm.conf  # slurm 설정 파일의 기본 값 확인.
```
출력 예)
>NodeName=node[1-3]  
NodeName=c[1-4] Sockets=2 CoresPerSocket=8 ThreadsPerCore=2 State=UNKNOWN  

```bash
perl -pi -e "s/NodeName=\S+/NodeName=${NODE_NAME}${NODE_RANGE}/" /etc/slurm/slurm.conf
grep NodeName= /etc/slurm/slurm.conf
```
출력 예) **노드 이름이 'node' 이고, 총 수량은 3대 일 경우**
>NodeName=*node[1-3]* Sockets=2 CoresPerSocket=8 ThreadsPerCore=2 State=UNKNOWN  



##### # Node CPU, Memory 속성 설정

\# 앞서 정의한 변수 값을 다시 한번 검토 한 후 진행 합니다.
```bash
cat ~/dasan_ohpc_variable.sh
```

\# slurm 설정파일(slurm.conf)의  기존 설정 값 확인.
```bash
grep NodeName= /etc/slurm/slurm.conf
```
출력 예)
>NodeName=node[1-3] Sockets=2 CoresPerSocket=8 ThreadsPerCore=2 State=UNKNOWN  

```bash
perl -pi -e "s/Sockets=\S+/Sockets=${SOCKETS}/"  /etc/slurm/slurm.conf
perl -pi -e "s/CoresPerSocket=\S+/CoresPerSocket=${CORESPERSOCKET}/"  /etc/slurm/slurm.conf
perl -pi -e "s/ThreadsPerCore=\S+/ThreadsPerCore=${THREAD}/"  /etc/slurm/slurm.conf

grep NodeName= /etc/slurm/slurm.conf
```
출력 예)
>NodeName=node[1-3] Sockets=*2* CoresPerSocket=*10* ThreadsPerCore=*2* State=UNKNOWN  


## # 4-B. (PBS Pro) resource management services Install
### # Install to pbspro-server-ohpc

```bash
yum -y install pbspro-server-ohpc

```

## # 5. (Optional) Add InfiniBand support services on master node

```bash
yum -y groupinstall "InfiniBand Support"
yum -y install infinipath-psm
```

### # 5-1. (Optional) Load InfiniBand drivers
```bash
systemctl start rdma

cp /opt/ohpc/pub/examples/network/centos/ifcfg-ib0     /etc/sysconfig/network-scripts
```

### # 5-2. (Optional) Define local IPoIB(IP Over InfiniBand) address and netmask
```bash
perl -pi -e "s/master_ipoib/${sms_ipoib}/" /etc/sysconfig/network-scripts/ifcfg-ib0
perl -pi -e "s/ipoib_netmask/${ipoib_netmask}/" /etc/sysconfig/network-scripts/ifcfg-ib0

echo  “MTU=4096”  >>  /
```

### # 5-3. (Optional) Initiate ib0 (InfiniBand Interface 0)
```bash
ifup ib0

rdma   tunning

udaddy -s  10.1.1.1

```


## # 6. Complete basic Warewulf setup for master node

### # 클러스터 내부망 인터페이스 변경.
\# 내부망 인터페이스 설정 내용 점검.
```bash
echo ${INT_NIC}

ifconfig ${INT_NIC}
```

\# warewulf provision.conf 파일의 기본값 확인.
```bash
grep device /etc/warewulf/provision.conf
```
출력 얘)
># What is the default network device that the master will use to  
network device = eth1  

\# 인터페이스 명 변경
```bash

perl -pi -e "s/device = eth1/device = ${INT_NIC}/" /etc/warewulf/provision.conf
grep device /etc/warewulf/provision.conf
```

### # tftp 서비스 Enable.
```bash
grep disable /etc/xinetd.d/tftp
perl -pi -e "s/^\s+disable\s+= yes/ disable = no/" /etc/xinetd.d/tftp
grep disable /etc/xinetd.d/tftp
```

### # 관련 서비스 부팅시 시작 되도록 변경(enable) 및 Restarting.
```bash
systemctl enable dhcpd
systemctl restart xinetd

systemctl enable mariadb.service
systemctl restart mariadb

systemctl enable httpd.service
systemctl restart httpd
```

### # Define NODE image for provisioning

#### # Check chroot location
```bash
echo ${CHROOT}
```
출력 예)
>/opt/ohpc/admin/images/centos7.4

#### # Build initial chroot image
```bash
wwmkchroot centos-7 ${CHROOT}
```

#### # Install compute node base meta-package
```bash
yum -y --installroot=${CHROOT} install ohpc-base-compute  parted  xfsprogs  python-devel

cat /etc/resolv.conf
cp -p /etc/resolv.conf ${CHROOT}/etc/resolv.conf
```

***

#### # Add Slurm client support meta-package
\# **주의!** - Resource Manager 로 **Slurm** 을 사용하는 경우에만 실행 합니다.
```bash
yum -y --installroot=${CHROOT} install ohpc-slurm-client
```

#### # Add PBS Professional client support
\# **주의!** - Resource Manager 로 **PBS** 를 사용하는 경우에만 실행 합니다.
```bash
yum -y --installroot=${CHROOT} install pbspro-execution-ohpc

grep PBS_SERVER ${CHROOT}/etc/pbs.conf
perl -pi -e "s/PBS_SERVER=\S+/PBS_SERVER=${MASTER_HOSTNAME}/" ${CHROOT}/etc/pbs.conf

chroot ${CHROOT}/opt/pbs/libexec/pbs_habitat

grep clienthost ${CHROOT}/var/spool/pbs/mom_priv/config
perl -pi -e "s/\$clienthost \S+/\$clienthost ${MASTER_HOSTNAME}/" ${CHROOT}/var/spool/pbs/mom_priv/config
grep clienthost ${CHROOT}/var/spool/pbs/mom_priv/config

echo "\$usecp *:/home /home" >> ${CHROOT}/var/spool/pbs/mom_priv/config
cat    ${CHROOT}/var/spool/pbs/mom_priv/config
chroot ${CHROOT}/opt/pbs/libexec/pbs_habitat

chroot ${CHROOT} systemctl enable pbs
```

***

#### # (Optional) Add IB support and enable
```bash
yum -y --installroot=${CHROOT} groupinstall "InfiniBand Support"
yum -y --installroot=${CHROOT} install infinipath-psm
chroot ${CHROOT} systemctl enable rdma
```

#### # Add Network Time Protocol (NTP) support
```bash
yum -y --installroot=${CHROOT} install ntp
```

#### # Add kernel drivers
```bash
yum -y --installroot=${CHROOT} install kernel
```

#### # Include modules user environment
```bash
yum -y --installroot=${CHROOT} install lmod-ohpc
```


### # Customize system configuration

#### # Initialize warewulf database and add new cluster key to base image
```bash
wwinit database
wwinit ssh_keys
cat ~/.ssh/cluster.pub >> ${CHROOT}/root/.ssh/authorized_keys
```

#### # Add NFS client mounts of /home and /opt/ohpc/pub and /data to base image
```bash
echo ${MASTER_HOSTNAME}
cat  ${CHROOT}/etc/fstab

echo "${MASTER_HOSTNAME}:/home /home nfs nfsvers=3,rsize=1024,wsize=1024,cto 0 0" >> ${CHROOT}/etc/fstab
echo "${MASTER_HOSTNAME}:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3 0 0" >> ${CHROOT}/etc/fstab
# data 디렉토리를 별도로 구성하는 경우에만.
# echo "${MASTER_HOSTNAME}:/data /data nfs nfsvers=3 0 0" >> ${CHROOT}/etc/fstab
cat  ${CHROOT}/etc/fstab
```

#### # Export /home and OpenHPC public packages from master server
```bash
cat /etc/exports
echo "/home *(rw,no_subtree_check,fsid=10,no_root_squash)" >> /etc/exports
echo "/opt/ohpc/pub *(ro,no_subtree_check,fsid=11)" >> /etc/exports
echo "/data *(rw,no_subtree_check,fsid=10,no_root_squash)" >> /etc/exports
cat /etc/exports

exportfs -a
systemctl enable nfs-server
systemctl restart nfs-server
```

#### # Enable NTP time service on computes and identify master host as local NTP server
chroot ${CHROOT} systemctl enable ntpd
echo "server ${MASTER_HOSTNAME}" >> ${CHROOT}/etc/ntp.conf

***

### # (Additional Custom) Increase locked memory limits

#### # Update memlock settings on master and compute
```bash
perl -pi -e 's/# End of file/\* soft memlock unlimited\n$&/s' /etc/security/limits.conf
perl -pi -e 's/# End of file/\* hard memlock unlimited\n$&/s' /etc/security/limits.conf
perl -pi -e 's/# End of file/\* soft memlock unlimited\n$&/s' ${CHROOT}/etc/security/limits.conf
perl -pi -e 's/# End of file/\* hard memlock unlimited\n$&/s' ${CHROOT}/etc/security/limits.conf

tail /etc/security/limits.conf
tail ${CHROOT}/etc/security/limits.conf
```

#### # 제외 // - (Additional Custom) Enable ssh control via resource manager (Slurm)
\# slurm Resource Manager 를 통한 명령 외에 는 노드에 접근할 수 없도록 하는 설정 인데,
\# 관리의 편의를 위해 설정하지 않습니다.
```bash
# echo "account required pam_slurm.so" >> ${CHROOT}/etc/pam.d/sshd
```

### # 제외 // - (Additional Custom) Enable forwarding of system logs

### # Configure SMS to receive messages and reload rsyslog configuration

grep ModLoad /etc/rsyslog.conf

perl -pi -e "s/\\#\\\$ModLoad imudp/\\\$ModLoad imudp/" /etc/rsyslog.conf
perl -pi -e "s/\\#\\\$UDPServerRun 514/\\\$UDPServerRun 514/" /etc/rsyslog.conf

grep ModLoad /etc/rsyslog.conf
grep UDPServerRun /etc/rsyslog.conf

systemctl restart rsyslog

# Define compute node forwarding destination
echo "*.* @${MASTER_HOSTNAME}:514" >> ${CHROOT}/etc/rsyslog.conf

# Disable most local logging on computes. Emergency and boot logs will remain on the compute nodes
perl -pi -e "s/^\*\.info/\\#\*\.info/" ${CHROOT}/etc/rsyslog.conf
perl -pi -e "s/^authpriv/\\#authpriv/" ${CHROOT}/etc/rsyslog.conf
perl -pi -e "s/^mail/\\#mail/" ${CHROOT}/etc/rsyslog.conf
perl -pi -e "s/^cron/\\#cron/" ${CHROOT}/etc/rsyslog.conf
perl -pi -e "s/^uucp/\\#uucp/" ${CHROOT}/etc/rsyslog.conf


   - (Additional Custom) Add Ganglia monitoring
# Install Ganglia meta-package on master
yum -y install ohpc-ganglia

# Install Ganglia compute node daemon
yum -y --installroot=${CHROOT} install ganglia-gmond-ohpc

# Use example configuration script to enable unicast receiver on master host
/usr/bin/cp  /opt/ohpc/pub/examples/ganglia/gmond.conf  /etc/ganglia/gmond.conf

grep 'host =' /etc/ganglia/gmond.conf
perl -pi -e "s/<sms>/${MASTER_HOSTNAME}/" /etc/ganglia/gmond.conf
grep 'host ='  /etc/ganglia/gmond.conf

# Add configuration to compute image and provide gridname
/usr/bin/cp   /etc/ganglia/gmond.conf  ${CHROOT}/etc/ganglia/gmond.conf
echo "gridname MySite" >> /etc/ganglia/gmetad.conf


# Start and enable Ganglia services
systemctl enable gmond
systemctl enable gmetad
systemctl start gmond
systemctl start gmetad

chroot ${CHROOT} systemctl enable gmond

# Restart web server
systemctl try-restart httpd

#Open http://localhost/ganglia




    제외 // - (Additional Custom) Add ClusterShell
# Install ClusterShell
yum -y install clustershell-ohpc

# Setup node definitions
cd /etc/clustershell/groups.d
mv local.cfg local.cfg.orig

echo "adm: ${MASTER_HOSTNAME}" > local.cfg
echo "compute: ${NODE_NAME}" >> local.cfg
echo "all: @adm,@compute" >> local.cfg

cat local.cfg

제외 // - (Additional Custom) Add genders
# Install genders
yum -y install genders-ohpc

# Generate a sample genders file
echo -e "${MASTER_HOSTNAME}\tsms" > /etc/genders
for ((i=1; i<$NODE_NUM; i++)) ; do echo -e "${NODE_NAME[$i]}\tcompute" done >> /etc/genders





- Import files

#Import files
wwsh file import /etc/passwd
wwsh file import /etc/group
wwsh file import /etc/shadow

# optional support for controlling IPoIB interfaces
wwsh file import /opt/ohpc/pub/examples/network/centos/ifcfg-ib0.ww
wwsh -y file set ifcfg-ib0.ww --path=/etc/sysconfig/network-scripts/ifcfg-ib0


- Finalizing provisioning configuration

# Assemble bootstrap image
wwbootstrap  `uname -r`

# (Optional) Include BeeGFS/Lustre drivers; needed if enabling additional kernel modules on computes
export WW_CONF=/etc/warewulf/bootstrap.conf
echo "drivers += updates/kernel/" >> $WW_CONF
# (Optional) Include overlayfs drivers; needed by Singularity
echo "drivers += overlay" >> $WW_CONF

- Assemble Virtual Node File System (VNFS) image

# Assemble Virtual Node File System (VNFS) image
export CHROOT=/opt/ohpc/admin/images/centos7.4
wwvnfs --chroot ${CHROOT}


64. Register nodes for provisioning
# Set provisioning interface as the default networking device
echo "GATEWAYDEV=eth0" > /tmp/network.$$
wwsh -y file import /tmp/network.$$ --name network
wwsh -y file set network --path /etc/sysconfig/network --mode=0644 --uid=0

 # Add new nodes to Warewulf data store
wwsh -y node new n01  --netdev  eth0 --ipaddr=10.1.1.1 --hwaddr=******** --gateway ${MASTER_IP}  --netmask=255.255.255.0

# Define provisioning image for hosts
wwsh -y provision set "n01" --vnfs=centos7.3 --bootstrap=` uname -r ` --files=dynamic_hosts,passwd,group,shadow,slurm.conf,munge.key,network

wwsh  node list
wwsh  node print
wwsh  object  print  -p :all
wwsh  file list
wwsh  pxe  update
wwsh  dhcp  update
wwsh  dhcp   restart
wwsh  bootstrap  list
wwsh  vnfs  list




# Restart dhcp / update PXE
systemctl restart dhcpd
wwsh pxe update

- node  n01 boot on pxe

ping n01
ssh n01
df -hT

su - dasan
ssh n01

제외 // @@. OpenHPC - Masquerade Setting

- Master 설정

[root@ohpc-master:~]# echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/ip_forward.conf
[root@ohpc-master:~]#
[root@ohpc-master:~]# cat /etc/sysctl.d/ip_forward.conf
net.ipv4.ip_forward = 1
[root@ohpc-master:~]#
[root@ohpc-master:~]# sysctl -p /etc/sysctl.d/ip_forward.conf
net.ipv4.ip_forward = 1
[root@ohpc-master:~]#
[root@ohpc-master:~]# sysctl --all | grep net.ipv4.ip_forward
net.ipv4.ip_forward = 1
net.ipv4.ip_forward_use_pmtu = 0
[root@ohpc-master:~]#
[root@ohpc-master:~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: em3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 24:6e:96:6e:60:7c brd ff:ff:ff:ff:ff:ff
    inet 10.1.1.254/24 brd 10.1.1.255 scope global em3
       valid_lft forever preferred_lft forever
3: em4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 24:6e:96:6e:60:7d brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.146/24 brd 192.168.0.255 scope global em4
       valid_lft forever preferred_lft forever
4: em1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 24:6e:96:6e:60:78 brd ff:ff:ff:ff:ff:ff
5: em2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 24:6e:96:6e:60:7a brd ff:ff:ff:ff:ff:ff
[root@ohpc-master:~]#
[root@ohpc-master:~]# firewall-cmd --zone=external  --add-masquerade  --permanent
success
[root@ohpc-master:~]# firewall-cmd --list-all --zone=external
external (active)
  target: default
  icmp-block-inversion: no
  interfaces: em4
  sources:
  services: vnc-server
  ports: 7777/tcp 1311/tcp
  protocols:
  masquerade: yes
  forward-ports:
  sourceports:
  icmp-blocks:
  rich rules:

[root@ohpc-master:~]# firewall-cmd --list-all --zone=trusted
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: em3
  sources:
  services:
  ports:
  protocols:
  masquerade: no
  forward-ports:
  sourceports:
  icmp-blocks:
  rich rules:

[root@ohpc-master:~]#
i
- node 에 설정 적용 (설정 안되어 있었을 경우)

[root@ohpc-master:~]# wwsh -y node set compute01 --gateway 10.1.1.254
[root@ohpc-master:~]# wwsh dhcp update
Rebuilding the DHCP configuration
Done.
[root@ohpc-master:~]# wwsh dhcp restart
Restarting the DHCP service
Done.
[root@ohpc-master:~]# grep 10.1.1.254 /etc/dhcp/dhcpd.conf
    option pxelinux.pathprefix "tftp://10.1.1.254/warewulf/";
    filename "tftp://10.1.1.254/warewulf/pxelinux.0";
      option routers 10.1.1.254;
      next-server 10.1.1.254;
[root@ohpc-master:~]#

[root@ohpc-master:~]# ssh compute01 reboot
Connection to compute01 closed by remote host.
[root@ohpc-master:~]#
[root@ohpc-master:~]# ssh compute01 ip r
default via 10.1.1.254 dev eth0
10.1.1.0/24 dev eth0  proto kernel  scope link  src 10.1.1.10
169.254.0.0/16 dev eth0  scope link  metric 1002
[root@ohpc-master:~]#


65. OpenHPC - Add Node (Clone)

wwsh node list
wwsh -y node clone n01 n02
wwsh node list


wwsh -y node set n02 --netdev=eth0 --ipaddr=10.1.1.2 --hwaddr=70:85:c2:4d:a8:b7  --gateway=10.1.1.254  --netmask=255.255.255.0


## #66. WOL - Wake Nodes

vi node_on_by_WOL.sh
cat node_on_by_WOL.sh

============================

# Node List
n0[1]=70:85:c2:4d:a8:9a
n0[2]=70:85:c2:4d:a8:b7
n0[3]=70:85:c2:4d:a7:d4
n0[4]=70:85:c2:4d:a8:28
n0[5]=70:85:c2:4d:a8:a7
n0[6]=70:85:c2:4d:a8:b5
n0[7]=70:85:c2:4d:a8:b1
n0[8]=70:85:c2:4d:a7:ac

# Node Num + 1
NODE_NUM=9

# Wake On Command
for ((i=1 ; i<$NODE_NUM ; i++))
do
ether-wake -i em2 ${n0[$i]}
done

=============================

sh node_on_by_WOL.sh

pdsh -w n[01-08] date | sort


## # 64. OpenHPC - Add User

adduser test
passwd test

echo  “Y”  | wwsh file import /etc/passwd
echo  “Y” |  wwsh file import /etc/group
echo  “Y” |  wwsh file import /etc/shadow

wwinit ssh_keys
wwsh   file  resync  passwd  shadow  group

pdsh -w n[01-02] /warewulf/bin/wwgetfiles

su - test
ssh compute01


65. OpenHPC - Node Boot Image Update (after add Program)
[root@ohpc-master:~]# # Define chroot location
[root@ohpc-master:~]# export CHROOT=/opt/ohpc/admin/images/centos7.4
[root@ohpc-master:~]# echo ${CHROOT}
/opt/ohpc/admin/images/centos7.3
[root@ohpc-master:~]#
[root@ohpc-master:~]# yum -y --installroot=${CHROOT} install tmux
Loaded plugins: fastestmirror, langpacks, priorities

<생략>

Complete!
[root@ohpc-master:~]#
[root@ohpc-master:~]# wwvnfs --chroot /opt/ohpc/admin/images/centos7.3
<생략>

[root@ohpc-master:~]#
[root@ohpc-master:~]# ssh compute01
Last login: Mon Aug 28 10:00:18 2017 from ohpc-master
[root@compute01 ~]#
[root@compute01 ~]# tmux
-bash: tmux: command not found
[root@compute01 ~]#
[root@compute01 ~]# reboot
Connection to compute01 closed by remote host.
Connection to compute01 closed.
[root@ohpc-master:~]#
[root@ohpc-master:~]#
[root@ohpc-master:~]# ssh compute01
[root@compute01 ~]#
[root@compute01 ~]# tmux
[exited]
[root@compute01 ~]# [root@compute01 ~]# which tmux
/usr/bin/tmux



제외 // @@. OpenHPC - user's ssh login to compute nodes

vi /opt/ohpc/admin/images/centos7.3/etc/pam.d/sshd
tail -5 /opt/ohpc/admin/images/centos7.3/etc/pam.d/sshd

session    include      password-auth
session    include      postlogin
# Used with polkit to reauthorize users in remote sessions
-session   optional     pam_reauthorize.so prepare
#account required pam_slurm.so

wwvnfs --chroot /opt/ohpc/admin/images/centos7.3

ssh compute01 reboot
ssh compute02 reboot


66. OpenHPC -  Node Local Disk Mount (/scratch)


# Define chroot location
```bash
echo ${CHROOT}

yum -y --installroot=${CHROOT} install parted xfsprogs
mkdir ${CHROOT}/scratch
wwvnfs --chroot=${CHROOT}

pdsh -w n[01-08] reboot
```

===== reboot ======
```bash
pdsh -w n[01-08] date

pdsh -w n[01-08] parted  -s /dev/sda "mklabel  GPT "
pdsh -w n[01-08] parted  -s /dev/sda "mkpart primary 0% 100%"
pdsh -w n[01-08] mkfs.xfs  -f  -L SCRATCH   -i  size=1024  -s  size=4096   /dev/sda1
```

```bash
export CHROOT=/opt/ohpc/admin/images/centos7.4
echo "LABEL="SCRATCH"  /scratch   xfs  defaults  0 0 "  >>  ${CHROOT}/etc/fstab
cat ${CHROOT}/etc/fstab

vi ${CHROOT}/etc/rc.d/rc.local
tail -3 ${CHROOT}/etc/rc.d/rc.local
```

# dasandata add
chmod 1777 /scratch

ll ${CHROOT}/etc/rc.d/rc.local
chmod +x ${CHROOT}/etc/rc.d/rc.local

ll ${CHROOT}/etc/rc.d/rc.local

wwvnfs --chroot=${CHROOT}

pdsh -w n[01-08] reboot

===== reboot ======

```bash
pdsh -w n[01-08] date

pdsh -w n[01-08] lsblk
pdsh -w n[01-08] 'df -hT | grep -v tmpfs' | sort | grep -v Filesystem

pdsh -w n[01-08] 'll / | grep scratch'

```


## # 67.  Install OpenHPC Development Components

# Install autotools meta-package (Default)
```bash
yum -y  install ohpc-autotools EasyBuild-ohpc hwloc-ohpc spack-ohpc valgrind-ohpc
```

# Compilers ## gcc ver 7 and 5.4
```bash
yum -y  install gnu7-compilers-ohpc   gnu-compilers-ohpc
```

# MPI Stacks
```bash
yum -y  install openmpi-gnu7-ohpc mvapich2-gnu7-ohpc mpich-gnu7-ohpc
```

# Install perf-tools meta-package
```bash
yum -y  install ohpc-gnu7-perf-tools
yum -y  groupinstall  ohpc-perf-tools-gnu
```

# Setup default development environment
```bash
yum -y  install lmod-defaults-gnu7-openmpi-ohpc
```
### yum -y install lmod-defaults-gnu-openmpi-ohpc


# Install 3rd party libraries/tools meta-packages built with GNU toolchain
```bash
yum -y  install   ohpc-gnu7-serial-libs   ohpc-gnu7-io-libs   ohpc-gnu7-python-libs  ohpc-gnu7-runtimes
```

# Install parallel lib meta-packages for all available MPI toolchains
yum -y  install   ohpc-gnu7-mpich-parallel-libs   ohpc-gnu7-mvapich2-parallel-libs   ohpc-gnu7-openmpi-parallel-libs

# Install gnu5  MPI Stacks & lib & meta-packages
yum -y  groupinstall    ohpc-io-libs-gnu    ohpc-parallel-libs-gnu  ohpc-parallel-libs-gnu-mpich    \
ohpc-python-libs-gnu  ohpc-runtimes-gnu    ohpc-serial-libs-gnu


68.  (PBS Pro)  Resource Manager Startup  & Run a Test Job



# start pbspro daemons on master host
systemctl enable pbs
systemctl start pbs


# initialize PBS path
source  /etc/profile.d/pbs.sh

qmgr -c "print server"


# enable user environment propagation (needed for modules support)
qmgr -c "set server default_qsub_arguments= -V"

# enable uniform multi-node MPI task distribution
qmgr -c "set server resources_default.place=scatter"

# enable support for job accounting
qmgr -c "set server job_history_enable=True"


# register compute hosts with pbspro
# Node Num + 1
NODE_NUM=9
for ((i=1 ; i<$NODE_NUM ; i++))  ;   do  qmgr -c "create node n0$i"  ;   done

ll /var/spool/pbs/server_priv/topology
pbsnodes -a
pbsnodes -l   # show down node

=========
-  Interactive execution

# Switch to "test" user
su - test

# Check environment
module list
module purge
module av
module load ohpc
module list

gcc -v
which mpirun
which mpicc


# Compile MPI "hello world" example
mpicc -O3  hello.c

# Submit interactive job request and use prun to launch executable

qsub -I -l select=2:mpiprocs=4   #Select -> Nodes Number  // mpicprocs  => Thread per node (Tasks per node)

user@n01 ~]$ prun ./a.out

    --> Process #   1 of   8 is alive. -> n01
    --> Process #   2 of   8 is alive. -> n01
    --> Process #   3 of   8 is alive. -> n01
    --> Process #   0 of   8 is alive. -> n01
    --> Process #   7 of   8 is alive. -> n02
    --> Process #   4 of   8 is alive. -> n02
    --> Process #   5 of   8 is alive. -> n02
    --> Process #   6 of   8 is alive. -> n02


-  Batch execution


### PBS env check
vi pbs_env.sh

#!/bin/sh
hostname
pwd
echo HOME=$PBS_O_HOME
echo PATH=$PBS_O_PATH
echo SHELL=$PBS_O_SHELL
echo PID=$$
echo PBS_O_HOST=$PBS_O_HOST
echo PBS_O_QUEUE=$PBS_O_QUEUE
echo PBS_O_WORKDIR=$PBS_O_WORKDIR
echo PBS_ENVIRONMENT=$PBS_ENVIRONMENT
echo PBS_JOBID=$PBS_JOBID
echo PBS_JOBNAME=$PBS_JOBNAME
echo PBS_NODEFILE=$PBS_NODFILE
echo PBS_QUEUE=$PBS_QUEUE

qsub pbs_env.sh
cat pbs_env.sh.o??


# Copy example job script
cp /opt/ohpc/pub/examples/pbspro/job.mpi  hello.mpi

# Examine contents (and edit to set desired job sizing characteristics)
(1) cat hello-prun.mpi
#!/bin/bash
#----------------------------------------------------------
# Job name
#PBS -N hello

# queue select
#PBS -q workq

# Name of stdout output file (default)
###PBS -o job.out

# stdout output file  -> 실행파일 이름으로 생성
#PBS -j oe

# Total number of nodes and MPI tasks/node requested
#PBS -l select=2:mpiprocs=4

# Max Run time (hh:mm:ss) - 1.5 hours
#PBS -l walltime=01:30:00
#----------------------------------------------------------
# Change to submission directory
cd $PBS_O_WORKDIR

module purge
module  load ohpc

# Launch MPI-based executable
prun ./a.out


(2) cat hello-mpirun.mpi
#!/bin/bash
#----------------------------------------------------------
# Job name
#PBS -N hello

# queue select
#PBS -q workq

# Name of stdout output file (default)
###PBS -o job.out

# stdout output file  -> 실행파일 이름으로 생성
#PBS -j oe

# Total number of nodes and MPI tasks/node requested
#PBS -l select=4:mpiprocs=8

# Max Run time (hh:mm:ss) - 1.5 hours
#PBS -l walltime=01:30:00
#----------------------------------------------------------
# Change to submission directory
cd $PBS_O_WORKDIR

module purge
module  load ohpc

# Launch MPI-based executable
echo starting

echo '---------------------------------------------'
num_proc=`wc -l $PBS_NODEFILE | awk '{print $1}'`
echo 'num_proc='$num_proc
echo '---------------------------------------------'
cat $PBS_NODEFILE
echo '---------------------------------------------'

export  OMPI_mtl=^psm
mpirun  -np $num_proc -hostfile $PBS_NODEFILE  ./a.out




# Submit job for batch execution
qsub hello.mpi
5.master





70.  LAMMPS (Molecular Dynamics Simulator)

cd /opt/ohpc/pub/apps/

wget http://jaist.dl.sourceforge.net/project/lammps/lammps-15May15.tar.gz
wget http://jaist.dl.sourceforge.net/project/lammps/lammps-1Feb14.tar.gz
wget https://sourceforge.net/projects/lammps/files/lammps-16Feb16.tar.gz

tar xvzf ....

cd lammps-16Feb16

cat lib/reax/Makefile.lammps.gfortran
cat lib/meam/Makefile.lammps.gfortran
cat lib/poems/Makefile.lammps.empty
cat lib/poems/Makefile.g++

cd lib/reax/
make -f Makefile.gfortran

cd ../meam/
 make -f Makefile.gfortran

cd ../poems/
make -f Makefile.g++

cd ../src/
make yes-standard

make no-gpu no-KOKKOS no-VORONOI no-KIM no-GRANULAR
make ps

yum install python-devel
make mpi

# 실행파일 경로 / 링크

mkdir -p /opt/ohpc/pub/apps/lammps/bin
ln -s /opt/ohpc/pub/apps/lammps-16Feb16/src/lmp_mpi  /opt/ohpc/pub/apps/lammps/bin/lmp_mpi_16Feb16


# example test
cd
mkdir lammps_test
cd lammps_test

cp -r /opt/ohpc/pub/apps/lammps-16Feb16/examples/ .
cd  examples/meam/

vi lammps_mpi.sh
#!/bin/bash
#----------------------------------------------------------
# Job name
#PBS -N lammps_meam

# queue select
#PBS -q workq

# Name of stdout output file (default)
###PBS -o job.out

# stdout output file  -> 실행파일 이름으로 생성
#PBS -j oe

# Total number of nodes and MPI tasks/node requested
#PBS -l select=4:mpiprocs=8

# Max Run time (hh:mm:ss) - 1.5 hours
#PBS -l walltime=01:30:00
#----------------------------------------------------------
# Change to submission directory
cd $PBS_O_WORKDIR

module purge
module  load ohpc

# Launch MPI-based executable
echo starting

echo '---------------------------------------------'
num_proc=`wc -l $PBS_NODEFILE | awk '{print $1}'`
echo 'num_proc='$num_proc
echo '---------------------------------------------'
cat $PBS_NODEFILE
echo '---------------------------------------------'

export  OMPI_mtl=^psm

lmp_cmd=/opt/ohpc/pub/apps/lammps/bin/lmp_mpi_16Feb16
mpirun  -np $num_proc -hostfile $PBS_NODEFILE  $lmp_cmd < in.meam


qsub lammps_mpi.sh
cat lammps_meam.o32



71.  Material Studio Install


rpm -qa | grep  glibc
rpm -qa | grep  libgcc
rpm -qa | grep  libstdc++
rpm -qa | grep  redhat-lsb
rpm -qa | grep  compat-libstdc++
rpm -qa | grep  fontconfig
rpm -qa | grep libSM
rpm -qa | grep libXext
rpm -qa | grep libXrender
rpm -qa | grep java

yum install  -y  glibc*.i686  libgcc*.i686  redhat-lsb  redhat-lsb*.i686  compat-libstdc++*  compat-libstdc++*.i686
yum install  -y  compat-libstdc++*  compat-libstdc++*.i686


ls -l /usr/lib/jvm/
rpm -qa | grep java
java -version

export CHROOT=/opt/ohpc/admin/images/centos7.4
yum -y --installroot=${CHROOT} install glibc*.i686  libgcc*.i686  redhat-lsb  redhat-lsb*.i686  \
compat-libstdc++*  compat-libstdc++*.i686 compat-libstdc++*  compat-libstdc++*.i686

wwvnfs --chroot ${CHROOT}

chroot ${CHROOT} rpm -qa | grep  glibc
chroot ${CHROOT} rpm -qa | grep  libgcc
chroot ${CHROOT} rpm -qa | grep  libstdc++
chroot ${CHROOT} rpm -qa | grep  redhat-lsb
chroot ${CHROOT} rpm -qa | grep  compat-libstdc++
chroot ${CHROOT} rpm -qa | grep  fontconfig
chroot ${CHROOT} rpm -qa | grep libSM
chroot ${CHROOT} rpm -qa | grep libXext
chroot ${CHROOT} rpm -qa | grep libXrender

pdsh -w n[01-08] reboot












@@. OpenHPC - NFS Mount

[root@ohpc-master:openhpc]# # export nfs.
[root@ohpc-master:openhpc]# cat /etc/exports
/home *(rw,no_subtree_check,fsid=10,no_root_squash)
/data *(rw,no_subtree_check,fsid=12,no_root_squash)
[root@ohpc-master:openhpc]# systemctl restart nfs-server
[root@ohpc-master:openhpc]#
[root@ohpc-master:openhpc]# # Define chroot location
[root@ohpc-master:openhpc]# export CHROOT=/opt/ohpc/admin/images/centos7.4

[root@ohpc-master:openhpc]# # Add NFS client mounts of /home and /opt/ohpc/pub and /data to base image
[root@ohpc-master:openhpc]# echo "ohpc-master:/home /home nfs nfsvers=3,rsize=1024,wsize=1024,cto 0 0" >> ${CHROOT}/etc/fstab
[root@ohpc-master:openhpc]# echo "ohpc-master:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3 0 0" >> ${CHROOT}/etc/fstab
[root@ohpc-master:openhpc]# echo "ohpc-master:/data /data nfs nfsvers=3 0 0" >> ${CHROOT}/etc/fstab
[root@ohpc-master:openhpc]#
[root@ohpc-master:openhpc]# wwvnfs --chroot /opt/ohpc/admin/images/centos7.3
[root@ohpc-master:openhpc]# #Nodes reboot
[root@ohpc-master:openhpc]# pdsh -w compute0[1-2] reboot

@@. Install OpenHPC Development Components

[root@ohpc-master:~]# #Install OpenHPC Development Components
[root@ohpc-master:~]# yum -y install gnu7-compilers-ohpc
[root@ohpc-master:~]# yum -y install openmpi-gnu7-ohpc mvapich2-gnu7-ohpc mpich-gnu7-ohpc
[root@ohpc-master:~]# yum -y install ohpc-gnu7-perf-tools
[root@ohpc-master:~]# yum -y install lmod-defaults-gnu7-mvapich2-ohpc
[root@ohpc-master:~]#
[root@ohpc-master:~]# # 3rd Party Libraries and Tools
[root@ohpc-master:~]# yum -y install ohpc-gnu7-serial-libs ohpc-gnu7-io-libs ohpc-gnu7-python-libs ohpc-gnu7-runtimes ohpc-gnu7-mpich-parallel-libs ohpc-gnu7-mvapich2-parallel-libs  ohpc-gnu7-openmpi-parallel-libs


@@ . Intel Compile install   < Free  versaion  >
intel  login   /  KDS   gmail  id   and  Passwd   /

https://software.intel.com/en-us/parallel-studio-xe/choose-download/free-trial-cluster-linux-fortran
https://software.seek.intel.com/ps-l

30일   lic  획득하기 …

 Tip  :    한번  설치 한 후   30일 경과시   같은   direcory  에서
install  한후    다시  인증 받은 후    나머지   과정 생략 한후   빠져 나옵니다..
    그럼   계속 사용 할 수 있습니다.

[root@statgpu:~]# ls -l /scratch/
total 26304
drwxr-xr-x 4 18837 2222      188  4월 28 20:05 parallel_studio_xe_2017_update4_cluster_edition_online
-rw-r--r-- 1 root  root 26931848  4월 28 13:05 parallel_studio_xe_2017_update4_cluster_edition_online.tgz

 [root@statgpu:scratch]# cd parallel_studio_xe_2017_update4_cluster_edition_online/
[root@statgpu:parallel_studio_xe_2017_update4_cluster_edition_online]# ./install.sh


확인  하기 ..
[dasan@statgpu:hpl]$ cat /opt/intel/licenses/l_G2RJ5TLF.lic


intel  compiler  install 하기

Getting Started
--------------------------------------------------------------------------------
Welcome to the Intel(R) Parallel Studio XE 2017 Update 4 Cluster Edition for Linux* setup program.

--------------------------------------------------------------------------------
Do you want to Install or Download? Please choose:
--------------------------------------------------------------------------------
1. Install to this computer [default]
2. Download for later installation on the same or another computer.

q. Quit
--------------------------------------------------------------------------------
Please type a selection or press "Enter" to accept default choice [1]: 1

accept

Step 2 of 5 | License activation
--------------------------------------------------------------------------------
If you have purchased this product and have the serial number and a connection
to the internet you can choose to activate the product at this time.
Alternatively, you can choose to evaluate the product or defer activation by
choosing the evaluate option. Evaluation software will time out in about one
month. You can also use license file or Intel(R) Software License Manager.
--------------------------------------------------------------------------------
1. Use existing license [default]
2. I want to activate my product using a serial number
3. I want to evaluate Intel(R) Parallel Studio XE 2017 Update 4 Cluster Edition
for Linux* or activate later (EXPIRED)
4. I want to activate by using a license file, or by using Intel(R) Software
License Manager

h. Help
b. Back to the previous menu
q. Quit
--------------------------------------------------------------------------------
Please type a selection or press "Enter" to accept default choice [1]: 2

Please type your serial number (the format is XXXX-XXXXXXXX): =VZ3N-G2RJ5TLF   ⇒>  30일 마다   다시   받아야 합니다.


Step 3 of 5 | Options > Configure Cluster Installation
--------------------------------------------------------------------------------
This product can be installed on cluster nodes.
--------------------------------------------------------------------------------
1. Finish configuring installation target [default]

2. Installation target                           [ Current system only ]

h. Help
b. Back to the previous menu
q. Quit
--------------------------------------------------------------------------------
Please type a selection or press "Enter" to accept default choice [1]: 1


Step 3 of 5 | Options > Pre-install Summary
--------------------------------------------------------------------------------
Install location:
    /opt/intel/parallel_studio_xe_2017.4.056

Download location:
    /tmp/root/l_psxe_2017.4.056

Component(s) selected:
    Intel(R) Trace Analyzer and Collector 2017 Update 3
        Intel(R) Trace Analyzer for Intel(R) 64 Architecture
        Intel(R) Trace Collector for Intel(R) 64 Architecture
        Intel(R) Trace Collector for Intel(R) Many Integrated Core Architecture

    Intel(R) Cluster Checker 2017 Update 2
        Cluster Checker common files
        Cluster Checker Analyzer
        Cluster Checker Collector

    Intel(R) VTune(TM) Amplifier XE 2017 Update 3
        Command line interface
        Sampling Driver kit
        Graphical user interface

    Intel(R) Inspector 2017 Update 3
        Command line interface
        Graphical user interface

    Intel(R) Advisor 2017 Update 3
        Command line interface
        Graphical user interface

    Intel(R) C++ Compiler 17.0 Update 4
        Intel C++ Compiler

    Intel(R) Fortran Compiler 17.0 Update 4
        Intel Fortran Compiler

    Intel(R) Math Kernel Library 2017 Update 3 for C/C++
        Intel MKL core libraries for C/C++
        Intel(R) Xeon Phi(TM) coprocessor support for C/C++

 Cluster support for C/C++
        Intel TBB threading support
        GNU* C/C++ compiler support

    Intel(R) Math Kernel Library 2017 Update 3 for Fortran
        Intel MKL core libraries for Fortran
        Intel(R) Xeon Phi(TM) coprocessor support for Fortran
        Cluster support for Fortran
        GNU* Fortran compiler support
        Fortran 95 interfaces for BLAS and LAPACK

    Intel(R) Integrated Performance Primitives 2017 Update 3
        Intel IPP single-threaded libraries: General package

    Intel(R) Threading Building Blocks 2017 Update 6
        Intel TBB

    Intel(R) Data Analytics Acceleration Library 2017 Update 3
        Intel(R) Data Analytics Acceleration Library 2017 Update 3

    Intel(R) MPI Library 2017 Update 3
        Intel MPI Benchmarks 2017 Update 2
        Intel MPI Library for applications running on Intel(R) 64 Architecture
        Intel MPI Library for applications running on Intel(R) Many Integrated
Core Architecture

    Intel(R) Debugger for Heterogeneous Compute 2017 Update 4
        GNU* GDB 7.6 and ELFDWARF library

    GNU* GDB 7.10
        GNU* GDB 7.10 on Intel(R) 64

    Intel(R) Debugger for Intel(R) MIC Architecture 2017 Update 4
        GNU* GDB 7.8
        GDB Eclipse* Integration

Install space required:    0MB
Download space required:    1MB

Driver parameters:
    Sampling driver install type: Driver will be built
    Load drivers: yes
    Reload automatically at reboot: yes
    Per-user collection mode: no
    Drivers will be accessible to everyone on this system. To restrict access,
        select Customize Installation > Change advanced options > Drivers are accessible to
        and set group access.

Installation target:
    Install on the current system only

--------------------------------------------------------------------------------
1. Start installation Now [default]
2. Customize installation

h. Help
b. Back to the previous menu
q. Quit
--------------------------------------------------------------------------------
Please type a selection or press "Enter" to accept default choice [1]: 1

계속    진행 하면    /opt/intel  밑에    설치 됩니다..  ///



@@. Resource Manager Startup

[root@ohpc-master:~]# systemctl enable munge
[root@ohpc-master:~]# systemctl enable slurmctld
[root@ohpc-master:~]#
[root@ohpc-master:~]# systemctl start munge
[root@ohpc-master:~]# systemctl start slurmctld
[root@ohpc-master:~]#
[root@ohpc-master:~]# chroot /opt/ohpc/admin/images/centos7.3
[root@ohpc-master:/]# systemctl enable slurmd
Created symlink /etc/systemd/system/multi-user.target.wants/slurmd.service, pointing to /usr/lib/systemd/system/slurmd.service.
[root@ohpc-master:/]# exit
exit
[root@ohpc-master:~]# wwvnfs --chroot /opt/ohpc/admin/images/centos7.3
[root@ohpc-master:~]#
[root@ohpc-master:~]# pdsh -w compute0[1-2] systemctl start slurmd


@@. Interactive execution

[root@ohpc-master:~]# su - user
Last login: Mon Aug 28 11:19:08 KST 2017 from 192.168.0.153 on pts/1
[user@ohpc-master:~]$
[user@ohpc-master:~]$ mpicc  /opt/ohpc/pub/examples/mpi/hello.c
[user@ohpc-master:~]$ ll
total 12K
-rwxrwxr-x 1 user user 8.4K Aug 28 11:39 a.out
drwxr-xr-x 2 user user    6 Aug 20 15:08 Desktop
drwxr-xr-x 2 user user    6 Aug 20 15:08 Documents
drwxr-xr-x 2 user user    6 Aug 20 15:08 Downloads
drwxr-xr-x 2 user user    6 Aug 20 15:08 Music
drwxr-xr-x 2 user user    6 Aug 20 15:08 Pictures
drwxr-xr-x 2 user user    6 Aug 20 15:08 Public
drwxr-xr-x 2 user user    6 Aug 20 15:08 Templates
drwxr-xr-x 2 user user    6 Aug 20 15:08 Videos
[user@ohpc-master:~]$ ./a.out

 Hello, world (1 procs total)
    --> Process #   0 of   1 is alive. -> ohpc-master
[user@ohpc-master:~]$
[user@ohpc-master:~]$ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
normal*      up 1-00:00:00      2   down compute[01-02]
[user@ohpc-master:~]$
[root@ohpc-master:~]# sinfo -N
NODELIST   NODES PARTITION STATE
compute01      1   normal* down
compute02      1   normal* down
[user@ohpc-master:~]$ su -
Password:
Last login: Mon Aug 28 19:32:08 KST 2017 on pts/0

[root@ohpc-master:~]#
[root@ohpc-master:~]# scontrol update nodename="compute0[1-2]" state=RESUME
[root@ohpc-master:~]#
[root@ohpc-master:~]# sinfo --long
Tue Aug 29 10:34:36 2017
PARTITION AVAIL  TIMELIMIT   JOB_SIZE ROOT OVERSUBS     GROUPS  NODES       STATE NODELIST
normal*      up 1-00:00:00 1-infinite   no       NO        all      2        idle compute[01-02]
[root@ohpc-master:~]#
[root@ohpc-master:~]# srun -n4  -l /bin/hostname
srun: error: Unable to allocate resources: Requested node configuration is not available
[root@ohpc-master:~]# srun -n2  -l /bin/hostname
1: compute02
0: compute01
[root@ohpc-master:~]#





8.1    HPL   TEST


intel     HPL

https://software.intel.com/en-us/articles/performance-tools-for-software-developers-hpl-application-note


#####  HPL.dat   화일  만들기 ..

http://www.advancedclustering.com/act_kb/tune-hpl-dat-file/


wget   http://www.netlib.org/benchmark/hpl/hpl-2.2.tar.gz

 #tar xvzf hpl-2.2.tar.gz
 #cd hpl-2.2/
 #mv hpl-2.2 hpl
 #cd hpl
 #cp setup/Make.Linux_PII_CBLAS  .
 #mv Make.Linux_PII_CBLAS Make.intel64

# cat Make.intel64  | grep  -v "#"
SHELL        = /bin/sh
CD               = cd
CP              = cp
LN_S           = ln -s
MKDIR        = mkdir
RM               = /bin/rm -f
TOUCH        = touch
ARCH          = intel64
TOPdir        = $(HOME)/HPL/hpl
INCdir         = $(TOPdir)/include
BINdir         = $(TOPdir)/bin/$(ARCH)
LIBdir         = $(TOPdir)/lib/$(ARCH)
HPLlib        = $(LIBdir)/libhpl.a

MPdir          = /opt/intel/impi/2017.3.196/
MPinc         = -I$(MPdir)/include64
MPlib          = $(MPdir)/lib64/libmpi_mt.so

LAdir          = /opt/intel/compilers_and_libraries_2017.4.196/linux/mkl/lib/intel64/
LAinc         = -l/opt/intel/compilers_and_libraries_2017.4.196/linux/mkl/include
LAlib          = -mkl=cluster

F2CDEFS      =
HPL_INCLUDES = -I$(INCdir) -I$(INCdir)/$(ARCH) $(LAinc) $(MPinc)
HPL_LIBS     = $(HPLlib) $(LAlib) $(MPlib)
HPL_OPTS     = -DHPL_CALL_CBLAS
HPL_DEFS     = $(F2CDEFS) $(HPL_OPTS) $(HPL_INCLUDES)

CC           = mpiicc
CCNOOPT      = $(HPL_DEFS)
CCFLAGS      = -qopenmp -xHost -fomit-frame-pointer -O3 -funroll-loops
LINKER       = mpiicc
LINKFLAGS    = $(CCFLAGS)
ARCHIVER     = ar
ARFLAGS      = r
RANLIB       = echo
# make arch=intel64
…...
OK

#ls -l bin/intel64/

rw-r--r-- 1 root root   1133  8월 22 22:06 HPL.dat
-rwxr-xr-x 1 root root 408992  8월 22 22:06 xhpl

#su -  user

$cp /home/program/HPL/hpl/bin/intel64/* .
$source  /share/apps/intel/bin/compilervars.sh  intel64

or

$  module   load intel

$mpiexec.hydra   --hostfile  ~/hostfile  -np  112  ./xhpl  | tee  -a  hpl-test

OR

$mpirun --hostfile  ~/hostfile  -np  112  ./xhpl  | tee  -a  hpl-test

cat  hpl-test

===END ====


2.    intel   linpack benchmark

https://software.intel.com/en-us/articles/intel-mkl-benchmarks-suite

http://registrationcenter-download.intel.com/akdlm/irc_nas/9752/l_mklb_p_2017.3.018.tgz

[root@c6320p-1:hpl]# make arch=intel64
……..

[root@c6320p-1:hpl]# pwd
/home/program/HPL/hpl
[root@c6320p-1:hpl]# ls -l bin/intel64/
total 404
-rw-r--r-- 1 root root   1133  8월 22 22:06 HPL.dat
-rwxr-xr-x 1 root root 408992  8월 22 22:06 xhpl
[root@c6320p-1:hpl]#

===========================


3. Running Linpack (HPL) Test on Linux Cluster with OpenMPI and Intel Compilers

 yum install  atlas  atlas-devel    blas  blas-devel  lapack lapack-devel
 wget   http://www.netlib.org/benchmark/hpl/hpl-2.2.tar.gz

  변경 합니다.

 tar xvzf hpl-2.2.tar.gz
 cd hpl-2.2/
 mv hpl-2.2 hpl
 cd hpl
 cp setup/Make.Linux_PII_CBLAS  .
 vi Make.Linux_PII_CBLAS

[root@master:hpl]# cat Make.Linux_PII_CBLAS | grep MPdir
# used. The variable MPdir is only used for defining MPinc and MPlib.
MPdir = /opt/ohpc/pub/mpi/openmpi-gnu/1.10.4
MPinc = -I$(MPdir)/include
MPlib = $(MPdir)/lib/libmpi.so

[root@master:hpl]# cat Make.Linux_PII_CBLAS | grep LAdir
# used. The variable LAdir is only used for defining LAinc and LAlib.
LAdir = /usr/lib64/atlas
LAlib = $(LAdir)/libtatlas.so $(LAdir)/libsatlas.so

[root@master:hpl]#
root@GIST-R740:ATLAS]# rpm -qa  | grep  atlas
atlas-3.10.1-12.el7.x86_64
[root@GIST-R740:ATLAS]#
[root@GIST-R740:ATLAS]#
[root@GIST-R740:ATLAS]# rpm -ql  atlas-3.10.1-12.el7.x86_64
/etc/ld.so.conf.d/atlas-x86_64.conf
/usr/lib64/atlas
/usr/lib64/atlas/libsatlas.so.3
/usr/lib64/atlas/libsatlas.so.3.10
/usr/lib64/atlas/libtatlas.so.3
/usr/lib64/atlas/libtatlas.so.3.10
/usr/share/doc/atlas-3.10.1
/usr/share/doc/atlas-3.10.1/README.dist
[root@GIST-R740:ATLAS]#


[root@hnode:hpl]# cat Make.Linux_PII_CBLAS | grep LINKER
LINKER = /usr/bin/gfortran

 #make arch=Linux_PII_CBLAS
 #cp bin/Linux_PII_CBLAS/xhpl       /home/dasan/
 #cp bin/Linux_PII_CBLAS/HPL.dat   /home/dasan/
 #chown dasan:dasan /home/dasan/xhpl
 #su - dasan
 #mpirun  --hostfile hosts  -np 48  ./xhpl    | tee -a hpl-test



[dasan@master:~]$ cat hpl | more
================================================================================
HPLinpack 2.2 -- High-Performance Linpack benchmark -- February 24, 2016
Written by A. Petitet and R. Clint Whaley, Innovative Computing Laboratory, UTK
Modified by Piotr Luszczek, Innovative Computing Laboratory, UTK
Modified by Julien Langou, University of Colorado Denver
================================================================================

An explanation of the input/output parameters follows:
T/V : Wall time / encoded variant.
N : The order of the coefficient matrix A.
NB : The partitioning blocking factor.
P : The number of process rows.
Q : The number of process columns.
Time : Time in seconds to solve the linear system.
Gflops : Rate of execution for solving the linear system.

The following parameter values will be used:

N : 29 30 34 35
NB : 1 2 3 4
PMAP : Row-major process mapping
P : 2 1 4
Q : 2 4 1
PFACT : Left Crout Right
NBMIN : 2 4
NDIV : 2
RFACT : Left Crout Right
BCAST : 1ring
DEPTH : 0
SWAP : Mix (threshold = 64)
L1 : transposed form
U : transposed form
EQUIL : yes
ALIGN : 8 double precision words

--------------------------------------------------------------------------------

- The matrix A is randomly generated for each test.
- The following scaled residual check will be computed:
  ||Ax-b||_oo / ( eps * ( || x ||_oo * || A ||_oo + || b ||_oo ) * N )
- The relative machine precision (eps) is taken to be 1.110223e-16
- Computational tests pass if scaled residuals are less than 16.0


--------------------------------------------------------------------------------
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)= 0.0207165 ...... PASSED
================================================================================
T/V N NB P Q Time  Gflops
--------------------------------------------------------------------------------
WR00R2R4 35 4 4 1 0.00  2.535e-01
HPL_pdgesv() start time Wed Mar 15 00:45:03 2017

HPL_pdgesv() end time Wed Mar 15 00:45:03 2017

--------------------------------------------------------------------------------
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)= 0.0207165 ...... PASSED
================================================================================

Finished 864 tests with the following results:
  864 tests completed and passed residual checks,
  0 tests completed and failed residual checks,
  0 tests skipped because of illegal input values.
--------------------------------------------------------------------------------

End of Tests.
================================================================================
[dasan@master:~]$




71. @@sge  ,  torque   설치  및   사용법 .
