
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
