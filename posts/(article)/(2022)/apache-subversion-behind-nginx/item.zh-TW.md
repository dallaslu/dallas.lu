---
title: Nginx 反代 Apache Subversion
date: '2022-01-03 00:52'
author: 'dallaslu'
published: true
license: CC-BY-4.0
taxonomy:
    category:
        - Software
    tag:
        - Nginx
        - Apache
        - Subversion
        - Regexp
toc:
  enabled: true
---
Subversion 聽上去像是十年前的東西了，尤其是  `mod_dav_svn`。不過祖傳代碼放在哪裡可就不好說了。總之，你已經有了一個現成的 Nginx，希望為已經一個一直裸奔著的代碼倉庫添加 HTTPS 的支持，但並非一句 `proxy_pass` 就能搞得定。

===

例如： 

```nginx
upstream subversion{
    127.0.0.1:1080;
}
server{
    listen [::]:443;
    server_name svn.example.com;

    # SSL ...

    location / {
        proxy_pass http://subversion;
    }
}
```

首先，恭喜一下，沒有使用 `proxy_pass http://subversion/`，避免了第一個坑。因為結尾的 `/` 字符會使得 Nginx 自動對 URL 進行編碼，從而影響正常使用。但馬上就會在提交時會遇到 502 錯誤。 

## COPY 和 DELETE 的支援

Subversion 認爲 `https://svn.example.com` 是一个 HTTPS 連結，而 Apache 只提供了 HTTP 服務，所以請求 Header 中的 `Destination` 應以 `http://` 開頭才能正常工作。 

很快，你從 Stackoverfollow 找到了修改的辦法：

```nginx
location / {
    proxy_pass http://subversion;
    set $fixed_destination $http_destination;
    if ( $http_destination ~* ^https(.*)$ ) {
        set $fixed_destination http$1;
    }
    proxy_set_header Destination $fixed_destination;
}
```

然後發現一切 OK。很好，果然掉進了第二個坑。

## Nginx 的迷惑行爲

`$fixed_destination` 看起來只是把 `https://` 替換成了 `http://`，非常簡單明瞭，沒有問題。

當你愉快地從主幹上複製了一個新分支，修改了一個檔案名包含中文的檔案，順利地編譯並通過測試；然後再合併回主乾時，如果足夠細心的話，就會發現這個檔案名被 urlencode 了。當然，並不是僅僅包括中文名檔案，想像一下，可是分支中的提交的所有檔案的名字都被 urlencode 了哦！而且已經被 urlencode 過的檔案名，下次合併分支時還會被再 urlencode 一次哦！

問題就在於 `$fixed_destination`。`http$1` 其實就被 Nginx 進行了一次 urlencode。也許你決定把修改 `Destination` 的操作交給 Apache，或者決定寫一段 lua 腳本進行解碼，來規避這個神奇的問題。且慢！這裡還有一個神奇的解決辦法：

```nginx
location / {
    proxy_pass http://subversion;
    set $fixed_destination $http_destination;
    if ( $http_destination ~* ^https(?<unencoded_destinaton>.*)$ ) {
        set $fixed_destination http$unencoded_destinaton;
    }
    proxy_set_header Destination $fixed_destination;
}
```

給匹配用的正則組加一個命名就 OK 了…… 

## 其他

這個解決方案出自 [Maxim Dounin](https://trac.nginx.org/nginx/ticket/348) 九年多以前的回复。所以，**在 Nginx 中使用正則修改變量最好使用命名捕獲組**。

十年前的架構，十年前的問題，十年後仍然存在。神奇的是，十年前的方案仍然管用。