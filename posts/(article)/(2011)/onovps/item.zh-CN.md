---
title: 超高性价比的欧诺VPS
date: '2011-11-23 21:57'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Vps
review:
  item:
     type: WebApplication
     name: 欧诺VPS
  rating: 8
---
实际上，这个博客以及其他的一时心血来潮的站点，都处于高成本运营状态。本着折腾精神，一路从低价虚拟主机入门，然后购买共享主机、低价VPS，至今竟然也用过几家的VPS了。现在正在用的[欧诺VPS](http://www.onovps.com/)也有3个来月了，目前还说，还是可以推荐一下的。

===

## 配置与价格

我在用的是特惠XEN，1024M内存，30G硬盘，每月800G流量，目前价格每月120元。单从配置上来讲，这个价格绝对的有优势。

## 使用体验

### 编译安装 lnmp

曾在 VPSYOU 的 X360 上编译安装，在中午开始执行脚本，直到下班后一个小时才安装结束；而在欧诺VPS编译时，只用了个把小时，在公司执行，坐车到家竟然就已经编译好了。（抱歉，现在没有确切数据可以提供）

### 访问速度

本博客速度你觉得如何呢？为了发挥VPS的优势，并进一步提高WordPress的访问速度，我又进行了以下优化：

1.   关闭多余 centos 服务，节省内存
2.   使用 nginx 对 html/css/js 文件进行gzip压缩输出
3.   安装 WP Minity 插件，自动合并页面中的 css 和 js 文件，减少 http 请求
4.   安装 WP Super Cache 插件，对页面进行缓存
5.   安装 eAccelerator 组件，加速 PHP 解析

虽然美国主机速度也就如此，但是相信面对未来很长一段时间之内的流量增长（一定会有的）完全绰绰有余了。

### J2EE 服务器

朋友在欧诺的VPS上搭建了Tomcat、MySQL，跑着一套自行开发的SNS系统，完全没有任何问题。

## 美中不足

欧诺提供的VPS君位于美国凤凰城，独立服务器价格较低廉，所以才有如此高性价比的VPS。所以常见的凤凰城抽风问题也是不可避免，在我监控宝账户中，可以看到，我的站点仍然达到了99%的可用率。

![](https://dallas.lu/files/2011/11/goose.jpg)

监控宝并不代表一切，在故障的19小时40分中，有大概12小时是母机维护更换硬盘，有2小时是因本站WEB服务器配置错误，还有3小时是我操作VPS失误意外关机所致，所以VPS本身理论可用率应该已经接近 99.9%。线路问题实属无奈，但这对我影响并不大。

你觉得这个VPS如何呢？是否有更好的推荐？
