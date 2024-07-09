---
title: 邮件投递平台 Postal 的使用经验 
published: true
date: '2024-07-09 07:09'
license: CC-BY-NC-SA-4.0
taxonomy:
  category:
    - Internet
  tag:
    - Email
    - Postal
    - Self-hosted
keywords: 
  - Postal 安装
  - SendGrid 替代
  - Postal STARTTLS
toc:
  enabled: true
x.com:
  status: 
nostr:
  note: 
---

使用 Postal 来替代 SendGrid 已经有一段时间了。基本上可以完全替代 SendGrid。在使用过程中，也遇到了一些问题。本文记录一些使用中的经验之谈。

===

## 25 端口的问题

当服务器向外发送邮件，首先是检查邮箱地址中的域名部分，查询 MX 记录，找到该邮箱的邮件服务器并投递信件。那么在投递时，按默认流程需要连接其 25 端口。如果一台服务器被限制连接其他服务器的 25 端口，那么它就不能轻易地发送邮件。基于这样的原理，很多 VPS 厂商就禁止目标端口 25 的出站流量。

Postal 只提供了一个 SMTP 端口，也就是 25。尽管可以使用 HTTP 接口发信，但大多数应用并没有适配其 HTTP 接口，使用 SMTP 协议还是最通用的方案。若不幸遇到这样的 VPS，只能另寻他法。

一种方式是，使用 Socks 代理。让 25 端口的出站流量另寻出路，以突破限制。不过，在 Socks 的代理服务器，可能也同样限制了 25 端口。

还有一种方式是，在 Postal 的 SMTP 服务器上启用另一个备用端口，比如 2525[^cloudflare-2525]。不过 Postal 本身只允许设置一个端口。可以在 Postal 的服务器上，使用 iptables 来提供备用端口：

```bash
iptables -t nat -A PREROUTING -p tcp --match multiport --dports 587,2525 -j REDIRECT --to-ports 25
```

## SMTP 服务独立域名

正如上文所说，Postal 对外暴露的只有两个服务，

* Web 服务提供管理面板、HTTP API
* SMTP 提供收发服务

但他们共用着域名 postal.example.com。也就是说，你不能使用 Cloudflare 的代理功能来为 Postal 的 Web 服务提速。所以，我们需要将两个服务的域名拆分出来。

所幸，Postal 本身支持这个配置。我们可以编辑配置文件 `/opt/postal/config/postal.yml`，设置 `smtp_hostname` 为 `smtp.example.com`。并设置好 DNS 的 A 记录解析，和对应 IP 的 PTR 记录。

## PTR 记录

很多 VPS 商提供了在线修改 PTR 记录的入口，只需在页面上操作即可。也有一些 VPS 商需要提工单处理。一般来说，建议主机名与 PTR 保持一致。在 SMTP 服务器协商 STARTTLS 时，会在 banner 中声明自己的 hostname，对方会拿这个 hostname 去验证 PTR 记录是否相符。比如在 Postal 中，如果没有配置 `helo_hostname` 则会使用 `smtp_hostname` 的值作为此处的 hostname。

在邮件协议中，客户端验证 Cert 的规则并没有强制的标准，客户端既可以不验证书的域名，甚至自签证书也可以，也可要求必须严格匹配。有的客户端要求其 SMTP 服务器所声明的主机名一致，有的要求其与 MX 记录中的域名，或发起连接时的域名匹配（比如 Plausible 所使用 Bamboo 库）。

PTR 记录与 TLS 无直接关联，但通过 helo_hostname 产生了微妙的联系。在 Postal 和 Mail-in-a-box 的默认情况中，只使用一个域名，因此不会发生任何问题。

不过，在一些特殊情况，当你的 Postal 有多个备用 IP ，或者 IP 池时，其他 IP 可能只做发信的出口使用，未必会提供 Web 服务或者收信服务。默认的 smtp_hostname 就不能与一些仅出站的 IP 的 PTR 记录保持一致了。

不幸的是，目前的 `helo_hostname` 配置的实现上有些问题，并无效果。所以我目前的方案是，先修改配置文件中 `smtp_hostname`，为 `helo.example.com`，重启 SMTP 服务（`docker restart postal-smtp-1`），再修改`smtp_hostname` 为 `smtp.example.com`，再重启 Web 服务（`postal-web-1`）。这样在 helo.example.com 创建多条 A 记录，指向每一个出站 IP，以顺利通过 PTC 检查。

## 证书的问题

Postal 在 25 端口上实现了 STARTTLS 的支持。我们只需要在 Postal 的配置文件中，开启 `smtp_server.tls_enabled: true`，并添加密钥和证书到默认路径：

* `/opt/postal/config/smtp.key`
* `/opt/postal/config/smtp.cert`

鉴于前面提到的SMTP Cert 在客户端的验证逻辑并无标准，这里最好使用一张多域名的证书，包含邮件系统中所用到的域名；也可以使用 WildCard 证书。

## 结语

上次我因 SendGrid 的账户问题而不得不另寻替代；不久后， 其开发商 Twilio 的另一知名产品 Authy 被爆出手机号泄露事件。建议用过 SendGrid 的人都寻找好替代产品吧，自建 Postal 就是一个非常值得尝试的方案。

[^cloudflare-2525]: https://www.cloudflare-cn.com/learning/email-security/smtp-port-25-587/