---
title: FeedBurner 与站点 SSL
date: '2009-06-01 23:16'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - FeedBurner
        - Nginx
        - WordPress

---

我在 StartSSL 申请了免费证书，为全站强制启用了加密链接，所有 http 方式的访问都会跳转到 https 链接。国内的 FeedSky 十分不给力，于是重新切换到了 FeedBurner。在 FeedBurner 抓取 feed 时却发生了 400 错误。解决方案很简单，就是禁止自动跳转。那么如何在全站都跳转到安全链接的情况下，保证 feed 地址提供 http 的访问呢？

===

我启用了 WordPress 的多站点模式，并为 80 和 443 端口分别配置了虚拟主机。于是我想到了配置多个虚拟主机，但这有可能为日后的维护造成麻烦，并非最好的办法。经过一番尝试，发现只要在 Nginx 配置文件中，在 80 端口的主机中进行判断，来有条件跳转即可：

```nginx
set $dallaslu_rewrite_to_ssl 0;
if ($host ~ ^(www\.)?dallas\.lu) {
	set $dallaslu_rewrite_to_ssl 1;
}
if ( $http_user_agent ~ FeedBurner ){
	set $dallaslu_rewrite_to_ssl 0;
}
if ($dallaslu_rewrite_to_ssl = 1){
	rewrite ^(.*) https://dallas.lu$1 permanent;
}
```

思路很简单，以一个变量控制是否跳转，如果浏览器标识是 FeedBurner，则不进行跳转。
