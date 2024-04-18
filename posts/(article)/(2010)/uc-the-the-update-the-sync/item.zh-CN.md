---
title: UC 修改密码同步到其他应用
date: '2010-12-15 13:52'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Discuz
        - Uc

---
最近在做网站与UC整合和工作。这个工作的难点在于，我们希望在自己的网站中保存用户密码。UC原本的机制中，并没有在注册和修改用户资料时，向应用发送密码信息。

===

先是在论坛中找到了一个贴子：[修改密码后同步到其他应用](http://www.discuz.net/thread-1696726-1-1.html)。

>  discuz修改密码后将修改密码和email的信息通过ucclient传递给ucenter，ucenter在收到消息后将消息存入cdb\_uc\_notelist表，而后从cdb\_uc\_notelist取出一条close为0的记录，逐一向各个应用发送修改密码的通知。各位朋友在调试时记得核对下表cdb\_uc\_notelist中是否有多条close为0的记录影响调试。

<div class="notice">适用于程序版本：UCenter 1.5.2 Release 20101001</div>

## Ucenter 修改密码同步到其他应用

修改 uc_server/control/admin/user.php

```php
$_ENV['note']->add('updatepw', 'username='.urlencode($username).'&password=');
```

为

```php
$_ENV['note']->add('updatepw', 'username='.urlencode($username).'&password='.urlencode($orgpassword).'&email='.urlencode($email));
```

## Discuz 修改密码同步到其他应用

修改 uc_client/control/user.php 100行

```php
$_ENV['note']->add('updatepw', 'username='.urlencode($username).'&password=');
```

为

```php
$_ENV['note']->add('updatepw', 'username='.urlencode($username).'&password='.urlencode($newpw).'&email='.urlencode($email));
```

这样，在第三方应用中，就可以利用 API 来获取其他应用中修改的明文信息了。
