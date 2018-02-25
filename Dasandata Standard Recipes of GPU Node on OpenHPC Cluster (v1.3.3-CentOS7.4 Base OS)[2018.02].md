# Dasandata Standard Recipes of GPU Node on OpenHPC Cluster (v1.3.3-CentOS7.4 Base OS)[2018.02]



```bash
[root@master:~]#
[root@master:~]# pwd
/root
[root@master:~]#
[root@master:~]# cat dasan_ohpc_variable.sh
#!/bin/bash

# 클러스터 이름.
export CLUSTER_NAME=OpenHPC-Dasandata

# MASTER 의 이름 과 IP.
export MASTER_HOSTNAME=$(hostname)
export MASTER_IP=10.1.1.1
export MASTER_PREFIX=24

# 인터페이스 이름.
export EXT_NIC=em2 # 외부망.
export INT_NIC=p1p1 # 내부망.
export NODE_INT_NIC=p1p1 # node 들의 내부망 인터페이스 명.

# NODE 의 이름, 수량, 사양.
export NODE_NAME=node
export NODE_NUM=3
export NODE_RANGE="[1-3]"  # 전체 노드가 3개일 경우 1-3 / 5대 일 경우 [1-5]

# NODE 의 CPU 사양에 맞게 조정.
# 물리 CPU가 2개 이고, CPU 당 코어가 10개, 하이퍼스레딩은 켜진(Enable) 상태 인 경우.  
export SOCKETS=2          ## 물리 CPU 2개
export CORESPERSOCKET=10  ## CPU 당 코어 10개
export THREAD=2           ## 하이퍼스레딩 Enable

# 노드 배포 이미지 경로.
export CHROOT=/opt/ohpc/admin/images/centos7.4

# end of file.
[root@master:~]#
[root@master:~]# vi dasan_ohpc_variable.sh
[root@master:~]#
[root@master:~]# source dasan_ohpc_variable.sh
[root@master:~]#
[root@master:~]# echo $CHROOT
/opt/ohpc/admin/images/centos7.4
[root@master:~]#

```





# END.
