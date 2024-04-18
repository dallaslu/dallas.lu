---
title: Use your primary domain as an Mastodon name
date: '2020-11-10 13:44'
author: 'dallaslu'
license: CC-BY-NC-SA-4.0
taxonomy:
    category:
        - Internet
    tag:
        - Mastodon
        - Nginx
        - Unify-your-online-accounts
toc:
  enabled: true
---
If you have a self-built blog and are planning to or have set up an instance of Mastodon, you will have to face the problem of domain name choice. Assuming your blog is `example.com`, should your Mastodon account be `yourname@example.com` or `yourname@mastodon.example.com`?

===

For the sake of simplicity and clarity, you will naturally prefer to have the same domain name for your blog and Mastodon. However, Mastodon does not run under a second-level directory. Even if the web part of Mastodon is moved to a second-level domain or directory by means of reverse engineering, there is a high probability that the service, as a decentralized service, will have unknown problems when exchanging data with other instance nodes in the Federation universe.

Fortunately, an important step in inter-federation node communication is access to `https://example.com/.well-known/host-meta`, a file whose contents contain URLs for subsequent steps. and Mastodon also supports the `LOCAL_DOMAIN` and `WEB_DOMAIN ` options.

## Configuring Mastodon

Edit the `.env.production` with the following changes.

1. __Don't__ modify `LOCAL_DOMAIN`; 
2. Add WEB_DOMAIN configuration, set to a second-level domain name, such as `mastodon.example.com`. 

## Configuration mastodon.example.com

Refer to the Mastodon documentation to configure an nginx host for `mastodon.example.com`. Restart Mastodon's streaming/sidekiq/web service, reload the nginx configuration, and mastodon.example.com is now accessible.

## Configuring example.com

But the external instance trying to connect to your account `yourname@example.com` doesn't yet know that your web address is mastodon.example.com, so we'd like to visit `https://example.com/.well-known/host-meta` returns `https://mastodon.example.com/.well-known/host-meta`.

In `example.com`'s nginx configuration, remove Mastodon's configuration and add only the following rules.

```nginx
location = /.well-known/host-meta {
       return 301 https://mastodon.example.com$request_uri;
}
```

Just reload nginx.

## More configurations

The above configurations are from felx's supplemental documentation [Using a different domain name for Mastodon and the users it serves](https://github.com/felx/mastodon-documentation/blob/master/Running-Mastodon/Serving_a_different_domain.md). As mentioned in the article, despite the fact that it is possible to achieve the requirements through primary domain hopping and WEB_DOMAIN configuration, there are still strange issues that are inevitable due to the different instance versions and the variety of clients.

And switching Mastodon, which has been running for some time, from a primary domain to a secondary domain may have even more obvious problems.

According to the [Routes chapter](https://docs.joinmastodon.org/dev/routes/) in the official documentation, as well as experience with it, it is recommended to set the following rules for example.com to increase compatibility.

```nginx
## mastodon web url
location ~ ^/(about/more|settings|web|pghero|sidekiq|admin|interact|explore|public|@. *|relationships|filters|terms|inert.css){
        rewrite ^(.*) https://$mastodon_host$1 permanent;
}

## mastodon .well-known
location ~ ^/(.well-known/(host-meta|nodeinfo|webfinger|change-password|keybase-proof-config)|nodeinfo) {
        rewrite ^(.*) https://$mastodon_host$1 permanent;
}

## mastodon system resources
location ~ ^/(system|headers|avatars) {
        ## set your mastodon public folder, or just redirect to $mastodon_host
        #rewrite ^(.*) https://$mastodon_host$1 permanent;
        root /home/mastodon/live/public;
}

## mastodon url (possible use post)
location ~ ^/(api/v1|inbox|actor|oauth|auth|users){
        return 308 https://$mastodon_host$request_uri;
}
```

You can now toot with `yourname@example.com`.
