# slurm

## slurm 설정파일 경로 (2가지)
### /etc/slurm/slurm.conf
```
[root@master:~]#
[root@master:~]# cat /etc/slurm/slurm.conf | grep -v "^$\|^#"  # 공백라인 과 주석 제외
ClusterName=OpenHPC-KoreaAC
ControlMachine=master
SlurmUser=slurm
SlurmctldPort=6817
SlurmdPort=6818
AuthType=auth/munge
StateSaveLocation=/var/spool/slurm/ctld
SlurmdSpoolDir=/var/spool/slurm/d
SwitchType=switch/none
MpiDefault=none
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmdPidFile=/var/run/slurmd.pid
ProctrackType=proctrack/pgid
SlurmctldTimeout=300
SlurmdTimeout=300
InactiveLimit=0
MinJobAge=300
KillWait=30
Waittime=0
SchedulerType=sched/backfill
SelectType=select/cons_res
SelectTypeParameters=CR_Core
DefMemPerCPU=0
FastSchedule=1
SlurmctldDebug=3
SlurmctldLogFile=/var/log/slurmctld.log
SlurmdDebug=3
SlurmdLogFile=/var/log/slurmd.log
JobCompType=jobcomp/filetxt
JobCompLoc=/var/log/slurm/job_completions.log
JobAcctGatherType=jobacct_gather/linux
JobAcctGatherFrequency=30
AccountingStorageType=accounting_storage/slurmdbd
AccountingStoreJobComment = YES
AccountingStorageLoc=/var/log/slurm_accounting.log
PropagateResourceLimitsExcept=MEMLOCK
Epilog=/etc/slurm/slurm.epilog.clean
GresTypes=gpu
NodeName=node[1-3] Procs=32  Sockets=2 CoresPerSocket=8 ThreadsPerCore=2   RealMemory=102400    TmpDisk=51200   Gres=gpu:TitanXp:4  Feature=TitanXp,DellT640
PartitionName=cpu Default=Yes MinNodes=1 MaxNodes=3 DefaultTime=12:00:00 MaxTime=12:00:00 Priority=1 DisableRootJobs=NO RootOnly=NO Hidden=NO Shared=NO GraceTime=0 ReqResv=NO AllowAccounts=ALL AllowQos=ALL LLN=NO Nodes=node[1-3]
PartitionName=gpu             MinNodes=1 MaxNodes=3 DefaultTime=12:00:00 MaxTime=12:00:00 Priority=1 DisableRootJobs=NO RootOnly=NO Hidden=NO Shared=NO GraceTime=0 ReqResv=NO AllowAccounts=ALL AllowQos=ALL LLN=NO Nodes=node[1-3]
[root@master:~]#
[root@master:~]#
```

### /etc/slurm/gres.conf
```
[root@master:~]# cat /etc/slurm/gres.conf
Nodename=node[1-3]    Name=gpu  Type=TitanXp  File=/dev/nvidia0  CPUs=0-1
Nodename=node[1-3]    Name=gpu  Type=TitanXp  File=/dev/nvidia1  CPUs=2-3
Nodename=node[1-3]    Name=gpu  Type=TitanXp  File=/dev/nvidia2  CPUs=4-5
Nodename=node[1-3]    Name=gpu  Type=TitanXp  File=/dev/nvidia3  CPUs=6-7
[root@master:~]#
```

## Slurm Example (interactive job - 대화형 작업).

