[userguide]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide#-%EB%AA%A9%EC%B0%A8
[ohpc]: http://openhpc.community/
[slurm]: https://slurm.schedmd.com/

# [5.   클러스터 자원사용][userguide]

안녕하세요 다산데이타 입니다.

HPC 클러스터에서 자원을 요청하고 할당 받아서
사용하는 방법에 대해 알아 보겠습니다.








--runtime=nvidia  -e NVIDIA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES


docker run  --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES   --rm  -v ~:/home/$USER  tensorflow/tensorflow:1.11.0-gpu-py3   python   ~/TensorFlow-Examples/examples/3_NeuralNetworks/neural_network.py



***
## [끝][userguide]
