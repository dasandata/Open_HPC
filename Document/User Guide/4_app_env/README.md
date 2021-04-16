[userguide]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide#-%EB%AA%A9%EC%B0%A8
[ohpc]: http://openhpc.community/
[slurm]: https://slurm.schedmd.com/
[4]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide/4_app_env

# [# 4.   응용프로그램 사용환경 구성 및 시험][userguide]

안녕하세요 다산데이타 입니다.  

HPC 클러스터에서 응용프로그램 사용환경을 구성하고  
응용프로그램을 시험구동 하는 방법을 알아 보겠습니다.  

환경구성 -> 샘플코드 시험구동 -> 스크립트파일로 작성하여 실행 하는 순서로 진행 됩니다.  

***
## [## TensorFlow Example Download][4]

시작하기에 앞서 시험구동에 사용할 TensorFlow Sample Code를 다운로드 합니다.  

```bash
cd ~  # change directory to HOME.

git   clone   https://github.com/aymericdamien/TensorFlow-Examples

```

## [## 4.1  Anaconda][4]

### ### Anaconda 란.
사용자의 Home 디렉토리에 설치해서 다양한 버젼의 Python 을 설치하고   
쉽게 전환하며 사용할 수 있게 해주는 도구.  

### ### 4.1.1 Anaconda 다운로드 및 설치.

웹 브라우져로 Anaconda download 페이지에 접속 한 후   
[Download] -> [Linux] -> [64-Bit (x86) Installer (529 MB)] 를   
마우스 포인터로 가르킨 후 **오른쪽** 클릭하여 "링크주소 복사" 를 합니다.  

### https://www.anaconda.com/products/individual

<img src="https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/images/anaconda_copy_download_link.png">

***

터미털 창에서 HOME 디렉토리로 이동한 다음  
wget 명령과 함께 복사된 링크를 붙여넣고 실행하면 다운로드가 시작 됩니다.  

```bash
cd ~   # ~   =>>  사용자의 home 디렉토리 경로

wget https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh
```

다운로드가 완료되면 저장된 파일을 확인 한 후 실행하여 설치를 진행 합니다.

```bash
ls -lh   # l = 목록(list) 형태로 출력  , h = human-readable (숫자를 사람이 읽기 쉬운 단위로 표시).

file  ~/Anaconda3-2020.11-Linux-x86_64.sh  # 파일이 어떤 형식으로 되어있는시 확인.

bash  ~/Anaconda3-2020.11-Linux-x86_64.sh  # 스크립트 파일을 실행.
```

* license terms 는 yes 입력.   
* 설치 경로는 기본값 "/home/<User ID>/anaconda3" 그대로 Enter.    
* running conda init 는 yes 입력.   

`conda env list` 명령을 입력하면 기본 설치된 "base" 환경(environments)이 확인 됩니다.  
<br>
아래 명령을 입력해서 로그인시 base 환경이 자동으로 활성화 되지 않도록 합니다.   

```bash
conda config --set auto_activate_base false
```

conda를 최신 버젼으로 업데이트 합니다.
```bash
conda update -n base -c defaults conda
```

### ### 4.1.2 Python + CUDA, tensorflow 환경 구성.

conda create 와 conda install 명령을 통해서   
[ python 3.6.5 | tensorflow-gpu 1.11 | cuda 9.0 | cudnn 7 ] 로 구성된 환경을 만들어 보겠습니다.

```bash
# 환경 생성.     (-n == name ,            -c == channel)
conda create    -n py36-tf1.11-cuda9.0    -c anaconda    python=3.6  cudatoolkit=9.0  cudnn=7

# 생성된 환경 목록 확인.
conda env list

# 환경 활성화.
conda activate   py36-tf1.11-cuda9.0  

# 활성화된 환경 안에서 python 과 pip 명령의 위치 확인.
which   python
which   pip

# 활성화된 환경 안에서 python 과 pip 명령의 버젼 확인.
python --version
pip    --version

# tensorflow-gpu 1.11 설치
pip  install   tensorflow-gpu==1.11

# 설치된 tensorflow-gpu 버젼 확인.
pip list | grep tensorflow-gpu

# 환경 비활성화
conda deactiavte

#비활성화 된 환경에서 python 과 pip 명령 위치 확인.
python --version
pip    --version
```

