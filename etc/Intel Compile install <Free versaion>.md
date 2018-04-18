## . Intel Compile install   < Free  versaion  >
```
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
```
