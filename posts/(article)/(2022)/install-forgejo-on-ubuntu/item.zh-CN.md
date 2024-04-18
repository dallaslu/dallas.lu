---
title: 在 Ubuntu 上搭建 Forgejo
date: '2022-12-27 12:27'
author: 'dallaslu'
published: true
license: WTFPL
taxonomy:
    category:
        - Internet
    tag:
        - Git
        - Ubuntu
        - Forgejo
        - Gitea
keywords:
  - 自建 Git 托管
  - 搭建 Gitea
  - 安装 Gitea
  - 自建 Github
  - 私有 Github
toc:
  enabled: true
---
Gitea 是 Gogs 的分支，据说 Gogs 的开发者不接受外部 PR，于是大家纷纷转向 Gitea。而 Forgejo 是 fork 自 Gitea，是 Gitea 商业化后出现的社区版。

===

## 添加专用用户
```bash
# Ubuntu
sudo adduser --system --group --disabled-password --shell /bin/bash --home /home/git --gecos 'Git Version Control' git
```

## 准备目录
```bash
sudo mkdir -p /var/lib/forgejo/{custom,data,indexers,public,log}
sudo chown git:git /var/lib/forgejo/{data,indexers,log}
sudo chmod 750 /var/lib/forgejo/{data,indexers,log}
sudo mkdir /etc/forgejo
sudo chown root:git /etc/forgejo
sudo chmod 770 /etc/forgejo
```

## 下载安装文件

根据 forgejo 的下载页面[^forgejo-download]的介绍，下载安装文件：

```bash
wget https://codeberg.org/forgejo/forgejo/releases/download/v1.19.3-0/forgejo-1.19.3-0-linux-amd64
chmod +x forgejo-1.19.3-0-linux-amd64
```

### 验证签名

```bash
gpg --keyserver keys.openpgp.org --recv EB114F5E6C0DC2BCDD183550A4B61A2DC5923710
wget https://codeberg.org/forgejo/forgejo/releases/download/v1.19.3-0/forgejo-1.19.3-0-linux-amd64.asc
gpg --verify forgejo-1.19.3-0-linux-amd64.asc forgejo-1.19.3-0-linux-amd64
```

### 移动到本地目录

```bash
sudo mv forgejo-1.19.3-0-linux-amd64 /usr/local/bin/forgejo
```

## 安装依赖

### Git
```bash
apt install git
```

### Mariadb
```bash
apt install mariadb-server
mysql_secure_installation
mysql -u root -p
```
```sql
CREATE DATABASE forgejo;
CREATE USER 'forgejo'@'localhost' IDENTIFIED BY '<YOUR_PASSWORD>';
GRANT ALL ON forgejo.* TO 'forgejo'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```


## 安装为服务

```bash
vim /usr/lib/systemd/system/forgejo.service
```

```ini
[Unit]
Description=Forgejo
After=network.target
After=mariadb.service

[Service]
# Modify these two values and uncomment them if you have
# repos with lots of files and get an HTTP error 500 because
# of that
###
#LimitMEMLOCK=infinity
#LimitNOFILE=65535
RestartSec=2s
Type=simple
User=git
Group=git
WorkingDirectory=/var/lib/forgejo/
ExecStart=/usr/local/bin/forgejo web -c /etc/forgejo/app.ini
Restart=always
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/forgejo
# If you want to bind to a port below 1024 uncomment
# the two values below
###
#CapabilityBoundingSet=CAP_NET_BIND_SERVICE
#AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now forgejo

sudo firewall-cmd --add-port 3000/tcp --permanent
sudo firewall-cmd --reload 
```

## Nginx 配置

可配置一个域名为 `git.example.com` 的 ssl 主机，并添加反代：
```nginx
location ^~ / {
        proxy_redirect off;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        if (!-e $request_filename) {
                proxy_pass http://127.0.0.1:3000;
                break;
        }
}
```

## 安装向导

访问 `https://git.example.com/install`，根据向导完成安装过程。

## 调整 Forgejo 配置

```bash
vim /etc/forgejo/app.ini
```

参考： [`app.example.ini`](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/custom/conf/app.example.ini)

修改配置后重启 forgejo 即可。

[^forgejo-download]: <https://forgejo.org/download/>