```
[sonic@master:~]$ cd /DATA1
[sonic@master:DATA1]$ pwd
/DATA1
[sonic@master:DATA1]$
[sonic@master:DATA1]$
[sonic@master:DATA1]$ ll
total 12K
drwxr-xr-x 12 root root 294 Apr 23 20:47 NVIDIA_CUDA-8.0_Samples
drwxrwxr-x  6 root root 175 Apr 23 20:47 TensorFlow-Examples
-rw-rw-rw-  1 root root 463 Apr 23 20:49 test-sbatch-tensorflow-1GPU.sh
-rw-rw-rw-  1 root root 463 Apr 23 20:49 test-sbatch-tensorflow-2GPU.sh
-rw-rw-rw-  1 root root 463 Apr 23 20:49 test-sbatch-tensorflow-4GPU.sh
[sonic@master:DATA1]$
[sonic@master:DATA1]$
[sonic@master:DATA1]$ squeue  # 작업 대기열 (queue) 확인
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
[sonic@master:DATA1]$
[sonic@master:DATA1]$ srun --gres=gpu:1 --pty bash -i   # 대화형 (interactive) 작업 으로 진입. - gpu 1개 사용.
[sonic@node1:DATA1]$
[sonic@node1:DATA1]$ squeue    # 작업 대기열 (queue) 확인
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
               269       gpu     bash    sonic  R       0:03      1 node1
[sonic@node1:DATA1]$  
[sonic@node1:DATA1]$ env | grep SLURM | head       # SLURM 환경변수 확인.
SLURM_CHECKPOINT_IMAGE_DIR=/var/slurm/checkpoint
SLURM_NODELIST=node1
SLURM_JOB_NAME=bash
SLURMD_NODENAME=node1
SLURM_TOPOLOGY_ADDR=node1
SLURM_PRIO_PROCESS=0
SLURM_SRUN_COMM_PORT=39762
SLURM_PTY_WIN_ROW=45
SLURM_TOPOLOGY_ADDR_PATTERN=node
SLURM_NNODES=1
[sonic@node1:DATA1]$
[sonic@node1:DATA1]$
[sonic@node1:DATA1]$ # 샘플 코드 테스트.
[sonic@node1:DATA1]$ python3 ./TensorFlow-Examples/examples/1_Introduction/basic_operations.py
2018-04-23 21:15:06.776819: I tensorflow/core/platform/cpu_feature_guard.cc:137] Your CPU supports instructions that this TensorFlow binary was not compiled to use: SSE4.1 SSE4.2 AVX AVX2 FMA
2018-04-23 21:15:07.152736: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1030] Found device 0 with properties:
name: GeForce GTX 1080 Ti major: 6 minor: 1 memoryClockRate(GHz): 1.582
pciBusID: 0000:03:00.0
totalMemory: 10.92GiB freeMemory: 10.76GiB
2018-04-23 21:15:07.152848: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:0) -> (device: 0, name: GeForce GTX 1080 Ti, pci bus id: 0000:03:00.0, compute capability: 6.1)
a=2, b=3
Addition with constants: 5
Multiplication with constants: 6
2018-04-23 21:15:07.334873: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:0) -> (device: 0, name: GeForce GTX 1080 Ti, pci bus id: 0000:03:00.0, compute capability: 6.1)
Addition with variables: 5
Multiplication with variables: 6
2018-04-23 21:15:07.656210: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:0) -> (device: 0, name: GeForce GTX 1080 Ti, pci bus id: 0000:03:00.0, compute capability: 6.1)
[[12.]]
[sonic@node1:DATA1]$ # gpu 1개만 할당 되어 코드가 작동 된것을 확인할 수 있습니다.
[sonic@node1:DATA1]$
[sonic@node1:DATA1]$
[sonic@node1:DATA1]$ exit      # 대화형 (interactive) 작업 에서 빠져 나옴.
[sonic@master:DATA1]$
[sonic@master:DATA1]$ srun --gres=gpu:4 --pty bash -i   # 대화형 (interactive) 작업 으로 진입. - gpu 4개 사용.
[sonic@node1:DATA1]$
[sonic@node1:DATA1]$ python3 ./TensorFlow-Examples/examples/1_Introduction/basic_operations.py
2018-04-23 21:15:29.582576: I tensorflow/core/platform/cpu_feature_guard.cc:137] Your CPU supports instructions that this TensorFlow binary was not compiled to use: SSE4.1 SSE4.2 AVX AVX2 FMA
2018-04-23 21:15:30.005642: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1030] Found device 0 with properties:
name: GeForce GTX 1080 Ti major: 6 minor: 1 memoryClockRate(GHz): 1.582
pciBusID: 0000:03:00.0
totalMemory: 10.92GiB freeMemory: 10.76GiB
2018-04-23 21:15:30.324056: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1030] Found device 1 with properties:
name: GeForce GTX 1080 Ti major: 6 minor: 1 memoryClockRate(GHz): 1.582
pciBusID: 0000:04:00.0
totalMemory: 10.92GiB freeMemory: 10.76GiB
2018-04-23 21:15:30.686609: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1030] Found device 2 with properties:
name: GeForce GTX 1080 Ti major: 6 minor: 1 memoryClockRate(GHz): 1.582
pciBusID: 0000:81:00.0
totalMemory: 10.92GiB freeMemory: 10.76GiB
2018-04-23 21:15:31.023573: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1030] Found device 3 with properties:
name: GeForce GTX 1080 Ti major: 6 minor: 1 memoryClockRate(GHz): 1.582
pciBusID: 0000:82:00.0
totalMemory: 10.92GiB freeMemory: 10.76GiB
2018-04-23 21:15:31.025774: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1045] Device peer to peer matrix
2018-04-23 21:15:31.025859: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1051] DMA: 0 1 2 3
2018-04-23 21:15:31.025874: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1061] 0:   Y Y N N
2018-04-23 21:15:31.025902: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1061] 1:   Y Y N N
2018-04-23 21:15:31.025910: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1061] 2:   N N Y Y
2018-04-23 21:15:31.025921: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1061] 3:   N N Y Y
2018-04-23 21:15:31.025949: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:0) -> (device: 0, name: GeForce GTX 1080 Ti, pci bus id: 0000:03:00.0, compute capability: 6.1)
2018-04-23 21:15:31.025961: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:1) -> (device: 1, name: GeForce GTX 1080 Ti, pci bus id: 0000:04:00.0, compute capability: 6.1)
2018-04-23 21:15:31.025975: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:2) -> (device: 2, name: GeForce GTX 1080 Ti, pci bus id: 0000:81:00.0, compute capability: 6.1)
2018-04-23 21:15:31.025996: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:3) -> (device: 3, name: GeForce GTX 1080 Ti, pci bus id: 0000:82:00.0, compute capability: 6.1)
a=2, b=3
Addition with constants: 5
Multiplication with constants: 6
2018-04-23 21:15:31.476017: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:0) -> (device: 0, name: GeForce GTX 1080 Ti, pci bus id: 0000:03:00.0, compute capability: 6.1)
2018-04-23 21:15:31.476079: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:1) -> (device: 1, name: GeForce GTX 1080 Ti, pci bus id: 0000:04:00.0, compute capability: 6.1)
2018-04-23 21:15:31.476098: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:2) -> (device: 2, name: GeForce GTX 1080 Ti, pci bus id: 0000:81:00.0, compute capability: 6.1)
2018-04-23 21:15:31.476123: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:3) -> (device: 3, name: GeForce GTX 1080 Ti, pci bus id: 0000:82:00.0, compute capability: 6.1)
Addition with variables: 5
Multiplication with variables: 6
2018-04-23 21:15:31.794484: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:0) -> (device: 0, name: GeForce GTX 1080 Ti, pci bus id: 0000:03:00.0, compute capability: 6.1)
2018-04-23 21:15:31.794544: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:1) -> (device: 1, name: GeForce GTX 1080 Ti, pci bus id: 0000:04:00.0, compute capability: 6.1)
2018-04-23 21:15:31.794605: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:2) -> (device: 2, name: GeForce GTX 1080 Ti, pci bus id: 0000:81:00.0, compute capability: 6.1)
2018-04-23 21:15:31.794632: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:3) -> (device: 3, name: GeForce GTX 1080 Ti, pci bus id: 0000:82:00.0, compute capability: 6.1)
[[12.]]
[sonic@node1:DATA1]$ # gpu 4개가 할당 되어 코드가 작동 된것을 확인할 수 있습니다.
```


