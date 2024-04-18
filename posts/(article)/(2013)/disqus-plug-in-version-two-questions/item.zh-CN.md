---
title: Disqus 插件版中的两个问题
date: '2013-09-05 20:24'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - Disqus

---
WordPress 的评论链接默认是以 #comments 结尾，而 Disqus 插件会替换掉系统应用，生成一个 id 为 disqus_thread 的 div 来显示评论内容。这就导致点击评论链接，不能通过锚点定位到评论系统。只能在 Disqus 的设置中的 Intsall 选项中，获取代码手动为 WordPress 添加评论系统，才能解决这个问题了；在一些论坛中提到的，可设置 HTML 的 Disqus 选项可能已经被官方移除了。

第二个问题是，Disqus 评论系统加载时引用一个文件，地址是：http://mediacdn.disqus.com/1378324593/fonts/next/embed-icons.woff。这个链接以 http 开头，导致使用了 SSL 证书的博客在浏览器中有不安全的提示。这是由 Disqus 提供的脚本代码中引用的路径，应该没有办法取消了。

综上，再一次禁用了 Disqus 评论插件。
