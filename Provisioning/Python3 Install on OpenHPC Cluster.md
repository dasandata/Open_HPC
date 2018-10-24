# Python3 Install on OpenHPC Cluster
## # 기존에 OS에 설치된 Python3.4 제거
```bash
rpm -qa | grep python3

yum -y erase python34-*  >> dasan_log_uninstall_python34.txt 2>&1
tail dasan_log_uninstall_python34.txt
```

## # Pre installation package
```bash
yum -y install zlib-devel bzip2-devel sqlite sqlite-devel openssl-devel \
>> dasan_log_install_python-prepackage.txt 2>&1
tail dasan_log_install_python-prepackage.txt
```

## # Download Python 3.x.x
\# https://www.python.org/downloads/

```bash
PYTHON_VERSION=3.5.4  # 다운로드 및 설치할 받을 버젼명을 기재 합니다.

wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
tar  xvzf  Python-${PYTHON_VERSION}.tgz
```

## # Install Python3 via gnu5 Compiler
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
## # Download Module Template of Python
```bash
cd /root/
git clone https://github.com/dasandata/Open_HPC

cd /root/Open_HPC
git pull

cd
cat /root/Open_HPC/Module_Template/python3.txt
```

*output example>*
```
[root@master:~]# cat /root/Open_HPC/Module_Template/python3.txt
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

cp -a /root/Open_HPC/Module_Template/python3.txt  /opt/ohpc/pub/modulefiles/python3/${PYTHON_VERSION}
sed -i "s/{VERSION}/${PYTHON_VERSION}/"                  /opt/ohpc/pub/modulefiles/python3/${PYTHON_VERSION}
```


## # Refresh modules
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


## # Test of Python Module
```bash
[root@master:~]# ml list

Currently Loaded Modules:
  1) gnu/5.4.0

[root@master:~]# ml purge
[root@master:~]# ml list
No modules loaded
[root@master:~]#
[root@master:~]# which python3
/usr/bin/which: no python3 in (/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/dell/srvadmin/bin:/opt/dell/srvadmin/sbin:/root/bin)
[root@master:~]#

[root@master:~]# ml load python3
[root@master:~]# ml

Currently Loaded Modules:
  1) python3/3.x.x

[root@master:~]#
[root@master:~]# which python3
/opt/ohpc/pub/apps/python3/${PYTHON_VERSION}/bin/python3
[root@master:~]#
[root@master:~]# python3 -V
Python ${PYTHON_VERSION}
[root@master:~]#
[root@master:~]# which pip3
/opt/ohpc/pub/apps/python3/${PYTHON_VERSION}/bin/pip3
[root@master:~]#
[root@master:~]#
[root@master:~]# pip3  install --upgrade pip
Downloading/unpacking pip from https://files.pythonhosted.org/packages/c2/d7/90f34cb0d83a6c5631cf71dfe64cc1054598c843a92b400e55675cc2ac37/pip-18.1-py2.py3-none-any.whl#sha256=7909d0a0932e88ea53a7014dfd14522ffef91a464daaaf5c573343852ef98550
  Downloading pip-18.1-py2.py3-none-any.whl (1.3MB): 1.3MB downloaded
Installing collected packages: pip
  Found existing installation: pip 1.5.4
    Uninstalling pip:
      Successfully uninstalled pip
Successfully installed pip
Cleaning up...
[root@master:~]#
[root@master:~]# rm /opt/ohpc/pub/apps/python3/3.4.0/bin/pip
[root@master:~]# 
```

## # Default Load Module 설정 파일 2가지

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

# END.
