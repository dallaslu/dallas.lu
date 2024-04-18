---
title: Java 文件上传
date: '2009-04-28 23:01'
author: 'dallaslu'

taxonomy:
    category:
        - Ubuntu
        - Internet
    tag:
        - Java

---
最近用到文件上传，遇见几个小问题，隔了几天才解决。包括在 enctype 为 multipart/form-data 的表单中取其他参数，url 传递中文参数等。

===

先说下表单。要想传文件，必须指定表单属性：`enctype=" multipart/form-data"` 。如果还想在这样的表单中添加其他文本域，那么抱歉， `request.getParameter("xxx")` 的办法永远取不到值了。可能你需要查阅所使用的上传组件的 API 文档 (如 [SmartUpload](http://www.cnblogs.com/luwenyan/archive/2008/03/29/1128380.html))，来看看有没有办法了。

但是，我只是期望上传文件的同时得知此文件属于哪个 post 。传这个 post_id ，让我十分无奈 —— 我总不能放在 session 里面吧？

## 用 action 来传递简单参数

最后没辙了，把__参数直接写在表单的 action 里：action="upload?id=1989" __。还真管用。在servlet 的 doPost 方法中 `request.getParameter("id")` 一取一个准儿（时而去到时而取不到，那是见鬼了），没想到这个 Google 不会的问题，就这么解决了。

还是 PHP 简单直观，3个数组就解决了这个问题。很久前曾为这个问题困惑：action中指定url （GET方法）的 POST 表单提交到 servlet 后，触发的是 doPost 还是 doGet 方法？简单测试之后，结果是：__只执行了 doPost 方法__。

现在遇到问题，就受到上面的测试结果影响，干扰了思路 —— 其实无论调用那种方法，其参数 request 是一样的。

## GET 方法传中文参数

我在 Google 上面的问题的时候，发现很多人问这个问题。有人提出了复杂的 JS + Java类来实现。我通常只转下编码就 OK 了啊，这问题没那么复杂吧？

```java
String name = request.getParameter("name");
name = new String ( name.getBytes("ISO-8859-1" ) ,"GBK" );
```

## 文件上传

捎带说一下。使用的是Apache组织的commons项目中的FileUpload。需要下载的有：

<div class="download">
<a href="http://commons.apache.org/downloads/download_fileupload.cgi" title="commons FileUpload -- ( 链接到下载页面，非真实下载链接 )">FileUpload</a>
<a href="http://commons.apache.org/downloads/download_io.cgi" title="commons IO -- ( 链接到下载页面，非真实下载地址 )">IO</a>
</div>

另，还有人[提到用软件去下载 API 网页](http://xiaoduan.blog.51cto.com/502137/137909)，其实上面的压缩包里就有了文档了。安排好 jar 包之后，就可以测试一下了。

```html
<!– file.html –>
<form action="upload.jsp" enctype="multipart/form-data" method="post">
<input type="file" name="upload" />
<input type="submit" />
</form>
```

Jsp 比较方便，如果在 servlet 中应用记得捕获异常。建立好 upload 文件夹来存文件。

```jsp
<!– upload.jsp –>
<%@ page pageEncoding=”gbk” %>
<%@page import=”org.apache.commons.fileupload.DiskFileUpload” %>
<%@page import=”java.util.List” %>
<%@page import=”org.apache.commons.fileupload.FileItem” %>
<%@page import=”java.io.File” %>
<%
	DiskFileUpload upload = new DiskFileUpload();
	List list = upload.parseRequest(request);
	for (int i = 0; i < list.size(); i++) {
 		FileItem item = (FileItem) list.get(i);
 		item.write(new File(request.getRealPath("/upload"), item.getName()));
 	} %>
```
