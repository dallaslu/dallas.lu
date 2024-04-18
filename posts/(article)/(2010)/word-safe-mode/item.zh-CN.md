---
title: Word安全模式启动解决办法
date: '2010-12-31 10:34'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Word

---
这个问题困扰我很久，双击WORD文档时，程序提示“正在处理的信息有可能丢失……是否以安全模式启动WORD”。如果选择以安全模式启动WORD，而只显示空白 窗口，需要重新打开文档才行。

===

![](word.png)

解决办法：

WIN徽标键+R，输入CMD，执行命令：

```cmd
del "Application Data"\Microsoft\Templates\Normal.dot
```
