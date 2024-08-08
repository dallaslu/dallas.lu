---
title: jQuery 验证码插件 QapTcha
date: '2011-10-28 13:51'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - jQuery

---
最近用的欧诺VPS管理面板和caboo的免费VPN发布程序中都见到了这个插件。感觉蛮新潮，恰巧都是在 asp 语言编写的网站上看到，于是就以为是相关社区开发的小控件，从移动设备上借鉴到WEB上的滑动解锁，倒也很有意思。

===

在插件主页中介绍到，该插件是简单易用的“验证码系统”：
>  QapTcha is a draggable jQuery captcha system with jQuery UI !__QapTcha is an easy-to-use, simple and intuitive captcha system.__It needs human action instead of to read a hard text and it is a very lightweight jQuery plugin.
但是实际上，这个插件能否作为验证码来使用很让人怀疑。在插件的[演示界面](http://www.myjqueryplugins.com/QapTcha/demo)，设置了一个表单，需要滑动 QapTcha 插件产生的滑块儿才可以提交表单，并借此防止机器人自动提交。

在常规的图片验证码中，如果机器人想自动提交的话就得花费大量精力在处理验证码识别上。所以为了保证有效阻止机器人，常见的图片验证码都比较复杂，甚至人都很难识别。这个“滑动解锁”的小插件，能否搞定既阻止机器人，又方便人类呢？

通过查看演示页面上的 JS 文件了解了一定原理，尝试在 firebug 控制台中执行以下 JS 代码：

```javascript
$.post('plugins/qaptcha/demo/php/Qaptcha.jquery.php'
	,{action:'qaptcha'}
	,function(data){
		$("input[name='iQapTcha']").val('');
		alert('Now,try to submit!')
	},'json');
```

然后再提交表单：很不幸地，表单提交成功了。所以说，这个插件__没有验证码的作用__，只能作为Javascript 中 confirm 的一个替代方案，只是提升了用户体验，其意义仍然只是提供给用户一个确认机会而已。