## Slurm Example (batch job - 일괄작업).

```
[sonic@master:DATA1]$
[sonic@master:DATA1]$ pwd
/DATA1
[sonic@master:DATA1]$
[sonic@master:DATA1]$ ls -l
total 12
drwxr-xr-x 12 root root 294 Apr 23 20:47 NVIDIA_CUDA-8.0_Samples
drwxrwxr-x  6 root root 175 Apr 23 20:47 TensorFlow-Examples
-rw-rw-rw-  1 root root 463 Apr 23 20:49 test-sbatch-tensorflow-1GPU.sh
-rw-rw-rw-  1 root root 463 Apr 23 20:49 test-sbatch-tensorflow-2GPU.sh
-rw-rw-rw-  1 root root 463 Apr 23 20:49 test-sbatch-tensorflow-4GPU.sh
[sonic@master:DATA1]$
[sonic@master:DATA1]$ cat test-sbatch-tensorflow-1GPU.sh     # gpu 1개를 사용하는 샘플 파일 입니다.
#!/bin/sh

#SBATCH -J  1GPU-tf                       # Job name
#SBATCH -o  out.test-tensorflow-1GPU.%j   # Name of stdout output file (%j expands to %jobId)
#SBATCH -p  gpu                           # queue or partiton name
#SBATCH -t  01:30:00                      # Max Run time (hh:mm:ss) - 1.5 hours

#SBATCH --gres=gpu:1                      # Num Devices

python3   ./TensorFlow-Examples/examples/5_DataManagement/tensorflow_dataset_api.py

# End of File.
[sonic@master:DATA1]$
[sonic@master:DATA1]$ cat test-sbatch-tensorflow-2GPU.sh   # gpu 2개를 사용하는 샘플 파일 입니다.
#!/bin/sh

#SBATCH -J  2GPU-tf                       # Job name
#SBATCH -o  out.test-tensorflow-2GPU.%j   # Name of stdout output file (%j expands to %jobId)
#SBATCH -p  gpu                           # queue or partiton name
#SBATCH -t  01:30:00                      # Max Run time (hh:mm:ss) - 1.5 hours

#SBATCH --gres=gpu:2                      # Num Devices

python3   ./TensorFlow-Examples/examples/5_DataManagement/tensorflow_dataset_api.py

# End of File.
[sonic@master:DATA1]$
[sonic@master:DATA1]$
[sonic@master:DATA1]$ sbatch test-sbatch-tensorflow-2GPU.sh     # batch 작업 제출
Submitted batch job 272  
[sonic@master:DATA1]$
[sonic@master:DATA1]$ cat out.test-tensorflow-2GPU.272     # 작업 결과 확인.
2018-04-23 21:32:31.384916: I tensorflow/core/platform/cpu_feature_guard.cc:137] Your CPU supports instructions that this TensorFlow binary was not compiled to use: SSE4.1 SSE4.2 AVX AVX2 FMA
2018-04-23 21:32:31.830157: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1030] Found device 0 with properties:
name: GeForce GTX 1080 Ti major: 6 minor: 1 memoryClockRate(GHz): 1.582
pciBusID: 0000:03:00.0
totalMemory: 10.92GiB freeMemory: 10.76GiB
2018-04-23 21:32:32.227943: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1030] Found device 1 with properties:
name: GeForce GTX 1080 Ti major: 6 minor: 1 memoryClockRate(GHz): 1.582
pciBusID: 0000:04:00.0
totalMemory: 10.92GiB freeMemory: 10.76GiB
2018-04-23 21:32:32.229740: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1045] Device peer to peer matrix
2018-04-23 21:32:32.229791: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1051] DMA: 0 1
2018-04-23 21:32:32.229804: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1061] 0:   Y Y
2018-04-23 21:32:32.229812: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1061] 1:   Y Y
2018-04-23 21:32:32.229833: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:0) -> (device: 0, name: GeForce GTX 1080 Ti, pci bus id: 0000:03:00.0, compute capability: 6.1)
2018-04-23 21:32:32.229843: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:1) -> (device: 1, name: GeForce GTX 1080 Ti, pci bus id: 0000:04:00.0, compute capability: 6.1)
WARNING:tensorflow:From ./TensorFlow-Examples/examples/5_DataManagement/tensorflow_dataset_api.py:33: Dataset.from_tensor_slices (from tensorflow.contrib.data.python.ops.dataset_ops) is deprecated and will be removed in a future version.
Instructions for updating:
Use `tf.data.Dataset.from_tensor_slices()`.
Extracting /tmp/data/train-images-idx3-ubyte.gz
Extracting /tmp/data/train-labels-idx1-ubyte.gz
Extracting /tmp/data/t10k-images-idx3-ubyte.gz
Extracting /tmp/data/t10k-labels-idx1-ubyte.gz
Step 1, Minibatch Loss= 2.2709, Training Accuracy= 0.227
Step 100, Minibatch Loss= 0.1267, Training Accuracy= 0.945
Step 200, Minibatch Loss= 0.1082, Training Accuracy= 0.977
Step 300, Minibatch Loss= 0.0922, Training Accuracy= 0.969
Step 400, Minibatch Loss= 0.0673, Training Accuracy= 0.984
Step 500, Minibatch Loss= 0.0967, Training Accuracy= 0.992
Step 600, Minibatch Loss= 0.0465, Training Accuracy= 0.984
Step 700, Minibatch Loss= 0.0077, Training Accuracy= 1.000
Step 800, Minibatch Loss= 0.0565, Training Accuracy= 0.984
Step 900, Minibatch Loss= 0.0405, Training Accuracy= 0.992
Step 1000, Minibatch Loss= 0.0143, Training Accuracy= 0.992
Step 1100, Minibatch Loss= 0.0160, Training Accuracy= 1.000
Step 1200, Minibatch Loss= 0.0139, Training Accuracy= 1.000
Step 1300, Minibatch Loss= 0.0227, Training Accuracy= 0.977
Step 1400, Minibatch Loss= 0.0300, Training Accuracy= 1.000
Step 1500, Minibatch Loss= 0.0047, Training Accuracy= 1.000
Step 1600, Minibatch Loss= 0.0175, Training Accuracy= 1.000
Step 1700, Minibatch Loss= 0.1386, Training Accuracy= 0.961
Step 1800, Minibatch Loss= 0.0261, Training Accuracy= 1.000
Step 1900, Minibatch Loss= 0.0257, Training Accuracy= 1.000
Step 2000, Minibatch Loss= 0.0772, Training Accuracy= 0.984
Optimization Finished!
[sonic@master:DATA1]$  # gpu 2개가 사용되어 코드가 작동된 것을 확인할 수 있습니다.
[sonic@master:DATA1]$
[sonic@master:DATA1]$ # gpu 2개 짜리 작업을 여러개 제출 합니다.
[sonic@master:DATA1]$ sbatch test-sbatch-tensorflow-2GPU.sh
Submitted batch job 273
[sonic@master:DATA1]$ sbatch test-sbatch-tensorflow-2GPU.sh
Submitted batch job 274
[sonic@master:DATA1]$ sbatch test-sbatch-tensorflow-2GPU.sh
Submitted batch job 275
[sonic@master:DATA1]$ sbatch test-sbatch-tensorflow-2GPU.sh
Submitted batch job 276
[sonic@master:DATA1]$ sbatch test-sbatch-tensorflow-2GPU.sh
Submitted batch job 277
[sonic@master:DATA1]$ sbatch test-sbatch-tensorflow-2GPU.sh
Submitted batch job 278
[sonic@master:DATA1]$ sbatch test-sbatch-tensorflow-2GPU.sh
Submitted batch job 279
[sonic@master:DATA1]$ sbatch test-sbatch-tensorflow-2GPU.sh
Submitted batch job 280
[sonic@master:DATA1]$
[sonic@master:DATA1]$ squeue   # 작업 대기열 (queue) 확인
            JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
               277       gpu  2GPU-tf    sonic PD       0:00      1 (Resources)
               278       gpu  2GPU-tf    sonic PD       0:00      1 (Priority)
               279       gpu  2GPU-tf    sonic PD       0:00      1 (Priority)
               280       gpu  2GPU-tf    sonic PD       0:00      1 (Priority)
               273       gpu  2GPU-tf    sonic  R       0:05      1 node1
               274       gpu  2GPU-tf    sonic  R       0:02      1 node1
               275       gpu  2GPU-tf    sonic  R       0:02      1 node2
               276       gpu  2GPU-tf    sonic  R       0:02      1 node2
[sonic@master:DATA1]$ # 노드당 2개씩 총 4개의 작업이 작동 합니다.
[sonic@master:DATA1]$
[root@master:~]# sinfo    -o "%20P %5D  %20C %14F %6t  %8z  %10m %10d %11l %16f %N   %G"
PARTITION            NODES  CPUS(A/I/O/T)        NODES(A/I/O/T) STATE   S:C:T     MEMORY     TMP_DISK   TIMELIMIT   AVAIL_FEATURES   NODELIST   GRES
cpu                  2      8/72/0/80            2/0/0/2        mix     2:10:2    102400     0          1-00:00:00  (null)           node[1-2]   gpu:GTX1080Ti:4
gpu*                 2      8/72/0/80            2/0/0/2        mix     2:10:2    102400     0          1-00:00:00  (null)           node[1-2]   gpu:GTX1080Ti:4
[root@master:~]#

```
