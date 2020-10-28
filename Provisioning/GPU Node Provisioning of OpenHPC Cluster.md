# GPU Node Provisioning of OpenHPC Cluster

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
[root@master:~]# echo ${CHROOT}
/opt/ohpc/admin/images/centos7.4
[root@master:~]#
```


## # Install cuda-repo to Master
```bash
yum -y install \
 http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-8.0.61-1.x86_64.rpm \
 >> dasan_log_ohpc_cudarepo-on-master.txt
tail dasan_log_ohpc_cudarepo-on-master.txt

cat /etc/yum.repos.d/cuda.repo
```

## # Install cuda-repo to node vnfs images
```bash
yum -y install --installroot ${CHROOT} \
 http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-8.0.61-1.x86_64.rpm \
 >> dasan_log_ohpc_cudarepo-on-node.txt
tail dasan_log_ohpc_cudarepo-on-node.txt

cat ${CHROOT}/etc/yum.repos.d/cuda.repo

```
*output example>*
```bash
[root@master:~]# yum -y install --installroot ${CHROOT} \
> http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-8.0.61-1.x86_64.rpm \
> >> dasan_log_ohpc_cudarepo-on-node.txt
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

## # Check to available list cuda repo
```bash

yum --disablerepo="*" --enablerepo="cuda" list available

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
cuda-visual-tools-9-1.x86_64                     9.1.85-1                   cuda
gpu-deployment-kit.x86_64                        352.93-0                   cuda
nvidia-kmod.x86_64                               1:390.30-2.el7             cuda
nvidia-uvm-kmod.x86_64                           1:352.99-3.el7             cuda
xorg-x11-drv-nvidia.x86_64                       1:390.30-1.el7             cuda
xorg-x11-drv-nvidia-devel.x86_64                 1:390.30-1.el7             cuda
xorg-x11-drv-nvidia-diagnostic.x86_64            1:390.30-1.el7             cuda
xorg-x11-drv-nvidia-gl.x86_64                    1:390.30-1.el7             cuda
xorg-x11-drv-nvidia-libs.x86_64                  1:390.30-1.el7             cuda
[root@master:~]#
```


## # Install libGLU.so libX11.so libXi.so libXmu.so to Master
```bash
yum -y install libXi-devel mesa-libGLU-devel \
libXmu-devel libX11-devel freeglut-devel libXm*   openmotif*  \
  >> dasan_log_ohpc_libGLU,libX-on-master.txt
tail dasan_log_ohpc_libGLU,libX-on-master.txt
```


## # Install  libGLU.so libX11.so libXi.so libXmu.so to node vnfs images
```bash
yum -y install --installroot ${CHROOT} libXi-devel mesa-libGLU-devel \
libXmu-devel libX11-devel freeglut-devel libXm*   openmotif*  \
 >> dasan_log_ohpc_libGLU,libX-on-node.txt 2>&1
tail dasan_log_ohpc_libGLU,libX-on-node.txt
```

## # Mount /dev on CHROOT
```bash
mount -o bind /dev  ${CHROOT}/dev

mount | grep ${CHROOT}
```

## # Install cuda 8.0, 9.0 to Master
```bash
yum -y install cuda-8-0 cuda-9-0 \
>> dasan_log_ohpc_cuda8,9-master.txt 2>&1
tail dasan_log_ohpc_cuda8,9-master.txt
```

## # Install gcc, make to node nvfs images
```bash
yum -y install --installroot ${CHROOT} gcc, make \
>> dasan_log_ohpc_cuda8,9-node-vnfs.txt 2>&1
tail dasan_log_ohpc_cuda8,9-node-vnfs.txt
```

## # Install cuda 8.0, 9.0 to node vnfs images
```bash
yum -y install --installroot ${CHROOT} cuda-8-0 cuda-9-0 \
>> dasan_log_ohpc_cuda8,9-node-vnfs.txt 2>&1
tail dasan_log_ohpc_cuda8,9-node-vnfs.txt
```


## # Install Cudnn (for cuda 8.0) to Master  
\# 먼저 cudnn 압축파일을 ~/cudnn 에 다운로드 한 후 진행 합니다.

