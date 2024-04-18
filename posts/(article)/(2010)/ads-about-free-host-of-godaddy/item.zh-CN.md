---
title: GoDaddy 的免费空间
date: '2010-04-14 10:43'
author: 'dallaslu'
published: false

taxonomy:
    category:
        - Internet
    tag:
        - Godaddy
        - Skill

---
话说，在 GoDaddy 注册域名之后都可以申请一个免费的空间，但是会在每个页面强制添加广告。空间大小10G，月流量300G。作为免费用户，被加了广告也没啥说的，但是，这个广告每次在页面加载后把网页的内容挤到下面去，自己占用了页首 100px 的位置，实在不爽。

===

其广告代码为：
>  &lt; script language='javascript' src='https://a12.alphagodaddy.com/hosting\_ads/gd01.js'&gt;&lt; /script&gt;
网络上流传的三种屏蔽广告的方法如下：
>  
> 
> #### 方法一：在页面最后加
> 
> &lt;script&gt;可以完全去掉广告,在需要去广告的页面后面加该标记后，广告代码加入后就成为：&lt;script&gt;中间可以有非Java内容&lt; script language='javascript' src='https://a12.alphagodaddy.com/hosting\_ads/gd01.js'&gt;&lt; /script&gt;这就造成广告代码匹配出现错误，从而阻止了广告代码的执行。这种方法完全去除了广告的影响，可以大大提升页面显示速度，是目前最好的方法，我用的就是这一种。不足之处是可能导致空间被K，为了尽量避免其发生，建议保留部分页面的广告。
> 
> #### 方法二：在文件结尾处加入
> 
> &lt;noscript&gt;可以完全去掉广告。原理和方法一差不多，阻止后面的广告代码的执行，效果和可能导致的后果也完全一样。
> 
> #### 方法三：文件的开头加入
> 
> &lt;div style= "margin-top:-94" &gt;在末尾加入&lt;/div &gt;这种方法是让页面顶端的部分内容不显示出来，由于顶端是加的广告，所以可以起到隐藏广告的作用。隐藏内容的高度为：９４，可以修改-94的大小适应广告的高度直到隐藏广告。使用这种方法是隐藏广告不是删除广告，广告仍然存在只是看不到了，所以空间应该不会被K。不足之处是，广告仍然被载入，所以广告对页面显示速度的影响没有消除。
要知道，如果被K的话，可是连空间带域名都废废了，虽然 GoDaddy 会反给你域名钱。

所以只有第三种方法靠谱点。但是有个小问题是一开始载入的时候网页的位置是有问题的，直到广告加载完毕才正常。而且，经我测试这种方法已经失效了。

貌似最近<a href="http://ishawn.net/essay/what-is-optimize-user-experices.html" target="_blank">一直都在讲用户体验</a>，所以呢，嘿嘿，我想出了个办法，既不违反 GoDaddy 的规则，又能让访问者能一直看到正常的页面。

大家知道 HTML 有锚点一说，我们在页面内容里的 div 里搞个锚点，然后按 url#id 的方式来跳转。还是举例子来讲吧。

米国人真是浪费呃，一个免费空间也有10G，谁用得完。所以捏，我搞了个上传程序放在免费空间上了。

继续讲锚点。我这里在页面内容最上面的 div 的 id 是 logo，那么怎样做到访问首页时即能跳转到此呢？

我的办法是在网站根目录下建立 .htaccess 文件，内容如下：
>  &lt;IfModule mod\_rewrite.c&gt;RewriteEngine OnRewriteRule / http://domain.com/\#logo \[L,R\]&lt;/IfModule&gt;
嘿嘿，我太有才了……
