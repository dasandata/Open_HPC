# Install VASP on OpenHPC. (VASP 5.4.1 Compile with gfortran + openmpi)
참조 링크 : https://cms.mpi.univie.ac.at/wiki/index.php/Installing_VASP
2019-04 dasandata.

## Requirements.
For the compilation of the parallel version of VASP the following software is mandatory:
- Fortran and C compilers.
- An implementation of MPI (Message Passing Interface).
- Numerical libraries like BLAS, LAPACK, ScaLAPACK, and FFTW.

### Requirements 중, fortran and C compilers, ScaLAPACK, MPI 는 OpenHPC 에 포함된 버젼을 사용.
#### fortran and C compilers (7.3.0)
```
[root@ohpc-master:~]# module whatis gnu7
gnu7/7.3.0          : Name: GNU Compiler Collection
gnu7/7.3.0          : Version: 7.3.0
gnu7/7.3.0          : Category: compiler, runtime support
gnu7/7.3.0          : Description: GNU Compiler Family (C/C++/Fortran for x86_64)
gnu7/7.3.0          : URL: http://gcc.gnu.org/

[root@ohpc-master:~]#
[root@ohpc-master:~]# ml show gnu7
----------------------------------------------------------------------------
   /opt/ohpc/pub/modulefiles/gnu7/7.3.0:
----------------------------------------------------------------------------
whatis("Name: GNU Compiler Collection ")
whatis("Version: 7.3.0 ")
whatis("Category: compiler, runtime support ")
whatis("Description: GNU Compiler Family (C/C++/Fortran for x86_64) ")
whatis("URL: http://gcc.gnu.org/ ")
prepend_path("PATH","/opt/ohpc/pub/compiler/gcc/7.3.0/bin")
prepend_path("MANPATH","/opt/ohpc/pub/compiler/gcc/7.3.0/share/man")
prepend_path("INCLUDE","/opt/ohpc/pub/compiler/gcc/7.3.0/include")
prepend_path("LD_LIBRARY_PATH","/opt/ohpc/pub/compiler/gcc/7.3.0/lib64")
prepend_path("MODULEPATH","/opt/ohpc/pub/moduledeps/gnu7")
family("compiler")
help([[
This module loads the GNU compiler collection

See the man pages for gcc, g++, and gfortran for detailed information
on available compiler options and command-line syntax.


Version 7.3.0

]])

[root@ohpc-master:~]#
[root@ohpc-master:~]# which gcc
/opt/ohpc/pub/compiler/gcc/7.3.0/bin/gcc
[root@ohpc-master:~]#
[root@ohpc-master:~]# which gfortran
/opt/ohpc/pub/compiler/gcc/7.3.0/bin/gfortran
```

#### scalapack 2.0.2
```
[root@ohpc-master:~]# module whatis scalapack
scalapack/2.0.2     : Name: scalapack built with gnu7 compiler and openmpi MPI
scalapack/2.0.2     : Version: 2.0.2
scalapack/2.0.2     : Category: runtime library
scalapack/2.0.2     : Description: A subset of LAPACK routines redesigned for heterogenous computing
scalapack/2.0.2     : http://www.netlib.org/lapack-dev/

[root@ohpc-master:~]#
[root@ohpc-master:~]# ml show scalapack
----------------------------------------------------------------------------
   /opt/ohpc/pub/moduledeps/gnu7-openmpi/scalapack/2.0.2:
----------------------------------------------------------------------------
whatis("Name: scalapack built with gnu7 compiler and openmpi MPI ")
whatis("Version: 2.0.2 ")
whatis("Category: runtime library ")
whatis("Description: A subset of LAPACK routines redesigned for heterogenous computing ")
whatis("http://www.netlib.org/lapack-dev/ ")
depends_on("openblas")
prepend_path("LD_LIBRARY_PATH","/opt/ohpc/pub/libs/gnu7/openmpi/scalapack/2.0.2/lib")
setenv("SCALAPACK_DIR","/opt/ohpc/pub/libs/gnu7/openmpi/scalapack/2.0.2")
setenv("SCALAPACK_LIB","/opt/ohpc/pub/libs/gnu7/openmpi/scalapack/2.0.2/lib")
help([[
This module loads the ScaLAPACK library built with the gnu7 compiler
toolchain and the openmpi MPI stack.


Version 2.0.2

]])

[root@ohpc-master:~]#
```

