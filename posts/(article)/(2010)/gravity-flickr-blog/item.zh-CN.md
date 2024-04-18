---
title: Gravity 传图至 Flickr 与博客引用
date: '2010-09-09 09:52'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Flickr
        - Gravity

---
Twitter的优秀客户端Gravity所支持的几个图片服务都已经被GFW，只有Flickr还可以使用了。Flickr 目前可以访问，但是唯独图片不能显示。之前有想过搭建图床，以邀请制供推友发图。却因为没有合适的开源程序而作罢。

===

用Gravity将手机拍的照片传至Flickr的确是个不错的主意。嘀咕网的手机拍照上传的意义也是记录生活分享点滴，何况还有Flickr强大的照片管理功能。我目前发现的唯一问题是，Gravity上传的图片Exif信息会丢失。

## Gravity 上传至 Flickr

先访问 <http://mobileways.de/flickr> ，在Flickr中授权给Gravity，并获得 Flickr Code。 在 Gravity 的图片功能中，Options->Setting，输入 Flickr Code 即可。

选一张照片，在下拉的选项中单击 flickr ，很快就上传完毕了。如果嫌图片质量不高，可以在 Setting 中调整。

## 博客引用 Flickr 图片

相信一定有 WordPress 的 Flickr 管理软件，配合一些将外部图片下载到本地的插件，就可以做到墙内用户无障碍浏览。但我没发现在 typecho 中的相关的插件。所以索性弄了个简单的办法，适用于服务器在国外的同学们。

保存以下内容为 index.php：

```php
<?php

define('STATIC_URL','http://farm5.static.flickr.com/');
define('REAL_URL','http://photo.dallas.lu/'); //编辑此处改为你的空间域名

if ( curl_download( STATIC_URL.$_GET['file'],$_GET['file'] ) ){
	header("Location: ".REAL_URL.$_GET['file']);
	exit;
}else{
	header("HTTP/1.0 404 Not Found");
	exit;
}

function curl_download($remote, $local) {
	$cp = curl_init($remote);
	$fp = create_file($local, "w");

	curl_setopt($cp, CURLOPT_FILE, $fp);
	curl_setopt($cp, CURLOPT_HEADER, 0);
	curl_setopt($cp, CURLOPT_FOLLOWLOCATION,1);

	curl_exec($cp);

	$httpinfo= curl_getinfo($cp);

	if ( $error = curl_error($cp)
		||$httpinfo['http_code'] != 200 ){
		curl_close($cp);
		fclose($fp);
		@unlink ($local);
		return false;
	}else{
		curl_close($cp);
		fclose($fp);
		return true;
	}
}

function create_file( $file_name,$w){
	$dir_name=dirname($file_name);
	if(!file_exists($dir_name)){
		mkdir($dir_name);
	}
	if (file_exists($file_name)){
		@unlink ($file_name);
	}
	return fopen($file_name, $w);
}
```

然后加入URL重写规则到 .htaccess 文件：

```htaccess
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
```

嗯，然后把这个index.php 和 .htaccess 发布到你的php空间中即可。在flickr中获取图片外链地址时，将 farm*.static.flickr.com 替换成你的域名就行啦。
