---
title: Pidgin的QQ掉线问题
date: '2008-07-18 01:12'
author: 'dallaslu'

taxonomy:
    category:
        - IM
    tag:
        - Pidgin
        - QQ

---
很不幸的，在Pidgin 2.4.3 这个版本上又有QQ的问题发生。之前一个版本是QQ群的名称问题，而这次则是掉线，频繁的掉线。我用Pidgin登录了两个QQ，几乎是两个QQ轮流掉线，频率稳定，重新连接上的时候就蹦出一堆窗口，说“演示群已经删除，……”。刚刚安装完2.4.3的时候还没有意识到这个问题，因为一起用宽带的Windows XP3、Vista系统中使用QQ2008也掉线。但是不久，别人的Q就不掉了。

这个Q掉的实在让人心烦，跟Vista的确认提示有得一拼。于是无奈的谷歌了下该问题，发现掉线现象很普遍。

之后经过一番折腾——使用TCP登录、使用代理等，还是没有找到解决办法。但是，似乎有那么一点规律。

* 隐身的掉线率比离开状态要低。
* 在线的掉线率比隐身状态要高。

不知道是不是我的错觉。

如果你也遇到了这个问题（目前只在Ubuntu里遇到此问题，Windows版本未测试），那么，建议你尝试下面的办法。

===

1. 在 password.qq.com 改个密码试试。
2. 在 Windows 下登录QQ（或者Wine）设置一下区域信息，使其与你所处位置一致。
3. 将QQ设置为隐身状态。
4. 如果3不行，就切换到在线，然后再切换到隐身。
5. 4也不行的话……离线算了。

听闻最近QQ for Linux 即将发布，嵌入到QQ中的WebQQ也开始内测，不过最是期待Pidgin能更完美的支持QQ。

PS：QQ掉线问题有所缓解之后，Gtalk又开始掉线了……

![pidgin](pidgin.png)

![QQ](qq.png)

这两个家伙看起来挺可爱的，怎么就不能好好在一起玩呢？
