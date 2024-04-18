---
title: 为后台添加标签按钮
date: '2008-12-29 19:58'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - WordPress
        - Skill

---
众所周知，很多文章类插件都需要在撰写的时候添加标签，比方说语法高亮插件 wp-syntax，以及之前介绍的 [下载计数插件](https://dallas.lu/wp-downloadcounter/)。但是这些插件并没有自动在后台编辑器上添加按钮，这需要我们去记忆那些标签，还要手动地输入。不常用的标签会忘记，常用的又懒得输入。这里给出此问题的所有解决方案。

===

今天 <del datetime="2008-12-29T10:32:03+00:00">Souyu</del> Sofish 小朋友<a href="http://www.happinesz.cn/archives/897/" target="_blank">介绍了 Easy2hide</a> 这个欠扁的插件，在那里 <del datetime="2008-12-29T10:32:03+00:00">小黑</del> <a href="http://www.leinky.com/" target="_blank">小墨</a> 同学问怎么在后台编辑器里面加个按钮。给出3个办法。

## 修改 quicktags.js 文件

打开 yourwordpress/wp-includes/js/quicktags.js ， 搜索 `edButtoms[edButtons.length]` 找到：

`edButtons[edButtons.length] =  new edButton('ed_more' ,'more' ,'<!--more-->' ,'' ,'t' ,-1 );`

在下面添加你自己的按钮，比如：

```javascript
edButtons[edButtons.length] =new edButton(
'ed_moreandmore' ,
'moreandmore' ,
'<!--more more-->' ,
'' ,
't' ,
-1 );
```

那个 “ed_more” 就是按钮的 id ，“more”就是显示在后台的名字，“<!--more-->”是标签前缀，接着那个参数因为没有用到后缀而省略了，“t” 是快捷键，“-1”代表此标签不必闭合(可以不写，默认闭合)。

例如，为 wp-syntax 添加按钮，代码如下：

`edButtons[edButtons.length] =  new edButton('ed_syntax' ,'syntax' ,'<pre>' ,'</pre>' ,'' );`

## 使用 AddQuicktag 插件

用这个插件可以很方便地添加很多按钮，适合长期工作在 HTML源代码 编辑模式下的同学。

作者主页介绍说支持 WordPress 2.7 。根据我的测试，这个插件当前版本不支持 WordPress 2.7 ，起码在我用来测试的官方中文版中是这样的。建议你先试试这个插件，如果不成的话请再参考第三种方法。

<a href="http://bueltge.de/wp-addquicktags-de-plugin/120/" target="_blank">作者主页</a>｜<a href="http://downloads.wordpress.org/plugin/addquicktag.zip" target="_blank">直接下载</a>

## 修改插件

这个方法比第一种麻烦点，好处在于不用修改 WordPress 文件，省得升级后还要再次修改重复劳动；还有禁用了某插件之后不会留下一坨没有用处的按钮。这个方法来自上面提到的那款插件。

以 Easy2hide 的代码为例：

```php
<?php
    add_action('admin_footer', 'easy2hide_footer_admin');
    function easy2hide_footer_admin() {
        // Javascript Code Courtesy Of WP-AddQuicktag (http://bueltge.de/wp-addquicktags-de-plugin/120/)?>
        <script type="text/javascript">
            if(e2h_toolbar = document.getElementById("ed_toolbar")){
                easy2hideNr = edButtons.length;
                edButtons[easy2hideNr] =new edButton('ed_easy2hide' ,'easy2hide' ,'<!--easy2hide start-->' ,'<!--easy2hide end-->' ,'h' );
                var easy2hideBut = e2h_toolbar.lastChild;
                while (easy2hideBut.nodeType != 1){
                    easy2hideBut = easy2hideBut.previousSibling;
                }
                easy2hideBut = easy2hideBut.cloneNode(true);
                easy2hideBut.value = "easy2hide";
                easy2hideBut.title = "Insert Hidden Words";
                easy2hideBut.onclick = function () {
                    edInsertTag(edCanvas,parseInt(easy2hideNr));
                }
                e2h_toolbar.appendChild(easy2hideBut);
                easy2hideBut.id = "ed_easy2hide";
            }
        </script>
<?php } ?>
```

修改建议就是，用一个有个性地单词（例如 dallasmore），把这里面的 easy2hide 统统替换掉，目的是为了不与现存的东东重名，尤其是 `easy2hide_footer_admin`。

代码中 `new edButton('ed_easy2hide' ,'easy2hide' ,'<!--easy2hide start-->' ,'<!--easy2hide end-->' ,'h' );`，请参考第一种方法自行修改。然后把修改好的代码粘贴到你的__插件主文件的末尾处__，或者是你的__主题中的 function.php 的末尾处__。

-------------手工分割线-------------

最近比较懒，而且还比较忙……睡觉去咯。
