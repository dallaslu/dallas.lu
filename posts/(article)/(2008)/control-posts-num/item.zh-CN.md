---
title: 控制文章显示
date: '2008-12-16 01:45'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - Skill

---
有时候我们的 WordPress 设置为每页显示10篇文章，但是我们需要在首页或者其他页面只显示6篇文章，或者是第一篇文章输出摘要，其他文章只输出标题。怎么做到呢？

===

## 首页只显示6篇文章

打开位于  /wordpress/wp-content/themes 中的主题文件夹里的 index.php ，找到：

```php
<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
```

在此之前，加入一个计数器，代码：

```
<?php $postcounter=0;?>
```

然后继续搜索：

```php
<?php endwhile; ?>;
```

在这句，也就是循环结束之前，让计数器工作：

```php
<?php $postcounter++;?>
```

好了，如果，我们打算输出6篇文章就够了，那么，在上面的两句之间插入代码，最后看起来像下面这样：

```php
<?php
    $postcounter++;
    if ($postcounter==6){
        break;
    }?>
<?php endwhile; ?>
```

（这个仅当例子来看吧，猛然想到翻页的问题，第二页显示的是第11篇文章，7~10的文章根本没显示，汗）

## 只有第一篇文章输出内容

找到：

```php
<?php the_content(); ?>
```

也可能找不到，因为可能你的主题里在括号里写了东西，搜索 the_content 就可以找到了。把这句改成下面这样：

```php
<?php if ($postcounter!=1){the_content();}?>
```

----------------

利用这个可以干很多事情，比方在<a href="http://ishawn.net/my-blog-related/wordpress-adsense-without-a-plugin.html" target="_blank">某一篇文章插播广告</a>。

@zoll

```php
<?php 
    if ($postcounter!=1 or is_paged()){
        $content_class='content';
    }else{
        $content_class='content hide';
    }?>
    <div class="<?php echo $content_class;?>" >
        <?php the_content('Read more...'); ?>
        <div class="fixed"></div>
    </div>
```

然后在 CSS 里面来句 `.hide { display:none}`。应该可以了吧
