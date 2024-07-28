---
title: 被墙IP的妙用：UFW 转发
date: '2023-05-28 05:28'
published: true
license: WTFPL
taxonomy:
  category:
    - Internet
  tag:
    - GFW
    - UFW
    - Ubuntu
keywords:
  - UFW 端口转发
  - Ubuntu TCP 转发规则
x.com:
  status: https://x.com/dallaslu/status/1662735175384731648
nostr:
  note: note149shamx6vnquuxrs7t0n8essd7lhas249xz2refz8dt9g87jn0tsmcc6jw
---

很多人为自己的 Web 服务开启了 Cloudflare 的 CDN，既能加速（也可能减速），又能隐藏真实的服务器 IP，避免被攻击。不过，当你拥有了一个被墙的 IP，那么你就可以肆无忌惮地考虑搭建一些非 Web 服务了。一个死去的人不会再次死亡，一个已经被墙的 IP 也不再担心被墙。而且它还天然免疫来自中国大陆的攻击。

===

当然，Cloudflare 也有一些特殊的加速服务，比如加速 SSH，但毕竟端口有限制，而且价格不菲。只需在这个 IP 的 VPS 上做转发，就可以同样做到不暴露真正的服务器 IP。我的情况是，在一台服务器上搭建了 Frogejo(详见：[在 Ubuntu 上搭建 Forgejo](https://dallas.lu/install-forgejo-on-ubuntu/))，一直以来，关于用 SSH 来 Pull/Push 代码方面有些纠结，因为用 SSH 会暴露 IP，有安全性的风险。现在我将在被墙的 VPS 上操作，将 22/80/443 端口的转发到真实的 IP `1.2.3.4` 上。

## 更改转发机 SSH 默认端口

因为要占用 22 端口，所以要将转发机的 SSH 端口修改为其他。先加入防火墙规则，允许 2222 端口通行：

```bash
ufw allow 2222/tcp
```

编辑 SSH 服务配置文件 `/etc/ssh/sshd_config`，将端口修改为 2222。

```bash
Port 2222
```

重新启动 SSH 服务。注意，重启服务后当前的连接仍在保持，确认 2222 端口可用前先保留此连接，留个后手，如有问题可随时改回 22 端口。此时可以另行建立连接，验证 2222 端口是否可用。
```bash
systemctl restart sshd
```

## UFW 基础配置

编辑 `/etc/ufw/sysctl.conf`，开启转发功能。

```ini
net/ipv4/ip_forward=1
net/ipv6/conf/default/forwarding=1
net/ipv6/conf/all/forwarding=1
```

编辑 `/etc/default/ufw`
```ini
DEFAULT_FORWARD_POLICY="ACCEPT"

MANAGE_BUILTINS=yes
```

## UFW 规则

编辑 `/etc/ufw/before.rules` 来设定转发规则：

```bash
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]

-A PREROUTING -p tcp --dport 22 -j DNAT --to-destination 1.2.3.4:22
-A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 1.2.3.4:80
-A PREROUTING -p tcp --dport 443 -j DNAT --to-destination 1.2.3.4:443

-A POSTROUTING ! -o lo -j MASQUERADE

COMMIT
```

放行 22/80/443 流量：
```bash
ufw route allow to 1.2.3.4 port 22
ufw route allow to 1.2.3.4 port 80
ufw route allow to 1.2.3.4 port 443
```

重新加载 UFW：
```bash
/usr/lib/ufw/ufw-init flush-all
ufw enable
ufw reload
```

## 其他

如果希望在应用服务器中，能够正确获取客户端 IP，那么可能需要更加复杂的配置，比如使用 haproxy 代替 iptables，或者建立专用隧道，或者更改应用服务器的路由，这里不再展开讨论。

## 使用

大陆的用户将被墙 IP 加入代理规则就能愉快地 Pull/Push 代码了！如果你觉得这不愉快，请想一想，github.com 不是也要挂代理嘛，大家不还是照用不误！

同时，想在大陆直连使用，还是有其他办法的。比如[微林](https://www.vx.link)的流量加速服务，通过位于中国大陆的节点转发，是有穿墙特效的，可以连接到海外任意 IP 和端口，收费只要每月 10 元，有 100GB 流量。
