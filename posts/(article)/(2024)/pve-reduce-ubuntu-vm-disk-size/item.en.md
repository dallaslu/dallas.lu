---
title: Shrinking the disk of an Ubuntu VM in PVE
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
  - PVE shrink VM disk
  - PVE reduce VM disk
  - PVE Reduce Shrink Virtual Machine Hard Disk
toc:
  enabled: true
---

In PVE, it is easy to expand the disk using its WebUI. So when you create a VM, you don't have to allocate an oversized disk. There is still a chance when you finally realize that the disk is too big. This article describes the experience and methodology of shrinking a disk for an Ubuntu VM.

===

This site is running in a VM with another Ubuntu VM running Nginx as the frontend. The frontend machine was originally allocated 128GB of disk space, but after running for half a year, it's actually taking up less than 10GB of disk space, which isn't a lot of space, and some of the new files are just logs and configuration backups. So I'm planning to reduce the allocated disk space to 32GB for backup and transfer to SSD. If the space requirement grows in the future, I can expand the capacity at any time, or mount another HDD disk as the storage space for logs and backups.

If you have the same need, you can try it as below with **a safe backup of your data**. Compared with disk reduction [^lxc-reduce-disk] for LXC containers, disk resizing for VMs is more complicated, you need to compress the disk in the VM first to free up space, then go to PVE to operate, and finally go back to the VM to repair the partition.

## Information Collection

To avoid IO errors, data loss[^lvreduce-warning], you should compress the partition size in the VM first. Before that, you should make a backup of the VM in the PVE management interface.

Next, log in to your Ubuntu VM and view the current disk partition:

```bash
lsblk
```

This Ubuntu VM uses the default partition settings when installing the system, and the partition table is MBR. (If you have a GUID partition table, then see Egidio Docile's article,[How to manipulate gpt partition tables with gdisk and sgdisk on Linux](https://linuxconfig.org/how-to-manipulate-gpt-partition-tables-with-gdisk-and-sgdisk-on-linux)）

The hard disk is divided into three partitions, the device path is `/dev/sda`, and the last partition is mounted as the root directory. Run:

```bash
df -h
```

Check disk space usage to verify that the tuning solution is feasible.

## SystemRescueCD

Next use [SystemRescueCD](https://www.system-rescue.org)[^pve-resize-disks] for disks

Get the ISO download link from <https://www.system-rescue.org/Download/>, go to PVE and add the ISO image from the URL. Mount the image in an Ubuntu virtual machine and boot from the CD. Once inside the system, run:

```bash
startx
```

to access the desktop environment.

## Information Confirmation

Open GParted to view the current partitioning. Run:

```bash
lvs
lvdisplay
```

Confirm the usage of the target partition, and the device path. Here it is assumed to be `/dev/ubuntu-vg/ubuntu-lv`.

## Reduce Disk

!!! WARNING Double-check that there is a backup available; continued operation may result in data loss!

### Reduce Disk in VM

To continue reduce the virtual volume, run:

```bash
lvreduce --resizefs --size -96G /dev/ubuntu-vg/ubuntu-lv
```
### Resizing a Partition

Use GParted to resize the partition to a suitable size, right-click on the target partition -> `Move/Resize` to compress the size of the target partition and free up unallocated space.

### Resize Disk in PVE

Back to PVE shell, run:

```bash
lvresize --size -96G /dev/pve/vm-100-disk-0
```

Note that this step has a chance to be undone if done incorrectly:

```bash
lvresize --size +96G /dev/pve/vm-100-disk-0
```

For the PVE system to display the disk size correctly, it is also necessary to perform [^qm-rescan]:

```bash
qm rescan
```

## Repairing the Partition Table

Reboot the VM, re-enter SystemRescue, run:

```bash
fdisk -l
```

It will prompt `GPT PMBR mismatch... `. Run:

```bash
gdisk /dev/sda
```

1. Enter `v` to verify that the partition table is repaired;
2. Enter `w` to write to the partition table.

Run `fdisk -l` again to verify.

## Ending

Remove the CD/DVD drive and restart the VM. If you have any problems with your system or data, then bless you that your backup is still there :)

[^lxc-reduce-disk]: Yomi Ikuru. [Proxmox - Resizing a LXC Disk](https://yomis.blog/proxmox-resizing-a-disk/). Yomi’s Blog. 2021.
[^lvreduce-warning]: Feng. [Proxmox VE (PVE) lvm thin 减小缩减虚拟机硬盘设置的空间大小(Reducing the amount of space set aside for VM hard disks)](https://www.d3tt.com/view/116). D3TT. 2019. "需要先从虚拟机内部缩小分区，然后再执行下边操作，比较繁琐，易翻车，务必先备份数据 (You need to shrink the partition from inside the VM first, and then perform the following operations, more cumbersome, easy to turn over, be sure to back up the data first!)"
[^pve-resize-disks]: <https://pve.proxmox.com/wiki/Resize_disks> 'If you reduce (shrink) the hard disk, of course removing the last disk plate will probably destroy your file system and remove the data in it! So in this case it is paramount to act in the VM in advance, reducing the file system and the partition size. SystemRescueCD comes very handy for it, just add its iso as cdrom of your VM and set boot priority to CD-ROM.'
[^qm-rescan]: aaron. [Reply to lumox in 'How to resize a VM's disk'
 #6](https://forum.proxmox.com/threads/how-to-resize-a-vms-disk.79349/post-351732). Proxmox Forum. 2020.