---
title: 用 Beancount 解决生意头脑类趣味数学题
date: '2022-04-14 04:14'
license: CC-BY-SA-4.0
taxonomy:
    category:
        - Software
    tag:
        - Beancount
        - Bookkeeping
keywords:
  - 一共亏了多少
  - 他赚了多少钱
  - 还有一元钱去了哪里
  - Beancount 示例
toc:
  enabled: true
---

很久以前流传着一些类似脑筋急转弯的数学题，帮一个生意人算账，看看他到底是赔了还是赚了。往往大家会持不同意见，即使最后公布了答案，很多人还会转不过弯来，只好自嘲一句做生意太难了！那么，使用 Beancount 记账来解决这些问题，会不会更清晰明了呢？

===

## 赔本生意收假币（钻石戒指交易）

> 王师傅是卖鱼的，一公斤鱼进价46元。现市场价大甩卖35元一公斤。顾客买了一公斤，给了王师傅100元假钱，王师傅没零钱，于是找邻居换了100元。事后邻居存钱过程中发现钱是假的，被银行没收了，王师傅又赔了邻居100元。
> 请问王师傅一共亏了多少?

```beancount
option "operating_currency" "CNY"

1948-12-01 commodity CNY
1948-12-01 commodity CNY.FAKE
1970-01-01 commodity FISH
  name: "鱼/公斤"

1948-12-01 price CNY.FAKE 0 CNY

1970-01-01 open Assets:Cash ;现金
1970-01-01 open Assets:Fish FISH ;鱼的库存
1970-01-01 open Liabilities:Payable ;债务
1970-01-01 open Income:Sales

1970-01-01 * "进货一公斤鱼"
  Assets:Cash                                           -46 CNY @@ 1 FISH
  Assets:Fish

1970-01-01 * "顾客" "收款" ^sale
  Assets:Cash                                           100 CNY.FAKE ;收100元假币
  Liabilities:Payable

1970-01-01 * "邻居" "换零钱"
  Assets:Cash                                          -100 CNY.FAKE ;交给邻居
  Liabilities:Payable                                   100 CNY.FAKE ;邻居收下假币
  Liabilities:Payable                                  -100 CNY ;邻居交出真币
  Assets:Cash                                           100 CNY ;拿到零钱

1970-01-01 * "顾客" "找零及交付" ^sale
  Assets:Cash                                           -65 CNY ;找零
  Assets:Fish                                            -1 FISH @@ 35 CNY
  Liabilities:Payable

1970-01-01 * "邻居" "索赔"
  Assets:Cash                                          -100 CNY ;赔偿
  Liabilities:Payable

1970-01-01 * "顾客" "顾客已逃跑，债权作废"
  Liabilities:Payable                                  -100 CNY
  Income:Sales
```

或者完全忽略假币，不记录任何 `CNY.FAKE` 的交易。

最终我们来看看资产负债表：

| | CNY | Other|
|-| ---:| ----:|
| Assets | -111 | -0 FISH |
| __Cash | -111 | |
| __Fish |      | -0 FISH |

| | CNY | Other|
|-| ---:| ----:|
| Liabilities | | |
| __Payable | | |

| | CNY | Other|
|-| ---:| ----:|
| Equity | 111 | 0 FISH |
| __Conversions | 11 | 0 FISH |
| ____Current | 11 | 0 FISH |
| __Earnings | 100 | |
| ____Current | 100 | |

| | 123 | 456 |
|-| ---:| ---:|
|1| 0.1|| 0.2 |

<table>
  <tr>
    <th><th>
    <th>123<th>
    <th>456<th>
  </tr>
  <tr>
    <td>1</td>
    <td>0.1</td>
    <td>0.2</td>
  </tr>
</table>

结果很直观，现金由进货前的 0 元，变成了 -111 元；其中转换（倒卖鱼）损失 11 元，其他交易损失 100 元，共计损失 111 元。

邻居和银行的最终资产变化是 0，所以完全不记录这二位的换钱、没收过程，也不影响最终结果。

