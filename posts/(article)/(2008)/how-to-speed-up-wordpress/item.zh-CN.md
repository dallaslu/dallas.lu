---
title: 加速 WordPress
date: '2008-12-09 00:01'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - CSS
        - WordPress
        - Skill

---
通过 Hyper Cache 等插件，以及使用 Gzip 压缩 CSS 、JS 文件并改变其在页面的位置来提高 WordPress 的加载速度。

===

## 通过插件缓存

<a href="http://mnm.uib.es/gallir/wp-cache-2/" target="_blank">WP-Cache 2.0</a> 、<a href="http://wordpress.org/extend/plugins/wp-super-cache/download/" target="_blank">WP Super Cache</a> 、<a href="http://getfreeware.net/archives/Batcache" target="_blank">Batcache</a> 算是比较流行的了。介绍一下我在使用的 [Hyper Cache](http://www.satollo.com/english/wordpress/hyper-cache "访问插件主页")。Hyper Cache 简单小巧，完美支持Gzip压缩更好的支持移动设备，还可以缓存404页，重定向页面等，生成的缓存文件不占用太多空间。关于更加详尽的介绍请看 《<a href="http://zuoshen.com/2008/12/05/450/" target="_blank">Hyper Cache 设置相关</a>》，或者《<a href="http://www.lwydl.cn/?s=hyper-cache" target="_blank">Hyper Cache 汉化版</a>》。

## Gzip 压缩 CSS 、JS 文件

我的主题的 style.css 文件原大小 20K ，压缩后只有5K，速度提升十分明显。同时也不必担心占用过多的服务器 CPU 资源，因为有缓存滴。首先确认你的空间支持 .htaccess ，然后移步到《<a href="http://www.cbmland.com/post/522/optimized-wordpress-notes-1.html" target="_blank">Gzip 压缩 CSS 、JS</a>》来下载需要的 gzip.php 文件。

我把该文件命名为 wp-gzip.php 传至网站根目录，同时在根目录下建立文件夹 wp-cache ，并确保可写。然后在根目录的 `.htaccess` 加入：`RewriteRule (.*.css$|.*.js$) gzip.php?$1 [L]`。可以参考这段：

```apacheconf
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule (.*.css$|.*.js$) wp-gzip.php?$1 [L]
</IfModule>
```

最好不要在 WordPress 默认的那段里面写，`# BEGIN WordPress` 和 `# END WordPress` 之间的东西随时可能被 WordPress 重置为默认的语句。

## 合并 CSS 文件

很多插件都会在 head 标签里插入自己的 CSS 文件，不信打开你的首页，看下源代码就知道。为了确定那些是自动加入的，你可以在你的主题中的 header.php 里查找：`wp_head(); ` ，将之更改为：

```php
echo '<!--start-->';
wp_head();
echo '<!--end-->';
```

然后重新打开你的网站，看看这两段注释里都多了什么东西？把多的那几行保存一下，然后改成  `<?php //wp_head(); ?>` 来注释掉这句。把网页代码中引用的 CSS 文件地址，复制到浏览器地址栏中打开，把代码复制，通通粘贴到你的主题 `style.css` 文件的末尾。要注意，有些插件的 CSS 里面定义了图片背景，你可以把插件中的图片目录移动到主题文件夹里面。比方说某插件里面有一句 `url(images/loading.gif)`,你就可以把插件里面的 images 文件夹放到主题目录中与 `style.css` 所在的目录即可。

## JS 文件放到最后加载

把引用的 JS 文件的语句统统从 `header.php` 里面剪切掉，粘贴到主题中的 `footer.php` 中的 `</body>` 前面。

需要注意的是，如果你使用的是 WordPress 2.7 ，并且主题支持原生嵌套评论 ，可以在 header.php 中找到 位于 wp_head() 前面的：

```php
<?php if(is_singular()) wp_enqueue_script('comment-reply'); ?>`
```

删除掉，并在 footer.php 中添加：

```php
<?php if(is_singular()) : ?>
    <script type='text/javascript' src='http://yourwordpress.com/wp-includes/js/comment-reply.js?ver=20081009'></script>
<?php endif;?>
```

同样，你也可以对 JS 文件像对 CSS 文件一样进行合并，不过建议有把握再这么做。

## 其他方面

尽量使用图片较少的主题；尽量使用站内图片。至于广为流传的将主题中的一些判断及函数按执行结果写死的方法也不错，不过有了缓存插件，估计效果不是很大了。另外很多人喜欢在侧边栏放一些引用站外 JS 文件的挂件，还有统计代码等等；如果不是必要，最好不要加这些东西，加的话也尽量放在 footer.php 里面。

## 加载条

加载条并不能提高页面载入速度，但是能缓解一下访问者等待时的尴尬气氛。添加这个进度条总共分为3步：

1. 在你的 header.php 中，添加 `<div id="loading">加载ing（可以不设置文字，而用背景图片）</div>`
可以参考我的网页代码。

2. 在 `style.css` 里面为 loading 设置样式。我的样式：
    
```css
#loading{
    z-index:3;
    background-image:url(images/loading.gif);
    left:48%;
    top:10px;
    width:128px;
    height:15px;
    position:fixed;
}
* html #loading {
    position:absolute; /*for the fucking IE6*/
}
*+html #loading {
    position:fixed;/*for the fucking IE7*/
}
```

而这个 loading 的图片，你可以去<a href="http://www.ajaxload.info/" target="_blank" title="在线生成 loading 动画图片">定制一个</a>。

3. 在 footer.php 里面添加一段代码保证那个 loading 在页面加载完毕后消失：

```php
<script>document.write('<style>#loading{display:none}</style>');</script>`
```

（以上方法来自 <a href="http://www.awflasher.com/blog/archives/1589" target="_blank">aw</a>）

大概就这么多了，如果你还不满足，可以看看 shawn 的 《<a href="http://ishawn.net/my-blog-related/cache-gravatar-into-local-server.html" target="_blank">如何缓存Gravatar 至本地服务器</a>》，我嫌麻烦就没弄，呵呵，我对现在的速度很满足了。如果你还有别的高招，不妨留言哈~
