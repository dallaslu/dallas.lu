---
title: 换域名后 WordPress 重定向
date: '2008-12-03 21:33'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - Skill

---
这个重定向问题纠结了好久。我在原来的站点基础上<a href="https://dallas.lu/domain-has-been-changed/">绑定了新米</a> dallas.lu，想以此域名为主，因此需要将原域名下的所有链接都平滑的重定向到新域名。

===

## 情况、方法

WordPress 根目录下的 `.htaccess` 默认内容如下：

```apacheconf
# BEGIN WordPress
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.php [L]
</IfModule>
# END WordPress
```

一般来说，只需要把下面两句加上即可：

```apacheconf
RewriteCond %{HTTP_HOST} ^old.cn [NC]
RewriteRule ^(.*) https://dallas.lu/$1 [L, R=301]
```

第一行的意思是判断下当前请求域名是否为 old.cn ，也可写为 `!^dallas.lu`（意即“不是 dallas.lu”，适合有多个域名时用这句判断），NC 是不分大小写的意思——如果不加这行判断会陷入循环重定向；第二行是从当前请求 URL 中取出 old.cn 后面那段加在 dallas.lu 上，`L` 意思是循环结束，`R＝301` 代表 301 永久重定向。我理解没错误吧，毕竟是换过域名的人，*$#%&@#$。

## 困惑、转机

但是，问题在于，修改 `.htaccess` 之后，old.cn 上面所有的页面都被跳转到 dallas.lu 的首页上了。无奈差点把 `.htaccess` 的各种用途都了解个遍的时候，看到 FDS‘s Blog (个人觉得应该是 FDS' Blog ，S‘s 看着别扭- -|)<a href="http://blog.1xi.net/seo/wordpress-301" target="_blank" title="域名，WordPress的301重定向简单方法">提到</a>说，把上面两句写在了 WordPress 默认那几句里面。我是放在 `# END WordPress` 后面的，汗。最后修改如下：

```apacheconf
# BEGIN WordPress
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTP_HOST} ^old.cn [NC]
    RewriteRule ^(.*) https://dallas.lu/$1 [L, R=301]
    RewriteBase /
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.php [L]
</IfModule>
# END WordPress
```

之后解决。不过写在这里可能会出现被 WordPress 修改回来的情况，建议写成：

```apacheconf
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTP_HOST} ^old.cn [NC]
    RewriteRule ^(.*) https://dallas.lu/$1 [L, R=301]
</IfModule>
# BEGIN WordPress
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.php [L]
</IfModule>
# END WordPress
```

## 鸣谢

感谢下萝卜，虽然一直误以为我要设置错误页面。我倒是想来着，可是<a href="https://dallas.lu/what-fucking-is-zbea-com/" title="zbea.com 是个啥东西">404被劫持</a>了。

貌似最近看见好几个博客换米了，比方说 <a href="http://www.xiaorsz.com/2008/11/change-new-domain/" target="_blank" title=".cn 换到 .com">Xiaorsz</a> 、<a href="http://ooxx.me/ooxxme.orz" target="_blank" title="YD的域名">大猫</a>……
