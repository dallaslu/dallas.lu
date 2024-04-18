---
title: 使用 acme.sh 管理 Let’s Encrypt Wildcard SSL 证书
date: '2018-12-15 16:19'
author: 'dallaslu'
license: WTFPL
taxonomy:
    category:
        - Internet
    tag:
        - Acme-sh
        - Lets-encrypt
        - SSL

---
Certbot 可以申请 Wildcard 证书，但更新不便。

===

## 安装

```bash
curl https://get.acme.sh | sh
```
## 配置 API
编辑 ~/.bashrc ，加入以下内容（以 cloudflare 为例）：
```bash
export CF_Key="123456789"
export CF_Email="a@b.com"
```
保存后，执行

```bash
source ~/.bashrc
```

## 申请证书
```bash
acme.sh --issue --dns dns_fs -d dallas.lu -d *.dallas.lu
```

值得一提的是，如果有多个域名，各自使用不同的 DNS，可以参考以下命令：
```bash
acme.sh --issue \
-d dallas.lu --dns dns_cf \
-d *.dallas.lu --dns dns_cf \
-d a.com --dns dns_namecom \
-d *.a.com --dns dns_namecom \
-d b.com --dns dns_dp \
-d *.b.com --dns dns_dp
```
## 安装证书
```bash
acme.sh --install-cert -d dallas.lu \
--key-file /etc/nginx/certs/dallas.lu.key \
--fullchain-file /etc/nginx/certs/dallas.lu.fullchain.cer \
--reloadcmd "service nginx restart"
```
一切配置妥当后，开启 acme.sh 的自动版本更新：
```bash
acme.sh --upgrade --auto-upgrade
```
