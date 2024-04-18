---
title: 自动挂载交换分区
date: '2008-11-10 11:23'
author: 'dallaslu'

taxonomy:
    category:
        - Ubuntu
    tag:
        - Swap
        - Ubuntu

---
话说，自从某次我调整了交换分区的大小之后，我的Ubuntu不能开机自动挂载交换分区了。虽然没有什么大碍，最后还是Google解决了。

===

其现象如下，交换区显示“0字节（0.0％）来自0字节”。

![系统监视器截图](system-monitor.png)

之后一番搜寻之后发现大概是这么个原因：__对Swap重新调整大小之后，UUID值发生了变化__，但是 `/etc/fstab` 中的设置，并没有随之改变。

于是乎，执行：

```bash
sudo gnome-open /dev/disk/by-uuid
```

另开终端，执行：

```bash
sudo gedit /etc/fstab
```

对比 `/dev/disk/by-uuid` 中的文件名称，来判定swap分区的UUID值，将其填写到 `/etc/fstab` 中。

按说，到这里应该可以了。但是，依然没有自动挂载。下面是网友 <a href="http://www.ubuntu-tw.org/modules/newbb/viewtopic.php?post_id=26382#forumpost26382" target="_blank">cel570818</a> 给出的办法。

>  $sudo swapoff$sudo fdisk /dev/hda按P记下 /hda3 的 Blocks 的数值按Q$sudo mkswap -c /dev/hda3 数值

但是执行之后依旧没有解决这个问题。（……请原谅我如此罗嗦 － －｜）

猛地想起，这次操作后，Swap分区的UUID值再次发生了变化。然后以前面所讲的办法修改 /etc/fstab ，重启问题解决。
