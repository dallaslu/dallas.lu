---
title: The correct check_cmd parameter of Confd for Nginx configurations.
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
  - Confd Config Check
  - Confd Error
  - Confd Not Work
  - COnfd Nginx
  - Confd check_cmd
---
Recently, while using Confd to manage configurations, I realized that a lot of articles were using the wrong `check_cmd` configuration.

===

## Check the temporary files generated by Confd

For example, some people use a configuration like this:

```ini
# ...
dest = "/etc/nginx/nginx.conf"
check_cmd = "/usr/sbin/nginx -t"
```

Confd will run the `check_cmd` configured command to check before writing to the target file, but `nginx -t` does not detect the temporary file just generated. This results in the following scenario:

1. if Nginx's current file contains errors, then the check never passes; this means that even if Confd generates the correct file, it will not take effect unless it manually intervenes to fix the errors in Nginx's current file.
2. if Nginx's current file does not contain an error, then the check must pass; this means that even if Confd generates the wrong file, it will be written to the target file; the next time a configuration file is generated, this will cause case 1 to occur.

So the correct way to write it would be:

```ini
dest = "/etc/nginx/nginx.conf"
check_cmd = "/usr/sbin/nginx -t -c {{.src}}"
```

`{.src}` is the temporary path to the latest file generated by Confd, in the same directory as `dest`, e.g. it might be `/etc/nginx/.nginx.conf123456789` (123456789 is a random number).

## Target non-`/etc/nginx/nginx.conf` cases

What happens if `dest` is a file that is included by Nginx?

```ini
# ...
dest = "/etc/nginx/conf.d/proxy.conf"
check_cmd = "/usr/sbin/nginx -t -c {{.src}}"
```

Let's assume that the contents of the final proxy.conf generated are:

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

The final executed check command may be:

```bash
/usr/sbin/nginx -t -c /etc/nginx/conf.d/.proxy.conf123456789
```

Unsurprisingly, the check will always fail. This is because the check takes the `-c` parameter as the only configuration file, and there is no `http` in the configuration file; if `include` is also used, you will most likely get a file not found error.

There are two problems here, one is that the configuration file is incomplete and the other is that the relative path is wrong.

So the logical thing to do would be to add the missing statements for `.proxy.conf123456789` and copy them to `/etc/nginx` before calling `nginx -t -c /etc/nginx/.proxy.conf123456789`.

Here is a verified example that works correctly:

```ini
check_cmd = "TMP=/etc/nginx/$(basename {{.src}}).tmp && echo 'events{}http{' > $TMP && cat {{.src}} >> $TMP && echo '}' >> $TMP && (nginx -t -c $TMP; R=$?; rm -f $TMP; exit $R)"
```

The process is to wrap `/etc/nginx/conf.d/.proxy.conf123456789` with `events{}http{` and `}`, output it to `/etc/nginx/.proxy.conf123456789.tmp`, verify it, and then delete this temporary file.
