---
title: 玩转Pidgin
date: '2009-03-01 23:02'
author: 'dallaslu'

taxonomy:
    category:
        - Ubuntu
    tag:
        - Pidgin
        - IM

---
Ubuntu 自带的 Pidgin ，支持多款聊天协议。你可以它同时登录你的 Gtalk/MSN/QQ/ICQ/校内/飞信 等等账号，可以对不同 IM 中的好友进行统一管理。安装好了Ubuntu 之后，可以在 应用程序&gt;互联网&gt; 中找到它。

===

初次启动会提示你添加账号。我们可以从__协议__列表中看到 Pidgin 支持的协议还真是不少。

<img alt="addaccount" class="alignnone wp-image-648" src="https://file.dallaslu.com/2009/03/addaccount.png"/>

使用起来及其简单吧，选择协议之后填上密码就OK了。值得一提的是，通过安装插件，就还可以登录更多类型的协议。

## 更多的协议

<h3 style="padding-left: 30px;">用 Pidgin 登录飞信</h3>

<p style="padding-left: 30px;">前往<a href="http://forum.ubuntu.org.cn/viewtopic.php?t=100260" target="_blank">Ubuntu 中文论坛</a> 下载相应的文件。例如，在下载到的 fetion_v0.98-4.X86-32.tar.gz 上<strong>右键&gt;解压到此处</strong>得到 libfetion.so；执行 <strong>应用程序&gt;附件&gt;终端</strong>，执行命令 <code>sudo gnome-open ~/.purple/plugins/</code> ，输入密码；将 libfetion.so 复制到打开的文件夹中。然后打开 <strong>Pidgin&gt;账户&gt;管理账户&gt;添加</strong> ，就可以看到 fetion 协议了吧。（服务器填写：221.130.44.193）</p>

<h3 style="padding-left: 30px;">用 Pidgin 登录Facebook</h3>

<p style="padding-left: 30px;">前往 <a href="http://code.google.com/p/pidgin-facebookchat/" target="_blank">该插件项目主页</a> 下载 .deb 格式的软件包，下载之后直接双击运行，再单击一下 <strong>安装软件包</strong> 稍等即可。然后重启一下 Pidgin 即可看到 Facebook 协议。</p>

<h3 style="padding-left: 30px;">用 Pidgin 登录校内通</h3>

<p style="padding-left: 30px;">话说，发现很多人不登录QQ却要登录校内，校内也网页底部集成了聊天。这次不用安装插件了，添加新账户，协议选择为 XMPP（实际上 Gtalk 也使用该协议）。用户名填写校内 ID，即登录校内后地址栏  home.do?id= 后面的那一坨数字；域名填写为 www.xiaonei.com ；切换到<strong>高级</strong>选项卡，<strong>连接服务器</strong>填写为 talk.xiaonei.com ，OK。</p>

<h3 style="padding-left: 30px;">用Pidgin 登录 Skype</h3>

<p style="padding-left: 30px;">这个麻烦了一些，而且，使用该协议的同时需要开着 Skype……安装 Skype 先，<a href="http://skype.tom.com/download/linux.html" target="_blank">下载 Deb 包 </a> （选择 Debian Etch 类型）。再前往<a href="http://eion.robbmob.com/" target="_blank">插件主页</a>，有 .deb 安装包 和 .so 文件下载，这次不必细说了，选择其一下载。具体可参考 <a href="http://www-user.tu-chemnitz.de/~tali/2007/11/30/skype-plugin-for-pidgin/" target="_blank">Liang Tao 的介绍</a>。</p>

## 强大的功能

Pidgin 是一款很有效率的 IM 软件，列举两个功能，更多自己请自己发掘～

<h3 style="padding-left: 30px;">好友千里眼</h3>

<p style="padding-left: 30px;">QQ中里面有这个功能的吧，收费服务。现在免费无限制使用了，嘎嘎。在任意好友图标上<strong>右键&gt;添加好友千里眼</strong>，哗，很强大吧。在 <strong>工具&gt;好友千里眼 </strong>中可以进行统一管理。</p>

<h3 style="padding-left: 30px;">合并联系人</h3>

<p style="padding-left: 30px;">我们可能添加了某人的 Gtalk 和 MSN ，那么，在好友图标上 <strong>右键&gt;展开</strong> ，看到什么？然后我们另拖一个联系人过去。</p>

<p style="padding-left: 30px;"><img alt="friends" class="alignnone wp-image-650" src="https://file.dallaslu.com/2009/03/friends.png"/></p>

<p style="padding-left: 30px;">这样，我们就不必去关心具体的协议，从而能够更直观地管理好友了。</p>

## 实用的插件

在__工具&gt;插件__中可以看到预装的插件，喜欢折腾的同学自己折腾吧。

<h3 style="padding-left: 30px;">短信通知插件 gSMS</h3>

<p style="padding-left: 30px;">离线消息各大 IM 都有，短信通知就没了吧？用这款插件，当你离开电脑时，别人的消息就会直接发到你的手机上。感谢 Google 吧。关于<a href="http://linuxtoy.org/archives/gsms-plugin-for-pidgin.html" target="_blank">使用介绍</a>，不过，插件主页貌似挂了，可以暂时用一年前的对付一下，<a href="https://dallas.lu/file/2009/03/gsms.so" target="_blank">下载</a>。</p>

<h3 style="padding-left: 30px;">Twitter</h3>

<p style="padding-left: 30px;"><span style="text-decoration: line-through;">眼睛一亮是吧，不过，作为 Twitter 的客户端我们有更多的选择，这里只是提一下。插件主页。</span> 主页也挂了？请参考《<a href="https://dallas.lu/be-a-twitter-on-pidgin/">Pidgin 上玩 Twitter</a>》</p>

有点意犹未尽的感觉吧，这里有一篇 Windows 用户写的经验：<a href="http://www.lirui.name/post/95.html" target="_blank">让 Pidgin 如虎添翼的十大插件</a>。

如果你读到这里，我不得不承认你很有折腾精神。看看官方的<a href="http://developer.pidgin.im/wiki/ThirdPartyPlugins" target="_blank">插件目录</a>吧。

另，Pidgin 还支持其他系统，所以即使你没有安装 Ubuntu ，依然能在 Windows 下体验。Pidgin 不像 QQ 这么普遍，装机必备，所以你可以来个移动版的，放在U盘里，数据、程序随身携带。

<div class="download">
<a href="http://pidgin.im/download/" target="_blank">下载Pidgin</a>
<a href="http://portableapps.com/apps/internet/pidgin_portable" target="_blank">下载便携版Pidgin</a>
</div>

好吧，就到这里吧。
