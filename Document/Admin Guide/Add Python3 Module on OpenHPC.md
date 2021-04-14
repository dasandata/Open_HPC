
### [4. Example to Add Python3 Module on OpenHPC][contents]
Python 3.5.x 을 Opeh_HPC 의 nfs 공유 디렉토리에 컴파일 하여 설치 하고,
모듈(module) 파일을 생성하여 node 에서 사용하는 방법 입니다.

#### 4-1. Module 명령어 사용 및 경로 확인
```
[root@Master:~]#
[root@Master:~]# module --version

Modules based on Lua: Version 7.7.14  2017-11-16 16:23 -07:00
    by Robert McLay mclay@tacc.utexas.edu

[root@Master:~]#
[root@Master:~]#
[root@Master:~]# ml --version

Modules based on Lua: Version 7.7.14  2017-11-16 16:23 -07:00
    by Robert McLay mclay@tacc.utexas.edu

[root@Master:~]#
[root@Master:~]# module list
No modules loaded
[root@Master:~]#
[root@Master:~]# ml list
No modules loaded
[root@Master:~]#

[root@Master:~]#
[root@Master:~]# ml av

-------------------------------------- /opt/ohpc/admin/modulefiles ---------------------------------------
   spack/0.11.2

--------------------------------------- /opt/ohpc/pub/modulefiles ----------------------------------------
   EasyBuild/3.5.3    cmake/3.10.2    gnu7/7.3.0      ohpc          prun/1.2             valgrind/3.13.0
   autotools          gnu/5.4.0       hwloc/1.11.9    papi/5.6.0    singularity/2.4.5

Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".

[root@Master:~]#
[root@Master:~]#
[root@Master:~]#
[root@Master:~]# ls -l /opt/ohpc/admin/modulefiles/
total 4
drwxr-xr-x 2 root root 4096 Apr 26 18:18 spack
[root@Master:~]#
[root@Master:~]# ls -l /opt/ohpc/pub/modulefiles/
total 44
-rw-r--r-- 1 root root  606 Nov  2  2017 autotools
drwxr-xr-x 2 root root 4096 Apr 26 16:50 cmake
drwxr-xr-x 2 root root 4096 Apr 26 18:18 EasyBuild
drwxr-xr-x 2 root root 4096 Apr 26 18:18 gnu
drwxr-xr-x 2 root root 4096 Apr 26 18:19 gnu7
drwxr-xr-x 2 root root 4096 Apr 26 18:18 hwloc
-rw-r--r-- 1 root root  754 Jun 15  2017 ohpc
drwxr-xr-x 2 root root 4096 Apr 26 18:20 papi
drwxr-xr-x 2 root root 4096 Apr 26 18:19 prun
drwxr-xr-x 2 root root 4096 Apr 26 18:22 singularity
drwxr-xr-x 2 root root 4096 Apr 26 18:18 valgrind
[root@Master:~]#
```


#### 4-2. Install Python 3.5
Python 다운받고 컴파일 하여 설치 합니다.

##### # 현재 파이썬 버젼 확인
```bash
[root@Master:~]# python3 -V
Python 3.4.8
[root@Master:~]#
[root@Master:~]# which python3
/bin/python3
[root@Master:~]#
```

##### # Pre installation package for python3 compile.
```
yum -y install zlib-devel bzip2-devel sqlite sqlite-devel openssl-devel
```

##### # Download & Install Python 3.5.4
```bash
cd /root
PYTHON_VERSION=3.5.4

wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz

tar  xvzf  Python-${PYTHON_VERSION}.tgz

cd ~/Python-${PYTHON_VERSION}

./configure --enable-optimizations --with-ensurepip=install --enable-shared \
--prefix=/opt/ohpc/pub/apps/python3/${PYTHON_VERSION}

make -j$(nproc) ; make install
```

##### # Add Python Module
```bash
cd /root
PYTHON_VERSION=3.5.4

git clone https://github.com/dasandata/Open_HPC
cd /root/Open_HPC
git pull

cat /root/Open_HPC/Module_Template/python3.txt
echo ${PYTHON_VERSION}

mkdir /opt/ohpc/pub/modulefiles/python3
cp -a /root/Open_HPC/Module_Template/python3.txt  /opt/ohpc/pub/modulefiles/python3/${PYTHON_VERSION}
sed -i "s/{VERSION}/${PYTHON_VERSION}/"                  /opt/ohpc/pub/modulefiles/python3/${PYTHON_VERSION}

cat /opt/ohpc/pub/modulefiles/python3/${PYTHON_VERSION}

rm -rf  ~/.lmod.d/.cache

ml list
ml av

ml load python3/${PYTHON_VERSION}
ml list

python3 -V
which python3
```
##### # Verification
node 에 사용자 계정으로 로그인 하여 python3.5.4 module load 해 봅니다.
```
[root@Master:~]# su - sonic
Last login: Wed May 30 11:17:51 KST 2018 from localhost on pts/4
[sonic@Master:~]$
[sonic@Master:~]$ ml list
No modules loaded
[sonic@Master:~]$
[sonic@Master:~]$ ml av

--------------------------------------- /opt/ohpc/pub/modulefiles ----------------------------------------
   EasyBuild/3.5.3    cmake/3.10.2    gnu7/7.3.0      ohpc          prun/1.2         singularity/2.4.5
   autotools          gnu/5.4.0       hwloc/1.11.9    papi/5.6.0    python3/3.5.4    valgrind/3.13.0

Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".


[sonic@Master:~]$
[sonic@Master:~]$
[sonic@Master:~]$ python3 -V
Python 3.4.8
[sonic@Master:~]$ which python3
/bin/python3
[sonic@Master:~]$
[sonic@Master:~]$ ml load python3/3.5.4
[sonic@Master:~]$
[sonic@Master:~]$ ml list

Currently Loaded Modules:
  1) python3/3.5.4

[sonic@Master:~]$
[sonic@Master:~]$ python3 -V
Python 3.5.4
[sonic@Master:~]$
[sonic@Master:~]$ which python3
/opt/ohpc/pub/apps/python3/3.5.4/bin/python3
[sonic@Master:~]$
[sonic@Master:~]$ pip3 -V
pip 9.0.1 from /opt/ohpc/pub/apps/python3/3.5.4/lib/python3.5/site-packages (python 3.5)
[sonic@Master:~]$
[sonic@Master:~]$
```