### ### 4.1.3 Anaconda 환경에서 TensorFlow Sample Code 실행.

만들어진 환경을 활성화 해서 TensorFlow Sample Code 를 실행해 보겠습니다.  

```bash
# 생성된 환경 목록 확인.
conda env list

# 환경 활성화.
conda activate   py36-tf1.11-cuda9.0  

# 활성화된 환경 안에서 python 과 pip 명령의 버젼 확인.
python --version

# 설치된 tensorflow-gpu 버젼 확인.
pip list | grep tensorflow-gpu

# Sample Code 를 실행해 보기 전에 gpu 상태 확인
gpustat

nvidia-smi

# Sample Code 실행 1 (short)
python  ~/TensorFlow-Examples/examples/3_NeuralNetworks/neural_network_raw.py

# Sample Code 실행 2 (long)
pip install matplotlib
python  ~/TensorFlow-Examples/examples/3_NeuralNetworks/dcgan.py

```

***

Sample Code 가 gpu 에서 잘 작동 되는지 확인하기 위해  
터미널 창을 하나 더 열어서 클러스터에 접속 합니다.  

```bash
watch   gpustat

nvidia-smi --loop=2  # loop

watch   'nvidia-smi ; echo ; gpustat'
```

### ### 4.1.4 스크립트(Script) 파일로 작성하여 실행해 보기.
```bash
cat << EOF >  ~/anaconda-py36-tf1.11-Example.sh
# HOME 디렉토리로 이동.  
cd ~

# bashrc 불러오기.  
source  .bashrc

# conda 환경 비활성화.  
conda deactivate

# 원하는 conda 환경 활성화.  
conda activate   py36-tf1.11-cuda9.0  

# 샘플코드 실행.
python  ~/TensorFlow-Examples/examples/3_NeuralNetworks/neural_network_raw.py

# End.
EOF
```

```bashrc
cat ~/anaconda-py36-tf1.11-Example.sh

bash ~/anaconda-py36-tf1.11-Example.sh
```


### ### 4.1.5 Anaconda 환경 yaml 로 내보내기, 제거, yaml 에서 불러오기.

#### Anaconda 환경 yaml 로 내보내기.
```bash
conda deactivate
conda env list

conda env export  -n py36-tf1.11-cuda9.0   >   ~/conda-py3-ten1.11-cuda9.yaml

file ~/conda-py3-ten1.11-cuda9.yaml

cat  ~/conda-py3-ten1.11-cuda9.yaml
```
***
#### 환경 제거.
```bash
conda deactivate
conda env list

conda remove  -n py36-tf1.11-cuda9.0  --all

conda env list
```
***
#### yaml 에서 환경 불러오기.
```bash
conda deactivate
conda env list

conda env create   -f ~/conda-py3-ten1.11-cuda9.yaml   -n NEW-py36-tf1.11-cuda9.0

conda env list
conda activate  NEW-py36-tf1.11-cuda9.0

which python
python --version
pip list | grep tensorflow-gpu

python  ~/TensorFlow-Examples/examples/3_NeuralNetworks/neural_network_raw.py

conda deactivate
```

### ### 4.1.6 로그인시 anaconda 기본 환경 구성 (bashrc / rc = Run command)

`~/.bashrc` 파일에 `conda  activate  py36-tf1.11-cuda9.0` 를 추가 하면
로그인 할때마다 해당 환경이 기본으로 activate 됩니다.

```bash
vi ~/.bashrc

exit

conda env list
```

## [## 4.2  Module][4]  

### ### Module 이란.
클러스터에 설치된 **공유 프로그램을 사용**하기 위해서  
사전에 정의된 환경변수(PATH)를 불러오거나(load) 전환(swap) 할 수 있는 도구 입니다.  

https://modules.readthedocs.io/en/latest/   

클러스터 에서 사용할 수 있는 디스크 용량이 한정적 이기 때문에  
사용 가능한 공유 프로그램이 있다면 활용하는 것이 좋습니다.
또한 anaconda 같은 도구에서 제공되지 않는 프로그램을
관리자에게 설치 요청하여 사용할 수 있습니다.


