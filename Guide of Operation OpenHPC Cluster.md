# Dasandata Opertation Guide of OpenHPC Cluster
\# 참조 링크 : http://openhpc.community/  
\# OpenHPC Cluster를 운영 하면서 필요한 명령어들 입니다.  
***
## # 목차
[1. 사용자 추가 (add user)]  
[2. 계산 노드에 프로그램 추가 (Install App on nodes)]  

***

### 1. 사용자 추가 (add user)

```bash

wwshuseradd

```


### 2. 계산 노드에 프로그램 추가 (Install App on nodes)

```bash

```

### 3. 네트워크 마운트 포인트 추가 (Add NFS Mount on nodes)

```bash

```

### 4. Add Module

```bash

```


### 5. Nodes Power On / Off
#### Power On
- ipmi (iDrac)
- WOL (Wake On Lan)

#### Power Off
- ipmi (iDrac)
- pdsh -w

```bash

```


### 6. master hostname 변경.

```bash
grep -r ${OLD_HOSTNAME} /etc/


```



### 7. 계산 노드 추가 / macaddress 변경

```bash

wwsh node add


wwsh node set

wwsh pxe update
systemctl restart dhcpd

```



## End.
