# Install VASP on OpenHPC.
## VASP 5.4.1 Compile with gfortran + openmpi
##### dasandata. 2019-04.
참조 링크 : https://cms.mpi.univie.ac.at/wiki/index.php/Installing_VASP  

## Requirements.
For the compilation of the parallel version of VASP the following software is mandatory:
- Fortran and C compilers.
- An implementation of MPI (Message Passing Interface).
- Numerical libraries like BLAS, LAPACK, ScaLAPACK, and FFTW.

### # Requirements 중, fortran and C compilers, ScaLAPACK, MPI 는 OpenHPC 에 포함된 버젼을 사용.
#### Check fortran and C compilers (7.3.0)
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

#### Check scalapack 2.0.2
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

#### Check openmpi built with gnu7 (1.10.7)
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

### # Requirements 중 BLAS, LAPACK, FFTW 은 build 하여 사용.


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
mkdir -p /opt/ohpc/pub/libs/gnu7/blas/3.8.0/include
mkdir -p /opt/ohpc/pub/libs/gnu7/blas/3.8.0/lib

cp  libblas.a   /opt/ohpc/pub/libs/gnu7/blas/3.8.0/include
cp  libblas.so  /opt/ohpc/pub/libs/gnu7/blas/3.8.0/lib


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

prepend-path    INCLUDE             /opt/ohpc/pub/libs/gnu7/blas/3.8.0/include
prepend-path    LD_LIBRARY_PATH     /opt/ohpc/pub/libs/gnu7/blas/3.8.0/lib

setenv          BLAS_DIR        /opt/ohpc/pub/libs/gnu7/blas/3.8.0/
setenv          BLAS_LIB        /opt/ohpc/pub/libs/gnu7/blas/3.8.0/lib
setenv          BLAS_INC        /opt/ohpc/pub/libs/gnu7/blas/3.8.0/include

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
mkdir -p /opt/ohpc/pub/libs/gnu7/openmpi/lapack/3.8.0/include/
cp  *.a  /opt/ohpc/pub/libs/gnu7/openmpi/lapack/3.8.0/include/


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

prepend-path    INCLUDE         /opt/ohpc/pub/libs/gnu7/openmpi/lapack/3.8.0/include

setenv          LAPACK_DIR      /opt/ohpc/pub/libs/gnu7/openmpi/lapack/3.8.0/
setenv          LAPACK_INC      /opt/ohpc/pub/libs/gnu7/openmpi/lapack/3.8.0/include

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
#BLAS       = -L$(LIBDIR) -lrefblas
#LAPACK     = -L$(LIBDIR) -ltmglib -llapack
BLAS       = -L/opt/ohpc/pub/libs/gnu7/blas/3.8.0/include -lrefblas
LAPACK     = -L/opt/ohpc/pub/libs/gnu7/openmpi/lapack/3.8.0/include/ -ltmglib -llapack
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
19,21c20,24
< LIBDIR     = /data1/gf01/libs/
< BLAS       = -L$(LIBDIR) -lrefblas
< LAPACK     = -L$(LIBDIR) -ltmglib -llapack
---
> LIBDIR     = /opt/ohpc/pub/compiler/gcc/7.3.0/lib64/
> #BLAS       = -L$(LIBDIR) -lrefblas
> #LAPACK     = -L$(LIBDIR) -ltmglib -llapack
> BLAS       = -L/opt/ohpc/pub/libs/gnu7/blas/3.8.0/include -lrefblas
> LAPACK     = -L/opt/ohpc/pub/libs/gnu7/openmpi/lapack/3.8.0/include/ -ltmglib -llapack
26,27c29,30
<              /data1/gf01/fftw-3.3.4/lib/libfftw3.a
< INCS       =-I/data1/gf01/fftw-3.3.4/include
---
>              /opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/lib/libfftw3.a
> INCS       =-I/opt/ohpc/pub/libs/gnu7/openmpi/fftw/3.3.8/include
[root@ohpc-master:vasp.5.4.1]#
```

#### /src/symbol.inc 파일에 내용추가.
https://cms.mpi.univie.ac.at/wiki/index.php/Installing_VASP#Note_on_LAPACK_3.6.0_and_newer
> Note on LAPACK 3.6.0 and newer  
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
```bash
module purge
module load gnu7 openmpi blas lapack

