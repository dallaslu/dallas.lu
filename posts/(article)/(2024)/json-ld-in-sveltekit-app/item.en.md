---
title: Using JSON-LD in SvelteKit Applications
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

Using SvelteKit it is very easy to create web applications with SSR, but for SEO we need to add some metadata like JSON-LD to the page.This article will explain how to use JSON-LD in SvelteKit applications.

===

## What is JSON-LD

JSON-LD is a data structure that uses the JSON format to describe the semantics of data. It is a format used to add structured data to web pages, which helps search engines to better understand the content of web pages. JSON-LD is a very important technique when it comes to SEO. JSON-LD
defines an embedded syntax for embedding structured data in HTML documents. Generally we use the data structure provided by Schema.org to describe the data.

## Current Status of JSON-LD Use in SvelteKit

The +layout in SvelteKit adds a layout to each page. Adding JSON-LD data to the layout adds structured data to the structure of the entire site. Adding JSON-LD
data to a page adds structured data to the content of the page. But at the same time, JSON-LD data can be added to +page.svelte, which describes the content of the page. SvelteKit doesn't automatically handle the relationship between the two for us automatically, we need to work around this manually.

## Practices for adding JSON-LD data to SvelteKit

We can pre-organize the JSON-LD data in +layout.ts and then add the JSON-LD data for the page in +page.svelte. This is a good solution to the problem of JSON-LD data. We can add in +page.svelte the JSON-LD output:

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

Where `ldjson` is the generic JSON-LD data from the parent layout and `creativeWork` is the JSON-LD data for the current page. We can add our own JSON-LD data to the page and merge it into `ldjson`. This is a good solution to the JSON-LD data problem. In +layout.ts, you can:

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

## Use schema-dts

In TypeScript, we can use Schema type definitions to describe JSON-LD data.This allows for better organization of JSON-LD data.We can use the [schema-dts](https://www.npmjs.com/package/schema-dts) maintained by Google

```bash
npm install -D --save schema-dts
```

Then use it in +page.svelte：

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

## Conclusion

Using JSON-LD in SvelteKit applications can help search engines better understand page content.We can pre-organize the JSON-LD data in +layout.ts and then add the JSON-LD data of the page in +page.svelte.This is a good solution to the problem of JSON-LD data.We can use schema-dts to better organize JSON-LD data. This can better describe the semantics of the data. Some of my previous reviews have used JSON-LD data, and my ratings have been shown in Google search results.