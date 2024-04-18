---
title: Using Webhook to Automatically Pull Code
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
  - Webhook Getting Started
  - Webhook Usage
  - Automatically Pull Code
  - Webhook Config
  - Webhook yaml
toc:
  enabled: true
---

Many applications store data in texts, such as the Beancount, or some static blogs. This data is ideal for versioning with git. However, after you push your changes locally, you need to pull them somewhere else. This article uses Webhook to automate this process.

===

Previously, when building Fava, I used a timed task to pull [^fava-server]; previously, the articles on this site were modified and updated manually [^note:new-blog-program]. Here's an example of how to do it with Ubuntu and Forgejo[^note:forgejo].

## Webhook

[Webhook](https://github.com/adnanh/webhook) is a webhook utility written with Go that can be used to build a general-purpose webhook server (much like Weibo(微博), with product features as product names). It can be installed directly on Ubuntu:

```bash
apt install webhook
systemctl enable webhook
touch /etc/webhook.yaml
```

Don't start it yet, because the default Webhook service file points to the configuration file `/etc/webhook.conf`, which neither exists nor has a file extension supported by Webhook. Modify the configuration file `/usr/lib/systemd/system/webhook.service`:

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

Webhook also supports configuration files in json format, which has a `.json` suffix. To continue with the `.yaml` format, edit `/etc/webhook.yaml`[^note:match-gitea]:

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

Note that you need to set the `secret`, and the name of the master branch (`main`/`master`) yourself.

```bash
touch /path-to-script.sh
systemctl daemon-reload
systemctl start webhook
systemctl status webhook
```

If the Webhook service can be started normally then continue.

## Nginx Proxy

Webhook provides http service on port 9000 by default. For security reasons, Nginx is used as a reverse proxy to provide https service. For more information, please refer to the following:

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

## Forgejo Adding Hooks

On the settings page of the corresponding repo on Forgejo, add a web hook. The URL should be `https://your-domain.com/hooks/hookname` and the key text should be `REPLACE_WITH_YOUR_SECRET`. Save it and click "Test Push" at the bottom of the page to debug it.

You should also add a deployment key, which will be the SSH public key that will be used to automate the git pull. If you also need to push code in this environment, remember to check the "Enable write access" box.

## git pull script

文件 `path-to-script.sh`：

```bash {8}
#!/bin/sh

git pull

status_log=$(git status -sb)

# In bash, `=` in the following line should be `==`
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

It is recommended to commit this script to the root of the repo to make it easier to use. After cloning the repo at the target location, try executing the script first:

```bash
chomod +x path-to-script.sh
sh path-to-script.sh
```

## Conclusion

At this point, the code is automatically pulled (no Actions at all!). In practice, you may want to refine the webhook's match rules and check parameters in the script as needed.

[^note:new-blog-program]: Since May, this site has been built using a program based on SvelteKit's own development.
[^note:forgejo]: Forgejo is a branch of Gitea, build tutorial: [Build Forgejo on Ubuntu](/install-forgejo-on-ubuntu/).
[^note:match-gitea]: The Webhook project's [example](https://github.com/adnanh/webhook/blob/master/docs/Hook-Examples.md#incoming-gitea-webhook) and [issue#280](https://github.com/adnanh/webhook/issues/280) may only work with older versions of Gitea.

[^fava-server]: Dallas Lu. [搭建多用户、多账本 Fava 服务器(Build Multi-User, Multi-Book Fava Server)](/ubuntu-fava-server-for-multiple-user/).
