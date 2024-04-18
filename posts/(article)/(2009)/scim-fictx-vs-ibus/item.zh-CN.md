---
title: iBus 输入法平台
date: '2009-03-25 19:06'
author: 'dallaslu'

taxonomy:
    category:
        - Ubuntu
    tag:
        - Ibus

---
Ubuntu 中自带的输入法平台是 scim ，但是它经常性地崩溃，并且引诱 FireFox、Pidgin 等重要程序集体停止响应。所以某天实在是无法忍受，尝试了其他输入法，现在正在用的是 ibus 。

===

scim 的关于信息中写的是2004，而且开发 scim 的来自清华的苏哲同学已经去开发另外一款输入法平台了。所以先尝试了一下
fcitx 。体验也不是很好。尽管 iBus 安装文件大得离谱，但在这种没有退路的情况下还是安装了。

我以使用 scim 大半年的经验提醒你，它真的真的不好用。所以，如果你现在还在使用 scim ，并且对其没有特殊情结的话，建议你尝试一下 iBus 。

关于安装，请参考：《<a href="http://www.lirui.name/post/148.html" target="_blank">Ubuntu 8.10 英文环境下安装ibus输入法笔记</a>》。通过此文的方法，即使没有安装中文环境，也可以使用中文输入法。

<div class="smile"><h2>优点</h2>
<h3 style="padding-left: 30px">拼音词库来自搜狗拼音</h3>
<p style="padding-left: 30px">这个比较爽的哈，打起字来如行云流水。哈哈。而且还支持双拼，有多种方案可供选择。</p>

![haha](haha.png)

<p style="padding-left: 30px">在<a href="http://code.google.com/p/ibus/">iBus 的项目主页</a>，你还可以下载到其他输入发的码表，如郑码、Anthy（日文）。</p>
<h3 style="padding-left: 30px">兼容性更好</h3>
<p style="padding-left: 30px">scim 应该是兼容最差的了吧。总之上面提到的应用程序停止响应的情况几乎是没有了。</p>
<h3 style="padding-left: 30px">简单</h3>
<p style="padding-left: 30px">尽管 fictx 的配置十分的强大，iBus 的体积十分的庞大，我还是喜欢这个看起来比较简单的 iBus。安装和配置都很简单，词库很大，选词也比较科学。</p></div>

<div class="sad"><h2>缺点</h2>
遗憾的发现，缺点竟然不少于优点。但是我依然推荐。
<h3 style="padding-left: 30px">五笔</h3>
<p style="padding-left: 30px">五笔很不好用，前几天才给 scim 弄上了万能五笔，而 iBus 中的五笔对于我们只使用简体字的低俗用户来说基本是残废一个。不过已经<a href="http://mineral.javaeye.com/blog/262309" target="_blank">有人整理好了 五笔词库</a> 。不过万能五笔目前还没戏。</p>
<h3 style="padding-left: 30px">速度</h3>
<p style="padding-left: 30px">不少人说 iBus 速度很慢。经过一个星期的使用，感觉还是完全可以接受的。据说新版本（1.1.0）有所改善？不过我用的是源里面的，V0.1.1，并非最新版。</p>
<h3 style="padding-left: 30px">繁体字</h3>
<p style="padding-left: 30px">偶尔也响应下XX的号召，使用繁体字。搞不好以后会有繁体字等级考试，所以要打好提前量。但是，我还是比较喜欢通过拼音和五笔直接输入繁体字。iBus 这点上做得不够。我知道 Hack 下词库可能搞定，但我不会。</p></div>

好了，我准备去升级到  1.1.0 了。留给你无尽的幻想吧。
