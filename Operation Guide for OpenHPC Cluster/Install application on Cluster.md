
### [2. 계산 노드에 프로그램 추가 (Install App on nodes)][contents]
OpenHPC 는 [Warewulf](http://warewulf.lbl.gov/trac) 의 [DiskLess](https://en.wikipedia.org/wiki/Diskless_node) 방식을 기반으로 구성 되어 있어 (재 부팅시 배포 이미지를 내려 받음)
계산노드에 패키지(프로그램) 를 설치하는 경우 실행되고 있는 계산노드에 설치하는 것 뿐만 아니라
노드 재부팅후 또는 추가 되는 노드에 동일한 상태가 적용 되도록 노드의 배포 이미지에도 설치 되어야 합니다.

#### 2-1. 우선 현재 동작중인 노드에 yum 명령을 이용하여 프로그램 을 설치 합니다.
```
** 아래 예제는 git 을 설치 합니다.
** 여러 노드에 명령을 한꺼번에 전달하기 위해 pdsh 를 사용 합니다.
** 노드의 범위는 [ ] 사이에 넣습니다.
** node[1-2] 의 경우 node1 과 node2 를 뜻합니다.

[root@Master:~]# pdsh -w node[1-2] 'yum install -y git'
node1: Loaded plugins: fastestmirror
node1: Loading mirror speeds from cached hostfile
node1:  * base: data.nicehosting.co.kr
node1:  * epel: mirrors.ustc.edu.cn
node1:  * extras: data.nicehosting.co.kr
node1:  * updates: data.nicehosting.co.kr
node2: Loaded plugins: fastestmirror
node1: Resolving Dependencies
node1: --> Running transaction check
node1: ---> Package git.x86_64 0:1.8.3.1-12.el7_4 will be installed

<생략>

node2:
node2: Installed:
node2:   git.x86_64 0:1.8.3.1-12.el7_4
node2:
node2: Dependency Installed:
node2:   libgnome-keyring.x86_64 0:3.12.0-1.el7  perl-Error.noarch 1:0.17020-2.el7
node2:   perl-Git.noarch 0:1.8.3.1-12.el7_4      perl-TermReadKey.x86_64 0:2.30-20.el7
node2:
node2: Complete!
[root@Master:~]#
```
#### 2-2. 노드의 부팅 이미지에도 yum 명령을 이용하여 프로그램을 설치 합니다.

```
[root@Master:~]#
[root@Master:~]# yum --installroot=/opt/ohpc/admin/images/centos7.6/  install  -y  git
Loaded plugins: fastestmirror, langpacks, priorities
OpenHPC                                                      | 1.6 kB  00:00:00
OpenHPC-updates                                                                                    | 1.2 kB  00:00:00
base                                                         | 3.6 kB  00:00:00
epel/x86_64/metalink                                         | 5.4 kB  00:00:00
epel                                                         | 4.7 kB  00:00:00
extras                                                       | 3.4 kB  00:00:00
updates                                                      | 3.4 kB  00:00:00
(1/2): epel/x86_64/primary_db                                | 6.4 MB  00:00:01
(2/2): epel/x86_64/updateinfo                                | 919 kB  00:00:02
Determining fastest mirrors
 * base: ftp.kaist.ac.kr
 * epel: mirrors.ustc.edu.cn
 * extras: ftp.kaist.ac.kr
 * updates: ftp.kaist.ac.kr
139 packages excluded due to repository priority protections
Resolving Dependencies
--> Running transaction check
---> Package git.x86_64 0:1.8.3.1-12.el7_4 will be installed

<생략>

Installed:
  git.x86_64 0:1.8.3.1-12.el7_4

Dependency Installed:
  libgnome-keyring.x86_64 0:3.12.0-1.el7     perl-Error.noarch 1:0.17020-2.el7     perl-Git.noarch 0:1.8.3.1-12.el7_4
  perl-TermReadKey.x86_64 0:2.30-20.el7

Complete!
[root@Master:~]#
[root@Master:~]#
```

#### 2-3. 노드의 부팅 이미를 갱신 시킵니다.
```
[root@Master:~]# wwvnfs --chroot /opt/ohpc/admin/images/centos7.6
Using 'centos7.6' as the VNFS name
Creating VNFS image from centos7.6
Compiling hybridization link tree                           : 2.88 s
Building file list                                          : 2.11 s
Compiling and compressing VNFS                              : 53.87 s
Adding image to datastore                                   : 60.00 s
Total elapsed time                                          : 118.87 s
[root@Master:~]#
[root@Master:~]#
```
