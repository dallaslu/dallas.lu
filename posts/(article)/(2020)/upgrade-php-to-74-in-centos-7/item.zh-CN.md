---
title: CentOS 7 升级到 PHP 7.4
date: '2020-10-19 14:33'
author: 'dallaslu'
license: WTFPL
taxonomy:
    category:
        - Internet
    tag:
        - CentOS
        - PHP

---
最近 WordPress 后台一直提示升级到 PHP 7.4。之前用的 7.1.33 竟然在十个月前就停止支持了。因为 CentOS 默认源中的版本较旧，所以印象中升级 PHP 步骤稍有繁琐。但 Remi's RPM repository 提供了一个向导，步骤非常清晰简单。

===

访问 <https://rpms.remirepo.net/wizard/> 选择系统为 CentOS 7 ，PHP 版本为 7.4.11，安装类型为 Default/Single (simplest way)。接下来按向导操作即可。

如果尚未安装 EPEL 源，请执行：

```bash
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
```

安装 Remi 源：

```bash
yum install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
```

安装 `yum-utils` (yum-config-manager)：

```bash
yum install yum-utils
```

记录和备份当前的 PHP 安装情况

```bash
yum list installed | grep php > /tmp/current-php.txt
cp /etc/php.ini /tmp/php.ini.bak
cp /etc/php-fpm.d/www.conf /temp/www.conf

#...
```

配置源：

```bash
yum-config-manager --disable 'remi-php*'
yum-config-manager --enable   remi-php74
```

Update:

```bash
yum update
```

根据 `/tmp/current-php.txt` 安装 PHP 组件：

```bash
yum install php-a php-b php-c
#...
```

然后重新检查修改 `php.ini` 和 `www.conf`。大功告成！