如果顾客自己也有一个账本，那么他用一张无价值的假币，换到了 65 元和 1 公斤鱼。鱼原价 46 元，共计收入 111 元。为什么不是按鱼的售价 35 元来计算，进而得出收入 100 元呢？因为正常买鱼的人，就已经白赚 11 元了，最后结果还是 111 元。或者我们只说，他收入的只是 65 元和 1 公斤鱼；如果他将赃物鱼转手出售，则会有额外的盈亏，也就是另一个问题了。

## 买入卖出（买马交易）

> 一个人花9块钱买了一只鸡，然后10块钱卖掉了，之后他觉得不划算，又花11块钱买回来了，12块钱卖给另一个人，问他赚了多少钱？

```beancount
option "operating_currency" "CNY"

1948-12-01 commodity CNY
1970-01-01 commodity CHICKEN
  name: "鸡/只"

1970-01-01 open Assets:Cash ;现金
1970-01-01 open Assets:Chicken ;鸡库存

1970-01-01 * "买鸡"
  Assets:Cash                                            -9 CNY @@ 1 CHICKEN
  Assets:Chicken

1970-01-01 * "卖鸡"
  Assets:Chicken                                         -1 CHICKEN @@ 10 CNY
  Assets:Cash

1970-01-01 * "买鸡"
  Assets:Cash                                           -11 CNY @@ 1 CHICKEN
  Assets:Chicken

1970-01-01 * "卖鸡"
  Assets:Chicken                                         -1 CHICKEN @@ 12 CNY
  Assets:Cash
```

几乎不用贴表了。两次买入卖出各赚1元，一共2元。如果拒绝了别人的12元出价，选择不卖鸡，那么他手里剩下一只鸡，成本为 $9-10+11=10$ 元。所以认为是10元买入，若最终还是选择12元卖出，则赚了2元，也说得通。

这也意味着，无论价格多高，只要有人以更高的价格接盘，那么你总是会赚钱的。

## 消失的一元钱（少了的法郎）

> 有3个人去投宿，一晚30元。三个人每人掏了10元，凑够30元交给了老板。后来老板说今天优惠只要25元就够了，拿出5元命令服务生退还给他们, 服务生偷偷藏起了2元, 然后把剩下的3元钱分给了那三个人，每人分到1元。这样，一开始每人掏了10元，现在又退回1元，也就是 10-1=9，每人只花了9元钱，3个人每人9元，3 X 9 = 27 元，加上服务生藏起的2元等于29元，还有一元钱去了哪里？请给合理解释！

```beancount
option "operating_currency" "CNY"

1948-12-01 commodity CNY

1970-01-01 open Assets:Cash:A ;现金
1970-01-01 open Assets:Cash:B ;现金
1970-01-01 open Assets:Cash:C ;现金
1970-01-01 open Expenses:Hotel
1970-01-01 open Income:Rebate
1970-01-01 open Equity:UFO

1970-01-01 * "老板" "支付费用"
  Assets:Cash:A                                         -10 CNY
  Assets:Cash:B                                         -10 CNY
  Assets:Cash:C                                         -10 CNY
  Expenses:Hotel

1970-01-01 * "老板" "退回费用"
  Income:Rebate                                          -5 CNY
  Assets:Cash:A                                           1 CNY
  Assets:Cash:B                                           1 CNY
  Assets:Cash:C                                           1 CNY
  Equity:UFO

```

资产负债表：

| | CNY | Other|
|-| ---:| ----:|
| Assets | -27 | |
| __Cash | -111 | |
| ____A | -9 | |
| ____B | -9 | |
| ____C | -9 | |

| | CNY | Other|
|-| ---:| ----:|
| Equity | 27 | |
| __Earnings | 25 | |
| ____Current | 25 | |
| __UFO | 2 | |

可以明显发现，三人消费 27 元，其中 25 元交给了老板，2 元被服务生贪污。问题中「加上服务生藏起的2元」是一句误导。

怎么样，找到生意头脑了吗，快把 Beancount 用起来吧！

PS：以上的数学问题原始版本为 [测试你有没有经理头脑](https://www.cnblogs.com/skylaugh/archive/2006/09/13/503501.html)