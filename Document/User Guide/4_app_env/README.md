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

### ### 4.1.1 Anaconda 설치.

웹브라우져로 Anaconda download 페이지에서 [Linux] -> [64-Bit (x86) Installer (529 MB)] 를   
마우스 포인터로 가르킨 후 오른쪽 클릭하여 "링크주소 복사" 를 합니다.  

### https://www.anaconda.com/products/individual

<img src="https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/images/anaconda_copy_download_link.png">

***

터미널 창에 wget 명령을 입력한 후, 복사된 링크를 붙여넣고 실행하면 다운로드가 시작 됩니다.

```bash
wget https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh
```





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
