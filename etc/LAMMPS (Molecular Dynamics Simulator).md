
## # 70.  LAMMPS (Molecular Dynamics Simulator)

cd /opt/ohpc/pub/apps/

wget http://jaist.dl.sourceforge.net/project/lammps/lammps-15May15.tar.gz
wget http://jaist.dl.sourceforge.net/project/lammps/lammps-1Feb14.tar.gz
wget https://sourceforge.net/projects/lammps/files/lammps-16Feb16.tar.gz

tar xvzf ....

cd lammps-16Feb16

cat lib/reax/Makefile.lammps.gfortran
cat lib/meam/Makefile.lammps.gfortran
cat lib/poems/Makefile.lammps.empty
cat lib/poems/Makefile.g++

cd lib/reax/
make -f Makefile.gfortran

cd ../meam/
 make -f Makefile.gfortran

cd ../poems/
make -f Makefile.g++

cd ../src/
make yes-standard

make no-gpu no-KOKKOS no-VORONOI no-KIM no-GRANULAR
make ps

yum install python-devel
make mpi

# 실행파일 경로 / 링크

mkdir -p /opt/ohpc/pub/apps/lammps/bin
ln -s /opt/ohpc/pub/apps/lammps-16Feb16/src/lmp_mpi  /opt/ohpc/pub/apps/lammps/bin/lmp_mpi_16Feb16


# example test
cd
mkdir lammps_test
cd lammps_test

cp -r /opt/ohpc/pub/apps/lammps-16Feb16/examples/ .
cd  examples/meam/

vi lammps_mpi.sh
#!/bin/bash
#----------------------------------------------------------
# Job name
#PBS -N lammps_meam

# queue select
#PBS -q workq

# Name of stdout output file (default)
###PBS -o job.out

# stdout output file  -> 실행파일 이름으로 생성
#PBS -j oe

# Total number of nodes and MPI tasks/node requested
#PBS -l select=4:mpiprocs=8

# Max Run time (hh:mm:ss) - 1.5 hours
#PBS -l walltime=01:30:00
#----------------------------------------------------------
# Change to submission directory
cd $PBS_O_WORKDIR

module purge
module  load ohpc

# Launch MPI-based executable
echo starting

echo '---------------------------------------------'
num_proc=`wc -l $PBS_NODEFILE | awk '{print $1}'`
echo 'num_proc='$num_proc
echo '---------------------------------------------'
cat $PBS_NODEFILE
echo '---------------------------------------------'

export  OMPI_mtl=^psm

lmp_cmd=/opt/ohpc/pub/apps/lammps/bin/lmp_mpi_16Feb16
mpirun  -np $num_proc -hostfile $PBS_NODEFILE  $lmp_cmd < in.meam


qsub lammps_mpi.sh
cat lammps_meam.o32
