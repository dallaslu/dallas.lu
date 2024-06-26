---
title: 使用自建 Tabby Web 来同步 Tabby 配置
date: '2024-02-21 02:21'
author: 'dallaslu'
license: WTFPL
taxonomy:
    category:
        - Software
    tag:
        - SSH
        - Tabby
        - Podman
keywords:
  - Tabby Sync
  - Tabby 多端同步
  - Tabby 同步
  - Tabby配置同步
  - Tabby Web
  - podman-compose
  - podman tabby web
toc:
  enabled: true
---

Tabby 作为一个跨平台的 多功能 SSH 终端，在其 Web 版中提供了配置同步的功能。本文介绍用 podman 搭建 Tabby Web 及使用 Tabby 内建的配置同步功能。

===

在此之前，我尝试过使用 Nextcloud 来同步配置文件目录[^sync-with-nextcloud]，后来改用插件 Setting Sync。长期以来该插件工作并不是很稳定，常有提示无法同步的情况。而 Tabby 内建的同步服务使用起来则稳定许多，还支持多套配置 (profile) 的同步与切换。内建的同步功能需要连接一个 [Tabby Web](https://github.com/Eugeny/tabby-web) 实例，用 Github 等账户授权登录后获得同步密钥。如果你有信任的人拥有一个 Tabby Web 实例，你可直接借用。

## 注册 Github App

访问 <https://github.com/settings/applications/new> 注册一个应用。填入地址与回调 URL。例如：

* Homepage URL: `https://tabby.example.com`
* Authorization callback URL: `https://tabby.example.com/api/1/auth/social/complete/github/`

注册完成后，记录 Client ID 并获取 Client secrets。

## 运行 Tabby Web

创建 `podman-compose.yml`[^note:docker]：

```yaml
services:
  tabby:
    image: ghcr.io/eugeny/tabby-web:latest
    container_name: tabby
    restart: always
    ports:
      - '8000:8000'
    volumes:
      - ./data:/app-dist
    environment:
      - DATABASE_URL=sqlite:////app-dist/db.sqlite3 
      - PORT=8000
      - DEBUG=False
      - SOCIAL_AUTH_GITHUB_KEY=<Your Github App Client ID>
      - SOCIAL_AUTH_GITHUB_SECRET=<Your Github App Client Secret>
```

```bash
podman pull ghcr.io/eugeny/tabby-web:latest
podman-compose up -d
```

然后使用 Nginx 等为 Tabby Web 实例做一个反代。

## 配置 Tabby Web

进入容器 shell：

```bash
podman exec -it tabby /bin/sh
```

从 <https://registry.npmjs.org/tabby-web-container/> 中找一个较新的版本号，给 Tabby Web 注册应用版本：

```bash
./manage.sh add_version 1.0.163
```

## 配置 Tabby 同步

首先要启用库（Vault），设置主密码，注意不要开启 `Encrypt config file`，这会影响同步功能。访问 `https://tabby.example.com`，点击页面左下登录按钮，选择 Github 登录；点击页面左下设置按钮，复制同步 Token。

在 Tabby 设置中，先进入 `Config file`， 备份一下当前的配置。然后进入 `Config Sync` 设置，填入信息：

* Sync Host: `https://tabby.example.com`
* Secret sync token: <Your Tabby Sync Token>

稍等片刻，即可在下方看到已经同步的配置（profile）。可以上传写入、下载覆盖，或者创建新的。建议开启 `Sync automatically` 选项。

[^note:docker]: 使用 docker 和 docker-compose 亦可。本文选择使用 podman 和 podman-compose。
[^sync-with-nextcloud]: Dallas Lu. [使用 Nextcloud 同步 Tabby 配置文件](/sync-tabby-config-with-nextcloud/). ISSN 2770-7288. 2021.