```
cd ~/cudnn
pwd
ls -l

tar xvzf cudnn-8.0-linux-x64-v5.0.tgz  
tar xvzf cudnn-8.0-linux-x64-v6.0.tgz   
tar xvzf cudnn-8.0-linux-x64-v7.0.tgz

ls -l cuda/include/
ls -l cuda/lib64/

chmod a+r  cuda/include/*
chmod a+r  cuda/lib64/*

mv  cuda/include/cudnn.h  /usr/local/cuda-8.0/include/
mv  cuda/lib64/libcudnn*  /usr/local/cuda-8.0/lib64/

cd
updatedb ; locate libcudnn.so
```

## # Install Cudnn (for cuda 9.0) to Master  

```
cd ~/cudnn9
pwd
ls -l

tar xvzf cudnn-9.0-linux-x64-v7.0.tgz

ls -l cuda/include/
ls -l cuda/lib64/

chmod a+r  cuda/include/*
chmod a+r  cuda/lib64/*

mv  cuda/include/cudnn.h  /usr/local/cuda-9.0/include/
mv  cuda/lib64/libcudnn*  /usr/local/cuda-9.0/lib64/

cd
```

## # multiple CUDNN to MASTER

```
echo "cudnn-8.0-linux-x64-v7.1.tgz"        > cudnn.txt
echo "cudnn-9.0-linux-x64-v7.6.5.32.tgz"  >> cudnn.txt
echo "cudnn-10.0-linux-x64-v7.6.5.32.tgz" >> cudnn.txt
echo "cudnn-10.1-linux-x64-v7.6.5.32.tgz" >> cudnn.txt
echo "cudnn-10.2-linux-x64-v7.6.5.32.tgz" >> cudnn.txt
echo "cudnn-11.0-linux-x64-v8.0.2.39.tgz" >> cudnn.txt

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
```

```
rm cudnn.txt
```


## # wwsh vnfs.con 파일을 아래와 같이 수정.
```bash
[root@master:~]# grep -n -v '^$\|^#' /etc/warewulf/vnfs.conf
15:gzip command = /usr/bin/pigz -9
26:cpio command = cpio --quiet -o -H newc
31:build directory = /var/tmp/
41:exclude += /tmp/*
42:exclude += /var/log/*
43:exclude += /var/chroots/*
44:exclude += /var/cache
45:exclude += /usr/src
46:exclude += /usr/local
68:hybridize += /usr/X11R6
72:hybridize += /usr/share/man
73:hybridize += /usr/share/doc
[root@master:~]#
```


## # /usr/local/ 을 NFS Service 에 추가.
```bash
echo "/usr/local *(ro,no_subtree_check)"  >> /etc/exports
systemctl restart nfs-server
exportfs

echo "${MASTER_HOSTNAME}:/usr/local /usr/local nfs nfsvers=3 0 0" >> ${CHROOT}/etc/fstab
```


## # Nvidia device enable on boot (/dev/nvidia*)

```bash
chroot /opt/ohpc/admin/images/centos7.4
```

```bash
vi  /etc/init.d/nvidia
```

