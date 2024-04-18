---
title: 移除评论框下“可用标签和属性”提示
date: '2011-12-17 19:39'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - WordPress
        - Comment

---
使用 WordPress 的默认主题或其他主题时，每篇文章的评论框下面都有一段文字，提示浏览者可以在评论中使用的HTML标签和属性，而实际你的网站目标用户并不懂HTML意味着什么：

===

>  您可以使用这些 HTML 标签和属性： &lt;a href=”" title=”"&gt; &lt;abbr title=”"&gt; &lt;acronym title=”"&gt; &lt;b&gt; &lt;blockquote cite=”"&gt; &lt;cite&gt; &lt;code&gt; &lt;del datetime=”"&gt; &lt;em&gt; &lt;i&gt; &lt;q cite=”"&gt; &lt;strike&gt; &lt;strong&gt;
为了删除这段文字，有的网友[建议](http://bolg.malu.me/html/2011/936.html)在WordPress 根目录下 wp-includes/comment-template.php 文件中删除 `echo $args['comment_notes_after'];` 而这么做的一个明显的缺点就是当 WordPress 升级时，文件的内容将被覆盖。

所以，你应该在自建主题或某流行主题的[子主题](http://codex.wordpress.org/zh-cn:%E5%AD%90%E4%B8%BB%E9%A2%98 "如何创建子主题？")中的 functions.php 文件中加入以下代码，来屏蔽这个提示：

```php
add_filter('comment_form_defaults',my_comment_form_defaults);
function my_comment_form_defaults( $defaults) {
$defaults['comment_notes_after'] = '';
return $defaults;
}
```
