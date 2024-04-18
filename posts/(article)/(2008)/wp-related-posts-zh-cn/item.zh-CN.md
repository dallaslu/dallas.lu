---
title: 相关文章插件的汉化问题
date: '2008-11-16 01:24'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - Hanz

---
话说，装了 WordPress Related Posts 这个插件很久了，今天进后台才注意到居然是英文的。于是乎去寻找语言文件，几经辗转，找到了 <a href="http://fairyfish.net/2008/06/06/wordpress-related-posts-plugin-translation/" target="_self" title="WordPress Related Posts Plugin Translation">该插件的翻译页面</a> ，但是居然没有中文语言包……水煮鱼说是有的——特意去官方目录里重新下载了一边，但是没看到。

===

浏览了下该文的评论，也是一堆牢骚。看来得自己动手了， Wordpress 的官方插件目录和水煮鱼那里都没看到语言包模板。嘿嘿，然后采取了偷懒的办法，直接下载了翻译页面上提供的繁体语言包。（貌似其他语言的链接都不太好用，失效或者不指向语言包页面。）

然后解压之，打开 wp_related_posts-zh_TW.po 文件，全选复制，粘贴到 <a href="http://translate.google.com/" target="_blank">Google翻译</a> 里，从繁体翻译到简体，然后复制回来，把该文件令存为 wp_related_posts-zh_CN.po 。

接着，打开终端（你用 Windows 的？自己去搜索下怎么po 2 mo ），转到该文件目录，执行：

```bash
msgfmt wp_related_posts-zh_CN.po -o wp_related_posts-zh_CN.mo
```

呃，如果你的 Ubuntu 还没安装 msgfmt 的话，先执行：

```bash
sudo aptitude install gettext
```

好了，把这个 `wp_related_posts-zh_CN.mo` 上传到这个插件的目录下的 `langs` 目录里。

这个插件使用也很简单，只需要后台设置下，然后把 `<?php wp_related_posts(); ?>` 这句放到主题文件中就可以了。相比，“WordPress SEO 中文插件”虽然也集成了这个功能，但不是很好用，比方控制不了风格。目前我仅仅用这个SEO插件来自动填充文章摘要……

插件下载：<a href="http://fairyfish.net/2007/09/12/wordpress-23-related-posts-plugin/" target="_blank">wordpress-23-related-posts-plugin</a>

中文下载：[wp_related_posts-zh_CN.zip](wp_related_posts-zh_CN.zip)
