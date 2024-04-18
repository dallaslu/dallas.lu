---
title: Easy to Hide
date: '2009-06-11 18:00'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - WordPress
        - Plugin

---
WordPress 的插件，可以在文章或者评论中随意插入隐藏内容，并可以选择 “曾经在博客留言的评论者”还是“当前文章”的评论者可见。

===

命名为 Easy2hide ，哈哈，麻雀虽小，五脏俱全。<del datetime="2009-06-11T09:25:21+00:00">一共30行，注释占了一半，囧。</del>

<div class="warning">

2010-06-01  Dallas Lu: 如果你需要的功能恰好只是 “登陆可见”，建议尝试 [Login to view all](http://www.ludou.org/wordpress-plugin-login-to-view-all.html)。我最近超级忙，很久以来没更新、更久以后也没有时间更新了。:)

</div>

## 功能

隐藏掉关键的内容，强迫访客留言以赚取人气；

隐藏掉不和谐的内容，小心为上；

隐藏掉额外内容，给留言者一个惊喜；

……

## 安装

<div class="download"><a href="http://wordpress.org/extend/plugins/easy2hide/" target="_blank">Download Easy2hide</a>
<em>插件目录下载页面</em></div>

解压，将 easy2hide 整个文件夹传到 yourwordpress/wp-content/plugins 目录中。后台管理->插件，启用之。

或者访问 yoursite.com/wp-admin/plugin-install.php ，输入 easy2hide 搜索插件。

## 使用

后台编辑器，切换为 HTML 模式，点击“隐藏”按钮来插入代码。

<img alt="Buttom" class="size-full wp-image-544" height="140" src="https://file.dallas.lu/2008/12/easy2hide03.png" width="361"/>

例如（此例只为展示用法，并无真正下载地址）：
>  《金瓶梅 The Forbidden Legend.Sex and Chopsticks 2008.》BT 下载地址：`<--easy2hide start-->https://dallas.lu<!--easy2hide end-->`

上例子中，回复过博客内任意文章的浏览者，都可以阅读隐藏内容。如果希望浏览者必须回复当前文章才可阅读，请参考：

>  本人裸照一枚`<!--easy2hide start{reply_to_this=true}-->哇哈哈，你被骗了<!--easy2hide end-->`

以后再更新自动插入代码吧。

## 提示

<div class="notice">
<ol>
<li>请在<strong> HTML 源代码</strong>编辑模式下使用新标签。</li>
<li>默认并非“回复可见”，发表评论的人可以看到所有文章的隐藏内容。</li>
<li>因使用本插件可能导致的评论泛滥与我无关。</li>
<li>如果使用了缓存插件，可能导致本插件失效。</li>
<li>如果用 <a href="https://dallas.lu/wordpress-perfect-ajax-thread-comment/">ajax 方式提交评论</a>，刷新页面才看得到隐藏内容。</li>
</ol>
</div>

## 更新

* 0.4 更新：实现回复可见，即回复该文章并且评论通过审核才能阅读隐藏内容。
* 0.3 更新：在 HTML 编辑器中添加按钮，可以直接插入隐藏标签。
* 0.2 更新：隐藏标签改为 `<!--easy2hide start-->` 与 `<!--easy2hide end-->` 。