```
#!/bin/bash
#
# nvidia    Set up NVIDIA GPU Compute Accelerators
#
# chkconfig: 2345 55 25
# description:    NVIDIA GPUs provide additional compute capability. \
#    This service sets the GPUs into the desired state.
#
# config: /etc/sysconfig/nvidia

### BEGIN INIT INFO
# Provides: nvidia
# Required-Start: $local_fs $network $syslog
# Required-Stop: $local_fs $syslog
# Should-Start: $syslog
# Should-Stop: $network $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Set GPUs into the desired state
# Description:    NVIDIA GPUs provide additional compute capability.
#    This service sets the GPUs into the desired state.
### END INIT INFO


################################################################################
######################## Microway Cluster Management Software (MCMS) for OpenHPC
################################################################################
#
# Copyright (c) 2015-2016 by Microway, Inc.
#
# This file is part of Microway Cluster Management Software (MCMS) for OpenHPC.
#
#    MCMS for OpenHPC is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    MCMS for OpenHPC is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with MCMS.  If not, see <http://www.gnu.org/licenses/>
#
################################################################################


# source function library
. /etc/rc.d/init.d/functions

# Some definitions to make the below more readable
NVSMI=/usr/bin/nvidia-smi
NVCONFIG=/etc/sysconfig/nvidia
prog="nvidia"

# default settings
NVIDIA_ACCOUNTING=1
NVIDIA_PERSISTENCE_MODE=1
NVIDIA_COMPUTE_MODE=0
NVIDIA_CLOCK_SPEEDS=max
# pull in sysconfig settings
[ -f $NVCONFIG ] && . $NVCONFIG

RETVAL=0


# Determine the maximum graphics and memory clock speeds for each GPU.
# Create an array of clock speed pairs (memory,graphics) to be passed to nvidia-smi
declare -a MAX_CLOCK_SPEEDS
get_max_clocks()
{
    GPU_QUERY="$NVSMI --query-gpu=clocks.max.memory,clocks.max.graphics --format=csv,noheader,nounits"

    MAX_CLOCK_SPEEDS=( $($GPU_QUERY | awk '{print $1 $2}') )
}


start()
{
    /sbin/lspci | grep -qi nvidia
    if [ $? -ne 0 ] ; then
        echo -n $"No NVIDIA GPUs present. Skipping NVIDIA GPU tuning."
        warning
        echo
        exit 0
    fi

    echo -n $"Starting $prog: "

    # If the nvidia-smi utility is missing, this script can't do its job
    [ -x $NVSMI ] || exit 5

    # A configuration file is not required
    if [ ! -f $NVCONFIG ] ; then
        echo -n $"No GPU config file present ($NVCONFIG) - using defaults"
        echo
    fi

    # Set persistence mode first to speed things up
    echo -n "persistence"
    $NVSMI --persistence-mode=$NVIDIA_PERSISTENCE_MODE 1> /dev/null
    RETVAL=$?

    if [ ! $RETVAL -gt 0 ]; then
        echo -n " accounting"
        $NVSMI --accounting-mode=$NVIDIA_ACCOUNTING 1> /dev/null
        RETVAL=$?
    fi

    if [ ! $RETVAL -gt 0 ]; then
        echo -n " compute"
        $NVSMI --compute-mode=$NVIDIA_COMPUTE_MODE 1> /dev/null
        RETVAL=$?
    fi


    if [ ! $RETVAL -gt 0 ]; then
        echo -n " clocks"
        if [ -n "$NVIDIA_CLOCK_SPEEDS" ]; then
            # If the requested clock speed value is "max",
            # work through each GPU and set to max speed.
            if [ "$NVIDIA_CLOCK_SPEEDS" == "max" ]; then
                get_max_clocks

                GPU_COUNTER=0
                GPUS_SKIPPED=0
                while [ "$GPU_COUNTER" -lt ${#MAX_CLOCK_SPEEDS[*]} ] && [ ! $RETVAL -gt 0 ]; do
                    if [[ ${MAX_CLOCK_SPEEDS[$GPU_COUNTER]} =~ Supported ]] ; then
                        if [ $GPUS_SKIPPED -eq 0 ] ; then
                            echo
                            GPUS_SKIPPED=1
                        fi
                        echo "Skipping non-boostable GPU"
                    else
                        $NVSMI -i $GPU_COUNTER --applications-clocks=${MAX_CLOCK_SPEEDS[$GPU_COUNTER]} 1> /dev/null
                    fi
                    RETVAL=$?

                    GPU_COUNTER=$(( $GPU_COUNTER + 1 ))
                done
            else
                # This sets all GPUs to the same clock speeds (which only works
                # if the GPUs in this system are all the same).
                $NVSMI --applications-clocks=$NVIDIA_CLOCK_SPEEDS 1> /dev/null
            fi
        else
            $NVSMI --reset-applications-clocks 1> /dev/null
        fi
        RETVAL=$?
    fi

    if [ ! $RETVAL -gt 0 ]; then
        if [ -n "$NVIDIA_POWER_LIMIT" ]; then
            echo -n " power-limit"
            $NVSMI --power-limit=$NVIDIA_POWER_LIMIT 1> /dev/null
            RETVAL=$?
        fi
    fi

    if [ ! $RETVAL -gt 0 ]; then
        success
    else
        failure
    fi
    echo
    return $RETVAL
}

stop()
{
    /sbin/lspci | grep -qi nvidia
    if [ $? -ne 0 ] ; then
        echo -n $"No NVIDIA GPUs present. Skipping NVIDIA GPU tuning."
        warning
        echo
        exit 0
    fi

    echo -n $"Stopping $prog: "
    [ -x $NVSMI ] || exit 5

    $NVSMI --persistence-mode=0 1> /dev/null && success || failure
    RETVAL=$?
    echo
    return $RETVAL
}

restart() {
    stop
    start
}

force_reload() {
    restart
}

status() {
    $NVSMI
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    force-reload)
        force_reload
        ;;
    status)
        status
        RETVAL=$?
        ;;
    *)
        echo $"Usage: $0 {start|stop|restart|force-reload|status}"
        RETVAL=2
esac
exit $RETVAL
```

