---
title: How to write print styles for web pages
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
  - 'print styles'
  - '@media print'
  - 'webpage to pdf'
  - 'markdown to pdf'
toc:
  enabled: true
x.com:
  status: https://x.com/dallaslu/status/1783896218814517522
nostr:
  note: note1jkfut2kx6xv68d03h44cl02czwdk3a3j8ltl9u5jn78r4lpg6xtsuxvme3
---

Just started the development of this site's program, I have considered the issue of page printing. Markdown to PDF has a variety of options, and the web page to PDF experience is very poor, a lot of unimportant content affects the printing results. Whether you print to paper or to PDF, the layout of the page itself is fully capable.

===

Then I read the article "[How to Create a Print-Friendly Web Page](https://blog.baoshuo.ren/post/printer-friendly-webpage/)" on Baoshuo's blog, and he listed some very important suggestions and methods with examples. This article tries to summarize and add to them.

## @media print Query

The overall structure of the style sheet should be planned in order to facilitate the setting of print styles:

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

The advantage of putting definitions other than the base style in `@media screen` is that you don't have to do the extra reset and write `!important` in `@media print`. If you're using sass, it's even easier to write:

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
        font-size: 12pt;
    }
}
```

## Hide non-text content

For example, headers and footers, sidebars, action buttons, etc. in the page layout. You can specify rules to hide them or add a tool class to them:

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

## Hyperlink

Hyperlinks generally have a default color, but in black and white printing, the color is not obvious, so it is best to give an underline style. And the actual link should be shown directly:

```css
@media print {
  a:not([href^='#'])::after {
    content: ' (' attr(href) ')';
    font-size: 80%;
  }
}
```

Similarly, `abbr` can be specified to display its `title` attribute.
 
## Other media content

Video and audio, for example, can be added separately with footnote information and a QR code. Use `.print-only` and `.no-print` rules to flexibly control what is printed.

```html
<video class="no-print"></video>
<img class="print-only"/>
```

It is also possible to extend the style of hyperlinks as:

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

## Page

Page breaks can also be inserted when printing web pages, just like text layout software, to avoid strange page breaks that may affect the reading experience. Generally speaking, it is better not to split the outline title with its following content in two pages, and some special elements such as code blocks are better not to be split in two pages. We are also allowed to manually insert elements at appropriate page breaks in the page.

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
    }
}
```

When writing an article, we can add a pagination element to the page:

```html
<div class="page-break" />
```

## Conclusion

You can perform a print preview to see how this page will print. Or you can use the developer tools and toggle the activation of `@media print`. There is a difference, most of the browser print previews have some mandatory internal rules, such as ignoring the background color and so on. Maybe, we don't need Markdown to PDF tool.
