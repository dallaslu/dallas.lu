---
title: Nginx Reverses Apache Subversion 
date: '2022-01-03 00:52'
author: 'dallaslu'
published: true
license: CC-BY-4.0
taxonomy:
    category:
        - Software
    tag:
        - Nginx
        - Apache
        - Subversion
        - Regexp
toc:
  enabled: true
---
Subversion sounds like it's ten years old, especially `mod_dav_svn`. But it's hard to say where the ancestral code is placed. In short, you already have a ready-made Nginx, and you want to add HTTPS support to an already streaking code repository, but it is not a `proxy_pass` can do it.

===

For example: 

```nginx
upstream subversion{
    127.0.0.1:1080;
}
server{
    listen [::]:443;
    server_name svn.example.com;

    # SSL ...

    location / {
        proxy_pass http://subversion;
    }
}
```

First of all, congratulations, you avoided the first pit by not using `proxy_pass http://subversion/`. Because the trailing `/` character will cause Nginx to automatically encode the URL, which affects normal use. But soon you will get a 502 error when submitting.

## COPY and DELETE support 

Subversion considers `https://svn.example.com` to be an HTTPS link, and Apache only provides HTTP services, so the `Destination` in the request header should start with `http://` to work properly.

Soon, you found a way to modify it from Stackoverfollow:

```nginx
location / {
    proxy_pass http://subversion;
    set $fixed_destination $http_destination;
    if ( $http_destination ~* ^https(.*)$ ) {
        set $fixed_destination http$1;
    }
    proxy_set_header Destination $fixed_destination;
}
```

Then found everything OK. Very good, it really fell into the second pit. 

## Nginx's confusing behavior 

`$fixed_destination` looks like just replacing `https://` with `http://`, very simple and clear, no problem.

When you happily copy a new branch from the trunk, modify a file whose file name contains Chinese, compile it smoothly and pass the test; and then merge back into the trunk, if you are careful enough, you will find that the file name is urlencoded. Of course, it's not just including Chinese name files, imagine, but the names of all the files submitted in the branch are urlencoded! And the file name that has been urlencoded will be urlencoded again when the branch is merged next time!

The problem is with `$fixed_destination`. `http$1` is actually urlencoded by Nginx. Maybe you decided to leave the modification of `Destination` to Apache, or decided to write a lua script to decode it, to avoid this magical problem. Wait a minute! Here's another magic solution: 

```nginx
location / {
    proxy_pass http://subversion;
    set $fixed_destination $http_destination;
    if ( $http_destination ~* ^https(?<unencoded_destinaton>.*)$ ) {
        set $fixed_destination http$unencoded_destinaton;
    }
    proxy_set_header Destination $fixed_destination;
}
```

Just add a name to the regular group used for matching and it's OK... 

## Other

This solution comes from a reply from [Maxim Dounin](https://trac.nginx.org/nginx/ticket/348) more than nine years ago. Therefore, **it is better to use named capture groups to modify variables using regular expressions in Nginx**.

The architecture of ten years ago, the problems of ten years ago, still exist ten years later. Amazingly, the solution from ten years ago still works. 