rm -rf build/
mkdir build
chmod 755 build/

make
```

```bash
ldd bin/vasp_std
```
```
[root@ohpc-master:vasp.5.4.1]# ldd bin/vasp_std
	linux-vdso.so.1 =>  (0x00007ffc9ebca000)
	libmpi_usempif08.so.11 => /opt/ohpc/pub/mpi/openmpi-gnu7/1.10.7/lib/libmpi_usempif08.so.11 (0x00007f0070796000)
	libmpi_usempi_ignore_tkr.so.6 => /opt/ohpc/pub/mpi/openmpi-gnu7/1.10.7/lib/libmpi_usempi_ignore_tkr.so.6 (0x00007f007058e000)
	libmpi_mpifh.so.12 => /opt/ohpc/pub/mpi/openmpi-gnu7/1.10.7/lib/libmpi_mpifh.so.12 (0x00007f0070337000)
	libmpi.so.12 => /opt/ohpc/pub/mpi/openmpi-gnu7/1.10.7/lib/libmpi.so.12 (0x00007f0070043000)
	libgfortran.so.4 => /opt/ohpc/pub/compiler/gcc/7.3.0/lib64/libgfortran.so.4 (0x00007f006fc70000)
	libm.so.6 => /lib64/libm.so.6 (0x00007f006f94e000)
	libgcc_s.so.1 => /opt/ohpc/pub/compiler/gcc/7.3.0/lib64/libgcc_s.so.1 (0x00007f006f737000)
	libquadmath.so.0 => /opt/ohpc/pub/compiler/gcc/7.3.0/lib64/libquadmath.so.0 (0x00007f006f4f7000)
	libpthread.so.0 => /lib64/libpthread.so.0 (0x00007f006f2db000)
	libc.so.6 => /lib64/libc.so.6 (0x00007f006ef0e000)
	libopen-rte.so.12 => /opt/ohpc/pub/mpi/openmpi-gnu7/1.10.7/lib/libopen-rte.so.12 (0x00007f006ec92000)
	libopen-pal.so.13 => /opt/ohpc/pub/mpi/openmpi-gnu7/1.10.7/lib/libopen-pal.so.13 (0x00007f006e9ad000)
	libnuma.so.1 => /lib64/libnuma.so.1 (0x00007f006e7a1000)
	libdl.so.2 => /lib64/libdl.so.2 (0x00007f006e59c000)
	librt.so.1 => /lib64/librt.so.1 (0x00007f006e394000)
	libutil.so.1 => /lib64/libutil.so.1 (0x00007f006e191000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f00709c7000)
[root@ohpc-master:vasp.5.4.1]#
```

### Module make for VASP 5.4.1

```bash
# file copy.
mkdir -p /opt/ohpc/pub/libs/gnu7/openmpi/vasp/5.4.1
cp -r ./bin /opt/ohpc/pub/libs/gnu7/openmpi/vasp/5.4.1/

# make module file.
mkdir -p /opt/ohpc/pub/moduledeps/gnu7-openmpi/vasp/

echo '#%Module1.0#####################################################################

proc ModulesHelp { } {

puts stderr " "
puts stderr "This module loads the VASP apps built with the gnu7 compiler "
puts stderr "toolchain and the openmpi MPI stack."
puts stderr "\nVersion 5.4.1\n"

}
module-whatis "Name: VASP built with gnu7 compiler and openmpi MPI"
module-whatis "Version: 5.4.1"
module-whatis "Category: utility, developer support, user tool"
module-whatis "Description: VASP (Vienna Ab initio Simulation Package)"
module-whatis "URL https://www.vasp.at/"

set     version    5.4.1

prepend-path    PATH            /opt/ohpc/pub/libs/gnu7/openmpi/vasp/5.4.1/bin/

