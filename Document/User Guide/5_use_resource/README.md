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
## [## 5.1  자원관리자(Resource Manager) 개요][5.1]  
## [## 5.2  클러스터 자원배정(요청)][5.2]  
## [## 5.3  제출된 작업의 우선순위, 시작예상시간][5.3]  



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
