---
title: Manually configuring network and VM IPv6 public network in PVE
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
  - PVE Virtual Machine IPv6 Internet
  - PVE IPv6 Support
  - PVE Shared IPv4
  - PVE Exclusive IPv6
toc:
  enabled: true
---

My dedicated server hosting provider offers an IPv4 address, as well as an IPv6 address for /64. Although additional IPv4 addresses were purchased, they were not sufficient. There are several virtual machines that do not need a public IPv4 address, but only need to be able to access both IPv4 and IPv6 networks, such as monitoring services. There are also temp test services that may only need IPv6 addresses. This article describes the network configuration of PVE on a standalone server, especially the IPv6 part, so that the virtual machine can have both an intranet IPv4 address and a public IPv6 address.

===

## PVE's own network vmbr0 configuration

PVE creates `vmbr0` by default, which bridges the first physical port. You need to check which port is plugged into the network cable, maybe not eno1 but eno2. I wasted more than half an hour here.

### Configuration of IPv4 on the public network

The hoster provides explicit configuration information, assuming it is:

> IPv4: 1.2.3.4/30  
> IPv4 Gateway: 1.2.3.1  
> IPv6: 1:2:3:4::/64  
> IPv6 Gateway: 1:2:3:4::1  

Connect to the server using IPMI or VNC, then edit `/etc/network/interfaces`:

```conf {3,4}
auto vmbr0
iface vmbr0 inet static
        address 1.2.3.4/30
        gateway 1.2.3.1
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0
```

Then reboot the network:

```bash
systemctl restart networking
```

Visit `https://1.2.3.4:8006` to access the PVE control panel[^note:reboot]. The rest can be done from the PVE control panel.

### PVE's own IPv6 configuration

Edit the configuration of `vmbr0`, you can already see the IPv4 configuration on the interface, go ahead and set up IPv6:

* IPv6/CIDR: `1:2:3:4::a/64`
* IPv6 gateway: `1:2:3:4::1`

After saving and applying the changes, you can verify that `1:2:3:4::a/64` is accessible externally via <https://ping6.ping.pe> and check in the PVE node shell that the Internet connection is available via IPv6.

```bash
# Google DNS
ping6 2001:4860:4860::8888
```

### Other

Once the network is working properly, you can perform other network-dependent operations, such as joining a PVE cluster in another server room.

If a virtual machine needs to use an additional standalone IP, it can connect directly to the default `vmbr0`, and then configure the network address according to the information provided by the hosting provider to connect to both IPv4 and IPv6 networks. Because `vmbr0` bridges the physical port where the network cable is plugged in, you can configure the public IP address based on this network without further action.

## Configure the virtual machine's dedicated bridged network vmbr1

More often than not, VMs do not need public IPv4, but only a NAT intranet address or IPv6, so add a bridge network (Linux Bridge) `vmbr1` to the nodes of the PVE:

* IPv4/CIDR: `1.0.0.1/16`
* IPv6/CIDR: `1:2:3:4:a::1/80`

If you plan to use VLANs, the address information here is optional. If you need to test the VM temporarily, use this as the default test network. This IPv4 address is the IPv4 gateway for the VM, and the same for IPv6.

In `vmbr0`, the VM can choose any IPv6 address in the available range, while in `vmbr1`, we want the VM to use only one of the subnet segments [^note:addr-limit]. The first address in `1:2:3:4:aa::/80` is selected.

### Configuring VLANs

In `vmbr1`, turn on 'VLAN aware'. Create a new bridged network, e.g. `vmbr1.100`, with VLAN tag 100. Configure with the following:

* IPv4/CIDR: `1.0.100.1/24`
* IPv6/CIDR: `1:2:3:4:a:100::1/96`.

We want VMs accessing VLANs tagged with 100 to use only addresses in the smaller ranges `1.0.100.0/24` and `1:2:3:4:a:100::/96` [^note:multiple-range].

### Configuring the VM

A CT instance has been chosen here to test the network configuration of the VM, with the benefit of the convenience of setting up the network directly from the PVE control panel. Edit the network information:

* Bridge: `vmbr1`.
* VLAN tagging: `100`.
* IPv4: `static`.
* IPv4/CIDR: `1.0.100.100/24`
* IPv4 gateway: `1.0.100.1`
* IPv6: `static`
* IPv6/CIDR: `1:2:3:4:a:100::100/96`
* IPv6 gateway: `1:2:3:4:a:100::1`.

