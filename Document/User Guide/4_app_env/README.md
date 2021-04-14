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

git clone https://github.com/dragen1860/TensorFlow-2.x-Tutorials.git

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

### ### 4.1.2 Python + CUDA, tensorflow 환경 구성.

conda create 와 conda install 명령을 통해서  
python 3.6.5 / tensorflow-gpu 2.0 / cuda 10.0 / cudnn 7.4  으로 구성된 환경을 만들어 보겠습니다.

```bash
# 환경 생성.
conda create   -n PY3-Ten2-Cuda10.0    -c anaconda   python==3.6.5

# 생성된 환경 목록 확인.
conda env list

# 환경 활성화.
conda activate   PY3-Ten2-Cuda10.0

# cudatoolkit 설치 (cudnn 포함.)
conda  install   -c anaconda   cudatoolkit=10.0

# 활성화된 환경 안에서 python 과 pip 명령의 위치 확인.
which   python
which   pip

# 활성화된 환경 안에서 python 과 pip 명령의 버젼 확인.
python --version
pip    --version

# tensorflow-gpu 설치
pip  install   tensorflow-gpu==2.0

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
conda activate   PY3-Ten2-Cuda10.0

# 활성화된 환경 안에서 python 과 pip 명령의 버젼 확인.
python --version

# 설치된 tensorflow-gpu 버젼 확인.
pip list | grep tensorflow-gpu

# Sample Code 실행 1
python  TensorFlow-2.x-Tutorials/07-Inception/main.py

# Sample Code 실행 2
pip install scipy
python TensorFlow-2.x-Tutorials/13-DCGAN/main.py

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
conda deactiavte
conda env list

conda env export -n PY3-Ten2-Cuda10.0   >  ~/conda-py3-ten2-cuda10.yaml

file ~/conda-py3-ten2-cuda10.yaml

cat  ~/conda-py3-ten2-cuda10.yaml
```
***
#### 환경 제거.
```bash
conda deactiavte
conda env list

conda remoe  -n PY3-Ten2-Cuda10.0   --all
```
***
#### yaml 에서 환경 불러오기.
```bash
conda deactiavte
conda env list

conda env create   -f  ~/conda-py3-ten2-cuda10.yaml   -n  NEW-PY3-Ten2-Cuda10.0

conda env list
conda actiavte  NEW-PY3-Ten2-Cuda10.0

which python

python --version

python  TensorFlow-2.x-Tutorials/07-Inception/main.py
```

## [## 4.2  Module][4]  

cuda / nvcc

gnu gcc


## [## 4.3  Docker][4]  




## [## 4.4  Singularity][4]  




***
## [끝][userguide]
