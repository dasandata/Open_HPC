# (PBS Pro)  Resource Manager Startup  & Run a Test Job


# start pbspro daemons on master host
systemctl enable pbs
systemctl start pbs


# initialize PBS path
source  /etc/profile.d/pbs.sh

qmgr -c "print server"


# enable user environment propagation (needed for modules support)
qmgr -c "set server default_qsub_arguments= -V"

# enable uniform multi-node MPI task distribution
qmgr -c "set server resources_default.place=scatter"

# enable support for job accounting
qmgr -c "set server job_history_enable=True"


# register compute hosts with pbspro
# Node Num + 1
NODE_NUM=9
for ((i=1 ; i<$NODE_NUM ; i++))  ;   do  qmgr -c "create node n0$i"  ;   done

ll /var/spool/pbs/server_priv/topology
pbsnodes -a
pbsnodes -l   # show down node

=========
-  Interactive execution

# Switch to "test" user
su - test

# Check environment
module list
module purge
module av
module load ohpc
module list

gcc -v
which mpirun
which mpicc


# Compile MPI "hello world" example
mpicc -O3  hello.c

# Submit interactive job request and use prun to launch executable

qsub -I -l select=2:mpiprocs=4   #Select -> Nodes Number  // mpicprocs  => Thread per node (Tasks per node)

user@n01 ~]$ prun ./a.out

    --> Process #   1 of   8 is alive. -> n01
    --> Process #   2 of   8 is alive. -> n01
    --> Process #   3 of   8 is alive. -> n01
    --> Process #   0 of   8 is alive. -> n01
    --> Process #   7 of   8 is alive. -> n02
    --> Process #   4 of   8 is alive. -> n02
    --> Process #   5 of   8 is alive. -> n02
    --> Process #   6 of   8 is alive. -> n02


-  Batch execution


### PBS env check
vi pbs_env.sh

#!/bin/sh
hostname
pwd
echo HOME=$PBS_O_HOME
echo PATH=$PBS_O_PATH
echo SHELL=$PBS_O_SHELL
echo PID=$$
echo PBS_O_HOST=$PBS_O_HOST
echo PBS_O_QUEUE=$PBS_O_QUEUE
echo PBS_O_WORKDIR=$PBS_O_WORKDIR
echo PBS_ENVIRONMENT=$PBS_ENVIRONMENT
echo PBS_JOBID=$PBS_JOBID
echo PBS_JOBNAME=$PBS_JOBNAME
echo PBS_NODEFILE=$PBS_NODFILE
echo PBS_QUEUE=$PBS_QUEUE

qsub pbs_env.sh
cat pbs_env.sh.o??


# Copy example job script
cp /opt/ohpc/pub/examples/pbspro/job.mpi  hello.mpi

# Examine contents (and edit to set desired job sizing characteristics)
(1) cat hello-prun.mpi
#!/bin/bash
#----------------------------------------------------------
# Job name
#PBS -N hello

# queue select
#PBS -q workq

# Name of stdout output file (default)
###PBS -o job.out

# stdout output file  -> 실행파일 이름으로 생성
#PBS -j oe

# Total number of nodes and MPI tasks/node requested
#PBS -l select=2:mpiprocs=4

# Max Run time (hh:mm:ss) - 1.5 hours
#PBS -l walltime=01:30:00
#----------------------------------------------------------
# Change to submission directory
cd $PBS_O_WORKDIR

module purge
module  load ohpc

# Launch MPI-based executable
prun ./a.out


(2) cat hello-mpirun.mpi
#!/bin/bash
#----------------------------------------------------------
# Job name
#PBS -N hello

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
mpirun  -np $num_proc -hostfile $PBS_NODEFILE  ./a.out




# Submit job for batch execution
qsub hello.mpi
5.master
