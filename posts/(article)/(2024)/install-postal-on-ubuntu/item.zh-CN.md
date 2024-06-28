---
title: 自建 Postal 完美替代 SendGrid 
published: true
date: '2024-06-28 06:28'
license: CC-BY-NC-SA-4.0
taxonomy:
  category:
    - Internet
  tag:
    - Email
    - Postal
    - Self-hosted
keywords:
  - 搭建 Postal
  - Postal 安装
  - SendGrid 替代
toc:
  enabled: true
x.com:
  status: 
nostr:
  note: 
---

Cloudflare 的邮件路由功能很好用。作为补充，我一直使用 SendGrid 来发信，也一直在寻找替代品。自托管邮件有 Mail-in-a-box，Docker-mailserver，MailCow 等等选择。不过，有时我并不需要收件箱，因此我决定尝试 Postal 作为 SendGrid 的替代方案。本文记录 Postal 的安装与使用。

## 准备

### 一个域名

一般使用二级域名即可，比如 postal.example.com。仅作为管理和配置使用，安装成功后，可以随意绑定新域名来收发邮件。

### 一台 VPS

最好有一台专门用来运行 Postal 的 VPS，允许 25 端口的出入流量，有 IPv4 和 IPv6 的公网 IP，同时为其设置 rDNS 解析到 postal.example.com，这是发信成功率的一个重要因素。

#### 如何测试 VPS 是否允许 25 端口的流量

##### 测试能否连接其他服务器的 25 端口

```bash
telnet smtp.google.com 25
```

##### 测试外部服务器能否连接本机的 25 端口

在本机监听 25 端口：

```bash
nc -l -p 25
```

放行 25 端口入站流量，例如使用 UFW：

```bash
ufw allow 25/tcp
```

从外部连接本地 25 端口

```bash
telnet <YOUR_VPS_IP> 25
```

很幸运，我常用的 [DMIT](https://www.dmit.io/aff.php?aff=6587) 和 ServerHub 独立主机均没有 25 端口的限制，其中 DMIT 不限制 25 端口应该有[涛叔](https://taoshu.in)的功劳[^dmit-25]。

## 安装 Postal

Postal 建议至少 4GB 内存，以及 25GB 的存储空间。我使用了一台全新安装的 Ubuntu 22.04 来运行 Postal。

```bash
apt install git curl jq
git clone https://github.com/postalserver/install /opt/postal/install
sudo ln -s /opt/postal/install/bin/postal /usr/bin/postal
```

### Docker

Postal 并没有声明其支持 Podman，因此我们还是老实地[安装 Docker](https://docs.docker.com/engine/install/ubuntu/):

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### MariaDB

可以使用 Docker。

```bash
docker run -d \
   --name postal-mariadb \
   -p 127.0.0.1:3306:3306 \
   --restart always \
   -e MARIADB_DATABASE=postal \
   -e MARIADB_ROOT_PASSWORD=postal \
   mariadb
```

当然也可以不用 Docker，注意 Postal 需要对数据库 `postal` `postal-%` 有全部的权限。

```sql
GRANT ALL PRIVILEGES ON `postal`.* TO 'postal'@'%' IDENTIFIED BY 'YOUR_PASSWORD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON `postal\-%`.* TO 'postal'@'%' IDENTIFIED BY 'YOUR_PASSWORD' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

为了记录邮件，需要确认 `innodb_log_file_size` 为邮件大小上限的十倍。查看当前的配置[^mariadb-innodb-log-file-size]：

```sql
SHOW GLOBAL VARIABLES LIKE 'innodb_log_file_size';
```

### 准备 Postal

运行：

```bash
postal bootstrap postal.yourdomain.com
```

编辑生成的配置文件，设置数据库密码等：

```
vim /opt/postal/config/postal.yml
```

#### ghcr.io

访问 <https://github.com/settings/tokens/new> 生成一个 classic token[^auth-ghcr]。

```bash
export CR_PAT=YOUR_TOKEN
export ghcr_user=YOUR_GITHUB_USERNAME
echo $CR_PAT | docker login ghcr.io -u $ghcr_user -password-stdin
```

#### 初始化数据库等

```bash
postal initialize
```

#### 创建管理员

```bash
postal make-user
```

#### 启动 Postal

```bash
postal start
```

#### Caddy
```bash
docker run -d \
   --name postal-caddy \
   --restart always \
   --network host \
   -v /opt/postal/config/Caddyfile:/etc/caddy/Caddyfile \
   -v /opt/postal/caddy-data:/data \
   caddy
```

## 配置 DNS 解析

需要为 postal.example.com 创建 A 和 AAAA 记录，指向服务器 IP。根据 <https://docs.postalserver.io/getting-started/dns-configuration> 继续配置其他解析记录。

配置文件中，`dns.mx_records` 中的域名，都应该 CNAME 到 postal.example.com。

## 使用 Postal

访问 postal.example.com，创建一个组织，再创建一个邮件服务器，添加域名，按页面提示配置好邮件域名的 DNS 解析记录并验证。

访问 Messages -> Send Message，可以发送测试邮件。访问 <https://www.mail-tester.com> 获得一个测试邮件地址，并发送测试邮件，看看能否达到满分。

访问 Credentials，可以添加 SMTP 凭据，就可以愉快地发信了。

建议打开设置中的隐私模式，以避免泄漏 SMTP 客户端的 IP。

## 结语

Postal 同样支持类似 Cloudflare 邮件路由的收信功能，可以转发到邮箱或者 HTTP 接口。不久前，我的 SendGrid 账户因为未知原因无法登陆，发了工单，客服回复说我的账户来自外部系统，因为技术原因不能登录了。用了一段时间的 Postal，基本上可以完全替代 SendGrid 之类的服务，并且更加自由。

[^dmit-25]: 涛叔. [记录开通 25 号端口的经历](https://taoshu.in/dmit-25.html). Taoshu.in. 2022.
[^mariadb-innodb-log-file-size]: https://mariadb.com/docs/server/storage-engines/innodb/operations/configure-redo-log/
[^auth-ghcr]: Andrew Hoog. [Authorizing GitHub Container Registry](https://www.andrewhoog.com/post/authorizing-github-container-registry/). DON'T PANIC. 2023