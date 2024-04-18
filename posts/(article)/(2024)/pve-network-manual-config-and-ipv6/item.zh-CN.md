---
title: 在 PVE 手动配置网络及虚拟机 IPv6 公网
date: '2024-02-15 15:02'
author: 'dallaslu'
published: true
taxonomy:
    category:
        - Internet
    tag:
        - PVE
        - IPv6
        - NDPPD
license: CC-NC-SA-4.0
keywords:
  - PVE 虚拟机 IPv6 上网
  - PVE IPv6 支持
  - PVE 共享 IPv4
  - PVE 独享 IPv6
toc:
  enabled: true
---

独立服务器主机商提供了一个 IPv4 地址，以及 /64 的 IPv6 地址。尽管额外购买了 IPv4 地址，但并不够用。有几个虚拟机本身并不需要公共的 IPv4 地址，只需要能访问 IPv4 和 IPv6 网络即可，比如监控服务。另有一些临时测试服务，也可能只需要 IPv6 地址。本文记述一台独立服务器上 PVE 的网络配置，尤其是 IPv6 部分，方便虚拟机同时拥有内网 IPv4 地址和公网 IPv6 地址。

===

## PVE 自身网络 vmbr0 配置

PVE 会默认创建 `vmbr0`，桥接了第一个物理端口。需要确认一下，已插入网线的端口是哪一个，也许不是 eno1 而是 eno2。我曾在此处浪费了半个多小时。

### 公网 IPv4 的配置

主机商提供了明确的配置信息，假设是：

> IPv4: 1.2.3.4/30  
> IPv4 Gateway: 1.2.3.1  
> IPv6: 1:2:3:4::/64  
> IPv6 Gateway: 1:2:3:4::1  

使用 IPMI 或 VNC 连接至服务器，编辑 `/etc/network/interfaces`：

```conf {3,4}
auto vmbr0
iface vmbr0 inet static
        address 1.2.3.4/30
        gateway 1.2.3.1
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0
```

然后重启网络：

```bash
systemctl restart networking
```

访问 `https://1.2.3.4:8006` 即可访问 PVE 的控制面板[^note:reboot]。接下来的操作都可在 PVE 控制面板完成。

### PVE 自身 IPv6 配置

编辑 `vmbr0` 的配置，已经在界面上看到刚刚的 IPv4 配置，继续设置 IPv6：

* IPv6/CIDR: `1:2:3:4::a/64`
* IPv6 网关: `1:2:3:4::1`

保存后应用更改，可通过 <https://ping6.ping.pe> 来验证 `1:2:3:4::a/64` 是否可从外部访问，以及在 PVE 节点 shell 中检查是否可通过 IPv6 连接互联网。

```bash
# Google DNS
ping6 2001:4860:4860::8888
```

### 其他

网络正常使用后，即可进行其他依赖网络的操作，比如加入另一机房的 PVE 集群等。

如果一台虚拟机需要使用额外的独立 IP，可直接连接到默认建立的 `vmbr0`，然后按主机商提供的信息配置网络地址即可连接 IPv4 和 IPv6 网络。因为 `vmbr0` 桥接了已插入网线的物理端口，基于此网络直接配置公网 IP 地址即可，无需其他操作。

## 配置虚拟机专用桥接网络 vmbr1

更多的时候，虚拟机不需要公网 IPv4，只需 NAT 内网地址或者 IPv6。所以在 PVE 的节点上添加一个桥接网络（Linux Bridge）`vmbr1`：

* IPv4/CIDR: `1.0.0.1/16`
* IPv6/CIDR: `1:2:3:4:a::1/80`

如果打算使用 VLAN，此处的地址信息可填可不填。如果有临时开测试虚拟机的需要，就以此作为默认的测试网络，此 IPv4 地址即为虚拟机的 IPv4 网关，IPv6 亦同。

在 `vmbr0` 中，虚拟机可以任意选择一个可用范围内的 IPv6 地址，而在 `vmbr1` 中，我们希望虚拟机只使用其中一个子网段[^note:addr-limit]。选择了 `1:2:3:4:aa::/80` 中的第一个地址。

### 配置 VLAN

在 `vmbr1` 中，开启 VLAN 感知（VLAN aware）。新建桥接网络，比如 `vmbr1.100`，VLAN 标记即为 100。配置如下：

* IPv4/CIDR: `1.0.100.1/24`
* IPv6/CIDR: `1:2:3:4:a:100::1/96`

我们希望接入标记为 100 的 VLAN 的虚拟机，只使用更小范围的网段 `1.0.100.0/24` 和 `1:2:3:4:a:100::/96` 范围内的地址[^note:multiple-range]。

### 配置虚拟机

这里选择了一个 CT 实例来测试虚拟机的网络配置，好处是可在 PVE 控制面板直接设置网络，非常方便。编辑网络信息：

