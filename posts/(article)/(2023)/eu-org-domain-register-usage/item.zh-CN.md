---
title: EU.org 免费域名的注册与使用
date: '2023-08-18 00:18'
author: 'dallaslu'
keywords:
    - 免费域名
    - 免费域名注册
    - 免费二级域名
    - nic.eu.org
    - 注册EU.org
    - EU.org注册
published: true
license: CC-BY-NC-SA-4.0
toc:
    enabled: true
taxonomy:
    category:
        - Internet
    tag:
        - EU.org
        - Domain
        - Cloudflare
        - Hostry
---

域名不再是唯一的流量入口途径，除去专业域名玩家之外，仍很多人持续续费持有域名。有些人的博客已经十年未更新，但域名依然健在。可能是在古早互联网沾染的执拗，必须拥有一个域名。从最早的功能有限的免费二级域名，到随时可能被收割的免费顶级域名，使用免费域名似乎总要付出金钱外的某些代价。但也有例外，就是免费域名注册服务 EU.org。本文介绍注册过程以及成功后的基本使用事项。

===

比如我不久前注册成功的 `dallaslu.eu.org`，看起来像是二级域名，实际上却是受到广泛承认的顶级域名[^note:domain-level]。整个注册过程，只需要事先准备好一个邮箱，填写一些表单即可。然后等上三五月，或者一年半载。是的，EU.org 的域名注册周期长短不定的。

## 建立 Contact Information

访问 <https://nic.eu.org/arf/en/contact/create/>，填写表单。

1. E-mail 必须真实有效
2. 建议勾选 `Private (not shown in the public Whois)` 以启用隐私保护
3. 必须勾选 `I have read and I accept the domain policy `
4. 设置足够强度的密码

其他联系信息字段可酌情随意填写。鉴于注册周期是个玄学，可能信息详尽有效会更早获批也说不定呢。点击 Create 按钮后，邮箱中会收到激活信件。

EU.org 的登录账号（Handle[^note:eu-handle]）是根据联系人姓名缩写和编号自动生成的，类似 `DL1216-FREE` 这种。一个联系帐号也对应着一个 Contact。

即使启用了隐私保护，仍可查询到一个 eu.org 域名的 Handle。如果你注册多个用途不同的域名，那么有心人可以通过对比 whois 信息，而意外地发现域名之间的关联。而使用同一个邮箱也可注册多个 Handle，所以，你可以在注册时就做好安排。当然，注册成功后再做变更也没问题， Handle 之间可以自由转移域名。

## 注册域名

登录后点击 New Domain 进入注册界面。

### 查询域名可用性

只需填写表单中的 Complete domain name 字段，比如填入 `dallaslu.eu.org`，然后 Submit 表单。如果界面进入了一个黑色的类 bash 界面进行 NS 检查，说明域名尚可以注册；否则页面中会显示域名不能注册的原因。

### Name Server

EU.org 并不提供默认的 NS，这需要我们自行解决。尽管 Cloudflare 提供了免费的 NS，但其为保证 CDN 等服务开箱可用，只能添加已经成功注册的域名。所以我们选择可添加尚未注册的域名的 hostry.com 作为 NS。

在 hostry.com 注册登录后，进入 SERVICES > Free DNS 菜单，输入刚刚选好的域名，点 CREATE DNS，稍后再点击 CREATE。稍等片刻，状态可用后，回到 EU.org 的申请页面，填写 NS:

    ns1.hostry.com
    ns2.hostry.com
    ns3.hostry.com
    ns4.hostry.com

### 提交验证

点击 Submit，在 NS 检查页面如果出现 Errors 字样，可稍等一会刷新页面确认重新提交表单，直到出现：

    No error, storing for validation...
    Saved as request 20230818xxxxxx-arf-xxxxx

    Done

就算成功提交了注册申请。重复以上过程，可注册多个域名，以我的经验看，同 Handle 申请十几个域名也是可以的。
 
接下来是漫长的等待，以我的经验看，需要三个月。请进入舱冬眠三个月，然后查收邮箱，是否有标题为 `request [20230818xxxxxx-arf-xxxxx] (domain XXXXXXXX.EU.ORG) accepted` 的邮件。

## Cloudflare

一旦注册成功，即可在 Cloudflare 添加站点，需要按的提示，在 EU.org 修改域名的 Name Server，然后等待 Cloudflare 验证。可立即申请 Cloudflare 的免费邮件转发服务，获得一个无限别名的域名邮箱。

如果你打算使用这个域名做网站，不要忘记以下几个步骤：

### 开启 DNSSEC

在 Cloudflare 控制面板中，进入此站点的 `DNS`>`设置`菜单，选择启用 DNSSEC，将 DS 值复制填写到 EU.org 的域名 DNSSEC 表单中保存。

### 开启 HSTS

在 Cloudflare 控制面板中，进入此站点的 `SSL/TLS`>`边缘证书`菜单，启用始终使用 HTTPS；选择启用 HSTS，开启表单中所有开关，并选择最长期限标头为 12 个月，保存。添加 DNS 记录，可指向任何 IP，以保证首页能够访问即可。

访问 <https://hstspreload.org>，填入域名，检查通过后，再次提交。数周之后方能生效。

### 重定向跳转

如果希望域名访问时跳转你已有网站，可在 Cloudflare 控制面板中，进入此站点的`规则`>`重定向规则`菜单，创建一条规则。

注意， HSTS 要求访问 `http://XXXXXXXX.eu.org` 时，先跳转到 `https://XXXXXXXX.eu.org`，所以这里要选择自定义筛选表达式，字段选择 `SSL/HTTPS`，值为开启状态，以保证 http 的访问不会跳转到其他的域名。

重定向规则选择类型为动态，表达式填写为：

```javascript
concat("https://yourdomain.com", http.request.uri.path)
```

如果你希望跳转到自己的社交媒体，则可直接选择静态类型填写网址。保存即可。

## 结语

有人说，地球人都应该建个自己的网站[^everyone-own-website]，这说法尚待商榷。不过在此之前，倒是都应该先注册一个 EU.org 域名。

[^note:domain-level]: 这里采用了“顶级域名”与“二级域名”的通俗意义。
[^note:eu-handle]: EU.org 称呼登录名为 Handle。
[^everyone-own-website]: Amin Eftegarie. [Every person on the planet should have their own website](https://eftegarie.com/every-person-on-the-planet-should-have-their-own-website/). EFTEGARIE. 2023