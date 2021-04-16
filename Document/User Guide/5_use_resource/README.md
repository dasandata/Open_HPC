[userguide]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide#-%EB%AA%A9%EC%B0%A8
[ohpc]: http://openhpc.community/
[slurm]: https://slurm.schedmd.com/
[5]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide/5_use_resource
[5.1]: http://google.com
[5.2]: http://google.com
[5.3]: http://google.com

# [5.   클러스터 자원사용][userguide]

안녕하세요 다산데이타 입니다.

HPC 클러스터에서 자원을 요청하고 할당 받아서
사용하는 방법에 대해 알아 보겠습니다.

## ## 목차

[## 5.1  자원관리자(Resource Manager) 개요][5]  
[## 5.2  클러스터 자원배정(요청)][5]  
[## 5.3  제출된 작업의 우선순위, 시작예상시간][5]  

***

## [## 5.1  자원관리자(Resource Manager) 개요][5]  

**자원관리자(Resource Manager)** 는 보통 HPC 클러스터 환경에서만 접할 수 있는 도구로,
기본적으로 아래 그림과 같이(Backfil) 작업의 크기에 따라 가용한 자원에 작업을 분배하고  
자원이 모두 사용중일 때는 **대기열(queue)** 에 작업을 쌓아 두었다가  
사용가능한 자원이 확보되면, 대기하고 있던 작업을 시작시켜주는 역할을 하게 됩니다.

### [### 5.1.1 Resource Manager 의 Backfill][5.1]

<img src="http://docs.adaptivecomputing.com/torque/5-0-1/Content/Resources/Graphics/backfill.gif">  
***
<img src="https://image.news1.kr/system/photos/2019/5/3/3629007/article.jpg">
***

기본적으로 FIFO (First In, First Out) 방식 이지만,  
무분별한 자원 점유를 방지하고 자원을 공정하게 분배 하거나   
특정 사용자 와 그룹의 작업을 우선 배정하는 **우선순위(Priority)** 조정 기능도 지원 됩니다.

### [### 5.1.2 SLURM - Priority_and_Fair_Trees](https://slurm.schedmd.com/SLUG19/Priority_and_Fair_Trees.pdf)

<img src="https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/images/SLURM_Priority_and_Fair_Trees.png">

### [### 5.1.3 SLURM 구성 파일][5.1]

SLURM 은 다음과 같은 파일에 의해 구성 됩니다.  

| 위치              |  용도    |
|------------------|----------|
| /etc/slurm.conf  | 일반 Slurm 구성 정보, 관리 할 노드, 해당 노드가 파티션으로 그룹화되는 방법에 대한 정보 및 <br> 해당 파티션과 관련된 다양한 스케줄링 매개 변수를 지정. |
| /etc/gres.conf   | 각 계산 노드의 GRES (Generic RESource)의 구성 정보를 지정. <br> GRES는 그래픽 처리 장치 (GPU), CUDA MPS (다중 프로세스 서비스) 및 인텔 MIC (다중 통합 코어) 를 지원 합니다. <br> 일반적으로 GPU 구성에 대한 내용으로 작성 됩니다.  |

위 두 설정파일의 NodeName 항목을 통해 클러스터에서 사용되는 노드들의 세부 구성정보를 살펴볼 수 있습니다.

```bash
cat /etc/slurm/slurm.conf | grep ^NodeName

cat /etc/slurm/gres.conf
```

### [### 5.1.4 SLURM 명령][5.1]

| 명령어     |  내용    |
|-----------|----------|
| sinfo     | Slurm 노드 및 파티션에 대한 정보를 봅니다. <br> alias (별칭) 를 통해 `sinfolong` 과 같은 명령을 추가하여 상세한 정보를 표시 합니다.  |
| squeue    | Slurm 스케줄링 대기열에 있는 작업에 대한 정보를 봅니다. <br> alias (별칭) 를 통해 `squeuelong` 과 같은 명령을 추가하여 상세한 정보를 표시 합니다. |
| srun      | 실시간으로 실행할 작업을 제출하는 데 사용됩니다. <br> 명령어를 노드에 직접 입력하거나 작업 결과를 즉시 확인할 수 있는 대화형 작업을 시작 합니다. <br> 작업을 시작하기 위해 리소스를 할당 받아 노드에 진입하고 난 후에 <br> 작업이 끝나도 자동으로 종료되지 않으므로 **클러스터 자원이 낭비**되는 요인이 될 수 있습니다. <br> 가급적 디버깅 용도로만 사용는 것을 권장 합니다. <br> 일부 클러스터 시스템 에서는 srun 을 통한 작업의 제한시간이 sbatch 보다 짧게 설정 되는 경우가 있습니다. |
| sbatch    | Slurm에 배치(batch/일괄작업) 스크립트를 제출 합니다 <br> 제출된 작업은 가용한 자원이 있는 경우 즉시 실행되며, 없는 경우 대기열(queue) 에서 보류(pending) 됩니다. |
| scancel   | 제출된 작업을 취소 합니다. |
| scontrol  | 작업, 작업 단계, 노드, 파티션, 예약 및 전체 시스템 구성을 포함한 Slurm 구성을 보거나 수정하는 데 사용 합니다. <br> 일반 사용자의 경우 자신의 작업만 수정할 수 있습니다. (보는 것은 가능 합니다) |

### [### 5.1.5 SLURM 우선순위 정책][5.1]

아래 표시된 정책은 예시 이며 클러스터의 구축목적 과 관리정책에 따라 다를 수 있습니다.


#### #### 기본 정책
- 클러스터의 최대 작업시간 5일 (5-00:00:00) / 사용자의 최대 작업시간은 계정(Account) 별로 상이함.								
- 실제 사용량(RawUsage)많은 사용자의 작업 우선순위(PRIORITY)가 낮아 집니다. (FairShare)								
- 실제 사용량(RawUsage)이 동일하다면 기준 사용량(RawShares)이 많은 계정(그룹) 의 작업 우선순위(PRIORITY)가 높게 책정 됩니다.								
- 집계된 사용량은 1주 단위로 절반으로 감소 됩니다. (PriorityDecayHalfLife=7-0)								
- 집계된 사용량의 초기화 주기는 설정되지 않음. (PriorityUsageResetPeriod=0)								
- 집계된 사용량은 관리자 권한으로 초기화 가능 (sacctmgr modify account  $USERNAME  set rawusage=0)								
- 오랫동안 대기열에 머물러 있는 job은 7일 동안 우선순위 (Priority) 가 점차 상승 합니다. (PriorityMaxAge=7) / 최대 7일								
- 적용 우선순위 : 1.QOS / 2.Association / 3. Partition								

#### #### 사용자 개별 적용 정책
| 내용      |  명칭        |  값  |
|-----------|-------------|------|
| 실행 작업  |  MaxJobs=   |  10  |
| 제출 작업  |  MaxJobs=   |  20  |
| 최대 GPU  |  MaxTRES=   | gres/gpu=10 |

#### #### 계정(Account) 개별 적용 정책 (사용자 그룹)
| 내용                |  명칭              |  값  |
|--------------------|-------------------|------|
| 계정 이름           |  Account          |  default  |
| 기준 사용량         |  fairshare= <br> (RawShares)  | 10000 |
| 최대 실행 작업      |  GrpJobs=         |  100  |
| 최대 제출 작업      |  GrpSubmit=       |  200  |
| 최대 실행 시간      |  MaxWall= <br> (일-시간:분:초) | 3-00:00:00 |
| 최대 GPU 수        |  GrpTRESS=      |  gres/gpu=50 |

#### #### QOS 정책
| 내용                |  명칭              |  값  |
|--------------------|--------------------|------|
| 내용                |  name              |  value  |
|--------------------|--------------------|------|
| QOS 이름           |  Name              |  small-fast  |
| 우선 순위          |  Priority= <br>  (high->fast)  |  150  |
| 최대 실행 작업     |  MaxJobsPU=        |  default  |
| 최대 제출 작업     |  Account           |  default  |
| 최대 실행 기간     |  Account           |  default  |
| 최대 GPU 수        |  Account           |  default  |
| node당 최대 GPU    |  Account           |  default  |
| node당 최소 GPU    |  Account           |  default  |

#### #### 클러스터에 적용 되어 있는 설정 값 확인.
```bash
ssh MASTER  sacctmgr list   Cluster
ssh MASTER  sacctmgr list   Account
ssh MASTER  sacctmgr list   User
ssh MASTER  sacctmgr list   Association
ssh MASTER  sacctmgr list   QOS
```


***



```
--runtime=nvidia  -e NVIDIA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES


docker run  --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES   --rm  -v ~:/home/$USER  tensorflow/tensorflow:1.11.0-gpu-py3   python   ~/TensorFlow-Examples/examples/3_NeuralNetworks/neural_network.py

## docker sbatch
```


```bash
# UID, GID 확인.
id  


#
docker run -u $UID:$GROUPS --shm-size=4g --ulimit memlock=-1 --ulimit stack=67108864  --gpus "device=$CUDA_VISIBLE_DEVICES" --rm -ti -v /home/sonic/TensorFlow-2.x-Tutorials/03-Play-with-MNIST/:/mnt  tensorflow/tensorflow:latest-gpu  python /mnt/main.py
```


***
## [끝][5]