```bash
chmod  +x   /etc/init.d/nvidia
```


***


```bash
vi    /lib/systemd/system/nvidia-gpu.service
```
```
[Unit]
Description=NVIDIA GPU Initialization
After=remote-fs.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/etc/init.d/nvidia start
ExecStop=/etc/init.d/nvidia stop

[Install]
WantedBy=multi-user.target
```

```bash
systemctl enable nvidia-gpu.service
```

```bash
exit

wwvnfs --chroot /opt/ohpc/admin/images/centos7.4
```

***


## # Update to Node nvfs image.
```bash
wwvnfs --chroot ${CHROOT}

wwsh vnfs list
```

## # UnMount /dev on CHROOT
```bash
umount ${CHROOT}/dev

mount | grep ${CHROOT}
```

## # Apply update imgae to nodes (rebooting)
```bash
ssh node1 reboot
```


## # Add Multiple Cuda Module for GPU Node
### # Download Module Template file of CUDA
```bash
cd /root
git clone https://github.com/dasandata/open_hpc

cd /root/open_hpc
git pull

mkdir -p /opt/ohpc/pub/modulefiles/cuda
cd
```


### # Add CUDA Module File by each version
```bash
for CUDA_VERSION in 8.0 9.0 ; do
cp -a ${GIT_CLONE_DIR}/Module_Template/cuda.lua ${MODULES_DIR}/cuda/${CUDA_VERSION}.lua ;
sed -i "s/{version}/${CUDA_VERSION}/" ${MODULES_DIR}/cuda/${CUDA_VERSION}.lua ;
done
```

### # Refresh modules
```bash
rm -rf  ~/.lmod.d/.cache

module av
```
*output example>*
```bash
------------------------ /opt/ohpc/pub/moduledeps/gnu7 -------------------------
   R/3.4.4         mpich/3.2.1            openmpi3/3.0.0      scotch/6.0.4
   gsl/2.4         mvapich2/2.2           pdtoolkit/3.25      superlu/5.2.1
   hdf5/1.10.1     ocr/1.0.1              plasma/2.8.0
   likwid/4.3.1    openblas/0.2.20        py2-numpy/1.14.2
   metis/5.1.0     openmpi/1.10.7  (L)    py3-numpy/1.14.2

------------------------- /opt/ohpc/admin/modulefiles --------------------------
   spack/0.11.2

-------------------------- /opt/ohpc/pub/modulefiles ---------------------------
   EasyBuild/3.5.3        gnu/5.4.0           pmix/2.1.1
   autotools       (L)    gnu7/7.3.0   (L)    prun/1.2          (L)
   cmake/3.10.2           hwloc/1.11.9        singularity/2.4.5
   cuda/8.0               ohpc         (L)    valgrind/3.13.0
   cuda/9.0        (D)    papi/5.6.0

  Where:
   D:  Default Module
   L:  Module is loaded

Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules matching
any of the "keys".
```
### # CUDA Sample Compile
\# 사용자 계정으로 / Master 에서 Sample 을 Compile
```bash
su - sonic
cd

pwd
whoami
```

\#샘플 컴파일시, gcc7 에서는 오류 발생  
```bash
module purge
module load gnu cuda/8.0

cd -r /usr/local/cuda-8.0/samples  ~/NVIDIA_CUDA-8.0_Samples

cd  ~/NVIDIA_CUDA-8.0_Samples
make -j $(nproc) >> dasan_log_cuda8.0_sample_compile.txt 2>&1
tail dasan_log_cuda8.0_sample_compile.txt

ssh node ~/NVIDIA_CUDA-8.0_Samples/1_Utilities/deviceQuery/deviceQuery
```