* 桥接：`vmbr1`
* VLAN 标记：`100`
* IPv4：`静态`
* IPv4/CIDR: `1.0.100.100/24`
* IPv4 网关：`1.0.100.1`
* IPv6：`静态`
* IPv6/CIDR: `1:2:3:4:a:100::100/96`
* IPv6 网关：`1:2:3:4:a:100::1`

此时虚拟机与 PVE 可互相 ping 来测试网络。

### 配置 IPv4 NAT

目前虚拟机还不能通过 IPv4 访问网络，需要连接到 PVE 节点 shell，编辑 `/etc/network/interfaces`，为 `vmbr1` 添加 'post' 开头的语句：

```conf {8-10} showLineNumbers
iface vmbr1 inet static
        address 10.0.0.1/16
        bridge-ports none
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 2-4094
        post-up sysctl -w net.ipv4.ip_forward=1
        post-up iptables -t nat -A POSTROUTING -s '10.0.0.0/16' -o vmbr0 -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s '10.0.0.0/16' -o vmbr0 -j MASQUERADE
```

保存后重启网络[^note:port-forward]。

### 配置 IPv6 转发及 NDP 代理

编辑 `/etc/network/interfaces`，为 `vmbr1` 添加 'post' 开头的语句：

```conf {3-6} showLineNumbers
iface vmbr1 inet6 static
        address 1:2:3:4:a::1/80
        post-up sysctl -w net.ipv6.conf.default.forwarding=1
        post-up sysctl -w net.ipv6.conf.all.forwarding=1
        post-up sysctl -w net.ipv6.conf.default.proxy_ndp=1
        post-up sysctl -w net.ipv6.conf.all.proxy_ndp=1
```

保存重启网络。PVE 会自动创建相关路由，可通过 `ip -6 route` 查看。如果缺少相关路由[^pve-ipv6-route]，可手动添加：

```bash
ip -f inet6 route add 1:2:3:4:100::100 dev vmbr1.100
```

注意重启后可能会消失，自行加入启动脚本或 `/etc/network/interfaces` 相关接口的 post-up 语句中。

至此外部尚不能连接 `vmbr1`、`vmbr1.100` 以及虚拟机上配置的 IPv6 地址。添加 NDP 代理：

```bash
# vmbr1
ip -f inet6 neigh add proxy 1:2:3:4:a::1 dev vmbr0
# vmbr1.100
ip -f inet6 neigh add proxy 1:2:3:4:a:100::1 dev vmbr0
# 虚拟机
ip -f inet6 neigh add proxy 1:2:3:4:a:100::100 dev vmbr0
```

可通过 `ip -f heigh show proxy` 查看。如网络不通，可尝试刷新 ndp 缓存：`ip -6 neigh flush all`。

### NDPPD

未来添加虚拟机时，还会需要手动添加 NDP 代理。可通过 NDPPD 一劳永逸。

```bash
apt install ndppd
```

编辑 `/etc/ndppd.conf`：

```conf
proxy vmbr0 {
        rule 1:2:3:4::/64 {
                auto
        }
}
```

启用 NDPPD

```bash
systemctl enable --now ndppd
```

## 其他

家庭宽带网络环境不适用本文方案，可使用 DHCP/SLAAC 等方式为虚拟机直接自动配置 IPv6[^pve-ipv6-auto][^pve-ipv6]。

[^note:multiple-range]: 本案例中，三个接口中分别配置了不同的子网网段，以避免路由冲突。
[^note:addr-limit]: 如果需要限制 `vmbr1` 或 `vmbr1.100` 中的虚拟机仅能使用规划网段的地址，可为其添加防火墙规则，抛弃非规划网段的数据。
[^note:reboot]: 有时手动更改 PVE 的网络配置，重启网络也没有效果，可尝试重启 PVE 节点。
[^note:port-forward]: 为了从外部 IPv4 地址连接 NAT 网络中的虚拟机，可能需要在 PVE 中配置端口转发。

[^pve-ipv6-route]: coldark. [单IPv4独服利用ProxmoxVE建立IPv4-NAT和IPv6虚拟机（小鸡）](https://www.wnark.com/archives/32.html). 方舟基地. 2019. 「……这时只能访问IPv4地址，IPv6这个时候还是不通的，需要在主机输入以下命令开启:`... ip -f inet6 route add ...`」
[^pve-ipv6-auto]: Insylei. [PVE Proxmox VE 使用IPv6](https://www.icn.ink/pve/57.html). 自由de风. 2023.
[^pve-ipv6]: bruj0. [ProxmoxIPv6](https://github.com/bruj0/ProxmoxIPv6). Github. [46d1aac](https://github.com/bruj0/ProxmoxIPv6/tree/46d1aac3f0a43102848b69e36aebcf0a18964e14). 2023.