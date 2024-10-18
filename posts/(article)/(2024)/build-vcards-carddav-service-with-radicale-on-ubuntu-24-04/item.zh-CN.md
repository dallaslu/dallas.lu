---
title: 使用 Radicale 在 Ubuntu 24.04 中搭建 vCards CardDav 服务
date: '2024-10-17 10:17'
license: CC-BY-NC-SA-4.0
taxonomy:
    category:
        - Software
    tag:
        - Radicale
        - CardDav
        - Ubuntu
keywords:
  - vCards 同步
  - 企业联系人
  - 公共通讯录
  - 中国黄页
  - 自建 Radicale
toc:
  enabled: true
---

vCards 是一个中国黄页开源项目，整理了一批常用的企业联系人，并精心设定了头像；可以导入到手机、电脑中，优化来电和信息界面的使用体验。支持 vcf 文件下载，要求使用者手动导入；如果后续有变动，仍需重复手动导入操作。本文探讨使用 Radicale 在 Ubuntu 24.04 中搭建 CardDav 服务，以实现方便在各个设备上订阅导入，以及让黄页联系人自动保持最新的目标。

===

![](https://user-images.githubusercontent.com/2666735/59692672-0b6bdf00-9218-11e9-881e-5856e263f3aa.png)

!!! __提示__ 如果你并不想自行搭建，只想体验订阅同步，可以前往[使用介绍](#使用)，或者访问图文并茂的使用教程：[快速实现在 iPhone通讯录中添加中国黄页的步骤](https://www.dalao.net/thread-27691.htm)。

## 准备工作

出于安全考虑，建议使用专用的用户：

```bash
sudo useradd --system --user-group --home-dir /home/radicale --shell /sbin/nologin radicale
```

创建 Radicale 数据目录：

```bash
sudo mkdir -p /home/radicale/collections/collections-root
sudo chown -R radicale: /home/radicale
```

## vCards

[vCards](https://github.com/metowolf/vCards) 项目已经可以直接输出 Radicale 所支持的数据格式。

```bash
sudo apt install git npm

# 切换到用户 radicale
sudo su -l radicale -s /bin/bash
cd ~
git clone https://github.com/metowolf/vCards.git
cd vCards
npm install
npm run radicale
```

完成后，数据会输出在 vCards 目录中的 `radicale`，创建一个软链接，以供 Radicale 使用：

```bash
ln -s /home/radicale/vCards/radicale /home/radicale/collections/collection-root/cn
```

## Radicale

[Radicale](https://github.com/Kozea/Radicale) 是一个开源的 CalDav 和 CardDav 服务器软件，基于 Python 编写。

### 安装

安装 Radicale

```bash
sudo apt install python3-pip python3.12-venv

python3 -m venv /home/radicale/python3-env
source /home/radicale/python3-env/bin/activate
pip install radicale
```

### 配置

创建配置目录：

```bash
mkdir /etc/radicale
```

因为联系人数据是由 vCards 项目自动生成，为避免日后数据混乱，所以要关闭 Radicale 的修改写入功能。创建权限配置 `/etc/radicale/rights`：

```conf
[root]
user: .+
collection:
permissions: R

# (same as user name)
[principal]
user: .+
collection: {user}
permissions: R

[collections]
user: .+
collection: {user}/[^/]+
permissions: rR
```

参考 [官方文档](https://radicale.org/3.0.html#documentation/configuration) ，创建 Radicale 配置文件 `/etc/radicale/config`：

```conf
[rights]
type = from_file
file = /etc/radicale/rights
[storage]
type = multifilesystem
filesystem_folder = /home/radicale/collections
```

创建服务配置 `/etc/systemd/system/radicale.service`：

```conf
[Unit]
Description=A simple CalDAV (calendar) and CardDAV (contact) server
After=network.target
Requires=network.target

[Service]
ExecStart=/home/radicale/python3-env/bin/python -m radicale
Restart=on-failure
User=radicale
# Deny other users access to the calendar data
UMask=0027
# Optional security settings
PrivateTmp=true
ProtectSystem=strict
#ProtectHome=true
PrivateDevices=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
NoNewPrivileges=true
ReadWritePaths=/home/radicale/collections

[Install]
WantedBy=multi-user.target
```

启动服务并查看状态：

```bash
sudo systemctl deamon-reload
sudo systemctl enable --now radicale
sudo systemctl status radicale
```

## 提供 HTTPS 访问

### Caddy

安装 Caddy 并编辑配置文件：

```bash
sudo apt install caddy

sudo vim /etc/caddy/CaddyFile
```

配置：

```caddy
vcards.example.com {
    reverse_proxy localhost:5232
}
```

启动：

```bash
sudo caddy validate --config /etc/caddy/Caddyfile
sudo systemctl enable --now caddy
sudo systemctl status caddy
```

请确保 80/443 端口开放：

```bash
sudo ufw allow 80,443/tcp
```

### Nginx

参考以下配置：

```nginx
server {
        listen          443 ssl http2;
        listen          [::]:443 ssl http2;
        server_name vcards.example.com;

        # ssl cert ...
        # security ...

        location ^~ /{
                proxy_pass          http://localhost:5232;
        }
        access_log off;
}
```

## 使用{id=usage}

访问 https://vcards.example.com，如果一切正常，会看到 Radicale 的登录页面，用户名 `cn` 密码任意填写，即可登录并查看到 vCards 提供的联系人信息。

订阅相关参数：

* 服务器：`vcards.example.com`
* 用户名: `cn`
* 密码：`cn` 或任意填写

在设备中添加订阅：

* iOS: 「设置」--「通讯录」--「账户」--「添加账户」-- 「其他」--「添加 CardDAV 账户」。因为 iOS 的 Bug，并不能随时修改描述，建议将 描述 填写为「中国黄页」。
* Mac：「通讯录」--「设置」--「账户」--「其他通讯录账户」
* ThunderBird
  - 旧版：需要安装 TbSync 及 Provider for CalDav & CardDav 扩展。「工具」--「Synchronization Settings(TbSync)」--「Account actions」--「alDav & CardDav」-- 「Manual Configuration
  - 新版：等待官方支持
* Android：需要安装 DAVx5。「+」--「使用 URL 和用户名登录」

可尝试使用由 vCards 的作者 [metowolf](https://i-meto.com) 提供的公开订阅服务：`vcards.metowolf.com` (以 `vcards.metowolf.com`替换`vcards.example.com`)

## 结语

本方案中 Radicale 对于订阅用户来说，是只读的。如果你有需要临时加入一些号码，建议在本地另建同名联系人，在 iOS 中可以将 vCards 中的黄页联系人和本地联系人自动合并显示。