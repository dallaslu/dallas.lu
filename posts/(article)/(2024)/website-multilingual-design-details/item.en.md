---
title: Website Multilingual Design Details
date: '2024-08-23 08:23'
author: 'dallaslu'
published: true
taxonomy:
    category:
        - Internet
    tag:
        - WordPress
        - Press
        - Multilingual
keywords:
  - Multilingual URL
  - Multilingual detection
  - Multilingual
  - International
  - i18n
toc:
  enabled: true
---

When I was using WordPress, I was wondering what kind of way to implement a multilingual website. WordPress itself has great support for multilingual UI, but building a multilingual website with WordPress is a bit difficult. I switched to Grav and learned a great way to do it. When I started writing my own programs, I was determined to implement a solution that worked well and made sense. This article discusses some of the design details involved.

===

## Writing Multilingual Content

Language carries culture, and when you choose a language, it more or less comes with a cultural attribute. People have been writing in English for more than a decade. Even some of the people who run junk farm sites are making English content. Crossing over to the Chinese-speaking world also gives you access to a wider audience for English content. Maybe there are certain topic areas where English does fit better.

In today, even if English is not very good, there is no delay in communicating with the English speaking world. In the early years, you could use translation software, which used multiple programs to translate between the source and target languages, and proofread; in recent years, you can use AI, which understands the human language better, and at the same time, writing content in English and then reading and proofreading it manually is an excellent way to learn English[^write-to-learn]. For example, [pigleo](https://www.piglei.com) mentions in "[Anyone can write an English blog](https://www.piglei.com/articles/everyone-can-write-eng-blog/)" that he started using software to assist him in writing in English after his articles were stolen and translated into English. started using software to assist in English writing.

Given that the Chinese Internet is collapsing[^hejiayan], leading to the isolation of civilization[^isolation], writing multilingual content can help with cultural input and output, and be a cultural porter - or, to put it bluntly, you hometown boy, writing in English makes you get more traffic.

## Multi-language website implementation

Of course you can choose to make a separate English site, but this is not internationalized enough. WordPress has created sub-sites in different languages to provide help and support. This is because the content posted in the forums is usually only available in a single language. If you are writing your own articles, then every piece of content on the site is likely to be available in more than one language.

There are authors who provide translation features on their pages, or readers will use translation software (e.g., [Immersion Translate](https://immersivetranslate.com/)), but this is not native content. It's not friendly enough for search engines and readers. It's better to create multilingual content manually, even if it's all AI-translated, and it's excellent to expend a little effort proofreading it all over again.

So, my understanding of a multilingual website is that the content and UI support multilingual versions natively, with the same browsing experience in multiple languages, and the same content and quality. Essentially it's the same site, with the ability to use sub-domains, or even different domains - so the WordPress multisite model is out of the scope of this discussion.

I've used the [qtranslate-x](https://wordpress.org/plugins/qtranslate-x/) plugin to make WordPress multilingual. This plugin is slow to update and uses delimiters in database fields to store multilingual text, a compromise implementation of the current state of WordPress which does not naturally support multilingual content. It's often a bit of a pain to use and migrate. I'm also not too keen on trying [WPML](https://wpml.org). [Grav](https://getgrav.org) is file-based, so if you have a Chinese version of your content with the filename `item.zh.md`, then creating `item.en.md` in the same directory creates the corresponding English content. This design is very intuitive and free. However, Grav has a few minor drawbacks: there is only one set of site configurations, such as the site name, and only one language version is supported[^note:grav]. So I've used an extremely similar treatment, on top of which more fine-grained planning can be achieved.

## Planning for content

You've written an article to praise mainland China's App auditing system, would you consider creating an English version? You wrote a long article bashing Trump, would you create a version in Tranditional Chinese? You wrote a movie review that uses a lot of anime stems in Japanese for satire, would you consider making a German version?

Just because you don't do a standalone site and choose to do a multi-language site doesn't mean that every kind of content is a translation of the same thing. You are free to choose which language versions you want for each article. You can even express marketing content that caters to their language and culture in different versions, as you wish.

## URL Design

How do you design URLs when you have content in multiple languages crammed into one site? Add `?lang=zh-CN` to the URL using URL Search Param like Google? Or let visitors choose a language and store it in a cookie? Or use `/en/post-slug/`?

Sometimes when you browse some articles not in English, you don't understand them, and the quality of the translation software is not good enough; if you see a few English characters on the page, you will try to look for their English versions, but it's often futile. If you have multiple language versions, you should really implement support for `Accept-Language` in the request header. Even if there is no language version for the current article, at least the UI of the website can use English. Sometimes it's a challenge to find the language switching buttons for Russian and German sites.

So, my site implements:

- Separation of UI language from content language
- Default URL to realize automatic language
- When the URL contains a language, display the corresponding article content

In addition to the content, some elements on the page should also be linked to the language, for example, the simplified Chinese version may need to display the ICP record number, the public security record number, the publication license; European languages may need to display the Cookie privacy options, click on Accept to hide the prompts, click on Reject to jump to Google.

English users who visit the path `/website-multilingual-design-details/` will not be redirected to `/en/website-multilingual-design-details/` according to the language of the visitor, but will remain on this page, with the UI displayed in English and the content displayed in English (if provided).

When you visit the path of the specified language version, the content switches to the corresponding version, and the UI language still depends on the visitor's browser settings.

## Other details

With the most important URL scheme in place, the other details pretty much fall into place. For example, if the site's preferred language is `en-US`, then the site can provide the `en` it supports. If it's `zh-CN`, you can barely get by with `zh-HK` content, and there's also a nifty feature in Grav that allows you to disable a language for an article by simply creating content in that language and marking it for removal.

### Content language hints

If a non-English speaking user goes to a URL with an English language path through a link on Google or social media, the site can detect that the content language does not match the visitor's preferred language. At the top of the page, the language of the current content is indicated, as well as the available content languages in relation to the browser language, so that the visitor can switch freely and feel at home. At the end of the article, there is a link to all language versions, so that readers can <del>learn a foreign language</del>can help with proofreading.

### UI language switching

At the end of the page, all UI language versions are provided and can be switched freely. If there is a corresponding content, the content will also switch languages. This way, even if you're using the default English Tor browser, you can send a Spam by clicking the `Отправить`{lang=ru} button.

### Media Resources

If you're using images with text, in addition to introducing two different links in the `item.en.md` and `item.zh.md` files, one way to do this is to create the `image.en.png` and `image.zh.png` files, and use the `![](image.png)` to reference them. Yes, the URL `/image.png` also returns content in a different language, that just is how the `Accep-Language` header is used.

### RSS

While some people still miss Google Reader, I've implemented an automatic language feature for RSS. Unfortunately, I haven't yet found a reader bot that passes the correct language header and follows the language links in the atom file. So links like `/en/feed/` are also supported to subscribe to English content exclusively.

### SEO

One of the downsides of not using a publishing platform is that you have to do your own SEO. Google gives good [guidelines](https://developers.google.com/search/docs/specialty/international/) for multilingual sites. Each language of each article is treated as a different piece of content, and I've specified links with language paths as the preferred version, while the default links without language paths are referred to as `hreflang="x-default"`. The same is true in Sitemap. The file-based article system also makes it easy to set keywords for each language individually.

As well as letting the more Chinese-savvy Baidu focus on Chinese in robots.txt:

```
User-Agent: Baiduspider
Disallow: /en/
```

### Anchor links

I've even handled anchor links. Because by default, the heading plugin for Markdown in general, assigns the id of this section heading in the Chinese version as `锚点链接`{lang=zh-CN}. If Chinese users share a link with an anchor without a language path, then English users will not be able to locate the section. Theoretically, adding attribute support to Markdown and specifying the id with `{#id=anchor-link}` in all languages would work. It's probably over-engineered and doesn't happen at all ......

### Comment system languages

Another overdesign or over-engineered. The comment system does get tricky in this case though. I've chosen to record the content language and UI language in which the comment occurs, which can be used to display comments grouped by language, as well as to choose the language of the comment notification email.

## Conclusion

After continuous improvement, it's now working. I had someone point out that my RSS was buggy and the language content was messed up (thanks to that person). As well, Spam comments are now available in English and Russian. "Internationale", will be the human race!

[^note:grav]: In Grav, it is possible to create a hidden content page for storing multi-language versions of site configurations, but this approach requires the use of a custom theme that supports this feature.

[^write-to-learn]: Dallas Lu. [...原始文章是你自己写的，这个理解程度是他人作品所不能比的。整个过程既有输出的强化练习，又有高效地学习吸收...](https://x.com/dallaslu/status/1785720867571601637). 𝕏. 2024-05-01.
[^hejiayan]: 何加盐. [中文互联网正在加速崩塌](https://www.cnbeta.com.tw/articles/tech/1431972.htm). cnBeta. 2024-05-23. [MP](https://mp.weixin.qq.com/s/afg3zHPpEyRzSfOR1Aeh3w).
[^isolation]: darmau. [We are witnessing the insularization of Chinese civilization](https://darmau.co/en/article/we-are-witnessing-isolation-of-chinese-civilization). darmau.co. 2024-08-13.