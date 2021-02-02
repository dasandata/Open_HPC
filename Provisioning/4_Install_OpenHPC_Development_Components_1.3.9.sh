#!/bin/bash
echo
# 4. Install OpenHPC Development Components
echo "##### Start... Install OpenHPC Development Components on Master"
echo
echo
# 4.1 Development Tools
# Install autotools meta-package (Default)
echo "##### Start... Install autotools meta-package (Default) "
yum -y install  ohpc-autotools EasyBuild-ohpc hwloc-ohpc spack-ohpc valgrind-ohpc \
>> ~/dasan_log_ohpc_autotools,meta-package.txt 2>&1
tail -1 ~/dasan_log_ohpc_autotools,meta-package.txt
echo
echo
# 4.2 Compilers (gcc ver 7 and 5.4)
echo "##### Start... Install Compilers (gcc ver 8, 7 and 5.4) "
yum -y install  gnu8-compilers-ohpc gnu7-compilers-ohpc gnu-compilers-ohpc \
 >> ~/dasan_log_ohpc_Compilers.txt 2>&1
tail -1 ~/dasan_log_ohpc_Compilers.txt
echo
echo
# 4.3 MPI Stacks
echo "##### Start... Install MPI Stacks (for gnu7, gnu8)"
yum -y install  openmpi-gnu7-ohpc openmpi3-gnu7-ohpc mvapich2-gnu7-ohpc mpich-gnu7-ohpc \
 >> ~/dasan_log_ohpc_MPI-Stacks_gnu7.txt 2>&1
tail -1 ~/dasan_log_ohpc_MPI-Stacks_gnu7.txt
echo
yum -y install  openmpi3-gnu8-ohpc mpich-gnu8-ohpc mvapich2-gnu8-ohpc \
 >> ~/dasan_log_ohpc_MPI-Stacks_gnu8.txt 2>&1
tail -1 ~/dasan_log_ohpc_MPI-Stacks_gnu8.txt
echo
echo
# 4.4 Performance Tools
# Install perf-tools meta-package
echo "##### Start... Install perf-tools meta-package "
yum -y install ohpc-gnu8-perf-tools >> ~/dasan_log_ohpc_perf-tools-gnu8.txt 2>&1
tail -1 ~/dasan_log_ohpc_perf-tools-gnu8.txt
echo
yum -y groupinstall  ohpc-perf-tools-gnu >> ~/dasan_log_ohpc_perf-tools-gnu.txt 2>&1
tail -1 ~/dasan_log_ohpc_perf-tools-gnu.txt
echo
echo
# 4.5 Setup default development environment
echo "##### Start... Install default development environment"
yum -y install  lmod-defaults-gnu7-openmpi3-ohpc  >> ~/dasan_log_ohpc_lmod-gnu7.txt 2>&1
tail -1 ~/dasan_log_ohpc_lmod-gnu7.txt
echo
echo
# 4.6 3rd Party Libraries and Tools
# Install 3rd party libraries/tools meta-packages built with GNU toolchain
echo "##### Start... Install 3rd Party Libraries and Tools"
yum -y install ohpc-gnu8-serial-libs ohpc-gnu8-io-libs ohpc-gnu8-python-libs \
 ohpc-gnu8-runtimes >> ~/dasan_log_ohpc_3rdPartyLib.txt 2>&1
tail -1 ~/dasan_log_ohpc_3rdPartyLib.txt
echo
echo
# Install parallel lib meta-packages for all available MPI toolchains
echo "##### Start... Install parallel lib meta-packages for all available MPI toolchains"
yum -y install  ohpc-gnu8-mpich-parallel-libs ohpc-gnu8-openmpi3-parallel-libs \
  >> ~/dasan_log_ohpc_parallellib.txt 2>&1
tail -1 ~/dasan_log_ohpc_parallellib.txt
echo
echo
# Install gnu5 MPI Stacks & lib & meta-packages
echo "##### Start... Install gnu5 MPI Stacks & lib & meta-packages"
yum -y groupinstall  ohpc-io-libs-gnu ohpc-parallel-libs-gnu ohpc-parallel-libs-gnu-mpich \
 ohpc-python-libs-gnu ohpc-runtimes-gnu ohpc-serial-libs-gnu >> ~/dasan_log_ohpc_gnu5MPI.txt 2>&1
tail -1 ~/dasan_log_ohpc_gnu5MPI.txt
echo
echo
echo "##### Start... Optional Development Tool Builds"
yum -y install intel-compilers-devel-ohpc intel-mpi-devel-ohpc >> ~/dasan_log_ohpc_compatibility.txt 2>&1
tail -1  ~/dasan_log_ohpc_compatibility.txt
echo
echo "##### Done... Install OpenHPC Development Components."
echo
# End of File.
