---
title: 在 CentOS 8 中搭建 Matrix Synapse
date: '2021-07-30 14:01'
author: 'dallaslu'
license: CC-BY-NC-SA-4.0
taxonomy:
    category:
        - IM
    tag:
        - CentOS8
        - Matrix
        - Synapse
    series:
        - Unify Your Online Accounts
keywords:
  - 搭建 Matrix 服务器
  - Matrix 聊天
toc:
  enabled: true
---
Matrix 是一个分布式的联邦宇宙 IM 系统，多个中心服务器可以互联互通。本文介绍如何在 CentOS 8 下手动安装 Matrix 的服务器软件 Synapse。

===

## 安装依赖：

```bash
sudo dnf -y install libtiff-devel libjpeg-devel libzip-devel freetype-devel \
  lcms2 libwebp-devel tcl-devel tk-devel redhat-rpm-config \
  python36 virtualenv libffi-devel openssl-devel
sudo dnf -y group install "Development Tools"
```

## 配置防火墙：

```bash
sudo firewall-cmd --permanent --add-service http
sudo firewall-cmd --permanent --add-service https
sudo firewall-cmd --reload
```

## 安装 Synapse

在本例中，我们将 Synapse 的安装目录设定为 `/opt/synapse`。

```bash
mkdir -p /opt/synapse
virtualenv -p python3 /opt/synapse/env
source /opt/synapse/env/bin/activate

pip install --upgrade pip virtualenv six packaging appdirs
pip install --upgrade setuptools
pip install matrix-synapse

source /opt/synapse/env/bin/activate
pip install -U matrix-synapse
cd /opt/synapse
```

### 生成配置文件

注意，这里的 `--server-name` 参数，将会是你 Matrix 用户名的一部分。一般来说建议使用顶级域名，这样最终的用户名会更短。

```bash
python -m synapse.app.homeserver \
  --server-name example.com \
  --config-path homeserver.yaml \
  --generate-config \
  --report-stats=no
```

## 使用 PostgreSQL

Synapse 默认使用 sqlite，为了性能更优，所以选择使用 PostgreSQL。

安装过程不再赘述。

创建用户：

```bash
sudo su - postgres
createuser synapse
psql
```

设置密码、创建数据库：

```sql
ALTER USER synapse WITH ENCRYPTED password 'DBPassword';
CREATE DATABASE synapse ENCODING 'UTF8' LC_COLLATE='C' LC_CTYPE='C' template=template0 OWNER synapse;
\q
```

退出 synapse 用户：

```bash
exit
```

安装 Synapse 使用 PostgreSQL 所需的相关依赖：

```bash
sudo dnf -y install postgresql-devel libpqxx-devel.x86_64
source ~/synapse/bin/activate
pip install psycopg2
```

### 修改 Synapse 配置

```bash
vim /opt/synapse/homeserver.yaml
```

找到：

```yaml
database:
  name: sqlite3
  args:
    database: /opt/synapse/homeserver.db
```

修改为：

```yaml
database:
#  name: sqlite3
#  args:
#    database: /opt/synapse/homeserver.db
  name: psycopg2
  args:
    user: synapse
    password: DBPassword
    database: synapse
    port: 5432
    cp_min: 5
    cp_max: 10
```

## 尝试启动

```bash
synctl start
```

成功后日志中会有以下绿色字样：

    started synapse.app.homeserver(homeserver.yaml)

如果遇到 `FATAL:  Peer authentication failed for user "synapse"` 错误，请检查 PostgreSQL 的 pg_hba.conf 文件中的配置。

## 与 Nginx 整合

Synapse 默认使用 8008 端口提供 http 服务，使用 8448 端口提供 HTTPS 链接。为简明起见，我们这里使用 Nginx 反代 Synapse，以实现对外提供 HTTPS 访问。

为不与主域下的网站发生冲突，这里使用了二级域名 `synapse.example.com`。

在 Nginx 中创建一个虚拟主机配置，参考：

