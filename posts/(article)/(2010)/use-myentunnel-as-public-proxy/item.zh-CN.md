---
title: 分享你的 MyEntunnel
date: '2010-03-07 15:00'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:

---
MyEntunnel 只能给本机提供服务。这个就不太爽快了，难不成每台电脑都弄个 SSH 吗？google 了一下，才知道实际上它只是 plink.exe 的图形界面而已。于是乎又开始琢磨 plink.exe。

===

只要将转发端口设置为 0.0.0.0:7070，其他电脑就可以搭上云梯了。还是 MyEntunnel 的自动重连比较好用，无奈端口号的设置选项，只支持填写纯数字，并不能包含“.”和“:”。

其中过程不用再提。请编辑 myentunnel.ini ，将 SOCKSPort 设置为 0.0.0.0:7070 即可。重新启动 MyEntunnel，可以看到消息：
>  plink.exe: Local port 0.0.0.0:7070 SOCKS dynamic forwarding
另，换了域名了。麻烦的 feed 问题，目前两个域名应该都有效。[新地址](http://feed.dallas.lu)。
