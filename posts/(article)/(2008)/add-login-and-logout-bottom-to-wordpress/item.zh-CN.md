---
title: 给Wordpress添加登录按钮
date: '2008-08-19 16:52'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - WordPress

---
偶尔翻硬盘发现。为我以前的主题搞的。没准有人会用到？

以下是代码了。

===

```php
<?php
    $u = get_userdata($user_ID);
    $user_name = ($user_ID == 0) ? "Guest" : $u->nickname;
    print($user_name);?>
<?php if ( $user_ID ) : ?>
    <span class="loginout">
        <?php if (is_single() or is_page() ): ?>
            <a href="<?php get_option('siteurl'); ?>/wp-login.php?action=logout&redirect_to=<?php get_permalink(); ?>">注销</a>
        <?php else : ?>
            <a href="<?php get_option('siteurl'); ?>/wp-login.php?action=logout">注销</a>
        <?php endif; ?>
        |<a href="<?php echo get_option('siteurl'); ?>/wp-admin/index.php">管理</a>
    </span>
<?php else : ?>
    <span class="loginout">
        <?php if (is_single() or is_page() ): ?>
            <a href="<?php echo get_option('siteurl'); ?>/wp-login.php?redirect_to=<?php get_permalink(); ?>">登陆</a>
        <?php else : ?>
            <a href="<?php echo get_option('siteurl'); ?>/wp-login.php">登陆</a>
        <?php endif; ?>
        |<a href="<?php echo get_option('siteurl'); ?>/wp-login.php?action=register">注册</a>
    </span>
<?php endif; ?>
```
