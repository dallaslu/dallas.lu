---
title: 用WordPress做静态站
date: '2010-03-23 10:16'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - wget
        - Skill

---
两年前，给学校的一位老师制作过课程展示网站。当时是借用了另外一个网站的样式，那个网站几乎是静态的，但是每个页面都有一些 ASP 脚本。装好了IIS，打开 DreamWare，耗费在网页制作上的工作量大概是4人日；文档资料整理10人日。

===

如今要更新这些页面，真是让人抓狂。时间比较紧迫，好在对页面美观程度没有什么要求。重新装上 DreamWare，我马上就被乱乎乎的代码弄得晕头转向。

## 思路

制作好页面之后，需要发布到学校的网站上，仅支持 ASP 脚本。我想，或许一个 CMS 能完成这个工作。不过我早把 ASP 忘光了，还是用 WordPress 好了。

## 使用 WordPress

早上八点开工。我先去下载了 [PHPnow](http://phpnow.org/download.php)，一个 AMP 环境的集成包。不一会，连 [WordPress](http://wordpress.org) 也装好了。直接就用默认的主题，启用简洁链接。

接着就是乏味的发布工作。一共创建了大概60个页面。文字内容直接从 Word 粘贴过来，编辑器中生成的 html 代码也十分简洁；图片和其他附件也都上传过来，方便生成文字链接。再稍稍设置一下页面的缩略名、上级页面和页面排序，就可以了。下午三点半，总算完成了编辑工作。

接着给 WordPress 安装了导航插件 [Multi-level Navigation Plugin](http://wordpress.org/extend/plugins/multi-level-navigation-plugin/)（[中文介绍](http://www.wordpress.la/multi-level-navigation.html)），和 [LightBox](http://wordpress.org/extend/plugins/lightbox-2/)。修改了默认主题的 style.css，又去掉了侧边栏、评论。就算差不多完工了。

## 获得静态网页

但是学校的网站无法运行 WordPress，反正也不需要动态管理，就下载了一个 [Windows 版本的 wget](http://gnuwin32.sourceforge.net/packages/wget.htm) ，执行一下命令` wget -r -p -np -k http://127.0.0.1/wordpress`，就获得了静态页面。

放心，所有的链接都被改成了相对路径。但是 JS 脚本中的字符串中的网址，得需要自己手动处理一下了。也简单，访问一下本地站，把 `get_header()` 输出的内容拷贝到主题模板 header.php 中，替换掉 `get_header()`，稍做些编辑就可以了。

## 总结

有了 WordPress 和 wget 两个利器，一样是从头开始，考虑到难度降低和有了经验的因素，仍然可以说效率提高了10倍。
