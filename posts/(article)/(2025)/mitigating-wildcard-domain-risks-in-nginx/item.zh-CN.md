---
title: Nginx 泛域名配置的隐患与对策
date: '2025-05-23 05:23'
license: CC-BY-NC-SA-4.0
taxonomy:
    category:
        - Internet
    tag:
        - Nginx
        - Domain
        - SSL
---

一个网站的程序支持多站点模式，于是为了方便，在 Nginx 中绑定了域名 `*.example.com`，但奇怪的是，访问记录中总是有一些奇怪的二级域名，让人隐约觉得不妥。本文记述使用 Nginx 的来规避类似的风险。

===

## Wildcard 域名绑定

原本的 Nginx 大约如下：

```nginx
server {
    listen 80;
    server_name *.example.com;

    // blabla
}
```

这样配置简单方便。不过如果你的网站并不是多站点模式，或者网站程序未能恰当地处理，会导致任意二级域名却都能正常访问网站内容，是有点奇怪的。也许有人故意构造并发布了一个链接，不幸又被爬虫抓取，想想一下，从这个流量来源过来的访客们，纷纷皱着眉头看着你的奇怪的二级域名。这是一个未预期的行为，会影响 SEO，且有一定的合规风险，应当采取一些措施。

如果二级站点数量有限，可以手动列出全部二级域名：

```diff
server {
    listen 80;
-    server_name *.example.com;
+    server_name
+        www.example.com
+        cdn.example.com
+        api.example.com;
}
```

倘若你有更复杂的需要，仍需要保留 `*.example.com` 以简化配置，那么就可以加一个白名单的校验。

!!! 在 Nginx 中 `$server_name` 代表的是 server_name 配置中的第一个值，因此将网站的主域名放在第一位就非常方便后续处理。

如果你曾经使用过 blog.example.com，如今回归到 www.example.com， 那么更合适的办法应该是重定向。而其他未预期的域名都可以使用 `return 444;` 来直接断开连接。

```diff
server {
    listen 80;
-    server_name *.example.com;
+    server_name www.example.com example.com *.example.com;
+
+    if ($host ~* ^((blog|feed|log)\.example\.com|example.com)$) {
+        return 307 $scheme://$server_name$request_uri;
+    }
+
+    if ($host !~* ^(cdn|api)\.example\.com$) {
+        return 444;
+    }
}
```

## 默认主机

除了泛域名绑定之外，默认主机也会有类似的问题。如果在中国大陆，有未备案的域名指向到你的服务器，也有监管的风险。直接让默认主机断开所有连接：

```nginx
server {
    listen 80 default_server;
    server_name _;

    return 444;
}
```

在某些情况下，你可能需要在阻断未指定域名的同时，支持使用 IP 地址直接访问：

```diff
-return 444;
+if ($host !~* "^((?:\d{1,3}\.){3}\d{1,3}|(?:[a-fA-F0-9:]+))$") {
+    return 444;
+}
```

### SNI 域名泄露

在尝试 HTTPS 访问时，即便 Nginx 断开了连接，但客户端仍能够从返回的证书中获取 SNI 域名列表。很多人使用 CDN 全站加速来隐藏真实 IP，被扫描 IP 时，可能就会泄漏服务器与域名的关联。

可以在 server 块中配置，拒绝 ssl 握手：

```diff
+ssl_reject_handshake on;
````

如果你还是希望能够支持使用 IP 地址直接访问……那么，要使用一个 IP 专用的 SSL 证书。IP 证书购买渠道有限，自签一个也是可以的。

生成一个 IPv4 地址的证书：

```shell
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ip.key -out ip.crt \
  -subj "/CN=1.2.3.4" \
  -addext "subjectAltName=IP:1.2.3.4"
```

如果你还希望支持 IPv6……建立自签证书的配置 `openssl-san.conf`

```toml
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = (ip or domain or keep bank)

[v3_req]
subjectAltName = @alt_names

[alt_names]
IP.1 = 1.2.3.4
IP.2 = 2001:db8::1

```

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ip-mixed.key -out ip-mixed.crt \
  -config openssl-san.conf
```

然后配置 Nginx：

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;

    server_name _;

    ssl_certificate /path/to/ip.crt;
    ssl_certificate_key /path/to/ip.key;

    if ($host !~* "^((?:\d{1,3}\.){3}\d{1,3}|(?:[a-fA-F0-9:]+))$") {
        return 444;
    }
}
```

### 避免 CDN 域名被收录


```nginx
    root /path/to/webroot/www.example.com;

    location = /robots.txt {
        default_type text/plain;

        if ($host = 'cdn.example.com') {
            #return 200 "User-agent: *\nAllow: /*.png$\nDisallow: /\n";
            alias /path/to/webroot/www.example.com/robots-cdn.txt;
        }
    }
```
