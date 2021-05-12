# Prometheus-slurm-exporter ( Centos7 )

```bash
export VERSION=1.15 OS=linux ARCH=amd64
wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz

tar -xzvf go$VERSION.$OS-$ARCH.tar.gz

export PATH=$PWD/go/bin:$PATH

git clone https://github.com/vpenso/prometheus-slurm-exporter.git

cd prometheus-slurm-exporter

pwd

export GOPATH=$PWD/go/modules

go mod download

go build -o bin/prometheus-slurm-exporter {main,accounts,cpus,nodes,partitions,queue,scheduler,users}.go

go test -v *.go

cp bin/prometheus-slurm-exporter /usr/bin/  ## service 파일 복사

bin/prometheus-slurm-exporter  ## 테스트 커맨드 입력 하여도 되고 테스트 하지 않아도 됩니다

cd
```

## Firewall port add

```bash
firewall-cmd --add-port=8080/tcp --permanent

firewall-cmd --reload

firewall-cmd --list-all
```

### Prometheus-slurm service add

```bash
vi /lib/systemd/system/prometheus-slurm-exporter.service

cat /lib/systemd/system/prometheus-slurm-exporter.service

[Unit]
Description=Prometheus SLURM Exporter

[Service]
ExecStart=/usr/bin/prometheus-slurm-exporter
Restart=always
RestartSec=15

[Install]
WantedBy=multi-user.target

chmod +x /lib/systemd/system/prometheus-slurm-exporter.service

systemctl daemon-reload

systemctl enable prometheus-slurm-exporter.service

systemctl restart prometheus-slurm-exporter.service
```

### Prometheus-config file Modified

```bash
ll -ld /etc/prometheus/prometheus.yml

vi /etc/prometheus/prometheus.yml

### 아래 내용 추가

- job_name: 'slurm'
  scrape_interval:  5s
  scrape_timeout:   5s

  static_configs:
  - targets: ['xxx.xxx.xxx.xxx:8080']

docker restart prometheus

```
