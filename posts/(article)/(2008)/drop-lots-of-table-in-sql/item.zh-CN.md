---
title: SQL 批量删除表
date: '2008-11-30 00:27'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Discuz
        - SQL

---
情况是这么个情况：在某个装在康盛创想虚拟主机里的站点里，装了康盛创想的 Discuz、Supesite、Ucenter、Ecshop、 SupeV……而且是使用了同一个数据库，导致该数据库里面有300＋表。进一步导致在 phpMyAdmin 里面不能进行表的批量操作（貌似是表太多服务器处理不来？），不能浏览、不能导出。选择导出的后果就是一直返回500错误。而且，这个虚拟主机已经过期，只能考虑在 phpMyAdmin 里导出数据了。

===

问题来了，这个时候我们要删除 Supesite、Ucenter、Ecshop、 SupeV 所产生的所有表。在当前情况下，只能通过类似 `drop table supe_ad` 的语句来删除了。但是，哥哥姐姐们，里面有200个表要删除的。

我感到很恐惧、很绝望。于是一通搜索，找到了这样的办法：

> 在phpMyAdmin中先运行（假设前缀是"cdb_"）：`select concat('drop table ', table_name, ';')from information_schema.tables;where table_name like 'cdb_%'`

原理么，就是按表名前缀找出所有符合的表，并返回文本。而这个文本就是我们打算用来批量删除表的语句。可惜呢，运行不成功，提示最后一句话有错误。我 SQL 很烂，空间过期了不能用脚本来搞。

嘿嘿，懒人有懒人的办法。在康盛创想的这个 phpMyAdmin 里呢，不能在侧栏点击数据库名称，但是可以看到所有表的名称。首先呢，在 phpMyAdmin 里面，鼠标点下侧栏空白处，Ctrl+A ，复制下来。粘贴到本地编辑器里面，我用的是 Ubuntu 里自带的文本编辑器。查找：

> \\n \* 浏览

这里可能在＊好前面有几个空格的。替换为：

> ;\\n

然后编辑一下这个文本的最开始几行和后面几行，去掉无关内容；还有呢，很重要的就是把你想要保留的表的那些句子删掉，这个就比较简单了，眼睛扫一下带 cdb_ 这几行的，鼠标选中删除就可以了。

这样，这个文本就有了类似的格式：

```sql
drop table supe_ad;drop table supe_ads;……drop table ecs_user;
```

嘿嘿，复制到 phpMyAdmin 里面执行这些 SQL 语句，所有不想要的表统统消失了！终于可以用 phpMyAdmin 来导出咯。
