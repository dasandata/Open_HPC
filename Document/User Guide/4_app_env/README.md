[userguide]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide#-%EB%AA%A9%EC%B0%A8
[ohpc]: http://openhpc.community/
[slurm]: https://slurm.schedmd.com/
[4]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide/4_app_env

# [# 4.   응용프로그램 사용환경 구성 및 시험][userguide]

안녕하세요 다산데이타 입니다.

HPC 클러스터에서 응용프로그램 사용환경을 구성하고
응용프로그램을 시험구동 하는 방법을 알아 보겠습니다.

***
## [## gpu cluster 용 tensorflow example download][4]

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
아래 명령을 입력해서 로그인시 base 환경이 자동으로 활성화 되지 않도록 합니다.   

```bash
conda config --set auto_activate_base false
```

### ### 4.1.2 Python + CUDA, tensorflow 환경 구성.

TensorFlow
Python
tensorflow


## [## 4.2  Module][4]  

cuda / nvcc

gnu gcc


## [## 4.3  Docker][4]  




## [## 4.4  Singularity][4]  




***
## [끝][userguide]
