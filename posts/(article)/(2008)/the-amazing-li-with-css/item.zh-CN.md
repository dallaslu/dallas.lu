---
title: CSS和无序列表
date: '2008-12-15 22:23'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - CSS

---
觉得很有用的 CSS 技巧，无聊就翻译过来。中心思想就是，通过 CSS ，li 标签可以无比强大。以下是翻译后的内容。

===

我仍然记得我发现 li 标签这一天。这并不是说在此之前，我没用过——事实上我曾经大量使用无序列表。那一天我发现的是使用小小的 CSS，li 变得很好很强大，堪称网页设计的三个俯卧撑。我们甚至可以用 ul li 来创建整个网站的布局。当然，你不要太认真，不过可以试试。仅以此文向 li 致以崇高的敬意。

## 使用多个 li 标签创建水平导航

你可以在水平导航、横向名单中使用无序列表。基于表的 CSS 布局，深深地深深地震撼了我。它可以使你的代码更加风情万种，楚楚动人。下面是个有5个按钮的水平导航的例子。

```css
ul{
    margin: 0 auto;
}
ul.horizontal_list li{
    text-align: left;
    float: left;
    list-style: none;
    padding: 3px 10px 3px 10px;
    margin: 5px;
    border: 1px solid #CCC;
}
```

以上是 CSS ，HTML 如下：

```html
<ul class="horizontal_list">
    <li>Home</li>
    <li>About Us</li>
    <li>Contact Us</li>
    <li>News</li>
    <li>Mission</li>
</ul>
```

效果如下：

<ul style="margin: 0 auto">
    <li style="list-style: none;text-align: left;float: left;padding: 3px 10px 3px 10px;margin: 5px;border: 1px solid #CCC">Home</li>
    <li style="list-style: none;text-align: left;float: left;padding: 3px 10px 3px 10px;margin: 5px;border: 1px solid #CCC">About Us</li>
    <li style="list-style: none;text-align: left;float: left;padding: 3px 10px 3px 10px;margin: 5px;border: 1px solid #CCC">Contact Us</li>
    <li style="list-style: none;text-align: left;float: left;padding: 3px 10px 3px 10px;margin: 5px;border: 1px solid #CCC">News</li>
    <li style="list-style: none;text-align: left;float: left;padding: 3px 10px 3px 10px;margin: 5px;border: 1px solid #CCC">Mission</li>
</ul>
<div style="clear: both"></div>

## 多列显示

使用 li 可以很容易实现，告别 br 吧！而且日后方便维护。原理如下：

```css
ul{
    margin: 0 auto;
}

/* The wider the #list_wrapper is, the more columns will fit in it */
#list_wrapper{
    width: 200px
}

/* The wider this li is, the fewer columns there will be */
ul.multiple_columns li{
    text-align: left;
    float: left;
    list-style: none;
    height: 30px;
    width: 50px;
}
```

以上是 CSS 。

```html
<div id="list_wrapper">
    <ul class="multiple_columns">
        <li>One</li>
        <li>Two</li>
        <li>Three</li>
        <li>Four</li>
        <li>Five</li>
        <li>Six</li>
        <li>Seven</li>
        <li>Eight</li>
        <li>Nine</li>
    </ul>
</div>
```

效果如下：

<div style="width: 200px">
    <ul style="margin: 0 auto">
        <li style="list-style: none;text-align: left;float: left;height: 30px;width: 50px">One</li>
        <li style="list-style: none;text-align: left;float: left;height: 30px;width: 50px">Two</li>
        <li style="list-style: none;text-align: left;float: left;height: 30px;width: 50px">Three</li>
        <li style="list-style: none;text-align: left;float: left;height: 30px;width: 50px">Four</li>
        <li style="list-style: none;text-align: left;float: left;height: 30px;width: 50px">Five</li>
        <li style="list-style: none;text-align: left;float: left;height: 30px;width: 50px">Six</li>
        <li style="list-style: none;text-align: left;float: left;height: 30px;width: 50px">Seven</li>
        <li style="list-style: none;text-align: left;float: left;height: 30px;width: 50px">Eight</li>
        <li style="list-style: none;text-align: left;float: left;height: 30px;width: 50px">Nine</li>
    </ul>
</div>
<div style="clear: both"></div>

## 背景效果

厌倦了默认的黑点吧，可以使用超酷的背景来替换之。使用 CSS 的话，小菜一碟。

HTML 代码：

```html
<ul class="cool_background">
    <li>Home</li>
    <li>About Us</li>
    <li>Contact Us</li>
    <li>News</li>
    <li>Mission</li>
</ul>
```

CSS 代码：

```css
ul{
    margin: 0 auto;
}
ul.cool_background li{
    text-align: left;
    float: left;
    list-style: none;
    padding: 3px 10px 3px 25px;
    margin: 5px;
    background: url(cool_background.gif) 5px 5px no-repeat;
}
```

别忘记把图片放到跟 CSS 文件相同目录里面。效果如下。

<img alt="" class="alignnone" height="32" src="http://bitsonewmedia.com/images/illustrations/2008_01_list_item/cool_backgrounds2.gif" width="452"/>
  
来源：<http://mirificampress.com/permalink/the\_amazing\_li>

作者：Matthew Griffin