#### openmpi built with gnu7 (1.10.7)
```
[root@ohpc-master:~]# module whatis openmpi
openmpi/1.10.7      : Name: openmpi built with gnu7 toolchain
openmpi/1.10.7      : Version: 1.10.7
openmpi/1.10.7      : Category: runtime library
openmpi/1.10.7      : Description: A powerful implementation of MPI
openmpi/1.10.7      : URL: http://www.open-mpi.org

[root@ohpc-master:~]#
[root@ohpc-master:~]# module show openmpi
----------------------------------------------------------------------------
   /opt/ohpc/pub/moduledeps/gnu7/openmpi/1.10.7:
----------------------------------------------------------------------------
whatis("Name: openmpi built with gnu7 toolchain ")
whatis("Version: 1.10.7 ")
whatis("Category: runtime library ")
whatis("Description: A powerful implementation of MPI ")
whatis("URL: http://www.open-mpi.org ")
setenv("MPI_DIR","/opt/ohpc/pub/mpi/openmpi-gnu7/1.10.7")
prepend_path("PATH","/opt/ohpc/pub/mpi/openmpi-gnu7/1.10.7/bin")
prepend_path("MANPATH","/opt/ohpc/pub/mpi/openmpi-gnu7/1.10.7/man")
prepend_path("LD_LIBRARY_PATH","/opt/ohpc/pub/mpi/openmpi-gnu7/1.10.7/lib")
prepend_path("MODULEPATH","/opt/ohpc/pub/moduledeps/gnu7-openmpi")
prepend_path("PKG_CONFIG_PATH","/opt/ohpc/pub/mpi/openmpi-gnu7/1.10.7/lib/pkgconfig")
family("MPI")
help([[
This module loads the openmpi library built with the gnu7 toolchain.

Version 1.10.7

]])

[root@ohpc-master:~]#
[root@ohpc-master:~]# which mpirun
/opt/ohpc/pub/mpi/openmpi-gnu7/1.10.7/bin/mpirun
[root@ohpc-master:~]#
```

### Requirements 중 BLAS, LAPACK, FFTW 은 build 하여 사용.


#### BLAS 3.8.0
```bash
cd ~Downloads
wget  http://www.netlib.org/blas/blas-3.8.0.tgz
tar xvzf blas-3.8.0.tgz
cd BLAS-3.8.0/

# build libblas.so
gfortran -shared  -O2  *.f  -o libblas.so  -fPIC  

# build libblas.a
gfortran -O2 -c *.f
ar cr libblas.a *.o

ll -tr *.so *.a
```

```  
[root@ohpc-master:BLAS-3.8.0]# ll -tr *.so *.a
-rwxr-xr-x 1 root root 350K Apr 17 11:45 libblas.so
-rw-r--r-- 1 root root 597K Apr 17 11:47 libblas.a
[root@ohpc-master:BLAS-3.8.0]#
```

##### Module make for blas 3.8.0
```bash
# file copy.
mkdir -p /opt/ohpc/pub/libs/gnu7/blas/3.8.0/
cp  libblas*  /opt/ohpc/pub/libs/gnu7/blas/3.8.0/


# make module file.
mkdir -p /opt/ohpc/pub/moduledeps/gnu7/blas/

echo '#%Module1.0#####################################################################

proc ModulesHelp { } {

puts stderr " "
puts stderr "This module loads the BLAS (Basic Linear Algebra Subprograms) library built with the gnu7 compiler"
puts stderr "\nVersion 3.8.0\n"

}
module-whatis "Name: blas built with gnu7 compiler"
module-whatis "Version: 3.8.0"
module-whatis "Category: runtime library"
module-whatis "Description: BLAS (Basic Linear Algebra Subprograms)"
module-whatis "URL http://www.netlib.org/blas/"

set     version      3.8.0

prepend-path    LD_LIBRARY_PATH    /opt/ohpc/pub/libs/gnu7/blas/3.8.0/

setenv          FFTW_LIB           /opt/ohpc/pub/libs/gnu7/blas/3.8.0/

' > /opt/ohpc/pub/moduledeps/gnu7/blas/3.8.0

# module reload
rm -rf ~/.lmod.d/
module av | grep blas/3.8.0

module whatis blas/3.8.0
module show blas/3.8.0

```

#### LAPACK 3.8.0

```bash
cd ~Downloads
wget  wget http://www.netlib.org/lapack/lapack-3.8.0.tar.gz
tar xvzf lapack-3.8.0.tar.gz
cd lapack-3.8.0/

# build liblapack.a, librefblas.a, libtmglib.a
cp INSTALL/make.inc.gfortran  make.inc
make

ll -tr *.a
```

