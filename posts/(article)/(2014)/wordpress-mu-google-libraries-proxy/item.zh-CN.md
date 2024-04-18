---
title: WordPress 多站点的 Google 公共库反代
date: '2014-11-23 10:53'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - GFW
        - Google
        - jQuery
        - Nginx
        - PHP
        - WordPress
        - Plugin

---
听说最近召开了某互联网大会，想来是形势一片大好。值此良机，记录一下解决万恶的Google 提供的反动公共库文件拖慢整站的问题。如果你的 WordPress 上只跑着一个站点，插件 <a href="https://wordpress.org/plugins/useso-take-over-google/" target="_blank">Useso take over Google</a> 已经提供了完美的解决方案。但是，如果想要在 WordPress 多站点中，把库文件放在每个站点的目录下呢？

===

## Nginx 反代

公共库文件不是随时更新的内容，所以很适合用缓存进一步提速。注意，缓存功能需要 nginx cache_purge 模块。

### 设定缓存文件

编辑 nginx.conf，增加：
https://gist.github.com/dallaslu/70894e5bfb18d427b9a9

### 指定 ajax 目录反代

创建 conf.d/proxy-ajax-googleapis.conf，内容如下：
https://gist.github.com/dallaslu/4777fb6c327e8ea202d2

### 对站点启用

修改 WordPress 站点的 nginx 配置文件，增加：

```nginx
include conf.d/proxy-ajax-googleapis.conf;
```

### 加载反代配置

在终端中执行：

```sh
service nginx reload
```

## WordPress 引用地址

### 替换脚本引用地址

把插件 Useso take over Google 下载下来，修改 php 文件中的 function useso_take_over_google_str_handler 为：
https://gist.github.com/dallaslu/6fb3831e30fa09b3d6d0

### 使插件生效

将插件的文件夹名字改为 do-not-use-google-libraries，上传到 `wp-content/plugins`，进入管理网络的插件菜单下，选择在全部站点中启用。

你猜怎么着？好使了呗！
