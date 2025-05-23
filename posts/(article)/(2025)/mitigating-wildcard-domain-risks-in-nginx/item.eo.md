---
title: Wildcard-domajna agordo en Nginx: riskoj kaj kontraŭrimedoj
date: '2025-05-23 05:23'
license: CC-BY-NC-SA-4.0
translator: ChatGPT, dallaslu
taxonomy:
    category:
        - Internet
    tag:
        - Nginx
        - Domain
        - SSL
---

La programo de retejo subtenas plurlokan reĝimon, do pro oportunecon oni agordis la domajnon *.example.com en Nginx.
Tamen, strangaj subdomajnoj ofte aperas en la alirregistroj, kio kaŭzas senton de malkonveno.
Ĉi tiu artikolo priskribas kiel uzi Nginx por eviti tian riskon.

===

## Wildcard-domajna ligado

Origina agordo de Nginx aspektas tiel:

```nginx
server {
    listen 80;
    server_name *.example.com;

    // blabla
}
```

Tia agordo estas simpla kaj oportuna. Tamen, se via retejo ne efektive subtenas plurlokan reĝimon, aŭ se la programo ne ĝuste traktas la domajnojn, ĉiu ajn subdomajno povos aliri la enhavon — kio estas iom strange.

Eble iu konscie konstruas kaj publikigas nekutiman ligilon, kiu hazarde estas kaptita de ret-robotoj. Imagu vizitantojn venantajn el tiaj fontoj, mirantajn pri la stranga subdomajno — tio estas neintencita konduto, kun ebla SEO-damaĝo kaj konformeca risko. Oni devus adopti rimedojn por eviti tion.

Se la nombro de subdomajnoj estas limigita, listigu ilin rekte:

```diff
server {
    listen 80;
-    server_name *.example.com;
+    server_name
+        www.example.com
+        cdn.example.com
+        api.example.com;
}
```

Se via bezono estas pli kompleksa kaj vi volas konservi `*.example.com`, vi povas aldoni blanklistan kontrolon:

!!! En Nginx, `$server_name` estas la unua valoro listigita en server_name, do metu la ĉefan domajnon unue por pli facila traktado.

Se vi antaŭe uzis blog.example.com, sed nun revenis al `www.example.com`, la plej taŭga maniero estas redirekti. Ĉiuj aliaj neatenditaj domajnoj povas esti tuj fermitaj per `return 444;`.


```diff
server {
    listen 80;
-    server_name *.example.com;
+    server_name www.example.com example.com *.example.com;
+
+    if ($host ~* ^((blog|feed|log)\.example\.com|example.com)$) {
+        return 307 $scheme://$server_name$request_uri;
+    }
+
+    if ($host !~* ^(cdn|api)\.example\.com$) {
+        return 444;
+    }
}
```

## Defaŭlta gastiganto

Ankaŭ defaŭltaj serviloj havas riskojn. Se ne-registrita domajno indikas al via IP-adreso, en Ĉinio tio povus kontraui regulojn. Por tio, malakceptu ĉion krom laŭ-IP-aliron:

```nginx
server {
    listen 80 default_server;
    server_name _;

    return 444;
}
```

Por permesi rektan IP-aliron:

```diff
-return 444;
+if ($host !~* "^((?:\d{1,3}\.){3}\d{1,3}|(?:[a-fA-F0-9:]+))$") {
+    return 444;
+}
```

## SNI-revelacio en HTTPS

Eĉ se konekto estas malakceptita, en HTTPS la TLS-certifikato ankoraŭ povas reveli domajnojn per SNI (Server Name Indication). Por tio:

```diff
+ssl_reject_handshake on;
````

Se vi volas permesi IP-bazitan HTTPS, vi bezonas IP-specifan SSL-atestilon. Vi povas memsigni tian:

IPv4-certifikato

```shell
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ip.key -out ip.crt \
  -subj "/CN=1.2.3.4" \
  -addext "subjectAltName=IP:1.2.3.4"
```

IPv6-subteno

Uzu openssl-san.conf:

```toml
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = (ip or domain or keep bank)

[v3_req]
subjectAltName = @alt_names

[alt_names]
IP.1 = 1.2.3.4
IP.2 = 2001:db8::1

```

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ip-mixed.key -out ip-mixed.crt \
  -config openssl-san.conf
```

Nginx-agordo:

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;

    server_name _;

    ssl_certificate /path/to/ip.crt;
    ssl_certificate_key /path/to/ip.key;

    if ($host !~* "^((?:\d{1,3}\.){3}\d{1,3}|(?:[a-fA-F0-9:]+))$") {
        return 444;
    }
}
```

### Eviti ke CDN-domajno estu indeksita

```nginx
    root /path/to/webroot/www.example.com;

    location = /robots.txt {
        default_type text/plain;

        if ($host = 'cdn.example.com') {
            #return 200 "User-agent: *\nAllow: /*.png$\nDisallow: /\n";
            alias /path/to/webroot/www.example.com/robots-cdn.txt;
        }
    }
```
