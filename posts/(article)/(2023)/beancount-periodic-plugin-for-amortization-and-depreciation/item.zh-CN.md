---
title: Beancount 摊销与折旧的使用以及相关插件
date: '2023-08-28 08:28'
published: true
license: CC-BY-ND-4.0
taxonomy:
  category:
    - Software
  tag:
    - Beancount
    - Bookkeeping
keywords:
  - Beancount摊销
  - Beancount折旧
  - Beancount插件
  - Beancount周期交易
toc:
  enabled: true
x.com:
  status: https://x.com/dallaslu/status/1696349425818611731
nostr:
  note: note1zmpz9x6x5ud6cxzdrl9nfgjwfuppfq030jhlaa0qxs35e5qua38qcuqym9
---

Beancount 等复式记账软件让个人也能方便地使用会计的记账技巧，逐渐养成看报表来评估财务状况的习惯。当某月有大笔支出时，就需要将支出摊销到未来的几个月，以更好地反映生活成本。本文探讨摊销和折旧的使用经验，以及介绍相关插件。

===

## 个人记账需要摊销和折旧吗

举一个曾经举过的例子[^rent-example]，如果你在年初时预付了一年的房租，那么在每个月的报表中，都应该看到房租支出的一笔；而不是只在年初看到一笔。因为房租的一般计价就是按月，当你考虑是否要搬家时，你也会考虑到每个月的房租支出。如果在非年初时间签合同、签署了一年以上的合同，情况也更复杂。而摊销之后，每个月的报表都会看到房租支出，这样就更容易做出决策了。

同样的道理，如果你在年初购买了一台电脑，那么每个月的月报表中，都应该看到电脑折旧的一笔。这样在未来，你转卖二手电脑时，也能更好地反映出电脑的价值[^sspai-real-cost]。每次看到 MBP 出新，我都会感叹我的 2015款还能再战五年。如果是 2000 USD购入，计划使用2年[^note:depreiation-peroid]，之后二手还能卖上 200 USD，那么平均每月是 30 USD，这样的成本是可以接受的。

## 摊销与折旧怎么记

摊销与折旧这两种操作都是将一笔交易拆分成多笔交易，分摊到未来，每笔交易的金额都是原交易的一部分。

不同的是，一般摊销在企业中一般用来计算无形资产，折旧用来计算有形资产。个人账本中，无形资产一般不会太多，可以混用，或者只用其中一种。比如年付的房租，可以理解为无形资产，你付钱买到的是限时居住权；而电脑或汽车则是有形资产，你付钱买到的是产品本身。

也可以认为摊销是用来计算消费的，折旧是用来计算资产的。看你如何看待这些交易了。

### 摊销房租

比如记录年付款房租，原本记为：

```beancount
2023-01-01 *
  Assets:Cash          -12000 USD
  Expenses:Rent
```

现金账户直接流入了租金消费账户。摊销则可改为：

```beancount
2023-01-01 * ^rent-2023
  Assets:Cash          -12000 USD
  Expenses:Rent          1000 USD
  Equity:Prepayment

2023-02-01 * ^rent-2023
  Equity:Prepayment     -1000 USD
  Expenses:Rent

2023-03-01 * ^rent-2023
  Equity:Prepayment     -1000 USD
  Expenses:Rent

;... 未来月份省略
```

权益账户 `Equity:Prepayment` 作为临时账户，用来记录摊销的金额；每个月再记一笔该账户到租金消费账户的转账，金额为摊销的一部分。这样每个月的报表中，都会看到租金支出的一笔。

这个临时账户根据个人喜好和需要，可以为任何类型，比如 `Expenses:Unamortied`（待摊销费用）、`Assets:Prepayment`（预付资产）等等。我建议选择 `Equity` 类型的原因是，它不会影响资产负债表的总额，而且在报表中也不会显示。在你支付房租的那一刻，现金的确减少了 12000 USD，但消费还没有落实到每一个月中，用 Equity 账户更加合理。

如果你的账本中有多种摊销，可以为每种摊销创建一个临时账户，比如 `Equity:Prepayment:Rent`、`Equity:Prepayment:Insurance` 等等。

### 折旧电脑

前面讨论提到，折旧与摊销可以混用，比如购买了一台电脑，也可以以摊销的形式记录消费（好像信用卡分期那样），也可以记成资产折旧。如果记成折旧，先改成购入资产：

```beancount
2023-01-01 *
  Assets:Cash          -2000 USD
  ;Expenses:Digital ;不再记录为消费
  Assets:Computer
```

有没有一种像是在运营一家公司，进行优化资产结构的感觉？你的钱并没有凭空消失，只是换了一种形式陪在你身边，这种感觉很好。

