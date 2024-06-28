---
title: 'Build Your Own SendGrid: Postal SMTP Server'
published: true
date: '2024-06-28 06:28'
license: CC-BY-NC-SA-4.0
taxonomy:
  category:
    - Internet
  tag:
    - Email
    - Postal
    - Self-hosted
keywords:
  - Build Postal
  - Postal Installation
  - SendGrid Alternative
toc:
  enabled: true
x.com:
  status: 
nostr:
  note: 
---

Cloudflare's email routing feature is quite useful. Additionally, I have been using SendGrid for sending emails and have been on the lookout for alternatives. Self-hosted email options include Mail-in-a-box, Docker-mailserver, MailCow, among others. However, sometimes I don't need an inbox, so I decided to try Postal as a replacement for SendGrid. This article documents the installation and usage of Postal.

===

## Preparation

### A Domain Name

Usually, a subdomain is sufficient, such as postal.example.com. This will be used for management and configuration purposes. Once installed, you can bind new domains to send and receive emails.

### A VPS

It's best to have a VPS dedicated to running Postal, allowing traffic on port 25, with both IPv4 and IPv6 public IPs, and set rDNS to resolve to postal.example.com, which is crucial for successful email delivery.

#### How to Test If Your VPS Allows Traffic on Port 25

##### Test Connection to Other Servers on Port 25

```bash
telnet smtp.google.com 25
```

##### Test If External Servers Can Connect to Your VPS on Port 25

Listen on port 25 on your VPS:

```bash
nc -l -p 25
```

Allow inbound traffic on port 25, for example, using UFW:

```bash
ufw allow 25/tcp
```

Connect to your local port 25 from an external server:

```bash
telnet <YOUR_VPS_IP> 25
```

Fortunately, my usual [DMIT](https://www.dmit.io/aff.php?aff=6587) and ServerHub dedicated servers do not have port 25 restrictions. DMIT's lack of restrictions on port 25 is likely thanks to [Tao Shu](https://taoshu.in)[^dmit-25].

## Install Postal

Postal recommends at least 4GB of RAM and 25GB of storage space. I used a freshly installed Ubuntu 22.04 to run Postal.

```bash
apt install git curl jq
git clone https://github.com/postalserver/install /opt/postal/install
sudo ln -s /opt/postal/install/bin/postal /usr/bin/postal
```

### Docker

Postal does not officially support Podman, so we should [install Docker](https://docs.docker.com/engine/install/ubuntu/):

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### MariaDB

You can use Docker.

```bash
docker run -d \
   --name postal-mariadb \
   -p 127.0.0.1:3306:3306 \
   --restart always \
   -e MARIADB_DATABASE=postal \
   -e MARIADB_ROOT_PASSWORD=postal \
   mariadb
```

Alternatively, you can run MariaDB without Docker. Ensure that Postal has all privileges on the postal and postal-% databases.

```sql
GRANT ALL PRIVILEGES ON `postal`.* TO 'postal'@'%' IDENTIFIED BY 'YOUR_PASSWORD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON `postal\-%`.* TO 'postal'@'%' IDENTIFIED BY 'YOUR_PASSWORD' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

To log emails, confirm that innodb_log_file_size is ten times the maximum email size. Check the current configuration [^mariadb-innodb-log-file-size]:

```sql
SHOW GLOBAL VARIABLES LIKE 'innodb_log_file_size';
```

### Setting Up Postal

Run:

```bash
postal bootstrap postal.yourdomain.com
```

Edit the generated configuration file to set the database password, etc.:

```
vim /opt/postal/config/postal.yml
```

#### ghcr.io

Visit <https://github.com/settings/tokens/new> to generate a classic token[^auth-ghcr]。

```bash
export CR_PAT=YOUR_TOKEN
export ghcr_user=YOUR_GITHUB_USERNAME
echo $CR_PAT | docker login ghcr.io -u $ghcr_user -password-stdin
```

#### Initialize the Database and More

```bash
postal initialize
```

#### Create an Admin User

```bash
postal make-user
```

#### Start Postal

```bash
postal start
```

#### Caddy
```bash
docker run -d \
   --name postal-caddy \
   --restart always \
   --network host \
   -v /opt/postal/config/Caddyfile:/etc/caddy/Caddyfile \
   -v /opt/postal/caddy-data:/data \
   caddy
```

## Configuring DNS Records

Create A and AAAA records for postal.example.com pointing to your server's IP. Follow https://docs.postalserver.io/getting-started/dns-configuration to configure other DNS records.

In the configuration file, the domains in dns.mx_records should all be CNAMEs to postal.example.com.

## Using Postal

Access postal.example.com, create an organization, then create a mail server, add a domain, configure the DNS records for the mail domain as prompted on the page, and verify them.

Go to Messages -> Send Message to send a test email. Visit <https://www.mail-tester.com> to get a test email address and send a test email to see if you can achieve a perfect score.

In Credentials, you can add SMTP credentials to start sending emails.

It's recommended to enable privacy mode in the settings to avoid leaking the IP addresses of SMTP clients.

## Conclusion

Postal also supports email receiving features similar to Cloudflare's email routing, allowing forwarding to mailboxes or HTTP endpoints. Recently, my SendGrid account became inaccessible for unknown reasons. After using Postal for a while, I found it can completely replace services like SendGrid and offers more freedom.

[^dmit-25]: 涛叔. [记录开通 25 号端口的经历](https://taoshu.in/dmit-25.html). Taoshu.in. 2022.
[^mariadb-innodb-log-file-size]: https://mariadb.com/docs/server/storage-engines/innodb/operations/configure-redo-log/
[^auth-ghcr]: Andrew Hoog. [Authorizing GitHub Container Registry](https://www.andrewhoog.com/post/authorizing-github-container-registry/). DON'T PANIC. 2023