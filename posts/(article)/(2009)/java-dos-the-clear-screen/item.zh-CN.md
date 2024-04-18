---
title: Java Dos 清屏
date: '2009-04-05 00:57'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - DOS
        - Java

---
学习 Java 的过程中，经常编个控制台程序来做些测试。在命令行里运行Java程序时，清屏真是个麻烦的事情。但是不清屏，这程序实在没法看。最后还是实现了，哈哈。

===

先讲如何使用。

<div class="download file-archiver file-rar">
<a href="http://file.dallas.lu/2009/04/cls.rar">下载 cls.rar</a>

只适合 Windows 系统。

</div>

解压之后得到 CLS.class  和 cls.dll 。把两者放到同一文件夹下（比如跟你的 class 文件放到相同目录）。在你的程序中需要清除屏幕输出时，调用方法 `CLS.CLS()` ，即可实现。

<a href="https://file.dallas.lu/2009/04/cls.jpg" rel="lightbox[800]">

<img alt="cls" class="alignnone size-full wp-image-802" height="217" src="https://file.dallas.lu/2009/04/cls.jpg" width="253"/>

</a>

这个是演示，Java 程序刚刚启动时候的效果。

下面开始扯淡。

## 哥，你这是刷屏

刚遇到这问题时候 Google 了半天。在某论坛也有人问这个问题。某人回答到：
>  输出100个换行试试？
然后另一人回复：
>  我怎么觉得你这不是清屏，像是刷屏呢？
哈哈，当时我就笑喷了。说点正经的，有个方法多数人都提到过，但是不管用：

## Runtime

比如下面两种办法：

```java
Runtime.getRuntime().exec("cmd   /c   cls");

Runtime.getRuntime().exec("exec.bat");//批处理之中有一句 cls
```

第一个办法打开了一个新的 DOS 窗口，并没有实现原窗口清屏。第二种我试了几次，完全没有效果。

## JNI

这个还是很靠谱的，虽然有点大材小用了。之前也见有人提到挂载 DLL 文件来实现，但还是一头雾水。直到找到了《<a href="http://forums.devshed.com/java-help-9/java-and-the-dos-cls-command-140998.html" rel="noopener noreferrer" target="_blank">Java and the DOS "CLS" command</a>》这篇文章。

其实如果你装好了 JDK 和 VC++，直接按照文中所描述的办法就OK 了。我做了些许改动。先建立 CLS.java：

```java
public class CLS {
static {
System.loadLibrary("cls");
}
public native static void CLS();
}
```

编译过后，执行 `javah CLS` 来获得 CLS.h 。接着同文件夹下建立 c.cpp ：

```cpp
#include
#include "CLS.h"
#include 

JNIEXPORT void JNICALL Java_CLS_CLS(JNIEnv *, jclass){
system("cls");
}
```

好了，来执行个命令编译：

`cl -IC:\j2sdk1.4.2\include -IC:\j2sdk1.4.2\include\win32 -LD c.cpp -cls.dll`

这个 `C:\j2sdk1.4.2` 换成你的 JDK 安装目录。然后我们就拿到 CLS.class 和 cls.dll 了。

## 背后的血泪

我先是试了几张光碟，好在有没划坏的。重新装了一下 VC++，结果丫提示我安装没成功。我一看，还真是，环境变量没设置。更糟糕的是，我装的是 java 1.6，竟然没找到 JDK 目录，现从另外机器把一堆头文件拷贝过来的。接着把所有需要的头文件、库文件统统拷贝到 C:\Program Files\Microsoft Visual Studio\VC98\Bin 目录，把各文件中的 #include &lt;*.h&gt; 都改成了 #include "*.h" ，嘿嘿，虽然费劲，也编译成功了。

## Linux 怎么办？

我记得，在 Ubuntu 终端里面，Ctrl+H 是清屏——不过是伪清屏，不过是把滚动条拉下来而已。

记得要编译成 cls.so。

不琢磨了，睡觉去。
