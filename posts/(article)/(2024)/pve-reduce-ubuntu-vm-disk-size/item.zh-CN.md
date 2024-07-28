---
title: 在 PVE 中缩小 Ubuntu 虚拟机的磁盘
date: '2024-02-11 11:02'
author: 'dallaslu'
published: true
taxonomy:
    category:
        - Internet
    tag:
        - PVE
        - Ubuntu
license: CC-BY-NC-SA-4.0
keywords:
  - PVE shrink vm disk
  - PVE reduce vm disk
  - PVE 减小缩减虚拟机硬盘
toc:
  enabled: true
---

在 PVE 中，使用其 WebUI 就能方便地扩展磁盘。所以当你创建虚拟机时，不必分配过大的磁盘。终于有一天你意识到磁盘过大时，还是有机会的。本文记述为一台 Ubuntu 虚拟机缩小磁盘的经历和方法。

===

本站运行在一台虚拟机中，另外一台 Ubuntu 虚拟机中运行着 Nginx 作为前端。这台前置机最初分配的磁盘大小是 128GB，实际上运行大半年后，磁盘占用仅不到 10GB。对磁盘空间要求属实不多，新增的一些文件不过是些日志、配置备份。所以我计划缩减其分配的磁盘空间至 32GB ，方便备份和转移到 SSD 上。若未来空间需求增长，可随时扩容，或另行挂载一块 HDD 磁盘作为日志和备份的存储空间。

如果你也有同样的需求，可以在**数据有安全的备份**的情况下，按如下操作尝试。相比LXC 容器的磁盘缩小[^lxc-reduce-disk]，VM 的磁盘调整更复杂，需要先在 VM 内压缩磁盘释放空间后，再到 PVE 中操作，最后再回到 VM 中修复分区。

## 信息收集

为避免 IO 错误、数据丢失[^lvreduce-warning]，应该先在虚拟机中压缩分区大小。在此之前，应该在 PVE 管理界面中为虚拟机做一个备份。

接下来登录 Ubuntu 虚拟机，查看当前磁盘分区：

```bash
lsblk
```

这台 Ubuntu 虚拟机在安装系统时，使用了默认的分区设置，分区表为 MBR。（如果你的分区表是 GUID，那请参考 Egidio Docile 的文章：[How to manipulate gpt partition tables with gdisk and sgdisk on Linux](https://linuxconfig.org/how-to-manipulate-gpt-partition-tables-with-gdisk-and-sgdisk-on-linux)）

一共分为三个分区，硬盘设备路径是 `/dev/sda`，最后一个分区挂载为根目录。运行：

```bash
df -h
```

检查磁盘空间使用情况，以确认调整方案是否可行。

## SystemRescueCD

接下来使用 [SystemRescueCD](https://www.system-rescue.org)[^pve-resize-disks]来处理磁盘。

从 <https://www.system-rescue.org/Download/> 获得 ISO 下载链接，到 PVE 中从 URL 添加 ISO 镜像。将该镜像挂载到 Ubuntu 虚拟机中，并从光盘启动。进入系统后运行：

```bash
startx
```

来进入桌面环境。

## 信息确认

打开 GParted 来查看当前分区情况。运行：

```bash
lvs
lvdisplay
```

确认目标分区的使用情况，以及设备路径。这里假设是 `/dev/ubuntu-vg/ubuntu-lv`。

## 压缩磁盘

!!! WARNING 再次确认是否有可用的备份，继续操作有可能导致数据丢失！

### 在虚拟机中压缩卷

继续压缩虚拟卷，运行：

```bash
lvreduce --resizefs --size -96G /dev/ubuntu-vg/ubuntu-lv
```
### 调整分区大小

使用 GParted 将分区大小调整为合适的大小，在目标分区上右键->`Move/Resize`，压缩目标分区的大小，释放未分配空间。

### 在 PVE 中压缩卷

回到 PVE shell，运行：

```bash
lvresize --size -96G /dev/pve/vm-100-disk-0
```

注意，此步骤如果操作有误，还有机会挽回：

```bash
lvresize --size +96G /dev/pve/vm-100-disk-0
```

为 PVE 系统能正确显示磁盘大小，还需要执行[^qm-rescan]：

```bash
qm rescan
```

## 修复分区表

重启虚拟机，重新进入 SystemRescue，运行：

```bash
fdisk -l
```

会提示 `GPT PMBR mismatch...`。运行：

```bash
gdisk /dev/sda
```

1. 输入 `v` 验证修复分区表；
2. 输入 `w` 写入分区表。

再次运行 `fdisk -l` 来验证。

## 结束

移除 CD/DVD 驱动器，重启虚拟机。如果你的系统或数据有任何问题，那么祝福你的备份还在 :)

[^lxc-reduce-disk]: Yomi Ikuru. [Proxmox - Resizing a LXC Disk](https://yomis.blog/proxmox-resizing-a-disk/). Yomi’s Blog. 2021.
[^lvreduce-warning]: Feng. [Proxmox VE (PVE) lvm thin 减小缩减虚拟机硬盘设置的空间大小](https://www.d3tt.com/view/116). D3TT. 2019. 「需要先从虚拟机内部缩小分区，然后再执行下边操作，比较繁琐，易翻车，务必先备份数据」
[^pve-resize-disks]: <https://pve.proxmox.com/wiki/Resize_disks> 'If you reduce (shrink) the hard disk, of course removing the last disk plate will probably destroy your file system and remove the data in it! So in this case it is paramount to act in the VM in advance, reducing the file system and the partition size. SystemRescueCD comes very handy for it, just add its iso as cdrom of your VM and set boot priority to CD-ROM. '
[^qm-rescan]: aaron. [Reply to lumox in 'How to resize a VM's disk'
 #6](https://forum.proxmox.com/threads/how-to-resize-a-vms-disk.79349/post-351732). Proxmox Forum. 2020.