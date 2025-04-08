---
title: 访问 ChatGPT 终极方案：IPRoyal 美国家宽 IP
date: '2023-05-18 05:18'
published: true
license: WTFPL
taxonomy:
  category:
    - Internet
  tag:
    - IPRoyal
    - Cloudflare
    - ChatGPT
    - Residential
keywords:
  - 美国家宽
  - 美国家宽IP
  - 美国住宅IP
  - Socks代理
  - Socks5代理
  - 原生 IP 购买
  - 美国家宽机场
review:
  item:
     type: WebApplication
     name: IPRoyal
     description: "One of the best proxy services with more than 8,003,349 IP's"
     url: 'https://iproyal.com/?r=dallaslu'
     image: 'https://ph-files.imgix.net/542f3c51-8a73-48b9-a27f-2f7d60fa1b51.png'
     screenshots: 
       - "https://ph-files.imgix.net/717088fe-33a0-4dd9-a7a5-e4003d651c47.png"
  rating: 10
sameAs: https://www.producthunt.com/products/iproyal/reviews?review=747126
x.com:
  status: https://x.com/dallaslu/status/1662348585634246656
nostr:
  note: note1tcqekzt27f2hg6fhdj6zjqa0d47crkvxaa6f3r8rjpkxu66c3dys9jwkcc
---

近期套 Warp 用 ChatGPT 的人越来越多。毕竟 Warp 的出口 IP 数量还是有限的，尽管 Warp 不会被 block，却因同 IP 人数过多常常触发 OpenAI 的访问频率限制，也就是部分接口返回 429 错误，表现为 chat.openai.com 页面大面积空白，页面上方中间显示一朵 loading 菊花。我也试过数个美国机房的原生IP，无一例外都是 blocked。与其再另找机场，不如一步到位，使用美国家宽 IP。

===

## IPRoyal 注册与购买

IPRoyal 提供 20 多个国家和地区的家宽 IP，并有静态和非静态两款产品。其中非静态是按流量收费，2 GB 流量的价格大约是 \$12。为了「一步到位」，最好还是静态家宽IP，价格是 90 天 \$10.8。基本都是买得越多折扣越大[^iproyal-pricing-static]。就权当是 ChatGPT Plus 涨价了几美元吧。

访问 IPRoyal：[https://iproyal.com/?r=dallaslu](https://iproyal.com/?r=dallaslu) (Aff) (或者 [直接访问](https://iproyal.com/))，点击 `Register` 按钮注册。注册时填写的手机号和国家等，建议与注册时所用 IP 保持一致，以确保最后能购买成功。验证邮箱后，就算注册成功了。

不过要购买静态家宽(`Static Residential`) IP 还需要做身份认证（KYC），这一点大家可能有疑虑，不过也很好理解，使用周期内该 IP 为你一人独占，如果你拿去做些访问儿童色情之类的敏感行为，FBI 免不了要找到你 Warning 一下吧。其使用 Identy 平台的认证服务，支持大陆身份。

支持多种付款方式，包括信用卡和 Paypal，还支持 BTC(仅充值消费)。

购买成功后，在邮件或 IPRoyal 后台中能看到代理 IP 端口、用户名和密码，支持 socks5 和 http。可以使用如下命令验证:

```bash
curl --proxy socks5://USER:PASS@IP:PORT ipinfo.io
```

## 使用

如果你在大陆，为了避免风险，还是建议在你的线路的美国出口处使用家宽代理。或者将买到的家宽代理 IP 加入代理规则名单，来个 SOCKS5 over GFW-Fucker。

在服务器节点上，可以设置 Socks5 代理，让整个系统的流量都经过家宽 IP。尽管 IPRoyal 并未明确地声明对静态家宽 IP 的带宽和流量限制，但出于提升使用体验的目的，最好还是做分流或者按需切换使用，一些不需家宽 IP 的服务直连访问，以求获得最高速度。各种现代代理服务软件应该都支持按域名设置代理线路，具体方式这里就略了。或者，可以将所有发往 Cloudflare 的流量都转发到家宽线路。比如，我尝试过分流 Warp，那么可以按[之前的方案](/redirect-cloudflare-traffic-back-to-warp/)，修改 redsocks 配置文件：

```ini showLineNumbers
redsocks {
        local_ip = 127.0.0.1;
        local_port = 12345;

        ip = IP;
        port = PORT;

        type = socks5;

        login = "USER";
        password = "PASS";
}
```

终于可以正常使用 ChatGPT 了：

![ChatGPT Plus Works](./chatgpt-plus.png)

同时，可以另行添加转发规则，将 Netflix、Google 等目标流量转发到家宽线路，以避免出现人机验证、服务锁定等影响使用体验的情况，充分发挥家宽的优势。

## 其他

另有一个住宅家宽代理提供商 SpaceProxy([https://spaceproxy.net](https://spaceproxy.net?ref=80864) [https://proxyline.net](https://proxyline.net?ref=209726))，成本更低。使用优惠码 `dallaslu` 可以获得 95折的优惠。

有了家宽 IP，给 ChatGPT 付费应该也会容易一些了。希望大家都能成功「对抗两个超级大国」[^super-two]。

[^iproyal-pricing-static]: [IPRoyal 静态住宅 IP 价格表](https://iproyal.com/pricing/static-residential-proxies/)
[^super-two]: h2ruk1. [充值openai简直就是同时对抗两个超级大国....](https://x.com/h2ruk1/status/1658362135037239297). 𝕏. 2022-05-16.
