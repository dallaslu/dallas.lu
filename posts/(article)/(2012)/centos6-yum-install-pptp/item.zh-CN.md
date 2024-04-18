---
title: CentOS6 yum 安装 pptp
date: '2012-07-24 20:28'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - CentOS
        - PPTPD
        - VPN
        - Yum

---
与一键安装包的方式相比，通过 yum 方式安装的好处是便于管理，可以通过 `yum update` 命令来升级程序版本。

===

## 安装 ppp 和 iptalbes

```bash
yum install ppp iptables
```

## 安装 pptpd

加入 yum 源

```bash
rpm -Uvh http://poptop.sourceforge.net/yum/stable/rhel6/pptp-release-current.noarch.rpm
```

安装 pptpd

```bash
yum install pptpd
```

## 开启路由转发

```bash
vi /etc/sysctl.conf
```

修改：

```ini
net.ipv4.ip_forward = 1
```

执行：

```bash
/sbin/sysctl -p
```

## 配置

修改 /etc/ppp/options.pptpd

```bash
ms-dns 4.2.2.1
ms-dns 4.2.2.2
```

修改 /etc/pptpd.conf

```bash
localip 10.8.8.1
remoteip 10.8.8.2-245
```

## 开机启动、运行

```bash
chkconfig pptpd on
service pptpd start
```

## 账号

修改 /etc/ppp/chap-secrets 文件即可，例如添加账号:

```bash
echo -e 'vpntest * vpntestpassword *' >> /etc/ppp/chap-secrets
```

## iptables 配置

```bash
chkconfig iptables on

/sbin/iptables -A INPUT -p tcp --dport 1723 -j ACCEPT
/sbin/iptables -A INPUT -p tcp --dport 47 -j ACCEPT
/sbin/iptables -A INPUT -p gre -j ACCEPT
iptables -A POSTROUTING -t nat -s 10.10.10.0/24 -o eth0 -j MASQUERADE

service iptables start
```

参考：<http://www.deepvps.com/centos-pptp-vpn-install.html>
