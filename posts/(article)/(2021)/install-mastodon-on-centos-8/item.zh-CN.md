---
title: 在 CentOS 8 上搭建 Mastodon
date: '2021-07-30 19:00'
author: 'dallaslu'
published: false
license: CC-BY-NC-SA-4.0
taxonomy:
    category:
        - Software
    tag:
        - CentOS8
        - Mastodon
keywords:
  - 手动安装 Mastodon
  - Mastodon 非 Docker
---
Mastodon 是联邦宇宙中的一个重要成员，功能像 Twitter 。本文介绍如何在 CentOS 8 中搭建 Mastodon 实例。

## 安装依赖

```bash
sudo dnf install curl git gpg gcc git-core zlib zlib-devel gcc-c++ \
  patch readline readline-devel  libffi-devel openssl-devel make \
  autoconf automake libtool bison curl sqlite-devel ImageMagick \
  libxml2-devel libxslt-devel gdbm-devel ncurses-devel glibc-headers \
  glibc-devel libicu-devel protobuf jemalloc-devel jemalloc

sudo dnf install --enablerepo=powertools \
  libyaml-devel libidn-devel protobuf-devel
```

## 使用 PostgreSQL

安装过程不再赘述。

配置用户：

```bash
sudo su - postgres
```

```bash
createuser mastodon
psql
```

```postgresql
ALTER USER mastodon WITH ENCRYPTED password 'DBPassword' CREATEDB;
\q
```

```bash
exit
```

安装依赖：

```bash
dnf -y install libpqxx-devel
```

## 配置用户

```bash
adduser mastodon -d /home/mastodon
sudo su - mastodon
```

## 安装 Ruby

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec bash
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install 2.7.2
rbenv global 2.7.2
gem install bundler --no-document
```

## 安装 Mastodon

```bash
git clone https://github.com/mastodon/mastodon.git live && cd live
git checkout $(git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1)

bundle config deployment 'true'
bundle config without 'development test'
bundle install -j$(getconf _NPROCESSORS_ONLN)
yarn install --pure-lockfile

## 运行安装向导
RAILS_ENV=production bundle exec rake mastodon:setup
```

配置文件位于 `.env.production`，可[参考配置文档](https://docs.joinmastodon.org/zh-cn/admin/config/)按需修改。

```bash
exit
```

## 创建系统服务

```bash
cp /home/mastodon/live/dist/mastodon-*.service /etc/systemd/system/
```

编辑以下文件，确认文件内的配置是正确的：
* `/etc/systemd/system/mastodon-web.service`
* `/etc/systemd/system/mastodon-sidekiq.service`
* `/etc/systemd/system/mastodon-streaming.service`

加载、启动服务

```bash
systemctl daemon-reload
systemctl enable --now mastodon-*
```
