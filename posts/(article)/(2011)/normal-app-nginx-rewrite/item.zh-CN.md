---
title: 常见程序 nginx 伪静态规则
date: '2011-05-29 17:22'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Nginx
        - Typecho
        - WordPress
        - XNote

---
自从买了[VPS](http://billing.vpsyou.com/aff.php?aff=139)，就经常痒痒着装上各种程序来体验。虽然lnmp一键安装包附带了几个伪静态规则，仍免不了自己写一些nginx的伪静态规则。

===

## Wordpress

```nginx
location / {
	if (-f $request_filename/index.html){
		rewrite (.*) $1/index.html break;
	}
	if (-f $request_filename/index.php){
		rewrite (.*) $1/index.php;
	}
	if (!-f $request_filename){
		rewrite (.*) /index.php;
	}
}
```

## WordPress Mu

```nginx
location /{
  server_name_in_redirect off;
  port_in_redirect off;
  
  rewrite ^.*/files/(.*) /wp-includes/ms-files.php?file=$1;
  rewrite ^/files/(.+) /wp-includes/ms-files.php?file=$1;
  
  if (!-e $request_filename) {
	rewrite ^.+?(/wp-.*) $1 last;
	rewrite ^.+?(/.*\.php)$ $1 last;
	rewrite ^ /index.php last;
  }
}
```

## Drupal

```nginx
location / {
	if (!-e $request_filename) {
		rewrite ^/(.*)$ /index.php?q=$1 last;
	}
}
```

## Twip

```nginx
location /{
	if (!-e $request_filename){
		rewrite ^/(.*)$ /index.php last;
	}
}
```

## Typecho

```nginx
location / {
	index index.html index.php;
	if (-f $request_filename/index.html){
		rewrite (.*) $1/index.html break;
	}
	if (-f $request_filename/index.php){
		rewrite (.*) $1/index.php;
	}
	if (!-f $request_filename){
		rewrite (.*) /index.php;
	}
}
```

## Discuz

```nginx
location / {
	rewrite ^/archiver/((fid|tid)-[\w\-]+\.html)$ /archiver/index.php?$1 last;
	rewrite ^/forum-([0-9]+)-([0-9]+)\.html$ /forumdisplay.php?fid=$1&page=$2 last;
	rewrite ^/thread-([0-9]+)-([0-9]+)-([0-9]+)\.html$ /viewthread.php?tid=$1&extra=page%3D$3&page=$2 last;
	rewrite ^/space-(username|uid)-(.+)\.html$ /space.php?$1=$2 last;
	rewrite ^/tag-(.+)\.html$ /tag.php?name=$1 last;
}
```

## Discuz X

```nginx
location / {
	rewrite ^([^\.]*)/topic-(.+)\.html$ $1/portal.php?mod=topic&topic=$2 last;
	rewrite ^([^\.]*)/article-([0-9]+)-([0-9]+)\.html$ $1/portal.php?mod=view&aid=$2&page=$3 last;
	rewrite ^([^\.]*)/forum-(\w+)-([0-9]+)\.html$ $1/forum.php?mod=forumdisplay&fid=$2&page=$3 last;
	rewrite ^([^\.]*)/thread-([0-9]+)-([0-9]+)-([0-9]+)\.html$ $1/forum.php?mod=viewthread&tid=$2&extra=page%3D$4&page=$3 last;
	rewrite ^([^\.]*)/group-([0-9]+)-([0-9]+)\.html$ $1/forum.php?mod=group&fid=$2&page=$3 last;
	rewrite ^([^\.]*)/space-(username|uid)-(.+)\.html$ $1/home.php?mod=space&$2=$3 last;
	rewrite ^([^\.]*)/([a-z]+)-(.+)\.html$ $1/$2.php?rewrite=$3 last;
	if (!-e $request_filename) {
		return 404;
	}
}
```

## Dabr

```nginx
location / {
	if (!-e $request_filename) {
		rewrite ^/(.*)$ /index.php?q=$1 last;
	}
}
```

## SaBlog

```nginx
location / {
	rewrite “^/date/([0-9]{6})/?([0-9]+)?/?$” /index.php?action=article&setdate=$1&page=$2 last;
	rewrite ^/page/([0-9]+)?/?$ /index.php?action=article&page=$1 last;
	rewrite ^/category/([0-9]+)/?([0-9]+)?/?$ /index.php?action=article&cid=$1&page=$2 last;
	rewrite ^/category/([^/]+)/?([0-9]+)?/?$ /index.php?action=article&curl=$1&page=$2 last;
	rewrite ^/(archives|search|article|links)/?$ /index.php?action=$1 last;
	rewrite ^/(comments|tagslist|trackbacks|article)/?([0-9]+)?/?$ /index.php?action=$1&page=$2 last;
	rewrite ^/tag/([^/]+)/?([0-9]+)?/?$ /index.php?action=article&item=$1&page=$2 last;
	rewrite ^/archives/([0-9]+)/?([0-9]+)?/?$ /index.php?action=show&id=$1&page=$2 last;
	rewrite ^/rss/([^/]+)/?$ /rss.php?url=$1 last;
	rewrite ^/user/([^/]+)/?([0-9]+)?/?$ /index.php?action=article&user=$1&page=$2 last;
	rewrite sitemap.xml sitemap.php last;
	rewrite ^(.*)/([0-9a-zA-Z\-\_]+)/?([0-9]+)?/?$ $1/index.php?action=show&alias=$2&page=$3 last;
        }
```

## Xnote

```nginx
location / {
	if (!-e $request_filename) {
		rewrite "^/([A-Za-z0-9\-]{4,20})$" /index.php?url=$1 last;
	}
}
```

## Status.net

```nginx
location / {
	if (-f $request_filename/index.html){
		rewrite (.*) $1/index.html break;
	}
	if (-f $request_filename/index.php){
		rewrite (.*) $1/index.php;
	}
	if (!-f $request_filename){
		rewrite (.*) /index.php;
	}
}
```

打包下载：[nginx-rewrite.zip](nginx-rewrite.zip)
