---
title: 网页的打印样式应该怎么写
published: true
date: '2024-04-26 04:26'
license: CC-BY-NC-SA-4.0
taxonomy:
  category:
    - Internet
  tag:
    - HTML
    - CSS
keywords:
  - 打印样式
  - '@media print'
  - 网页转PDF
  - Markdown转PDF
toc:
  enabled: true
x.com:
  status: https://x.com/dallaslu/status/1783896218814517522
nostr:
  note: note1jkfut2kx6xv68d03h44cl02czwdk3a3j8ltl9u5jn78r4lpg6xtsuxvme3
hackernews: https://news.ycombinator.com/item?id=41369083
---

刚开始开发本站的程序时，我就考虑到页面打印的问题。Markdown 转 PDF 有很多种方案，而网页转 PDF 体验就很差了，很多不重要的内容影响了打印效果。无论是打印到纸张还是打印到 PDF，网页本身的排版功能是完全胜任的。

===

后来拜读了宝硕博客的文章《[如何创建一个打印友好型的网页](https://blog.baoshuo.ren/post/printer-friendly-webpage/)》，他结合示例，列出了一些非常重要的建议和方法。本文尝试对其进行总结和补充。

## @media print 查询

为方便设置打印样式，应当对样式表整体结构进行规划：

```css
/** Base */
:root{
    /* vars */
}
/* and other base styles */

/** Normal */
@media screen {
    /*  */
}

/** print */
@media print {

}
```

把基础样式外的其他定义放在 `@media screen` 中，这样做的好处是，在 `@media print` 中不必再做多余的 reset 和写 `!important`。如果你使用 sass，写起来更加方便：

```scss
article{
    --article-bg-color: #fafafa;
    background-color: var(--article-bg-color);
    font-size: 16px;

    @media screen{
        border: 1px solid #aaa;
    }

    @media print {
        --article-bg-color: #fff;
        print-color-adjust: exact; /* force bg color if need */
        font-size: 12pt;
    }
}
```

## 隐藏非正文内容

比如页面布局中的 header 和 footer，侧边栏，操作按钮等等。可以指定规则来隐藏，或者为其添加工具 class：

```css
.print-only{
    display: none;
}
@media print{
    .no-print{
        display: none;
    }
    .print-only{
        display: block;
    }
}

```

## 超链接

超链接一般有默认颜色，但在黑白打印中，颜色并不明显，所以最好给出下划线样式。而且应当直接显示出实际的链接：

```css
@media print {
  a:not([href^='#'])::after {
    content: ' (' attr(href) ')';
    font-size: 80%;
  }
}
```

同理，还可为 `abbr` 指定显示其 `title` 属性。

```css
@media print{
    abbr[title]:after {
    content: ' (' attr(title) ')';
    }
}
```
 
## 其他媒体内容

比如视频、音频，可以单独添加脚注信息，并提供二维码。使用 `.print-only` 和 `.no-print` 的规则来灵活控制打印的内容。

```html
<video class="no-print"></video>
<img class="print-only"/>
```

还可以扩展超链接的样式为：

```css
@media print{
    a[data-print-content]::after {
        content: " (" attr(data-print-content) ")";
        font-size: 80%;
        color: #666;
    }
    a:not([href^="#"]):not([data-print-content-none]):not([data-print-content])::after {
        content: "(" attr(href) ")";
        font-size: 80%;
        color: #666;
    }
}
```

```html
<video data-print-content=""><video>
<a href="https://google.com" data-print-content-none>https://google.com<a>
```

## 分页

网页打印时也可像文字排版软件一样插入「分页符」，来避免奇怪的分页行为，影响阅读体验。一般来说，大纲标题最好不要与其后面的内容分割在两页中，一些特殊元素比如代码块最好不要被分割在两页中。同时允许我们在页面中的合适的分页位置手动插入元素。

```css
@media print {
    h2,
    h3,
    h4,
    h5,
    h6 {
        page-break-after: avoid;
    }

    .page-break {
        page-break-after: always;
        break-after: page;
    }

    pre,
    blockquote {
        page-break-inside: avoid;
        box-decoration-break: clone;
    }

    p {
        widows: 4;
        orphans: 3;
    }
}
```

写文章时，我们可在页面中加入一个分页元素：

```html
<div class="page-break" />
```

## 结语

可以执行打印预览，看一下本页面的打印效果。或者使用开发者工具，切换激活 `@media print`。这两者是有区别的，浏览器的打印预览大多有一些强制的内部规则，比如忽视背景颜色等。也许，我们并不需要 Markdown 转 PDF 的工具。