### ### 현재 사용중인 용량과 가능한 용량 확인.
```bash
# anaconda 설치 용량 확인.
du -h -d 0 ~/anaconda3/

# home directory 전체 용량 확인.
df -hT /home

# 할당된(quota) 용량 확인
ssh  MASTER   '/usr/sbin/xfs_quota -xc "quota -h $USER"'
```

### ### module 명령어
```bash
module

#  module list  ==  ml
#  module avail ==  ml av

# 현재 load 되어 있는 module 목록  
ml list

# 사용 가능한 module 목록  
ml av

# 일부 module 내리기
ml unload cuda  
ml list

# 모든 module 내리기(all unload)
ml purge
ml list

# module 올리기 (load)
ml load ohpc  # ohpc == default load module name
ml   ##  ml == ml list or module list

# 일부 moudel 바꾸기 (swap)
ml
ml av

ml swap  cuda/11.2   cuda/9.0
ml

# module 의 상세 정보 출력
ml show ohpc
ml show cuda/9.0
```

### ### module 사용 예

#### cuda / nvcc
```bash
ml purge
ml

which nvcc ; echo ; nvcc -V

ml av | grep cuda
ml load cuda/9.0

which nvcc ; echo ; nvcc -V

ml swap   cuda/9.0  cuda/11.2
which nvcc ; echo ; nvcc -V
```

#### gnu gcc
```bash
ml purge
ml

which gcc  ; echo ; gcc --version

ml av | grep gnu
ml load gnu/5.4.0

which gcc  ; echo ; gcc --version

ml swap   gnu/5.4.0  gnu7
ml

which gcc  ; echo ; gcc --version
```

#### 환경변수(PATH, env) 의 변화
```bash
ml purge
echo $PATH

ml load gnu/5.4.0
echo $PATH

env | grep PATH
```


### ### bash script 파일로 작성
```bash

vi ~/module_test.sh

bash ~/module_test.sh
```

### ### 로그인시 module 기본 환경 구성 (bashrc / rc = Run command)

`~/.bashrc` 파일에 `module swap cuda/9.0  cuda/11.2` 를 추가 하면
로그인 할때마다 해당 환경이 기본으로 load 됩니다.

```bash
vi ~/.bashrc

exit

ml list
```



## [## 4.3  Docker][4]  

운영체제 수준의 가상화로 리눅스 커널을 공유하면서 프로세스를 격리된 환경에서 실행하는 기술.  

### ### Docker 를 사용할 수 있는지 확인.
```bash
grep docker /etc/group | grep $USER

docker --version
```
docker group 에 계정이 포함되어 있지 않다면 docker 명령을 실행할 수 없습니다.  
docker 그룹에 포함될 수 있도록 관리자에게 요청하십시요.  
docker run 명령을 실행하는 경우 항상 `-u $UID:$GROUPS` 옵션이 포함되어야 합니다.  

***

### ### Docker hub 에서 원하는 이미지 찾기.

https://hub.docker.com/


### ### Docker 기본 명령.
```bash
# Docker 버젼 확인.
docker --version

# Download 되어 있는 docker image 목록 확인.
docker images

# 실행중인 Docker Process (컨테이너) 목록 확인.
docker ps

# 실행중 이지 않은 Docker Process (컨테이너) 까지 포함한 목록 확인.
docker ps -a

# ubuntu 20.4 image 내려받기.
docker pull ubuntu:20.04

# 내려받은 이미지가 목록에 추가 되었는지 확인.
docker images | grep ubuntu

# ubuntu:20.04 이미지를 이용한 생성되는 프로세스(컨테이너) 안에서 "cat /etc/os-release" 명령어 실행.
docker run -u $UID:$GROUPS  ubuntu:20.04  cat /etc/os-release

# 비교를 위해 os 에서 "cat /etc/os-release" 명령어 실행.
cat /etc/os-release

# docker 프로세스(컨테이너) 로 들어가서 직접 명령 실행. (-it 옵션)
docker run -u $UID:$GROUPS  -it  ubuntu:20.0
```

***

