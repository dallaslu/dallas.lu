---
title: WordPress 下载计数插件
date: '2008-12-04 16:05'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - Download
        - WordPress
        - Plugin
        - Hanz
        - Translation

---
一款为你的 WordPress 的附件下载进行计数的插件。下面是介绍、使用方法和中文包。

===

## 插件功能

*   随时了解某一附件的下载次数
*   随时掌握最后下载时间
*   可以重置计数器
*   可以对内部和外部的网址使用计数器
*   可以自定义的地址（如/downloads/ file.zip ）
*   可以在文章中显示下载次数、文件大小、最后更改时间。

## 安装插件

下载压缩文件，上传到 wp-content/plugins。在 WordPress 的插件页面启动插 件。激活之后，将会在你的数据库建立一个类似 wp_ downloadstats 的表，含有两个选项。停用之后会被删除。别忘记更新永久链接结构，如果你不想这样做，你得停用简洁链接。

## 管理

激活之后可以到 工具->Downloads 菜单下进行管理。别忘记填写名称，因为这个名称将被用于创建网址。接下来填写目标网址，点击保存。概览窗口，您可以重置计数器下载，编辑下载文件（这将不会重设计数器）和删除下载。当然，在删除时，只有指向该文件的链接会被删除，该文件在目标网址不会被删除。

## 使用

你可能想在日志或者页面中添加这个文件的下载次数等信息。

* 使用 `[ download(downloadname) ]` (没有空格)， 将会被替换以下载地址
* 使用`[ downloadcounter(downloadname) ]` 将被替换以下载次数；
* 使用`[ downloadsize(downloadname) ]` 将会显示文件大小，以 GB、 MB、 kB 、 B 为单位
* ` [ downloadupdated(downloadname) ]` 将会显示最后更新时间，以 WordPress 设置的时间格式为准
* 创建好链接之后，你可以，比方说 使用 `<a href="[ download(file.zip) ]">下载</a>`(再次提醒，替换掉 \[\]里面的空格)
* 当使用了最后更新的大小，你可以制定额外的选项。使用了文件大小, 你可以添加 false 来避免使用 GB、MB、 kB 或者 B 。所以，举例来讲，使用 `[ downloadsize(file.zip, false) ]` 将只显示字节数。
* 使用了最后更新时间，你可以用 PHP 来控制时间格式。例如，`[ downloadupdated(file.zip, d-m-Y) ]` 将会显示 27-11-2008。

#### 调用

可以直接在你的模板或在你自己的插件使用此信息。这里有个重要的函数：

```php
download_information($download_name, $return_information = DOWNLOAD_URL | DOWNLOAD_AMOUNT)
```

这个函数会返回一个满足要求的数组，你可以通过 `$return_information` 控制返回信息。在 `downloadcounter-options.php` 文件中包含了可用的值，当前仅有 URL、Amount,、Size 和 Last Modified Date 是可用的。

使用代码：

```php
$info = download_information(wp-downloadcounter.zip, DOWNLOAD_URL | DOWNLOAD_AMOUNT | DOWNLOAD_SIZE | DOWNLOAD_LASTMODIFIED | DOWNLOAD_LASTDOWNLOAD);
var_dump($info);
```

将返回：

```php
array(4) {
	["url"]=>string(73) "http://projects.bovendeur.org/downloads/wp-downloadcounter.zip"
	["amount"]=>string(4) "1887"
	["size"]=>int(13058)
	["lastmodified"]=>int(1228340791)
}
```

## 相关信息与链接

作者：Erwin Bovendeur

翻译：本银

官方目录：<a href="http://wordpress.org/extend/plugins/wp-downloadcounter/" target="_blank">http://wordpress.org/extend/plugins/wp-downloadcounter/</a>

插件主页：<a href="http://projects.bovendeur.org/2007/07/06/download-counter/" target="_blank">http://projects.bovendeur.org/2007/07/06/download-counter/</a>

## 插件及中文下载

* [来自官方插件目录](http://downloads.wordpress.org/plugin/wp-downloadcounter.0.8.zip)
* [包含中文汉化版本](wp-downloadcounter.zip)

## 废话

支持 WordPress 2.7 。

累死我了。
