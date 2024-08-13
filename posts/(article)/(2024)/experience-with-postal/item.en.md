---
title: Experience with Using Postal, the Mail Delivery Platform
published: true
date: '2024-07-09 07:09'
license: CC-BY-NC-SA-4.0
taxonomy:
  category:
    - Internet
  tag:
    - Email
    - Postal
    - Self-hosted
keywords: 
  - Postal Installing
  - SendGrid Alternative
  - Postal STARTTLS
toc:
  enabled: true
x.com:
  status: 
nostr:
  note: 
---

I have been using Postal as a replacement for SendGrid for some time now. It can almost completely replace SendGrid. During its use, I encountered some issues. This article records some experiences.

===

## Issues with Port 25 for SMTP Client

When a server sends an email, it first checks the domain part of the email address, queries the MX records, finds the mail server for that email, and delivers the message. In the default process, it needs to connect to port 25. If a server is restricted from connecting to port 25 of other servers, it cannot easily send emails. Many VPS providers restrict outbound traffic to port 25 for this reason.

Postal only provides an SMTP port, which is 25. Although it can use the HTTP interface to send emails, most applications do not adapt to its HTTP interface, making SMTP the most common solution. If you encounter such a VPS, you will have to find another way.

One way is to use a Socks proxy to route the outbound traffic of port 25 through a different path to bypass the restriction. However, the proxy server may also restrict port 25.

Another method is to enable an alternative port on the Postal SMTP server, such as 2525. However, Postal itself only allows setting one port. You can use iptables on the Postal server to provide alternative ports:

```bash
iptables -t nat -A PREROUTING -p tcp --match multiport --dports 587,2525 -j REDIRECT --to-ports 25
```
## Separate Domain for SMTP Service

As mentioned above, Postal exposes only two services externally:

* Web service providing the management panel and HTTP API
* SMTP service for sending and receiving emails

They share the domain postal.example.com. This means you cannot use Cloudflare's proxy feature to speed up Postal's web service. So, we need to split the domains for the two services.

Fortunately, Postal supports this configuration. We can edit the configuration file /opt/postal/config/postal.yml, set smtp_hostname to smtp.example.com, and configure the DNS A record and corresponding IP PTR record.

## PTR Records of Postal Server

Many VPS providers offer an online interface to modify PTR records, while some require submitting a ticket. Generally, it's recommended to keep the hostname and PTR record consistent. During SMTP server negotiation of STARTTLS, the hostname declared in the banner will be verified against the PTR record. If helo_hostname is not configured in Postal, it will use the value of smtp_hostname as the hostname.

In the mail protocol, there is no mandatory standard for client verification of the certificate. The client may or may not verify the domain name, and even self-signed certificates can be used. Some clients require the SMTP server's declared hostname to match, while others may require it to match the MX record domain or the connecting domain (like the Bamboo library used by Plausible).

PTR records are not directly related to TLS, but there is a subtle connection through helo_hostname. In Postal and Mail-in-a-box by default, only one domain is used, so no issues arise.

However, in some special cases, when your Postal has multiple backup IPs or an IP pool, some IPs might only be used for outbound traffic and not provide web or receiving services. The default smtp_hostname may not match the PTR records of these outbound-only IPs.

Unfortunately, there is an issue with the current implementation of helo_hostname, making it ineffective. So, my current solution is to first modify the smtp_hostname in the configuration file to helo.example.com, restart the SMTP service (docker restart postal-smtp-1), then change smtp_hostname back to smtp.example.com, and restart the web service (postal-web-1). This way, multiple A records for helo.example.com can point to each outbound IP to pass the PTR check.

## Certificate Issues

Postal supports STARTTLS on port 25. We just need to enable tls with `smtp_server.tls_enabled: true` in Postal's configuration file and add the key and certificate to the default paths:

* /opt/postal/config/smtp.key
* /opt/postal/config/smtp.cert

Given the lack of standards for client verification logic of SMTP certificates, it is best to use a multi-domain certificate that includes the domains used in the mail system or use a WildCard certificate.

## Conclusion

I had to find an alternative due to an issue with my SendGrid account; shortly after, another well-known product by its developer Twilio, Authy, experienced a phone number leakage incident. I recommend everyone who has used SendGrid to look for a good alternative, and self-hosting Postal is a very worthwhile solution to try.

[^cloudflare-2525]: https://www.cloudflare-cn.com/learning/email-security/smtp-port-25-587/