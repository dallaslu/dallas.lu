---
title: Current Progress and Outlook of the Website Comment System
published: true
date: '2024-08-08 08:08'
license: CC-BY-NC-SA-4.0
taxonomy:
  category:
    - Internet
  tag:
    - Blog
    - Comment
    - Email
keywords:
  - Blog Comment System
  - Website Comment System
  - Third-Party Comment System
  - Nested Comments
  - Email Comments
  - Webmention
toc:
  enabled: true
x.com:
  status: https://x.com/dallaslu/status/1821816952727490678
nostr:
  note: note1xgph22n4n0mgl68pc3vqeq2julhwaxh7lmdgctmjjzqrn0xgmsysljgwtr
hackernews: https://news.ycombinator.com/item?id=41202486
---

More than a year ago, I researched the status of comment systems at the time and ultimately chose a traditional comment system for the website. To date, there have been some new developments and new ideas.

===

## Progress

### Integrating Webmention

For research purposes, I integrated Webmention. For convenience, I chose [webmention.io](https://webmention.io). Through some bridging services, more scattered interaction information can be actively collected. For example, if you post an article link on social media and receive a thousand likes, these likes can be displayed on the article[^webmention].

Theoretically, through bridging, more types of content can be collected, such as discussion interactions on Hacker News. If Nostr is integrated, the website itself would not need to connect to the Nostr network.

### Email Integration

#### Email Notifications

Traditional comments and emails have always been a classic combination. To better send comment-related email notifications, I migrated from SendGrid to Postal.

In the early days, the email notifications of Douban's DM only had one sentence: "You have a new message." I found this very frustrating. Since the email is already sent, why not mention who sent it and what was said? It forced users to log into the site to view detail. Fortunately, the blog community is generally more open. If your comment on a website is mentioned or responded to, you usually receive an email with full details.

#### Email Replies

Since full details are already sent, why can't you reply directly? Too many notification emails come from `noreply@*`, except for some merchants' ticket systems and services like Github. In this regard, using Github Issues to implement a comment system is quite ingenious.

Email replies are not difficult to implement. Modern Email platforms can forward the parsed email content to a specified Http Endpoint[^mailersend].

Using email for a comment system can make discussing blog posts feel like using a mailing list. Nested comments can be conveniently handled on the page as well.

#### Email Comments

Going further, why can email only be used to reply to notifications? Perhaps it can be used proactively; you could open your email client and send an email to comment on an article or someone else's comment. People who prefer to communicate via Email are in luck, finally.

Next to the comment button, I placed a mailto protocol link. Clicking it opens the email client, allowing users to send an email instead of filling out the form on the page.

### Visitor Identity

If you comment via email, your email address is naturally valid. The website can display a verification icon to indicate that this person used a real email.

Of course, this does not mean that the email address of those who comment via form is invalid. But who knows? The email field can be filled with anything, including someone else's email or a fake one.

Since email addresses may not be real, I allow you not to fill in the email field at all. Enjoy the privacy and the joy of surfing the web, with the trade-off being a dog icon next to your information, because nobody knows you're a dog on the internet.

Since even email can be left blank, the name becomes even less important. However, these incomplete replies will be subject to certain sending restrictions and may require moderation.

### Sensitive Information

A comment typically has only two sensitive fields: IP and Email. My article content is based on markdown files, making it very easy to open-source. However, sensitive information in local comments needs to be encrypted and decrypted with a key when used.

## Outlook

### Improvements

Performance and useful small features are always targets for improvement. For example, paginated loading, voting, search, etc. And, a better notification policy. During my time using WordPress, the site was often bombarded with spam comments, and my inbox was flooded with notification emails.

### Integration

I believe that comments on articles are an extension of the article content. If there are no comments, one might as well read the article in an RSS reader, on a public account platform, or in marketing screenshots. Besides contacting the author, there's no need to visit the article. So, scattered information can be collected, allowing readers to assess the article more intuitively.

### Comment Platform

Static websites are very popular now, and more often, people need a third-party comment system. Considering the shutdown of Duoshuo, the risks of using a third-party comment system must also be considered. If I were to create a comment system, the most important point would be that data can be exported at any time, or even in real-time, because my current comment system is based on file storage and can be pushed to a git repo.

## Conclusion

Personal websites or blogs have become a nostalgic toy. Recently, I saw people still tinkering with third-party comment systems[^axiaoxin] or developing their own programs and comment systems[^darmau]. Nostalgia doesn't necessarily mean retro; there should be more variations.

[^webmention]: Jason. [透過 webmention 來搜集 blog 的社群迴響](https://jason-memo.dev/posts/webmention/). Jason's Web Memo. 2022-09-12.
[^mailersend]: Tautvydas Tijūnaitis. [Enable the use of email replies to post comments or messages](https://www.mailersend.com/blog/post-comments-with-email-replies). Mailersend. 2022-05-25.
[^axiaoxin]: ashin. [个人博客新增云评论留言板，欢迎大家测试](https://v2ex.com/t/1062883). V2EX. 2024-08-06.
[^darmau]: Darmau. [This site has evolved to the third generation](https://darmau.co/en/article/this-site-has-evolved-to-third-generation). Darmau. 2024-08-05.