---
title: 在 OpenWRT 23 中使用 nftset 配置 Shadowsocks 规则
date: '2024-03-18 03:18'
author: 'dallaslu'
published: true
taxonomy:
    category:
        - Internet
    tag:
        - OpenWRT
        - GFW
        - nftables
license: WTFPL
toc:
    enabled: true
keywords:
  - openwrt 23 redir
  - dnsmasq nftset
image: featured.webp
x.com:
  status: https://x.com/dallaslu/status/1770670425284207034
nostr:
  note: note199rcrl3qd9q7ry2ynr847zmdk4xcjjv2wust5l2s5r4jz523h7fswngs7k
---

在 OpenWRT 23 中，默认使用的防火墙是 fw4；nftables 对应的的是 nftset。本人介绍使用 dnsmasq-full/nftset/nftables 为 shadowsocks redir 创建基于 gfwlist 的规则。

===

## nftables

编辑 `/etc/nftables.d/gfwlist.nft`，设置 nftset 的初始配置，加入了 Telegram 的 IP 段，以及转发规则[^99010-nftables]：

```conf
set gfwlist {
	type ipv4_addr
	flags interval
	elements = {
		# telegram start
		91.105.192.0/23,
		91.108.4.0/22,
		91.108.8.0/22,
		91.108.12.0/22,
		91.108.16.0/22,
		91.108.20.0/22,
		91.108.56.0/22,
		149.154.160.0/20,
		185.76.151.0/24,
		#telegram end
	}
}

chain gfwlist-redirect {
	type nat hook prerouting priority 0; policy accept;
	ip daddr @gfwlist ip protocol tcp redirect to :1100
}
```

以上配置假设 ss-redir 监听的端口是 1100。重启防火墙：

```bash
service firewall restart
```

### 手动配置

临时将 IP 加入 gfwlist 或从 gfwlist 移出[^nftables]：

```bash
nft add element inet fw4 gfwlist { 1.2.3.4 }
nft delete element inet fw4 gfwlist { 1.2.3.4 }
```

## Dnsmasq

### 切换为  dnsmasq-full

```bash
opkg remove dnsmasq
opkg install dnsmasq-full

service dnsmasq restart
```

### 创建 dnsmasq 配置文件

默认的配置目录是 `/tmp/dnsmasq.d`，所以我们最好将配置文件放在另外一个位置：

```bash
mkdir -p /root/gfwlist/nftset
```

并在启动时，自动复制配置文件：

```bash
cp -f /root/gfwlist/nftset/*.conf /tmp/dnsmasq.d
```

### 手动配置

如果我们有一个手动维护的配置文件 `/root/gfwlist/nftset/dnsmasq_gfwlist_nftset_custom.conf`：

```conf
server=/githubusercontent.com/127.0.0.1#5353
nftset=/githubusercontent.com/4#inet#fw4#gfwlist
server=/github.com/127.0.0.1#5353
nftset=/github.com/4#inet#fw4#gfwlist
```

创建部署脚本 `deploy-dnsmasq-conf.sh`:

```bash
cp -f /root/gfwlist/nftset/*.conf /tmp/dnsmasq.d && service dnsmasq restart
```

### gfwlist

将 gfwlist 转化为 dnsmasq 配置文件的脚本 [gfwlist2dnsmasq.sh](https://github.com/cokebar/gfwlist2dnsmasq) 只支持 ipset，需要进行一些编辑：

```diff showLineNumbers=287
- ipset=/\1/'$IPSET_NAME'#g' > $CONF_TMP_FILE
+ nftset=/\1/4\#inet\#fw4\#'$IPSET_NAME'#g' > $CONF_TMP_FILE
```

将其写入到脚本文件 `/root/gfwlist/nftset/gfwlist2dnsmasq-nftset.sh` 中。另建立 `update-gfwlist-dnsmasq-conf.sh`：

```bash
sh /root/gfwlist/nftset/gfwlist2dnsmasq-nftset.sh -s gfwlist -o /root/gfwlist/nftset/dnsmasq_gfwlist_nftset.conf && /root/gfwlist/nftset/deploy-dnsmasq-conf.sh
```

编辑 `/etc/rc.local`，加入：

```bash
sh /root/gfwlist/nftset/update-gfwlist-dnsmasq-conf.sh
```

添加 crontab 任务：

```crontab
0 0 1 * * ?     sh /root/gfwlist/nftset/update-gfwlist-dnsmasq-conf.sh
```

## 结语

网上的文章多以翻墙为例，本文内容也选择了这一场景。实际上，另一个有用的场合是使用[住宅 IP 访问 ChatGPT](/iproyal-usa-static-residential-proxies/) 等服务。

[^99010-nftables]: 99010\. [dnsmasq-full + nftset + nftables透明代理](https://www.right.com.cn/FORUM/thread-8313005-1-1.html). 恩山无线论坛. 2023.
[^nftables]: [10.5. 使用 nftables 命令中的集合](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/8/html/securing_networks/using-sets-in-nftables-commands_getting-started-with-nftables). Red Hat.