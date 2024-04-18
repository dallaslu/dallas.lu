---
title: 卸载 Gnome3 后恢复启动 Logo
date: '2013-12-18 18:57'
author: 'dallaslu'

taxonomy:
    category:
        - Ubuntu
    tag:
        - Ubuntu

---
Gnome 3 很漂亮，但是在任务切换方面，倒不如 Unity 简洁。所以本着不折腾的原则卸载了。恢复了 Ubuntu 13.10 自带的登录管理器 LightDM 后，还有启动时的 logo（splash screen）仍是 Gnome 风格的。

最后，在 [http://ubuntuguide.org/wiki/Ubuntu:Saucy\#Change\_Plymouth\_Splash\_Screen](http://ubuntuguide.org/wiki/Ubuntu:Saucy#Change_Plymouth_Splash_Screen) 找到了更改的办法：

```bash
sudo update-alternatives --config default.plymouth
sudo update-initramfs -u
```

然后按提示输入编号，选择想要使用的 Splash Screen 即可。
