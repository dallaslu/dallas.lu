---
title: 解决 Let's Encrypt 的 OCSP 超时问题
date: '2020-11-27 12:18'
author: 'dallaslu'
license: CC-NC-SA-4.0
taxonomy:
    category:
        - Internet
    tag:
        - Lets-encrypt
        - Nginx
        - OCSP

---
众所周知，Let's Encrypt 是一个免费的服务。免费自然代表着劣质，所以 `ocsp.int-x3.letsencrypt.org` 在某些地区无法访问，也就一点不奇怪了。

===

Nginx 支持 ssl_stapling_responder 参数，允许指定一个 ocsp server。一个显而易见的办法是，为 `ocsp.int-x3.letsencrypt.org` 创建一个反向代理。但是稳定而又便宜的线路不太好找哇。但是，如果你有一个稳定的 SOCKS 或 HTTP 代理，那就可以基于此自己在本机搭建一个。

本来是很简单的事情，但是 Nginx 本身并不支持 http_proxy。所以有网友用 docker 包装之后在 docker 上设置代理。下面介绍一个更省资源的办法。

## OCSP Proxy

发现一个用 Go 语言写的 ocsp 代理 [`https://github.com/dlecorfec/ocsp-proxy`](https://github.com/dlecorfec/ocsp-proxy)。为 Linux 编译一下（使用 Windows 10）：

```bat
SET CGO_ENABLED=0
SET GOOS=linux
SET GOARCH=amd64
go build main.go
```

编译出来的程序大小约 5M（如果你信任我的话，可以直接下载 [ocsp-proxy](ocsp-proxy.zip)），上传到服务器的 `/usr/local/bin` 目录下。

添加可执行权限：

```bash
chmod +x /usr/local/bin/ocsp-proxy
```

### 配置服务

```bash
vim /etc/systemd/system/ocsp-proxy.service
```

输入：

```ini
[Unit]
Description=OCSP Proxy for letsencrypt

[Service]
Environment="HTTP_PROXY=http://127.0.0.1:8118"
ExecStart=/usr/local/bin/ocsp-proxy -ocsphost ocsp.int-x3.letsencrypt.org -http :2020
Restart=on-failure
NonBlocking=true

User=ocsp-proxy
PrivateTmp=yes
ProtectSystem=full
PrivateDevices=yes
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
NoNewPrivileges=yes

[Install]
WantedBy=multi-user.target
```

请把 `http://127.0.0.1:8118` 替换为你的 http_proxy。

```bash
# 添加用户
useradd --system -s /bin/false -M ocsp-proxy

systemctl enable ocsp-proxy
systemctl start ocsp-proxy
systemctl status ocsp-proxy
```

### 配置 Nginx

在 server 配置中添加：

```nginx
ssl_stapling_responder http://127.0.0.1:2020;
```

加载 Nginx：

```bash
systemctl reload nginx
```

可以使用验证命令来验证一下，对比一下其他网站：

```bash
openssl s_client -connect example.com:443 -servername example.com -tls1 -tlsextdebug -status | grep -A 17 'OCSP response:'
```