```bash
module purge
module load gnu cuda/9.0

cd -r /usr/local/cuda-9.0/samples  ~/NVIDIA_CUDA-9.0_Samples

cd  ~/NVIDIA_CUDA-9.0_Samples
make -j $(nproc) >> dasan_log_cuda9.0_sample_compile.txt 2>&1
tail dasan_log_cuda9.0_sample_compile.txt

ssh node ~/NVIDIA_CUDA-9.0_Samples/1_Utilities/deviceQuery/deviceQuery
```

## # Install Python 3.5.4 to Master

### # 기존에 OS에 설치된 Python3.4 제거
```bash
yum -y erase python34-*  >> dasan_log_uninstall_python34.txt 2>&1
tail dasan_log_uninstall_python34.txt
```

### # Pre installation package
```bash
yum -y install zlib-devel bzip2-devel sqlite sqlite-devel openssl-devel \
>> dasan_log_install_python-prepackage.txt 2>&1
tail dasan_log_install_python-prepackage.txt
```

### # Download Python 3.x.x
\# https://www.python.org/downloads/

```bash
PYTHON_VERSION=3.5.4  # 다운로드 및 설치할 받을 버젼명을 기재 합니다.

wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
tar  xvzf  Python-${PYTHON_VERSION}.tgz
```

### # Install Python3 via gnu5 Compiler
```bash
module purge
module load gnu
gcc --version

cd ~/Python-${PYTHON_VERSION}
./configure --enable-optimizations \
--with-ensurepip=install --enable-shared \
--prefix=/opt/ohpc/pub/apps/python3/${PYTHON_VERSION}

make -j$(nproc) ; make install

cd
```


## # Add Python Module
### # Download Module Template of Python
```bash
cd /root/
git clone https://github.com/dasandata/open_hpc

cd /root/open_hpc
git pull

cd
cat /root/open_hpc/Module_Template/python3.txt
```

*output example>*
```
[root@master:~]# cat /root/open_hpc/Module_Template/python3.txt
#%Module1.0

module-whatis "python"
module-whatis "Version: {VERSION}"

setenv PYTHONROOT             /opt/ohpc/pub/apps/python3/{VERSION}/

prepend-path PATH             /opt/ohpc/pub/apps/python3/{VERSION}/bin
prepend-path LD_LIBRARY_PATH  /opt/ohpc/pub/apps/python3/{VERSION}/lib
prepend-path LIBPATH          /opt/ohpc/pub/apps/python3/{VERSION}/lib
[root@master:~]#
```
***

```bash
mkdir /opt/ohpc/pub/modulefiles/python3

cp -a /root/open_hpc/Module_Template/python3.txt  /opt/ohpc/pub/modulefiles/python3/${PYTHON_VERSION}
sed -i "s/{VERSION}/${PYTHON_VERSION}/"                  /opt/ohpc/pub/modulefiles/python3/${PYTHON_VERSION}
```


### # Refresh modules
```bash
rm -rf  ~/.lmod.d/.cache

module av
```
*output example>*
```bash
[root@master:~]# module av

-------------------------------------------- /opt/ohpc/pub/moduledeps/gnu --------------------------------------------
   gsl/2.2.1      metis/5.1.0    mvapich2/2.2    ocr/1.0.1          openmpi/1.10.6
   hdf5/1.8.17    mpich/3.2      numpy/1.11.1    openblas/0.2.19    superlu/5.2.1

-------------------------------------------- /opt/ohpc/admin/modulefiles ---------------------------------------------
   spack/0.11.2

--------------------------------------------- /opt/ohpc/pub/modulefiles ----------------------------------------------
   EasyBuild/3.5.3    cuda/8.0  (L)    gnu7/7.3.0      papi/5.6.0    python3/${PYTHON_VERSION}
   autotools          cuda/9.0  (D)    hwloc/1.11.9    pmix/2.1.1    singularity/2.4.5
   cmake/3.10.2       gnu/5.4.0 (L)    ohpc            prun/1.2      valgrind/3.13.0

  Where:
   D:  Default Module
   L:  Module is loaded

Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".

[root@master:~]#
```


