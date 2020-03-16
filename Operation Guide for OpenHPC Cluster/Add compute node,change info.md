
### [7. 계산 노드 추가 및 정보 변경][contents]
새로운 계산노드가 추가 되거나, 고장 등으로 노드를 교체해야 할 때
마스터(로그인) 노드에 새로운 노드 정보를 추가 / 변경하는 방법 입니다.
```bash
wwsh node new node1 --netdev eth0 --ipaddr=10.1.1.11 --hwaddr=xx:xx:xx:xx:xx:xx --gateway=10.1.1.1 --netmask=255.255.255.0

wwsh provision set node1 --vnfs=centos7.6 --bootstrap=3.10.0-693.21.1.el7.x86_64 --files=dynamic_hosts,passwd,group,shadow,network

wwsh pxe update
systemctl restart dhcpd
```
