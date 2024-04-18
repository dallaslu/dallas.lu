---
title: Using Let’s Encrypt Wildcard SSL Cert
date: '2018-03-15 16:15'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Lets-encrypt
        - SSL
        - VPS

---
Let's Encrypt has announced the official support of the Wildcard certificate FINALLY.

===

## Apply

Run command on your VPS:

```bash
~/certbot-auto certonly \
-d dallas.lu \
-d *.ngrok.dallas.lu \
-d *.dallas.lu \
-d other.com \
-d *.other.com \
--manual \
--preferred-challenges dns \
--server https://acme-v02.api.letsencrypt.org/directory
```

Use --cert-name to set cert name, otherwise the domain name after the first '-d' param will be used as the cert name.

## IP logged notice

The IP of the request machine will be logged, but it [will not be public now](https://community.letsencrypt.org/t/public-ip-logging/26385/2). If worry about the important one of IPs on the VPS，you can modify the config files in  /etc/sysconfig/network-scripts and restart the network service to change your IP temporarily. Type 'Y' to continue.

<pre>-------------------------------------------------------------------------------
NOTE: The IP of this machine will be publicly logged as having requested this
certificate. If you're running certbot in manual mode on a machine that is not
your server, please ensure you're okay with that.

Are you OK with your IP being logged?
-------------------------------------------------------------------------------
(Y)es/(N)o: Y</pre>

## DNS txt records

Add a txt record.

<pre>-------------------------------------------------------------------------------
Please deploy a DNS TXT record under the name
_acme-challenge.dallas.lu with the following value:

QQxHqbXK2aWM8qRWpAyenXo2QotSejV_ERnnc6MUEqU

Before continuing, verify the record is deployed.
-------------------------------------------------------------------------------
Press Enter to Continue</pre>

TIPS: if you want root.com and *.root.com verified in the same cert, you should add the params for each domain, for example: '-d dallas.lu -d *.dallas.lu'. AND, you need add multiple txt records. Use 'nslookup' to verify:

<pre lang="shell">nslookup
&gt; set type=txt
&gt; _acme-challenge.dallas.lu
Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
_acme-challenge.dallas.lu text = "I6Tys5RebMhWaBxN1e4fBaBj2OF7jUPl92tdDtfKjao"
_acme-challenge.dallas.lu text = "QQxHqbXK2aWM8qRWpAyenXo2QotSejV_ERnnc6MUEqU"</pre>

## Cert

After verification:

<pre>Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
- Congratulations! Your certificate and chain have been saved at:
/etc/letsencrypt/live/dallas.lu/fullchain.pem
Your key file has been saved at:
/etc/letsencrypt/live/dallas.lu/privkey.pem
Your cert will expire on 2018-06-13. To obtain a new or tweaked
version of this certificate in the future, simply run certbot-auto
again. To non-interactively renew *all* of your certificates, run
"certbot-auto renew"
- If you like Certbot, please consider supporting our work by:

Donating to ISRG / Let's Encrypt: https://letsencrypt.org/donate
Donating to EFF: https://eff.org/donate-le</pre>

We don't talk about configuring SSL certs now. If failed to verify some domains, just run the command again. The value of txt records will not change after verified.
