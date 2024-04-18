---
title: The Nostr Behind Damus
date: '2023-03-09 03:09'
published: true
license: CC-BY-4.0
taxonomy:
    category:
        - Internet
    tag:
        - Damus
        - Nostr
        - Microblogging
keywords:
  - Principles of Nostr
  - Drawbacks of Nostr
  - Features of Nostr

review:
  item:
     type: WebApplication
     name: Nostr
     description: "Nostr is a protocol built using self-owned account/identities so that it enables us to create 'decentralized' social networks and even other types of solutions"
     url: 'https://github.com/nostr-protocol/nostr'
     image: 'https://ph-files.imgix.net/dcf83fad-eaa2-4c58-a3fe-95317a20cb55.jpeg'
     screenshots: 
       - "https://ph-files.imgix.net/aef9b320-af4f-4258-9f82-32b9470a5f3c.png"
  rating: 8
sameAs: https://www.producthunt.com/products/nostr/reviews?review=747123
---

The recent release of the social software Damus has sparked widespread discussion. The Nostr protocol it utilizes is fascinating, with principles that are very simple. Some say Nostr resembles a keyserver without a synchronization mechanism, but I think it's more akin to the early internet's forum groups.

===

Nostr uses key pairs to confirm user identities, with actions such as posting content defined within a scalable Event structure. Each Event must be signed with a key and is then distributed among users via Relays. Relays operate independently, without a mandated mechanism for synchronizing data among them.

This design has several obvious benefits, such as:

* Users can seamlessly migrate to other Relays if banned by one
* The content posted by users is undeniable due to signatures
* The network transmits content in JSON format Events, facilitating backups
* ……

However, there are also some drawbacks:

* Lack of a true delete function
* Disastrous consequences of key leaks, necessitating some cybersecurity knowledge from users

Many are initially fascinated by Nostr but become skeptical after further study, raising concerns such as:

* Lack of anti-spam mechanisms in current client and relay implementations
* Absence of moderation systems to prevent violent or child pornography content
* Potential disconnection from users who rely on specific relays
* Continuous relay switching may result in the loss of earlier content
* Potential emergence of dominant relays leading back to centralization

In the era when internet forums thrived, "forum surfing" was a popular pastime for many. Larger forums featured numerous sections, while smaller ones specialized in specific topics. Individuals frequented several forums, encountering familiar users across different platforms and possibly sharing or forwarding their threads across multiple forums. When a forum closed, some posts might disappear from the internet, but distributed content often remained. It was impractical to browse all forum posts, nor was anyone aware of every forum's existence, yet this did not hinder our ability to communicate through forums.

Nostr represents an improved version of this forum network model. Clients and relays can collaborate to filter spam or implement strict moderation systems. These details are insignificant; the Nostr network will continue to exist. Anyone can find a comfortable way to use it, including users and operators. Hypothetically, if Weibo fully integrated into the Nostr network, it would establish a relay with real-name registration and a strong moderation system; if Twitter joined, its relay would still be blocked in mainland China. Nostr has some effectiveness against censorship, but not much. If self-hosted relays could bypass censorship, governments would require all domestic relays to have appropriate licenses. However, if both Weibo and WeChat joined the Nostr network, a standard Nostr client could connect to both networks, easily migrating from one platform to another.

Of course, these are all hypothetical scenarios, as governments and traditional centralized platforms would not favor Nostr. One reason is that content, if sufficiently outstanding and widely disseminated on Nostr, is difficult to disappear from the internet merely because a relay ceases operation, and users might follow the content to new relays. If sheep could migrate quickly and unrestrictedly between farms, neither the wolf unable to catch them nor the farmer unable to sell them would be pleased.

Some applications have attempted to use keys for encryption or signatures on traditional social networks, making the choice between WhatsApp and WeChat irrelevant. However, like PGP, this also requires a trust relationship, and the communication channels are borrowed, very loosely tied. Nostr represents a further specialized solution.

Last year, Clubhouse became popular, making one marvel that in 2022, people were still fascinated with voice chat rooms. Perhaps 2023 will be the year forums become popular again. Thus, I've also contemplated improvements to the forum model. Traditional forums had two significant issues affecting discovery: content could only be found by browsing sections or sorting by latest posts, replies, and highlights, and following discussions in threads with many posts was challenging. Later, microblogging introduced following users and trending topics to improve content discovery and used threads to track conversations. It'll be interesting to see what new ideas Nostr brings. Damus, as the first Nostr client to gain widespread attention, indeed faces some issues and has room for improvement. Let's look forward to the development of Damus and Nostr!