![你的钱并没有凭空消失](./pony-money.jpg)

折旧可追加记录：

```beancount
2023-01-01 *
  Assets:Computer            -30 USD
  Expenses:Digital

2023-02-01 *
  Assets:Computer            -30 USD
  Expenses:Digital

2023-03-01 *
  Assets:Computer            -30 USD
  Expenses:Digital

;... 未来月份省略
```

### 改进

上面的例子中，每个月都要记一笔交易，这样的操作很繁琐。当然，Beancount 允许我们提前记下未来的交易，可以使用时间参数过滤掉未来的交易。但这样的操作仍然不够方便，因为每个月都要记一笔交易，而且还要记得修改日期。这时候就需要使用插件了。

## 插件 beancount-periodic

接下来把上面的例子改成以插件实现。推荐一下我写的插件 [beancount-periodic](https://github.com/dallaslu/beancount-periodic)，我自己也一直在使用。

房租的例子：

```beancount
2023-01-01 *
  Assets:Cash          -12000 USD
  Expenses:Rent
    amortize: "1 Year /Monthly"
```

电脑的例子：

```beancount
2023-01-01 *
  Assets:Cash          -2000 USD
  Expenses:Digital
    depreciate: "5 Year /Monthly =200"
```

只要将原本的交易中需要摊销或折旧的 posting 加入一个特殊的 meta，就可以了。其内容是描述摊销或折旧的规则，比如总周期、开始时间、金额、残值等等。插件会自动计算出每个月的摊销或折旧金额，生成对应的交易。

当你转卖电脑时，不需记成收入与负支出[^note:depr-resell]。关于折旧的残值 200 USD，是在开始计算折旧时的预估值。可以根据转时的市场价，来调整最初记录中的残值。比如转卖后，将残值改为实际成交金额 100 USD。在未来回顾和调整，可以更真实地反映生活成本。

另外此插件还支持以年、日为周期的摊销与折旧，以及重复交易等功能。关于插件的安装过程、meta 语法规则等详细使用说明，请参考 [README](https://github.com/dallaslu/beancount-periodic#readme)。

在去年七月份，我在 JetBrains 续费了全家桶，因为有优惠，一直买到了 2025年7月份。这笔交易是这样记的：

```beancount
2022-07-14 * "JetBrains" "AllProductsPack2022~2025"
  time: "11:45:00"
  Liabilities:CreditCard:CN:CMB:6687         -369.38 USD
  Expenses:Shopping:Software                  149.25 USD
    narration: "AllProductsPack2023"
    amortize: "@2022-07-26~2023-07-25 /Monthly"
  Expenses:Shopping:Software                  220.13 USD
    narration: "AllProductsPack2025"
    amortize: "@2023-07-26~2025-07-13 /Monthly"
```

一次性付费 369 USD，实际上包含了两个订单。插件会为这两个订单共计生成36条交易。上个月刚好第二个订单开始生效。

![Jetbrains Amortize](./jetbrains-amortize-2025.png)

如图所示，第一个订单每月摊销成本大约 12.5 USD[^note:amortized-amount]，而第二个订单月成本就降到了 9.3 USD。这样的成本是可以接受的，因为我每天都在使用 JetBrains 的产品，而且我也不会再去关注 JetBrains 的产品是否有新版本了。

除此之外，我还用这个插件记录了一些其他的类似交易，比如 Github Copilot 年付、DMIT VPS 三年付、宽带预付款等等。各种服务的年度会员也可以用这个插件来记录。

另有其他插件可供选择：

* [beancount_interpolate](https://github.com/Akuukis/beancount_interpolate) 

## 结语

持续关注你的真实生活成本，等哪一天你的被动收入超过了生活成本，你就可以选择不再工作了。或者先定个小目标，先实现 IDE/VPS/Copilot 自由。

[^note:depreiation-peroid]: 企业中对不同种类的资产折旧有不同的期限，一般至少2年以上。个人账本则无需严格遵守此惯例。
[^note:depr-resell]: 折旧的资产出售时，需要将残值从资产账户中转出，转入现金账户。
[^note:amortized-amount]: 149 USD / 12 = 12.43 USD，累计的四舍五入的误差会计算在最后一个月中，所以6月份的成本为 12 USD

[^rent-example]: Dallas Lu. [《Beancount 记账规则不完全指北》](https://dallas.lu/beancount-bookkeeping-rules-incomplete-guide/#摊销、分期类交易怎么记？). 2022.「摊销、分期类交易怎么记？」
[^sspai-real-cost]: ElijahLee. [《折旧摊销在个人记账中的应用》](https://sspai.com/post/40718). 少数派. 2018. 「报表不能真实地反映生活成本」
