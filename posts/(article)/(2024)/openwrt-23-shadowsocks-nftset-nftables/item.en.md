---
title: Configuring Shadowsocks rules with nftset in OpenWRT 23
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
image: featured.webp
x.com:
  status: https://x.com/dallaslu/status/1770670425284207034
nostr:
  note: note199rcrl3qd9q7ry2ynr847zmdk4xcjjv2wust5l2s5r4jz523h7fswngs7k
---

In OpenWRT 23, the default firewall is fw4; the nftables counterpart is nftset. I will introduce the creation of gfwlist-based rules for shadowsocks redir using dnsmasq-full/nftset/nftables.

===

## nftables

Edit `/etc/nftables.d/gfwlist.nft` to set the initial configuration of nftset, adding the IP segment for Telegram, and the forwarding rules [^99010-nftables]:

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

The above configuration assumes that ss-redir listens on port 1100. Restart the firewall:

```bash
service firewall restart
```

### Manual configuration

Temporarily add IPs to or remove them from gfwlist[^nftables]:

```bash
nft add element inet fw4 gfwlist { 1.2.3.4 }
nft delete element inet fw4 gfwlist { 1.2.3.4 }
```

## Dnsmasq

### Switch to  dnsmasq-full

```bash
opkg remove dnsmasq
opkg install dnsmasq-full

service dnsmasq restart
```

### Create Dnsmasq Configuration

The default configuration directory is'/tmp/dnsmaseq. d ', so it is best to place the configuration file in another location:

```bash
mkdir -p /root/gfwlist/nftset
```

And automatically copies the configuration file at startup:

```bash
cp -f /root/gfwlist/nftset/*.conf /tmp/dnsmasq.d
```

### Manual configuration

If we have a manually maintained configuration file `/root/gfwlist/nftset/dnsmasq_gfwlist_nftset_custom.conf`:

```conf
server=/githubusercontent.com/127.0.0.1#5353
nftset=/githubusercontent.com/4#inet#fw4#gfwlist
server=/github.com/127.0.0.1#5353
nftset=/github.com/4#inet#fw4#gfwlist
```

Create deployment script `deploy-dnsmasq-conf.sh`:

```bash
cp -f /root/gfwlist/nftset/*.conf /tmp/dnsmasq.d && service dnsmasq restart
```

### gfwlist

The script [gfwlist2dnsmasq.sh](https://github.com/cokebar/gfwlist2dnsmasq) that converts gfwlist to a dnsmasq profile only supports ipset and requires some editing:

```diff showLineNumbers=287
- ipset=/\1/'$IPSET_NAME'#g' > $CONF_TMP_FILE
+ nftset=/\1/4\#inet\#fw4\#'$IPSET_NAME'#g' > $CONF_TMP_FILE
```

Write it to the script file `/root/gfwlist/nftset/gfwlist2dnsmasq-nftset.sh`. Create another `update-gfwlist-dnsmasq-conf.sh`:

```bash
sh /root/gfwlist/nftset/gfwlist2dnsmasq-nftset.sh -s gfwlist -o /root/gfwlist/nftset/dnsmasq_gfwlist_nftset.conf && /root/gfwlist/nftset/deploy-dnsmasq-conf.sh
```

Edit `/etc/rc.local`, add:

```bash
sh /root/gfwlist/nftset/update-gfwlist-dnsmasq-conf.sh
```

Add crontab task:

```crontab
0 0 1 * * ?     sh /root/gfwlist/nftset/update-gfwlist-dnsmasq-conf.sh
```

## Conclusion

Most of the articles on the Internet use the example of going over the gfw, and this scenario has been chosen for the content of this article. In fact, another useful case is to use services such as [Residential IP Access ChatGPT](/iproyal-usa-static-residential-proxies/).

[^99010-nftables]: 99010\. [dnsmasq-full + nftset + nftables透明代理](https://www.right.com.cn/FORUM/thread-8313005-1-1.html). 恩山无线论坛. 2023.
[^nftables]: [6.4. Using sets in nftables commands](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-using_sets_in_nftables_commands). Red Hat.