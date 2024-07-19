---
title: Manually establish your own IPv6 Tunnel
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
  - IPv6 Tunnel
  - self-host IPv6 Tunnel
  - he-ipv6
  - self TunnelBroker
  - tunnelbroker.net
  - dmit ipv6
toc:
  enabled: true
---

After so many years, there are still ISPs that don't provide IPv6. Although you can use HE's service to get an IPv6 address for free, the speed and stability of the IPv6 tunneling server really affects your experience. This article explains how to set up your own IPv6 tunneling server with practical examples.

===

Currently, one of my dedicated servers has no available IPv6, while the VPS I bought from [Dmit](https://dmit.io) has a native IPv6/64 address. The PING is about 4ms between the two places, and the network on the free node on [TunnelBroker](https://tunnelbroker.net) is much worse. Since I have an endless supply of IPv6 addresses, why not build my own tunnel server?

## Network conditions

Let's start by listing the network conditions.

Where Dmit VPS acts as a server, hereafter referred to as Server:

* IPv4: `11.11.11.11`
* IPv6: `2024:2:16:2::/64`
* Egress NIC: `eth0`

IPv4-only server as client, hereafter referred to as Client.

* IPv4: `22.22.22.22`

The plan is to create a subnet, configure an IP `2024:2:16:2:1::2` for the Client, and add an IP `2024:2:16:2::1` for the Server as a gateway to the subnet.

In fact, this is the minimum configuration to enable IPv6 tunneling servers, requiring only three available IPv6 addresses on the Server[^xiaodu].

## Establishing the tunnel

### Server configuration

```bash
ip tunnel add sit1 mode sit remote 22.22.22.22 local 11.11.11.11 ttl 255
ip link set sit1 up
ip link set sit1 up

### Client configuration

ip tunnel add dmit-ip
ip tunnel add dmit-ipv6 mode sit remote 11.11.11.11 local 22.22.22.22 ttl 255
ip link set dmit-ipv6 up
```

The remote and local ip tunnel commands for Server and Client are exactly mirrored.

## Configuring Addressing and Routing

### Server configuration

```bash
ip addr add 2024:2024:2024 ip addr add 2024:2024
ip addr add 2024:2:16:2:1::1/80 dev sit1
ip route add 2024:2:16:2:1::2 dev sit1
```

### Client configuration

```bash
ip addr add 2024:2:16:2:1::2/80 dev dmit-ipv6
ip route add ::/0 dev dmit-ipv6
```

## Checking the network

In theory, the two nodes can now communicate with each other using the newly added IP.

```bash
# on server
ping -6 2024:2:16:2:1::2
```
```bash
# on client
ping -6 2024:2:16:2:1::1
```

## Forwarding traffic to the Client

### Outgoing traffic

Edit `/etc/sysctl.conf` to add:

```conf
net.ipv6.conf.sit1.forwarding=1
```

Or if the security policy allows it:
```conf
net.ipv6.conf.all.forwarding=1
```

```bash
sysctl -p
```

### Incoming traffic

The tunnel server needs to use neighbor announcements to forward traffic to the Client, and the NDP proxy needs to be enabled. Edit `/etc/sysctl.conf` to add:

```conf
net.ipv6.conf.sit1.proxy_ndp=1
```

Or if the security policy allows it:
```conf
net.ipv6.conf.all.proxy_ndp=1
```

```bash
sysctl -p
ip -6 neigh add proxy 2024:2:16:2:1::2 dev eth0
```

## Create multiple Tunnel

Simply repeat the above. Or:

### Reuse Tunnel

If you continue to access a new Client1 (IPv4: 33.33.33.33), you can repeat the above steps in full. Or create a reusable tunnel definition on the Server.

```bash
ip tunnel add sit-any mode sit remote any local 11.11.11.11 ttl 255
ip link set sit-any up
ip -6 addr add 2024:2:16:2:1::1/80 dev sit-any
ip -6 route add 2024:2:16:2:1::2 via ::22.22.22.22 dev sit-any
ip -6 route add 2024:2:16:2:1::3 via ::33.33.33.33 dev sit-any
```

Note that `remote any` is set here, which means that any host on the Internet can tunnel to the Server. To avoid abuse, you can use your firewall to add a rule that only accepts data from the specified IPv4 address on interface `sit-any`.

```bash
iptables -A INPUT -p ipv6 -i sit-any -s 22.22.22.22 -j ACCEPT
iptables -A INPUT -p ipv6 -i sit-any -s 33.33.33.33 -j ACCEPT
#....
iptables -A INPUT -p ipv6 -i sit-any -j DROP
```

Configuration on the Client:

```bash
ip tunnel add dmit-ipv6 mode sit remote 11.11.11.11 local 22.22.22.22 ttl 255
ip link set dmit-ipv6 up
ip addr add 2024:2:16:2:1::2/80 dev dmit-ipv6
ip route add ::/0 via 2024:2:16:2:1::1 dev dmit-ipv6
```

Configuration on Client1:

```bash
ip tunnel add dmit-ipv6 mode sit remote 11.11.11.11 local 33.33.33.33 ttl 255
ip link set dmit-ipv6 up
ip addr add 2024:2:16:2:1::3/80 dev dmit-ipv6
ip route add ::/0 via 2024:2:16:2:1::1 dev dmit-ipv6
```

Outgoing traffic configuration `/etc/sysctl.conf` on the server:

```conf
net.ipv6.conf.sit-any.proxy_ndp=1
```

Incoming traffic configuration on the server:

```bash
ip -6 neigh add proxy 2024:2:16:2:1::2 dev eth0
ip -6 neigh add proxy 2024:2:16:2:1::3 dev eth0
```

The NDP proxy only supports a single IPv6 address that is explicitly specified, not segments. Either use multiple `ip -6 neigh add proxy` statements or switch to [NDPPD](https://github.com/DanielAdolfsson/ndppd) which supports network segments.

```bash
apt install ndppd
```

Edit `/etc/ndppd.conf` 
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

## Assign the entire /80 subnet IP to the client.

There is an endless supply of IP on the Server, so it would be too stingy to assign only one IPv6 to the tunnel, and the TunnelBroker is assigned to the entire subnet. To do this on Server.

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

Configuration on the Client:

```bash
ip tunnel add dmit-ipv6 mode sit remote 11.11.11.11 local 22.22.22.22 ttl 255
ip link set dmit-ipv6 up
ip addr add 2024:2:16:2:2::/80 dev dmit-ipv6
ip route add ::/0 via 2024:2:16:2:1::1 dev dmit-ipv6
```

Configuration on the Client1:

```bash
ip tunnel add dmit-ipv6 mode sit remote 11.11.11.11 local 33.33.33.33 ttl 255
ip link set dmit-ipv6 up
ip addr add 2024:2:16:2:3::/80 dev dmit-ipv6
ip route add ::/0 via 2024:2:16:2:1::1 dev dmit-ipv6
```

## Conclusion

This completes the configuration. If it is not available, check the firewall. If the entire network is working, you should consider persisting the configuration of tunnels, IP addresses, routes, etc. so that the tunnels do not fail after a network outage or system reboot. For example, netplan can be used in Ubuntu, and systems such as Debian can write ip commands to `/etc/network/interfaces`.

If you want more security, you can use IPsec to establish a tunnel connection.

[^building-your-own-ipv6-tunnel]: Sam Wilson. [Building your own IPv6 Tunnelbroker](https://www.cycloptivity.net/building-your-own-ipv6-tunnel/). cycloptivity. 2016.
[^xiaodu]: Xiaodu. [Setting up your own IPv6 Tunnel](https://t.du9l.com/2020/12/setting-up-your-own-ipv6-tunnel/). Xiaodu Blog. 2020