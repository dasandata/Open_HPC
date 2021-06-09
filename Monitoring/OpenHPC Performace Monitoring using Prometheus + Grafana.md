
# # OpenHPC Performace Monitoring using Prometheus + Grafana (based docker)

[contents]: https://github.com/dasandata/Open_HPC/blob/master/Monitoring/OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#%EB%AA%A9%EC%B0%A8
[1]: https://github.com/dasandata/Open_HPC/blob/master/Monitoring/OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-1-insatll-docker-to-master--vnfs-of-openhpc-nodes
[2]: https://github.com/dasandata/Open_HPC/blob/master/Monitoring/OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-2-install-nvidia-docker-to-master--vnfs-of-openhpc-nodes
[3]: https://github.com/dasandata/Open_HPC/blob/master/Monitoring/OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-3-prometheus-docker-run-on-master
[4]: https://github.com/dasandata/Open_HPC/blob/master/Monitoring/OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-4-run-on-node-prometheus-node-expoter
[5]: https://github.com/dasandata/Open_HPC/blob/master/Monitoring/OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-5-add-scrape-node-info-to-master
[6]: https://github.com/dasandata/Open_HPC/blob/master/Monitoring/OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-6-run-prometheus-nvidia-dcgm-expoter-prometheus-dcgm
[7]: https://github.com/dasandata/Open_HPC/blob/master/Monitoring/OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-7-add-script--crontab-for-start-docker-process-after-node-reboot
[8]: https://github.com/dasandata/Open_HPC/blob/master/Monitoring/OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-8-prometheus-slurm-exporter--for-centos7-only-master-
[9]: https://github.com/dasandata/Open_HPC/blob/master/Monitoring/OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-9-prometheus-ipmi-exporter--for-centos7-only-master-
[10]: https://github.com/dasandata/Open_HPC/blob/master/Monitoring/OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-10-grafana-install-on-master
[11]: https://github.com/dasandata/Open_HPC/blob/master/Monitoring/OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#-11-grafana-report-to-pdf
[grafanadashboards]: https://github.com/dasandata/Open_HPC/blob/master/Monitoring/OpenHPC%20Performace%20Monitoring%20using%20Prometheus%20%2B%20Grafana.md#grafana-dashboardshttpsgrafanacomgrafanadashboards

## ## Requirements  
 - openhpc node staeful setup  # docker image in physical disk and save docker config on nodes.

## 목차  

### [1. Insatll Docker to Master & VNFS of openhpc nodes.][1]
### [2. Install Nvidia Docker to Master & VNFS of openhpc nodes.][2]
### [3. Prometheus docker run on master.][3]
### [4. Run on node prometheus-node-expoter][4]
### [5. add scrape node info to master][5]
### [6. Run prometheus nvidia dcgm expoter (prometheus-dcgm)][6]
### [7. Add script & Crontab, for Start docker process after node reboot][7]  
### [8. Prometheus-slurm exporter ( For Centos7, Only Master )][8]
### [9. Prometheus-ipmi exporter ( For Centos7, Only Master )][9]
### [10. Grafana Install (on Master)][10]
### [11. Grafana Report to PDF][11]
### [Grafana dashboards][grafanadashboards]

### [END.][contents]

***

## ## [1. Insatll Docker to Master & VNFS of openhpc nodes.][contents]
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


## ## [2. Install Nvidia Docker to Master & VNFS of openhpc nodes.][contents]
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



## ## [3. Prometheus docker run on master.][contents]
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


# Make Prometheus Data folder.

adduser --uid 9090 --no-create-home  --shell /sbin/nologin   prometheus

mkdir   /var/lib/prometheus/
chown   prometheus:prometheus    /var/lib/prometheus/

# run prometheus docker.
docker run \
   --name prometheus -d -p 9090:9090 \
   --user 9090:9090   \
   -v /etc/prometheus/:/etc/prometheus/  \
   -v /var/lib/prometheus/:/prometheus/  \
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



