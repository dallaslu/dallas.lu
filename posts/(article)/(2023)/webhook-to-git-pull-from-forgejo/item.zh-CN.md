---
title: 使用 Webhook 来自动拉取代码
date: '2023-05-31 05:31'
published: true
license: CC-BY-SA-4.0
taxonomy:
  category:
    - Software
  tag:
    - Webhook
    - Git
    - Forgejo
    - Beancount
keywords:
  - Webhook 入门
  - Webhook 使用
  - 自动pull代码
  - Webhook 配置
  - Webhook yaml
toc:
  enabled: true
---

很多应用以文本来存储数据，比如 Beancount 账本、一些静态博客。这些数据非常适合用 git 来做版本管理。但本地修改并 push 之后，还需要在其他地方 pull 才行。本文使用 Webhook 来自动完成这一操作过程。

===

之前在搭建 Fava 时，使用了定时任务来 pull[^fava-server]；此前本站的文章修改后也是手动更新的[^note:new-blog-program]。下面以 Ubuntu 系统和 Forgejo 为例进行操作[^note:forgejo]。

## Webhook

[Webhook](https://github.com/adnanh/webhook) 是一个 Go 语言的 webhook 工具，可以用来搭建通用的 webhook server（跟微博一样，用产品功能当产品名）。在 Ubuntu 上可以直接安装：

```bash
apt install webhook
systemctl enable webhook
touch /etc/webhook.yaml
```

先不要着急启动，因为默认的 Webhook 的 service 文件中把配置文件指向了 `/etc/webhook.conf`，这个文件既不存在，其文件后缀也不能被 Webhook 所支持。修改配置文件 `/usr/lib/systemd/system/webhook.service`：

```ini {4,7} showLineNumbers filename="/usr/lib/systemd/system/webhook.service"
[Unit]
Description=Small server for creating HTTP endpoints (hooks)
Documentation=https://github.com/adnanh/webhook/
ConditionPathExists=/etc/webhook.yaml

[Service]
ExecStart=/usr/bin/webhook -nopanic -hotreload -verbose -hooks /etc/webhook.yaml 

[Install]
WantedBy=multi-user.target
```

Webhook 也支持 json 格式的配置文件，对应的配置文件名后缀是 `.json`。下面以 `.yaml` 格式继续操作，编辑 `/etc/webhook.yaml`[^note:match-gitea]：

```yaml {2,3,15,21} filename="/etc/webhook.yaml"
- id: hookname
  execute-command: "/path-to-script.sh"
  command-working-directory: "/path-to-working-dir"
  pass-arguments-to-command:
  - source: payload
    name: head_commit.id
  - source: payload
    name: pusher.name
  - source: payload
    name: pusher.email
  trigger-rule:
    and:
    - match:
        type: payload-hmac-sha256
        secret: 'REPLACE_WITH_YOUR_SECRET'
        parameter:
          source: header
          name: X-Gitea-Signature
    - match:
        type: value
        value: refs/heads/main
        parameter:
          source: payload
          name: ref
```

这里要注意，需要自己设定 `secret`，以及主分支名称（`main`/`master`）。

```bash
touch /path-to-script.sh
systemctl daemon-reload
systemctl start webhook
systemctl status webhook
```

如果 Webhook 服务可以正常启动再继续。

## Nginx 代理

Webhook 默认在本机的 9000 端口提供 http 服务，安全起见，用 Nginx 做反代来提供 https 服务。可参考：

```nginx {4,6}
server {
    listen          443 ssl http2;
    listen          [::]:443 ssl http2;
    server_name your-domain.com;

    # YOUR SSL CONFIG

    location ^~ / {
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_pass http://localhost:9000/;
    }
    access_log off;
}
```

## Forgejo 添加钩子

在 Forgejo 上对应 repo 的设置页面，添加一个 Web钩子。其中，URL 应该填写为 `https://your-domain.com/hooks/hookname`，密钥文本应该填写为 `REPLACE_WITH_YOUR_SECRET`。保存后可在页面下方点击「测试推送」来调试。

还要添加一个部署密钥，将需要自动 git pull 所使用 SSH 公钥填上。如果同时需要在这个环境 push 代码，记得勾选「启用写权限」。

## git pull 脚本

文件 `path-to-script.sh`：

```bash {8}
#!/bin/sh

git pull

status_log=$(git status -sb)

# 在 bash 中，下面一行中的 `=` 应为 `==`
if [ "$status_log" = "## main...origin/main" ];then
        echo "nothing"
else
        echo "commit..."
        # git config --global user.email <>
        git add .
        git commit -m "update" -a
fi

git push
```

建议将这个脚本提交到 repo 的根目录下，这样使用起来更方便。在目标位置 clone 好 repo 后，先试执行脚本：

```bash
chomod +x path-to-script.sh
sh path-to-script.sh
```

## 结语

至此，就实现了自动 pull 代码（要啥 Actions!）。实际使用上，根据需要，可能要细化 webhook 的 match 规则，以及在脚本中检查参数。

[^note:new-blog-program]: 从5月份开始，本站使用基于 SvelteKit 自行开发的程序搭建。
[^note:forgejo]: Forgejo 是 Gitea 的一个分支，搭建教程：[在 Ubuntu 上搭建 Forgejo](/install-forgejo-on-ubuntu/)。
[^note:match-gitea]: Webhook 项目的[示例](https://github.com/adnanh/webhook/blob/master/docs/Hook-Examples.md#incoming-gitea-webhook) 和 [issue#280](https://github.com/adnanh/webhook/issues/280) 的配置方式可能只适用于旧版本的 Gitea.

[^fava-server]: [搭建多用户、多账本 Fava 服务器](/ubuntu-fava-server-for-multiple-user/)
