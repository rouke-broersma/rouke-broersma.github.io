---
title: "How to Resize an Ext4 Partition in Linux"
subtitle: "Why does this have to be so hard?"
image: ""
tags: []
draft: true
---

https://snapshooter.com/blog/how-to-grow-an-ext234-file-system-with-resize2fs-
1sudo fdisk /dev/sdx
2(p)rint partition info
3save partitionX start sector so we can use this as the start for the new partition later
4(d)elete linux partition
5(w)rite partition table
6sudo fdisk /dev/sdx
7(n)ew partition at posX
8fill sector from step 3 as start
9fill untill end (take suggestion)
10(w)rite updated partition table
11sudo e2fsck -f /dev/sdxX
12sudo resize2fs /dev/sdxX