---
title: 邮件服务的域名成功从 SURBL 黑名单移除
published: true
date: '2024-10-14 10:14'
license: CC-BY-NC-SA-4.0
taxonomy:
  category:
    - Internet
  tag:
    - Self-hosted
    - Email
    - Mail-in-a-box
keywords:
  - SURBL Removal
  - SURBL 移除
  - Mail-in-a-box
---

当我正式切换到自托管邮箱的第一天，邮件服务的域名就进了 SURBL 的黑名单。算是在第一时间，就提交了 Removal 请求。经过数月的等待，终于成功从名单中移除。

===

## 发现

我使用了 [Mail-in-a-box](https://mailinabox.email/) 搭建了自己的邮箱。尽管是运行在一台专用的服务器上，有独立 IP；但出于一些考虑，我使用了同内网的另一个有独立 IP 的节点，做了 SMTP 的端口映射。又为了测试送达率，Google 到一个服务，并尝试向其提供的数十个地址发送了测试邮件。

不久我就在 [MX Toolbox](https://mxtoolbox.com) 发现自己的域名被列入了黑名单。

## 申请移除

访问 <https://surbl.org/surbl-analysis>，并查询自己的域名，结果页面中会有申请的链接。填写了一个冗长的表单，并介绍了发送数十封测试邮件的缘由。

### 真实原因

接着，我从 Mail-in-a-box 附带的状态页中发现，队列中有数千封邮件。很快我意识到问题出在另一节点的端口映射上。

Mail-in-a-box 的提供的配置文件 `/etc/postfix/main.cf` 中有：

```conf
mynetworks_style=subnet
```

这会使得邮件服务器所在子网的其他主机，能够无需认证直接发送邮件[^mynetwork_style]。前面所提到的简单端口映射，并没有将外部数据包的 IP 传送到邮件服务器。对于邮件服务器来说，这些攻击请求都来自于内网节点，从而跳过了验证，成为了一个公开的 SMTP 中继。

### 解决

问题出在端口映射，自然可以换用其他可以[保留源 IP 的转发方案](https://dallas.lu/preserving-client-ip-in-iptables-port-forwarding/)。更简单的办法是，改变邮件组件的默认行为：

```conf
mynetworks_style=host
```

而在裸奔期间，有近万封邮件从这个节点发出……

## 移除成功

然而，SURBL 填写 Removal 请求的机会只有一次，再次查询时只显示队列中已有一个移除请求，请等待处理。于是上面的后续并没有同步给 SURBL。

经过漫长的等待，终于收到了回信，给了十几个关于邮件服务器的实践参考链接。两个小时后，收到了移除成功的邮件。

## 影响

实际上，在被列入黑名单期间，对我发邮件并没有任何影响。也许是因为这是作为私人邮箱用途，仅被一家黑名单收录，只是增加了一点点的 Spam 评分而已。

## 结语

很多人不建议搞自托管邮箱，理由之一就是需要耗费精力维护自己的 IP/域名 的信誉。除此之外，一些大的邮件服务提供商，常被一些白名单收录，比如 Graylist。尽管我收到的垃圾邮件绝大部分都来自这些大提供商，但他们就是在白名单里。自托管就很难被白名单收录。

以前我认为自己不会陷入黑名单的魔咒，并希望在成功移除之后写一篇文章来记录过程。但现在只能写到这了，因为我刚刚发现，有一个叫做 UCEPROTECTL3 的黑名单，竟然收录了我的一个只收信不发信的 IP……

[^mynetwork_style]: https://www.postfix.org/postconf.5.html#mynetworks