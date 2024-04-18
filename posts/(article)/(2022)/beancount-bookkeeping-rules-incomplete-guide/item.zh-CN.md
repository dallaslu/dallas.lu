---
title: 'Beancount 记账规则不完全指北'
date: '2022-02-21 21:02'
author: dallaslu
published: true
license: CC-BY-NC-SA-4.0
taxonomy:
    category:
        - Internet
    tag:
        - Beancount
        - Bookkeeping
keywords:
  - Beancount 记账入门
  - Beancount Payee 子账户
  - Beancount 怎么记
  - Beancount 退款怎么记
  - Beancount 报销
  - Beancount 多成员
toc:
  enabled: true
---

基于文本的记账软件 Beancount 给了使用者极大的自由，同时也容易让新手感到迷惑，总是有人在问某种情况下的账该怎么记、要记成什么样。

===

我在使用 Beancount 时，一直践行着以下两个原则：

* 关心则记，不关心则不记
* 有限精力投入，力求详尽以体现真实流水

「关心则记」是一个万能回答，「陈年老账要导入吗？」「信用卡积分变动要记吗？」「电商优惠要记成收入吗？」等等「要不要」的问题，都可以先问问自己：你 Care 这些吗？如果只关心大宗资产账户，一些只有零星交易的小额账户，完全可以忽视；如果只关心总资产，一些交易则不必过分细分到消费账户。这将节省大量的精力。

假设你决心要控制自己的食品支出，则应在精力允许的范围内，为食品类消费制定详尽的支出科目，并记录商家、详情、时间、说明、商品规格等等任何有用的信息。不用担心 Beancount 或 Fava 无法利用这些附加信息，因为账本是文本格式，这些信息在浏览账本回顾时很有用，甚至简单地文本搜索就能帮助你了解自己买过多少次无糖可乐。

解决了「要记什么」和「要记得多详细」的问题，我们才能接着讨论一些如何记得详细的规则或技巧。

## Payee 还是子账户？

使用 Payee:
```beancount
2022-02-21 * "张三" ""
  Assets:Cash                                          -100 USD
  Assets:Recievables
```

使用子账户
```beancount
2022-02-21 * "张三借款"
  Assets:Cash                                          -100 USD
  Assets:Recievables:张三
```

Payee 非常简便，可以方便地查找各种账户往来。但子账户更容易单独统计，麻烦之处在于借出与借入可能要分别开一个 Assets 和 Liabilities 账户。另外，在包含多个 Posting 的交易中，子账户更清晰。比如：
```beancount
2022-02-01 * "Walmart" "超市结账"
  Assets:Cash                                          -100 USD
  Liabilities:Payable:李四
  Expense:Food                                          150 USD
```

不过，如果你有好友在做微商，你们之间的借入、借出、消费、收入恐怕得各建一个子账户了，小心账户数量爆炸。

综上，可优先使用 Payee，针对交易频繁、需要明确追踪的特殊情况，再使用子账户。历史记录也可以通过替换账本内容或利用插件把 Payee 转换成子账户。针对频次低的复杂交易，可以在 Posting 上添加 meta:
```beancount
2022-02-01 * "Walmart" "超市结账"
  Assets:Cash                                          -100 USD
  Liabilities:Payable
    payee: 李四
  Expense:Food                                          150 USD
```

## 退款（返现、折扣等）是收入还是负支出？

退款记成收入或负支出，都不影响平衡；使用链接 (如`^2022-02-21_00001`) 也很容易回顾。甚至还可以删掉支出记录，不过这仅限于全额退款，并且与真实流水不一致，给对账造成干扰。我们讨论几个常见的电商场景。

### 抢茅台

如果抢到了 1500 元的茅台，转手 2500 元卖掉，应该是支出 1500 元、收入 2500 元，而不是酒水消费 -1000 元。如果退掉，记成负支出则最终酒水消费 0 元；记成收入则虚增了 1500 元的收入与支出，若在支出与收入统计中不关注退款，却希望单独统计，则可记录到权益账户(`Equity:Expense` 和 `Equity:Income`)中。

似乎退款是负支出，转卖则是收入，非常符合直觉。

### 京东保价

如果买了一台 iPhone，突然市场价格下降，获得了 100 元保价退款，则两种记法看上去没有区别，全凭主观意愿。

### Amazon Prime / 京东 Plus 免运费

如果记录运费，则必然要记一条收入来冲抵这笔运费。如果你关心买电商会员到底值不值，还是记下为妙。

### 购物节折扣

以日常入手价格的八折买下一台笔记本，算是收入两成吗？也许一部分人给出肯定的答案。换一个例子，以 100 万元拍到市值 250 万的房产，按常识来说，只是当时市场价值 250 万，具体收入多少直到卖出的那一刻根据售价计算之后才知道。或许笔记本价格的两成，也应该计入到未变现收入的权益（`Equity:Unrealized`）中。

经过针对这几个例子的思考总结，可以得出大致结论：
* 负支出：正常交易流程中发生真实退款
* 收入：正常交易流程外发生变现，预期之外的退款
* 权益：有预期变现行为但尚未发生，有独立于支出与收入的统计需要

## 报销的类目如何体现？

一般报销会简单地记成：

```beancount
2022-02-21 * "Hilton" "住宿"
  Assets:Cash                                          -500 USD
  Assets:Recievables:Reimburse
```

如果要体现住宿消费，记成下面这样又显得罗嗦：

