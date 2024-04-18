---
title: 使用你的主域名作为 Mastodon 实例名
date: '2020-11-10 13:44'
author: 'dallaslu'
license: CC-BY-NC-SA-4.0
taxonomy:
    category:
        - Internet
    tag:
        - Mastodon
        - Nginx
        - Unify-your-online-accounts
toc:
  enabled: true
---
如果你有一个自建的博客，并且打算或已经建立一个 Mastodon 实例，那么就不得不面对一个域名选择的问题了。假设你的博客是 `example.com`，那么你的 Mastodon 账号应该是 `yourname@example.com` 还是 `yourname@mastodon.example.com`？

===

为了简单明了，你自然更希望博客域名和 Mastodon 域名是同一个。但是 Mastodon 无法运行在二级目录下。即使通过反代等手段，把 Mastodon 的 web 部分，转移到了某个二级域名或目录下，那么作为一个去中心化的服务，在与联邦宇宙其他实例节点交换数据时，很可能发生未知的问题。

幸运的是，联邦节点间通信的重要一步是访问 `https://example.com/.well-known/host-meta`，这个文件的内容中包含了供后续步骤使用的 URL。而且 Mastodon 也支持 `LOCAL_DOMAIN `和 `WEB_DOMAIN `两个选项。

## 配置 Mastodon

编辑 `.env.production`，进行如下修改：

1.   __不要__修改 `LOCAL_DOMAIN`；
2.   添加 WEB\_DOMAIN 配置，设置为一个二级域名，比如 `mastodon.example.com`。

## 配置 mastodon.example.com

参考 Mastodon 文档，为 `mastodon.example.com` 配置一个 nginx 主机。重启 Mastodon 的 streaming/sidekiq/web 服务，重新载入 nginx 配置，现在 `mastodon.example.com` 已经可以访问了。

## 配置 example.com

但是外部实例尝试连接你的账号 `yourname@example.com` 时，尚不知晓你的地址是 mastodon.example.com，所以我们希望访问 `https://example.com/.well-known/host-meta` 时能返回 `https://mastodon.example.com/.well-known/host-meta` 的内容。

在 `example.com` 的 nginx 配置中，移除 Mastodon 的配置，仅添加如下规则：

```nginx
location = /.well-known/host-meta {
       return 301 https://mastodon.example.com$request_uri;
}
```

重新载入 nginx 即可。

## 更多配置

以上配置均来自于 felx 的补充文档 [Using a different domain name for Mastodon and the users it serves](https://github.com/felx/mastodon-documentation/blob/master/Running-Mastodon/Serving_a_different_domain.md)。正如文中所说，尽管通过主域名跳转和 WEB_DOMAIN 配置，能够实现需求，但因为实例版本不一、客户端种类繁杂，难免仍会有奇怪的问题发生。

而且将已经运行了一段时间的 Mastodon 从主域名切换到二级域名，可能会有更明显的问题。

根据官方文档中的 [Routes 章节](https://docs.joinmastodon.org/dev/routes/)，以及使用经验，建议为 example.com 设置如下规则，增加兼容性：

```nginx
## mastodon web url
location ~ ^/(about/more|settings|web|pghero|sidekiq|admin|interact|explore|public|@.*|relationships|filters|terms|inert.css){
        rewrite ^(.*) https://$mastodon_host$1 permanent;
}

## mastodon .well-known
location ~ ^/(.well-known/(host-meta|nodeinfo|webfinger|change-password|keybase-proof-config)|nodeinfo) {
        rewrite ^(.*) https://$mastodon_host$1 permanent;
}

## mastodon system resources
location ~ ^/(system|headers|avatars) {
        ## set your mastodon public folder, or just redirect to $mastodon_host
        #rewrite ^(.*) https://$mastodon_host$1 permanent;
        root /home/mastodon/live/public;
}

## mastodon url (possible use post)
location ~ ^/(api/v1|inbox|actor|oauth|auth|users){
        return 308 https://$mastodon_host$request_uri;
}
```

现在可以用 `yourname@example.com` 来嘟嘟了。
