[userguide]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide#-%EB%AA%A9%EC%B0%A8
[ohpc]: http://openhpc.community/
[slurm]: https://slurm.schedmd.com/

[4]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide/4_app_env
[4.1]: https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/4_app_env/4.1_Anaconda.md
[4.2]: https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/4_app_env/4.2_Module.md
[4.3]: https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/4_app_env/4.3_Docker.md
[4.4]: https://github.com/dasandata/Open_HPC/blob/master/Document/User%20Guide/4_app_env/4.4_Singularity.md

# [# 4.   응용프로그램 사용환경 구성 및 시험][userguide]

안녕하세요 다산데이타 입니다.  

HPC 클러스터에서 응용프로그램 사용환경을 구성하고  
응용프로그램을 시험구동 하는 방법을 알아 보겠습니다.  

아래와 같은 순서로 진행 됩니다.  
환경구성 -> 샘플코드 시험구동 -> 스크립트 파일로 작성하여 실행.

## [## TensorFlow Example Download][4]

시작하기에 앞서 시험구동에 사용할 TensorFlow Sample Code를 다운로드 합니다.  

```bash
cd ~  # change directory to HOME.

git   clone   https://github.com/aymericdamien/TensorFlow-Examples

```
## ## 목차
[4.1  Anaconda][4.1]  
[4.2  Module][4.2]  
[4.3  Docker][4.3]  
[4.4  Singularity][4.4]  

***
## [끝][userguide]
