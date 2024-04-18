---
title: 搭建多用户、多账本 Fava 服务器
date: '2023-01-17 17:01'
published: true
license: CC-BY-NC-SA-4.0
taxonomy:
  category:
    - Ubuntu
  tag:
    - Fava
    - Nginx
    - Beancount
    - Bookkeeping
keywords:
  - Fava 搭建
  - 多账本 Fava 搭建
  - 多人一起用 Fava
  - 自建 记账
toc:
  enabled: true
---

此前有方案可利用 Nginx 为 Fava 增加认证功能，但只能提供固定的一组账本。本文介绍让多个用户一起使用 Fava 服务器的方法，以及各账本在不同账号之间的共享方案。

===

!!! 如果你仅需单用户，可参考更简单的方案：[用 Ubuntu 搭建可公网访问的 Fava 服务器](https://dallas.lu/ubuntu-fava-server)

## 安装
### 安装依赖
```bash
# apache-utils for htpasswd
sudo apt install python3 python3-pip python3-dev build-essential apache-utils

sudo pip install fava
```
### 创建运行环境
```bash
# 添加专属用户
sudo groupadd --system beancount
sudo useradd -s /sbin/nologin --system -g beancount beancount

# 创建账本文件
mkdir -p /home/beancount/accountings/example-a
mkdir -p /home/beancount/accountings/example-b
mkdir -p /home/beancount/accountings/example-c

# 创建账本合集（Fava 配置）文件夹
mkdir -p /home/beancount/collections

# 创建两个配置文件
touch /home/beancount/collections/default.env
touch /home/beancount/collections/another.env

chown -R beancount: /home/beancount
```

将你的 **账本文件夹** 放入 `/home/beancount/accountings` 目录中。例如上面创建了名字是 `example-*` 形式的三个独立账本 `a`, `b` 和 `c`。

## 配置 Fava

编辑 `/home/beancount/collectoions/default.env`，在其中定义一套账本合集，用以提供一个 Fava 实例的运行参数，参考下方示例配置账本文件路径（多个账本用空格隔开）：
```ini
BEANCOUNT_FILE=/home/beancount/accountings/example-a/main.bean /home/beancount/accountings/example-c/main.bean
FAVA_PORT=5000
```

设置第二个合集实例：`/home/beancount/collectoions/another.env`
```ini
BEANCOUNT_FILE=/home/beancount/accountings/example-b/main.bean /home/beancount/accountings/example-c/main.bean
FAVA_PORT=5001
```

创建服务配置模板文件：
```bash
vim /usr/lib/systemd/system/fava@.service
```
输入下方内容并保存
```ini
[Unit]
Description=Beancount Fava collection (%i)
Documentation=https://github.com/beanicount/fava
After=network.target

[Service]
EnvironmentFile=/home/beancount/collections/%i.env
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
```
# 设置目录所有者为 beancount 用户
chown -R beancount: /home/beancount

systemctl daemon-reload
systemctl enable --now fava@default
systemctl enable --now fava@another
systemctl status fava@default
systemctl status fava@another
```
## 配置 Nginx
生成密码：
```bash
htpasswd -c /home/beancount/.htpasswd user1

# 添加第二个用户
htpasswd /home/beancount/.htpasswd user2
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

        # 用户 user1 由 fava@default 提供服务
        if ($remote_user = 'user1') {
            proxy_pass  http://localhost:5000; 
        }
        
        # 用户 user2 由 fava@another 提供服务
        if ($remote_user = 'user2') {
            proxy_pass  http://localhost:5001;
        }
    }
}
```
```bash
nginx -t
systemctl reload nginx
```
## 使用

当 `user1` 登录时，可在页面导航位置切换到 `a` 账本 `c` 账本；当 `user2` 登录时，可在页面导航位置切换到 `b` 账本 `c` 账本。
两个用户各自由不同的 Fava 实例提供服务，分别对应了两套不同的账本集，两个集合有着一个共享的账本。

## Git 同步

### 定时
可使用 crontab 定时执行 pull 及 commit & push 操作。定时脚本可参考：
```bash
cd /home/beancount/accountings/example-a
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