## ## [4. Run on node prometheus-node-expoter][contents]
```bash
# on node. run expoter
docker run -d --restart=always --name node-exporter \
  --net="host" --pid="host" \
  -v "/:/host:ro,rslave" \
  quay.io/prometheus/node-exporter:latest \
  --path.rootfs=/host

# check exporter port.
netstat  -tnlp  | grep node_expo

```

## ## [5. add scrape node info to master][contents]

```bash
# on master, add scrape node info. * targets is node ip address.
cat << EOF >> /etc/prometheus/prometheus.yml

  - job_name: 'node-exporter'
    static_configs:
  - targets: ['10.1.1.254:9100']
      labels:
        note: 'master-node'
  - targets: ['10.1.1.1:9100','10.1.1.2:9100','10.1.1.3:9100','10.1.1.4:9100']
      labels:
        note: 'compute-node'

EOF

docker restart prometheus

```


## ## [6. Run prometheus nvidia dcgm expoter (prometheus-dcgm)][contents]
```bash
# on node.
docker run -d --restart=always --name dcgm-exporter \
  --gpus all -p 9400:9400 nvidia/dcgm-exporter:2.0.13-2.1.1-ubuntu18.04


# on master
cat << EOF >> /etc/prometheus/prometheus.yml

  - job_name: 'dcgm-exporter'
    static_configs:
    - targets: ['10.1.1.254:9400']
    labels:
      note: 'master-node'
  - targets: ['10.1.1.1:9400','10.1.1.2:9400','10.1.1.3:9400','10.1.1.4:9400']
    labels:
      note: 'compute-node'
EOF

docker restart prometheus

```

## ## [7. Add script & Crontab, for Start docker process after node reboot][contents]  
```bash
# make script folder
mkdir /opt/ohpc/pub/script

cat << EOF > /opt/ohpc/pub/script/docker-run-prometheus-exporter.sh

# node-exporter
docker run -d --restart=always --name node-exporter \\
  --net="host" --pid="host" \\
  -v "/:/host:ro,rslave" \\
  quay.io/prometheus/node-exporter:latest \\
  --path.rootfs=/host

# dcgm-exporter
docker run -d --restart=always --name dcgm-exporter \\
  --gpus all -p 9400:9400 \\
  nvidia/dcgm-exporter:2.0.13-2.1.1-ubuntu18.04

EOF

chmod a+x  /opt/ohpc/pub/script/docker-run-prometheus-exporter.sh

# Check vnfs PATH to chaing export CHROOT.
wwsh vnfs list
export CHROOT=/opt/ohpc/admin/images/centos7

# add crontab node vnfs
cat << EOF >> ${CHROOT}/etc/crontab

# docker-run-prometheus-node-exporter at Reboot.
@reboot    root    /opt/ohpc/pub/script/docker-run-prometheus-exporter.sh

EOF

cat  ${CHROOT}/etc/crontab

# vnfs update.
wwvnfs --chroot  ${CHROOT}
```



