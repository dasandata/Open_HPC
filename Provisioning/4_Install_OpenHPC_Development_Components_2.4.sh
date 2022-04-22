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
# 4.2 Compilers 
echo "##### Start... Install Compilers"
yum -y install  gnu9-compilers-ohpc >> ~/dasan_log_ohpc_Compilers.txt 2>&1
tail -1 ~/dasan_log_ohpc_Compilers.txt
echo
echo
# 4.3 MPI Stacks
echo "##### Start... Install MPI Stacks"
yum -y install  openmpi4-gnu9-ohpc mpich-ofi-gnu9-ohpc mpich-ucx-gnu9-ohpc \
 mvapich2-gnu9-ohpc >> ~/dasan_log_ohpc_MPI-Stacks.txt 2>&1
tail -1 ~/dasan_log_ohpc_MPI-Stacks.txt
echo
echo
# 4.4 Performance Tools
# Install perf-tools meta-package
echo "##### Start... Install perf-tools meta-package "
yum -y install  ohpc-gnu9-perf-tools  ohpc-gnu9-geopm \
 >> ~/dasan_log_ohpc_perf-tools.txt 2>&1
tail -1 ~/dasan_log_ohpc_perf-tools.txt
echo
echo
# 4.5 Setup default development environment
echo "##### Start... Install default development environment"
yum -y install   lmod-defaults-gnu9-openmpi4-ohpc  >> ~/dasan_log_ohpc_lmod.txt 2>&1
tail -1 ~/dasan_log_ohpc_lmod.txt
echo
echo
# 4.6 3rd Party Libraries and Tools
# Install 3rd party libraries/tools meta-packages built with GNU toolchain
echo "##### Start... Install 3rd Party Libraries and Tools"
yum -y install ohpc-gnu9-serial-libs ohpc-gnu9-io-libs ohpc-gnu9-python-libs \
 ohpc-gnu9-runtimes >> ~/dasan_log_ohpc_3rdPartyLib.txt 2>&1
tail -1 ~/dasan_log_ohpc_3rdPartyLib.txt
echo
echo
# Install parallel lib meta-packages for all available MPI toolchains
echo "##### Start... Install parallel lib meta-packages for all available MPI toolchains"
yum -y install  ohpc-gnu9-mpich-parallel-libs ohpc-gnu9-openmpi4-parallel-libs \
  >> ~/dasan_log_ohpc_parallellib.txt 2>&1
tail -1 ~/dasan_log_ohpc_parallellib.txt
echo
echo
# Enable Intel oneAPI and install OpenHPC compatibility packages
echo "##### Enable Intel oneAPI and install OpenHPC compatibility packages"
yum -y install intel-oneapi-toolkit-release-ohpc   >> ~/dasan_log_ohpc_inteloneapi.txt 2>&1

rpm --import https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB

yum -y install intel-compilers-devel-ohpc intel-mpi-devel-ohpc\
  >> ~/dasan_log_ohpc_inteloneapi.txt 2>&1

tail -1 ~/dasan_log_ohpc_inteloneapi.txt
echo
echo
# Install 3rd party libraries/tools meta-packages built with Intel toolchain
echo "##### Install 3rd party libraries/tools meta-packages built with Intel toolchain"
yum -y install  ohpc-intel-serial-libs ohpc-intel-geopm ohpc-intel-io-libs \
ohpc-intel-perf-tools ohpc-intel-python3-libs ohpc-intel-mpich-parallel-libs \
ohpc-intel-mvapich2-parallel-libs ohpc-intel-openmpi4-parallel-libs \
ohpc-intel-impi-parallel-libs   >> ~/dasan_log_ohpc_inteloneapi_3rdparty.txt 2>&1

tail -1  ~/dasan_log_ohpc_inteloneapi_3rdparty.txt
echo 
echo 
echo "##### Done... Install OpenHPC Development Components."
echo
# End of File.