```  
[root@ohpc-master:lapack-3.8.0]# ll -tr *.a
-rw-r--r-- 1 root root  12M Apr 17 14:34 liblapack.a
-rw-r--r-- 1 root root 605K Apr 17 14:34 libtmglib.a
-rw-r--r-- 1 root root 597K Apr 17 14:34 librefblas.a
[root@ohpc-master:lapack-3.8.0]#
```

##### Module make for lapack 3.8.0
```bash
# file copy.
mkdir -p /opt/ohpc/pub/libs/gnu7/openmpi/lapack/3.8.0/
cp  *.a  /opt/ohpc/pub/libs/gnu7/openmpi/lapack/3.8.0/


# make module file.
mkdir -p /opt/ohpc/pub/moduledeps/gnu7-openmpi/lapack/

echo '#%Module1.0#####################################################################

proc ModulesHelp { } {

puts stderr " "
puts stderr "This module loads the LAPACK (Linear Algebra PACKage) library built with the gnu7 compiler"
puts stderr "\nVersion 3.8.0\n"

}
module-whatis "Name: lapack built with gnu7 compiler"
module-whatis "Version: 3.8.0"
module-whatis "Category: runtime library"
module-whatis "Description: LAPACK (Linear Algebra PACKage)"
module-whatis "URL http://www.netlib.org/lapack/"

set     version      3.8.0

prepend-path    LD_LIBRARY_PATH   /opt/ohpc/pub/libs/gnu7/openmpi/lapack/3.8.0/

setenv          FFTW_LIB          /opt/ohpc/pub/libs/gnu7/openmpi/lapack/3.8.0/

' > /opt/ohpc/pub/moduledeps/gnu7-openmpi/lapack/3.8.0

# module reload
rm -rf ~/.lmod.d/
module av | grep lapack/3.8.0

module whatis lapack/3.8.0
module show lapack/3.8.0

```

#### FFTW 3.3.8

```bash
cd ~Downloads
wget http://www.fftw.org/fftw-3.3.8.tar.gz
tar xvzf fftw-3.3.8.tar.gz
cd fftw-3.3.8/

# build fftw
./configure  --prefix=/opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/
make -j8
make install

ll /opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/
```

```  
[root@ohpc-master:fftw-3.3.8]# ll /opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/
total 0
drwxr-xr-x 2 root root 52 Apr 17 16:18 bin
drwxr-xr-x 2 root root 89 Apr 17 16:18 include
drwxr-xr-x 4 root root 73 Apr 17 16:18 lib
drwxr-xr-x 4 root root 29 Apr 17 16:18 share
[root@ohpc-master:fftw-3.3.8]#
```

##### Module make for fftw 3.3.8
```bash
# file copy.
mkdir -p /opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/
cp  *.a  /opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/


# make module file.
mkdir -p /opt/ohpc/pub/moduledeps/gnu7-openmpi/fftw/

echo '#%Module1.0#####################################################################

proc ModulesHelp { } {

puts stderr " "
puts stderr "This module loads the fftw library built with the gnu7 compiler"
puts stderr "toolchain and the openmpi MPI stack."
puts stderr "\nVersion 3.3.8\n"

}
module-whatis "Name: fftw built with gnu7 compiler and openmpi MPI"
module-whatis "Version: 3.3.8"
module-whatis "Category: runtime library"
module-whatis "Description: A Fast Fourier Transform library"
module-whatis "URL http://www.fftw.org"

set     version    3.3.8

prepend-path    PATH                /opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/bin
prepend-path    MANPATH             /opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/share/man
prepend-path    INCLUDE             /opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/include
prepend-path    LD_LIBRARY_PATH     /opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/lib

setenv          FFTW_DIR        /opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8
setenv          FFTW_LIB        /opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/lib
setenv          FFTW_INC        /opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/include

' > /opt/ohpc/pub/moduledeps/gnu7-openmpi/fftw/3.3.8

# module reload
rm -rf ~/.lmod.d/
module av | grep fftw/3.3.8

module whatis fftw/3.3.8
module show fftw/3.3.8

```

## vasp compile


### 준비된 파일.
- vasp.5.4.1.05Feb16.tar.gz
- patch.5.4.1.14032016.gz
- patch.5.4.1.03082016.gz