```bash
# docker 프로세스(컨테이너) 삭제
docker ps
docker ps -a

docker stop   <CONTAINER ID>
docker rm     <CONTAINER ID>

docker ps -a

# docker 프로세스(컨테이너) 가 작업이 끝나는데로 삭제 (--rm)
docker ps -a
docker run  -u $UID:$GROUPS        ubuntu:20.04    cat /etc/os-release
docker ps -a
docker rm   <CONTAINER ID>
docker ps -a

docker ps -a
docker run  -u $UID:$GROUPS  --rm  ubuntu:20.04    cat /etc/os-release
docker ps -a
```

***

```bash
# docker image 삭제  /  이미지를 이용해 구동중인 프로세스(컨테이너) 가 없는 상태여야 함.
docker images

docker rmi  <IMAGE ID>

docker images
```

### ### TensorFlow Docker 컨테이너로 파이썬 코드 실행. (--runtime=nvidia 옵션)

```
docker run -u $UID:$GROUPS --runtime=nvidia --rm tensorflow/tensorflow:1.11.0-gpu-py3  pip list | grep tensor

docker run -u $UID:$GROUPS --runtime=nvidia --rm tensorflow/tensorflow:1.11.0-gpu-py3  \
   python   ~/TensorFlow-Examples/examples/3_NeuralNetworks/neural_network_raw.py

### 오류가 발생 합니다. TensorFlow-Examples 파일이 docker 이미지 내부에 없습니다.

docker run -u $UID:$GROUPS --runtime=nvidia  --rm  tensorflow/tensorflow:1.11.0-gpu-py3   ls -l
docker run -u $UID:$GROUPS --runtime=nvidia  --rm  tensorflow/tensorflow:1.11.0-gpu-py3   pwd
docker run -u $UID:$GROUPS --runtime=nvidia  --rm  tensorflow/tensorflow:1.11.0-gpu-py3   ls -l ~

### -V (Volume)옵션을 통해 directory 를 연결 시켜 줍니다.
pwd
ls -l  

docker run -u $UID:$GROUPS --runtime=nvidia  --rm  -v ~:/home/$USER  tensorflow/tensorflow:1.11.0-gpu-py3    ls -l ~

### sample data file 이 download 되는 tmp 폴더도 연결 시킵니다.
mkdir /tmp/$USER
docker run -u $UID:$GROUPS --runtime=nvidia  --rm  -v ~:/home/$USER  -v /tmp/$USER:/tmp  \
   tensorflow/tensorflow:1.11.0-gpu-py3  python  ~/TensorFlow-Examples/examples/3_NeuralNetworks/neural_network_raw.py

```

### ### HPC 클러스터 환경에서 Docker의 문제점

모든 작업이 `root` 권한으로 실행된다.   
다른 사용자의 작업이나 컨테이너(프로세스) 를 제어하거나,
심지어 다른 사용자의 데이터까지 접근할 수 있다.

docker image 가 /var/lib/docker 아래에 저장되어 local disk 가 필요하게 된다.




## [## 4.4  Singularity][4]  

과학 및 애플리케이션 기반 워크로드의 필요성에 의해 생성 된 컨테이너 솔루션
Docker 저장소의 이미지를 내려받을 수 있다.

### ### Singularity 사용 가능한지 확인.
```bash
ml | grep singularity

which singularity

```

### ### Singularity 기본 명령.
```
# 버젼 확인.
singularity  --version

# 이미지 다운로드 (docker 의 pull 과 동일함.) / simg = Singularity Image
singularity  build  ~/tf-1.11-gpu-py3.simg  docker://tensorflow/tensorflow:1.11.0-gpu-py3

# 다운로드 된 이미지 파일 확인.
ll   -trh   ~/tf-1.11-gpu-py3.simg
file        ~/tf-1.11-gpu-py3.simg

# 이미지 실행(exec)  (--nv 옵션 = GPU 사용)    
singularity exec --nv   ~/tf-1.11-gpu-py3.simg    pip list | grep tensor

# 코드 실행.  (singularity 의 경우 home 디렉토리는 기본으로 mount 됩니다.)
singularity exec --nv ~/tf-1.11-gpu-py3.simg  \
   python  TensorFlow-Examples/examples/3_NeuralNetworks/neural_network_raw.py

# 볼롬 마운트 (dataset)

singularity exec --nv -B /dataset:/dataset   ~/tf-1.11-gpu-py3.simg   ls -l /dataset



```











***
## [끝][userguide]
