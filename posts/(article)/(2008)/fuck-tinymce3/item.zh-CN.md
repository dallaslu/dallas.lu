---
title: 折腾编辑器 TinyMCE 3
date: '2008-06-22 11:16'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Drupal

---
为了给Drupal添加一个可视编辑器就浪费了我半个上午的时间。

给大家讲一下，该怎么折腾TinyMCE。

(适用于Drupal 5.x)

所需要下载的文件（前面是下载页面，后面是下载地址）：

* <a href="http://tinymce.moxiecode.com/download.php" target="_blank">Main package</a> [tinymce\_3\_1\_0\_1.zip](http://prdownloads.sourceforge.net/tinymce/tinymce_3_1_0_1.zip?download)
* <a href="http://tinymce.moxiecode.com/download.php" target="_blank">Compressor PHP</a> [tinymce\_compressor\_php\_2\_0\_1.zip](http://prdownloads.sourceforge.net/tinymce/tinymce_compressor_php_2_0_1.zip?download)
* <a href="http://drupal.org/project/tinymce" target="_blank">TinyMCE模块</a> <a href="http://ftp.drupal.org/files/projects/tinymce-5.x-1.9.tar.gz" target="_blank">TinyMCE WYSIWYG Editor</a>

（语言包的问题下面再说）

1.   好了。解压开 TinyMCE 模块，放到 `Drupal` 模块目录里面，最后是这样的路径：`/sites/all/modules/tinymce/`，在这个目录里你会发现有 `tinymce.module`这样一个文件，那就对了。
2.   解压`Main package`，将其放到模块 TinyMCE 目录里面，最后是这样的路径：`/sites/all/modules/tinymce/tinymce/`，在这个目录你会发现有这样一个文件夹 `jscripts`，OK。
3.   解压`Compressor PHP`,把两个文件`tiny_mce_gzip.js`、`tiny_mce_gzip.php`放到`/all/modules/tinymce/tinymce/jscripts/tiny_mce/`。
4.   进入后台，启用模块TinyMCE，设置好模块权限；进入TinyMCE设置，创建一个配置文件，选项不少，英文一般都看得懂，填好配置。
5.   随便找个编辑页面试用一下，基本达到可视化的目的。

但是，鼠标放到那些按钮上显示出的提示却是……

===

参考了<a href="http://www.metalstar.net/?d=86" target="_blank">在线编辑器 TinyMCE 3 的简体中文语言包</a> 这篇文章：

> 在这里可以下载到TinyMCE3的中文包　http://services.moxiecode.com/i18n　下载时注意，是先勾选前面的小方框，再按下方的Download按钮，而不是那个XML。  
> 可 惜是繁体的，我制作了一个简体中文包，因为TinyMCE要求语言代号必须遵守ISO 639-1的国际编码标准，中文的代号只能是zh，而且不分简体和 繁体。为了不覆盖原有的繁体包，我也耍了一下小滑头，将语言包代号写为ch，传了上去。嘿嘿，ch代表的语言是“Chamorro/夏莫洛语”，估计夏莫 洛人暂时还没有用TinyMCE吧，大家要简体中文包就下那个页面中的Chamorro语吧，哈哈。  
> 安装时，将下载的压缩包中的文件解压到javascript/tiny\_mce目录中，提示有同名文件选覆盖即可。  
> 使用时，在页面的tinyMCE初始化语句&nbsp;tinyMCE.init&nbsp;中加上一行&nbsp;language&nbsp;:&nbsp;"ch",　即可（ch前后是单引号）。

不过，有的时候下载到的 “Chamorro/夏莫洛语”还真的是 “Chamorro/夏莫洛语”。那么，先下载一个繁体的XML文件，用文本编辑器打开，第12行，把 `language code="zh"` 改为 `language code="ch"`，保存。下面就是找个能简繁转换的地方，转换为简体中文，我是用 OpenOffice 的，其他的也可以，然后依然保存为 `zh.xml`。好了，现在打开<a href="http://services.moxiecode.com/i18n/" target="_blank">http://services.moxiecode.com/i18n/</a>，最下面有个上传的地方，上传zh.xml。

接下来，下载 “Chamorro/夏莫洛语”语言包，记住先选中语言包前面的复选框，下载按钮在下面。

或者，干脆下载我改好的版本 [tinymce\_lang\_pack](http://file.dallas.lu/2008/06/tinymce_lang_pack.zip) 。不过可能不是最新的哦。

然后根据下面的步骤进行操作：

1. 将语言包解压，把里面的3个目录上传到 `/sites/all/modules/tinymce/tinymce/jscripts/tiny_mce/`，如果你以前传过 “Chamorro/夏莫洛语”语言包，那就直接选择覆盖。
2. 编辑文件 `/sites/all/modules/tinymce/tinymce.module` ，第735行，或者搜索 `zh_cn`，加上 `ch` ，代码类似这样：`'\#options' => drupal_map_assoc(array('ar', 'ca', 'cs', 'cy', 'ch','da', ……`
3. 进入TinyMCE设置，把语言设置为ch。

OK！ 如果你有更新的简体中文语言包，留言告诉我。
