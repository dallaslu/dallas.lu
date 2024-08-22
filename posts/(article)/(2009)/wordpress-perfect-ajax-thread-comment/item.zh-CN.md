---
title: WordPress 完美 AJAX 嵌套评论
date: '2009-06-04 20:27'
author: 'dallaslu'
comment:
  enabled: true
  reply: false
taxonomy:
    category:
        - WordPress
    tag:
        - Ajax
        - jQuery
        - WordPress

---
上一篇关于 Ajax 评论的文章中有两个缺点，分别是“不能输出合适的样式”和“没有回复链接”。下午对博客进行技术维护，现已基本 OK 了（对于我来说）。

===

页面 js 代码请参考[上篇文章](https://dallas.lu/wp-list-comment-not-perfect-ajax/ "WP默认评论之非完美 AJAX")，或者参见文章结尾的演示文件。

## 新增一个 comment-ajax.php

依然是需要把 WordPress 根目录下的 wp-comment-post.php 复制一份，另存为 comment-ajax.php ， 存到根目录（还需在 js 中指定该文件绝对路径）。

干掉 comment-ajax.php 中的 第 84、85、87 行。把下面的代码复制到该文件末尾的 `?>` 之前。

```php
//$location = empty($_POST['redirect_to']) ? get_comment_link($comment_id) : $_POST['redirect_to'] . '#comment-' . $comment_id;
//$location = apply_filters('comment_post_redirect', $location, $comment);

//wp_redirect($location);

$comment_depth = 1;   //for attribute class of new comment,such as "depth-2"
$tmp_c = $comment;
while($tmp_c->comment_parent != 0){
	$comment_depth++;
	$tmp_c = get_comment($tmp_c->comment_parent);
}
```

接着，打开你的主题中的 comments.php 看一下。搜索 wp_list_comment ，找到 `wp_list_comment()` 或者类似 `wp_list_comment('callback=dallas_list_comment')` 这样的代码。如果参数中没有 callback 字样：请把下面的代码粘贴到 comment-ajax.php <del datetime="2009-06-13T12:55:20+00:00">中上段代码之后</del> 的末尾， `?>`之<del datetime="2009-06-13T12:55:20+00:00">前</del>后（感谢[zwwooooo](http://zwwooooo.com/)同学的提醒）。

```php
<ul><li> 
	id="li-comment-<!--?php comment_ID() ?-->"
	style="display:none">
<div id="comment-<?php comment_ID(); ?>"></div></li></ul>
```

如果你的 comment.php 中 wp_list_comment 的函数中有 `callback` ，那么请打开主题下的 function.php （这种情况下没有这个文件就算是见鬼了）。找到与 callback 同名的函数，将其中的 `<li>`与之间`</li>` 的夹杂 php 代码的 html 部分复制过来。将其中两个函数 comment_class 和 comment_reply_link 的参数改成：

```php
//……
comment_class('',$comment_id,$comment_post_ID);
//……
comment_reply_link(
	array(
		'depth' => $comment_depth,
		'max_depth' => get_option('thread_comments_depth')
	),$comment_id,$comment_post_ID)
//……
```

实际就是改成与我给出的代码相似的样子。就是这些，再按照上篇文章中搞定 js 就 OK 了。

## 还可以更完美点儿？

很多人喜欢评论呈现隔条变色的样式，所以 WordPress 为每条评论都添加了 odd alt thread-odd thread-alt 或者 even thread-even 等 class 。现在唯一的瑕疵就是，comment-ajax.php 输出的都是 even、thread-even ……

由于不在主循环里，获取这些值就麻烦了。所以还是交给 js 处理吧。上篇文章中的 js 代码，修改 `var $newc = $child_list.find('li:last'); ` 为：

```js
var $newc = $child_list.find('li:last');
if($newc.prev().length){
	var $c = $newc.prev();
	if( $c.hasClass('even')){
		$newc.removeClass('even').addClass('odd alt');
	}
	if( $c.hasClass('thread-even')){
		$newc.removeClass('thead-even').addClass('thread-odd thread-alt');
	}
}
```

<div class="warning">
<ol>
<li>本文贴出的代码，依旧与本博客所使用的不一样。</li>
<li>给出的 js 代码需要 jQuery 框架。</li>
<li>如果你还使用了其他框架，可能因命名空间问题导致 js 失效。</li>
<li>js 代码不适用于所有主题，如发生页面错乱，请自行修改。</li>
<li>如果有人应用成功，别忘记通知我下～</li>
</ol>
</div>

## 完整的参考文件

[comment-ajax](comment-ajax.zip)

* 该 php 文件修改自 WordPress 2.8 的 wp-comment-post.php ;
* 在 WordPress 2.8 + Default 下测试通过。
* 在 WordPress 2.8 中，生成的回复链接有误，没有相关 js 则不能工作，原因未知。
