---
title: Press博客的评论系统的选择
date: '2023-08-25 08:25'
published: true
license: CC-BY-NC-4.0
toc:
  enabled: true
taxonomy:
  category:
    - Internet
  tag:
    - Blog
    - Comment
    - WordPress
    - Grav
    - Nostr
keywords:
  - 博客评论系统
  - 第三方评论系统
  - 嵌套评论
  - Nostr 评论
  - Webmention
---

三个月前开始用上自己开发的博客程序 Press，关于评论系统有过很多设想，目前的实现是一个表现非常传统的支持嵌套的内置评论。本文列举评论系统常见的实现方式，并进行浅显地探讨。

===

随着博客不再流行，评论系统也没人太过在意了。很多人在放弃使用 WordPress 之后，干脆放弃了传统的评论系统，转而使用其他方式作为与读者沟通的渠道。下面先回顾一下现有的实现方式。

## 现有的实现方式

### 传统评论系统

可免登录发布评论，只要填写邮箱和昵称，首次评论时可能需要站方审核。WordPress 中还常配合同门产品 Gravatar，根据邮箱获取到用户提前设定的头像。因为无需身份验证，导致 Spam 肆虐，常常需要手动审核，或者使用过滤插件。

这种不严格认证的作派，也与中国大陆的监管政策冲突。比如煎蛋网（WordPress），曾经主动关闭吐槽功能[^jandan-close-comment]，后来采取了限制措施，要求登录才能发表内容。