### # Test of Python Module
```bash
[root@master:~]# ml purge
[root@master:~]# ml list
No modules loaded
[root@master:~]#
[root@master:~]# which python3
/usr/bin/which: no python3 in (/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/dell/srvadmin/bin:/opt/dell/srvadmin/sbin:/root/bin)
[root@master:~]#
[root@master:~]# ml load python3
[root@master:~]#
[root@master:~]# which python3
/opt/ohpc/pub/apps/python3/${PYTHON_VERSION}/bin/python3
[root@master:~]#
[root@master:~]# python3 -V
Python ${PYTHON_VERSION}
[root@master:~]#
```

### # Defaule Module 설정 파일 2가지

\# /etc/profile.d/lmod.sh
```
[root@master:~]# cat /etc/profile.d/lmod.sh
#!/bin/sh
# -*- shell-script -*-
########################################################################
#  This is the system wide source file for setting up
#  modules:
#
########################################################################

# NOOP if running under known resource manager
if [ ! -z "$SLURM_NODELIST" ];then
     return
fi

if [ ! -z "$PBS_NODEFILE" ];then
    return
fi

export LMOD_SETTARG_CMD=":"
export LMOD_FULL_SETTARG_SUPPORT=no
export LMOD_COLORIZE=no
export LMOD_PREPEND_BLOCK=normal

if [ $EUID -eq 0 ]; then
    export MODULEPATH=/opt/ohpc/admin/modulefiles:/opt/ohpc/pub/modulefiles
else
    export MODULEPATH=/opt/ohpc/pub/modulefiles
fi

export BASH_ENV=/opt/ohpc/admin/lmod/lmod/init/bash

# Initialize modules system
. /opt/ohpc/admin/lmod/lmod/init/bash >/dev/null

# Load baseline OpenHPC environment
module try-add ohpc

[root@master:~]#
[root@master:~]#
```

***

\# /opt/ohpc/pub/modulefiles/ohpc
```
[root@master:~]# cat /opt/ohpc/pub/modulefiles/ohpc
#%Module1.0#####################################################################
# Default OpenHPC environment
#############################################################################

proc ModulesHelp { } {
puts stderr "Setup default login environment"
}

#
# Load Desired Modules
#

prepend-path     PATH   /opt/ohpc/pub/bin

if { [ expr [module-info mode load] || [module-info mode display] ] } {
        prepend-path MANPATH /usr/local/share/man:/usr/share/man/overrides:/usr/share/man/en:/usr/share/man
	module try-add cuda/8.0
	module try-add gnu
        module try-add python3/3.5.4-tf1.4
}

if [ module-info mode remove ] {
        module del python3/3.5.4-tf1.4
        module del gnu
        module del cuda/8.0
}
[root@master:~]#
```

```
[root@master:~]# module lsit

Currently Loaded Modules:
  1) cuda/8.0   2) gnu/5.4.0   3) python3/3.5.4-tf1.4   4) ohpc

[root@master:~]#
```


## # Install multiple versions of TensorFlow

컴파일된 파이썬 폴더 와 모듈파일을 복사한 후 텐서플로우 버젼을 표시.  

```bash
ml av | grep python3

PYTHON_VERSION=3.5.4  # 기타, 기존 설치된 버젼으로 변경.
TENSOR_VERSION=1.4    # or 1.6

cp -r /opt/ohpc/pub/apps/python3/${PYTHON_VERSION}  /opt/ohpc/pub/apps/python3/${PYTHON_VERSION}-tf${TENSOR_VERSION}
cp    /opt/ohpc/pub/modulefiles/python3/${PYTHON_VERSION}  /opt/ohpc/pub/modulefiles/python3/${PYTHON_VERSION}-tf${TENSOR_VERSION}

sed -i "s/${PYTHON_VERSION}/${PYTHON_VERSION}-tf${TENSOR_VERSION}/" /opt/ohpc/pub/modulefiles/python3/${PYTHON_VERSION}-tf${TENSOR_VERSION}
sed -i "s/${PYTHON_VERSION}/${PYTHON_VERSION}-tf${TENSOR_VERSION}/" /opt/ohpc/pub/apps/python3/${PYTHON_VERSION}-tf${TENSOR_VERSION}/bin/pip3
```

