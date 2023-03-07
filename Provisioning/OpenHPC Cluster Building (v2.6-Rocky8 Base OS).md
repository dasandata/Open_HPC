[contents]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-목차
[1]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-1-introduction
[2]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-2-network-and-firewall-setup-to-base-operating-system-bos
[3]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-3-install-openhpc-components
[3.1]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-31-enable-openhpc-repository-for-local-use
[3.3]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-33-add-provisioning-services-on-master-node
[3.4]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-34-add-resource-management-services-on-master-node
[3.5]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-35-optionally-add-infiniband-support-services-on-master-node
[3.7]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-37-complete-basic-warewulf-setup-for-master-node
[3.8]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-37-complete-basic-warewulf-setup-for-master-node
[3.9]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-39-finalizing-provisioning-configuration
[3.10]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-310-boot-compute-nodes
[4]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-4-install-openhpc-development-components
[5]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-5-resource-manager-startup
[6]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-6-slurmdbd-sacctmgr-cgroup
[7]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#-7-gpu-node-provisioning-of-openhpc-cluster
[END]: OpenHPC%20Cluster%20Building%20(v2.6-Rocky8%20Base%20OS).md#end

# Dasandata Standard Recipes of OpenHPC Cluster Building (v2.6-Rocky8 Base OS)[2022.11]

