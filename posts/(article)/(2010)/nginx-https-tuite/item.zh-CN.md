---
title: Nginx 下搭建 HTTPS 推特中文圈
date: '2010-09-01 11:12'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Nginx
        - Twitter

---
众所周知，今天开始 Twitter 停止了 Basic 的登陆方式。以往基于basic第三方应用可能都没法用了，而支持 oauth 的程序又需要翻墙验证。好在有推特中文圈之类的支持代理 oauth 的程序。

===

## 安装

安装起来也非常的简单，到<a href="http://code.google.com/p/tuite/" target="_blank">项目主页</a>下载程序，解压之后传至 php 空间即可。当然，配一张 SSL 证书来提供 https 安全访问是再好不过了，[StartSSL ](https://startssl.com)的证书申请方便，完全免费，特别推荐。

## 跳转链接问题

重点在于使用VPS的同学很多人都用的是 nginx。在nginx 配置好证书之后，访问路径是 https://tuite.com，通过代理 oauth 方式登陆时，地址栏链接却会跳转到 http://tuite.com:443。问过 @[bang590](https://twitter.com/bang590) ，貌似这个问题只有我遇到。莫非是 nginx 下独有的问题？

## 临时解决方案

本着不作深入研究、只为解决问题的方针，翻了一下代码。修改 lib/twitese.php 364行左右 testReferer 函数：

```php
function testReferer() {
	$scheme = 'https';
	$port = '';
	$HOST = $scheme . '://' . $_SERVER['HTTP_HOST'] . $port;
	return strpos($_SERVER['HTTP_REFERER'],$HOST) === 0 ? true : false;
}
```

修改oauth_proxy.php 56 行左右为：

```php
	$scheme = 'https';
	$port = '';
```

搞定，收工。另，我在 Nginx 装 WordPress 也有这样那样的问题，可有详细教程推荐？
