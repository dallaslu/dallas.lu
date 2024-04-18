---
title: 从缓存中保存 Flv 视频到本地
date: '2011-06-07 18:20'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Chrome
        - Firefox
        - IE
        - Twitter

---
有个MM，很喜欢 [@Stefsunyanzi](https://twitter.com/Stefsunyanzi)。由于 Twitter 是不能直接访问到的，于是我介绍给她一些第三方的服务。Stef Sun 偶尔发图片到 [TwitPic ](http://twitpic.com)上，这个比较好办，我截图就是了。今天 Stef Sun 又[发了个视频](https://twitter.com/Stefsunyanzi/status/11870953199)出来。

===

保存在线视频，我向来喜欢从缓存入手。

## FireFox

在 Linux 下比较简单，缓存文件夹在 /tmp 目录下。

Windows 中，在地址栏中输入 about:cache，就可以看到缓存的路径了。路径类似这样：

C:\Documents and Settings\Administrator\Local Settings\Application Data\Mozilla\Firefox\Profiles\<span style="text-decoration: line-through;">abcdefg</span>.default\Cache

![](https://dallas.lu/files/2011/06/firefox-cache.png)

## IE

从IE菜单栏开始，工具->Internet 选项->设置->查看文件；路径一般都是：

C:\Documents and Settings\Administrator\Local Settings\Temporary Internet Files

![](https://dallas.lu/files/2011/06/ie-cache.png)

## Chrome

Windows 中据说是类似这样的路径（把YourLogin 换成你的登录名就好了）：

C:\Documents and Settings\<span style="text-decoration: line-through;">YourLogin</span>\Local Settings\Application Data\Google\Chrome\User Data\Default\Cache

用 Linux 的，或者稍后发现找不到视频的，到[这里](http://forum.ubuntu.org.cn/viewtopic.php?t=243023)来看看。还有其他的浏览器，我就不知道了。

## 找视频

我们在浏览器中观看视频，等视频全部下载完毕之后，就可以来翻看你所使用的浏览器的缓存目录了。把目录中的文件按最后修改时间排一下，看下最近几分钟的文件，大小在1MB以上的（大小取决于视频长短与质量），基本上就是了。

在 Firefox 和 Chrome 中，缓存文件的名字是不分类型的，这个时候就看自己的感觉和人品了。IE 中，多数情况下可以看到后缀名为 .flv 的文件。

复制到其他目录，视频文件算保存完了。顺便赞下QQ的向好友传送离线文件。
