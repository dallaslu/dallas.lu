---
title: WordPress 与 Nginx
date: '2013-01-08 20:05'
author: 'dallaslu'
published: false

taxonomy:
    category:
        - WordPress
    tag:
        - Nginx

---
在使用 Linode VPS 以前，就已经使用 Nginx 来跑 WordPress 了；后来又使用了 WordPress 的多站点功能，也都在 Nginx 下运行得很好。这个过程中也遇到了一些问题，在此一一列举并附上解决方案。

## 去除固定链接中的 index.php

即使你在  Nginx 为 WordPress 配置了 rewrite 规则，在修改 WordPress 固定链接的设置时，默认的选项中依然会有 index.php。原因是 WordPress 在检查 mod_rewrite 模块时返回了 false。

在你已经为  WordPress 在 Nginx 中配置好了重写规则的情况下，
