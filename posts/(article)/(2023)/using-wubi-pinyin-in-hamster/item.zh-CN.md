---
title: 在仓输入法中使用五笔拼音
date: '2023-05-23 05:23'
published: true
taxonomy:
  category:
    - Software
  tag:
    - Rime
    - Hamster
    - iOS
license: WTFPL
keywords:
  - 仓输入法
  - 仓输入法自定义
  - 五笔拼音输入法
---

五笔拼音混合输入真的很快乐。此前我一直在 iOS 上使用 iRime 输入法，现在有了新选择：Hamster，也叫仓（鼠）输入法。相比较起来，Hamster 更加简洁，和其他平台上的 Rime 实现更相像。安装完 Hamster 后，默认是没有五笔拼音方案的。下面介绍一下在 Hamster 导入五笔拼音的办法。

===

!!! __2024-09-04__ 建议尝试更新活跃的 [rime-wubi86-jidian](https://github.com/KyleBing/rime-wubi86-jidian)。

## 五笔方案

五笔拼音输入方案（wubi_pinyin）基于于五笔86（wubi86）和袖珍简化字拼音（pinyin_simp）两个方案。

先访问袖珍简化字拼音 https://github.com/rime/rime-pinyin-simp ，里面包含两个我们需要的文件`pinyin_simp.dict.yaml`和`pinyin_simp.schema.yaml`，下载备用。再访问五笔86和五笔拼音 https://github.com/rime/rime-wubi ，下载其中的4个 YAML 文件。

在电脑上创建文件 `default.custom.yaml`：

```yaml
patch:
  schema_list:
     - {schema: wubi_pinyin}
     - {schema: wubi86}
     - {schema: pinyin_simp}
```

如果你想使用其他方案，亦可在此处添加。可直接访问仓库获取以上文件：<https://github.com/dallaslu/rime-wubi-pinyin>

## 使用方案

[仓输入法](https://github.com/imfuxiao/Hamster) 是一个很新的输入法应用。从 [App Store](https://apps.apple.com/cn/app/id6446617683) 下载安装。

### 使用「Wi-Fi 上传方案」

打开仓输入法应用，选择「输入方案上传」，单击「启动」按钮。用与手机连到同一 Wi-Fi 的电脑访问 App 页面显示的地址，在 Web 管理界面中，将上述 7 个文件上传到 `/Rime` 文件夹中。

回到仓输入法 App 主页，点击「重新部署」。如果在「输入方案」功能中看到了新增的「五笔・拼音」方案即为成功。

### 使用「输入法方案导入」

通过 IM 工具或邮件，将上述文件做成 zip 压缩包，保存在 iOS 的文件中。打开仓输入法应用，选择「输入方案设置」，单击右上的加号按钮，选择导入方案，选择该 zip 文件即可。

## 设置拼音提示五笔编码

打开仓输入法 App，进入「键盘设置」->「候选栏设置」，打开「显示候选 Comment」开关。

![使用拼音输入时自动提示五笔编码](wubi-pinyin.jpg)

## Sync

实际上我很少在 Android 和 iOS 设备上做 Rime 的同步，主要是嫌麻烦。在仓输入法中，可以在「其他设置」中找到 Rime 的同步选项，在 `installation.xml` 中增加 `sync_dir` 配置，可同步到 iCloud 上，进一步与其它平台上的 Rime 应用同步。

我觉得还是有点麻烦。就像用 Logseq 的 App 时，文档也只能通过 iCloud 同步，常常在急用某文档时，要等 Windows 上 iCloud 缓慢地同步文件，一看文件名还是 `2023-05-24(2).md`，同步还会失败，不同步不让用，只能等。好在 Rime 同步是一个低频的行为，同步时不影响输入法使用。

## 其他

之前用的 iRime 也不错，只不过近来一直被一个 Bug 困扰，输入完一个符号之后，整个输入法键盘就停止响应了，需要切换输入法才行。切换到仓输入法也略有些不习惯，比如我一直没找到输入 `:` 和 `@` 的办法。总体来说体验还是不错的，加上 Android 平台的同文输入法（Trime），全平台五笔拼音的感觉太好了。
