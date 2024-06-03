---
title: Sync Tabby Config with a Self-Built Tabby Web
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
  - Tabby Web
  - podman-compose
  - podman tabby web
  - Tabby Config
toc:
  enabled: true
---

Tabby is a cross-platform SSH terminal with configuration synchronization in its web version. I will introduce building Tabby Web with podman and using Tabby's built-in configuration synchronization feature.

===

Previously, I tried using Nextcloud to synchronize the profile directory[^sync-with-nextcloud], and then switched to the plugin Setting Sync, which hasn't worked very well for a long time, and often failed to synchronize. Tabby's built-in synchronization service is much more stable and supports synchronization and switching between multiple profiles. The built-in sync requires you to connect to a [Tabby Web](https://github.com/Eugeny/tabby-web) instance and log in with an account such as Github to get a sync key. If someone you trust has a Tabby Web instance, you can borrow it.

## Register Github App

Visit <https://github.com/settings/applications/new> to register a new app。Fill in the URL and the callback URL. for example:：

* Homepage URL: `https://tabby.example.com`
* Authorization callback URL: `https://tabby.example.com/api/1/auth/social/complete/github/`

When registration is complete, record the Client ID and obtain the Client secrets.

## Run Tabby Web

Create `podman-compose.yml`[^note:docker]：

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

Then use Nginx, etc. to do a reverse generation for the Tabby Web instance.

## Config Tabby Web

Enter the container shell：

```bash
podman exec -it tabby /bin/sh
```

Find a newer version number from  <https://registry.npmjs.org/tabby-web-container/>, to register it in Tabby Web：

```bash
./manage.sh add_version 1.0.163
```

## Config Tabby Setting Sync

First, enable the Vault, set the master password, and be careful not to turn on the `Encrypt config file`, as this will affect the synchronization. Go to `https://tabby.example.com`, click the login button on the bottom left of the page and select Github Login; click the Settings button on the bottom left of the page and copy the synchronization Token.

In the Tabby setup, go to the `Config file` and backup the current configuration. Then go to the `Config Sync` setting and fill in the information:

* Sync Host: `https://tabby.example.com`
* Secret sync token: <Your Tabby Sync Token>

Wait a few moments and you will see the synchronized configuration (profile) below. You can upload and write, download and overwrite, or create a new one. It is recommended to turn on the `Sync automatically` option.

[^note:docker]: You can also use docker and docker-compose. For this article, we've chosen to use podman and podman-compose.
[^sync-with-nextcloud]: Dallas Lu. [Sync Tabby Config with Nextcloud](/sync-tabby-config-with-nextcloud/). ISSN 2770-7288. 2021.