---
title: 使用 Nextcloud 同步 Tabby 配置文件
date: '2021-07-28 12:21'
author: 'dallaslu'
license: WTFPL
taxonomy:
    category:
        - Software
    tag:
        - Nextcloud
        - SSH
        - Tabby

---
[Tabby](https://github.com/Eugeny/tabby) 是一个免费开源的跨平台 SSH 终端，支持 macOS 和 Windows。但并未像 Termius 一样提供配置文件的同步功能。好在可以自己用 Nextcloud 之类的云盘软件自己实现。

===

!!!! __2022-12-26__ 可尝试更简单稳定的方案，如 Tabby 中自带的 Cloud Sync，或插件 Settings Sync。

Windows 中，Tabby 的配置文件是 `%USERPROFILE%\AppData\Roaming\tabby\config.yaml`（配置文件的位置可通过 Tabby 的`Settings`&gt;`Config File`&gt;`Show config file` 来获取 ），同目录下还有很多其他的程序文件、文件夹，我们当然只希望单独同步 `config.yaml` 这一个文件。而 Nextcloud 只支持同步文件夹。所以我们可以创建一个文件链接，让真实的 `config.yaml` 与另外一个专用文件夹中的 `config.yaml` 对应起来，以方便同步。鉴于 Windows 不能创建跨盘符的文件链接，为了更直观，我们选择使用 Nextcloud 的单独指定文件夹的同步功能。

## 同步配置、使用

### Windows

经过实验，Windows 中 Tabby 并不能正确处理链接类型的文件。所以我们保留 `%USERPROFILE%\AppData\Roaming\tabby\config.yaml`，创建一个链接文件以供 Nextcloud 同步。

在 `%USERPROFILE%\AppData\Roaming\tabby\` 目录中操作：

```bash
mkdir config
cd config
mklink /H config.yaml ..\config.yaml
```

然后在 Nextcloud 的设置界面中添加同步文件夹，本地目录为 `%USERPROFILE%\AppData\Roaming\tabby\config`，远程目录可以参考我的设置：`Applications/Tabby/config`。

### macOS

通过 Tabby 的`Settings`&gt;`Config File`&gt;`Show config file` 来获取配置文件位置。退出 Tabby 应用后，在 tabby 目录中操作：

```bash
mkdir config
mv config.yaml config
ln -s config.yaml config/config.yaml
```

同样在 Nextcloud 客户端中添加一个同步文件夹，将本地的 `Tabby/config` 目录与远程的 `Applications/Tabby/config` 进行同步。

### 使用

Tabby 没有动态加载配置文件的功能，所以如果你在另一台机器上修改过配置，那么请重启一下需更新配置的 Tabby 实例。

## 密钥配置

我们在不同的电脑上，可能使用了不同的 SSH 密钥，如果是相同的操作系统，倒是可以使用同样的文件名，避免需要单独修改的麻烦。不过，在 Tabby 中 Windows 与 macOS 的密钥路径配置是不一样的，也不能使用 `~/.ssh/id_rsa` 这种形式。

好在 Tabby 支持添加多个密钥，在 Profile 配置中，点击 `Add a private key` 即可添加。比如 Windows 中是 `C:\Users\dallaslu\.ssh\id_rsa`，而 macOS 中是 `file:///Users/dallaslu/.ssh/id_rsa`。在进行 SSH 连接时，Tabby 会逐个路径尝试，直到成功为止。

## 跳板配置

可能某些电脑的环境需要配置跳板，某些不需要。配置文件的同步会覆盖 Tabby 实例上的 Profile 跳板配置。建议这种情况就复制两个 Profile 吧。