## ## [8. Prometheus-slurm exporter ( For Centos7, Only Master )][contents]
```bash
# only master.

cd /tmp/

# Donwload go 1.15
export VERSION=1.15 OS=linux ARCH=amd64
wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz

tar -xzf go$VERSION.$OS-$ARCH.tar.gz
export PATH=$PWD/go/bin:$PATH

git clone https://github.com/vpenso/prometheus-slurm-exporter.git

# Change listen on for HTTP requests.
grep -n -r 8080          prometheus-slurm-exporter/main.go
sed -i 's/:8080/:9800/'  prometheus-slurm-exporter/main.go
grep -n -r 9800          prometheus-slurm-exporter/main.go

# make slurm expoter
cd prometheus-slurm-exporter
pwd
export GOPATH=$PWD/go/modules

go mod download
go test -v *.go
go build -o bin/slurm-exporter {main,accounts,cpus,gpus,partitions,node,nodes,queue,scheduler,sshare,users}.go

# copy make file
cp bin/slurm-exporter  /usr/local/sbin/slurm-exporter

# for test.
/usr/local/sbin/slurm-exporter

# Firewall port add
firewall-cmd --add-port=9800/tcp --permanent
firewall-cmd --reload
firewall-cmd --list-all

# Prometheus-slurm service add
cat << EOF > /lib/systemd/system/slurm-exporter.service
[Unit]
Description=Prometheus SLURM Exporter

[Service]
ExecStart=/usr/local/sbin/slurm-exporter
Restart=always
RestartSec=15

[Install]
WantedBy=multi-user.target
EOF

ll        /lib/systemd/system/slurm-exporter.service
chmod +x  /lib/systemd/system/slurm-exporter.service

systemctl  daemon-reload
systemctl  enable   slurm-exporter.service
systemctl  start    slurm-exporter.service
systemctl  status   slurm-exporter.service
netstat -tnlp | grep 9800

# Prometheus-config file Modified
ll -ld /etc/prometheus/prometheus.yml
cp    /etc/prometheus/prometheus.yml{,.bak}

cat << EOF >> /etc/prometheus/prometheus.yml

  - job_name: 'slurm-exporter'
    scrape_interval:  5s
    scrape_timeout:   5s

    static_configs:
      - targets: ['10.1.1.254:9800']
EOF

# restart prometheus
docker restart prometheus
```


## ## [9. Prometheus-ipmi exporter ( For Centos7, Only Master )][contents]
```bash
# only master.

cd /tmp/

# Donwload go 1.15
export VERSION=1.15 OS=linux ARCH=amd64
wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz

tar -xzf go$VERSION.$OS-$ARCH.tar.gz
export PATH=$PWD/go/bin:$PATH

git clone https://github.com/soundcloud/ipmi_exporter

# make slurm expoter
cd ipmi_exporter/
pwd
make

# copy make file
cp ./ipmi_exporter   /usr/local/sbin/ipmi_exporter
/usr/local/sbin/ipmi_exporter  --version

# for test.
/usr/local/sbin/ipmi_exporter

# Firewall port add
firewall-cmd --add-port=9290/tcp --permanent
firewall-cmd --reload
firewall-cmd --list-all

# Prometheus-slurm service add
cat << EOF > /lib/systemd/system/ipmi-exporter.service
[Unit]
Description=Prometheus IPMI Exporter

[Service]
ExecStart=/usr/local/sbin/ipmi_exporter
Restart=always
RestartSec=15

[Install]
WantedBy=multi-user.target
EOF

ll /lib/systemd/system/ipmi-exporter.service
chmod +x /lib/systemd/system/ipmi-exporter.service

systemctl daemon-reload
systemctl enable ipmi-exporter.service
systemctl start  ipmi-exporter.service
systemctl status ipmi-exporter.service
netstat -tnlp | grep 9290


cat << EOF >> /etc/prometheus/prometheus.yml

  - job_name: 'ipmi-exporter'
    scrape_interval:  5s
    scrape_timeout:   5s

    static_configs:
      - targets: ['10.1.1.254:9290']
EOF

# restart prometheus
docker restart prometheus
```


## ## [10. Grafana Install (on Master)][contents]

```bash
# https://grafana.com/grafana/download?pg=get&plcmt=selfmanaged-box1-cta1  

yum -y install  https://dl.grafana.com/oss/release/grafana-7.5.7-1.x86_64.rpm

which grafana-server
which grafana-cli

systemctl daemon-reload
systemctl enable grafana-server.service

grafana-cli plugins install grafana-clock-panel
systemctl   restart   grafana-server.service

# Firewall Port Open 3000
firewall-cmd --list-all | grep 3000
firewall-cmd --add-port=3000/tcp
firewall-cmd --add-port=3000/tcp --permanent
firewall-cmd --list-all | grep 3000

# Open Broser to http://localhost:3000
# id : admin / pass : admin
```

