#!/bin/bash
echo
# 4. Install OpenHPC Development Components
echo "##### Start... Install OpenHPC Development Components on Master"
echo
echo
# 4.1 Development Tools
# Install autotools meta-package (Default)
echo "##### Start... Install autotools meta-package (Default) "
dnf -y install  ohpc-autotools EasyBuild-ohpc hwloc-ohpc spack-ohpc valgrind-ohpc \
>> ~/dasan_log_ohpc_autotools,meta-package.txt 2>&1
tail -1 ~/dasan_log_ohpc_autotools,meta-package.txt
echo
echo
# 4.2 Compilers 
echo "##### Start... Install Compilers"
dnf -y install  gnu15-compilers-ohpc >> ~/dasan_log_ohpc_Compilers.txt 2>&1
tail -1 ~/dasan_log_ohpc_Compilers.txt
echo
echo
# 4.3 MPI Stacks
echo "##### Start... Install MPI Stacks"
dnf -y install  openmpi5-pmix-gnu15-ohpc mpich-ofi-gnu15-ohpc mpich-ucx-gnu15-ohpc mvapich2-gnu15-ohpc \
 >> ~/dasan_log_ohpc_MPI-Stacks.txt 2>&1
tail -1 ~/dasan_log_ohpc_MPI-Stacks.txt
echo
echo
# 4.4 Performance Tools
# Install perf-tools meta-package
echo "##### Start... Install perf-tools meta-package "
dnf -y install  ohpc-gnu15-perf-tools  >> ~/dasan_log_ohpc_perf-tools.txt 2>&1
tail -1 ~/dasan_log_ohpc_perf-tools.txt
echo
echo
# 4.5 Setup default development environment
echo "##### Start... Install default development environment"
dnf -y install  lmod-defaults-gnu15-openmpi5-ohpc  >> ~/dasan_log_ohpc_lmod.txt 2>&1
tail -1 ~/dasan_log_ohpc_lmod.txt
echo
echo
# 4.6 3rd Party Libraries and Tools
# Install 3rd party libraries/tools meta-packages built with GNU toolchain
echo "##### Start... Install 3rd Party Libraries and Tools"
dnf -y install  ohpc-gnu15-serial-libs ohpc-gnu15-io-libs ohpc-gnu15-python-libs \
 ohpc-gnu15-runtimes >> ~/dasan_log_ohpc_3rdPartyLib.txt 2>&1
tail -1 ~/dasan_log_ohpc_3rdPartyLib.txt
echo
echo
# Install parallel lib meta-packages for all available MPI toolchains
echo "##### Start... Install parallel lib meta-packages for all available MPI toolchains"
dnf -y install  ohpc-gnu15-mpich-parallel-libs ohpc-gnu15-openmpi5-parallel-libs \
  >> ~/dasan_log_ohpc_parallellib.txt 2>&1
tail -1 ~/dasan_log_ohpc_parallellib.txt
echo
echo
# Enable Intel oneAPI and install OpenHPC compatibility packages
echo "##### Enable Intel oneAPI and install OpenHPC compatibility packages"
dnf -y install intel-oneapi-toolkit-release-ohpc   >> ~/dasan_log_ohpc_inteloneapi.txt 2>&1

rpm --import https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB

dnf -y install intel-compilers-devel-ohpc intel-mpi-devel-ohpc\
  >> ~/dasan_log_ohpc_inteloneapi.txt 2>&1

tail -1 ~/dasan_log_ohpc_inteloneapi.txt
echo
echo
# Install 3rd party libraries/tools meta-packages built with Intel toolchain
echo "##### Install 3rd party libraries/tools meta-packages built with Intel toolchain"
dnf -y install                     \
 openmpi5-pmix-intel-ohpc          \
 ohpc-intel-serial-libs            \
 ohpc-intel-io-libs                \
 ohpc-intel-perf-tools             \
 ohpc-intel-python3-libs           \
 ohpc-intel-mpich-parallel-libs    \
 ohpc-intel-mvapich2-parallel-libs \
 ohpc-intel-openmpi5-parallel-libs \
 ohpc-intel-impi-parallel-libs     \
  >> ~/dasan_log_ohpc_inteloneapi_3rdparty.txt 2>&1

tail -1  ~/dasan_log_ohpc_inteloneapi_3rdparty.txt
echo 
echo 
echo "##### Done... Install OpenHPC Development Components."
echo
# End of File.