\# 참조 링크 : http://openhpc.community/  
\# Root 로 로그인 하여 설치를 시작 합니다.  
![Cluster Architecture](https://image.slidesharecdn.com/schulz-mug-17-170930151325/95/openhpc-project-overview-and-updates-8-638.jpg?cb=1506784595)

![Dasandata Logo](http://dasandata.co.kr/wp-content/uploads/2019/05/%EB%8B%A4%EC%82%B0%EB%A1%9C%EA%B3%A0_%EC%88%98%EC%A0%951-300x109.jpg)  

## ## 목차  
[1. Introduction ][1]  
[2. Network and Firewall Setup to Base Operating System (BOS) ][2]  
[3. Install OpenHPC Components ][3]   
[3.1. Enable OpenHPC repository for local use][3.1]  
[3.3. Add provisioning services on master node][3.3]  
[3.4. Add resource management services on master node][3.4]  
[3.5. Optionally add InfiniBand support services on master node][3.5]  
[3.7. Complete basic Warewulf setup for master node][3.7]  
[3.8 Define compute image for provisioning][3.8]  
[3.9 Finalizing provisioning configuration][3.9]  
[3.10 Boot compute nodes][3.10]  
[4. Install OpenHPC Development Components][4]     
[5. Resource Manager Startup ][5]  
[6. slurmdbd, sacctmg ][6]    
[7. GPU Provision][7]  
[END][END]  

***

# # [1. Introduction][contents]
안녕하세요?  
다산데이타 입니다.  

저희가 지원해 드리고 있는 HPC Cluster Tool 중 하나인   
OpenHPC Cluster 의 설치 방법 입니다.  

대부분의 내용은 공식 메뉴얼의 순서에 맞추어 작성 하였으며,  
편의상 필요한 부분들을 제외/추가/수정 하였습니다.   

자세한 내용은 공식 Install Recipe 를 참조 하시면 좋습니다 :)  
http://openhpc.community/downloads/  

궁금하신 점이나 오류, 오탈자 등을 발견 하시면 아래 주소로 메일 부탁 드립니다.
mail@dasandata.co.kr  

감사합니다.  

### ### Root 로 로그인하여 진행.

## ## 1.3 Inputs - 변수 정의 및 적용 (파일로 작성)

```bash
cd
pwd

cat << EOF > /usr/local/sbin/dasan_ohpc_variable.sh
#!/bin/bash

# 클러스터 이름.
export CLUSTER_NAME=OpenHPC_Dasandata # 변경 필요

# 노드 배포 이미지 경로 (chroot)
export CHROOT=/opt/ohpc/admin/images/rocky8

# MASTER 의 이름 과 IP.
export MASTER_HOSTNAME=$(hostname -s)
export MASTER_IP=10.1.1.200
export MASTER_PREFIX=24

# 인터페이스 이름.
export EXT_NIC=em2 # 외부망.
export INT_NIC=em1 # 내부망.
export NODE_INT_NIC=eth0  # node 들의 내부망 인터페이스 명.

# end of file.
EOF

cat /usr/local/sbin/dasan_ohpc_variable.sh

```

### ### root 계정에서 항상 사용할 수 있도록 적용.
```bash
echo "source  /usr/local/sbin/dasan_ohpc_variable.sh" >> /root/.bashrc

source  /root/.bashrc

echo $CHROOT

```

***

# # [2. Network and Firewall Setup to Base Operating System (BOS)][contents]

## ## 2.1 외부망 및 내부망 인터페이스 설정.

```bash
ip a    # 인터페이스 목록 확인  
```

## ## 2.2 Master 의 외부/내부 인터페이스 설정내용 확인, 필요한 경우 설정.
```bash
cat /etc/sysconfig/network-scripts/ifcfg-${EXT_NIC}

cat /etc/sysconfig/network-scripts/ifcfg-${INT_NIC}
```

## ## 2.3 방화벽 zone 설정 변경
```bash
firewall-cmd --list-all --zone=public
firewall-cmd --list-all --zone=trusted

firewall-cmd --add-masquerade --zone=public --permanent

firewall-cmd --change-interface=${EXT_NIC}  --zone=public    --permanent
firewall-cmd --change-interface=${INT_NIC}  --zone=trusted   --permanent

firewall-cmd --reload
systemctl restart firewalld

firewall-cmd --list-all --zone=public
firewall-cmd --list-all --zone=trusted
```

## ## 2.4 클러스터 마스터 IP 와 HOSTNAME 을 hosts 에 등록.
```bash
echo "${MASTER_IP}      ${MASTER_HOSTNAME}"  >>  /etc/hosts
cat /etc/hosts
```

***

# # [3. Install OpenHPC Components][contents]
## ## 3.1 Enable OpenHPC repository for local use
```bash
# Check current repolist
yum repolist

# Install to OpenHPC repository.
yum -y install \
http://repos.openhpc.community/OpenHPC/2/EL_8/x86_64/ohpc-release-2-1.el8.x86_64.rpm \
>> ~/dasan_log_ohpc_openhpc_repository.txt 2>&1  

tail ~/dasan_log_ohpc_openhpc_repository.txt

# Check added repolist
yum repolist | grep OpenHPC

# yum enable Powertools
yum -y install dnf-plugins-core
yum config-manager --set-enabled powertools

```

## ## [3.3 Add provisioning services on master node][contents]

### ### Install base meta-packages
```bash
yum -y install ohpc-base ohpc-warewulf squashfs-tools redhat-lsb >>  ~/dasan_log_ohpc_base,warewulf.txt 2>&1
tail ~/dasan_log_ohpc_base,warewulf.txt  
```

### ### Chrony Server 설정
```bash
# chrony를 사용한 시간 설정 방법 (NTP에서 변경됨)
cat /etc/chrony.conf | grep -v "#\|^$"

echo "local stratum 10"     >> /etc/chrony.conf
echo "allow all"            >> /etc/chrony.conf

cat /etc/chrony.conf | grep -v "#\|^$"

systemctl enable chronyd && systemctl restart chronyd

# chrony가 동기화되었는지 확인
chronyc tracking
chronyc sources
chronyc sourcestats

```

## ## [3.4 Add resource management services on master node][contents]
\# **주의!** Resource Manager는 Slurm 으로만 진행 합니다.  

### ### Install slurm server meta-package
```bash
yum -y install ohpc-slurm-server \
  >> ~/dasan_log_ohpc_resourcemanager_slurm.txt 2>&1

tail ~/dasan_log_ohpc_resourcemanager_slurm.txt  

# Use ohpc-provided file for starting SLURM configuration
cp /etc/slurm/slurm.conf.ohpc /etc/slurm/slurm.conf
# Setup default cgroups file
cp /etc/slurm/cgroup.conf.example /etc/slurm/cgroup.conf

cat /etc/slurm/slurm.conf

cat /etc/slurm/cgroup.conf

# Identify resource manager hostname on master host
perl -pi -e "s/SlurmctldHost=\S+/SlurmctldHost=${MASTER_HOSTNAME}/" \
   /etc/slurm/slurm.conf

# Identify resource manager ClusterName
perl -pi -e "s/ClusterName=\S+/ClusterName=${CLUSTER_NAME}/" \
   /etc/slurm/slurm.conf

# 중복된 설정값 2개중 1개 제거
sed -i  '/jobcomp\/none/d'   /etc/slurm/slurm.conf

cat /etc/slurm/slurm.conf

```



## ## [3.5 Optionally add InfiniBand support services on master node][contents]

### ### 3.5.1 Install InfiniBand support on master node

```bash
yum -y groupinstall "InfiniBand Support" >> ~/dasan_log_ohpc_IBSupport.txt 2>&1
tail -1 ~/dasan_log_ohpc_IBSupport.txt

yum -y install opensm libibverbs-utils libpsm2  >> ~/dasan_log_ohpc_IBSupport.txt 2>&1
tail -1 ~/dasan_log_ohpc_IBSupport.txt
```

### ### 3.5.2 Load InfiniBand drivers
```bash
systemctl enable opensm
systemctl start opensm
```

### ### 3.5.3 Copy ib0 template to master for IPoIB(IP Over InfiniBand)
```bash
cp  /opt/ohpc/pub/examples/network/centos/ifcfg-ib0   /etc/sysconfig/network-scripts

```

### ### 3.5.4 Define local IPoIB(IP Over InfiniBand) address and netmask
```bash
sed -i "s/master_ipoib/${sms_ipoib}/"      /etc/sysconfig/network-scripts/ifcfg-ib0
sed -i "s/ipoib_netmask/${ipoib_netmask}/" /etc/sysconfig/network-scripts/ifcfg-ib0

echo  "MTU=4096"  >>  /etc/sysconfig/network-scripts/ifcfg-ib0
```

### ### 3.5.5 configure NetworkManager to *not* override local /etc/resolv.conf
```bash
echo "[main]"   >  /etc/NetworkManager/conf.d/90-dns-none.conf
echo "dns=none" >> /etc/NetworkManager/conf.d/90-dns-none.conf

systemctl restart NetworkManager
```

### ### 3.5.6 Initiate ib0 (InfiniBand Interface 0)
```bash
ifup ib0

ibstat

ibhosts
```

### ### 3.5.7 ib 방화벽 zone 설정 변경
```bash
firewall-cmd --change-interface=ib0  --zone=trusted   --permanent

firewall-cmd --reload && systemctl restart firewalld

firewall-cmd --list-all --zone=trusted

```

## ## [3.7 Complete basic Warewulf setup for master node][contents]

### ### Configure Warewulf provisioning to use desired internal interface
\# 내부망 인터페이스 설정 내용 확인.  
```bash
echo ${INT_NIC}

ifconfig ${INT_NIC}
```

```bash
# warewulf provision.conf 파일의 기본값 확인.  
grep device /etc/warewulf/provision.conf

# 인터페이스 명 변경
sed -i "s/device = eth1/device = ${INT_NIC}/" /etc/warewulf/provision.conf

grep device /etc/warewulf/provision.conf
```

### ### Restart/enable relevant services to support provisioning
```bash
systemctl enable httpd.service
systemctl restart httpd

systemctl enable dhcpd.service

systemctl enable tftp.socket
systemctl start tftp.socket
```

## ## [3.8 Define compute image for provisioning][contents]

### ### Check chroot location.
\# chroot 작업을 하기 전에 항상, ${CHROOT} 변수가 알맞게 선언 되어 있는지 확인하는 것을 권장합니다.
```bash
echo ${CHROOT}
```

### ### 3.8.1 Build initial BOS (Base OS) image
```bash
# chroot 를 생성할 때 참고하는 template file.
cat /usr/libexec/warewulf/wwmkchroot/rocky-8.tmpl

wwmkchroot  -v rocky-8  ${CHROOT} >> ~/dasan_log_ohpc_initial-BaseOS.txt 2>&1
tail ~/dasan_log_ohpc_initial-BaseOS.txt
```

#### #### Build 된 node image 와 master 의 kernel version 비교.

```bash
uname -r

chroot ${CHROOT} uname -r
```

#### #### Build 된 node provision image 의 업데이트
```bash
yum -y --installroot=${CHROOT} update  >> ~/dasan_log_ohpc_update_nodeimage.txt 2>&1
tail ~/dasan_log_ohpc_update_nodeimage.txt

yum -y --installroot ${CHROOT} install epel-release  \
>> ~/dasan_log_ohpc_update_nodeimage.txt 2>&1
tail ~/dasan_log_ohpc_update_nodeimage.txt
```
#### #### CHROOT 에 OpenHPC Repository 추가.
```bash
cp -p /etc/yum.repos.d/OpenHPC*.repo ${CHROOT}/etc/yum.repos.d
```

### ### 3.8.2 Add OpenHPC components
#### #### Install compute node base meta-package.
\# 기본적으로 필요한 패키지를 node image 에 설치 합니다.
```bash
yum -y --installroot=${CHROOT} install \
 ohpc-base-compute kernel kernel-headers kernel-devel kernel-tools parted \
 xfsprogs yum htop ipmitool glibc* perl perl-CPAN perl-CPAN sysstat gcc make \
 xauth firefox squashfs-tools stress podman dmidecode >> ~/dasan_log_ohpc_meta-package.txt 2>&1

tail ~/dasan_log_ohpc_meta-package.txt  
```

#### #### updated to enable DNS resolution.
```bash
cat /etc/resolv.conf
cp -p /etc/resolv.conf  ${CHROOT}/etc/resolv.conf  
```

#### #### slurm-client 설치 등.
```bash
# copy credential files into $CHROOT to ensure consistent uid/gids for slurm/munge at install.
/usr/bin/cp    /etc/passwd /etc/group   $CHROOT/etc

# Add Slurm client support meta-package and enable munge
yum -y --installroot=${CHROOT} install ohpc-slurm-client >> ~/dasan_log_ohpc_slurmclient.txt 2>&1
tail -1 ~/dasan_log_ohpc_slurmclient.txt

chroot ${CHROOT} systemctl enable munge
chroot ${CHROOT} systemctl enable slurmd

# Register Slurm server with computes (using "configless" option)
echo SLURMD_OPTIONS="--conf-server ${MASTER_HOSTNAME}" > $CHROOT/etc/sysconfig/slurmd
cat $CHROOT/etc/sysconfig/slurmd

# Add Network Time Protocol (NTP) support
yum -y --installroot=$CHROOT install chrony

# Identify master host as local NTP server
echo "server ${MASTER_HOSTNAME}" iburst >> $CHROOT/etc/chrony.conf

# Add kernel drivers (matching kernel version on SMS node)
yum -y --installroot=$CHROOT install kernel-`uname -r`

# Include modules user environment
yum -y --installroot=$CHROOT install lmod-ohpc

```

### ### 3.8.3 Customize system configuration

#### #### Initialize warewulf database and ssh_keys
```bash
wwinit database
wwinit ssh_keys
```

#### #### Add NFS client mounts of /home and /opt/ohpc/pub and /{ETC} to base image.

```bash
df -hT | grep -v tmpfs
mkdir /opt/intel

cat  ${CHROOT}/etc/fstab

echo "${MASTER_HOSTNAME}:/home         /home         nfs nfsvers=3,nodev,nosuid 0 0" >> ${CHROOT}/etc/fstab
echo "${MASTER_HOSTNAME}:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3,nodev 0 0"        >> ${CHROOT}/etc/fstab
echo "${MASTER_HOSTNAME}:/opt/intel    /opt/intel    nfs nfsvers=3,nodev 0 0"        >> ${CHROOT}/etc/fstab

# 아래는 data 디렉토리를 별도로 구성하는 경우에만.  
#echo "${MASTER_HOSTNAME}:/data         /data         nfs nfsvers=3,nodev 0 0">> ${CHROOT}/etc/fstab  
#mkdir ${CHROOT}/data

# 아래는 Dell 서버의 경우 (racadm을 노드에서 사용)  
#echo "${MASTER_HOSTNAME}:/opt/dell     /opt/dell     nfs nfsvers=3,nodev 0 0" >> ${CHROOT}/etc/fstab  
#mkdir ${CHROOT}/opt/dell

cat  ${CHROOT}/etc/fstab  
```


#### #### Export /home and OpenHPC public packages from master server.

```bash
cat /etc/exports

echo "/home         10.1.1.0/24(rw,no_subtree_check,no_root_squash)"  >> /etc/exports
echo "/opt/ohpc/pub 10.1.1.0/24(ro,no_subtree_check)"                 >> /etc/exports
echo "/opt/intel    10.1.1.0/24(ro,no_subtree_check)"                 >> /etc/exports

# 아래는 data 디렉토리를 별도로 구성하는 경우에만.  
#echo "/data         10.1.1.0/24(rw,no_subtree_check,no_root_squash)" >> /etc/exports


# 아래는 dell 서버인 경우에만 (racadm을 노드에서 사용)
#echo "/opt/dell     10.1.1.0/24(ro,no_subtree_check)"                >> /etc/exports

cat /etc/exports

systemctl enable  nfs-server && systemctl restart nfs-server && exportfs
```

### ### 3.8.4 Additional Customization (optional)

#### #### 3.8.4.1 Enable InfiniBand drivers
```bash
# Add IB support and enable
yum -y --installroot=$CHROOT groupinstall "InfiniBand Support" >> ~/dasan_log_ohpc_nodeIBSupport.txt 2>&1
tail  -1 ~/dasan_log_ohpc_nodeIBSupport.txt

yum -y --installroot=${CHROOT} install libibverbs-utils libpsm2  >> ~/dasan_log_ohpc_nodeIBSupport.txt 2>&1
tail  -1 ~/dasan_log_ohpc_nodeIBSupport.txt
```
##### ##### Import File for IPoIB Interfaces
```bash
wwsh    file import  /opt/ohpc/pub/examples/network/centos/ifcfg-ib0.ww
wwsh -y file set ifcfg-ib0.ww  --path=/etc/sysconfig/network-scripts/ifcfg-ib0
```

#### #### 3.8.4.3 Increase locked memory limits

##### ###### Update memlock settings on master
```bash
tail /etc/security/limits.conf

perl -pi -e 's/# End of file/\* soft memlock unlimited\n$&/s' /etc/security/limits.conf
perl -pi -e 's/# End of file/\* hard memlock unlimited\n$&/s' /etc/security/limits.conf

tail /etc/security/limits.conf
```
##### ##### Update memlock settings on compute nodes  
```bash
tail ${CHROOT}/etc/security/limits.conf

perl -pi -e 's/# End of file/\* soft memlock unlimited\n$&/s' ${CHROOT}/etc/security/limits.conf
perl -pi -e 's/# End of file/\* hard memlock unlimited\n$&/s' ${CHROOT}/etc/security/limits.conf

tail ${CHROOT}/etc/security/limits.conf
```

#### #### 3.8.4.4 Enable ssh control via resource manager (only Slurm)

An additional optional customization that is recommended is to restrict ssh access on    
compute nodes to only allow access by users who have an active job associated with the node.   
This can be enabled via the use of a pluggable authentication module (PAM)   
provided as part of the Slurm package installs.  

To enable this feature within the compute image, issue the following:  

```bash
echo "account required pam_slurm.so" >> $CHROOT/etc/pam.d/sshd
```

#### #### 3.8.4.5 Add BeeGFS

```bash
# Add BeeGFS client software and dependencies to master host
wget -P /etc/yum.repos.d https://www.beegfs.io/release/beegfs_7.2.1/dists/beegfs-rhel8.repo

yum -y install kernel-devel gcc elfutils-libelf-devel
yum -y install beegfs-client beegfs-helperd beegfs-utils

# Enable OFED support in client
perl -pi -e "s/^buildArgs=-j8/buildArgs=-j8 BEEGFS_OPENTK_IBVERBS=1/" \
/etc/beegfs/beegfs-client-autobuild.conf

# Define client's management host
/opt/beegfs/sbin/beegfs-setup-client -m ${sysmgmtd_host}
systemctl start beegfs-helperd

# Build kernel and mount file system
systemctl start beegfs-client
```

#### #### 3.8.4.6 Add Lustre client 

```bash
# Add Lustre client software to master host
yum -y install lustre-client-ohpc

# Add Lustre client software in compute image
yum -y --installroot=$CHROOT install lustre-client-ohpc

```

```bash
# Include mount point and file system mount in compute image
mkdir $CHROOT/lustre

echo "10.xx.xx.x:/lustre  /lustre  lustre  defaults,localflock,noauto,x-systemd.automount 0 0" \
>> $CHROOT/etc/fstab
```

```bash
# Make file of lustre.conf (lnet config)
echo "options lnet networks=o2ib(ib0)" >> /etc/modprobe.d/lustre.conf
echo "options lnet networks=o2ib(ib0)" >> $CHROOT/etc/modprobe.d/lustre.conf
```

```bash
# Lustre Mount test.
mkdir /lustre

mount -t lustre -o localflock 10.xx.xx.x:/lustre /lustre
```


#### #### 3.8.4.7 Enable forwarding of system logs
```bash
# Configure SMS to receive messages and reload rsyslog configuration
echo 'module(load="imudp")'           >> /etc/rsyslog.d/ohpc.conf
echo 'input(type="imudp" port="514")' >> /etc/rsyslog.d/ohpc.conf

cat /etc/rsyslog.d/ohpc.conf

systemctl restart rsyslog

# Define compute node forwarding destination
echo "*.* @${MASTER_HOSTNAME}:514"                    >> $CHROOT/etc/rsyslog.conf
echo "Target=\"${MASTER_HOSTNAME}\" Protocol=\"udp\"" >> $CHROOT/etc/rsyslog.conf

# Disable most local logging on computes. Emergency and boot logs will remain on the compute nodes
perl -pi -e "s/^\*\.info/\\#\*\.info/" $CHROOT/etc/rsyslog.conf
perl -pi -e "s/^authpriv/\\#authpriv/" $CHROOT/etc/rsyslog.conf
perl -pi -e "s/^mail/\\#mail/"         $CHROOT/etc/rsyslog.conf
perl -pi -e "s/^cron/\\#cron/"         $CHROOT/etc/rsyslog.conf
perl -pi -e "s/^uucp/\\#uucp/"         $CHROOT/etc/rsyslog.conf

```


### ### 3.8.5 Import files
The Warewulf system includes functionality to import arbitrary files from the provisioning server for distribution to managed hosts. This is one way to distribute user credentials to compute nodes.  
To import local file-based credentials, issue the following:  

#### #### Default files
```bash
wwsh file list

wwsh file import /etc/passwd
wwsh file import /etc/group
wwsh file import /etc/shadow
wwsh file import /etc/munge/munge.key

wwsh file list
```

## ## [3.9 Finalizing provisioning configuration][contents]


### ### 3.8.0 /etc/warewulf/vnfs.conf 수정.

```bash
cp  /etc/warewulf/vnfs.conf{,.org}  # conf file backup.

cat /etc/warewulf/vnfs.conf  | grep -v "^$\|^#"

cat /etc/warewulf/vnfs.conf  | grep -v "^$\|^#" | wc -l
# -> 12
```
***
```bash
sed -i "s#hybridize += /usr/include#\#hybridize += /usr/include#"           /etc/warewulf/vnfs.conf
sed -i "s#hybridize += /usr/share/locale#\#hybridize += /usr/share/locale#" /etc/warewulf/vnfs.conf
sed -i "s#exclude += /usr/src#\#exclude += /usr/src#"                       /etc/warewulf/vnfs.conf

cat /etc/warewulf/vnfs.conf  | grep -v "^$\|^#"

cat /etc/warewulf/vnfs.conf  | grep -v "^$\|^#" | wc -l
# -> 9

# Make wareulf log forder 
mkdir -p ${CHROOT}/var/log/warewulf/provision

# ADD wwsh file resync command in crontab
cat /etc/crontab

cat << EOF >> /etc/crontab

# sync warewulf files at every 5 min
0,4,9,14,19,24,29,34,39,44,49,54   * * * *   root   /bin/wwsh file resync
EOF

cat /etc/crontab
```

### ### 3.9.1 Assemble bootstrap image

```bash
# Include drivers from kernel updates; needed if enabling additional kernel modules on computes

cat  /etc/warewulf/bootstrap.conf

cat << EOF >> /etc/warewulf/bootstrap.conf
# Dasandata additions
drivers  += updates/kernel/
modprobe += ahci, nvme, e1000e

EOF

tail  /etc/warewulf/bootstrap.conf

# Build bootstrap image & check bootstrap list
wwsh bootstrap list

wwbootstrap  `uname -r`

wwsh bootstrap list
```


### ### 3.9.2 Assemble Virtual Node File System (VNFS) image

```bash
wwsh vnfs list

echo ${CHROOT}

wwvnfs --chroot ${CHROOT}
# or wwvnfs --chroot /opt/ohpc/admin/images/rocky8

wwsh vnfs list
```

### ### 3.9.3 Register nodes for provisioning

#### #### Set provisioning interface as the default networking device
```bash
echo "GATEWAYDEV=${NODE_INT_NIC}" > /etc/network.wwsh
wwsh -y file import /etc/network.wwsh --name network
wwsh -y file set network --path /etc/sysconfig/network --mode=0644 --uid=0
```

#### #### Add new nodes to Warewulf data store
```bash
wwsh node list

wwsh -y node new node01

wwsh -y node set node01 --netdev eth0 --netmask=255.255.255.0 --gateway ${MASTER_IP} \
 --ipaddr=10.1.1.1 --hwaddr=aa:bb:cc:dd:ee:ff

wwsh node list
```

#### #### Define provisioning image for hosts
```bash
wwsh provision list

wwsh -y provision set node01 --vnfs=rocky8  --bootstrap=`uname -r ` \
--files=dynamic_hosts,passwd,group,shadow,network,munge.key

wwsh provision list
```

#### #### Restart dhcp / update PXE

```bash
systemctl restart dhcpd 
wwsh pxe update
```

#### #### define IPoIB network settings (if planning to mount NFS by IPoIB)
```bash
wwsh -y node set node01 -D ib0 --ipaddr=172.1.1.1 --netmask=255.255.255.0

wwsh -y provision set node01   --fileadd=ifcfg-ib0.ww
```

### ### 3.9.5 Optionally configure stateful provisioning

#### #### Add GRUB2 bootloader and re-assemble VNFS image
```bash
yum -y --installroot=${CHROOT} install  grub2 grub2-efi grub2-efi-modules
wwvnfs --chroot ${CHROOT}
```

#### #### Copy Filesystem cmds files
```bash
ll  /etc/warewulf/filesystem/examples/

cat /etc/warewulf/filesystem/examples/gpt_example.cmds

# dasandata custom cmds.
cd  /root/
git clone https://github.com/dasandata/Open_HPC
cp  /root/Open_HPC/Provisioning/*.cmds   /etc/warewulf/filesystem/
ll  /etc/warewulf/filesystem/
```

#### #### In GPT, Add GRUB2 bootloader for sda
```bash
wwsh -y provision set --filesystem=gpt_sda  node01
wwsh -y provision set --bootloader=sda      node01
```

#### #### In UEFI, Add GRUB2 bootloader for sda
```bash
wwsh -y provision set --filesystem=efi_sda  node01
wwsh -y provision set --bootloader=sda      node01
```

#### #### In UEFI, Add GRUB2 bootloader for NVME
```bash
wwsh -y provision set --filesystem=efi_nvme  node01
wwsh -y provision set --bootloader=nvme0n1   node01
```

#### #### Configure local boot (after successful provisioning)
```bash
wwsh provision set --bootlocal=normal  node01
```

#### #### Configure PXE boot (Disk ReFormat)
```bash
wwsh -y provision set --bootlocal=FALSE
wwsh provision print  | grep "BOOTLOCAL"
```

#### #### Remove Stateful config.
```bash
wwsh object modify -s FS=           -t node   node01
wwsh object modify -s BOOTLOADER=   -t node   node01
wwsh object modify -s BOOTLOCAL=    -t node   node01
```

#### #### stateful 로 전환할 경우, 원래의 네트워크 디바이스 이름으로 ifcfg 가 생성되도록 devname 을 변경.
```bash
wwsh node set  node01   --netdev eth0  --netrename  enp175s0f0
```

#### #### stateful 로 전환 후 외부 네트워크 접근을 허용시 필요한 ifcfg file 생성 및 import.
```bash
# eno1 ifcfg file add. (for Access from External Network)
cat << EOF > /opt/ohpc/pub/examples/network/centos/ifcfg-eno1.ww
DEVICE=eno1
BOOTPROTO=static
IPADDR=%{NETDEVS::eno1::IPADDR}
NETMASK=%{NETDEVS::eno1::NETMASK}
GATEWAY=%{NETDEVS::eno1::GATEWAY}
HWADDR=%{NETDEVS::eno1::HWADDR}
ONBOOT=yes
NM_CONTROLLED=yes
DEVTIMEOUT=5
DEFROUTE=yes
EOF

# file import
wwsh -y file  import             /opt/ohpc/pub/examples/network/centos/ifcfg-eno1.ww
wwsh -y file  set ifcfg-eno1.ww  --path=/etc/sysconfig/network-scripts/ifcfg-eno1

# provision set
wwsh provision set  node01  --fileadd=ifcfg-eno1.ww
wwsh node      set  node01  --netdev=eno1    --ipaddr=xx.xx.xx.x  --netmask=  --gateway=  --hwaddr=  

# Modify default gateway file

cat /etc/network.wwsh

```

#### #### node 에 root 계정이 password로 접근할 수 없도록 sshd 설정을 변경.
```bash
wwsh vnfs list
export CHROOT=/opt/ohpc/admin/images/rocky8

grep   PermitRootLogin  ${CHROOT}/etc/ssh/sshd_config

sed -i 's/PermitRootLogin yes/PermitRootLogin without-password/'  ${CHROOT}/etc/ssh/sshd_config
wwvnfs --chroot  ${CHROOT}
```

#### #### 외부 ip 접근이 허용된 장비를 로그인 노드로 운영할 경우, pam.d 를 일반 노드와 다르게 적용.
```bash
diff    /etc/pam.d/sshd   ${CHROOT}/etc/pam.d/sshd 
# 17a18
# > account required pam_slurm.so

wwsh file import    /etc/pam.d/sshd  # master 와 동일한 pam.d 를 적용하기 위함.
wwsh provision set  login-node  --fileadd=sshd
```

## ## [3.10 Boot compute nodes][contents]
### ### 노드를 부팅 한 후 o/s 가 설치 되는지 확인 하고 새 노드에 접속해 봅니다.

```bash
ping -c 4 node01

ssh node01

df -hT | grep -v tmpfs
```

***

### ### Command List of Checking Warewulf configuration
```bash
wwsh  file list

wwsh  bootstrap list

wwsh  vnfs list

wwsh  node list

wwsh  node print

wwsh  object  print  -p :all
```

***

# # [4. Install OpenHPC Development Components][contents]

## ## 4.1 Development Tools

### ### Install autotools meta-package (Default)
```bash
yum -y install  ohpc-autotools EasyBuild-ohpc hwloc-ohpc spack-ohpc valgrind-ohpc \
>> ~/dasan_log_ohpc_autotools,meta-package.txt 2>&1
tail -1 ~/dasan_log_ohpc_autotools,meta-package.txt
```

## ## 4.2 Compilers
```bash
yum -y install  gnu12-compilers-ohpc gnu9-compilers-ohpc >> ~/dasan_log_ohpc_Compilers.txt 2>&1
tail -1 ~/dasan_log_ohpc_Compilers.txt
```

## ## 4.3 MPI Stacks 
```bash
yum -y install  openmpi4-gnu12-ohpc mpich-ofi-gnu12-ohpc mpich-ucx-gnu12-ohpc \
 mvapich2-gnu12-ohpc >> ~/dasan_log_ohpc_MPI-Stacks.txt 2>&1
tail -1 ~/dasan_log_ohpc_MPI-Stacks.txt
```

## ## 4.4 Performance Tools
### ### Install perf-tools meta-package
```bash
yum -y install  ohpc-gnu12-perf-tools  ohpc-gnu12-geopm \
 >> ~/dasan_log_ohpc_perf-tools.txt 2>&1
tail -1 ~/dasan_log_ohpc_perf-tools.txt
```

## ## 4.5 Setup default development environment

```bash
yum -y install   lmod-defaults-gnu12-openmpi4-ohpc  >> ~/dasan_log_ohpc_lmod.txt 2>&1
tail -1 ~/dasan_log_ohpc_lmod.txt
```

## ## 4.6 3rd Party Libraries and Tools
### ### Install 3rd party libraries/tools meta-packages built with GNU toolchain
```bash
yum -y install ohpc-gnu12-serial-libs ohpc-gnu12-io-libs ohpc-gnu12-python-libs \
 ohpc-gnu12-runtimes >> ~/dasan_log_ohpc_3rdPartyLib.txt 2>&1
tail -1 ~/dasan_log_ohpc_3rdPartyLib.txt
```

### ### Install parallel lib meta-packages for all available MPI toolchains
```bash
yum -y install  ohpc-gnu12-mpich-parallel-libs ohpc-gnu12-openmpi4-parallel-libs \
  >> ~/dasan_log_ohpc_parallellib.txt 2>&1
tail -1 ~/dasan_log_ohpc_parallellib.txt
```

## ## 4.7 Optional Development Tool Builds

### ### Enable Intel oneAPI and install OpenHPC compatibility packages
```bash
yum -y install intel-oneapi-toolkit-release-ohpc   >> ~/dasan_log_ohpc_inteloneapi.txt 2>&1

rpm --import https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB

yum -y install intel-compilers-devel-ohpc intel-mpi-devel-ohpc \
  >> ~/dasan_log_ohpc_inteloneapi.txt 2>&1

tail -1 ~/dasan_log_ohpc_inteloneapi.txt
```

### ### Install 3rd party libraries/tools meta-packages built with Intel toolchain
```bash 
yum -y install  ohpc-intel-serial-libs ohpc-intel-geopm ohpc-intel-io-libs \
ohpc-intel-perf-tools ohpc-intel-python3-libs ohpc-intel-mpich-parallel-libs \
ohpc-intel-mvapich2-parallel-libs ohpc-intel-openmpi4-parallel-libs \
ohpc-intel-impi-parallel-libs   >> ~/dasan_log_ohpc_inteloneapi_3rdparty.txt 2>&1

tail -1  ~/dasan_log_ohpc_inteloneapi_3rdparty.txt
```

### ### Fast way ;)  (use script)
```bash
cd ~
git clone https://github.com/dasandata/Open_HPC
cat ./Open_HPC/Provisioning/4_Install_OpenHPC_Development_Components_2.6.sh

bash ./Open_HPC/Provisioning/4_Install_OpenHPC_Development_Components_2.6.sh
```
***

# # [5. Resource Manager Startup][contents]

## slurm.conf 의 NodeName 및  PartitionName 정보 수정
```bash

sed -i 's/Oversubscribe=EXCLUSIVE/Oversubscribe=NO/' /etc/slurm/slurm.conf 

vi /etc/slurm/slurm.conf

cat /etc/slurm/slurm.conf
```


## daemon start
```bash
systemctl enable munge
systemctl enable slurmctld

systemctl start munge
systemctl start slurmctld

systemctl status munge
systemctl status slurmctld

pdsh -w node[01-02]  'systemctl restart slurmd'
```

### ### sinfo
```bash
sinfo --long

sinfo -R
```

\# node 의 STATE 가 drain 이나 down 상태 일 경우   
\# scontrol 명령을 사용해 node 의 상태를 resume 로 변경 합니다.
```bash
scontrol  update  nodename=node01  state=resume

sinfo --long
```

### ### slurm alias 적용.
```bash
cat << EOF > /etc/profile.d/slurm.alias.sh
alias sinfolong='sinfo    -o "%16P %14C %6t %15N %5D %15G %11l %14f "     '
alias squeuelong='squeue  -o "%6i  %12j %9T %15u %8g %10P %8q %4D %20R %4C %13b %11l %11L %p"'
EOF

cat  /etc/profile.d/slurm.alias.sh

wwsh file list
wwsh file import  /etc/profile.d/slurm.alias.sh
wwsh file list

wwsh provision print    node01  | grep FILES
wwsh provision set  -y  node01 --fileadd=slurm.alias.sh
wwsh provision print    node01  | grep FILES

pdsh -w node01  'rm -rf /tmp/.wwgetfile*  &&  /warewulf/bin/wwgetfiles'
```


### ### 5.1 Run a Test Job

#### #### job test 사용자 추가
```bash
adduser testuser
passwd  testuser
```
#### #### 계정 정보 동기화.
```bash
wwsh file list
wwsh file resync

pdsh -w node01 uptime

pdsh -w node01 'rm -rf /tmp/.wwgetfile*  &&  /warewulf/bin/wwgetfiles'
pdsh -w node01 systemctl status slurmd | grep active

# node가 여러대 인 경우
pdsh -w node[01-04] uptime
pdsh -w node[01-04] 'rm -rf /tmp/.wwgetfile*  &&  /warewulf/bin/wwgetfiles'
```

### ### 5.2 Interactive execution
#### #### Switch to normal user
```bash
su - testuser    
```

#### #### Compile MPI "hello world" example
```bash
cd
pwd

mpicc -O3 /opt/ohpc/pub/examples/mpi/hello.c

ls
```

#### #### [Submit interactive job request and use prun to launch executable][contents]
```bash
srun --nodes 1 --ntasks-per-node 2 --pty /bin/bash  

squeue

prun  a.out

squeue

exit

squeue

# mpi test.

srun   --nodes 2 --ntasks-per-node 2 --pty /bin/bash  # 이건 실행이 안됩니다. (아직 왜 안되는지 모름)

salloc --nodes=1 --ntasks-per-node=4  prun  a.out

salloc --nodes=2 --ntasks-per-node=2  prun  a.out

# sbatch mpitest
cat << EOF > mpitest.sh
#!/bin/bash

prun a.out

EOF

cat mpitest.sh

sbatch --nodes=2 --ntasks-per-node=2   mpitest.sh
sbatch --nodes=2 --ntasks-per-node=4   mpitest.sh

squeue
cat slurm-<jobID>.out
```

# # [6. slurmdbd, sacctmgr, cgroup][contents]

```bash
systemctl status slurmdbd

```

## ## make slurmdbd.conf
```bash
cat << EOF > /etc/slurm/slurmdbd.conf
ArchiveEvents=yes
ArchiveJobs=yes
ArchiveSteps=no
ArchiveSuspend=no 
AuthType=auth/munge
DbdAddr=localhost
DbdHost=localhost
SlurmUser=slurm
DebugLevel=4
LogFile=/var/log/slurmdbd.log
PidFile=/var/run/slurmdbd.pid
PurgeEventAfter=1month 
PurgeJobAfter=12month 
PurgeResvAfter=1month 
PurgeStepAfter=1month 
PurgeSuspendAfter=1month 
TrackWCKey=no
StorageType=accounting_storage/mysql
StoragePass=slurmdbpass
StorageUser=slurm
StorageLoc=slurm_acct_db
EOF

cat /etc/slurm/slurmdbd.conf

chmod 600     /etc/slurm/slurmdbd.conf
chown slurm.  /etc/slurm/slurmdbd.conf

```

## ## mysql setup
```bash
mysql

 SHOW VARIABLES LIKE 'innodb_buffer_pool_size';

 exit

cat -n /etc/my.cnf | grep includedir

export INNODB_SIZE=600M

cat << EOF > /etc/my.cnf.d/innodb.cnf
[mysqld]
innodb_buffer_pool_size=${INNODB_SIZE}
innodb_log_file_size=64M
innodb_lock_wait_timeout=900
EOF

cat /etc/my.cnf.d/innodb.cnf

mv /var/lib/mysql/ib_logfile* /tmp/

systemctl  restart   mariadb

mysql

 SHOW VARIABLES LIKE 'innodb_buffer_pool_size';

 exit

```

```bash
firewall-cmd --add-port=6819/tcp  --permanent  ## slurmdbd  port
firewall-cmd --add-port=3306/tcp  --permanent  ## mysql  port
firewall-cmd  --reload
```

```bash
mysql

 create user 'slurm'@'localhost' identified by 'slurmdbpass';
 grant all on slurm_acct_db.* TO 'slurm'@'localhost';
 SHOW VARIABLES LIKE 'have_innodb';
 create database slurm_acct_db;

 exit
```

```bash
systemctl enable  slurmdbd
systemctl restart slurmdbd

mysql -u  slurm   -p    slurm_acct_db
# password => slurmdbpass

 SHOW VARIABLES LIKE 'have_innodb';
 select * from acct_table;

 exit
```

```bash
grep AccountingStorageType  /etc/slurm/slurm.conf

sed -i 's#accounting_storage/none#accounting_storage/slurmdbd#' /etc/slurm/slurm.conf

grep AccountingStorageType  /etc/slurm/slurm.conf

systemctl restart slurmctld  
```

```bash
sacctmgr list cluster

sacct
```
\# job을 실행한 후 sacct 를 실행 했을 때 과거 작업 목록이 표시 되어야 합니다. 

## ## Slurm Database Backup & Restore
\# Backup
```bash
mysqldump   slurm_acct_db > backup_slurm_acct_db.sql
```

\# Restore
```bash
mysql       slurm_acct_db < backup_slurm_acct_db.sql
```

***

## ## Re make cgroup.conf

```bash
cat << EOF > /etc/slurm/cgroup.conf
###
#
# Slurm cgroup support configuration file
#
# See man slurm.conf and man cgroup.conf for further
# information on cgroup configuration parameters
#--
CgroupAutomount=yes

ConstrainCores=yes
ConstrainRAMSpace=no
ConstrainDevices=yes
EOF

cat /etc/slurm/cgroup.conf

```

```bash 
###
cat /etc/slurm/slurm.conf | grep JobAcctGatherType

sed -i 's#jobacct_gather/none#jobacct_gather/cgroup#'  /etc/slurm/slurm.conf

cat /etc/slurm/slurm.conf | grep JobAcctGatherType

###
cat /etc/slurm/slurm.conf | grep TaskPlugin=

sed -i 's#TaskPlugin=task/affinity#TaskPlugin=task/affinity,task/cgroup#' /etc/slurm/slurm.conf

cat /etc/slurm/slurm.conf | grep TaskPlugin=

###
cat /etc/slurm/slurm.conf | grep  ProctrackType

```

```bash
systemctl restart slurmctld 

pdsh -w node[01-02]   systemctl restart slurmd
```

```bash
su - testuser

srun --nodes=1 --cpus-per-task=2   --pty /bin/bash

stress -c 4

```


# # [7. GPU Node Provisioning of OpenHPC Cluster][contents]

## ## Nvidia 저장소 생성 (Cuda,cudnn 설치를 위해)
```bash

dnf config-manager --add-repo \
https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo

dnf config-manager --installroot=$CHROOT --add-repo \
https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo

```

## ## nvidia X11 관련 lib 설치
```bash
yum -y install libXi-devel mesa-libGLU-devel libXmu-devel libX11-devel freeglut-devel libXm* openmotif*

yum -y install --installroot=$CHROOT \
 libXi-devel mesa-libGLU-devel libXmu-devel libX11-devel freeglut-devel libXm* openmotif*
```

## ## Install NVIDIA Driver to VNFS
```bash
# Mount /dev on CHROOT
mount -o bind /dev  ${CHROOT}/dev
mount | grep ${CHROOT}

# Install gcc, make to VNFS
yum -y install --installroot ${CHROOT} gcc make \
>> dasan_log_ohpc_nvidia-driver-latest-vnfs.txt 2>&1
tail dasan_log_ohpc_nvidia-driver-latest-vnfs.txt

# Install nvidia-driver node VNFS
yum -y install --installroot ${CHROOT} nvidia-driver nvidia-driver-cuda nvidia-driver-devel nvidia-driver-NVML \
>> dasan_log_ohpc_nvidia-driver-latest-vnfs.txt 2>&1
tail dasan_log_ohpc_nvidia-driver-latest-vnfs.txt

# umount /dev on CHROOT
umount  ${CHROOT}/dev
mount | grep ${CHROOT}

# Check to nvidia.ko module file maked to CHROOT
ll  ${CHROOT}/lib/modules/$(uname -r)/extra/drivers/video/nvidia/nvidia.ko

# Enable nvidia persiste mode
chroot  ${CHROOT}  systemctl enable nvidia-persistenced

```

## ## nvlink GPU 필수 package
```bash
yum -y install --installroot ${CHROOT}   nvidia-fabric-manager cuda-drivers-fabricmanager nvidia-fabric-manager-devel   

```

## ## gpustat (python3) install to VNFS
```bash
yum -y  install --installroot=${CHROOT}  python3-devel python3-pip ncurses-devel  

chroot  ${CHROOT}

pip3 list
pip3 install --upgrade gpustat
pip3 -V
pip3 list | grep -i gpustat

exit

wwvnfs --chroot  ${CHROOT}

# gpustat  --force-color 
```
```


## ## CUDA 설치 (master only)
```bash
yum -y install cuda-11-8 \
>> dasan_log_ohpc_cuda-master.txt 2>&1
tail dasan_log_ohpc_cuda-master.txt

ls -l /usr/local | grep cuda
```

```bash
mkdir /opt/ohpc/pub/apps/cuda/

for VER in  11.8  
  do echo $VER
  mv /usr/local/cuda-$VER  /opt/ohpc/pub/apps/cuda/$VER
  done

ll /usr/local/ | grep cuda

ll /opt/ohpc/pub/apps/cuda/

# Local에 있는 심볼릭 링크 제거
rm -f /usr/local/cuda
rm -f /usr/local/cuda-11
```

## ## CUDNN to MASTER
```bash
mkdir /root/cudnn/
cd    /root/cudnn/

# copy cudnn from file server.
I="cudnn-linux-x86_64-8.6.0.163_cuda11-archive.tar"

mount -t nfs  192.168.0.5:/file   /mnt
cp  /mnt/12_NVIDIA_CUDNN/1_LINUX/$I  /root/cudnn/

umount /mnt

# 압축 해제 후 /opt/ohpc/pub/apps/cuda 아래로 이동.

VER=11.8
echo "CUDA-$VER"

tar -xvf $I

chmod a+r  cudnn-linux-x86_64-8.6.0.163_cuda11-archive/include/*
chmod a+r  cudnn-linux-x86_64-8.6.0.163_cuda11-archive/lib/*

mv  cudnn-linux-x86_64-8.6.0.163_cuda11-archive/include/cudnn.h  /opt/ohpc/pub/apps/cuda/$VER/include/
mv  cudnn-linux-x86_64-8.6.0.163_cuda11-archive/lib/libcudnn*    /opt/ohpc/pub/apps/cuda/$VER/lib64/

rm -rf   cuda/

cd ~

```
## ## Add  Cuda Module
```bash
cd /root/
git clone https://github.com/dasandata/Open_HPC

cd /root/Open_HPC/
git pull

# Add CUDA Module File by each version
mkdir -p /opt/ohpc/pub/modulefiles/cuda
MODULES_DIR="/opt/ohpc/pub/modulefiles"

for CUDA_VERSION in 11.8
  do cp -a /root/Open_HPC/Module_Template/cuda.txt ${MODULES_DIR}/cuda/${CUDA_VERSION}
  sed -i "s/{version}/${CUDA_VERSION}/" ${MODULES_DIR}/cuda/${CUDA_VERSION}
done

ll /opt/ohpc/pub/modulefiles/cuda/

```

```bash
rm -rf  ~/.lmod.d/.cache

module av | grep cuda

ml load cuda
nvcc -V

```

## ## Slurm gres.conf
```bash
cat << EOF > /etc/slurm/gres.conf
# This file location is /etc/slurm/gres.conf
# for Four GPU Set

Nodename=gpu01  Name=gpu  Type=GTX1080Ti  File=/dev/nvidia[0-3]

# End of File.
EOF

cat /etc/slurm/gres.conf

vi  /etc/slurm/gres.conf

# slurm.conf 수정!

echo "GresTypes=gpu" >> /etc/slurm/slurm.conf 
echo "NodeName=gpu01        Sockets=1 CoresPerSocket=4 ThreadsPerCore=1 State=UNKNOWN Gres=gpu:GTX1080Ti:1" >>  /etc/slurm/slurm.conf 
echo "PartitionName=gpu    Nodes=gpu01                   MaxTime=6-24:00:00 State=UP Oversubscribe=NO"      >>  /etc/slurm/slurm.conf 

vi /etc/slurm/slurm.conf  # Gres 부분 설정 변경  
```

```bash
systemctl  restart  slurmctld 

scontrol  update  nodename=node01 state=resume

sinfo

su - sonic

srun  --partition gpu --gres=gpu:1 --pty /bin/bash

echo $CUDA_VISIBLE_DEVICES

nvidia-smi

sinfo

squeue
```



***

# [END.][contents]
