---
title: Nginx 配置 Namecheap 证书
date: '2011-11-17 23:42'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Namecheap
        - Nginx
        - SSL

---
这年头，SSL 应用真是太广泛了——不仅仅是电子商务，连写个博客、建个论坛也会有人上个SSL——中国的网民们被活生生地逼成了一个个的网络工程师；自从有了GFW以后，劳苦大众的计算机知识水平与日俱增，上个小网页各种SSH、VPN，和米国等发达帝国国民大范围使用类似 iPad 等拥有傻瓜界面的数码产品形成鲜明对比。

===

话说回来，在 Namecheap 注册域名可以以$1.99购得一个SSL证书，难得有博客话题，就凑成一篇。

## 生成CSR文件

下载 openssl for windows 安装文件：<http://xiazai.zol.com.cn/detail/39/389798.shtml> 并安装。打开命令行窗口，并切换到C:\OpenSSL\bin 目录下，依次执行：

`set OPENSSL_CONF=openssl.cfg`
`openssl req -new -nodes -sha256 -newkey rsa:2048 -keyout xxx_com.key -out server.csr`

![命令提示行](https://file.dallaslu.com/2011/11/cmd.png)

在这一命令执行的过程中，系统会要求您填写如下信息：

1.   Country Name (2 letter code):使用国际标准组织(ISO)国码格式，填写2个字母的国家代号。中国请填写CN。
2.   State or Province Name (full name): 省份，比如填写Shanghai
3.   Locality Name (eg, city): 城市，比如填写Shanghai
4.   Organization Name (eg, company): 组织单位，比如填写公司名的拼音
5.   Organizational Unit Name (eg, section): 比如填写IT Dept
6.   Common Name (eg, your websites domain name):  SSL 加密的网站地址。请注意这里并不是单指您的域名，而是直接使用 SSL 的网站名称 例如:pay.abc.com。 一个网站这里定义是：abc.com 是一个网站； <a href="http://www.abc.com/" target="_blank">www.abc.com</a> 是另外一个网站； pay.abc.com 又是另外一个网站。 注意：这个服务器域名应该和邮件客户端软件设置的SMTP/POP3服务器名称一致。
7.   Email Address: 邮件地址，可以不填
8.   A challenge password: 可以不填
9.   An optional company name:可以不填

于是当前目录下将产生两个文件：server.key 和 server.csr。请妥善保存这两个文，尤其不要泄露server.key私钥文件，应该像保存自己的艳照一样，不对，不能像艳照一样发给任何人看。

## 申请证书文件

登陆 namecheap.com，并打开菜单中的，SSL CERTIFICATES&gt;Your SSL certificates。

![Namecheap 证书产品菜单](https://file.dallaslu.com/2011/11/namecheap.png)

单击SSL产品列表中对应的Active Now 链接，在新页面的表单中，将Select Web Server 选为 other，并在下面粘贴server.csr的内容，并单击 next。

确定登陆信息并选择一个可以收到邮件的邮箱（没有？快去Google Apps 和 QQ 域名邮箱申请一个，并开通对应用户名的账号），单击next。再次确认接收域名证书的邮箱，和订单联系人信息，单击 Submit Order 按钮。

稍后查看邮箱，即可看到名为ORDER #000000 - Domain Control Validation for xxx.com的邮件，单击“here”，并将下方的验证码粘贴在打开的页面中并单击 next。很快，你将收到包含证书附件的邮件。

## Nginx主机配置 SSL

将邮件附件中的 zip 压缩包解压，并将其中的四个文件上传到服务器中的 /usr/local/nginx/conf 目录下。

合并 PositiveSSLCA.crt （证书签发机构的 crt） 和 jungehost_com.crt (自己域名的 crt)

`cat  xxx_com.crt &gt;&gt; PositiveSSLCA.crt`
`mv PositiveSSLCA.crt  xxx_com.crt`

或者直接用记事本打开，然后复制 PositiveSSLCA.crt 里面所有的内容到 xxx_com.crt 最下方即可。

在虚拟机中添加 SSL 证书支持：

```nginx
ssl on;
ssl_certificate xxx_com.crt;
ssl_certificate_key jungehost.pem;
...
fastcgi_param  HTTPS on;
```

最后代码如下：

```nginx
server
{
listen      443;
server_name jungehost.com www.jungehost.com;
index index.html index.htm index.php;
root  /home/wwwroot/jungehost;

ssl on;
ssl_certificate xxx_com.crt;
ssl_certificate_key xxx_com.key;

location ~ .*\.(php|php5)?$
{
fastcgi_pass  unix:/tmp/php-cgi.sock;
fastcgi_index index.php;
fastcgi_param  HTTPS on;
include fcgi.conf;
}
access_log  off;
}
```

好了，重新载入 nginx 即可。

参考：[www.jungehost.com](http://www.jungehost.com "http://www.jungehost.com")