## ## [11. Grafana Report to PDF][contents]

```bash
# pdf 를 생성시키는데 필요한 패키지 설치.
yum -y  install  texmaker texlive texlive-*.noarch

which pdflatex

### 그라파나가 패널을 이미지로 렌더링 하기위해 필요한 패키지 설치.
# https://grafana.com/docs/grafana/latest/administration/image_rendering/  

grafana-cli plugins install grafana-image-renderer

systemctl   restart   grafana-server

yum -y  install libXcomposite libXdamage libXtst cups libXScrnSaver pango atk \
adwaita-cursor-theme adwaita-icon-theme at at-spi2-atk at-spi2-core cairo-gobject \
colord-libs dconf desktop-file-utils ed emacs-filesystem gdk-pixbuf2 glib-networking \
gnutls gsettings-desktop-schemas gtk-update-icon-cache gtk3 hicolor-icon-theme \
jasper-libs json-glib libappindicator-gtk3 libdbusmenu libdbusmenu-gtk3 libepoxy \
liberation-fonts liberation-narrow-fonts liberation-sans-fonts liberation-serif-fonts \
libgusb libindicator-gtk3 libmodman libproxy libsoup libwayland-cursor libwayland-egl \
libxkbcommon m4 mailx nettle patch psmisc redhat-lsb-core redhat-lsb-submod-security \
rest spax time trousers xdg-utils xkeyboard-config


### grafana-reporter 설치.

cd /tmp/

# Donwload go 1.15
export VERSION=1.15 OS=linux ARCH=amd64
wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz

tar -xzf go$VERSION.$OS-$ARCH.tar.gz
export PATH=$PWD/go/bin:$PATH

go get github.com/IzakMarais/reporter/...
go install -v github.com/IzakMarais/reporter/cmd/grafana-reporter

ll /root/go/bin/grafana-reporter

# Firewall Port Open 8686
firewall-cmd --list-all | grep 8686
firewall-cmd --add-port=8686/tcp
firewall-cmd --add-port=8686/tcp --permanent
firewall-cmd --list-all | grep 8686

# test.
/root/go/bin/grafana-reporter

# grafana-reporter service add

cp /root/go/bin/grafana-reporter  /usr/local/sbin/grafana-reporter
cat << EOF > /lib/systemd/system/grafana-reporter.service
[Unit]
Description=Grafana-Reporter

[Service]
ExecStart=/usr/local/sbin/grafana-reporter
Restart=always
RestartSec=15

[Install]
WantedBy=multi-user.target
EOF

ll       /lib/systemd/system/grafana-reporter.service
chmod +x /lib/systemd/system/grafana-reporter.service

systemctl daemon-reload
systemctl enable grafana-reporter.service
systemctl start  grafana-reporter.service
systemctl status grafana-reporter.service

netstat -tnlp | grep   grafana-repo

```
### ### apitoken, PDF Gen Link
- http://localhost:8686/api/v5/report/{dashboardUID}?apitoken=12345&var-host=devbox  
- apitoken : Configuration => API Keys => Add API Key  
- dashboard settings => Links => Add Dashboard Link => Type Link...   

### ### PDF Gen cli

```bash



```

***

### [Grafana dashboards][https://grafana.com/grafana/dashboards]

#### Node Exporter for Prometheus Dashboard EN v20201010
https://grafana.com/grafana/dashboards/11074

#### Prometheus Node Exporter Full
https://grafana.com/grafana/dashboards/1860

#### Node Exporter Full with Node Name
https://grafana.com/grafana/dashboards/10242

#### Node Exporter Server Metrics
https://grafana.com/grafana/dashboards/405

#### GPU Nodes v2
https://grafana.com/grafana/dashboards/11752

#### NVIDIA DCGM Exporter Dashboard
https://grafana.com/grafana/dashboards/12239

#### slurm
https://grafana.com/grafana/dashboards/4323

## ## [END.][contents]
