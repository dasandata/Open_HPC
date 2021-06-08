[contents]: https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.9%20Base%20OS).md#-%EB%AA%A9%EC%B0%A8  
[1]: https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.9%20Base%20OS).md#-1-introduction
[2]: https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.9%20Base%20OS).md#-2-network-and-firewall-setup-to-base-operating-system-bos
[3]: https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.9%20Base%20OS).md#-3-install-openhpc-components
[3-4-A]: https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.9%20Base%20OS).md#-34-a-slurm-resource-management-services-install
[3-4-B]: https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.9%20Base%20OS).md#-34-b-pbs-pro-resource-management-services-install
[3-5]: https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.9%20Base%20OS).md#-35-optionally-add-infiniband-support-services-on-master-node
[4]: https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.9%20Base%20OS).md#-4-install-openhpc-development-components
[5]: https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.9%20Base%20OS).md#-5-resource-manager-startup
[5-A]: https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.9%20Base%20OS).md#-5-a-start-slurm-controller-and-munge-on-master-host
[5-B]: https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.9%20Base%20OS).md#-5-b-start-pbspro-daemons-on-master-host
[6]: https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.9%20Base%20OS).md#-6-run-a-test-job
[6-A]: https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.9%20Base%20OS).md#-6-a-slurm-submit-interactive-job-request-and-use-prun-to-launch-executable
[6-B]: https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.9%20Base%20OS).md#-6-b-pbs-pro-submit-interactive-job-request-and-use-prun-to-launch-executabl
[END]: https://github.com/dasandata/Open_HPC/blob/master/Provisioning/OpenHPC%20Cluster%20Building%20(v1.3.9-CentOS7.9%20Base%20OS).md#end


# Dasandata Standard Recipes of OpenHPC Cluster Building (v1.3.9-centos7.9 Base OS)[2021.06]

