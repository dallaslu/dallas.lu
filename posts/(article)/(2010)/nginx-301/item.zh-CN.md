---
title: Nginx 换域名重定向
date: '2010-12-08 11:30'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Nginx

---
更换了域名应该将旧域名 301 重定向到新域名，在Apache中可以使用 .htaccess 文件来实现。具体可参考[使用 htaccess 将旧域名 301 重定向到新域名](http://fairyfish.net/2007/07/02/301-redirect/ "使用 htaccess 将旧域名 301 重定向到新域名")。那么 Nginx 中该如何做呢？

===

比如网站的旧域名是 baidu.com ，新域名是 google.com 。现在google.com 已经上线。那么，添加如下代码至baidu.com所在服务器的 /usr/local/nginx/conf/nginx.conf 文件末尾的 "}" 之前：

```nginx
server
	{
		listen       80;
		server_name baidu.com;
		rewrite ^/(.*)$ http://google.com/$1 permanent;
		access_log off;
	}
```

重新加载或启动 Nginx 即可。这样，当访问 http://baidu.com/adsense就会跳转到 http://google.com/adsense了。话说 lnmp 还真是爽，有了 <http://lnmp.org> 什么都不懂一样可以维护和管理。
