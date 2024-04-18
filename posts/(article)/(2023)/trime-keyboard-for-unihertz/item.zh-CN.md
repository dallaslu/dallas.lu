---
title: 适用 Unihertz 全键盘手机的 Trime 键盘方案
date: '2023-05-26 05:26'
published: false
license: CC-BY-NC-SA-4.0
taxonomy:
  category:
    - Internet
  tag:
    - Rime
    - Trime
    - Android
    - Unihertz
keywords:
  - Unihertz 输入法
  - Unihertz 五笔拼音
---

全键盘手机的一个好处是，使用输入法时无需开启占据半屏的虚拟键盘。Unihertz 作为目前少有的有全键盘机型的手机品牌，也贴心地提供了一个定制的输入法，只支持拼音。所幸 Android 上也有 Rime 输入法实现，就是 Trime。Trime 也不是为全键盘开发，所以我们需要为其定制一个虚拟键盘方案。

===

毕竟是实体键盘，物理案件无法新增，很多时候还是需要动态的虚拟键盘辅助。比如需要临时切换九宫格输入数字、根据提示输入特殊符号。Unihertz 的独家键盘设计，缺少方向键和一大批常用符号。另外候选词也占据了至少一行文字的屏幕空间。Trime 默认也带了一套迷你虚拟键盘的方案，但并不适合 Unihertz 手机。

## Trime

注意，截至本文发表时，Google Play 中 Trime 的版本为 3.1.3。我使用的是版本是 3.2.10，是从 F-Droid 上安装的。如果你在其他版本中遇到了问题，可以在 F-Droid 上选择指定版本 3.2.10，从这个版本开始使用。

Trime 的配置文件路径是 `/storage/emulated/0/Applications/Rime`，共享文件夹和用户文件夹分别对应两个子目录：`share` 和 `user`。可以在 Trime App 的「配置管理」中看到。如果「配置管理」中的路径显示为空白，建议手动指定一下。



`trime.custom.yaml`
```yaml
# Trime 自定义
patch:
  "style/locale": zh_CN # 添加为汉语简体
  "style/show_preview": false #按鍵提示
  "style/show_comment": false #顯示提示區
  "style/key_sound": false
  "style/color_scheme": lost_temple
  "style/text_size": 14
  "style/key_height": 30
  "style/key_text_size": 20
  "style/keyboard_height": 175
  "style/keyboard_height_land": 140
  "style/round_corner": 3 #按鍵圓角半徑
  "style/keyboards/+": [mini2]
  "preset_keys/Keyboard_mini2": {label: 迷你, send: Eisu_toggle, select: mini2}
  "preset_keyboards/default/height": 30
  "preset_keyboards/mini/keyboard_height": 42
  "preset_keyboards/mini/height": 30
  "preset_keyboards/mini/keys":
    - {click: Keyboard_symbols, long_click: Escape}
    - {click: '`', long_click: '``{Left}', swipe_up: '~'}
    - {click: '$', long_click: '%'}
    - {click: '&', long_click: '^'}
    - {click: '=', long_click: '<>{Left}', swipe_left: '<', swipe_right: '>'}
    - {click: ';', long_click: redo}
    - {click: Left, long_click: Home, swipe_left: Home, swipe_up: Page_Up}
    - {click: Down, long_click: Up, swipe_up: Up}
    - {click: Right, long_click: End, swipe_right: End, swipe_down: Page_Down}
    - {label: '☰', click: Keyboard_mini2, long_click: Keyboard_default}
  "preset_keyboards/letter/height": 30
  "preset_keyboards/qwert0/height": 30
  "preset_keyboards/qwert_/height": 30
  "preset_keyboards/qwert/height": 30
  "preset_keyboards/us_intl/height": 30
  "preset_keyboards/number/height": 30
  "preset_keyboards/symbols/height": 30
  "preset_keyboards/bopomofo/height": 30
  "preset_keyboards/cangjie5/height": 30
  "preset_keyboards/cangjie6/height": 30
  "preset_keyboards/scj6/height": 30
  "preset_keyboards/stroke/height": 30
  "preset_keyboards/telegraph/height": 30
  "preset_keyboards/terra_pinyin/height": 30
  "preset_keyboards/array30/height": 30
  "preset_keyboards/mini2":
    name: 精简键盘2
    ascii_mode: 0
    author: "dallaslu"
    width: 10
    height: 30
    keyboard_height: 84
    lock: false #切換程序時記憶鍵盤
    keys:
      - {click: Keyboard_symbols, long_click: Keyboard_number}
      - {click: '~', long_click: '(){Left}', swipe_left: '(', swipe_right: ')'}
      - {click: '%', long_click: '[]{Left}', swipe_left: '[', swipe_right: ']'}
      - {click: '^', long_click: '{}{Left}', swipe_left: '(', swipe_right: ')'}
      - {click: '|', long_click: "''{Left}", swipe_left: "'", swipe_right: "'"}
      - {click: '\\', long_click: '""{Left}', swipe_left: '"', swipe_right: '"'}
      - {click: Insert }
      - {click: Up, long_click: Page_Up, swipe_up: Page_Up}
      - {click: Delete}
      - {click: liquid_keyboard_switch, long_click: liquid_keyboard_clipboard}
      - {click: Mode_switch, long_click: Menu}
      - {click: undo}
      - {click: redo}
      - {click: '<'}
      - {click: '>'}
      - {click: '…', long_click: liquid_keyboard_emoji}
      - {click: Left, long_click: Home, swipe_left: Home}
      - {click: Down, long_click: Page_Down}
      - {click: Right, long_click: End, swipe_right: End}
      - {label: '☰', click: Keyboard_mini, long_click: Keyboard_default}
```