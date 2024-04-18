---
title: 导航栏优化
date: '2008-11-21 21:36'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - UE
        - Skill

---
看到上面的一堆东东了吧，“首页”、“存档”、“链接”……当然我这里仅仅是一些页面的链接而已，也算是导航栏吧。

既然是导航，固然是要浏览者了解自己身在何处，可去向何方。

我这里有明显的提示了，在首页的时候，“首页”两个字就变成白色背景，其他诸如“链接”、“关于”也是如此。

其中，首页的这个提示在很多主题下都有实现，然后是其他页面的链接，WordPress 的 <a href="http://codex.wordpress.org/Template_Tags/wp_list_pages" target="_blank" title="查看官方文档关于此函数的说明">wp_list_pages</a> 函数，默认就给出了当前页面一个 `current_page_item` 标签。这样我们只要在 CSS 里面对 `current_page_item` 进行设置就能给浏览者提示了。

那么，__当我进入某篇文章的 时候，也就是 single 页面时，导航栏该作出什么样的反应呢？__

像我这样的导航栏或者称之为“菜单栏”自然无法做到对没一篇文章都来个提示。从概念上讲，文章应该属于菜单项目中的那一类呢？“存档”可以包含“文章”。很多人都会搞一个存档页面吧，来展示一下博客上的文章，方便用户查找。甚至不仅仅是文章（日志），分类页面、标签页面、作者页面都可以看成是从属于 archives （档案）的。

__那么怎么在导航栏中表现出来呢？__

===

首先，WordPress 本身的函数无法满足这一要求。所以要像首页链接一样，让 archives 不通过 `wp_list_pages` 函数直接显示。那么，从 `wp_list_pages` 中把 archives 页面排除掉。打开主题中的 header.php（一般都是在这里），搜索 `wp_list_pages`，找到类似这样的代码：

```php
<ul id="menubar">
    <li class="<?php echo($home_menu); ?>">
        <a href="<?php echo get_settings('home'); ?>/">首页</a>
    </li>
    <?php wp_list_pages('depth=1&title_li=0&sort_column=menu_order'); ?>
</ul>
```

然后把 `wp_list_pages('depth=1&title_li=0&sort_column=menu_order');` 改成：

```php
wp_list_pages('depth=1&exclude=109&title_li=0&sort_column=menu_order');
```

就是为参数中添加了一个 `exclude=109` ，这个意思是说不显示 ID 为 109 的页面。至于 ID 么，在后台编辑页面的时候会有类似的链接：`https://dallas.lu/wp-admin/page.php?action=edit&post=109`，最后面的 `post=109` ，这个109就是该页面ID了。

然后自己加上“存档”页面的连接，放在“首页”那行的下面。我这里是这样的：

```php
<li class="<?php echo($archives_class) ?>" >
    <a href="<?php echo get_settings('home'); ?>/archives/" title="文章列表">存档</a>
</li>
```

然后就是对什么时候的当前页面算 archives 的判断了。顺便提及判断是否为首页的方法如下：

```php
if (is_home()) {
    $home_menu = 'current_page_item';
} else {
    $home_menu = 'page_item';
}
```

那么，我是这样写的：

```php
if ((is_page() && $post->ID==109) | (is_archive() | is_single())) {
    $archives_class = 'current_page_item';
} else {
    $archives_class = 'page_item';
}
```

其中 `is_page() && $post->ID==109` 意思是说，不要忘记存档页本身；你也可以写成： `is_page('archives')`，这个 archives 就是你页面的缩略名啦。然后呢，`is_archive` 的情况包括了标签和分类。好吧，简单而言之，最后是这么办的：

```php
<ul>
    <?php if ((is_page() && $post->ID==109) | (is_archive() | is_single())) {
        $archives_class='current_page_item';
    }else{
        $archives_class='page_item';
    }
    if (is_home()) {
        $home_menu = 'current_page_item';
    } else {
        $home_menu = 'page_item';
    }?>
    <li class="<?php echo($home_menu); ?>">
        <a href="<?php echo get_settings('home'); ?>/" title="首页">首页</a>
    </li>
    <li class="<?php echo($archives_class) ?>" >
        <a href="<?php echo get_settings('home'); ?>/archives/" title="存档">存档</a>
    </li>
    <?php wp_list_pages('depth=1&exclude=109&title_li=0&sort_column=menu_order'); ?>
</ul>
```

一点点关于提高用户体验的小经验，欢迎指导。
