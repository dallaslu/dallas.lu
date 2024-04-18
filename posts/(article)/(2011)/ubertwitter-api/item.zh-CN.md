---
title: UberTwitter 0.97 可用API
date: '2011-09-25 21:25'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Twitter
        - Ubertwitter
        - Blackberry

---
UberTwitter 在今年早些时候[改名为UberSocial](http://www.bjxiaoc.cn/index.php/archives/tag/ubertwitter) 了，和Gravity一样，开始不支持自定义API了。不支持API的推软在天朝如同摆设一般，好在UberTwitter 的0.9系列版本仍然可用。但是可用API就太难找了，为了免于被墙，很少有人会把自己的API公布出来，所以在网络上已经搜索不到公开的支持 oauth 的API了。

===

好用稳定的API应该具有如下特点：

*   __稳定__：高可用率、可以接受的速度。
*   __安全__：支持加密访问，降低被墙风险。

所以如果自己搭建这样一个API，需要的大致成本是：

*   拥有独立IP的虚拟主机空间或VPS：$60+ 每年
*   手机可信任的SSL数字证书：$0~$19 每年
*   域名：$1.19~$19.9 每年

并非人人都有精力去搭建这么一个API，而我的成本如下：

VPS $479.4，SSL $12.9，域名 $13.99

## API分享计划

所以，有同样使用 UberTwitter 的黑莓用户，阅读完使用步骤之后确认需要此API，<del>可以在此评论，留下 twitter 账号和邮箱，我会将API地址发送与你</del> 请访问 <http://goo.gl/3WPEy> 。

## 使用步骤

1.   
    
    ### 下载
    
    请在此帖子按版本下载对应附件：<a href="http://www.52blackberry.com/thread-518993-1-1.html" id="thread_subject">UberTwitter一款黑莓上十分好用的twitter软件【需可用api支持】</a>
2.   
    
    ### 安装
    
    使用桌面管理器或其他黑莓工具，将UberTwitter安装到你的黑莓手机中。
3.   
    
    ### 获取API
    
    通过SSH、VPN等方法，确保__能直接访问Twitter官网__；访问API生成地址，选择O模式，进行 OAuth 认证；在Twitter官网输入用户名密码，获取API地址。
4.   
    
    ### 配置
    
    在UberTwitter 界面按下菜单键，依次选择Option、Advancer Option，输入获取的API即可。

至此，尽情Twitter吧！
