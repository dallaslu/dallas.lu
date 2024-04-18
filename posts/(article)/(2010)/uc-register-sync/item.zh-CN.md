---
title: UC 注册同步实现免激活
date: '2010-12-15 16:05'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Discuz
        - UC

---
同上一篇文章一样，还是要解决UC中的问题，注册用户时通过 API 向第三方应用发送密码。这样第三方应用可以保存新增用户的密码信息，一旦关闭UC支持，仍然可以独立运行。

===

实现原理是在添加用户时，生成一个通知(note)。鉴于UC内置note类型和API中没有为“注册”做支持，我们可以使用修改密码的note：updatepw。在第三方应用的UC客户端中处理 updatepw 通知时，先在本应用内判断用户是否存在，如果不存在则创建一个新用户到本应用中。

## 修改 uc\_server

首先还是对 uc\_server 下手，保证管理在UC后台新增用户时，能够同步到其他用户。在uc\_server/control/user.php 85 行：

```php
$uid = $_ENV['user']->add_user($username, $password, $email, 0, $questionid, $answer, $regip);
```

后面插入：

```php
if($uid > 0) {
			$this->load('note');
			$_ENV['note']->add('updatepw', 'username='.urlencode($username).'&password='.urlencode($password).'&email='.urlencode($email));
			$_ENV['note']->send();
		}
```

uc\_server/control/admin/user.php 170 行：

```php
$uid = $_ENV['user']->add_user($username, $password, $email);
```

后面插入：

```php
if($uid > 0) {
			$this->load('note');
			$_ENV['note']->add('updatepw', 'username='.urlencode($username).'&password='.urlencode($password).'&email='.urlencode($email));
			$_ENV['note']->send();
		}
```

同文件 187 行 或 192 行：

```php
$_ENV['user']->add_user($username, $password, $email);
```

修改为

```php
$uid = $_ENV['user']->add_user($username, $password, $email);
if($uid > 0) {
			$this->load('note');
			$_ENV['note']->add('updatepw', 'username='.urlencode($username).'&password='.urlencode($password).'&email='.urlencode($email));
			$_ENV['note']->send();
		}
```

## 修改 uc\_client

Discuz 中 uc\_client/control/user.php 79行：

```php
$uid = $_ENV['user']->add_user($username, $password, $email);
```

后面插入：

```php
if($uid > 0) {
			$this->load('note');
			$_ENV['note']->add('updatepw', 'username='.urlencode($username).'&password='.urlencode($password).'&email='.urlencode($email));
			$_ENV['note']->send();
		}
```

至此，在第三方应用的 api/uc.php 中依照 UC 接口开发文档，对 updatepw 类型的通知进行适当的判断即可实现UC注册同步到其他应用。
