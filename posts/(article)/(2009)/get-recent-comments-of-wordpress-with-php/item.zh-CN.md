---
title: 获取最新评论 PHP 代码
date: '2009-01-03 01:03'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - PHP
        - WordPress
        - Skill

---
WordPress 侧栏最新评论的默认样式很不顺眼，于是从 widgets.php 中把显示评论的代码抠出来改了一番。并且过滤掉了注册用户的评论，以及 trackback 、pingback 。

===

先说我是怎么办的。

打开 wordpress/wp-includes/widgets.php ，搜索 `wp_widget_recent_comments `，找到位于 1379~1405 行的函数，修改之后获得了如下代码：

```php
<?php
    global $wpdb, $comments, $comment;
    $comments = $wpdb->get_results("SELECT * FROM $wpdb->comments WHERE comment_approved = '1' and user_id = '0' and comment_type = '' ORDER BY comment_date_gmt DESC LIMIT 5");
?>
<ul id="recentcomments">
    <?php
        if ( $comments ) : 
            foreach ( (array) $comments as $comment) :$text = $comment->comment_author . ': ' . $comment->comment_content;
                $text = mb_strimwidth(strip_tags($text), 0, 40,"...");
                echo '<li class="recentcomments"><a href="'. get_comment_link($comment->comment_ID) . '" title="《' . get_the_title($comment->comment_post_ID) . '》">' . $text . '</a></li>';
            endforeach; 
        endif;?>
</ul>
```

接着在 WordPress 管理首页->外观->Widgets 添加了个 Samsarin PHP Widget （<a href="http://wordpress.org/extend/plugins/samsarin-php-widget/" target="_blank" title="可以在 Widget 中使用 PHP 代码。点击查看插件主页">？</a>），代码粘进去，OK。

下面说几个你可能用到的修改办法。

## 最新评论中不显示 trackback 、pingback

打开 widgets.php ，搜索 `WHERE comment_approved = '1'` 找到 1392行：

```php
$comments = $wpdb->get_results("SELECT * FROM $wpdb->comments WHERE comment_approved = '1' ORDER BY comment_date_gmt DESC LIMIT $number");
```

修改成：

```php
$comments = $wpdb->get_results("SELECT * FROM $wpdb->comments WHERE comment_approved = '1' and comment_type = '' ORDER BY comment_date_gmt DESC LIMIT $number");
```

## 最新评论中不显示注册用户评论

这个方法很适合像我一样的个人博客，经常回复读者留言，结果一段时间内“最新评论”中显示的都是自己的留言。方法同上，修改为：

```php
$comments = $wpdb->get_results("SELECT * FROM $wpdb->comments WHERE comment_approved = '1' and uesr_id = '0' ORDER BY comment_date_gmt DESC LIMIT $number");
```

需要注意的是，修改前请备份 widgets.php ；也把修改后的备份一下，升级程序会覆盖你修改的文件的。
