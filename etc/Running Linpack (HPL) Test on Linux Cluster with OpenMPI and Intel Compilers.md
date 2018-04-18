
3. Running Linpack (HPL) Test on Linux Cluster with OpenMPI and Intel Compilers

 yum install  atlas  atlas-devel    blas  blas-devel  lapack lapack-devel
 wget   http://www.netlib.org/benchmark/hpl/hpl-2.2.tar.gz

  변경 합니다.

 tar xvzf hpl-2.2.tar.gz
 cd hpl-2.2/
 mv hpl-2.2 hpl
 cd hpl
 cp setup/Make.Linux_PII_CBLAS  .
 vi Make.Linux_PII_CBLAS

[root@master:hpl]# cat Make.Linux_PII_CBLAS | grep MPdir
# used. The variable MPdir is only used for defining MPinc and MPlib.
MPdir = /opt/ohpc/pub/mpi/openmpi-gnu/1.10.4
MPinc = -I$(MPdir)/include
MPlib = $(MPdir)/lib/libmpi.so

[root@master:hpl]# cat Make.Linux_PII_CBLAS | grep LAdir
# used. The variable LAdir is only used for defining LAinc and LAlib.
LAdir = /usr/lib64/atlas
LAlib = $(LAdir)/libtatlas.so $(LAdir)/libsatlas.so

[root@master:hpl]#
root@GIST-R740:ATLAS]# rpm -qa  | grep  atlas
atlas-3.10.1-12.el7.x86_64
[root@GIST-R740:ATLAS]#
[root@GIST-R740:ATLAS]#
[root@GIST-R740:ATLAS]# rpm -ql  atlas-3.10.1-12.el7.x86_64
/etc/ld.so.conf.d/atlas-x86_64.conf
/usr/lib64/atlas
/usr/lib64/atlas/libsatlas.so.3
/usr/lib64/atlas/libsatlas.so.3.10
/usr/lib64/atlas/libtatlas.so.3
/usr/lib64/atlas/libtatlas.so.3.10
/usr/share/doc/atlas-3.10.1
/usr/share/doc/atlas-3.10.1/README.dist
[root@GIST-R740:ATLAS]#


[root@hnode:hpl]# cat Make.Linux_PII_CBLAS | grep LINKER
LINKER = /usr/bin/gfortran

 #make arch=Linux_PII_CBLAS
 #cp bin/Linux_PII_CBLAS/xhpl       /home/dasan/
 #cp bin/Linux_PII_CBLAS/HPL.dat   /home/dasan/
 #chown dasan:dasan /home/dasan/xhpl
 #su - dasan
 #mpirun  --hostfile hosts  -np 48  ./xhpl    | tee -a hpl-test



[dasan@master:~]$ cat hpl | more
================================================================================
HPLinpack 2.2 -- High-Performance Linpack benchmark -- February 24, 2016
Written by A. Petitet and R. Clint Whaley, Innovative Computing Laboratory, UTK
Modified by Piotr Luszczek, Innovative Computing Laboratory, UTK
Modified by Julien Langou, University of Colorado Denver
================================================================================

An explanation of the input/output parameters follows:
T/V : Wall time / encoded variant.
N : The order of the coefficient matrix A.
NB : The partitioning blocking factor.
P : The number of process rows.
Q : The number of process columns.
Time : Time in seconds to solve the linear system.
Gflops : Rate of execution for solving the linear system.

The following parameter values will be used:

N : 29 30 34 35
NB : 1 2 3 4
PMAP : Row-major process mapping
P : 2 1 4
Q : 2 4 1
PFACT : Left Crout Right
NBMIN : 2 4
NDIV : 2
RFACT : Left Crout Right
BCAST : 1ring
DEPTH : 0
SWAP : Mix (threshold = 64)
L1 : transposed form
U : transposed form
EQUIL : yes
ALIGN : 8 double precision words

--------------------------------------------------------------------------------
```
- The matrix A is randomly generated for each test.
- The following scaled residual check will be computed:
  ||Ax-b||_oo / ( eps * ( || x ||_oo * || A ||_oo + || b ||_oo ) * N )
- The relative machine precision (eps) is taken to be 1.110223e-16
- Computational tests pass if scaled residuals are less than 16.0


--------------------------------------------------------------------------------
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)= 0.0207165 ...... PASSED
================================================================================
T/V N NB P Q Time  Gflops
--------------------------------------------------------------------------------
WR00R2R4 35 4 4 1 0.00  2.535e-01
HPL_pdgesv() start time Wed Mar 15 00:45:03 2017

HPL_pdgesv() end time Wed Mar 15 00:45:03 2017

--------------------------------------------------------------------------------
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)= 0.0207165 ...... PASSED
================================================================================

Finished 864 tests with the following results:
  864 tests completed and passed residual checks,
  0 tests completed and failed residual checks,
  0 tests skipped because of illegal input values.
--------------------------------------------------------------------------------

End of Tests.
================================================================================
[dasan@master:~]$
```
