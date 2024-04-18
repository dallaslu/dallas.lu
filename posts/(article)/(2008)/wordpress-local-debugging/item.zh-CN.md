---
title: 本地调试 WordPress
date: '2008-12-11 23:33'
author: 'dallaslu'

taxonomy:
    category:
        - Ubuntu
        - WordPress
    tag:
        - PHP
        - Windows
        - WordPress

---
因为前几次改主题的时候把一些判断写死了。所以之后的更改基本都是在线完成。要崩溃了，所以决定还是把写死的判断改回来，在本地调试。下面给出我使用的本地搭建 WordPress 环境的方法。

===

## Ubuntu Linux 系统

当然咯，最方便的是使用源里的。

```bash
sudo apt-get install wordpress
```

现在我的源里默认的是 WordPress 2.5.1 。我曾经尝试过的，安装完之后莫名其妙，WordPress 不知道被安装到哪里去了，倒是 php 、apache2 等依赖程序安装了。所以最好还是一步一步来吧。

### 安装 Apache2+PHP5+MySQL

```bash
sudo apt-get install apache2 libapache2-mod-security libapache2-mod-php5 php5 php5-gd mysql-server php5-mysql phpmyadmin
```

其中 libapache2-mod-security 可以不装，还可以选装 mysql-admin 。

### 配置php.ini

```bash
sudo gedit /etc/php5/apache2/php.ini
```

如果有下面这句，前面有分号的话去掉分号；没有则自己加上这句。

```ini
extension=mysql.so
```

### GD库的安装

```bash
sudo apt-get install php5-gd
```

记得装完重启apache

```bash
sudo /etc/init.d/apache2 restart
```

### 启用 mod\_rewrite 模块

```bash
sudo a2enmod rewrite
```

### phpMyAdmin

默认并不是安装在 `/var/www` 下面的而是在 `/usr/share/phpmyadmin`，你可以把 phpmyadmin 复制过去，或者创建一个链接，然后把链接复制过去。然后在浏览器里打开 <a href="http://localhost/phpmyadmin" target="_blank">http://localhost/phpmyadmin</a> ，选择权限->添加用户，当然这个不是最重要的，而是建立新数据库。

### 安装 WordPress

可以去<a href="http://wordpress.org/download/" target="_blank">官方网站下载</a> ，或者下载 <a href="http://code.google.com/p/wpcn/downloads/list" target="_blank">中文版</a> 。解压之，放在网站根目录里面。注意一下文件夹权限，不可写的话会有问题的。然后访问你的 WordPress 输入数据库、用户名就可以了。

如果你发现自定义永久链接不能生效的话，编辑`/etc/apache2/sites-available/default` 这个站点缺省配置文件。找到`AllowOverRide None`，更改为`AllowOverRide All`，记住有多个地方要改。`sudo /etc/init.d/apache2 restart` 重启apache，也可以用 `sudo /etc/init.d/apache2 fore-reload` 强制重载配置文件。

## Windows系统

推荐使用 PHPnow 。你可以访问 <a href="http://phpnow.org" target="_blank">官方网站</a> ，如果不能访问下载链接，请自行搜索。

如果系统有同类软件件，请先停止或卸载，否则会占默认端口！请关闭迅雷，会占端口！

解压：解压到任意目录；（不能含有中文！例如 "桌面"）

安装：运行 Init.cmd 进行初始化；使用：.htdocs 为网站主目录。执行 PnCp.cmd 进行设置或管理。

注意：卸载前必须执行 `Stop.cmd`！

使用 `PnCp.cmd` 进行设置和管理。

把 WordPress 的文件夹复制到 htdocs 目录里，然后参考 Ubuntu 里面的方法即可。
