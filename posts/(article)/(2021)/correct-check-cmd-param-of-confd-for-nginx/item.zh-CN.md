---
title: Confd 管理 Nginx 配置的正确 check_cmd 参数
date: '2021-01-15 23:35'
author: 'dallaslu'
license: CC-BY-NC-SA-4.0
taxonomy:
    category:
        - Program
    tag:
        - Confd
        - Nginx
keywords:
  - Confd 配置检查
  - Confd 错误
  - Confd 不生效
  - Confd Nginx
  - Confd check_cmd
---
最近在使用 Confd 管理配置的过程中，发现很多文章都使用了错误的 `check_cmd` 配置。

===

## 检查 Confd 生成的临时文件

例如，有人使用了这样的配置：

```ini
# ...
dest = "/etc/nginx/nginx.conf"
check_cmd = "/usr/sbin/nginx -t"
```

Confd 会在写入目标文件前，执行 `check_cmd` 配置的命令进行检查，但是 `nginx -t` 并不能检测到刚刚生成的临时文件。会导致以下情况：

1. 如果 Nginx 的当前文件包含了错误，那么检查永远不通过；也就意味着 Confd 生成了正确的文件也不会生效，除非手动干预来修正 Nginx 当前文件中的错误。
2. 如果 Nginx 的当前文件不包含错误，那么检查肯定是通过的；也就意味着即使 Confd 生成了错误的文件，也会写入到目标文件中；下一次生成配置文件时，会导致情况 1 发生。

所以正确的写法应该是：

```ini
dest = "/etc/nginx/nginx.conf"
check_cmd = "/usr/sbin/nginx -t -c {{.src}}"
```

`{.src}` 就是 Confd 生成的最新文件的临时路径，与 `dest` 在相同目录，比如可能是 `/etc/nginx/.nginx.conf123456789` (123456789 是一个随机的数字)。

## 目标非 `/etc/nginx/nginx.conf` 的情况

如果 `dest` 是一个被 Nginx include 的文件，会发生什么呢？

```ini
# ...
dest = "/etc/nginx/conf.d/proxy.conf"
check_cmd = "/usr/sbin/nginx -t -c {{.src}}"
```

假设最终生成的 proxy.conf 内容是：

```nginx
upstream a {
    server 192.168.1.1;
}
server{
    listen 80;
    server_name _;
    location /{
        proxy_pass http://a;
    }
}
```

最终执行的检查命令可能是：

```bash
/usr/sbin/nginx -t -c /etc/nginx/conf.d/.proxy.conf123456789
```

不出意外，还是永远检查失败。因为检查时把 `-c` 的参数当作是唯一的配置文件，配置文件里并没有 `http`；如果还用了 `include`，那么多半还会提示找不到文件错误。

这里存在两个问题，一是配置文件不完整，二是相对路径有错。

所以合理的做法应该是：为 `.proxy.conf123456789` 补充缺失的语句，并复制到 `/etc/nginx`，然后再调用 `nginx -t -c /etc/nginx/.proxy.conf123456789`。

下面是一个经过验证的正确工作的例子：

```ini
check_cmd = "TMP=/etc/nginx/$(basename {{.src}}).tmp && echo 'events{}http{' > $TMP && cat {{.src}} >> $TMP && echo '}' >> $TMP && (nginx -t -c $TMP; R=$?; rm -f $TMP; exit $R)"
```

具体过程是，将 `/etc/nginx/conf.d/.proxy.conf123456789` 用 `events{}http{` 和 `}` 包裹，输出到 `/etc/nginx/.proxy.conf123456789.tmp` 中，校验后删除这个临时文件。