At this point the VM and PVE can ping each other to test the network.

### Configuring IPv4 NAT

Currently the VM does not have access to the network via IPv4, you need to connect to the PVE node shell, edit `/etc/network/interfaces` and add statements starting with 'post' for `vmbr1`:

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

Save and restart the network[^note:port-forward].

### Configuring IPv6 forwarding and NDP proxy

Edit `/etc/network/interfaces` and add statements starting with 'post' for `vmbr1`:

```conf {3-6} showLineNumbers
iface vmbr1 inet6 static
        address 1:2:3:4:a::1/80
        post-up sysctl -w net.ipv6.conf.default.forwarding=1
        post-up sysctl -w net.ipv6.conf.all.forwarding=1
        post-up sysctl -w net.ipv6.conf.default.proxy_ndp=1
        post-up sysctl -w net.ipv6.conf.all.proxy_ndp=1
```

Save and restart the network. the PVE automatically creates the relevant routes, which can be viewed with `ip -6 route`. If the associated route [^pve-ipv6-route] is missing, add it manually:

```bash
ip -f inet6 route add 1:2:3:4:100::100 dev vmbr1.100
```

Note that this may disappear after a reboot, so add it to your own startup script or to the post-up statement for the `/etc/network/interfaces`.

At this point, there is no external connection to `vmbr1`, `vmbr1.100` and the IPv6 address configured on the VM. Add the NDP proxy:

```bash
# vmbr1
ip -f inet6 neigh add proxy 1:2:3:4:a::1 dev vmbr0
# vmbr1.100
ip -f inet6 neigh add proxy 1:2:3:4:a:100::1 dev vmbr0
# virtual machine
ip -f inet6 neigh add proxy 1:2:3:4:a:100::100 dev vmbr0
```

This can be viewed with `ip -6 neigh show proxy`. If the network is down, try flushing the ndp cache: `ip -6 neigh flush all`.

### NDPPD

When adding VMs in the future, you will also need to add the NDP agent manually. This can be done once and for all with NDPPD.

```bash
apt install ndppd
```

Edit `/etc/ndppd.conf`:

```conf
proxy vmbr0 {
        rule 1:2:3:4::/64 {
                auto
        }
}
```

Enable NDPPD

```bash
systemctl enable --now ndppd
```

## Other

The home broadband network environment is not applicable to the solution in this article. you can use DHCP/SLAAC and other methods to directly auto-configure IPv6 for the virtual machine[^pve-ipv6-auto][^pve-ipv6].

[^note:multiple-range]: In this case, different subnet segments are configured in each of the three interfaces to avoid routing conflicts.
[^note:addr-limit]: If you need to limit the VMs in `vmbr1` or `vmbr1.100` to only use addresses on the planned segments, you can add a firewall rule for them to discard data on non-planned segments.
[^note:reboot]: Sometimes manually changing the PVE's network configuration and rebooting the network has no effect, try rebooting the PVE node.
[^note:port-forward]: In order to connect to a VM on a NAT network from an external IPv4 address, it may be necessary to configure port forwarding in the PVE.

[^pve-ipv6-route]: coldark. [单IPv4独服利用ProxmoxVE建立IPv4-NAT和IPv6虚拟机（小鸡）(Single IPv4 Solo Service Building IPv4-NAT and IPv6 VMs with ProxmoxVE )](https://www.wnark.com/archives/32.html). 方舟基地. 2019. "……这时只能访问IPv4地址，IPv6这个时候还是不通的，需要在主机输入以下命令开启:`... ip -f inet6 route add ...`(...At this point, only IPv4 addresses can be accessed, IPv6 is still not available at this time, you need to enter the following command in the host to turn it on:`... ip -f inet6 route add ... `)"
[^pve-ipv6-auto]: Insylei. [PVE Proxmox VE 使用IPv6(PVE Proxmox VE using IPv6)](https://www.icn.ink/pve/57.html). 自由de风. 2023.
[^pve-ipv6]: bruj0. [ProxmoxIPv6](https://github.com/bruj0/ProxmoxIPv6). Github. [46d1aac](https://github.com/bruj0/ProxmoxIPv6/tree/46d1aac3f0a43102848b69e36aebcf0a18964e14). 2023.