---
title: Why do Firefox and Chrome want to kill EV certificate
date: '2019-10-31 15:44'
author: 'dallaslu'
license: CC-BY-NC-ND-4.0
taxonomy:
    category:
        - Internet
    tag:
        - Chrome
        - Firefox
        - SSL
toc:
  enabled: true
---
In the latest versions of Firefox and Chrome, when visiting HTTPS sites using EV certificates, the address bar does not display the green lock icon and company information, instead, it displays the same gray lock icon as DV certificate sites.

===

As early as August this year, Firefox announced that it would cancel the special display of EV certificates when it released 70.0 in October. The reasons are：

1.   Additional company information confuses users and takes up screen space;
2.   It is emphasized that ev certificate affects user's cognition and delays the progress of default HTTPS experience that makes users imperceptible;
3.   Users do not care about the green mark of EV certificate, and the anti fraud effect is not significant.
4.   Safari has been hiding company information since last year.

However, they are more radical than Safari, just showing a gray icon. The news is seen as a major negative for the certificate industry. The EV sellers who claims to be able to turn the browser address bar green, have 10000 sentences of mother fuck in their mind, and I don't know who they can talk to.

![firefox-paypal](firefox-paypal.png "firefox-paypal")

There has been a long-standing conflict between the browser and the certificate provider. It's not the first time that Chrome and certificate providers are in conflict. In August, it proposed to reduce the validity period of the certificate, which was rejected. So, is EV certificate really unnecessary?

## EV & UI Design

In today's 1920 wide display resolution, the width left for the browser address bar is at least 1200 pixels. In the Firefox interface, there is a blank space before and after the address bar; on the left side is the privacy icon, on the right side is the reading mode and plug-in shortcut icon. It's reasonable to say that there's such a long company name as "宝鸡有一群怀揣着梦想的少年相信在牛大叔的带领下会创造生命的奇迹网络科技有限公司", but can't even "PayPal Inc." or "Apple Inc."?

Of course, browsers don't always run with maximized windows. How does Firefox deal with address bars? They hide part of the URL. So why can't corporate information get the same treatment? I've seen some people who almost never enter the URL manually. They are always searching for keywords in search engines and clicking links to enter the website. For these people, both of confusing URLs and complex buttons are useless. Just hide them, which can save a large amount of screen space.

n the mobile version, the horizontal space is indeed very less, and even only the domain name is displayed by default, and the complete URL can be seen after clicking. So it's not difficult to display EV information in two lines on the domain name.

Although users are lazy, they are not stupid. Company information is confusing, not a problem; the latest version of Firefox only shows "certificate issued to: PayPal Inc." which is the source of confusion. When clicking on the company information, you will be prompted with the words "Verified by XXX, this website is operated / owned by PayPal Inc." Anyone will know what does that mean.

## EV and imperceptible HTTPS

What Mozilla and Google think of imperceptible HTTPS is that whatever you are using EV / OV / DV, it will all display as a small black lock. After all, in order to be imperceptible, they dare to hide `http://www`. Imperceptible HTTPS is also a non-existent requirement. Insecurity, transmission security and commercial security cannot be simplified as insecurity and security. The users are not the resistance of HTTPS promotion. Whether they can distinguish between black lock and green lock does not automatically make the website support HTTPS.

Even the autocratic Qing government knew that in order to carry out the order of shaving, it was enough to kill those who didn't want to wear pigtails. There was no need to kill Manchus who wear smaller pigtails. Imagine the Manchu soldiers saying to you, what we want is imperceptible pigtails, your hair is too short, which affects other people's cognition of the pigtails. Pull it down and kill him!

## EV & Anti fraud

Users don't care about EV, which is the problem of browsers and certificate providers with poor publicity. Users don't care a lot, including HTTPS. Users are too lazy to type `https://`, the industry has proposed HSTS preload instead of giving up HTTPS.

Users don't care about the code signing certificates of Windows Drivers and Mac OS apps. Why don't you hide the signing information? Oh, I'm sorry. It's about Microsoft and Apple. Mozilla and Google can't help it.

Some users have just begun to pay attention to the meaning of green bar, and it is very helpful to fraud if EV is killed. If you receive an e-mail, there is a link [`https://www.apple.com`](https://www.аpple.com), which allows you to see the HTML source code. Do you dare to click it? Don't worry about the link, though it's not Apple's official website. So far it's still a non-existent site. The letter `а` in the website is not an ordinary small letter `a`.

[@ViafaSia](https://twitter.com/ViafaSia/status/854051035580481536) also found a phishing site that used the DV certificate from Let's Encrypt. Each letter of apple in the website is another similar character. Here is another one, <https://раураӏ.com>, open it with your Firefox, and then open the real <https://paypal.com>. You will known, Mozilla is just an idiot which stands with Google. Chrome displays IDN domains in another ways.

You may have some tips to identify fake links, such as mouse over the links to see the real URL from the browser's status bar, or pay attention to whether it is an HTTPS link. But still can't escape the advanced phishing website.

## EV & Safari

Although Safari has hidden EV company information for a long time, until the latest iOS / iPad OS 13.2 and Catalina, Safari still displays the green address bar for EV certificate sites. Google takes users as the puppet, to order the certificated sellers. Google's face says, 'if Apple dare to light the light, I dare to set it on fire'. Mozilla make wind behind Google, just like a dog.

It's always been easy for certification companies to make money. Google doesn't like it. When Chrome gets bigger, it has the right to speak. Finally, it can give directions. It's not enough to have Mozilla's support. By the way, it get Safari into the water to justify himself.

Some people say that EV is so expensive and doesn't support wildcard, it's not bad to suppress it. Google has the ability to launch competitive products to promote the development of the industry, but now it's going to kill EV directly.

## What will happen to EV?

Maybe EV will quit the stage of history, maybe it will be reborn after all parties play games. It's time for them to take some action.

1.   The EV upstream enterprises pay money to browser. After all, their necks are in the hands of others, money should be divided;
2.   Provides a preload list like HSTS (or a better HPKP), and sites using EV certificates are automatically submitted to the list. The browser judges the similarity of domain names, once reaches the threshold, directly prompt users and report to anti fraud organizations;
3.   Reduce price, and popularize EV / OV to enterprises and organizations with the popularity of HTTPS.
