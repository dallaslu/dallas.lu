---
title: 使用你的主网域作為 Mastodon 實例名
date: '2020-11-10 13:44'
author: 'dallaslu'
license: CC-BY-NC-SA-4.0
taxonomy:
    category:
        - Internet
    tag:
        - Mastodon
        - Nginx
    series:
        - Unify Your Online Accounts
toc:
  enabled: true
---
如果你有一個自建的博客，並且打算或已經建立一個 Mastodon 實例，那麼就不得不面對一個網域選擇的問題了。假設你的博客是 `example.com`，那麼你的 Mastodon 賬號應該是 `yourname@example.com` 還是 `yourname@mastodon.example.com` ？

===

為了簡單明了，你自然更希望博客網域和 Mastodon 網域是同一個。但是 Mastodon 無法運行在二級目錄下。即使通過反代等手段，把 Mastodon 的 web 部分，轉移到了某個二級網域或目錄下，那麼作為一個去中心化的服務，在與聯邦宇宙其他實例節點交換數據時，很可能發生未知的問題。

幸運的是，聯邦節點間通信的重要一步是訪問 `https://example.com/.well-known/host-meta`，這個文件的內容中包含了供後續步驟使用的URL 。而且 Mastodon 也支持 `LOCAL_DOMAIN ` 和 `WEB_DOMAIN `兩個選項。

## 配置 Mastodon

編輯 `.env.production`，進行如下修改：

1. __不要__修改 `LOCAL_DOMAIN`；
2. 添加 WEB_DOMAIN 配置，設置為一個二級網域，比如 `mastodon.example.com`。 

## 配置 mastodon.example.com

參考 Mastodon 文檔，為 `mastodon.example.com` 配置一個 nginx 主機。重啟 Mastodon 的 streaming/sidekiq/web 服務，重新載入 nginx 配置，現在 `mastodon.example.com` 已經可以訪問了。

## 配置 example.com

但是外部實例嘗試連接你的帳號 `yourname@example.com` 時，尚不知曉你的地址是 mastodon.example.com，所以我們希望訪問 `https://example.com /.well-known/host-meta` 時能返回`https://mastodon.example.com/.well-known/host-meta` 的內容。

在 `example.com` 的 nginx 配置中，移除 Mastodon 的配置，僅添加如下規則：

```nginx
location = /.well-known/host-meta {
       return 301 https://mastodon.example.com$request_uri;
}
```

重新載入 nginx 即可。

## 更多配置

以上配置均來自於felx 的補充文檔[Using a different domain name for Mastodon and the users it serves](https://github.com/felx/mastodon-documentation/blob/master/Running-Mastodon/Serving_a_different_domain.md)。正如文中所說，儘管通過主域名跳轉和 WEB_DOMAIN 配置，能夠實現需求，但因為實例版本不一、客戶端種類繁雜，難免仍會有奇怪的問題發生。

而且將已經運行了一段時間的 Mastodon 從主域名切換到二級網域，可能會有更明顯的問題。

根據官方文檔中的 [Routes 章節](https://docs.joinmastodon.org/dev/routes/)，以及使用經驗，建議為 example.com 設置如下規則，增加兼容性：

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

現在可以用 `yourname@example.com` 來嘟嘟了。
