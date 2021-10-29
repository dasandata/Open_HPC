[0]: http://google.com
[1]: http://google.com
[2]: http://google.com
[3]: http://google.com
[4]: http://google.com
[5]: http://google.com
[6]: http://google.com
[7]: http://google.com
[8]: http://google.com
[contents]: http://google.com

# # [2) GPU Node Provisioning of OpenHPC Cluster][0]

## ## [1. 환경점검 및 사전 패키지 설치.][contents]
### ### Check dasan_ohpc_variable.sh
```bash
cat /root/dasan_ohpc_variable.sh

cat /root/.bashrc

echo ${CHROOT}
```

### ### Install libGLU.so libX11.so libXi.so libXmu.so to Master & VNFS
```bash
yum -y install libXi-devel mesa-libGLU-devel \
libXmu-devel libX11-devel freeglut-devel libXm* openmotif*  \
  >> dasan_log_ohpc_libGLU,libX-on-master.txt 2>&1
tail dasan_log_ohpc_libGLU,libX-on-master.txt
```

```bash
yum -y install --installroot ${CHROOT} libXi-devel mesa-libGLU-devel \
libXmu-devel libX11-devel freeglut-devel libXm*   openmotif*  \
 >> dasan_log_ohpc_libGLU,libX-on-node.txt 2>&1
tail dasan_log_ohpc_libGLU,libX-on-node.txt
```

### ### Install cuda-repo to Master & VNFS
```bash
yum -y install \
 http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-8.0.61-1.x86_64.rpm

yum -y install --installroot ${CHROOT} \
 http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-8.0.61-1.x86_64.rpm
```

## ## [2. Install NVIDIA Driver to VNFS][contents]
```bash
# Mount /dev on CHROOT
mount -o bind /dev  ${CHROOT}/dev
mount | grep ${CHROOT}

# Install gcc, make to VNFS
yum -y install --installroot ${CHROOT} gcc make \
>> dasan_log_ohpc_nvidia-driver-latest-vnfs.txt 2>&1
tail dasan_log_ohpc_nvidia-driver-latest-vnfs.txt

# Install nvidia-driver node VNFS
yum -y install --installroot ${CHROOT} nvidia-driver-latest \
>> dasan_log_ohpc_nvidia-driver-latest-vnfs.txt 2>&1
tail dasan_log_ohpc_nvidia-driver-latest-vnfs.txt

# umount /dev on CHROOT
umount  ${CHROOT}/dev
mount | grep ${CHROOT}

# Check to nvidia.ko module file maked to CHROOT
ll  ${CHROOT}/lib/modules/$(uname -r)/extra/nvidia.ko.xz

# enable nvidia-persistenced
chroot ${CHROOT}
systemctl enable  nvidia-persistenced
exit

wwvnfs --chroot  ${CHROOT}
wwsh vnfs list
```


## ## [3. Install cuda 8 ~ 11 to Master (NVIDIA Driver 포함)][contents]
```bash
yum -y install cuda-8-0 cuda-9-0 \
               cuda-10-0 cuda-10-1 cuda-10-2 \
               cuda-11-0 cuda-11-1 cuda-11-2 cuda-11-3 \
>> dasan_log_ohpc_cuda8-11-master.txt 2>&1
tail dasan_log_ohpc_cuda8-11-master.txt

ls -l /usr/local | grep cuda

```

### ### move cuda directory /usr/local to /opt/ohpc/pub/apps
```bash
mkdir /opt/ohpc/pub/apps/cuda/

for I in  8.0 9.0 10.0 10.1 10.2 11.0 11.1 11.2 11.3
  do echo $I
  mv /usr/local/cuda-$I  /opt/ohpc/pub/apps/cuda/$I
  done

ll /usr/local/ | grep cuda

ll /opt/ohpc/pub/apps/cuda/

# Local에 있는 심볼릭 링크 제거
rm -f /usr/local/cuda
rm -f /usr/local/cuda-11
```

## ## [4. multiple CUDNN to MASTER][contents]
```bash
mkdir /root/cudnn/
cd    /root/cudnn/

echo "cudnn-8.0-linux-x64-v7.1.tgz
cudnn-9.0-linux-x64-v7.6.5.32.tgz
cudnn-10.0-linux-x64-v7.6.5.32.tgz
cudnn-10.1-linux-x64-v7.6.5.32.tgz
cudnn-10.2-linux-x64-v7.6.5.32.tgz
cudnn-11.0-linux-x64-v8.0.2.39.tgz
cudnn-11.1-linux-x64-v8.0.5.39.tgz
cudnn-11.2-linux-x64-v8.1.1.33.tgz
cudnn-11.3-linux-x64-v8.2.1.32.tgz" > cudnn.txt

# copy cudnn from file server.
mount -t nfs  192.168.0.5:/file   /mnt
for I in $(cat cudnn.txt)
  do  cp  /mnt/12_NVIDIA_CUDNN/1_Linux/$I  /root/cudnn/
done
umount /mnt

# 압축 해제 후 /opt/ohpc/pub/apps/cuda 아래로 이동.
for I in $(cat cudnn.txt)
  do  echo "$I"
  VER=$(echo "$I" | cut -d '-' -f 2)
  tar -xzf $I

  chmod a+r  cuda/include/*
  chmod a+r  cuda/lib64/*

  mv  cuda/include/cudnn.h  /opt/ohpc/pub/apps/cuda/$VER/include/
  mv  cuda/lib64/libcudnn*  /opt/ohpc/pub/apps/cuda/$VER/lib64/

  rm -rf   cuda/
done

rm cudnn.txt
cd ~
```

