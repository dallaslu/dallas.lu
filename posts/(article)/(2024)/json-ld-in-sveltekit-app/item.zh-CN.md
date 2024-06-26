---
title: 在 SvelteKit 应用中使用 JSON-LD
published: true
date: '2024-05-14 05:14'
license: CC-BY-NC-SA-4.0
taxonomy:
  category:
    - Internet
  tag:
    - SEO
    - SvelteKit
keywords:
  - SvelteKit JSON-LD
  - JSON-LD
toc:
  enabled: true
---

使用 SvelteKit 可以很轻松地创建 SSR 的网站应用，但是在 SEO 方面，我们需要在页面中添加一些元数据，比如 JSON-LD。本文将介绍如何在 SvelteKit 应用中使用 JSON-LD。

===

## JSON-LD 是什么

JSON-LD 是一种使用 JSON 格式的数据结构，用于描述数据的语义。它是一种用于在网页上添加结构化数据的格式，可以帮助搜索引擎更好地理解网页内容。在 SEO 方面，JSON-LD 是一种非常重要的技术。JSON-LD
定义了一种嵌入式的语法，用于在 HTML 文档中嵌入结构化数据。一般我们使用 Schema.org 提供的数据结构来描述数据。

## SvelteKit 中使用 JSON-LD 的现状

SvelteKit 中的 +layout 可以为每个页面添加一个 layout。在 layout 中添加 JSON-LD 数据，可以为整个网站的结构添加结构化数据。在页面中添加 JSON-LD
数据，可以为页面的内容添加结构化数据。但与此同时， +page.svelte 中也可以添加 JSON-LD 数据，用于描述页面的内容。SvelteKit 并不能为我们自动处理二者之间的关系。我们需要手动解决这个问题。

## 在 SvelteKit 中添加 JSON-LD 数据的实践

我们可以在 +layout.ts 中预先组织 JSON-LD 数据，然后在 +page.svelte 中添加页面的 JSON-LD 数据。这样可以很好地解决 JSON-LD 数据的问题。我们可在 +page.svelte 中加入
JSON-LD 的输出：

```html
<script lang="ts">
    export let data;

    $: ({ ldjson } = data);

    let ldjson = () => {
        let creativeWork = {
            "@context": "https://schema.org",
            "@type": "CreativeWork",
            "name": "Example Creative Work",
            "author": {
                "@type": "Person",
                "name": "Jane Doe"
            }
        };
        return Object.assign({}, ldjson, creativeWork);
    }
</script>

<svelte:head>
    {@html `<script type="application/ld+json">${JSON.stringify(
        json(),
    )}</script>`}
</svelte:head>
```

其中 `ldjson` 是来自父级 layout 的通用 JSON-LD 数据，`creativeWork` 是当前页面的 JSON-LD 数据。我们可以在页面中添加自己的 JSON-LD 数据，然后合并到 `ldjson` 中。这样就可以很好地解决 JSON-LD 数据的问题。在 +layout.ts 中，可以:

```javascript
import type { Load } from '@sveltejs/kit';

export const load: Load = async ({ fetch, params, depends, data }) => {

    const ldjson: any = {
        '@context': 'https://schema.org',
    };

    ldjson.issn = '1234-5678';

    return { ldjson };
}
```

## 使用 schema-dts

在 TypeScript 中，我们可以使用 Schema 类型定义来描述 JSON-LD 数据。这样可以更好地组织 JSON-LD 数据。我们可以使用由 Google 维护的 [schema-dts](https://www.npmjs.com/package/schema-dts)

```bash
npm install -D --save schema-dts
```

然后在 +page.svelte 中使用：

```javascript
import type {
    WithContext,
    Article as SchemeArticle,
    Review,
    CreativeWork,
    WebPage,
} from "schema-dts";

let post: any = {};

let json = () => {
    
    let creativeWork: CreativeWork = {
        "@type": "CreativeWork",
        headline: post.title,
        image: post.image,
        datePublished: new Date(post.date).toISOString(),
        url: post.url,
    };

    if (post.authors) {
        let author = post.authors.map((author: any) =>
            Object.assign(
                {
                    "@type": "Person",
                    name: author.name || author.account || author,
                },
                author.url
                    ? {
                          url: author.url,
                      }
                    : {},
            ),
        );
        if (author.length === 1) {
            author = author[0];
        }
        creativeWork.author = author;
    }

    if (post.modified?.date) {
        creativeWork.dateModified = new Date(
            post.modified.date,
        ).toISOString();
    }
    if (post.summary) {
        creativeWork.description = post.summary;
    }

    if (post.aggregateRating) {
        creativeWork.aggregateRating = {
            "@type": "AggregateRating",
            ratingValue: post.aggregateRating.value,
            reviewCount: post.aggregateRating.count,
            bestRating: post.aggregateRating.best || 10,
            worstRating: post.aggregateRating.worst || 1,
        };
    }

    if (post.template == "item") {
        if (post.review) {
            creativeWork = Object.assign(creativeWork, {
                "@type": "Review",
                itemReviewed: {
                    "@type": post.review.item?.type,
                    name: post.review.item?.name,
                    url: post.review.item?.url,
                    image: post.review.item?.image,
                },
                reviewRating: {
                    "@type": "Rating",
                    ratingValue: post.review.rating,
                    bestRating: 10,
                    worstRating: 1,
                },
                reviewBody: post.review.body || post.summary,
            } as Review);
        } else {
            creativeWork = Object.assign(creativeWork, {
                "@type": "Article",
            } as SchemeArticle);
        }
    } else if (post.template == "links") {
        creativeWork = creativeWork as WithContext<CreativeWork>;
    } else if (post.template == "default") {
        creativeWork = Object.assign(creativeWork, {
            "@type": "WebPage",
        } as WebPage);
    } else {
        creativeWork = creativeWork as WithContext<CreativeWork>;
    }

    let schema: WithContext<any> = Object.assign(creativeWork, {
        "@context": "https://schema.org",
    });

    return Object.assign({}, ldjson, schema);
};
```

## 结语

在 SvelteKit 应用中使用 JSON-LD 可以帮助搜索引擎更好地理解网页内容。我们可以在 +layout.ts 中预先组织 JSON-LD 数据，然后在 +page.svelte 中添加页面的 JSON-LD 数据。这样可以很好地解决 JSON-LD 数据的问题。我们可以使用 schema-dts 来更好地组织 JSON-LD 数据。这样可以更好地描述数据的语义。我之前写的一些评测文章，也使用了 JSON-LD 数据，在 Google 的搜索结果中已经显示了我给出的评分数据。