但仍有大量网站采用这种评论方式，如 [土木坛子](https://tumutanzi.com)（WordPress）、[Tualatrix](https://imtx.me)（非 WordPress），[阮一峰](https://ruanyifeng.com)（Movable Type）等。

#### Trackback/Pingback

一直被 Spam 滥用，因此，一些小白教程里面建议禁用掉。

### 第三方评论系统

如 Disqus、多说、Cusdis等。通过引入一个 JS 脚本，可以为任何页面提供评论功能。Disqus 非常有名，我在十年前就使用过，但最终一些问题放弃了[^quit-disqus-2013]。

至今仍有大量网站使用，比如 [Sukka](https://blog.skk.moe)（Next.js）。但我浏览了其最新文章的评论区，仍然显示着「评论基础模式加载失败，请 重载 或 尝试完整 Disqus 模式」的提示。

多说曾经广受欢迎，但早已在 2017年5月关闭。

### 自建第三方评论

第三方评论系统好处很多，自建版就更好了，不过有些技术门槛和运营成本。

如[罗磊](https://luolei.org)、[烧饼博客](https://u.sb)（Next.js）采用了自建 [Artalk](https://artalk.js.org)。有意思的是，烧饼博客的自建评论系统屏蔽了大陆的访问[^note:shou-si-403]，或许是出于保持ICP备案的目的吧。

[Cusdis](https://cusdis.com/)也支持自建。有意思的是，其作者的博客目前是关闭评论状态。

### 关闭评论

博客盛行的时代，有人只当笔记用，并不关注与读者的沟通，如好记性不如烂笔头[^note:lan-bi-tou]等。

也有一些评论很多的网站出于其他的考虑，直接关闭了评论功能，如 [我爱水煮鱼](https://blog.wpjam.com)。

### 借用评论

很多静态博客的原始数据就是 Markdown 文本，非常适合在 Github 托管，便于共同创作和堪误。更有人采用了 Github Issues 来发布内容，就干脆使用其自带的评论功能，如[BMPI](https://www.bmpi.dev)。[ULyC](https://ulyc.github.io) 也曾采用过这种方式[^note:ulyc-github-issues]。

### Nostr 评论系统

新概念社交媒体协议 Nostr 有一个第三方评论的替代方案 [nocommnet](https://github.com/fiatjaf/nocomment)。凭借 Nostr 本身的技术特色，这个评论系统无需存储，可匿名，也跨站点复用身份。评论内容因签名（还可加入可信时间戳）而具有不可篡改性，评论发布者应该会喜欢。Nostr 网络本身仍陷身于 Spam 泥沼，网站需采取一些预防性的过滤措施。

同时 Nostr 本身也有关于博客功能的提案[^nostr-nip-23]，或许未来最好的方式是把网站内容与评论系统都与其整合起来，但目前尚不够成熟。

### 隐藏评论

如[涛叔](https://taoshu.in)（Pandoc），关于评论有独到见解，与诸位读者均单线联系，对话姿势扁平化，采取了评论不公开、仅手动引用精选评论的做法。这一点非常像传统杂志的「来信选登」栏目。保持有限的沟通，将注意力集中在内容上。

### Webmention

[KAIX.IN](https://kaix.in)（Hugo）采用的评论方式，像是一种自动验证Trackback，曾经咨询过站长，大概是叫做「 Webmention」之类的名字。如果你想对其文章作出回应，则可先写一篇文章，然后将有链接到原文的文章网址帖回原文的回应处即可。

### 其他方式沟通

另有一些站点不提供任何评论功能，但留下了联系方式，可能是在线联系表单，或者邮件[^liufacai]、Telegram等。

## 选择传统评论

除去短暂地用过一段时间的 Disqus，我一直在用 WordPress 和 Grav 的原生评论。十几年前就在琢磨如何更好地使用嵌套评论[^wordpress-ajax-comment]。可能习惯使然，在等待 Nostr 成熟之际，还是实现了传统评论，并做了嵌套功能的支持。

为了防 Spam，简单地做了一个陷阱字段，效果还行，新评论系统收到的 Spam 大概就比真实评论多个三五条（0 + 3~5）吧。

一部分精力用在了转换整理历史评论上。这个体现出了不用第三方的一种好处，原始数据在自己手里。目前还能找到 2009年的评论数据。

### 一些可能的改进

* 评论提交后，同发布者发送邮件，一来可以通知、存档，二来提供一个可选的验证链接
* 验证身份后可在后续会话中保存 Token
* 增加筛选条件，来自未验证发布者的内容进入审核队列
* 异步提交，提高速度
* 投票等互动

未来还可能会引入整合在一起的多种形式的评论。

另外还有一点，非常重要，就是超大量评论性能的改进，当然目前的评论量还不到时候（进度大约是 0%），希望这一功能可以早日安排上 :)

[^quit-disqus-2013]: Dallas Lu. [《Disqus 插件版中的两个问题》](https://dallas.lu/disqus-plug-in-version-two-questions/). 2013
[^nostr-nip-23]: [NIP-23 Long-form Content](https://github.com/nostr-protocol/nips/blob/master/23.md)
[^note:lan-bi-tou]: 「好记性不如烂笔头」（www.lirui.name）是Google Reader 时代小有关注度的一个博客，话题集中在 Ubuntu 的使用等方面，使用 WordPress 搭建。
[^note:shou-si-403]: 使用大陆的 HTTP 检查工具得到了 403 的状态码 <https://tool.chinaz.com/pagestatus/?url=https%3A%2F%2Fshou.si>
[^note:ulyc-github-issues]: Ulyc 目前采用了第三方评论系统 Cusdis。在 Github 上仍有旧文的 Issue，如[2021年，用更现代的方法使用PGP（上）](https://github.com/UlyC/UlyC.github.io/issues/3)，最新评论停留在 2022年3月。而目前网站文章页面的最早评论出现在 2023年1月。
[^jandan-close-comment]: [如何评论煎蛋网关闭评论](https://www.zhihu.com/question/332681487). 知乎
[^liufacai]: 刘家财. [《评论系统迁移》](https://liujiacai.net/blog/2022/10/29/byebye-disqus/). 刘家财的个人网站. 2022. 「有价值的评论少之又少，那还不如不提供评论系统，读者直接通过邮件来与博主沟通」
[^wordpress-ajax-comment]: Dallas Lu. [《WordPress 完美 AJAX 嵌套评论》](https://dallas.lu/wordpress-perfect-ajax-thread-comment/). 2009.