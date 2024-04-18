---
title: 手动建立自己的 IPv6 Tunnel 服务
date: '2024-02-16 02:16'
published: true
license: CC-BY-ND-4.0
taxonomy:
  category:
    - Internet
  tag:
    - IPv6
    - VPS
    - dmit.io
    - NDPPD
keywords:
  - IPv6隧道
  - 自建IPv6隧道
  - he-ipv6
  - 自建TunnelBroker
  - tunnelbroker.net
toc:
  enabled: true
---

这么多年过去了，仍然有 ISP 不提供 IPv6。虽然可以使用 HE 的服务免费获得 IPv6 地址，但其速度和稳定性实在影响体验。本文以实操示例讲解如何建立自己的 IPv6 隧道服务器。

===

目前我的一台独立服务器没有可用的 IPv6，而我买的 [Dmit](https://dmit.io) 家的 VPS 有原生的 IPv6 /64 地址。两地 PING 值大约 4ms,[TunnelBroker](https://tunnelbroker.net) 上的免费节点的网络情况则比这糟很多。既然我有用不尽的 IPv6 地址，何不建立一个自己的隧道服务器呢？

## 网络情况

先列出网络情况。

其中 Dmit VPS 作为服务器，以下简称为 Server：

* IPv4: `11.11.11.11`
* IPv6: `2024:2:16:2::/64`
* 出口网卡：`eth0`

纯 IPv4 的服务器作为客户端，以下简称为 Client:

* IPv4: `22.22.22.22`

计划建立一个子网，为 Client 配置一个 IP `2024:2:16:2:1::2`，为 Server 增加一个 `IP 2024:2:16:2::1` 作为子网的网关。

实际上，这也是开启 IPv6 隧道服务器的最小配置，只需要 Server 上有三个可用的 IPv6 地址即可[^xiaodu]。

## 建立隧道

### Server 配置

```bash
ip tunnel add sit1 mode sit remote 22.22.22.22 local 11.11.11.11 ttl 255
ip link set sit1 up
```

### Client 配置

```bash
ip tunnel add dmit-ipv6 mode sit remote 11.11.11.11 local 22.22.22.22 ttl 255
ip link set dmit-ipv6 up
```

Server 和 Client 的 ip tunnel 指令的 remote 和 local 刚好是镜像的。

## 配置地址与路由

### Server 配置

```bash
ip addr add 2024:2:16:2:1::1/80 dev sit1
ip route add 2024:2:16:2:1::2 dev sit1
```

### Client 配置

```bash
ip addr add 2024:2:16:2:1::2/80 dev dmit-ipv6
ip route add ::/0 dev dmit-ipv6
```

## 检查网络

理论上来讲，现在两个节点可以用新增加的 IP 互相通讯了。

```bash
# on server
ping -6 2024:2:16:2:1::2
```
```bash
# on client
ping -6 2024:2:16:2:1::1
```

## 为 Client 转发流量

### 传出流量

编辑 `/etc/sysctl.conf`，增加：

```conf
net.ipv6.conf.sit1.forwarding=1
```

如果安全策略允许，也可：
```conf
net.ipv6.conf.all.forwarding=1
```

```bash
sysctl -p
```

### 传入流量

隧道服务器需要使用邻居通告，将流量转发给 Client，需要启用 NDP 代理。编辑 `/etc/sysctl.conf`，增加：

```conf
net.ipv6.conf.sit1.proxy_ndp=1
```

如果安全策略允许，也可：
```conf
net.ipv6.conf.all.proxy_ndp=1
```

```bash
sysctl -p
ip -6 neigh add proxy 2024:2:16:2:1::2 dev eth0
```

## 建立多个 Tunnel

简单地重复上述操作即可。或者：

### 重复利用 Tunnel

如果继续接入一个新的 Client1 (IPv4: 33.33.33.33)，则可以完整地重复以上步骤。或者在Server上建立一个可重复利用的 tunnel 定义。

```bash
ip tunnel add sit-any mode sit remote any local 11.11.11.11 ttl 255
ip link set sit-any up
ip -6 addr add 2024:2:16:2:1::1/80 dev sit-any
ip -6 route add 2024:2:16:2:1::2 via ::22.22.22.22 dev sit-any
ip -6 route add 2024:2:16:2:1::3 via ::33.33.33.33 dev sit-any
```

注意，这里设置了 `remote any`，意味着互联网上任意主机均可与 Server 建立隧道，为避免被滥用，可使用防火墙添加规则，在接口 `sit-any` 中只接受来自指定 IPv4 地址数据。

```bash
iptables -A INPUT -p ipv6 -i sit-any -s 22.22.22.22 -j ACCEPT
iptables -A INPUT -p ipv6 -i sit-any -s 33.33.33.33 -j ACCEPT
#...
iptables -A INPUT -p ipv6 -i sit-any -j DROP
```

在 Client 上的配置：

```bash
ip tunnel add dmit-ipv6 mode sit remote 11.11.11.11 local 22.22.22.22 ttl 255
ip link set dmit-ipv6 up
ip addr add 2024:2:16:2:1::2/80 dev dmit-ipv6
ip route add ::/0 via 2024:2:16:2:1::1 dev dmit-ipv6
```

在 Client1 上的配置：
```bash
ip tunnel add dmit-ipv6 mode sit remote 11.11.11.11 local 33.33.33.33 ttl 255
ip link set dmit-ipv6 up
ip addr add 2024:2:16:2:1::3/80 dev dmit-ipv6
ip route add ::/0 via 2024:2:16:2:1::1 dev dmit-ipv6
```

Server 上的传出流量配置 `/etc/sysctl.conf`：

```conf
net.ipv6.conf.sit-any.proxy_ndp=1
```

Server 上的传入流量配置：

```bash
ip -6 neigh add proxy 2024:2:16:2:1::2 dev eth0
ip -6 neigh add proxy 2024:2:16:2:1::3 dev eth0
```

NDP 代理只支持明确指定的单个 IPv6 地址，不支持网段。要么使用多条 `ip -6 neigh add proxy`语句，要么换成支持网段的 [NDPPD](https://github.com/DanielAdolfsson/ndppd)。

```bash
apt install ndppd
```

编辑 `/etc/ndppd.conf` 
```conf
route-ttl 30000
address-ttl 30000
proxy eth0 {
   router yes
   timeout 500
   autowire no
   keepalive yes
   retries 3
   promiscuous no
   ttl 30000
   rule 2024:2:16:2:1::/80 {
      static
      autovia no
   }
}
```

```bash
systemctl enable --now ndppd
```

## 将整个 /80 子网 IP 分配给 Client

Server 上有用不完的 IP，若只能分配给隧道单独一个 IPv6，未免太小气了。TunnelBroker 都是给整个子网的。在 Server 上操作

```bash
ip tunnel add sit-any mode sit remote any local 11.11.11.11 ttl 255
ip link set sit-any up
ip -6 addr add 2024:2:16:2:1::1/72 dev sit-any
ip -6 route add 2024:2:16:2:2::/80 via ::22.22.22.22 dev sit-any
ip -6 route add 2024:2:16:2:3::/80 via ::33.33.33.33 dev sit-any
```

`/etc/ndppd.conf` 
```conf
route-ttl 30000
address-ttl 30000
proxy eth0 {
   router yes
   timeout 500
   autowire no
   keepalive yes
   retries 3
   promiscuous no
   ttl 30000
   rule 2024:2:16:2:2::/80 {
      static
      autovia no
   }
   rule 2024:2:16:2:3::/80 {
      static
      autovia no
   }
}
```

在 Client 上的配置：

```bash
ip tunnel add dmit-ipv6 mode sit remote 11.11.11.11 local 22.22.22.22 ttl 255
ip link set dmit-ipv6 up
ip addr add 2024:2:16:2:2::/80 dev dmit-ipv6
ip route add ::/0 via 2024:2:16:2:1::1 dev dmit-ipv6
```

在 Client1 上的配置：
```bash
ip tunnel add dmit-ipv6 mode sit remote 11.11.11.11 local 33.33.33.33 ttl 255
ip link set dmit-ipv6 up
ip addr add 2024:2:16:2:3::/80 dev dmit-ipv6
ip route add ::/0 via 2024:2:16:2:1::1 dev dmit-ipv6
```

## 结语

至此配置完成。如果不可用，请检查防火墙。如果整个网络正常，则应考虑将隧道、IP 地址、路由等配置进行持久化，以免网络中断或系统重启后隧道失效。比如，Ubuntu 中可使用 netplan，Debian 等系统可以将 ip 命令写在 `/etc/network/interfaces` 中。

如果对安全性有更高要求，可以使用 IPsec 建立隧道连接。

[^building-your-own-ipv6-tunnel]: Sam Wilson. [Building your own IPv6 Tunnelbroker](https://www.cycloptivity.net/building-your-own-ipv6-tunnel/). cycloptivity. 2016.
[^xiaodu]: Xiaodu. [Setting up your own IPv6 Tunnel](https://t.du9l.com/2020/12/setting-up-your-own-ipv6-tunnel/). Xiaodu Blog. 2020