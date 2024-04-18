---
title: Amazon EC2 与 VPSYOU
date: '2011-05-19 12:59'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - VPSYOU
        - Amazon

---
《[WordPress 在云端](http://zhengyong.net/marketing/wordpress-on-amazon-ec2.html)》这篇教程直白全面，但是少了对价格的描述；正好我前几天也因为免费而去试用了 EC2，后来经我确认没有获得免费的资格，所以也看了一下价格，所以想以本博客为例将EC2与正在用的 VPSYOU 进行一下成本对比。

===

本博客正在使用的是[VPSYOU](http://billing.vpsyou.com/aff.php?aff=139)的X360，因为优惠获赠了1/2的内存，也就是540M内存。硬盘空间13G，九折后$13.5元/月。这是全部花销了。

EC2 的收费规则比较复杂，根据[官方的价格说明](http://aws.amazon.com/ec2/pricing/)，如果我想把本博客迁移到EC2，那么我将每月花费：

## EC2主机租用 $0.025 \*24 \*30 = $18

<a href="https://dallas.lu/files/2011/05/micro.jpg"><img alt="" class="alignnone size-medium wp-image-1204" height="150" src="https://dallas.lu/files/2011/05/micro-300x150.jpg" title="micro" width="300"/></a>

出于国内访问速度和成本考虑，我将选择美国西海岸的Micro方案，提供512M的内存。

## 数据传输 $0.1+ $0.15\*(5-1) = $0.7

传入数据 \$0.1/G，传出数据 \$0.15/G，本博客最多也就5G流量，1G内不收费。

## EBS租用 $0.11\*8 = $0.88

选用占用空间最小的AMI大概都在8G左右，而本博客对空间要求比较小。

最后的花费是 $19.7。

## 两种方案对比：

<table>
<tbody>
<tr>
<th></th>
<th>VPSYOU</th>
<th>Amazon EC2 Micro</th>
</tr>
<tr>
<td>内存</td>
<td>540M</td>
<td>512M</td>
</tr>
<tr>
<td>开销</td>
<td>$13.5/M</td>
<td>$19.7/M</td>
</tr>
<tr>
<td>包含流量</td>
<td>300G</td>
<td>5G</td>
</tr>
<tr>
<td>空间大小</td>
<td>13G</td>
<td>8G</td>
</tr>
</tbody>
</table>

## 结论

本博客还是原地立正，暂时别折腾了。
