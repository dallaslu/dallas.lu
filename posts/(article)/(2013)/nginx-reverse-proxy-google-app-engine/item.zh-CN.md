---
title: Nginx 反向代理 Google App Engine
date: '2013-01-11 22:13'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Google
        - Google-app-engine
        - Nginx

---
*.appspot.com 经常被 GFW 重置链接也就算了，Google 也已经停止了免费版的 Google Apps 的申请。这就导致跑在 Google App Engine 上的应用不能绑定自定义域名，也就无法通过更改解析到可用 IP 的方式，使其在中国大陆可被访问了。尽管如此，还有一个反向代理的办法，就像 Sina App Engine 绑定域名的原理一样，可以做到用自己的域名来访问 Google App Engine 上的应用。

===

在此贴出网站 invite.im 的 Nginx 配置文件。

```nginx
server
	{
		listen       106.187.35.37:80;
		server_name invite.im *.invite.im;
		index index.html;
		root  /home/wwwroot/invite.im;

		if ($host ~ ".+\.invite\.im") {
			rewrite ^/(.*)$ http://invite.im/$1 permanent;
		}

		location / {
			proxy_pass https://invitation-card.appspot.com/;
			proxy_redirect off;
			proxy_set_header X-Real-IP $remote_addr;
			proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		}

		location ~ .*\.(php|php5)?$
			{
				fastcgi_pass   127.0.0.1:9000;
				fastcgi_index  index.php;
				include        fastcgi_params;
			}

		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
			{
				expires      30d;
			}

		location ~ .*\.(js|css)?$
			{
				expires      12h;
			}

		access_log off;
	}
```

[invite.im](http://invite.im) 是一个正在开发的网站，你可以在这里交换邀请码，发现新的应用。:)

这个反向代理实际跑在 Linode 日本节点上，它会就近找到 IP，将请求转发到 appspot 上的应用。还有一点要注意，虽然转发的代码没有做什么判断处理，但有可能发生静态文件不能访问的问题，所以请在转发服务器所配置的虚拟主机根目录中部署一份静态文件的拷贝。