```nginx
server {
        listen          443 ssl http2;
        listen          [::]:443 ssl http2;
        server_name     martix.example.com synapse.example.com;

        ## 请将以下两行替换为自己的 SSL 配置
        #include conf.d/snippets/ssl.conf;
        #include conf.d/snippets/ssl-security.conf;

        location ^~ /{
                proxy_pass          http://localhost:8008;
                proxy_set_header    Host            $http_host;
                proxy_set_header    Scheme  $scheme;
                proxy_set_header    X-Real-IP       $remote_addr;
                proxy_set_header    X-Forwarded-Host $host;
                proxy_set_header    X-Forwarded-Proto $scheme;
                proxy_set_header    Destination $http_destination;
                proxy_set_header    X-Forwarded-Server $host;
                proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        access_log off;
```

我们选用了二级域名，而 Synapse 中使用的是顶级域名，为了与客户端和联邦中其他服务器通讯，应当在顶级域名对应的网站下，添加 `.well-known/matrix/server` 和 `.well-known/matrix/client` 两个 JSON 文件，以指引它们使用二级域名连接到 Synapse 服务。简单起见，直接使用 Nginx 返回 JSON 内容，在顶级域名对应的网站配置中，添加：

```nginx
location /.well-known/matrix/server {
    return 200 '{"m.server":"synapse.example.com:443"}';
    default_type    application/json;
    add_header Access-Control-Allow-Origin *;
}

location /.well-known/matrix/client {
    return 200 '{"m.homeserver": {"base_url": "https://synapse.example.com"}}';
    default_type    application/json;
    add_header Access-Control-Allow-Origin *;
}
```

在某些客户端中，即使配置了以上两个 JSON，仍会尝试连接顶级域名。如果你遇到了客户端提示 404 无法连接，可以在登录时，尝试使用 `synapse.example.com` 作为主域名。或者在确认与顶级域名对应的网站无冲突的情况下，在其配置文件中加入：

```nginx
location ^~ /_matrix{
    proxy_pass          http://localhost:8008;
    proxy_set_header    Host            $http_host;
    proxy_set_header    Scheme  $scheme;
    proxy_set_header    X-Real-IP       $remote_addr;
    proxy_set_header    X-Forwarded-Host $host;
    proxy_set_header    X-Forwarded-Proto $scheme;
    proxy_set_header    Destination $http_destination;
    proxy_set_header    X-Forwarded-Server $host;
    proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

## 注册管理员用户

```bash
register_new_matrix_user -c /opt/synapse/homeserver.yaml http://localhost:8008
```

    New user localpart [root]: root
    Password: 
    Confirm password: 
    Make admin [no]: yes
    Sending registration request...
    Success!

注意：

1. 一旦用户注册成功，再修改 homeserver.yaml 中的域名将导致报错，修复将需要一定的手动操作，也可能引起一些未知的问题。所以请在安装时，仔细规划域名。
2. 请仔细填写注册首个用户时的选项，变更起来也是比较麻烦的。

## 创建系统服务

```bash
# 先停止 synapse
synctl stop
```

创建用户

```bash
groupadd synapse
useradd -d /opt/synapse -m synapse -s /sbin/nologin -g synapse
chown -R synapse: /opt/synapse
```

```bash
vim /etc/systemd/system/synapse.service
```

输入：

```ini
[Unit]
Description=Synapse Matrix homeserver

[Service]
Type=simple
User=synapse
Group=synapse
WorkingDirectory=/opt/synapse
ExecStart=/opt/synapse/env/bin/python3 -m synapse.app.homeserver -c /opt/synapse/homeserver.yaml

[Install]
WantedBy=multi-user.target
```

保存后，执行：

```bash
systemctl daemon-reload
systemctl enable --now synapse
```

## 参考链接

*   [How to install Matrix Synapse Home Server](https://upcloud.com/community/tutorials/install-matrix-synapse/)
*   [Install Matrix Synapse on CentOS 8](https://www.informaticar.net/install-matrix-synapse-on-centos-8/)
