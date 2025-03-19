---
title: WISeID S/MIME 证书
date: '2025-03-19 03:19'
license: CC-BY-NC-SA-4.0
taxonomy:
    category:
        - Internet
    tag:
        - Email
        - SSL
---

免费的 S/MIME 证书已经几乎无可选择了。有些已经不再提供免费证书服务，比如 Comodo/emSign；有些厂商只签发有效期3个月的证书，比如 Sectigo，以及 WISeID；有些虽然有效期达一年但强制托管密钥，比如 Actalis/CerSign。如果将目光转向收费的 S/MIME 证书，倒是有非常实惠的选择。

===

## 价格优势

一些相对不贵的证书价格如下表：

| 厂商 | 1年 | 2年 | 3年|
|-----|----|-----|----|
| [ssl.com](https://www.ssl.com/certificates/basic-email-smime-certificates/buy/) | $14 | $21 | $27.99 |
| [Sectigo](https://www.sectigo.com/ssl-certificates-tls/email-smime-certificate) | $15 | $24 | - |
| [Certum](https://shop.certum.eu/certum-s-mime-mailbox.html) | €9.5 | €15 | - |

而 [WISeID](https://wiseid.com/) 家的 S/MIME 证书，是按订阅计划的权限计费的。这个模式让人想起古早时期的 StartCom。

订阅费用只要每年 $1.7 元。尽管 Landing 页面上显示的是 $4.99/年，但在实际下单时的价格的确是 $1.7。

订阅了基本套餐，就可以申请 S/MIME 证书，每次颁发的证书都是2年有效期。理论上讲，可以只订阅一年，申请证书后，在过期之前再重新订阅，大约每年只要不到 $1。

如果你在付费订阅之前，想试用一下，那么在注册之后可直接申请他家的有效期3个月的免费证书。

## 其他特征

只支持 RSA 2048。

## 申请及使用证书

WISeID 同样也将托管密钥作为默认选项。建议切换为上传密钥，然后使用 OpenSSL 手动生成 CSR 文件。

生成密钥文件：

```bash
openssl genpkey -algorithm RSA -out smime_rsa2048.key -pkeyopt rsa_keygen_bits:2048
```

生成 CSR 文件：

```bash
openssl req -new -key smime_rsa2048.key -out smime_rsa2048.csr -sha256
```

申请基本证书时，CSR 的字段信息似乎并不重要；在 Common Name 和 Email 两个字段，写入正确的邮箱地址即可。

获得证书后，手动导出 .p12 文件：

```bash
openssl pkcs12 -export -out smime_cert.p12 -inkey smime_rsa2048.key -in smime_rsa2048.crt -certfile smime_rsa2048.crt
```

如果是在 iOS 上使用，可能还需要手动导入这个中间证书 <http://public.wisekey.com/crt/wcidpersgbca4.cer>。

## 结语

很早以前 Lets Encrypt 论坛上就有关于 S/MIME 的讨论，直到近两年不再有更新。HTTPS 的证书是一次性使用的，可以随时无感更换，所以其有效期可以做到 90 天及更短。但 S/MIME 并不适用，太短的有效期带来的只有麻烦。每个月发邮件不多的日常场合，还是选近乎免费的 WISeID 吧！
