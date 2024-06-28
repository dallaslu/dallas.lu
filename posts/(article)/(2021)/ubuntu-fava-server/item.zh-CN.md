---
title: 用 Ubuntu 搭建可公网访问的 Fava 服务器
date: '2021-11-24 12:14'
license: CC-BY-4.0
taxonomy:
  category:
    - Ubuntu
  tag:
    - Fava
    - Nginx
    - Beancount
    - Bookkeeping
    - Self-hosted
keywords:
  - 搭建 Fava
toc:
  enabled: true
---

Fava 是一个 Beancount 的 Web 工具，当前并未提供用户认证的功能，所以并不适合部署在公网上。本文介绍使用 Nginx 为 Fava 增加用户认证功能，以便于在私有服务器上部署的方法。

===

## 安装
### 安装依赖
```bash
sudo apt install python3 python3-pip python3-dev build-essential
sudo pip install fava
```

### 创建运行环境
```bash
# 添加专属用户
sudo groupadd --system beancount
sudo useradd -s /sbin/nologin --system -g beancount beancount
mkdir -p /home/beancount/example
chown -R beancount: /home/beancount
```

将账本文件放入 `/home/beancount/example` 目录中。如有多个，可在 `/home/beancount` 中创建多个平级目录。

## 配置 Fava

编辑 `/home/beancount/fava.env`，参考下方示例配置账本文件路径（多个账本用空格隔开）：
```ini
BEANCOUNT_FILE=/home/beancount/example/example.bean /home/beancount/test/test.bean
```

创建服务配置文件：
```bash
vim /usr/lib/systemd/system/fava.service
```

输入下方内容并保存
```ini
[Unit]
Description=Beancount Fava
Documentation=https://github.com/beancount/fava
After=network.target

[Service]
EnvironmentFile=/home/beancount/fava.env
User=beancount
Type=simple
ExecStart=fava
WorkingDirectory=/home/beancount
Restart=on-failure
RestartSec=10s
LimitNOFILE=40000

[Install]
WantedBy=multi-user.target
```

加载并启动：
```bash
# 设置目录所有者为 beancount 用户
chown -R beancount: /home/beancount

systemctl daemon-reload
systemctl enable --now fava
systemctl status fava
```

## 配置 Nginx
生成密码：
```bash
htpasswd -c /home/beancount/.htpasswd username
```

参考下方示例，创建 Nginx 虚拟主机配置：
```nginx
server {
    listen  443 ssl http2;
    listen  [::]:443 ssl http2;
    server_name fava.example.com;
    
    # ssl cert config...
    # security conf
    
    location ^~ /{
        auth_basic  "Fava";
        auth_basic_user_file    "/home/beancount/.htpasswd";
        proxy_pass  http://localhost:5000;
    }
}
```

```bash
nginx -t
systemctl reload nginx
```

## Git 同步

### 定时
可使用 crontab 定时执行 pull 及 commit & push 操作。定时脚本可参考：
```bash
cd /home/beancount/example
git pull

status_log=$(git status -sb)

if [ "$status_log" == "## master...origin/master" ];then
        echo "nothing"
else
        echo "[example] commit..."
        # git config --global user.email <>
        git add .
        git commit -m "fava update" -a
fi

git push
```

### Webhook & Plugin

也可使用 Webhook 实现自动 pull[^webhook]；使用 Fava 的扩展 auto-commit 来自动提交。

[^webhook]: [使用 Webhook 来自动拉取代码](/webhook-to-git-pull-from-forgejo/)