```beancount
2022-02-21 * "Hilton" "住宿"
  Assets:Cash                                          -500 USD
  Expense:Hotel                                         500 USD
  Expense:Hotel                                        -500 USD
  Assets:Recievables:Reimburse
```

其实可以仅添加一条金额为 0 的 Posting:
```beancount
2022-02-21 * "Hilton" "住宿"
  Assets:Cash                                          -500 USD
  Expense:Hotel                                           0
  Assets:Recievables:Reimburse
```

## 账户内资金流转

如果从多个账户汇总资金到某一账户，再度进行交易，建议按真实转账顺序排列 posting:

```beancount
2022-02-21 *
  Assets:A                                             -500 USD
  Assets:B                                              -10 USD
  Assets:C                                              510 USD
  Liabilities:D                                        -510 USD
```

这样更直观。同样出于直观的目的，Beancount 允许在一个交易中，省略一条 Posting 的金额，建议省略在消费、收入、权益的账户上，保留资产负债账户（我们可能在这些账户上使用 balance 校对余额）的金额，这样更方便对账。如果 Posting 过多或金额数字杂乱，建议不省略任何金额，以求查看文本账本时不需要再按计算器。

## 多成员消费怎么记？

如果你有两只宠物猫，今天去了宠物医院分别做了检查和治疗，则可使用 Posting 的 meta 来记录成员消费：

```beancount
2022-02-21 *
  Assets:Cash                                         -1000 USD
  Expenses:Pet                                          200 USD
    member: 'A'
  Expenses:Pet
    member: 'B'
```

多成员消费理论上也可以用子账户来记，不过鉴于消费科目一般较多，可能会导致子账户爆炸。

## Fava 怎么方便地查看交易备注？

使用 `;` 添加的注释会被 Beancount 忽略，如果要针对 Posting 添加说明，仍可以利用万能的 meta:
```beancount
2022-02-21 * "Walmart" "超市购物"
  Assets:Cash                                          -200 USD
  Expenses:Food                                        -150 USD
  Expenses:Other
    narration: "打破玻璃杯赔付款"
```

## 摊销、分期类交易怎么记？

如果你在年初时预付这一年的房租，简单记录为房租支出，那么 1 月份支出就会偏高，其他月份支出就会偏少。当你评估在这个城市的生活成本时，不得不去关注整年的总消费；如果有多宗周期交叉的预付支出，就更难以了解每个月的实际情况。按理来说，预付一年的房租，资产的确在支付时减少了；但消费是逐月落实的。合理的记法应该是：

```beancount
2022-01-01 * ^rent-2022
  Assets:Cash                                        -12000 USD
  Expenses:Rent                                        1000 USD
  Equity:Prepayment

2022-02-01 * ^rent-2022
  Equity:Prepayment                                   -1000 USD
  Expenses:Rent

2022-03-01 * ^rent-2022
  Equity:Prepayment                                   -1000 USD
  Expenses:Rent
```

如果是提前一个月支付：

```beancount
2021-12-01 * ^rent-2022
  Assets:Cash                                        -12000 USD
  Expenses:Rent                                           0
  Equity:Prepayment

2022-01-01 * ^rent-2022
  Equity:Prepayment                                   -1000 USD
  Expenses:Rent

;...
```

值得留意的是，Beancount 允许我们提前记下未来的交易，这些交易若只涉及权益和消费账户，是不影响资产统计的；同时也很容易地以时间参数来过滤掉这些未来交易。

或者使用 meta 来描述这种周期特性，设定合同的开始日期、周期长度等信息，可使用 [beancount-periodic](https://github.com/dallaslu/beancount-periodic) 插件来自动处理这些周期交易：

```beancount
2021-12-01 * ^rent-2022
  Assets:Cash                                        -12000 USD
  Expenses:Rent
    amortize: "12 Months @2022-01-01 / Monthly"
```

若用上了插件，甚至精确到星期、日，也不算难事。资产折旧也一样，不过是从资产账户流向消费账户、周期不同罢了。

## 科目突然需要细分，账户如何规划？

如今订阅制大行其道，可能一开始你全部记录到 `Expenses:Subscription` 中，突然想关注具体分类的支出（如音乐和视频），旧的交易怎么办，新交易又如何记呢？不妨先将 `Expenses:Subscription` 批量替换为 `Expenses:Subscription:Unspecified`，然后再建立一些具体科目：

```beancount
2022-02-01 open Expenses:Subscription:Music
2022-02-01 open Expenses:Subscription:Video

2022-02-21 *
  Liabilities:CreditCard:A                              -10 USD
  Expenses:Subscription:Music
```

有精力时再将 `Expenses:Subscription:Unspecified` 逐个地改到新科目下。之所以建立一个 `Unspecified` 的子账户，是因为当前 Beancount 对涉及非子叶账户（有子账户的账户）的统计上有些小问题，也许未来版本会解决，届时只要把 `Expenses:Subscription:Unspecified` 替换为 `Expenses:Subscription` 即可。

也可以尝试一下插件「[非子叶账户别名](https://gist.github.com/dallaslu/f63f4b61994f37ec06e6143616855807)」插件来自动创建 Unspecified 账户。

## 总结

Beancount 灵活的账户系统和 meta 功能提供了无限可能。尤其是 meta，不仅支持数字和文本，还允许以账户作为值（虽然暂时未想到使用场景）。记账时做到清楚、明确，无论 Beancount 如何发展都可安心。当你最终抵达财富自由的彼岸，账本就是你的航海日记，见证着一次乘风破浪的伟大航行。