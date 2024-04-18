---
title: 使用 Let’s Encrypt Wildcard SSL 证书
date: '2018-03-15 16:15'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Lets-encrypt
        - SSL
        - VPS

---
Let's Encrypt 终于宣布正式支持 Wildcard 证书了。使用官方一直推荐的 Certbot 申请 Wildcard 证书，可以了解一下。

===

## 申请证书

在 VPS 上执行以下命令：

```bash
~/certbot-auto certonly \
-d dallas.lu \
-d *.ngrok.dallas.lu \
-d *.dallas.lu \
-d other.com \
-d *.other.com \
--manual \
--preferred-challenges dns \
--server https://acme-v02.api.letsencrypt.org/directory
```

可以使用参数 --cert-name 来指定域名证书，如没有指定，第一个 -d 参数后面的域名，会被当作证书名称。

## IP 记录提示

执行之后会提示IP会被记录。不过请放心，尽管申请 IP 会被记录在案，但[暂时还没有公开的计划](https://community.letsencrypt.org/t/public-ip-logging/26385/2)。这一点对于有多个 IP 的 VPS 来说，有可能会造成出口 IP 泄露，如果你很在意的话，建议通过修改 /etc/sysconfig/network-scripts 中的配置文件并重启网络服务，来临时切换一个出口 IP。此处可输入 Y 按回车继续。

<pre>-------------------------------------------------------------------------------
NOTE: The IP of this machine will be publicly logged as having requested this
certificate. If you're running certbot in manual mode on a machine that is not
your server, please ensure you're okay with that.

Are you OK with your IP being logged?
-------------------------------------------------------------------------------
(Y)es/(N)o: Y</pre>

## DNS 验证

接下来是 DNS 验证的时间了，需要为域名增加一条 txt 记录。

<pre>-------------------------------------------------------------------------------
Please deploy a DNS TXT record under the name
_acme-challenge.dallas.lu with the following value:

QQxHqbXK2aWM8qRWpAyenXo2QotSejV_ERnnc6MUEqU

Before continuing, verify the record is deployed.
-------------------------------------------------------------------------------
Press Enter to Continue</pre>

友情提示一下，如果你打算把 root.com 和 *.root.com 签在同一张证书里，不仅要在命令使用 -d dallas.lu -d *.dallas.lu 来声明，而且还需要创建多个 txt 记录来验证。同名 txt 记录是允许存在多条的哦，每当提示 `Please deploy a DNS TXT` 时，就按照提示去创建一条 txt 记录。创建完成后，在使用 nslookup 命令来验证一下：

```bash
nslookup
&gt; set type=txt
&gt; _acme-challenge.dallas.lu
Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
_acme-challenge.dallas.lu text = "I6Tys5RebMhWaBxN1e4fBaBj2OF7jUPl92tdDtfKjao"
_acme-challenge.dallas.lu text = "QQxHqbXK2aWM8qRWpAyenXo2QotSejV_ERnnc6MUEqU"
```

## 证书签发

当你验证完全部域名后，顺利的话：

<pre>Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
- Congratulations! Your certificate and chain have been saved at:
/etc/letsencrypt/live/dallas.lu/fullchain.pem
Your key file has been saved at:
/etc/letsencrypt/live/dallas.lu/privkey.pem
Your cert will expire on 2018-06-13. To obtain a new or tweaked
version of this certificate in the future, simply run certbot-auto
again. To non-interactively renew *all* of your certificates, run
"certbot-auto renew"
- If you like Certbot, please consider supporting our work by:

Donating to ISRG / Let's Encrypt: https://letsencrypt.org/donate
Donating to EFF: https://eff.org/donate-le</pre>

SSL 证书的配置就不缀述了。如果提示某域名未通过验证，重新执行命令之后，再按提示检查 DNS 设置即可。已经验证成功的域名，其 txt 记录的 value 是不用再修改的哦。