setenv          VASP_DIR        /opt/ohpc/pub/libs/gnu7/openmpi/vasp/5.4.1/

' > /opt/ohpc/pub/moduledeps/gnu7-openmpi/vasp/5.4.1

# module reload
rm -rf ~/.lmod.d/
module av | grep vasp/5.4.1

module whatis vasp/5.4.1
module show vasp/5.4.1

```

## vasp Test.
https://www.nsc.liu.se/support/tutorials/vasp/

```bash
# Download testfile.
mkdir ~/vasp_test
cd  ~/vasp_test
wget https://www.vasp.at/vasp-workshop/examples/3_5_COonNi111_rel.tgz
tar xzf 3_5_COonNi111_rel.tgz
cd ~/vasp_test/3_5_COonNi111_rel/
```
```bash
# Run Test.
ml load vasp/5.4.1

cd ~/vasp_test/3_5_COonNi111_rel/
vasp_std

# mpi run test.
mpirun vasp_std
```

```
running on    1 total cores
distrk:  each k-point on    1 cores,    1 groups
distr:  one band on    1 cores,    1 groups
using from now: INCAR     
vasp.5.4.1 05Feb16 (build Apr 17 2019 21:49:20) complex                         
POSCAR found :  3 types and       7 ions
scaLAPACK will be used
LDA part: xc-table for Ceperly-Alder, standard interpolation
POSCAR, INCAR and KPOINTS ok, starting setup
WARNING: small aliasing (wrap around) errors must be expected
FFT: planning ...
WAVECAR not read
entering main loop
      N       E                     dE             d eps       ncg     rms          rms(c)
DAV:   1     0.466016575259E+03    0.46602E+03   -0.24537E+04   864   0.179E+03
DAV:   2     0.206595601409E+02   -0.44536E+03   -0.42966E+03   868   0.398E+02
DAV:   3    -0.420732788047E+02   -0.62733E+02   -0.55563E+02  1184   0.163E+02
DAV:   4    -0.471824083250E+02   -0.51091E+01   -0.49871E+01   996   0.438E+01
DAV:   5    -0.473941591778E+02   -0.21175E+00   -0.21088E+00  1264   0.796E+00    0.217E+01
RMM:   6    -0.535507497830E+02   -0.61566E+01   -0.10078E+02   883   0.958E+01    0.265E+01
RMM:   7    -0.509120576394E+02    0.26387E+01   -0.27261E+01   876   0.480E+01    0.351E+01
RMM:   8    -0.443949552208E+02    0.65171E+01   -0.53180E+00   902   0.188E+01    0.222E+01
RMM:   9    -0.439305401422E+02    0.46442E+00   -0.33272E+00   885   0.139E+01    0.207E+01
RMM:  10    -0.439310199189E+02   -0.47978E-03   -0.31322E+00   881   0.146E+01    0.222E+01
RMM:  11    -0.419795036099E+02    0.19515E+01   -0.10173E+00   889   0.830E+00    0.118E+01
RMM:  12    -0.412833569341E+02    0.69615E+00   -0.67378E-01   894   0.695E+00    0.995E+00
RMM:  13    -0.409233498783E+02    0.36001E+00   -0.32076E-01   912   0.320E+00    0.361E+00
RMM:  14    -0.408611822653E+02    0.62168E-01   -0.65678E-02   887   0.211E+00    0.235E+00
RMM:  15    -0.408479025315E+02    0.13280E-01   -0.38559E-02   908   0.148E+00    0.199E+00
RMM:  16    -0.408332880764E+02    0.14614E-01   -0.10127E-02   876   0.859E-01    0.611E-01
RMM:  17    -0.408316307659E+02    0.16573E-02   -0.18504E-03   908   0.274E-01    0.393E-01
RMM:  18    -0.408308911565E+02    0.73961E-03   -0.47852E-04   622   0.153E-01    0.232E-01
RMM:  19    -0.408308340134E+02    0.57143E-04   -0.65460E-04   694   0.154E-01
  1 F= -.40830834E+02 E0= -.40826309E+02  d E =-.408308E+02
