---
title: WP默认评论之非完美 AJAX
date: '2009-06-01 23:16'
author: 'dallaslu'
comment:
  enable: true
  reply: true
taxonomy:
    category:
        - WordPress
    tag:
        - Ajax
        - jQuery
        - WordPress

---
WordPress 2.7 开始原生支持嵌套评论了，但是一直没见人介绍相关的 AJAX 实现办法。或不嵌套，或用插件。实际上简单修改就能做到。

===

<div class="notice">2009/06/13 更新：<br/>
修正的 php 和 js 请参见《<a href="https://dallas.lu/wordpress-perfect-ajax-thread-comment/>WordPress 完美 AJAX 嵌套评论</a>》，还提供了完整的参考文件。</div>

关于 AJAX 评论 ，忧伤的 Xiaorsz 同学，有篇《[使用 jQuery 实现 wordpress 的 Ajax 留言](http://www.xiaorsz.com/jquery-wordpress-ajax-comments/)》。这篇文章之所以不适合使用 WordPress 默认评论函数，就是因为这个函数处理的比较复杂。

## WordPress 函数 wp\_list\_comments()

这个函数生成的评论列表，每条评论都有丰富的 class 属性。还需要引入一段 js 来完成 reply 的功能。当然，这个 reply 的链接没有 js 也一样工作。

这个问题的稍难之处就在于，提交评论之后要返回合适的单条评论数据，而且需要网页的 js 来配合，呈现评论列表应有的样式。和 Xiaorsz 的教程一样，下面使用 jQuery 来实现。

## PHP 文件

打开 WordPress 根目录下的 wp-comment-post.php 。将84-87行删除掉，另存为 comment-ajax.php 。这段代码是处理评论成功后跳转的。

下面这段代码改自 wp\_list\_comment() 的示例，比较接近默认。如果你在处理评论时回调了自己的函数，拷贝来即可。

```php
function ajax_comment_output($comment, $args, $depth) {
	$GLOBALS['comment'] = $comment; ?>
	<li  id="li-comment-" style="display:none">
	<div id="comment-">
<div class="comment-author vcard">
		<?php echo get_avatar($comment,$size='32',$default='' ); ?>
		<?php printf(__('<cite class="fn">%s</cite>'), get_comment_author_link()); ?></div>
comment_approved == '0') : ?>
         <em>&nbsp;</em>
<div class="comment-meta commentmetadata">
            <a href="comment_ID ) ) ?>"></div>
<?php
}

ajax_comment_output($comment,null,null);
```

这坨代码粘到 comment-ajax.php 最后的 `?>` 前面。

## JavaScript 文件

也是看注释修改吧。

```javascript
$("#commentform").submit(function(){//comment-form 为评论表单 ID
	pass = true;
	var $text = $("#comment"); //评论内容输入框
	var $form = $('#commentform');
	var $respond = $('#respond'); //整个评论输入区，包括表单、提示什么的
	var $submit = $('#submit'); //提交按钮

	//进度条，请自行在 CSS 中设定样式
	var loading = '

';

	/*
	 * 简单验证表单数据
	 */
	$("input[aria-required=true]").each(function(){
		if(this.value == "") {
			this.focus();
			pass = false;
		};
	});
	if (pass && $text.val()==""){
			$text.focus();
			pass = false;
		};

	//开始处理评论
	if (pass){
		jQuery.ajax({
			url: 'https://dallas.lu/comments-ajax.php', //绝对路径
			data: $form.serialize(),
			type: 'POST',
			beforeSend:function(){ //发送数据前
				$submit.after(loading);
				$submit.hide();
				$('#comment-load').show('slow');
				$form.find('input,textarea').attr("disabled",true); //表单组件设置为不可用
			},
			error:function(request){ //出错的情况
				alert(request.responseText); //我比较懒，直接蹦个对话框
				$('#comment-load').remove();
				$submit.show();
				$form.find('input').removeAttr('disabled'); //表单可用
			},
			success:function(data){ //评论发表成功
				$('#comment-load').hide("slow").remove(); //干掉进度条
				$submit.show();
				$text.val(''); //清空文本域中评论内容
				var $parent = $respond.parent(); //评论区父元素
				var $child_list; //评论列表
				if(!$('#commentlist').length){ //没有评论则加个列表先。此ID请自行添加
					$respond.before('

');
				}
				if($parent.attr('id')=='main'){ //父元素若是main(与我模板有关)
					$child_list = $('#commentlist');
				}else{ //回复他人评论（嵌套）的情况
					if(!$parent.find('ul.children').length){ //还没有子评论则添加个列表先
						$respond.before('

');

						// class 添加 parent 值。WP默认就是这么干的
						$parent.addClass('parent');
					}
					$child_list = $parent.find('ul.children:first');
				}
				$child_list.append(data); //新评论终于出来了

				//处理评论计数。这个 comment-num 已经事先放好。
				if($('#comment-num').length){
					$('#comment-num').text(parseInt($('#comment-num').text())+1);
				}else{
					$('#comments').html('<span>1</span> 条');
				}
				//
				var $newc = $child_list.find('li:last'); //刚添加的评论
				$newc.slideDown('slow',function(){

					//slideDown 过后 display 值为 block，影响了评论样式。
					$newc.css('display','');
				});
				//表单恢复可用
				setTimeout(function(){
						$form.find('input,textarea').removeAttr('disabled');
					}, 3000);
			}
		});
	}
	return false;
});
```

## 为啥不完美

comment-ajax.php 中 comment\_class() 此时无法生成完美的 class 属性。还有一个，没有 reply 链接。所以我在考虑，能否用自定义查询来输出新增加的评论 ？这个就是以后的话题了。

<div class="warning">本文中代码和博客中所用代码有所不同，暂未通过任何类似 iso-8964 等组织认证。 <p>所以很可能造成一些诡异现象……</p>
</div>
