---
title: 'Trivia: Special ways of writing IP and domain names'
date: '2024-04-14 04:14'
author: dallaslu
license: CC-BY-NC-ND-4.0
taxonomy:
    category:
        - Internet
    tag:
        - SSL
        - IP
        - Domain
        - Trivia
keywords:
  - '127.1'
  - '127.0.0.1'
  - 'IPv4 abbr'
  - 'dot at end of domain'
toc:
  enabled: true
x.com:
  status: https://x.com/dallaslu/status/1779570633246183673
nostr:
  note: note1xgph22n4n0mgl68pc3vqeq2julhwaxh7lmdgctmjjzqrn0xgmsysljgwtr
---

X user plantegg, while testing MySQL connection issues, used IP 127.1, which piqued the interest of some netizens. When I first learned of this, I also doubted the legitimacy of my computer networking course. Thus, I've compiled some obscure knowledge akin to the "four ways to write the character 'hui'." Dear readers, remember! These facts are worth remembering. They'll come in handy when you work as a network administrator and need to write rules. (Earnest face)

===

## IPv4

While studying IPv6, everyone knows that consecutive zeros can be omitted, represented as `::`. This abbreviation applies to IPv4 as well.

### Abbreviations in IPv4

As plantegg mentioned1, `127.1` represents `127.0.0.1` by simply omitting the intermediate zero values.

The common IP format `127.0.0.1` uses dotted decimal notation, where four octets are separated by dots `.`. However, you could also write it in hexadecimal as `0x7f000001`, in decimal as `2130706433`, or in octal as `017700000001`, all of which represent `127.0.0.1`.

Dotted decimal notation does not necessarily require four parts; the first octet can be separated alone, for example, `1.65793` corresponds to `1.1.1.1`. Each part does not need to be in the same base, for example, its octal equivalent is `1.0200401`. Similarly, `127.0.0.1` can be written as `0x7f.01`.

From this, it should be clear that IPv4 can only omit zero-value octets, e.g., `127.1.1.1` can be written as `127.65793`, and by the same token, `127.0.0.1` can be abbreviated as `127.1`.

IPv4 essentially is a 32-bit integer, and these alternative notations are automatically converted to integer values at the network layer. Typically, when outputting, they are formatted into the standard four octet format.

### The Shortest IPv4 Address

Cloudflare has a DNS/Warp service IP `1.1.1.1` which is quite cool. In fact, its alternate IP `1.0.0.1` is cooler, as it can be simply written as `1.1`, making it the coolest Class A IPv4 address available at the beginning of its range.

In non-monospaced fonts, `1` is generally narrower than other characters, so `1.1` might be the shortest printed public IPv4 address.

## Domain Names

In popular understanding, there's often a difference in perception of terms and rules compared to professional fields.

### Omitted Dot at the End

For example, the definition of second-level domains and top-level domains. Popularly, a top-level domain refers to domains like `dallas.lu` that require registration, while second-level domains are its subdomains like `cdn.dallas.lu`. However, `.lu` is the actual top-level domain. Above top-level domains is the root domain, represented as `.`. Thus, `dallas.lu.` constitutes a complete domain name. In everyday use, the top-level domain suffix `.lu `is sufficient to distinguish it from hostnames/local domains, making the last `.` optional.

If you've owned a domain and set up CNAME or NS records, you might have encountered the necessity to add a `.` at the end. Nowadays, providers like Cloudflare allow domain names to be specified without being fully absolute. Many people have gradually forgotten this, so adding a `.` at the end can have unexpected effects. For instance, AliCloud prohibits unregistered at MII domains from providing web access, but it didn't account for domains ending with `.`, allowing them to be accessed normally. I've used this method for many years until it stopped working about three years ago.

Interestingly, different websites handle the last `.`in domain names differently. For example, <http://tesla.com.> and <http://google.com.> redirect to their respective non-dot-ending URLs; <http://microsoft.com.> leads to a 404 page; <http://x.com.> and <http://amazon.com.> show a blank page; <http://baidu.com.> results in a reset connection; <http://openai.com.> is accessible normally.

### The Shortest URL

Top-level domains are not directly accessible because they consist of at least two letters, causing conflict with the format of hostnames/local domains. However, adding a `.` after them allows for domain name resolution.

Thus, one of the shortest URLs is <http://to.>, which currently redirects to `www.to.`. Another is <http://ai.>, which is accessible normally.

### Similar Domain Names

IDN domains can use a broader range of characters. Many of these characters look very similar to Latin letters, and if the browser does not encode them for display, it can be difficult for users to distinguish them visually. For example, try visiting <https://раураӏ.com/>, and you'll find it's not the real PayPal—the `а`is not the standard lowercase letter `a`. The topic of legitimate versus deceptive domain names goes beyond the scope of this article and will not be discussed in detail here.

## Conclusion

Did you learn something? (Sigh + pity face)

[^plantegg]: plantegg. <https://x.com/plantegg/status/1773162126254952769>. X. 2024-03-27.
[^cloudflare-dns]:Ólafur Guðmundsson. [Introducing DNS Resolver, 1.1.1.1 (not a joke)](https://blog.cloudflare.com/dns-resolver-1-1-1-1). The Cloudflare Blog. 2018-04-01.