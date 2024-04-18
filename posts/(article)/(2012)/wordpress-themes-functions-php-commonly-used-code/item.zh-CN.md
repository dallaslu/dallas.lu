---
title: 主题 functions.php 常用代码
date: '2012-02-26 23:22'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - PHP
        - WordPress
        - Theme
toc:
  enabled: true
---
WordPress 的主题目录下都会有一个 functions.php 文件，这个文件负责为主题调用各种PHP函数；可以在functions.php文件里面添加各种函数来实各种需求。

===

## 关闭网站中的管理员工具条

```php
add_filter( 'show_admin_bar', '__return_false' );
```

## 移除 l10n.js 脚本

```php
wp_deregister_script( 'l10n' );
```

## 移除 Akismet 在网页头部添加的代码

```php
remove_action('wp_head', 'aktt_head');
```

## 关闭 Feed 订阅功能

```php
function fb_disable_feed() {
	wp_die( __('No feed available,please visit our <a href="'. get_bloginfo('url') .'">homepage</a>!') );
}

add_action('do_feed', 'fb_disable_feed', 1);
add_action('do_feed_rdf', 'fb_disable_feed', 1);
add_action('do_feed_rss', 'fb_disable_feed', 1);
add_action('do_feed_rss2', 'fb_disable_feed', 1);
add_action('do_feed_atom', 'fb_disable_feed', 1);
```

## [移除评论框下“可用标签和属性”提示](https://dallas.lu/remove-the-available-tags-and-attributes-prompt-under-the-comment-box/)

```php
add_filter('comment_form_defaults',my_comment_form_defaults);
function my_comment_form_defaults( $defaults) {
	$defaults['comment_notes_after'] = '';
	return $defaults;
}
```

## 移除评论表单的的网址输入框

```php
add_filter('comment_form_default_fields',my_comment_form_default_fields);
function my_comment_form_default_fields($fields){
	unset($fields['url']);
	return $fields;
}
```

## 移除登陆框 Logo 的连接地址

```php
add_filter( 'login_headerurl', 'custom_loginlogo_url' );
function custom_loginlogo_url($url) {
    return home_url( '/' );
}
```

## 更改登陆框 Logo

```php
add_action('login_head', 'my_custom_login_logo');
function my_custom_login_logo() {
    echo '';
}
```
