---
title: WordPress“即将推出”小工具
date: '2013-01-06 21:51'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - WordPress
        - Plugin

keywords:
  - WordPress 显示定时发布
---
出于维护博客更新频率，或精雕细琢文章时督促自己及时完成，我们会在 WordPress 中把该篇文章设为“定时发布”(Schedule)。如果能在网站显示出这些预定发布的文章，会吸引读者继续关注你的博客吧？

===

## 思路

把即将推出的文章显示在侧边栏是个好办法，不过很多主题都只能以小工具的形式在侧边栏添加内容。所以，[不得言的办法](http://www.budeyan.com/seo_youhua/display-future-posts/ "实现WordPress博客预发布日志预告功能的方法")，仍稍显不便。实际上，这个功能和 WordPress 中内置的近期文章小工具十分相似。

在 WordPress 的 wp-includes/default-widgets.php 第503行（WordPress 3.3.1，其他版本可能不同）处找到相关代码。

## 关键语句

找到代码：

```php
$r = new WP_Query(array('posts_per_page' => $number, 'no_found_rows' => true, 'post_status' => 'future', 'ignore_sticky_posts' => true));
```

将 publish 改为 future，应该就可以实现功能。

## 修改后的完整代码

经过一番尝试，改好的 widget 类代码如下：

```php
<?php
/**
 * Upcoming_Posts widget class
 */
class WP_Widget_Upcoming_Posts extends WP_Widget {

    function __construct() {
        $widget_ops = array('classname' => 'widget_upcoming_entries', 'description' => __( "The upcoming posts on your site") );
        parent::__construct('upcoming-posts', __('Upcoming Posts'), $widget_ops);
        $this->alt_option_name = 'widget_upcoming_entries';

        add_action( 'save_post', array(&$this, 'flush_widget_cache') );
        add_action( 'deleted_post', array(&$this, 'flush_widget_cache') );
        add_action( 'switch_theme', array(&$this, 'flush_widget_cache') );
    }

    function widget($args, $instance) {
        $cache = wp_cache_get('widget_upcoming_posts', 'widget');

        if ( !is_array($cache) )
            $cache = array();

        if ( ! isset( $args['widget_id'] ) )
            $args['widget_id'] = $this->id;

        if ( isset( $cache[ $args['widget_id'] ] ) ) {
            echo $cache[ $args['widget_id'] ];
            return;
        }

        ob_start();
        extract($args);

        $title = apply_filters('widget_title', empty($instance['title']) ? __('Upcoming Posts') : $instance['title'], $instance, $this->id_base);
        if ( empty( $instance['number'] ) || ! $number = absint( $instance['number'] ) )
             $number = 10;

        $r = new WP_Query(array('posts_per_page' => $number, 'no_found_rows' => true, 'post_status' => 'future', 'ignore_sticky_posts' => true, 'orderby' => 'date', 'order' => 'ASC'));
        if ($r->have_posts()) :
?>
        <?php echo $before_widget; ?>
        <?php if ( $title ) echo $before_title . $title . $after_title; ?>
        <ul>
        <?php  while ($r->have_posts()) : $r->the_post(); ?>
        <li><a href="<?php the_permalink() ?>" title="<?php echo esc_attr(get_the_title() ? get_the_title() : get_the_ID()); ?>"><?php if ( get_the_title() ) the_title(); else the_ID(); ?></a></li>
        <?php endwhile; ?>
        </ul>
        <?php echo $after_widget; ?>
<?php
        // Reset the global $the_post as this query will have stomped on it
        wp_reset_postdata();

        endif;

        $cache[$args['widget_id']] = ob_get_flush();
        wp_cache_set('widget_upcoming_posts', $cache, 'widget');
    }

    function update( $new_instance, $old_instance ) {
        $instance = $old_instance;
        $instance['title'] = strip_tags($new_instance['title']);
        $instance['number'] = (int) $new_instance['number'];
        $this->flush_widget_cache();

        $alloptions = wp_cache_get( 'alloptions', 'options' );
        if ( isset($alloptions['widget_upcoming_entries']) )
            delete_option('widget_upcoming_entries');

        return $instance;
    }

    function flush_widget_cache() {
        wp_cache_delete('widget_upcoming_posts', 'widget');
    }

    function form( $instance ) {
        $title = isset($instance['title']) ? esc_attr($instance['title']) : '';
        $number = isset($instance['number']) ? absint($instance['number']) : 5;
?>
        <p><label for="<?php echo $this->get_field_id('title'); ?>"><?php _e('Title:'); ?></label>
        <input id="<?php echo $this->get_field_id('title'); ?>" name="<?php echo $this->get_field_name('title'); ?>" type="text" value="<?php echo $title; ?>" /></p>

        <p><label for="<?php echo $this->get_field_id('number'); ?>"><?php _e('Number of posts to show:'); ?></label>
        <input id="<?php echo $this->get_field_id('number'); ?>" name="<?php echo $this->get_field_name('number'); ?>" type="text" value="<?php echo $number; ?>" size="3" /></p>
<?php
    }
}
```

## 使用方法

将以上代码小心地拷贝进主题的 functions.php 文件中，并添加以下代码：

```php
function upcoming_posts_widget_init() {
	register_widget( 'WP_Widget_Upcoming_Posts' );
}
add_action( 'widgets_init', 'upcoming_posts_widget_init' );
```

在主题的小工具选项中就可以使用了。

## 插件版

<http://wordpress.org/extend/plugins/wp-upcoming-posts-widget/>
