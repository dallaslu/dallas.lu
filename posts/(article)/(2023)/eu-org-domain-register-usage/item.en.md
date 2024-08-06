---
title: Registration and Usage of Free Domains from EU.org
date: '2023-08-18 00:18'
author: 'dallaslu'
keywords:
    - Free Domain
    - Register Free Domain
    - Free Subdomain
    - nic.eu.org
    - register EU.org
    - EU.org register
    - EU.org domain
    - eu.org domain apply
    - nic.eu.org domain apply
    - How long does it take to register a domain with EU.org
published: true
license: CC-BY-NC-SA-4.0
toc:
    enabled: true
taxonomy:
    category:
        - Internet
    tag:
        - EU.org
        - Domain
        - Cloudflare
        - Hostry
---

Domain names are no longer the sole entry point for online traffic. Aside from professional domain enthusiasts, many people continue to renew and maintain their domains. Some individuals' blogs haven't been updated for over a decade, yet their domains are still active. This persistence may stem from an early internet mentality that necessitates owning a domain. From the early days of limited functionality free subdomains to the free top-level domains that can be taken away at any time, using free domains often comes with costs other than money. However, there is an exception: the free domain registration service provided by EU.org. This article introduces the registration process and basic usage guidelines after successful registration.

===

For example, the domain I recently registered, `dallaslu.eu.org`, appears to be a subdomain but is actually widely recognized as a top-level domain[^note:domain-level]. The entire registration process only requires an email address and filling out some forms. After that, you wait for a few months, or perhaps even a year. Yes, the registration period for EU.org domains is quite unpredictable.

## Create Contact Information

Visit <https://nic.eu.org/arf/en/contact/create/>, and fill out the application form.

1. E-mail must be valid;
2. It's recommended to check the box of `Private (not shown in the public Whois)` to enable privacy protection;
3. Must check the box of  `I have read and I accept the domain policy`;
4. Set a sufficiently strong password.

Other contact information fields can be filled out at your discretion. Given the unpredictable nature of the registration period, providing detailed and accurate information might increase the chances of quicker approval. After clicking the "Create" button, you will receive an activation email.

The login account (Handle[^note:eu-handle]) for EU.org is automatically generated based on the contact person's initials and number, similar to DL1216-FREE. Each contact account corresponds to a single Contact.

Even if privacy protection is enabled, the Handle for a EU.org domain can still be queried. If you register multiple domains for different purposes, someone could potentially compare the whois information and unintentionally discover connections between these domains. Since you can use the same email to register multiple Handles, it's possible to plan accordingly during the registration process. Of course, you can also make changes after registration; domains can be freely transferred between Handles.

## Register Domain

Click `New Domain` to enter the application page after logging in.

### Checking Domain Availability

Simply fill in the "Complete domain name" field in the form, for example, by entering dallaslu.eu.org, and then submit the form. If the interface transitions to a black, bash-like screen performing an NS check, it indicates that the domain is available for registration. Otherwise, the page will display the reason why the domain cannot be registered.

### Name Server

EU.org does not provide default NS, so this needs to be managed independently. Although Cloudflare offers free NS services, it requires domains to be successfully registered before they can be added, ensuring CDN and other services work out of the box. Therefore, we choose [hostry.com](https://hostry.com), which allows the addition of domains that are not yet registered, as our NS provider.

After registering and logging in at hostry.com, navigate to the `SERVICES`>`Free DNS` menu, enter the domain name you just selected, and click `CREATE DNS`. Afterward, click `CREATE` again. Wait for a moment until the status becomes active, then return to the EU.org application page and fill in the NS.

    ns1.hostry.com
    ns2.hostry.com
    ns3.hostry.com
    ns4.hostry.com

### Submit for Verification

Click `Submit`. On the NS check page, if you see "Errors" mentioned, wait for a while and refresh the page to confirm before resubmitting the form. Continue this process until you see:

    No error, storing for validation...
    Saved as request 20230818xxxxxx-arf-xxxxx

    Done

Once you successfully submit the registration application, you can repeat the above process to register multiple domains. Based on my experience, it's possible to apply for a dozen domains with the same Handle.

Next comes the long wait. From my experience, it takes about three months. Please enter hibernation mode for three months, and then check your email for a message with the subject request [20230818xxxxxx-arf-xxxxx] (domain XXXXXXXX.EU.ORG) accepted.

## Cloudflare

Once the registration is successful, you can add the site to Cloudflare. Follow the instructions on the page to modify the domain's Name Server on EU.org and then wait for Cloudflare to verify. You can immediately apply for Cloudflare's free email forwarding service to get a domain email with unlimited aliases.

If you plan to use this domain for a website, don't forget the following steps:

### Enable DNSSEC

1. Visit the Cloudflare dashboard and navigate to the  `DNS`>`Settings` menu for this site，enable `DNSSEC`;
2. Copy the DSrecord values and fill them into the DNSSEC form on the EU.org domain management page, then save the changes.

### Enable HSTS

1. Visit the Cloudflare dashboard and navigate to the `SSL/TLS`>`Edge Certificates` menu for the site. Enable "Always Use HTTPS"; select and enable HSTS, turn on all the switches in the form, and choose the maximum header duration of 12 months. Save the changes.
2. Add DNS records that point to any IP address to ensure the homepage is accessible.
3. Visit <https://hstspreload.org>, enter your domain, and check. Once it passes, submit the domain. It may take a few weeks for the changes to take effect.

### Redirect to a Domain or a static URL

If you want the domain to redirect to an existing website, you can create a rule in the Cloudflare dashboard. Navigate to the `Rules`>`Redirect Rules` menu for the site and create a new rule.

Note that HSTS requires that when accessing `http://XXXXXXXX.eu.org`, it first redirects to `https://XXXXXXXX.eu.org`. Therefore, you should avoid redirecting http requests to other domains. Choose a custom filter expression, select the SSL/HTTPS field, and set the value to "On" to ensure that this rule only applies to https requests.

For the redirect rule, choose the type as "Dynamic" and fill in the expression as follows:

```javascript
concat("https://yourdomain.com", http.request.uri.path)
```

If you wish to redirect to your social media, you can directly choose the "Static" type and enter the URL. Save the changes, and the redirection will be set up.

## Conclusion

Some say that everyone on Earth should have their own website[^everyone-own-website], though this idea is still up for debate. However, before that, everyone should consider registering a domain with EU.org.

[^note:domain-level]: The terms "top-level domain" and "second-level domain" are used here in their colloquial sense.
[^note:eu-handle]: EU.org call a login account name as "Handle".
[^everyone-own-website]: Amin Eftegarie. [Every person on the planet should have their own website](https://eftegarie.com/every-person-on-the-planet-should-have-their-own-website/). EFTEGARIE. 2023