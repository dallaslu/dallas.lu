---
title: Nginx 反代 Apache Subversion 添加 HTTPS
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
        - HTTPS
keywords:
    - svn nginx
    - install svn
    - Nginx 反代 SVN
    - Nginx SVN 路径乱码
toc:
  enabled: true
---
Subversion 听上去像是十年前的东西了，尤其是 `mod_dav_svn`。不过祖传代码放在哪里可就不好说了。总之，你已经有了一个现成的 Nginx，希望为已经一个一直裸奔着的代码仓库添加 HTTPS 的支持，但并非一句 `proxy_pass` 就能搞得定。

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

首先，恭喜一下，没有使用 `proxy_pass http://subversion/`，避免了第一个坑。因为结尾的 `/` 字符会使得 Nginx 自动对 URL 进行编码，从而影响正常使用。但马上就会在提交时会遇到 502 错误。

## COPY 和 DELETE 的支持

Subversion 认为 `https://svn.example.com` 是一个 HTTPS 链接，而 Apache 只提供了 HTTP 服务，所以请求头中的 `Destination` 中应该以 `http://` 开头才能正常工作。 

很快，你从 Stackoverfollow 找到了修改的办法：

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

然后发现一切 OK。很好，果然掉进了第二个坑。

## Nginx 的迷惑行为

`$fixed_destination` 看起来只是把 `https://` 替换成了 `http://`，非常简单明了，没有问题。

当你愉快地从主干上复制了一个新分支，修改了一个文件名包含中文的文件，顺利地编译并通过测试；然后再合并回主干时，如果足够细心的话，就会发现这个文件名被 urlencode 了。当然，并不是仅仅包括中文名文件，想象一下，可是分支中的提交的所有文件的名字都被 urlencode 了哦！而且已经被 urlencode 过的文件名，下次合并分支时还会被再 urlencode 一次哦！

问题就在于 `$fixed_destination`。`http$1` 其实就被 Nginx 进行了一次 urlencode。也许你决定把修改 `Destination` 的操作交给 Apache，或者决定写一段 lua 脚本进行解码，来规避这个神奇的问题。且慢！这里还有一个神奇的解决办法：

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

给匹配用的正则组加一个命名就 OK 了……

## 其他

这个解决方案出自 [Maxim Dounin](https://trac.nginx.org/nginx/ticket/348) 九年多以前的回复。所以，**在 Nginx 中使用正则修改变量最好使用命名捕获组**。

十年前的架构，十年前的问题，十年后仍然存在。神奇的是，十年前的方案仍然管用。