### ### Add Multiple Cuda Module

```bash
# Download Module Template file of CUDA
cd /root/
git clone https://github.com/dasandata/Open_HPC

cd /root/Open_HPC/
git pull

# Add CUDA Module File by each version
mkdir -p /opt/ohpc/pub/modulefiles/cuda
MODULES_DIR="/opt/ohpc/pub/modulefiles"

for CUDA_VERSION in 8.0 9.0 10.0 10.1 10.2 11.0 11.1 11.2 11.3
  do cp -a /root/Open_HPC/Module_Template/cuda.txt ${MODULES_DIR}/cuda/${CUDA_VERSION}
  sed -i "s/{version}/${CUDA_VERSION}/" ${MODULES_DIR}/cuda/${CUDA_VERSION}
done

ll /opt/ohpc/pub/modulefiles/cuda/
```

### ### Refresh modules & Change Test.
```bash
rm -rf  ~/.lmod.d/.cache

module av | grep cuda

ml load cuda
nvcc -V

ml swap cuda/9.0
nvcc -V
```

## ## [5. gpustat (python3) install to VNFS][contents]

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



## ## [6. Insatll Docker to Master & VNFS of openhpc nodes.][contents]

### ### Install Docker
```bash
# Docker Install on master server.
yum-config-manager --add-repo \
   https://download.docker.com/linux/centos/docker-ce.repo

yum -y install docker-ce docker-ce-cli containerd.io

# Check selinx disable.
getenforce
grep  SELINUX= /etc/sysconfig/selinux

# Start & Enable Docker Daemon.
systemctl start  docker
systemctl enable docker

# Verify that Docker Engine running
docker run hello-world && docker images

# Docker Install on VNFS of OpenHPC Nodes.
cp  /etc/yum.repos.d/docker-ce.repo  ${CHROOT}/etc/yum.repos.d/
yum -y --installroot=${CHROOT}   install  docker-ce docker-ce-cli containerd.io


grep 'SELINUX=' ${CHROOT}/etc/sysconfig/selinux  
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' ${CHROOT}/etc/selinux/config
grep 'SELINUX=' ${CHROOT}/etc/sysconfig/selinux  

chroot ${CHROOT}  systemctl enable docker
wwsh file resync  # docker /etc/group sync.

```


### ### Install Nvidia Docker
```bash
# Nvidia-Docker Install on master server.
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo \
   | sudo tee /etc/yum.repos.d/nvidia-docker.repo

yum clean expire-cache
yum install -y nvidia-docker2
systemctl restart docker

docker run   --rm   --gpus all    nvidia/cuda:11.0-base    nvidia-smi

# Nvidia-Docker Install on VNFS of OpenHPC Nodes.
cp /etc/yum.repos.d/nvidia-docker.repo  ${CHROOT}/etc/yum.repos.d/
yum -y --installroot=${CHROOT}  install   nvidia-docker2
```

### ### Install Docker-Compose  

```bash
# Docker-Compose Install on master server
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose  /usr/bin/docker-compose

docker-compose --version

# docker-compose copy to VNFS
cp /usr/local/bin/docker-compose ${CHROOT}/usr/local/bin/

ll ${CHROOT}/usr/local/bin/

# vnfs image login
chroot ${CHROOT}
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

exit

wwvnfs --chroot  ${CHROOT}
```

### ### docker user add.
```bash
usermod -G docker sonic
cat /etc/group | grep -i docker
wwsh file resync

# user command
su - sonic
docker -v
docker images
```
### ### docker network IP 변경 방법
```bash
# BMM에 있는 docker network change 파일을 참조
```

## ## [7. gres.conf For Slurm Resource Manager.][contents]

### ### gres.conf 파일 생성 및 노드에 동기화  
```bash
# make gres.conf
cat << EOF > /etc/slurm/gres.conf
# This file location is /etc/slurm/gres.conf
# for Four GPU Set

Nodename=node01  Name=gpu  Type=GTX1080Ti  File=/dev/nvidia[0-3]

# End of File.
EOF

cat /etc/slurm/gres.conf

# slurm.conf 수정!
vi /etc/slurm/slurm.conf  # Gres 부분 설정 변경  

## file import, resync
wwsh file import /etc/slurm/gres.conf
wwsh file resync

wwsh provision list

wwsh provision set  -y  node01 --fileadd=gres.conf
pdsh -w node01  'rm -rf /tmp/.wwgetfile*  &&  /warewulf/bin/wwgetfiles'

wwsh file list
wwsh provision print  node01 | grep FILES

```
### ### slurm 서비스 재시작.
```bash
systemctl  restart  slurmctld

pdsh -w node01  'systemctl  restart  slurmd'

scontrol  update  nodename=node01 state=resume

scontrol  show  node

sinfo
```

## ## [8. GPU Job Test][contents]

```bash
su - sonic

git clone http://

srun  --gres=gpu:1 --pty /bin/bash

sinfo

squeue

echo $CUDA_VISIBLE_DEVICES
```

<추가 예정>


# END.
