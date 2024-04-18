---
title: 用网页截图做评论头像
date: '2008-08-24 22:30'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - Gravatar
        - WordPress

---
通常情况，在Wordpress搭建的博客上的留言者所显示的头像，是需要到Gravatar注册上传的。博客系统在显示评论的时候会根据作者的邮箱计算出在Gravatar上的头像地址。不过不用担心，这个头像地址是经过MD5加密的，不会泄露邮箱地址。

===

那么，没有注册上传头像的朋友们就不会显示头像了么？也是可以的，博客后台就可以选择默认的评论者头像。如果把这个默认地址填写为一个随机显示图片的PHP文件，就可以随机显示头像了。

但是，如果用网页截图作评论头像如何？<del>效果可以参考本文沙发。 </del>（更新：我现在用的是 wordpress 自带的随机头像功能。）

发挥一下DIY精神，自己动手添加这个功能。代码如下。

```php
if ($comment->comment_author_url==""){
    $gravatar_default = "你的默认头像地址";
}else{
    $gravatar_default="http://images.websnapr.com/?size=T&key=5D1WxBG8oU4s&url=$comment->comment_author_url";
}
echo get_avatar( $email=$comment->comment_author_email, $size = '40', $default = $gravatar_default);?>
```

用这段代码替换主题中显示头像的函数。

其中 `$gravatar_default` 所指向的值就是获得评论者网页截图的地址了。到 websnapr.com 去注册个账号吧，过程十分简单。然后得到你自己的 KEY ，替换掉 5D1WxBG8oU4s 就可以了。

如果嫌麻烦，这里有插件， <a href="http://fisio.cn/wp-snapavatar-plugin.html" rel="nofollow">WP-SnapAvatar</a> ，不过我没用过。