### 압축해제, patch 적용.
```bash
tar xvzf vasp.5.4.1.05Feb16.tar.gz

gunzip  patch.5.4.1.*
cp patch.5.4.1.*  vasp.5.4.1/

cd vasp.5.4.1/

ll
```

```
[root@ohpc-master:vasp.5.4.1]# ll
total 60K
drwxr-xr-x 2  521 users  165 Feb  8  2016 arch
drwxr-xr-x 2  521 users    6 Feb  8  2016 bin
drwxr-xr-x 2  521 users    6 Feb  8  2016 build
-rw-r--r-- 1  521 users  371 Feb  8  2016 makefile
-rw-r--r-- 1 root root   24K Apr 17 21:06 patch.5.4.1.03082016
-rw-r--r-- 1 root root  6.5K Apr 17 21:06 patch.5.4.1.14032016
-rw-r--r-- 1  521 users  12K Feb  9  2016 README
drwxr-xr-x 4  521 users 8.0K Feb  8  2016 src
[root@ohpc-master:vasp.5.4.1]#
```

### 오래된 패치 파일부터 적용.
```bash
patch -p0 < patch.5.4.1.14032016

patch -p0 < patch.5.4.1.03082016

```

```
[root@ohpc-master:vasp.5.4.1]# patch -p0 < patch.5.4.1.14032016
patching file src/chi.F
patching file src/CUDA/cuda_main.cu
patching file src/lib/makefile
patching file src/main.F
patching file src/makefile
patching file src/.objects
[root@ohpc-master:vasp.5.4.1]#
[root@ohpc-master:vasp.5.4.1]# patch -p0 < patch.5.4.1.03082016
patching file ./arch/makefile.include.linux_gfortran
patching file ./arch/makefile.include.linux_intel
patching file ./arch/makefile.include.linux_intel_cuda
patching file ./arch/makefile.include.linux_intel_serial
patching file ./src/fock.F
patching file ./src/linear_optics.F
patching file ./src/linear_response_NMR.F
patching file ./src/nonl.F
patching file ./src/pead.F
patching file ./src/pseudo.F
patching file ./src/relativistic.F
patching file ./src/tutor.F
[root@ohpc-master:vasp.5.4.1]#
```

