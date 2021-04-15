[userguide]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide#-%EB%AA%A9%EC%B0%A8
[ohpc]: http://openhpc.community/
[slurm]: https://slurm.schedmd.com/
[4]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide/4_app_env

# [# 4.   응용프로그램 사용환경 구성 및 시험][userguide]

안녕하세요 다산데이타 입니다.

HPC 클러스터에서 응용프로그램 사용환경을 구성하고
응용프로그램을 시험구동 하는 방법을 알아 보겠습니다.

***
## [## TensorFlow Example Download][4]

시작하기에 앞서 시험구동에 사용할 TensorFlow Sample Code를 다운로드 합니다.

```bash
cd ~  # change directory to HOME.

git   clone   https://github.com/aymericdamien/TensorFlow-Examples

```

## [## 4.1  Anaconda][4]

### ### 4.1.1 Anaconda 다운로드 및 설치.

웹브라우져로 Anaconda download 페이지에서 [Linux] -> [64-Bit (x86) Installer (529 MB)] 를   
마우스 포인터로 가르킨 후 오른쪽 클릭하여 "링크주소 복사" 를 합니다.  

### https://www.anaconda.com/products/individual

<img src="https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/images/anaconda_copy_download_link.png">

***

터미널 창에 wget 명령을 입력한 후, 복사된 링크를 붙여넣고 실행하면 다운로드가 시작 됩니다.

```bash
wget https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh
```

다운로드가 완료되면 저장된 파일을 확인 한 후 실행하여 설치를 진행 합니다.

```bash
ls -lh   # l = 목록(list) 형태로 출력  , h = human-readable (숫자를 사람이 읽기 쉬운 단위로 표시).

file Anaconda3-2020.02-Linux-x86_64.sh   # 파일이 어떤 형식으로 되어있는시 확인할 수 있습니다.

bash  Anaconda3-2020.02-Linux-x86_64.sh  # 스크립트 파일을 실행.
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
python 3.6.5 / tensorflow-gpu 2.0 / cuda 10.0 / cudnn 7.4  으로 구성된 환경을 만들어 보겠습니다.

```bash
# 환경 생성.
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

# tensorflow-gpu 설치
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

이제 방금 생성한 환경으로 TensorFlow Sample Code 를 실행해 보겠습니다.  

```bash
# 생성된 환경 목록 확인.
conda env list

# 환경 활성화.
conda activate   py36-tf1.11-cuda9.0  

# 활성화된 환경 안에서 python 과 pip 명령의 버젼 확인.
python --version

# 설치된 tensorflow-gpu 버젼 확인.
pip list | grep tensorflow-gpu

# Sample Code 실행 1 (short)
python  TensorFlow-Examples/examples/3_NeuralNetworks/neural_network_raw.py

# Sample Code 실행 2 (long)
pip install matplotlib
python  TensorFlow-Examples/examples/3_NeuralNetworks/dcgan.py

```

***

Sample Code 가 gpu 에서 잘 작동 되는지 확인하기 위해  
터미널 창을 하나 더 열어서 클러스터에 접속 합니다.  

```bash
# gpu 사용률 확인 1
gpustat

# gpu 사용률 확인 2
nvidia-smi
nvidia-smi --loop=2
```

### ### 4.1.4 Anaconda 환경 yaml 로 내보내기, 제거, yaml 에서 불러오기.

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

python  TensorFlow-Examples/examples/3_NeuralNetworks/neural_network_raw.py

conda deactivate
```

## [## 4.2  Module][4]  

### ### Module 이란
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

env
```

## [## 4.3  Docker][4]  




## [## 4.4  Singularity][4]  




***
## [끝][userguide]
