---
title: The Domain of Mail successfully removed from SURBL blacklist
published: true
date: '2024-10-15 10:15'
license: CC-BY-NC-SA-4.0
category:
  - Internet
tag:
  - Self-hosted
  - Email
  - Mail-in-a-box
keywords:
  - SURBL Removal
  - SURBL Removal
  - Mail-in-a-box
---

The first day I switched to self-hosted mailboxes, the domain name of the mail service was blacklisted by SURBL. I submitted a Removal request as soon as I could. After months of waiting, it was finally successfully removed from the list.

## Discovery

I used [Mail-in-a-box](https://mailinabox.email/) to build my own mailbox. Although it is running on a dedicated server with a separate IP, for some reasons I used another node with a separate IP on the same intranet and did port forwarding for SMTP. To test the delivery rate, I Googled a service and tried to send a test email to dozens of addresses it provided.

Soon after I found out in [MX Toolbox](https://mxtoolbox.com) that my domain was blacklisted.

## Request Removal

Visit <https://surbl.org/surbl-analysis> and look up the domain name, a link to apply is included in the results page. A lengthy form is filled out and the reason for sending dozens of test emails is described.

### The real reason

Then I noticed from the status page attached to Mail-in-a-box that there were thousands of emails in the queue. I soon realized that the problem was in the port forwarding of another node.

Mail-in-a-box's supplied configuration file `/etc/postfix/main.cf` has:

``conf
mynetworks_style=subnet
```

This will enable other hosts on the mail server's subnet to send mail without authentication[^mynetwork_style]. The simple port forwarding mentioned earlier does not transmit the IPs of external packets to the mail server. For the mail server, these attack requests are coming from intranet nodes, thus skipping authentication and becoming an open SMTP relay.

### Solution

The problem lies in the port forwarding, so naturally you can switch to another [forwarding scheme that preserves the source IP](https://dallas.lu/preserving-client-ip-in-iptables-port-forwarding/). A simpler approach is to change the default behavior of the mail component:

``conf
mynetworks_style=host
```

And during the bare bones period, nearly 10,000 emails were sent from this node...

## Removal successful

However, SURBL had only one chance to fill the Removal request, and querying it again only showed that there was already a Removal request in the queue, please wait for it to be processed. So the above follow-up is not synchronized to SURBL.

After a long wait, I finally received an email back, giving a dozen or so practice reference links about mail servers. Two hours later, I received an email that the removal was successful.

## Impact

In fact, during the period of being blacklisted, it didn't have any impact on my sending emails. Perhaps because it was for private email use, being blacklisted by only one blacklist added just a little bit to the Spam score.

## Conclusion

One of the reasons why many people don't recommend self-hosted mailboxes is that it takes a lot of effort to maintain the reputation of your IP/domain name. Besides that, some of the big email service providers are often whitelisted, such as Graylist, and even though most of the spam I get comes from these big providers, they are on the whitelist. Self-hosting makes it harder to get whitelisted.

I used to think that I wouldn't fall under the spell of blacklisting and hoped to write a post documenting the process after a successful removal. But that's all I can write about now, because I just found out that a blacklist called UCEPROTECTL3 has included one of my incoming but not outgoing IP...

[^mynetwork_style]: https://www.postfix.org/postconf.5.html#mynetworks