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
yum -y install --installroot ${CHROOT} gcc, make \
>> dasan_log_ohpc_nvidia-driver-latest-vnfs.txt 2>&1
tail dasan_log_ohpc_nvidia-driver-latest-vnfs.txt

# Install nvidia-driver node VNFS
yum -y install --installroot ${CHROOT} nvidia-driver-latest \
>> dasan_log_ohpc_nvidia-driver-latest-vnfs.txt 2>&1
tail dasan_log_ohpc_nvidia-driver-latest-vnfs.txt

# umount /dev on CHROOT
umount  ${CHROOT}/dev
mount | grep ${CHROOT}

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

rm -f /usr/local/cuda
rm -f /usr/local/cuda-11
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


### ### Install Nvidia Docker to Master & VNFS of openhpc nodes.
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

wwvnfs --chroot  ${CHROOT}
```

### ### docker user
```bash
usermod -G docker sonic
cat /etc/group | grep -i docker
wwsh file resync

# user command
su - sonic
docker -v
docker images
```


## ## [7. gres.conf For Slurm Resource Manager.][contents]

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

GresTypes=gpu

NodeName=node[1-2] Procs=40 Sockets=2 CoresPerSocket=10 ThreadsPerCore=2 RealMemory=102400 State=UNKNOWN Gres=gpu:GTX1080Ti:4

PartitionName=cpu             Nodes=node[1-2] MaxTime=24:00:00 State=UP
PartitionName=gpu Default=YES Nodes=node[1-2] MaxTime=24:00:00 State=UP
```

***

\# /etc/slurm/gres.conf

```bash
# This file location is /etc/slurm/gres.conf
# for Four GPU Set

Nodename=node[1-2]  Name=gpu  Type=GTX1080Ti  File=/dev/nvidia[0-3]

# End of File.
```

***

```bash
wwsh file import /etc/slurm/gres.conf

wwsh file resync

wwvnfs --chroot ${CHROOT}

pdsh -w node01   wwgetfiles


systemctl  restart  slurmctld  # 새로 설정된 파일에 맞추어 마스터 서비스 재시작.

scontrol  update  nodename=node[1-2] state=resume

scontrol  show  node

sinfo

```


### # 54-8. slurm interactive job test
#### # cpu test   

```bash
# 인터렉티브 모드 진입전 queue 상태 와 환경변수 확인.
squeue
env  | grep  SLURM | tail
```

```bash
# 인터렉티브 모드로 진입.
srun  -N1  -n 10 --pty bash -i
```

```bash
# 인터렉티브 모드로 진입 후 queue 상태 와 환경변수 (env) 확인.
squeue  
env  | grep SLURM | tail
```

```bash
# 병렬작업 실행 (모드 진입시 설정한 cpu 수 [-n 값] 만큼 실행 됩니다.)
srun  hostname
srun  hostname | wc -l
```

```bash
# 인터렉티브 모드에서 빠져나와서  queue 상태 와 환경변수 (env) 확인.
exit
squeue  
env  | grep  SLURM | tail
```

***

#### # GPU Test   
\# gpu 테스트를 하는동안 모니터링 : ` watch -n 1 'squeue ; echo ; echo ; nvidia-smi --loop=1 ; echo ; echo' `

```bash
srun  --gres=gpu:1   --pty bash -i
squeue  

~/NVIDIA_CUDA-8.0_Samples/bin/x86_64/linux/release/deviceQuery | tail
python3  ~/TensorFlow-Examples/examples/5_DataManagement/tensorflow_dataset_api.py | tail

exit

srun  --gres=gpu:2   --pty bash -i
squeue  

/root/NVIDIA_CUDA-8.0_Samples/bin/x86_64/linux/release/deviceQuery | tail
python  /root/TensorFlow-Examples/examples/5_DataManagement/tensorflow_dataset_api.py | tail

exit
```




# END.