BRION: g(F)=  0.118E-01 g(S)=  0.000E+00
bond charge predicted
      N       E                     dE             d eps       ncg     rms          rms(c)
DAV:   1    -0.408184859754E+02    0.12405E-01   -0.11664E+00   888   0.485E+00    0.323E-01
RMM:   2    -0.408237957894E+02   -0.53098E-02   -0.38314E-02  1002   0.120E+00    0.113E+00
RMM:   3    -0.408234609375E+02    0.33485E-03   -0.52760E-03   878   0.614E-01    0.124E+00
RMM:   4    -0.408234672979E+02   -0.63603E-05   -0.26265E-03   846   0.404E-01    0.112E+00
RMM:   5    -0.408220915910E+02    0.13757E-02   -0.28930E-03   864   0.439E-01    0.806E-01
RMM:   6    -0.408194149956E+02    0.26766E-02   -0.26190E-03   864   0.445E-01    0.427E-01
RMM:   7    -0.408207334429E+02   -0.13184E-02   -0.27125E-03   864   0.431E-01    0.720E-01
RMM:   8    -0.408186796517E+02    0.20538E-02   -0.15865E-03   847   0.370E-01    0.107E-01
RMM:   9    -0.408185572938E+02    0.12236E-03   -0.95597E-05   471   0.944E-02    0.285E-02
RMM:  10    -0.408186006657E+02   -0.43372E-04   -0.22506E-05   451   0.399E-02
  2 F= -.40818601E+02 E0= -.40813926E+02  d E =0.122333E-01
BRION: g(F)=  0.117E+00 g(S)=  0.000E+00 retain N=  1 mean eig= 0.24
eig:   0.238
bond charge predicted
      N       E                     dE             d eps       ncg     rms          rms(c)
DAV:   1    -0.408334311961E+02   -0.14874E-01   -0.62872E-01   880   0.339E+00    0.231E-01
RMM:   2    -0.408347449448E+02   -0.13137E-02   -0.20272E-02  1066   0.754E-01    0.498E-01
RMM:   3    -0.408369605471E+02   -0.22156E-02   -0.17256E-03   841   0.360E-01    0.113E+00
RMM:   4    -0.408376137417E+02   -0.65319E-03   -0.14241E-03   836   0.310E-01    0.106E+00
RMM:   5    -0.408338113153E+02    0.38024E-02   -0.17366E-03   859   0.367E-01    0.297E-01
RMM:   6    -0.408350439398E+02   -0.12326E-02   -0.21580E-03   853   0.378E-01    0.682E-01
RMM:   7    -0.408332043295E+02    0.18396E-02   -0.14919E-03   843   0.338E-01    0.590E-02
RMM:   8    -0.408331999473E+02    0.43822E-05   -0.15648E-04   483   0.120E-01
  3 F= -.40833200E+02 E0= -.40828601E+02  d E =-.145993E-01
BRION: g(F)=  0.273E-03 g(S)=  0.000E+00 retain N=  1 mean eig= 0.24
eig:   0.242
bond charge predicted
      N       E                     dE             d eps       ncg     rms          rms(c)
DAV:   1    -0.408333050958E+02   -0.10077E-03   -0.23635E-02   916   0.878E-01    0.371E-02
RMM:   2    -0.408340815544E+02   -0.77646E-03   -0.49568E-04   670   0.210E-01    0.457E-01
RMM:   3    -0.408333796885E+02    0.70187E-03   -0.21915E-04   508   0.140E-01    0.120E-01
RMM:   4    -0.408333273541E+02    0.52334E-04   -0.31800E-05   433   0.436E-02
  4 F= -.40833327E+02 E0= -.40828767E+02  d E =-.127407E-03
BRION: g(F)=  0.161E-03 g(S)=  0.000E+00 retain N=  2 mean eig= 0.21
eig:   0.289  0.123
reached required accuracy - stopping structural energy minimisation
writing wavefunctions
Note: The following floating-point exceptions are signalling: IEEE_UNDERFLOW_FLAG IEEE_DENORMAL
```

## END.
