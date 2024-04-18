---
title: Ubuntu 14.04 上使用中州韵五笔拼音
date: '2014-12-23 23:10'
author: 'dallaslu'

taxonomy:
    category:
        - Ubuntu
    tag:
        - Ibus
        - Rime
        - Trusty
        - Ubuntu

---
在 Window 7 上用了相当一段时间的小狼毫输入法，感觉不错。于是尝试在 Ubuntu 上使用其 Linux 版本——中州韵，根据其 [iBus 安装说明](https://code.google.com/p/rimeime/wiki/RimeWithIBus) 使用 `sudo apt-get install ibus-rime` 安装的版本太低了；安装说明里提到的 PPA 源又没有 Ubuntu 14.04 ( Trusty ) 适用的安装包。和遇到同样问题的 [lanking](http://www.slblog.net/) 一样只好下载编译。根据 [Ubuntu 12.04 安装手记](https://code.google.com/p/rimeime/wiki/RimeWithIBus#ibus-rime_on_Ubuntu_12.04_%E5%AE%89%E8%A3%9D%E6%89%8B%E8%A8%98)，将实践过程中可能会遇见的问题补充如下。

===

## 安装程序库

后续的编译提示找不到需要的 marisa 库，在这一步需额外执行：

```bash
sudo apt-get install libmarisa-dev
```

## 下载编译安装 yaml-cpp

本地 gcc 版本为 4.8.1，根据 Rime 下载页面的说明，需要下载 brise-0.35，librime-1.2，ibus-rime-1.2 这三个文件。后续的编译提示需要 yaml-cpp 0.5 以上版本，所以安装手记中 yaml-cpp 的安装过程应如下：

```bash
wget http://yaml-cpp.googlecode.com/files/yaml-cpp-0.5.1.tar.gz
tar xzf yaml-cpp-0.5.1.tar.gz
cd yaml-cpp-0.5.1
mkdir build
cd build
cmake -DBUILD_SHARED_LIBS=ON ..
make
sudo make install
```

## 下载编译安装 Rime

```bash
wget http://dl.bintray.com/lotem/rime/brise-0.35.tar.gz
wget http://dl.bintray.com/lotem/rime/librime-1.2.tar.gz
wget http://dl.bintray.com/lotem/rime/ibus-rime-1.2.tar.gz
tar xzf brise-0.35.tar.gz
tar xzf librime-1.2.tar.gz
tar xzf ibus-rime-1.2.tar.gz
cd ibus-rime
```
./install.sh
```

## 启用五笔拼音

```bash
sudo cp /usr/share/rime-data/wubi86.schema.yaml ~/.config/ibus/rime
sudo chown your_username ~/.config/ibus/rime
```

关于输入法状态栏的图标样式、繁简转换、图标文件请参考 lanking 的文章《[Ubuntu 14.04 配置 Rime 五笔输入法](http://www.slblog.net/2014/04/configure-ibus-rime-wubi-schemas-on-ubuntu-14-04/http://)》。
