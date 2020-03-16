
### [3. 네트워크 마운트 포인트 추가 (Add NFS Mount on nodes)][contents]
하드디스크 또는 스토리지를 추가로 장착하게 되어, 계산 노드들에서 사용할 수 있는 공유 저장 공간이
추가로 확보된 경우 마스터(로그인) 노드에 공유 설정을 추가하고, 노드에서 mount 하는 방법 입니다.

#### 3-1. master 의 nfs 설정 파일 위 및 현재 nfs 로 서비스 중인 경로 확인.
```
[root@master:~]# cat /etc/exports
/home *(rw,no_subtree_check,no_root_squash)
/opt/ohpc/pub *(ro,no_subtree_check)
[root@master:~]#
[root@master:~]#
[root@master:~]# exportfs
/home         	<world>
/opt/ohpc/pub 	<world>
[root@master:~]#
```

#### 3-2. 현재 node에서 nfs로 마운트 된 상태 확인. (pdsh 명령 이용)
```
[root@master:~]# pdsh -w node[1-2]  "df -hT | grep nfs"
node2: master:/home         nfs       932G  2.8G  929G   1% /home
node2: master:/opt/ohpc/pub nfs       899G   34G  865G   4% /opt/ohpc/pub
node1: master:/home         nfs       932G  2.8G  929G   1% /home
node1: master:/opt/ohpc/pub nfs       899G   34G  865G   4% /opt/ohpc/pub
[root@master:~]#
```

#### 3-3. master 에 /DATA1 이라는 nfs 서비스 경로 추가 및 설정 적용
```
[root@master:~]# cat /etc/exports
/home *(rw,no_subtree_check,no_root_squash)
/opt/ohpc/pub *(ro,no_subtree_check)
[root@master:~]#
[root@master:~]# echo "/DATA1 *(rw,no_subtree_check,no_root_squash)"  >>  /etc/exports
[root@master:~]#
[root@master:~]# cat /etc/exports
/home *(rw,no_subtree_check,no_root_squash)
/opt/ohpc/pub *(ro,no_subtree_check)
/DATA1 *(rw,no_subtree_check,no_root_squash)
[root@master:~]#
[root@master:~]# systemctl restart nfs-server.service
[root@master:~]#
[root@master:~]# exportfs
/home         	<world>
/opt/ohpc/pub 	<world>
/DATA1        	<world>
[root@master:~]#
```

#### 3-4. node 에 nfs 의 fstab 수정
```
[root@master:~]# pwd
/root
[root@master:~]#
[root@master:~]# chroot /opt/ohpc/admin/images/centos7.6
[root@master:/]# pwd
/
[root@master:/]#
[root@master:/]#
[root@master:/]# cat /etc/fstab
#GENERATED_ENTRIES#
tmpfs /dev/shm tmpfs defaults 0 0
devpts /dev/pts devpts gid=5,mode=620 0 0
sysfs /sys sysfs defaults 0 0
proc /proc proc defaults 0 0
master:/home /home nfs nfsvers=3,rsize=1024,wsize=1024,cto 0 0
master:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3 0 0
[root@master:/]#
[root@master:/]# echo "master:/DATA1 /DATA1 nfs nfsvers=3 0 0"   >> /etc/fstab
[root@master:/]#
[root@master:/]# cat /etc/fstab
#GENERATED_ENTRIES#
tmpfs /dev/shm tmpfs defaults 0 0
devpts /dev/pts devpts gid=5,mode=620 0 0
sysfs /sys sysfs defaults 0 0
proc /proc proc defaults 0 0
master:/home /home nfs nfsvers=3,rsize=1024,wsize=1024,cto 0 0
master:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3 0 0
master:/DATA1 /DATA1 nfs nfsvers=3 0 0
[root@master:/]#
[root@master:/]# mkdir /DATA1
[root@master:/]# exit
exit
[root@master:~]#
[root@master:~]# pwd
/root
[root@master:~]#
[root@master:~]#
[root@master:~]# wwvnfs --chroot /opt/ohpc/admin/images/centos7.6
Using 'centos7.6' as the VNFS name
Creating VNFS image from centos7.6
Compiling hybridization link tree                           : 0.33 s
Building file list                                          : 0.54 s
Compiling and compressing VNFS                              : 29.60 s
Adding image to datastore                                   : 24.16 s
Total elapsed time                                          : 54.63 s
[root@master:~]#
[root@master:~]#

** node 가 재부팅 된 후 새로운 경로가 잘 마운트 되었는지 확인 합니다.

[root@master:~]# pdsh -w node[1-2]  "reboot"

[root@master:~]#
[root@master:~]# pdsh -w node[1-2]  "df -hT | grep nfs"
node1: master:/home         nfs       932G  2.8G  929G   1% /home
node1: master:/opt/ohpc/pub nfs       899G   34G  865G   4% /opt/ohpc/pub
node1: master:/DATA1        nfs       3.7T  1.4G  3.7T   1% /DATA1
node2: master:/home         nfs       932G  2.8G  929G   1% /home
node2: master:/opt/ohpc/pub nfs       899G   34G  865G   4% /opt/ohpc/pub
node2: master:/DATA1        nfs       3.7T  1.4G  3.7T   1% /DATA1
[root@master:~]#
```
