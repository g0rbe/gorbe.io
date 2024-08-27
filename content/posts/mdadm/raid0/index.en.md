---
title: "Create RAID0 with mdadm"
description: "Create and manage RAID0 with mdadm on Linux."
summary: "Create and manage RAID0 with mdadm on Linux."
date: 2023-11-15T03:32:28+01:00
tags: ["linux", "raid", "mdadm"]
keywords: ["linux", "raid", "mdadm"]
aliases: ["/docs/mdadm/raid0"]
---

RAID (***R***edundant ***A***rray of ***I***nexpensive ***D***isks) is a data storage virtualization technology that combines multiple physical disk drive components into one or more logical units for the purposes of data redundancy, performance improvement, or both.

I create the raid on partitions instead of on disks. Here is why: https://unix.stackexchange.com/questions/320103/whats-the-difference-between-creating-mdadm-array-using-partitions-or-the-whole.

      The following commands are ran as `root`, therefore `sudo` is omitted.

## fdisk

The type of the partitions will be `Linux RAID` (code 29 on GPT).

Create the partitions with fdisk:

```bash
fdisk /dev/sda
```
```bash
Welcome to fdisk (util-linux 2.36.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): g
Created a new GPT disklabel (GUID: ...).

Command (m for help): n
Partition number (1-128, default 1): 
First sector (2048-976773134, default 2048): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-976773134, default 976773134): 

Created a new partition 1 of type 'Linux filesystem' and of size 465,8 GiB.

Command (m for help): t
Selected partition 1
Partition type or alias (type L to list all): 29
Changed type of partition 'Linux filesystem' to 'Linux RAID'.

Command (m for help): w
The partition table has been altered.
Syncing disks.
```

```bash
fdisk /dev/sdb
```
```bash
Welcome to fdisk (util-linux 2.36.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): g
Created a new GPT disklabel (GUID: 75F9C784-617F-0149-8227-7615469591AF).

Command (m for help): n
Partition number (1-128, default 1): 
First sector (2048-976773134, default 2048): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-976773134, default 976773134): 

Created a new partition 1 of type 'Linux filesystem' and of size 465,8 GiB.

Command (m for help): t
Selected partition 1
Partition type or alias (type L to list all): 29
Changed type of partition 'Linux filesystem' to 'Linux RAID'.

Command (m for help): w
The partition table has been altered.
Syncing disks.
```

Or a use these simple oneliners:

```bash
echo -e -n "g\nn\n\n\n\nt\n29\nw\n" | fdisk /dev/sda
```

```bash
echo -e -n "g\nn\n\n\n\nt\n29\nw\n" | fdisk /dev/sdb
```

## mdadm

Create the RAID 0:

```bash
mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/sda1 /dev/sdb1
```

Check the raid device:

```bash
cat /proc/mdstat
```
```
Personalities : [raid0] [linear] [multipath] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid0 sdb1[1] sda1[0]
      976506880 blocks super 1.2 512k chunks
      
unused devices: <none>
```

Save the array:

```bash
mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
```
```bash
update-initramfs -u
```

## mkfs

Create the filesystem on the new raid device:

```bash
mkfs.ext4 /dev/md0
```

## fstab

To auto mount at boot, edit `/etc/fstab`:

```bash
echo "/dev/md0 /mnt/md0 ext4 defaults,nofail,discard 0 0" >> /etc/fstab
```
