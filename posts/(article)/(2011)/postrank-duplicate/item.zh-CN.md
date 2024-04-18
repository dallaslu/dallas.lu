---
title: PostRank 插件重复文章问题
date: '2011-01-06 08:28'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:

---
终于搞定了 [PostRank 插件](http://jeeker.net/projects/postrank/) 的出现重复文章的问题。其实这个问题困扰我很久了，原作者已经2年没有更新这个插件了。谁叫我用得还挺爽的呢。所以自己动手，丰衣足食了。

===

好在该插件只有一个文件，一番排查之后注意力转移到了数据库上。果然，wp_postmeta 表中 id 一致、meta_key 为 '_post_rank' 的记录都有相同的两条存在。先把这些重复内容删除，在phpmyadmin 中执行SQL：

```sql
DELETE FROM wp_postmeta WHERE meta_key = '_post_rank';
```

那么，根源在哪儿呢？自然是创建这些 postmeta 的函数中。但是翻看了一下，创建 postmeta 时使用的是 WordPress 的内置函数，怎么会重复呢？例如，该插件文件267~272行代码如下：

```php
function UpdateViews($post_id = 0) {
        $post_views = $this->GetViews($post_id) + 1;
        if (!update_post_meta($post_id, '_post_views', $post_views))
           add_post_meta($post_id, '_post_views', 1);
        $this->UpdateRank($post_id, $this->Options['single_value']);
    }
```

去[官方文档](http://codex.wordpress.org/Function_Reference/update_post_meta)查看了一下，原来：

>  This may be used in place of add\_post\_meta() function.

既然如此，将下面两处：

```php
if (!update_post_meta($post_id, '_post_views', $post_views))
       add_post_meta($post_id, '_post_views', 1);
```

```php
if (!update_post_meta($post_id, '_post_views', $post_views))
       add_post_meta($post_id, '_post_views', 1);
```

修改为：

```php
然后到后台 PostRank 管理界面， Restat 一下即可。
