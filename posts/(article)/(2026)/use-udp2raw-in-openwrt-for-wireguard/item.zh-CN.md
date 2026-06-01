---
title: OpenWRT 使用 udp2raw 对抗 WireGuard 阻断
date: '2026-06-01 06:01'
license: CC-BY-NC-SA-4.0
taxonomy:
    category:
        - Internet
    tag:
        - OpenWRT, WireGuard
---

WireGuard 本身协议特征比较明显，默认配置很容易被识别甚至封锁。为了稳定地连接，需要额外加一层伪装

===

假设服务端 IP 为 11.22.33.44，并使用 443 端口。

### udp2raw

udp2raw 可以把 UDP 伪装成 TCP。在服务端使用：

```bash
udp2raw -s \
-l0.0.0.0:443 \
-r127.0.0.1:51820 \
-k udp2raw_password \
--raw-mode faketcp
```

客户端：

```bash
udp2raw -c \
-r 11.22.33.44:443 \
-l127.0.0.1:4000 \
-k udp2raw_password \
--raw-mode faketcp
```

### 服务端配置

```bash
cd /tmp
wget https://github.com/wangyu-/udp2raw/releases/download/20230206.0/udp2raw_binaries.tar.gz
tar zxvf udp2raw_binaries.tar.gz
sudo cp udp2raw_amd64 /usr/local/bin/udp2raw
sudo chmod +x /usr/local/bin/udp2raw
```

编辑 `/etc/wireguard/wg0.conf`

```bash
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = 服务端私钥

PostUp = sysctl -w net.ipv4.ip_forward=1
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = OpenWrt公钥
AllowedIPs = 10.0.0.2/32
```

启动

```bash
sudo systemctl enable --now wg-quick@wg0
```

#### 安装 udp2raw 服务

编辑 `/etc/systemd/system/udp2raw.service`：

```ini
[Unit]
Description=udp2raw
After=network.target

[Service]
ExecStart=/usr/local/bin/udp2raw \
-s \
-l0.0.0.0:443 \
-r127.0.0.1:51820 \
-k your-password \
--raw-mode faketcp \
-a

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

启动

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now udp2raw
```

### OpenWRT

#### 安装 WireGuard

```bash
opkg update
opkg install wireguard-tools luci-app-wireguard
```

创建一个网络接口 wg0, 远端节点 IP端口填写为 `127.0.0.1` 和 `4096`。

#### 安装 udp2raw

有的 OpenWRT 里没有下载命令，可以通过 System > Software 来上传一个包。下载 <https://github.com/wangyu-/udp2raw/releases/download/20230206.0/udp2raw_binaries.tar.gz> 后解压，找到对应的版本（amd/arm），上传到 OpenWRT 后：

```bash
mv /tmp/upload.ipk /usr/bin/udp2raw
chmod +x /usr/bin/udp2raw
```

OpenWRT 可能还需要安装 iptables-nft：

```bash
opkg update
opkg install iptables-nft kmod-ipt-core kmod-ipt-conntrack kmod-ipt-nat
```

创建配置：

```bash
vi /etc/config/udp2raw
```

```ini
config udp2raw 'main'
    option enabled '1'
    option mode 'client'
    option local_addr '127.0.0.1'
    option local_port '4096'
    option remote_addr '11.22.33.44'
    option remote_port '443'
    option password 'udp2raw_password'
    option raw_mode 'faketcp'
    option auto_rule '1'
    option log_level '4'
```

创建脚本：

```bash
vi /etc/init.d/udp2raw
```

写入：

```bash
#!/bin/sh /etc/rc.common

START=99
USE_PROCD=1

CONFIG_FILE="udp2raw"
PROG="/usr/bin/udp2raw"

start_service() {
    config_load "$CONFIG_FILE"
    config_foreach start_instance udp2raw
}

start_instance() {
    local section="$1"

    local enabled mode local_addr local_port remote_addr remote_port
    local password raw_mode auto_rule log_level

    config_get_bool enabled "$section" enabled 0
    [ "$enabled" = "1" ] || return 0

    config_get mode "$section" mode "client"
    config_get local_addr "$section" local_addr "127.0.0.1"
    config_get local_port "$section" local_port "4096"
    config_get remote_addr "$section" remote_addr
    config_get remote_port "$section" remote_port "443"
    config_get password "$section" udp2raw_password
    config_get raw_mode "$section" raw_mode "faketcp"
    config_get_bool auto_rule "$section" auto_rule 1
    config_get log_level "$section" log_level "4"

    [ -n "$remote_addr" ] || {
        echo "udp2raw: remote_addr is required"
        return 1
    }

    [ -n "$password" ] || {
        echo "udp2raw: password is required"
        return 1
    }

    procd_open_instance "$section"

    if [ "$mode" = "server" ]; then
        procd_set_param command "$PROG" \
            -s \
            -l"${local_addr}:${local_port}" \
            -r"${remote_addr}:${remote_port}" \
            -k "$password" \
            --raw-mode "$raw_mode" \
            --log-level "$log_level"
    else
        procd_set_param command "$PROG" \
            -c \
            -l"${local_addr}:${local_port}" \
            -r"${remote_addr}:${remote_port}" \
            -k "$password" \
            --raw-mode "$raw_mode" \
            --log-level "$log_level"
    fi

    [ "$auto_rule" = "1" ] && procd_append_param command -a

    procd_set_param respawn
    procd_set_param stdout 1
    procd_set_param stderr 1

    procd_close_instance
}

reload_service() {
    stop
    start
}
```

执行

```bash
chmod +x /etc/init.d/udp2raw
/etc/init.d/udp2raw enable
/etc/init.d/udp2raw start
```

未来修改配置可以：

```bash
uci set udp2raw.main.remote_addr='22.33.44.55'
uci set udp2raw.main.password='newpassword'
uci commit udp2raw
/etc/init.d/udp2raw restart
```