### makefile.include 수정.
```bash
cp arch/makefile.include.linux_gfortran  makefile.include

vi makefile.include
```
#### 아래 내용 참조하여 수정.
```
[root@ohpc-master:vasp.5.4.1]# cat arch/makefile.include.linux_gfortran
# Precompiler options
CPP_OPTIONS= -DMPI -DHOST=\"IFC91_ompi\" -DIFC \
             -DCACHE_SIZE=4000 -Davoidalloc \
             -DMPI_BLOCK=8000 -DscaLAPACK -Duse_collective \
             -Duse_bse_te -Duse_shmem -Dtbdyn

CPP        = gcc -E -P -C $*$(FUFFIX) >$*$(SUFFIX) $(CPP_OPTIONS)

FC         = mpif90
FCL        = mpif90

FREE       = -ffree-form -ffree-line-length-none

FFLAGS     =
OFLAG      = -O2
OFLAG_IN   = $(OFLAG)
DEBUG      = -O0

LIBDIR     = /data1/gf01/libs/
BLAS       = -L$(LIBDIR) -lrefblas
LAPACK     = -L$(LIBDIR) -ltmglib -llapack
BLACS      =
SCALAPACK  = -L$(LIBDIR) -lscalapack $(BLACS)

OBJECTS    = fftmpiw.o fftmpi_map.o  fftw3d.o  fft3dlib.o \
             /data1/gf01/fftw-3.3.4/lib/libfftw3.a
INCS       =-I/data1/gf01/fftw-3.3.4/include

LLIBS      = $(SCALAPACK) $(LAPACK) $(BLAS)

OBJECTS_O1 += fft3dfurth.o fftw3d.o fftmpi.o fftmpiw.o chi.o
OBJECTS_O2 += fft3dlib.o

# For what used to be vasp.5.lib
CPP_LIB    = $(CPP)
FC_LIB     = $(FC)
CC_LIB     = gcc
CFLAGS_LIB = -O
FFLAGS_LIB = -O1
FREE_LIB   = $(FREE)

OBJECTS_LIB= linpack_double.o getshmem.o

# Normally no need to change this
SRCDIR     = ../../src
BINDIR     = ../../bin

[root@ohpc-master:vasp.5.4.1]#
[root@ohpc-master:vasp.5.4.1]# cat ./makefile.include
# Precompiler options
CPP_OPTIONS= -DMPI -DHOST=\"IFC91_ompi\" -DIFC \
             -DCACHE_SIZE=4000 -Davoidalloc \
             -DMPI_BLOCK=8000 -DscaLAPACK -Duse_collective \
             -Duse_bse_te -Duse_shmem -Dtbdyn \
             -DLAPACK36

CPP        = gcc -E -P -C $*$(FUFFIX) >$*$(SUFFIX) $(CPP_OPTIONS)

FC         = mpif90
FCL        = mpif90

FREE       = -ffree-form -ffree-line-length-none

FFLAGS     =
OFLAG      = -O2
OFLAG_IN   = $(OFLAG)
DEBUG      = -O0

LIBDIR     = /opt/ohpc/pub/compiler/gcc/7.3.0/lib64/
BLAS       = -L$(LIBDIR) -lrefblas
LAPACK     = -L$(LIBDIR) -ltmglib -llapack
BLACS      =
SCALAPACK  = -L$(LIBDIR) -lscalapack $(BLACS)

OBJECTS    = fftmpiw.o fftmpi_map.o  fftw3d.o  fft3dlib.o \
             /opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/lib/libfftw3.a
INCS       =-I/opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/include

LLIBS      = $(SCALAPACK) $(LAPACK) $(BLAS)

OBJECTS_O1 += fft3dfurth.o fftw3d.o fftmpi.o fftmpiw.o chi.o
OBJECTS_O2 += fft3dlib.o

# For what used to be vasp.5.lib
CPP_LIB    = $(CPP)
FC_LIB     = $(FC)
CC_LIB     = gcc
CFLAGS_LIB = -O
FFLAGS_LIB = -O1
FREE_LIB   = $(FREE)

OBJECTS_LIB= linpack_double.o getshmem.o

# Normally no need to change this
SRCDIR     = ../../src
BINDIR     = ../../bin

[root@ohpc-master:vasp.5.4.1]#
[root@ohpc-master:vasp.5.4.1]#
[root@ohpc-master:vasp.5.4.1]# diff  arch/makefile.include.linux_gfortran ./makefile.include
5c5,6
<              -Duse_bse_te -Duse_shmem -Dtbdyn
---
>              -Duse_bse_te -Duse_shmem -Dtbdyn \
>              -DLAPACK36
19c20
< LIBDIR     = /data1/gf01/libs/
---
> LIBDIR     = /opt/ohpc/pub/compiler/gcc/7.3.0/lib64/
26,27c27,28
<              /data1/gf01/fftw-3.3.4/lib/libfftw3.a
< INCS       =-I/data1/gf01/fftw-3.3.4/include
---
>              /opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/lib/libfftw3.a
> INCS       =-I/opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/include
[root@ohpc-master:vasp.5.4.1]#
```

#### /src/symbol.inc 파일에 내용추가.
https://cms.mpi.univie.ac.at/wiki/index.php/Installing_VASP#Note_on_LAPACK_3.6.0_and_newer
> * Note on LAPACK 3.6.0 and newer
> LAPACK> = 3.6에서 서브 루틴 DGEGV는 더 이상 사용되지 않으며 DGGEV 로 대체됨.
> LAPACK 3.6 이상을 연결할 경우 필요한 작업으, 컴파일하기 전에 DGGEV에 의한 모든 호출을 DGGEV로 대체합니다.

```bash
echo '
! routines replaced in LAPACK >=3.6
#ifdef LAPACK36
#define DGEGV DGGEV
#endif
' >> ./src/symbol.inc

tail  ./src/symbol.inc
```
```
[root@ohpc-master:vasp.5.4.1]# echo '
> ! routines replaced in LAPACK >=3.6
> #ifdef LAPACK36
> #define DGEGV DGGEV
> #endif
> '  >>  ./src/symbol.inc
[root@ohpc-master:vasp.5.4.1]#
[root@ohpc-master:vasp.5.4.1]# tail  ./src/symbol.inc
#include "cuda_fft.inc"
#include "cuda_macros.inc"
#include "cuda_profiling.inc"
#endif

! routines replaced in LAPACK >=3.6
#ifdef LAPACK36
#define DGEGV DGGEV
#endif

[root@ohpc-master:vasp.5.4.1]#
```

### make.
```
rm -rf build/
mkdir build
chmod 755 build/

make -j8
```




## vasp Test.

https://www.nsc.liu.se/support/tutorials/vasp/





## END.