```bash
rm -rf  ~/.lmod.d/.cache
module av
ml load python3/${PYTHON_VERSION}-tf${TENSOR_VERSION}
```

```bash
pip3 install tensorflow-gpu==${TENSOR_VERSION}
pip3 list | grep tensorflow
```

***

## # slurm.conf & gres.conf For Slurm Resource Manager.

\# /etc/slurm/slurm.conf
```
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
PrologFlags=x11

ClusterName=OpenHPC_dasandata
ControlMachine=ohpc-master

GresTypes=gpu

NodeName=node[1-2] Procs=40 Sockets=2 CoresPerSocket=10 ThreadsPerCore=2 RealMemory=102400 State=UNKNOWN Gres=gpu:GTX1080Ti:4

PartitionName=cpu             Nodes=node[1-2] MaxTime=24:00:00 State=UP
PartitionName=gpu Default=YES Nodes=node[1-2] MaxTime=24:00:00 State=UP
```

\# /etc/slurm/gres.conf
```
# This file location is /etc/slurm/gres.conf
# for Four GPU Set

Nodename=node[1-2]  Name=gpu  Type=GTX1080Ti  File=/dev/nvidia[0-3]

# End of File.
```

***

```bash
wwsh file import /etc/slurm/gres.conf
wwsh file import /etc/slurm/slurm.conf

wwsh file resync

wwvnfs --chroot /opt/ohpc/admin/images/centos7.4  

pdsh -w node[1-2] reboot
```

***

```bash
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

### # 54-9. batch job test

##### # Copy of Batch Scripts Samples

```bash
cp -r /root/LISR/Ubuntu16/Slurm/SLURM_SBATCH_TEST/   /root/
cd /root/SLURM_SBATCH_TEST

```

#### # CPU Batch Job
```bash
cat test-sbatch-cpu.sh

sbatch test-sbatch-cpu.sh
sbatch test-sbatch-cpu.sh
sbatch test-sbatch-cpu.sh
sbatch test-sbatch-cpu.sh
sbatch test-sbatch-cpu.sh

sinfo
squeue
```

```bash
ls -ltr

cat $(ls -tr | tail -1)
```

#### # GPU batch job  
\# gpu 테스트를 하는동안 모니터링 : `watch 'squeue ; echo ; echo ; nvidia-smi -l ; echo ; echo '`

##### # nbody batch job (1GPU)    
```bash
cat test-sbatch-nbody.sh

sbatch  test-sbatch-nbody.sh
sbatch  test-sbatch-nbody.sh
sbatch  test-sbatch-nbody.sh
sbatch  test-sbatch-nbody.sh
sbatch  test-sbatch-nbody.sh

sinfo
squeue
```

```bash
ls -ltr

tail $(ls -tr | tail -1)
```

##### # nbody batch job (2GPU)    
```bash
cat test-sbatch-nbody-2GPU.sh

sbatch  test-sbatch-nbody-2GPU.sh
sbatch  test-sbatch-nbody-2GPU.sh
sbatch  test-sbatch-nbody-2GPU.sh
sbatch  test-sbatch-nbody-2GPU.sh
sbatch  test-sbatch-nbody-2GPU.sh

sinfo
squeue
```

```bash
ls -ltr

tail $(ls -tr | tail -1)
```

##### # Tensor flow Test (1GPU)  

```bash
cat test-sbatch-tensorflow.sh

sbatch  test-sbatch-tensorflow.sh
sbatch  test-sbatch-tensorflow.sh
sbatch  test-sbatch-tensorflow.sh
sbatch  test-sbatch-tensorflow.sh
sbatch  test-sbatch-tensorflow.sh

sinfo
squeue
```

```bash
ls -ltr

tail $(ls -tr | tail -1)
```

##### # Tensor flow Test (2GPU)  

```bash
cat test-sbatch-tensorflow-2GPU.sh

sbatch  test-sbatch-tensorflow-2GPU.sh
sbatch  test-sbatch-tensorflow-2GPU.sh
sbatch  test-sbatch-tensorflow-2GPU.sh
sbatch  test-sbatch-tensorflow-2GPU.sh
sbatch  test-sbatch-tensorflow-2GPU.sh

sinfo
squeue
```

```bash
ls -ltr

tail $(ls -tr | tail -1)
```




# END.
