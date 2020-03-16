# [1. 사용자 계정 관리 (추가 및 제거)][contents]
## 1-1. 사용자 계정 추가
클러스터에 새로운 사용자가 추가된 경우 아래와 같은 작업을 수행하여
새로운 사용자가 계산 노드들을 사용할 수 있게 합니다.
```
# testuser 계정 추가.
# -m : crate user home dir,  --uid : user ID
[root@master:~]# useradd -m --uid 2001 testuser
[root@master:~]#
[root@master:~]# passwd testuser
Changing password for user testuser.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.

# Account files sync.
[root@master:~]# wwsh file resync
[root@master:~]#

# Download account file from master to node.
[root@master:~]# pdsh -w node[1-3] 'rm -rf /tmp/.wwgetfile*  &&  /warewulf/bin/wwgetfiles'

```

## 1-2. 사용자 계정 제거
더이상 사용되지 않는 사용자 계정을 제거 합니다.
```
# testuser 사용자 제거
[root@master:~]# userdel testuser

# testuser 사용자 home 디렉토리 제거
[root@master:~]# rm -rf /home/testuser/

[root@master:~]# wwsh file resync
```
