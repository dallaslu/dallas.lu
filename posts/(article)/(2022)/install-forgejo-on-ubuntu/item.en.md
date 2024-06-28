---
title: Install Forgejo on Ubuntu
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
        - Nginx
        - Self-hosted
keywords:
  - self-hosted Git
  - Install Gitea
  - self-hosted Github
  - private Github
  - reverse proxy
toc:
  enabled: true
---
Gitea is forked from Gogs. It is said that Gogs developers don't accept extermal PR, so they turn to Gitea, and Forgejo is forked from Gitea, which is a  community version of Gitea after Gitea was commercialized.

===

## Add dedicated user

```bash
# Ubuntu
sudo adduser --system --group --disabled-password --shell /bin/bash --home /home/git --gecos 'Git Version Control' git
```

## Prepare folders

```bash
sudo mkdir -p /var/lib/forgejo/{custom,data,indexers,public,log}
sudo chown git:git /var/lib/forgejo/{data,indexers,log}
sudo chmod 750 /var/lib/forgejo/{data,indexers,log}
sudo mkdir /etc/forgejo
sudo chown root:git /etc/forgejo
sudo chmod 770 /etc/forgejo
```

## Download installation file

According to the introduction of forgejo's download page [^forgejo-download], download the installation file:

```bash
wget https://codeberg.org/forgejo/forgejo/releases/download/v1.19.3-0/forgejo-1.19.3-0-linux-amd64
chmod +x forgejo-1.19.3-0-linux-amd64
```

### Verify the signature

```bash
gpg --keyserver keys.openpgp.org --recv EB114F5E6C0DC2BCDD183550A4B61A2DC5923710
wget https://codeberg.org/forgejo/forgejo/releases/download/v1.19.3-0/forgejo-1.19.3-0-linux-amd64.asc
gpg --verify forgejo-1.19.3-0-linux-amd64.asc forgejo-1.19.3-0-linux-amd64
```

### Move to local folder

```bash
sudo mv forgejo-1.19.3-0-linux-amd64 /usr/local/bin/forgejo
```

## Install dependencies

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

## Install as service

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

## Nginx Configuration

You can configure an SSL host with the domain name `git.example.com` and add reverse proxy config：

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

## Installation Guide

Visit `https://git.example.com/install`, follow the wizard to complete the installation process.

## Adjust Forgejo configuration

```bash
vim /etc/forgejo/app.ini
```

(Reference: [`app.example.ini`](https://codeberg.org/forgejo/forgejo/src/branch/forgejo/custom/conf/app.example.ini))

Just restart Forgejo after modifying the configuration.

[^forgejo-download]: <https://forgejo.org/download/>