[contents]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-목차
[1]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-1-introduction
[2]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-2-network-and-firewall-setup-to-base-operating-system-bos
[3]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-3-install-openhpc-components
[3.1]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-31-enable-openhpc-repository-for-local-use
[3.3]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-33-add-provisioning-services-on-master-node
[3.4]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-34-add-resource-management-services-on-master-node
[3.5]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-35-optionally-add-infiniband-support-services-on-master-node
[3.7]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-37-complete-basic-warewulf-setup-for-master-node
[3.8]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-37-complete-basic-warewulf-setup-for-master-node
[3.9]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-39-finalizing-provisioning-configuration
[3.10]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-310-boot-compute-nodes
[4]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-4-install-openhpc-development-components
[5]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-5-resource-manager-startup
[6]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-6-slurmdbd-sacctmgr-cgroup
[7]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#-7-gpu-node-provisioning-of-openhpc-cluster
[END]: OpenHPC%20Cluster%20Building%20(v4.0-Alma10%20Base%20OS).md#end

# Dasandata Standard Recipes of OpenHPC Cluster Building (v4.0-Alma10 Base OS)[2025.12]

\# 참조 링크 : http://openhpc.community/  
\# Root 로 로그인 하여 설치를 시작 합니다.  
![Cluster Architecture](https://image.slidesharecdn.com/schulz-mug-17-170930151325/95/openhpc-project-overview-and-updates-8-638.jpg?cb=1506784595)

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
https://github.com/openhpc/ohpc/wiki/4.x 

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
export CLUSTER_NAME=ohpc_cluster # 변경 필요

# MASTER 의 이름 과 IP.
export MASTER_HOSTNAME=$(hostname -s)
export MASTER_IP=10.1.1.200
export MASTER_PREFIX=24
export MASTER_NETWORK=10.1.1.0

# 인터페이스 이름.
export EXT_NIC=eno1 # 외부망.
export INT_NIC=eno2 # 내부망.

# end of file.
EOF

cat /usr/local/sbin/dasan_ohpc_variable.sh

```

### ### root 계정에서 항상 사용할 수 있도록 적용.
```bash
echo "source  /usr/local/sbin/dasan_ohpc_variable.sh" >> /root/.bashrc

source  /root/.bashrc

echo $MASTER_HOSTNAME

```

***

# # [2. Network and Firewall Setup to Base Operating System (BOS)][contents]

## ## 2.1 외부망 및 내부망 인터페이스 설정.

```bash
ip a    # 인터페이스 목록 확인  
```

## ## 2.2 Master 의 외부/내부 인터페이스 설정내용 확인, 필요한 경우 설정.
```bash
nmtui  # NetworkMakager UserInterface.
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

***

# # [3. Install OpenHPC Components][contents]
## ## 3.1 Enable OpenHPC repository for local use
```bash
# Check current repolist
dnf repolist

# Install to OpenHPC repository.
dnf -y install \
http://repos.openhpc.community/OpenHPC/4/EL_10/x86_64/ohpc-release-4-1.el10.x86_64.rpm \
>> ~/dasan_log_ohpc_openhpc_repository.txt 2>&1  

tail ~/dasan_log_ohpc_openhpc_repository.txt

# Check added repolist
dnf repolist | grep OpenHPC

# dnf enable Powertools
dnf -y install dnf-plugins-core
dnf config-manager --set-enabled crb

```

## ## [3.3 Add provisioning services on master node][contents]

### ### Install base meta-packages
```bash
dnf -y install ohpc-base warewulf-ohpc yq >>  ~/dasan_log_ohpc_base,warewulf.txt 2>&1
tail ~/dasan_log_ohpc_base,warewulf.txt  
```

### ### Create the tftboot directory
```bash
 install -d -m 0755 /var/lib/tftpboot
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
sleep 10
chronyc tracking
chronyc sources
chronyc sourcestats

```

## ## [3.4 Add resource management services on master node][contents]
\# **주의!** Resource Manager는 Slurm 으로만 진행 합니다.  

### ### Install slurm server meta-package
```bash
dnf -y install ohpc-slurm-server \
  >> ~/dasan_log_ohpc_resourcemanager_slurm.txt 2>&1

tail ~/dasan_log_ohpc_resourcemanager_slurm.txt  

# Use ohpc-provided file for starting SLURM configuration
cp /etc/slurm/slurm.conf.ohpc     /etc/slurm/slurm.conf
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


cat /etc/slurm/slurm.conf | grep -v "^#\|^$"

```



## ## [3.5 Optionally add InfiniBand support services on master node][contents]

### ### 3.5.1 Install InfiniBand support on master node

```bash
dnf -y groupinstall "InfiniBand Support"        >> ~/dasan_log_ohpc_IBSupport.txt 2>&1
tail -1 ~/dasan_log_ohpc_IBSupport.txt

dnf -y install opensm libibverbs-utils libpsm2  >> ~/dasan_log_ohpc_IBSupport.txt 2>&1
tail -1 ~/dasan_log_ohpc_IBSupport.txt
```

### ### 3.5.2 Load InfiniBand drivers
```bash
udevadm trigger --type=devices --action=add
systemctl restart rdma-load-modules@infiniband.service

systemctl enable opensm
systemctl start opensm
```

### ### 3.5.3 Copy ib0 template to master for IPoIB(IP Over InfiniBand)
```bash
cp  /opt/ohpc/pub/examples/network/centos/ifcfg-ib0   /etc/sysconfig/network-scripts

```

### ### 3.5.4 Define local IPoIB(IP Over InfiniBand) address and netmask
```bash
sed -i "s/master_ipoib/172.1.1.200/"      /etc/sysconfig/network-scripts/ifcfg-ib0
sed -i "s/ipoib_netmask/255.255.255.0/"   /etc/sysconfig/network-scripts/ifcfg-ib0

echo  "MTU=4096"  >>  /etc/sysconfig/network-scripts/ifcfg-ib0

cat /etc/sysconfig/network-scripts/ifcfg-ib0
```

### ### 3.5.5 configure NetworkManager to *not* override local /etc/resolv.conf
```bash
echo "[main]"   >  /etc/NetworkManager/conf.d/90-dns-none.conf
echo "dns=none" >> /etc/NetworkManager/conf.d/90-dns-none.conf

systemctl restart NetworkManager
```

### ### 3.5.6 Initiate ib0 (InfiniBand Interface 0)
```bash
ip a

ibstat

ibstatus

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
# 적절한 네트워크 인터페이스와 설정을 사용하도록 warewulf.conf 파일을 수정  
yq -i ".ipaddr = \"${MASTER_IP}\"" /etc/warewulf/warewulf.conf
yq -i ".netmask = \"${MASTER_PREFIX}\"" /etc/warewulf/warewulf.conf
yq -i ".network = \"${MASTER_NETWORK}\"" /etc/warewulf/warewulf.conf
yq -i ".dhcp[\"range start\"] = \"${MASTER_NETWORK}\"" /etc/warewulf/warewulf.conf
yq -i ".dhcp[\"range end\"] = \"static\"" /etc/warewulf/warewulf.conf

cat /etc/warewulf/warewulf.conf

# 부팅 시 /opt 디렉터리가 마운트되도록 nodes.conf 파일을 수정
perl -pi -e "s/defaults,noauto,nofail,ro/defaults,nofail,ro/" /etc/warewulf/nodes.conf

grep "noauto"  /etc/warewulf/nodes.conf

# 내부 네트워크 인터페이스에서 요청을 수신하도록 dnsmasq를 설정
echo "interface=${INT_NIC}" > /etc/dnsmasq.d/ww4-interface.conf

cat /etc/dnsmasq.d/ww4-interface.conf

# DNS 기능은 비활성화하도록 dnsmasq를 설정
echo "port=0" >> /etc/dnsmasq.d/ww4-interface.conf

cat /etc/dnsmasq.d/ww4-interface.conf

# 부팅 시 디버깅 메시지를 활성화합니다.
yq -i '.nodeprofiles.default.kernel.args -= ["quiet"]' /etc/warewulf/nodes.conf
echo "log-debug" >> /etc/dnsmasq.d/ww4-interface.conf

grep "quiet" /etc/warewulf/nodes.conf # 출력물 없어야함
grep "log" /etc/dnsmasq.d/ww4-interface.conf

# wwctl 명령어를 사용하기 전에 warewulfd 서비스를 활성화하고 시작
systemctl enable --now warewulfd

# 새로운 "nodes" 프로필을 생성하고 "default" 프로필을 상속받도록 설정
wwctl profile add nodes --profile default --comment "Nodesprofile"

# 노드 설정 파일들을 저장할 "nodeconfig" 오버레이를 새로 생성하고, syncuser 오버레이를 사용
wwctl overlay create nodeconfig
wwctl profile set --yes nodes --system-overlays nodeconfig --runtime-overlays syncuser

# 기본 네트워크 구성을 설정
wwctl profile set -y nodes --netname=default --netdev=${NODE_INT_NIC}
wwctl profile set -y nodes --netname=default --netmask=${MASTER_PREFIX}
wwctl profile set -y nodes --netname=default --gateway=${MASTER_IP}
wwctl profile set -y nodes --netname=default --nettagadd=DNS=8.8.8.8  # 추후 외부망 연결 시 변경

# Warewulf 구성을 적용하면 프로비저닝을 지원하기 위해 관련 서비스들이 재시작되거나 활성화.
wwctl configure --all

# SSH 키를 생성
bash /etc/profile.d/ssh_setup.sh
```

## ## [3.8 Define compute image for provisioning][contents]

### ### 3.8.1 Build initial BOS (Base OS) image

```bash
# Import the base image from Warewulf
wwctl image import docker://ghcr.io/warewulf/warewulf-almalinux:10 almalinux-10 --syncuser
```
# Define chroot location
```bash
sed -i '/# end of file/i export CHROOT=$(wwctl image show almalinux-10)' /usr/local/sbin/dasan_ohpc_variable.sh

cat /usr/local/sbin/dasan_ohpc_variable.sh

source  /root/.bashrc

echo $CHROOT
```

### ### 3.8.2 Add OpenHPC components
#### #### Install compute node base meta-package.
# 기본적으로 필요한 패키지를 node image 에 설치 합니다.
```bash
wwctl image exec --build=false almalinux-10 -- /bin/bash -ex <<- EOF
dnf -y install dnf-utils
dnf -y install http://repos.openhpc.community/OpenHPC/4/EL_10/x86_64/ohpc-release-4-1.el10.x86_64.rpm
dnf -y update
EOF
```

```bash
wwctl image exec --build=false almalinux-10 -- /bin/bash -ex <<- EOF
dnf -y install epel-release
dnf -y install ohpc-base-compute
EOF
```

#### #### slurm-client, ntp, lmod 설치 등.
```bash
 wwctl image exec --build=false almalinux-10 -- /bin/bash -ex <<- EOF
# Add Slurm client support meta-package
dnf -y install ohpc-slurm-client
# Enable services to start on boot
systemctl enable munge.service
systemctl enable slurmd.service
# Add Network Time Protocol (NTP) support
dnf -y install chrony
# Include modules user environment
dnf -y install lmod-ohpc
EOF
```

### ### 3.8.4 Additional Customization (optional)

#### #### 3.8.4.1 Enable InfiniBand drivers
```bash
# Add IB support and enable
dnf -y --installroot=$CHROOT groupinstall "InfiniBand Support" >> ~/dasan_log_ohpc_nodeIBSupport.txt 2>&1
tail  -1 ~/dasan_log_ohpc_nodeIBSupport.txt

dnf -y --installroot=${CHROOT} install libibverbs-utils libpsm2  >> ~/dasan_log_ohpc_nodeIBSupport.txt 2>&1
tail  -1 ~/dasan_log_ohpc_nodeIBSupport.txt
```
##### ##### Import File for IPoIB Interfaces
```bash
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

#### #### 3.8.4.5 Add GPU drive (GPU노드 있을시)
```bash
# Add NVIDIA GPU driver repository to the SMS
dnf -y install cuda-repo-ohpc
dnf -y update kernel kernel-core kernel-modules
dnf -y update

# Install the toolkit on the SMS
dnf -y install nvidia-driver-cuda cuda-devel-ohpc

# Install NVIDIA repository and GPU driver in the compute image
wwctl image exec --build=false almalinux-10 -- /bin/bash -ex <<- EOF
dnf -y update kernel kernel-core kernel-modules
dnf -y install cuda-repo-ohpc
dnf -y install kmod-nvidia-latest-dkms nvidia-driver-cuda
KVER=\$(rpm -q --queryformat='%{version}-%{release}.%{arch}\n' \
kernel-core | sort -r | head -1)
echo "Building modules for kernel: \$KVER"
dkms autoinstall --verbose -k \$KVER
dkms status
EOF
```

```bash
wwctl image exec --build=false almalinux-10 -- /bin/bash -ex <<- EOF
dnf -y update
EOF
```

#### #### 3.8.4.6 Add Lustre client 

```bash
# Add Lustre client software to master host
dnf -y install lustre-client-ohpc

# Add Lustre client software in compute image
dnf -y --installroot=$CHROOT install lustre-client-ohpc

```

```bash

# Include mount point and file system mount in compute image
mkdir $CHROOT/lustre

echo "10.xx.xx.x:/lustre  /lustre  lustre  defaults,localflock,noauto,x-systemd.automount 0 0" \
>> $CHROOT/etc/fstab
```

```bash
# Make file of lustre.conf (lnet config)
#echo "options lnet networks=o2ib(ib0)" >> /etc/modprobe.d/lustre.conf
#echo "options lnet networks=o2ib(ib0)" >> $CHROOT/etc/modprobe.d/lustre.conf
echo "options lnet networks=tcp(eno2)" >> /etc/modprobe.d/lustre.conf
echo "options lnet networks=tcp(eno2)" >> $CHROOT/etc/modprobe.d/lustre.conf
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
# Add the following to support unprivileged user namespaces for tools like Apptainer
wwctl overlay import --parents nodeconfig /etc/subuid
wwctl overlay import --parents nodeconfig /etc/subgid

# Identify master host as local NTP server, configure it with a template with a Tag
 wwctl overlay import --parents nodeconfig \
/opt/ohpc/pub/examples/chrony.conf.ww /etc/chrony.conf.ww

wwctl profile set --yes nodes --tagadd ntpserver=${MASTER_IP}

# Configure systemd and NetworkManger to wait for the network to be fully up.
wwctl overlay import --parents nodeconfig \
/opt/ohpc/pub/examples/network/NetworkManager-wait-online.service.d/override.conf \
/etc/systemd/system/NetworkManager-wait-online.service.d/override.conf
```

```bash
# Configure Slurm server in the overlay (using "configless" option)
# using a tag in a template file (slurmd.ww)
wwctl overlay import --parents nodeconfig \
/opt/ohpc/pub/examples/slurm/slurmd.ww /etc/sysconfig/slurmd.ww

cat /opt/ohpc/pub/examples/slurm/slurmd.ww

# Set the value of the slurmctld tag to the $sms_ip for the nodes profile.
wwctl profile set --yes nodes --tagadd slurmctld=${MASTER_IP}

# Configure munge
wwctl overlay import --parents nodeconfig /etc/munge/munge.key
wwctl overlay chown nodeconfig /etc/munge/munge.key $(id -u munge) $(id -g munge)
wwctl overlay chown nodeconfig /etc/munge $(id -u munge) $(id -g munge)
wwctl overlay chmod nodeconfig /etc/munge 0700
```



## ## [3.9 Finalizing provisioning configuration][contents]
Warewulf는 선택적으로, 계산 노드에서 ramfs나 디스크로의 투‑스테이지 프로비저닝을 지원한다. 이때 노드들은 여전히 스테이트리스 상태이지만, 프로비저닝 과정 중에 이미지가 디스크로 복사되고, 매 부팅 시마다 다시 프로비저닝된다. 이는 예를 들어 GPU 드라이버처럼 계산 노드 이미지가 매우 크거나, 계산 노드의 메모리가 제한적인 경우에 유용하다. 투‑스테이지 프로비저닝을 설정하려면 계산 노드에 Dracut과 ignition을 설치해야 하며, ignition은 스왑과 로컬 스토리지를 프로비저닝하는 데에도 사용할 수 있다(자세한 내용은 Warewulf 문서를 참조). 아래 예제는 기본값인 ramfs로 프로비저닝하는 경우를 보여준다. 디스크로 프로비저닝하는 방법은 다음 절을 참고하라. 디버깅을 돕기 위해, 3.9.4절에서 설명하는 커널 인자에 rd.shell을 추가해 두면 문제 해결에 도움이 된다.

### ### 3.9.1 Two-Stage Provisioning (optional)
```bash
## Install Dracut in the image
wwctl image exec --build=false almalinux-10 -- /usr/bin/dnf install -y warewulf-ohpc-dracut \
ignition gdisk

## Configure Dracut. Note the leading and trailing spaces in the quotes in "add_dracutmodules"
echo 'hostonly="no"' > $CHROOT/etc/dracut.conf.d/wwinit.conf
echo 'add_dracutmodules+=" wwinit ignition "' >> $CHROOT/etc/dracut.conf.d/wwinit.conf

cat $CHROOT/etc/dracut.conf.d/wwinit.conf

## Build the Dracut initramfs
wwctl image exec --build=false almalinux-10 -- /usr/bin/dracut --force --regenerate-all

## Enable Dracut boot for compute nodes that use the "nodes" profile
wwctl profile set --yes nodes --tagadd IPXEMenuEntry=dracut
```

선택 사항으로, 계산 노드가 디스크에 프로비저닝하도록 설정합니다. (이 기능을 사용하려면) 이전 단계의 2단계 프로비저닝(Two-stage provisioning)도 반드시 활성화되어 있어야 합니다. 계산 노드는 노드 설정에 지정된 디스크를 사용하여 프로비저닝하며, 해당 디스크의 내용은 모두 지워집니다.
```bash

## Create the target "rootfs" partition and filesystem
## ${node_disk}에는 실제 장치명이 들어가야함.
### ex) /dev/sda , /dev/nvme01 ...
 wwctl profile set --yes nodes \
--diskname ${node_disk} --diskwipe \
--partname rootfs --partcreate --partnumber 1 \
--fsname rootfs --fswipe --fsformat ext4 --fspath /

## Enable provision-to-disk for compute nodes that use the "nodes" profile
wwctl profile set nodes --yes --root=/dev/disk/by-partlabel/rootfs
```

### ### 3.9.2  Build image image and overlays

```bash
wwctl image build almalinux-10
wwctl overlay build

wwctl overlay list --all
wwctl profile list --all
```

### ### 3.9.3 Register nodes for provisioning

#### #### Add new nodes to Warewulf data store
```bash
wwctl node add --image=almalinux-10 --profile=nodes --netname=default --ipaddr=10.1.1.1 --hwaddr=aa:bb:cc:dd:ee:ff node01

wwctl node list
```

#### #### Optionally define IPoIB network settings (required if planning to mount Lustre/BeeGFS over IB)
```bash
wwctl node set --yes node01 --netname=ib --netdev=ib0 --ipaddr=10.100.1.1 --netmask=255.255.255.0
```

# build the overlays for all the nodes
```bash
wwctl overlay build
wwctl configure --all

# Enable and start munge and slurmctld
systemctl enable --now munge
systemctl enable --now slurmctld
```

## ## [3.10 Boot compute nodes][contents]
### ### 노드를 부팅 한 후 o/s 가 설치 되는지 확인 하고 새 노드에 접속해 봅니다.

```bash
ping -c 4 node01

ssh node01

df -hT | grep -v tmpfs


# chrony가 동기화되었는지 확인
chronyc tracking
chronyc sources
chronyc sourcestats
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
dnf -y install  ohpc-autotools EasyBuild-ohpc hwloc-ohpc spack-ohpc valgrind-ohpc \
>> ~/dasan_log_ohpc_autotools,meta-package.txt 2>&1
tail -1 ~/dasan_log_ohpc_autotools,meta-package.txt
```

## ## 4.2 Compilers
```bash
dnf -y install  gnu15-compilers-ohpc >> ~/dasan_log_ohpc_Compilers.txt 2>&1
tail -1 ~/dasan_log_ohpc_Compilers.txt
```

## ## 4.3 MPI Stacks 
```bash
dnf -y install  openmpi5-pmix-gnu15-ohpc mpich-ofi-gnu15-ohpc mpich-ucx-gnu15-ohpc mvapich2-gnu15-ohpc --allowerasing >> ~/dasan_log_ohpc_MPI-Stacks.txt 2>&1
tail -1 ~/dasan_log_ohpc_MPI-Stacks.txt
```

## ## 4.4 Performance Tools
### ### Install perf-tools meta-package
```bash
dnf -y install ohpc-gnu15-perf-tools \
 >> ~/dasan_log_ohpc_perf-tools.txt 2>&1
tail -1 ~/dasan_log_ohpc_perf-tools.txt
```

## ## 4.5 Setup default development environment

```bash
dnf -y install  lmod-defaults-gnu15-openmpi5-ohpc  >> ~/dasan_log_ohpc_lmod.txt 2>&1
tail -1 ~/dasan_log_ohpc_lmod.txt
```

## ## 4.6 3rd Party Libraries and Tools
### ### Install 3rd party libraries/tools meta-packages built with GNU toolchain
```bash
dnf -y install  ohpc-gnu15-serial-libs ohpc-gnu15-io-libs ohpc-gnu15-python-libs ohpc-gnu15-runtimes \
     >> ~/dasan_log_ohpc_3rdPartyLib.txt 2>&1
tail -1 ~/dasan_log_ohpc_3rdPartyLib.txt
```

### ### Install parallel lib meta-packages for all available MPI toolchains
```bash
dnf -y install  ohpc-gnu15-mpich-parallel-libs ohpc-gnu15-openmpi5-parallel-libs \
  >> ~/dasan_log_ohpc_parallellib.txt 2>&1
tail -1 ~/dasan_log_ohpc_parallellib.txt
```

## ## 4.7 Optional Development Tool Builds

### ### Enable Intel oneAPI and install OpenHPC compatibility packages
```bash
dnf -y install intel-oneapi-toolkit-release-ohpc  >> ~/dasan_log_ohpc_inteloneapi.txt 2>&1

rpm --import https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB

dnf -y install intel-compilers-devel-ohpc intel-mpi-devel-ohpc \
  >> ~/dasan_log_ohpc_inteloneapi.txt 2>&1

tail -1 ~/dasan_log_ohpc_inteloneapi.txt
```

### ### Install 3rd party libraries/tools meta-packages built with Intel toolchain
```bash 
dnf -y install                     \
 openmpi5-pmix-intel-ohpc          \
 ohpc-intel-serial-libs            \
 #ohpc-intel-geopm                  \
 ohpc-intel-io-libs                \
 ohpc-intel-perf-tools             \
 ohpc-intel-python3-libs           \
 ohpc-intel-mpich-parallel-libs    \
 ohpc-intel-mvapich2-parallel-libs \
 ohpc-intel-openmpi5-parallel-libs \
 ohpc-intel-impi-parallel-libs     \
  >> ~/dasan_log_ohpc_inteloneapi_3rdparty.txt 2>&1

tail -1  ~/dasan_log_ohpc_inteloneapi_3rdparty.txt
```
### ### Fast way ;)  (use script)
```bash
cd ~
git clone https://github.com/dasandata/Open_HPC
cat ./Open_HPC/Provisioning/4_Install_OpenHPC_Development_Components_4.0.sh

bash ./Open_HPC/Provisioning/4_Install_OpenHPC_Development_Components_4.0.sh
```
***

***

# # [5. Resource Manager Startup][contents]

## slurm.conf 의 NodeName 및  PartitionName 정보 수정
```bash

cat /etc/slurm/slurm.conf | grep Oversubscribe

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
PidFile=/var/run/slurm/slurmdbd.pid
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

export INNODB_SIZE=2049M

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
mysql

 create user 'slurm'@'localhost' identified by 'slurmdbpass';
 grant all on slurm_acct_db.* TO 'slurm'@'localhost';
 create database slurm_acct_db;

 exit
```

```bash
ll /var/run/slurm  ## 없으면 생성

mkdir -p /var/run/slurm

chown slurm:slurm /var/run/slurm

ll -d /var/run/slurm
```

```bash
ll /var/log/slurmdbd.log ## 없으면 생성

touch /var/log/slurmdbd.log

chown slurm:slurm /var/log/slurmdbd.log

chmod 600 /var/log/slurmdbd.log

ll /var/log/slurmdbd.log
```

```bash
systemctl enable  slurmdbd
systemctl restart slurmdbd

mysql -u  slurm   -p    slurm_acct_db
# password => slurmdbpass

 select * from acct_table;

 exit
```

```bash
grep AccountingStorageType  /etc/slurm/slurm.conf

sed -i 's/^#AccountingStorageType=/AccountingStorageType=/' /etc/slurm/slurm.conf

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
###
cat /etc/slurm/slurm.conf | grep SlurmctldLogFile

ll /var/log/slurmctld.log  ## 없으면 생성

touch /var/log/slurmctld.log

ll /var/log/slurmctld.log

chown slurm:slurm /var/log/slurmctld.log

###
cat /etc/slurm/slurm.conf | grep SlurmdLogFile

ll /var/log/slurmd.log ## 없으면 생성

touch /var/log/slurmd.log

ll /var/log/slurmd.log

chown slurm:slurm /var/log/slurmd.log
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

## ## nvlink GPU 필수 package
```bash
dnf -y install --installroot ${CHROOT}   nvidia-fabric-manager cuda-drivers-fabricmanager nvidia-fabric-manager-devel   

chroot $CHROOT systemctl enable nvidia-fabricmanager
```

## ## gpustat (python3) install to VNFS
```bash
dnf -y  install --installroot=${CHROOT}  python3-devel python3-pip ncurses-devel  

chroot  ${CHROOT}

pip3 list
pip3 install --upgrade gpustat
pip3 -V
pip3 list | grep -i gpustat

exit

wwvnfs --chroot  ${CHROOT}

# gpustat  --force-color 
```

## ## CUDA 설치 (master only)
```bash
dnf -y install cuda-12-9   >> dasan_log_ohpc_cuda-master.txt 2>&1
tail dasan_log_ohpc_cuda-master.txt

ls -l /usr/local | grep cuda
```

```bash
mkdir /opt/ohpc/pub/apps/cuda/

for VER in  12.9
  do echo $VER
  mv /usr/local/cuda-$VER  /opt/ohpc/pub/apps/cuda/$VER
  done

ll /usr/local/ | grep cuda

ll /opt/ohpc/pub/apps/cuda/

# Local에 있는 심볼릭 링크 제거
rm -f /usr/local/cuda
rm -f /usr/local/cuda-12
```

## ## CUDNN to MASTER
```bash
mkdir /root/cudnn/
cd    /root/cudnn/

wget https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/linux-x86_64/cudnn-linux-x86_64-9.10.1.4_cuda12-archive.tar.xz

# 압축 해제 후 /opt/ohpc/pub/apps/cuda 아래로 이동.

VER=12.9
echo "CUDA-$VER"

tar -xvf cudnn-linux-x86_64-9.10.1.4_cuda12-archive.tar.xz

chmod a+r  cudnn-linux-x86_64-9.10.1.4_cuda12-archive/include/*
chmod a+r  cudnn-linux-x86_64-9.10.1.4_cuda12-archive/lib/*

mv  cudnn-linux-x86_64-9.10.1.4_cuda12-archive/include/cudnn.h  /opt/ohpc/pub/apps/cuda/$VER/include/
mv  cudnn-linux-x86_64-9.10.1.4_cuda12-archive/lib/libcudnn*    /opt/ohpc/pub/apps/cuda/$VER/lib64/

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

for CUDA_VERSION in 12.9
  do cp -a /root/Open_HPC/Module_Template/cuda.txt ${MODULES_DIR}/cuda/${CUDA_VERSION}
  sed -i "s/{version}/${CUDA_VERSION}/" ${MODULES_DIR}/cuda/${CUDA_VERSION}
done

ll /opt/ohpc/pub/modulefiles/cuda/

```

```bash
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

scontrol  update  nodename=gpu01 state=resume

sinfo

su - sonic

srun  --partition gpu --gres=gpu:1 --pty /bin/bash

echo $CUDA_VISIBLE_DEVICES

nvidia-smi

sinfo

squeue
```

```bash

conda activate pythorch

python -c "import torch; print(torch.cuda.is_available())"

```


***

# [END.][contents]
