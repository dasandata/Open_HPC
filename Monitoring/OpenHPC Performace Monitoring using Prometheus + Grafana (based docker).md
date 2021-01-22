

# OpenHPC Performace Monitoring using Prometheus + Grafana (based docker)

## Requirements  
 - openhpc node staeful setup  # docker image in physical disk and save docker config on nodes.


## Insatll Docker to Master & VNFS of openhpc nodes.
```bash
# Docker Install on master server.
yum-config-manager --add-repo \
   https://download.docker.com/linux/centos/docker-ce.repo

yum -y install docker-ce docker-ce-cli containerd.io

# Check selinx disable.
getenforce
grep  SELINUX= /etc/sysconfig/selinux

# Start & Enable Docker Daemon.
systemctl start  docker
systemctl enable docker

# Verify that Docker Engine running
docker run hello-world && docker images

# Docker Install on VNFS of OpenHPC Nodes.
wwsh vnfs list
export CHROOT=/opt/ohpc/admin/images/centos7.5-gpu

cp  /etc/yum.repos.d/docker-ce.repo  ${CHROOT}/etc/yum.repos.d/
yum -y --installroot=${CHROOT}   install  docker-ce docker-ce-cli containerd.io


grep 'SELINUX=' ${CHROOT}/etc/sysconfig/selinux  
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' ${CHROOT}/etc/selinux/config
grep 'SELINUX=' ${CHROOT}/etc/sysconfig/selinux  

chroot ${CHROOT}  systemctl enable docker
wwsh file resync  # docker /etc/group sync.

```



## Install Nvidia Docker to Master & VNFS of openhpc nodes.
```bash
# Nvidia-Docker Install on master server.
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo \
   | sudo tee /etc/yum.repos.d/nvidia-docker.repo

yum clean expire-cache
yum install -y nvidia-docker2
systemctl restart docker

docker run   --rm   --gpus all    nvidia/cuda:11.0-base    nvidia-smi

# Nvidia-Docker Install on VNFS of OpenHPC Nodes.
wwsh vnfs list
export CHROOT=/opt/ohpc/admin/images/centos7.5-gpu

cp /etc/yum.repos.d/nvidia-docker.repo  ${CHROOT}/etc/yum.repos.d/
yum -y --installroot=${CHROOT}  install   nvidia-docker2

wwvnfs --chroot  ${CHROOT}
```





## prometheus docker run
```bash
# Make Prometheus Config file (yaml).

mkdir /etc/prometheus

cat << EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label \`job=<job_name>\` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9090']
EOF

# run prometheus docker.
docker run --name prometheus -d -p 9090:9090 \
   -v /etc/prometheus/:/etc/prometheus/  \
   prom/prometheus

# Firewall Port Open 9090
firewall-cmd --list-all | grep 9090
firewall-cmd --add-port=9090/tcp
firewall-cmd --add-port=9090/tcp --permanent
firewall-cmd --list-all | grep 9090

# start prometheus docker at system restart
docker update --restart=always prometheus

# Open Broser to http://localhost:9090

```



## Install on node prometheus node expoter

```bash
# on node. run expoter
docker run -d --restart=always --name prometheus-node-exporter \
  --net="host" --pid="host" \
  -v "/:/host:ro,rslave" \
  quay.io/prometheus/node-exporter:latest \
  --path.rootfs=/host

# check exporter port.
netstat  -tnlp  | grep node_exporter

```

##

```bash
# on master, add scrape node info. * targets is node ip address.
cat << EOF >> /etc/prometheus/prometheus.yml

  - job_name: 'node-exporter'
    static_configs:
    - targets: ['10.1.1.78:9100']

EOF

docker restart prometheus

```



## Run prometheus nvidia dcgm expoter (prometheus-dcgm)

```bash
# on node.
docker run -d --restart=always --name dcgm-exporter \
  --gpus all -p 9400:9400 nvidia/dcgm-exporter:2.0.13-2.1.1-ubuntu18.04


# on master
cat << EOF >> /etc/prometheus/prometheus.yml

  - job_name: 'dcgm-exporter'
    static_configs:
    - targets: ['10.1.1.78:9400']

EOF

docker restart prometheus


```


## Grafana Docker

```bash
# on master.
docker run -d --restart=always --name grafana -p 3000:3000 grafana/grafana

docker ps | grep grafana

netstat  -tnlp | grep 3000

# Firewall Port Open 9090
firewall-cmd --list-all | grep 3000
firewall-cmd --add-port=3000/tcp
firewall-cmd --add-port=3000/tcp --permanent
firewall-cmd --list-all | grep 3000


# Open Broser to http://localhost:3000
# id : admin / pass : admin
```

## Grafana dashboard

https://grafana.com/grafana/dashboards



## END.