\# 참조 링크 : http://openhpc.community/  
\# Root 로 로그인 하여 설치를 시작 합니다.  
![Cluster Architecture](https://image.slidesharecdn.com/schulz-mug-17-170930151325/95/openhpc-project-overview-and-updates-8-638.jpg?cb=1506784595)

![Dasandata Logo](http://dasandata.co.kr/wp-content/uploads/2019/05/%EB%8B%A4%EC%82%B0%EB%A1%9C%EA%B3%A0_%EC%88%98%EC%A0%951-300x109.jpg)  

## ## 목차  
[1. Introduction ][1]  
[2. Network and Firewall Setup to Base Operating System (BOS) ][2]  
[3. Install OpenHPC Components ][3]  
[3-4. A (Slurm) Resource Management Services Install.][3-4-A]  
[3-4. B (PBS Pro) Resource Management Services Install][3-4-B]  
[3-5 Optionally add InfiniBand support services on master node][3-5]  
[4. Install OpenHPC Development Components][4]   
[5. Resource Manager Startup ][5]  
[5-A. Start slurm controller and munge on master host][5-A]  
[5-B. Start pbspro daemons on master host][5-B]  
[6. Run a Test Job ][6]  
[6-A. Slurm Submit interactive job request and use prun to launch executable][6-A]  
[6-B. PBS Pro Submit interactive job request and use prun to launch executable][6-B]  
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

vi /root/dasan_ohpc_variable.sh  
```

\# '/root/dasan_ohpc_variable.sh' 파일 내용.
```bash
#!/bin/bash

# 클러스터 이름.
export CLUSTER_NAME=OpenHPC_Dasandata # 변경 필요

# 노드 배포 이미지 경로 (chroot)
export CHROOT=/opt/ohpc/admin/images/centos7

# MASTER 의 이름 과 IP.
export MASTER_HOSTNAME=$(hostname -s)
export MASTER_IP=10.1.1.254
export MASTER_PREFIX=24

# 인터페이스 이름.
export EXT_NIC=em2 # 외부망.
export INT_NIC=em1 # 내부망.
export NODE_INT_NIC=eth0  # node 들의 내부망 인터페이스 명.

# end of file.
```

### ### root 계정에서 항상 사용할 수 있도록 적용.
```bash
echo "source  /root/dasan_ohpc_variable.sh" >> /root/.bashrc

source  /root/.bashrc

echo $CHROOT

```

***

# # 2. [Network and Firewall Setup to Base Operating System (BOS)][contents]

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
firewall-cmd --change-interface=${EXT_NIC}  --zone=external  --permanent
firewall-cmd --change-interface=${INT_NIC}  --zone=trusted   --permanent

firewall-cmd --reload
systemctl restart firewalld

firewall-cmd --list-all --zone=external
firewall-cmd --list-all --zone=trusted
```

## ## 2.4 클러스터 마스터 IP 와 HOSTNAME 을 hosts 에 등록.
```bash
echo "${MASTER_IP}      ${MASTER_HOSTNAME}"  >>  /etc/hosts
cat /etc/hosts
```

***

# # 3. [Install OpenHPC Components][contents]
## ## 3.1 Enable OpenHPC repository for local use
```bash
# Check current repolist
yum repolist

# Install to OpenHPC repository.
yum -y install \
http://build.openhpc.community/OpenHPC:/1.3/CentOS_7/x86_64/ohpc-release-1.3-1.el7.x86_64.rpm \
>> ~/dasan_log_ohpc_openhpc_repository.txt 2>&1  

tail ~/dasan_log_ohpc_openhpc_repository.txt

# Check added repolist
yum repolist | grep OpenHPC

```

## ## 3.3 Add provisioning services on master node

### ### Install base meta-packages
```bash
yum -y install ohpc-base ohpc-warewulf squashfs-tools >>  ~/dasan_log_ohpc_base,warewulf.txt 2>&1
tail ~/dasan_log_ohpc_base,warewulf.txt  
```

### ### NTP Server 설정
```bash
cat /etc/ntp.conf | grep -v "#\|^$"

echo "server time.bora.net" >> /etc/ntp.conf

cat /etc/ntp.conf | grep -v "#\|^$"

systemctl enable ntpd.service && systemctl restart ntpd
```

## ## 3.4 Add resource management services on master node
\# **주의!** Resource Manager는 Slurm 과 PBS Pro 중 선택하여 진행 합니다.  
\# GPU Cluster 의 경우 3.4-A. Slurm 을 설치해야 합니다.  
\# OpenHPC 에서 제공되는 Slurm 의 버젼이 18.08 으로 낮아서 EPEL 을 통해서 20.11 버젼을 설치 합니다.

## ## [3.4-A (Slurm) Resource Management Services Install.][contents]
\# 참조 링크: https://slurm.schedmd.com/

### ### Install slurm server meta-package
```bash
yum -y  --disablerepo=OpenHPC,OpenHPC-updates   install  slurm*  \
  >> ~/dasan_log_ohpc_resourcemanager_slurm.txt 2>&1
tail ~/dasan_log_ohpc_resourcemanager_slurm.txt  
```

### ### Install munge-devel
```bash
yum -y --disablerepo=OpenHPC,OpenHPC-updates install munge-devel
>> ~/dasan_log_ohpc_resourcemanager_slurm.txt 2>&1
tail ~/dasan_log_ohpc_resourcemanager_slurm.txt  

create-munge-key
ll /etc/munge/munge.key

systemctl enable munge.service && systemctl start  munge.service
```

### ### slurm.conf 는 추후 설정.

***

## ## [3.4-B (PBS Pro) Resource Management Services Install][content]

### ### Install to pbspro-server-ohpc
```bash
yum -y install pbspro-server-ohpc >> ~/dasan_log_ohpc_resourcemanager_pbspro.txt 2>&1
tail -1 ~/dasan_log_ohpc_resourcemanager_pbspro.txt
```
***

## ## [3.5 Optionally add InfiniBand support services on master node][content]

### ### 3.5.1 Install InfiniBand support on master node

```bash
yum -y groupinstall "InfiniBand Support" >> ~/dasan_log_ohpc_IBSupport.txt 2>&1
tail -1 ~/dasan_log_ohpc_IBSupport.txt

yum -y install infinipath-psm opensm libibverbs-utils >> ~/dasan_log_ohpc_IBSupport.txt 2>&1
tail -1 ~/dasan_log_ohpc_IBSupport.txt
```

### ### 3.5.2 Load InfiniBand drivers
```bash
systemctl enable opensm
systemctl start opensm

systemctl start rdma
systemctl enable rdma
```

### ### 3.5.3 Copy ib0 template to master for IPoIB(IP Over InfiniBand)
```bash
cp  /opt/ohpc/pub/examples/network/centos/ifcfg-ib0   /etc/sysconfig/network-scripts

```

### ### 3.5.4 Define local IPoIB(IP Over InfiniBand) address and netmask
```bash
sed -i "s/master_ipoib/${sms_ipoib}/"      /etc/sysconfig/network-scripts/ifcfg-ib0
sed -i "s/ipoib_netmask/${ipoib_netmask}/" /etc/sysconfig/network-scripts/ifcfg-ib0

echo  “MTU=4096”  >>  /etc/sysconfig/network-scripts/ifcfg-ib0
```

### ### 3.5.5 Initiate ib0 (InfiniBand Interface 0)
```bash
ifup ib0

ibstat

ibhosts
```

### ### 3.5.6 ib 방화벽 zone 설정 변경
```bash
firewall-cmd --change-interface=ib0  --zone=trusted   --permanent

firewall-cmd --reload && systemctl restart firewalld

firewall-cmd --list-all --zone=trusted

```

## ## 3.7 Complete basic Warewulf setup for master node

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


### ### Enable tftp service for compute node image distribution
```bash
grep disable /etc/xinetd.d/tftp
perl -pi -e "s/^\s+disable\s+= yes/ disable = no/" /etc/xinetd.d/tftp
grep disable /etc/xinetd.d/tftp
```

### ### Restart/enable relevant services to support provisioning
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

## ## 3.8 Define compute image for provisioning

### ### Check chroot location.
\# chroot 작업을 하기 전에 항상, ${CHROOT} 변수가 알맞게 선언 되어 있는지 확인하는 것을 권장합니다.
```bash
echo ${CHROOT}
```

### ### 3.8.1 Build initial BOS (Base OS) image
```bash
wwmkchroot centos-7 ${CHROOT} >> ~/dasan_log_ohpc_initial-BaseOS.txt 2>&1
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
```

### ### 3.8.2 Add OpenHPC components
#### #### 3.8.2.1 Install compute node base meta-package.
\# 기본 적으로 필요한 패키지를 node image 에 설치 합니다.
```bash
yum -y --installroot=${CHROOT} install \
 ohpc-base-compute kernel kernel-headers kernel-devel kernel-tools parted \
 xfsprogs python-devel yum htop ipmitool glibc* perl perl-CPAN perl-CPAN \
 sysstat gcc make xauth firefox squashfs-tools stress >> ~/dasan_log_ohpc_meta-package.txt 2>&1

tail ~/dasan_log_ohpc_meta-package.txt  
```

#### #### 3.8.2.2 updated to enable DNS resolution.
```bash
cat /etc/resolv.conf
cp -p /etc/resolv.conf ${CHROOT}/etc/resolv.conf  
```

***

#### #### 3.8.2.3-A Add Slurm client support meta-package
\# **주의!** - Resource Manager 로 **Slurm** 을 사용하는 경우에만 실행 합니다.
```bash
yum -y --installroot=${CHROOT} --disablerepo=OpenHPC,OpenHPC-updates install \
munge-libs munge slurm slurm-contribs slurm-pam_slurm slurm-perlapi slurm-slurmd \
>> ~/dasan_log_ohpc_slurmclient.txt 2>&1

tail -1 ~/dasan_log_ohpc_slurmclient.txt

chroot ${CHROOT} systemctl enable munge
chroot ${CHROOT} systemctl enable slurmd

# vnfs 에 log 폴더가 생성되도록 합니다. (munge log 폴더가 생성 되어야 함)
grep log /etc/warewulf/vnfs.conf

sed  -i 's#exclude += /var/log/*#\#exclude += /var/log/*#'  /etc/warewulf/vnfs.conf

grep log /etc/warewulf/vnfs.conf
```

***

#### #### 3.8.2.3-B Add PBS Professional client support
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

#### #### 3.8.2.4 Add Network Time Protocol (NTP) support, kernel drivers, modules user environment.
```bash
yum -y --installroot=${CHROOT} install ntp kernel lmod-ohpc \
 >> ~/dasan_log_ohpc_ntp,kernel,modules.txt 2>&1
tail ~/dasan_log_ohpc_ntp,kernel,modules.txt  
```

***

### ### 3.8.3 Customize system configuration

#### #### Initialize warewulf database and ssh_keys
```bash
wwinit database && wwinit ssh_keys
```

#### #### Add NFS client mounts of /home and /opt/ohpc/pub and /{ETC} to base image.

```bash
df -hT | grep -v tmpfs
echo ${MASTER_HOSTNAME}
cat  ${CHROOT}/etc/fstab

echo "${MASTER_HOSTNAME}:/home         /home         nfs nfsvers=3,nodev,nosuid 0 0" >> ${CHROOT}/etc/fstab
echo "${MASTER_HOSTNAME}:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3,nodev 0 0"        >> ${CHROOT}/etc/fstab

# 아래는 data 디렉토리를 별도로 구성하는 경우에만.
#echo "${MASTER_HOSTNAME}:/data /data nfs nfsvers=3,nodev 0 0" >> ${CHROOT}/etc/fstab
cat  ${CHROOT}/etc/fstab  
```


#### #### Export /home and OpenHPC public packages from master server.

```bash
cat /etc/exports

echo "/home         10.1.1.0/24(rw,no_subtree_check,no_root_squash)"  >> /etc/exports
echo "/opt/ohpc/pub 10.1.1.0/24(ro,no_subtree_check)"                 >> /etc/exports

# 아래는 dell 서버인 경우에만 (racadm을 노드에서 사용)
#echo "/opt/dell     10.1.1.0/24(ro,no_subtree_check)"                 >> /etc/exports

# 아래는 data 디렉토리를 별도로 구성하는 경우에만.  
#echo "/data 10.1.1.0/24(rw,no_subtree_check,no_root_squash)" >> /etc/exports
#mkdir ${CHROOT}/data

cat /etc/exports

systemctl enable  nfs-server && systemctl restart nfs-server && exportfs
```

#### #### (Optional) nfs by IPoIB with RDMA
```bash
echo rdma 20049       > /proc/fs/nfsd/portlist
echo "echo rdma 20049 > /proc/fs/nfsd/portlist" >> /etc/rc.local

vi ${CHROOT}/etc/fstab

master:/home         /home         nfs  nfsvers=3,nodev,proto=rdma,port=20049,nosuid  0 0
master:/opt/ohpc/pub /opt/ohpc/pub nfs  nfsvers=3,nodev,proto=rdma,port=20049         0 0
master:/data         /data         nfs  nfsvers=3,nodev,proto=rdma,port=20049,nosuid  0 0

systemctl enable  nfs-server && systemctl restart nfs-server && exportfs
```


#### #### Enable NTP time service on computes and identify master host as local NTP server.

```bash
chroot ${CHROOT} systemctl enable ntpd
echo "server ${MASTER_HOSTNAME}" >> ${CHROOT}/etc/ntp.conf
```

***

### ### 3.8.4 Additional Customization (Optional)

#### #### 3.8.4.1 Enable InfiniBand drivers

##### ###### Add IB support and enable on nodes
```bash
yum -y --installroot=${CHROOT} groupinstall "InfiniBand Support" >> ~/dasan_log_ohpc_nodeIBSupport.txt 2>&1
tail  -1 ~/dasan_log_ohpc_nodeIBSupport.txt

yum -y --installroot=${CHROOT} install infinipath-psm  libibverbs-utils >> ~/dasan_log_ohpc_nodeIBSupport.txt 2>&1
tail  -1 ~/dasan_log_ohpc_nodeIBSupport.txt

chroot ${CHROOT} systemctl enable rdma
```

##### ##### Import File for IPoIB Interfaces
```bash
wwsh    file import /opt/ohpc/pub/examples/network/centos/ifcfg-ib0.ww
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


#### #### 3.8.4.5 Add Lustre client (2.9.0-77.1.x86_64)

http://build.openhpc.community/OpenHPC:/1.3/CentOS_7/x86_64/

##### ##### Add Lustre client software to master host
```bash
yum -y install lustre-client-ohpc
```

##### ##### Add Lustre client software in compute image
```bash
yum -y --installroot=$CHROOT install lustre-client-ohpc
```

##### ##### Include mount point and file system mount in compute image
```bash
mkdir $CHROOT/lustre

echo "10.xx.xx.x:/lustre  /lustre  lustre  defaults,localflock,noauto,x-systemd.automount 0 0" \
>> $CHROOT/etc/fstab
```

##### ##### Make file of lustre.conf (lnet config)
```bash
echo "options lnet networks=o2ib(ib0)" >> /etc/modprobe.d/lustre.conf
echo "options lnet networks=o2ib(ib0)" >> $CHROOT/etc/modprobe.d/lustre.conf
```

##### ##### Lustre Mount test.
```bash
mkdir /lustre

mount -t lustre -o localflock 10.xx.xx.x:/lustre /lustre
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

wwsh file list
```

#### #### (Optional) Files for Slurm Resource Manager
\# Slurm 을 사용하는 경우에만 실행 합니다.
```bash
wwsh file import /etc/slurm/slurm.conf
wwsh file import /etc/munge/munge.key
```

## ## 3.9 Finalizing provisioning configuration


### ### 3.9.0 /etc/warewulf/vnfs.conf 수정.

```bash
cp  /etc/warewulf/vnfs.conf{,.org}  # conf file backup.

cat /etc/warewulf/vnfs.conf  | grep -v "^$\|^#"

cat /etc/warewulf/vnfs.conf  | grep -v "^$\|^#" | wc -l
# -> 14
```
***
```bash
sed -i "s#hybridize += /usr/lib/locale#\#hybridize += /usr/lib/locale#"     /etc/warewulf/vnfs.conf
sed -i "s#hybridize += /usr/lib64/locale#\#hybridize += /usr/lib64/locale#" /etc/warewulf/vnfs.conf
sed -i "s#hybridize += /usr/include#\#hybridize += /usr/include#"           /etc/warewulf/vnfs.conf
sed -i "s#hybridize += /usr/share/locale#\#hybridize += /usr/share/locale#" /etc/warewulf/vnfs.conf
sed -i "s#exclude += /usr/src#\#exclude += /usr/src#" /etc/warewulf/vnfs.conf

cat /etc/warewulf/vnfs.conf  | grep -v "^$\|^#"

cat /etc/warewulf/vnfs.conf  | grep -v "^$\|^#" | wc -l
# -> 9
```

### ### 3.9.1 Assemble bootstrap image

#### #### Include drivers from kernel updates; needed if enabling additional kernel modules on computes

```bash
export WW_CONF=/etc/warewulf/bootstrap.conf
echo "drivers += updates/kernel/"      >> $WW_CONF
echo "modprobe += ahci, nvme, e1000e"  >> $WW_CONF
```

#### #### Build bootstrap image & check bootstrap list
```bash
wwbootstrap  `uname -r`

wwsh bootstrap list
```


### ### 3.9.2 Assemble Virtual Node File System (VNFS) image

```bash
echo ${CHROOT}

wwvnfs --chroot ${CHROOT}
# or wwvnfs --chroot /opt/ohpc/admin/images/centos7

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
wwsh -y node new node01

wwsh -y node set node01 --netdev ${NODE_INT_NIC} --netmask=255.255.255.0 --gateway ${MASTER_IP} \
 --ipaddr=10.1.1.1 --hwaddr=aa:bb:cc:dd:ee:ff

wwsh node list
```

#### #### (Optional) Additional step required if desiring to use predictable network interface
#### #### naming schemes (e.g. en4s0f0). Skip if using eth# style names.
\# "이것을 적용하면 네트워크 인터페이스 명이 ens4s0f0 과 같은 형태로 표시됩니다."  
\# "eth0 과 같은 형식의 인터페이스명을 사용하려면 적용하지 않습니다."  

```bash
export kargs="${kargs} net.ifnames=1,biosdevname=1"

wwsh -y provision set node01   --kargs="${kargs}"
wwsh -y provision set --postnetdown=1  node01
```

#### #### Define provisioning image for hosts
```bash
wwsh -y provision set node01 --vnfs=centos7  --bootstrap=`uname -r ` \
--files=dynamic_hosts,passwd,group,shadow,network

wwsh provision list
```

##### ##### Slurm 을 사용할 경우 - files= 에 slurm.conf,munge.key 도 추가.
```bash
wwsh -y provision set node01 --vnfs=centos7  --bootstrap=`uname -r ` \
--files=dynamic_hosts,passwd,group,shadow,network,slurm.conf,munge.key

wwsh provision list
```

#### #### Restart dhcp / update PXE

```bash
systemctl restart dhcpd && wwsh pxe update
```

***

#### #### define IPoIB network settings (if planning to mount NFS by IPoIB)
```bash
wwsh -y node set node01 -D ib0 --ipaddr=172.1.1.1 --netmask=255.255.255.0

wwsh -y provision set node01   --fileadd=ifcfg-ib0.ww
```

### ### 3.7.5 configure stateful provisioning

#### #### Add GRUB2 bootloader and re-assemble VNFS image
```bash
yum -y --installroot=${CHROOT} install  grub2 grub2-efi grub2-efi-modules
wwvnfs --chroot ${CHROOT}
```

#### #### Copy Filesystem cmds files
```bash
cd /root/
git clone https://github.com/dasandata/Open_HPC
cp   /root/Open_HPC/Provisioning/*.cmds   /etc/warewulf/filesystem/
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
NM_CONTROLLED=no
DEVTIMEOUT=5
DEFROUTE=yes
EOF

# file import
wwsh -y file  import             /opt/ohpc/pub/examples/network/centos/ifcfg-eno1.ww
wwsh -y file  set ifcfg-eno1.ww  --path=/etc/sysconfig/network-scripts/ifcfg-eno1

# provision set
wwsh provision set  node01  --filadd=ifcfg-eno1.ww
wwsh node      set  node01  --netdev=eno1    --ipaddr=xx.xx.xx.x  --netmask=  --gateway=  --hwaddr=  

```

#### #### node 에 root 계정이 password로 접근할 수 없도록 sshd 설정을 변경.
```bash
wwsh vnfs list
export CHROOT=/opt/ohpc/admin/images/centos7

sed -i 's/#PermitRootLogin yes/PermitRootLogin without-password/'  ${CHROOT}/etc/ssh/sshd_config

wwvnfs --chroot  ${CHROOT}
```

#### #### 외부 ip 접근이 허용된 장비를 로그인 노드로 운영할 경우, pam.d 를 일반 노드와 다르게 적용.
```bash
diff  ${CHROOT}/etc/pam.d/sshd   /etc/pam.d/sshd
# 21d20
# < account required pam_slurm.so

wwsh file import    /etc/pam.d/sshd  # master 와 동일한 pam.d 를 적용하기 위함.
wwsh provision set  login-node  --fileadd=sshd
```

#### #### 외부 ip 접근이 허용된 로그인 노드에 대한 hosts.allow & deny 적용
```bash
ll   /etc/hosts.allow   /etc/hosts.deny

wwsh file import  /etc/hosts.allow
wwsh file import  /etc/hosts.deny

wwsh provision set  login-node  --fileadd=hosts.allow,hosts.deny
```

#### #### hosts.allow  hosts.deny 예제.
```bash
### /etc/hosts.deny
sshd: ALL

### /etc/hosts.allow
# From Local
sshd: 127., 172., 192.168., 10.1.
# From organization (range)
sshd: xxx.xx.
# From Dasandata.
sshd: xxx.xxx.xx.x
```

## ## 3.8 Boot compute nodes
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

# # 4. [Install OpenHPC Development Components][contents]

## ## 4.1 Development Tools

### ### Install autotools meta-package (Default)
```bash
yum -y install  ohpc-autotools EasyBuild-ohpc hwloc-ohpc spack-ohpc valgrind-ohpc \
>> ~/dasan_log_ohpc_autotools,meta-package.txt 2>&1
tail -1 ~/dasan_log_ohpc_autotools,meta-package.txt
```

## ## 4.2 Compilers (gcc ver 8, 7 and 5.4)
```bash
yum -y install  gnu8-compilers-ohpc gnu7-compilers-ohpc gnu-compilers-ohpc  \
 >> ~/dasan_log_ohpc_Compilers.txt 2>&1
tail -1 ~/dasan_log_ohpc_Compilers.txt
```

## ## 4.3 MPI Stacks (for gnu7, gnu8)
```bash
yum -y install  openmpi-gnu7-ohpc openmpi3-gnu7-ohpc mvapich2-gnu7-ohpc mpich-gnu7-ohpc \
 >> ~/dasan_log_ohpc_MPI-Stacks_gnu7.txt 2>&1
tail -1 ~/dasan_log_ohpc_MPI-Stacks_gnu7.txt

yum -y install  openmpi3-gnu8-ohpc mpich-gnu8-ohpc mvapich2-gnu8-ohpc \
 >> ~/dasan_log_ohpc_MPI-Stacks_gnu8.txt 2>&1
tail -1 ~/dasan_log_ohpc_MPI-Stacks_gnu8.txt
```

## ## 4.4 Performance Tools
### ### Install perf-tools meta-package
```bash
yum -y install       ohpc-gnu8-perf-tools >> ~/dasan_log_ohpc_perf-tools-gnu8.txt 2>&1
yum -y groupinstall  ohpc-perf-tools-gnu  >> ~/dasan_log_ohpc_perf-tools-gnu.txt 2>&1
tail -1 ~/dasan_log_ohpc_perf-tools-gnu8.txt
```

***

## ## 4.5 Setup default development environment

```bash
yum -y install  lmod-defaults-gnu7-openmpi3-ohpc  >> ~/dasan_log_ohpc_lmod-gnu7.txt 2>&1
tail -1 ~/dasan_log_ohpc_lmod-gnu7.txt

# Optionally
# yum -y install  lmod-defaults-gnu8-openmpi3-ohpc  >> ~/dasan_log_ohpc_lmod-gnu8.txt 2>&1
# tail -1 ~/dasan_log_ohpc_lmod-gnu8.txt
```

## ## 4.6 3rd Party Libraries and Tools
### ### Install 3rd party libraries/tools meta-packages built with GNU toolchain
```bash
yum -y install ohpc-gnu8-serial-libs ohpc-gnu8-io-libs ohpc-gnu8-python-libs \
 ohpc-gnu8-runtimes >> ~/dasan_log_ohpc_3rdPartyLib.txt 2>&1
tail -1 ~/dasan_log_ohpc_3rdPartyLib.txt
```

### ### Install parallel lib meta-packages for all available MPI toolchains
```bash
yum -y install  ohpc-gnu8-mpich-parallel-libs ohpc-gnu8-openmpi3-parallel-libs \
  >> ~/dasan_log_ohpc_parallellib.txt 2>&1
tail -1 ~/dasan_log_ohpc_parallellib.txt
````

### ### Install gnu5 MPI Stacks & lib & meta-packages
```bash
yum -y groupinstall  ohpc-io-libs-gnu ohpc-parallel-libs-gnu ohpc-parallel-libs-gnu-mpich \
 ohpc-python-libs-gnu ohpc-runtimes-gnu ohpc-serial-libs-gnu >> ~/dasan_log_ohpc_gnu5MPI.txt 2>&1
tail -1 ~/dasan_log_ohpc_gnu5MPI.txt
```

## ## 4.7 Optional Development Tool Builds

### ### Install OpenHPC compatibility packages (requires prior installation of Parallel Studio)
```bash
yum -y install intel-compilers-devel-ohpc intel-mpi-devel-ohpc >> ~/dasan_log_ohpc_compatibility.txt 2>&1
tail -1  ~/dasan_log_ohpc_compatibility.txt
```

### ### Fast way ;)  (use script)
```bash
cd ~
git clone https://github.com/dasandata/Open_HPC
cat ./Open_HPC/Provisioning/4_Install_OpenHPC_Development_Components_1.3.9.sh

bash ./Open_HPC/Provisioning/4_Install_OpenHPC_Development_Components_1.3.9.sh
```
***

# # 5. [Resource Manager Startup][contents]
\# **주의!** Resource Manager는 Slurm 과 PBSPro 중 선택하여 진행 합니다.  

## ## [5-A. Start slurm controller and munge on master host][contents]
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
\# /etc/slurm/slurm.conf

```bash
SlurmUser=slurm
SlurmctldPort=6817
SlurmdPort=6818
AuthType=auth/munge
StateSaveLocation=/var/spool/slurm/ctld
SlurmdSpoolDir=/var/spool/slurm/d
SwitchType=switch/none
MpiDefault=none
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmdPidFile=/var/run/slurmd.pid
ProctrackType=proctrack/pgid
SlurmctldTimeout=300
SlurmdTimeout=300
InactiveLimit=0
MinJobAge=300
KillWait=30
Waittime=0
SchedulerType=sched/backfill
SelectType=select/cons_res
SelectTypeParameters=CR_Core
DefMemPerCPU=0
FastSchedule=1
SlurmctldDebug=3
SlurmctldLogFile=/var/log/slurmctld.log
SlurmdDebug=3
SlurmdLogFile=/var/log/slurmd.log
JobCompType=jobcomp/none
PropagateResourceLimitsExcept=MEMLOCK
AccountingStorageType=accounting_storage/filetxt
ReturnToService=1
PrologFlags=x11        # X11 Forwarding for interactive job "srun --x11 --pty /bin/bash"

ClusterName=OpenHPC_dasandata
ControlMachine=ohpc-master

# GresTypes=gpu

NodeName=node01 CPUs=4 RealMemory=1024 State=UNKNOWN   # Gres=gpu:GTX1080Ti:4
# NodeName=node[01-05] CPUs=4 RealMemory=1024 State=UNKNOWN  Gres=gpu:GTX1080Ti:4

PartitionName=default  Default=YES   Nodes=node[1-2]   MaxTime=1-12:00:00  State=UP
```

### ### sinfo
```bash
sinfo --long

sinfo -R
```

\# node 의 STATE 가 drain 상태 일 경우 scontrol 명령을 사용해 node 의 상태를 resume 로 변경 합니다.
```bash
scontrol  update  nodename=node01  state=resume

sinfo --long
```

## ## [5-B. Start pbspro daemons on master host][contents]
```bash
systemctl enable pbs
systemctl start pbs
```
### ### initialize PBS path
```bash
source  /etc/profile.d/pbs.sh

# enable user environment propagation (needed for modules support)
qmgr -c "set server default_qsub_arguments= -V"
# enable uniform multi-node MPI task distribution
qmgr -c "set server resources_default.place=scatter"
# enable support for job accounting
qmgr -c "set server job_history_enable=True"
```

### ### register compute hosts with pbspro (single node)
```bash
qmgr -c "create node node01"
```

### ### add queue name for compute hosts (if you have))
```bash
qmgr -c "create queue  newqueue"

qmgr -c "set node  node01  queue=newqueue"

```

### ### check pbspro status

```bash
pbsnodes -aSj

qstat -q

qstat -ans
```

## ## 6. [Run a Test Job][contents]
```bash
wwsh file list
wwsh file resync
```

```bash
pdsh -w node01 uptime
pdsh -w node01 'rm -rf /tmp/.wwgetfile*  &&  /warewulf/bin/wwgetfiles'

# pbspro 인 경우
pdsh -w node01 systemctl status pbs | grep active

# slurm 인 경우
pdsh -w node01 systemctl status slurmd | grep active

# node가 여러대 인 경우
pdsh -w node[01-04] uptime
pdsh -w node[01-04] 'rm -rf /tmp/.wwgetfile*  &&  /warewulf/bin/wwgetfiles'
pdsh -w node[01-04] systemctl status pbs | grep active
```

### ### 6.1 Interactive execution
#### #### Switch to normal user
```bash
su - sonic   # sonic is dasandata's normal user name.
```

#### #### Compile MPI "hello world" example
```bash
cd
pwd

mpicc -O3 /opt/ohpc/pub/examples/mpi/hello.c

ls
```

#### #### [(6-A. Slurm) Submit interactive job request and use prun to launch executable][contents]
```bash
srun -N 1 -c 4 --pty /bin/bash  # -N = node 갯수 / -c = cpu 갯수

squeue

prun ./a.out

squeue

exit

squeue
```

#### #### [(6-B. PBS Pro) Submit interactive job request and use prun to launch executable][contents]
```bash
qsub -I -l select=1:mpiprocs=4  # select = node 갯수 / mpiprocs = cpu 갯수

qstat

prun ./a.out

qstat

exit

qstat
```
***

# END.
