---
title: "How to Use Dedicated Disks in Wsl"
date: 2021-06-08T20:49:30Z
subtitle: ""
summary: "When you access Windows files from WSL there is a large price to pay. But if you have important or a lot of data you use in WSL it can be a problem to only use the WSL root filesystem you get by default. It lives only in WSL (with an awkward way to access it from Windows) and to me feels like temporary storage you could lose at any time. Wouldn't it be great if you could use an external or extra hard disk in WSL while not having to pay the price? Well, now you can!"
image: "/content/how-to-use-dedicated-disks-in-wsl/explorer.png"
tags: ["wsl"]
---
I've recently started using [WSL](https://docs.microsoft.com/en-us/windows/wsl/about) and have fallen in love with it. 
Linux on Windows, The best of both worlds combined!
One of the major drawbacks however is that file access in wsl through the Windows filesystem is `slooooooooow..`.

I happen to have a lot of content on an external hard disk formatted to ntfs. 
Most of the software that accesses this content was moved to Docker in wsl some months ago which is awesome because I no longer need to run this software on 'my computer'. 
More importantly I don't need to have any of the dependencies installed on my computer!

But the content was still loaded through Windows and it was starting to bother me how slow my workflow had become. 
I was starting to realize the benefits might not be outweighing this drawback.

But then I thought "Hey why don't I just convert this disk to Ext4 and mount it directly to WSL?"! 
Well the answer is that currently you can't load external disks in WSL. 
Luckily I was not the only one that thought this might be useful. 
Microsoft is currently working on enabling mounting disks in WSL natively and the [feature](https://docs.microsoft.com/en-us/windows/wsl/wsl2-mount-disk) is available for preview through the [Windows Insiders Program](https://insider.windows.com/en-us/).  

{{<notice warning>}}
If you decide to continue and join the Insiders Program, realize that this contains cutting edge Windows updates and can potentially break your system in an update.
{{</notice>}}

### You've joined the ~~Dark Side~~ Insider Program  

So you've signed up for the windows insider program and you're done installing Windows Updates. You have the fancy new Windows features like the new explorer icons (they look pretty good by the way). How do you now mount your disk?

Well that part is actually pretty simple!

First identify your Windows 'physical' diskpath by starting Powershell as administrator and using the command `wmic diskdrive list brief`. The output should look a little something like this.

```
PS C:\WINDOWS\system32> wmic diskdrive list brief
Caption                      DeviceID            Model                        Partitions  Size
Samsung SSD 860 EVO 500GB    \\.\PHYSICALDRIVE2  Samsung SSD 860 EVO 500GB    0           500105249280
ST2000DM006-2DM164           \\.\PHYSICALDRIVE4  ST2000DM006-2DM164           1           2000396321280
ST2000DM001-1CH164           \\.\PHYSICALDRIVE3  ST2000DM001-1CH164           1           2000396321280
WD Elements 107C USB Device  \\.\PHYSICALDRIVE5  WD Elements 107C USB Device  1           4000710389760
Samsung SSD 860 EVO 500GB    \\.\PHYSICALDRIVE1  Samsung SSD 860 EVO 500GB    1           500105249280
Samsung SSD 840 EVO 250GB    \\.\PHYSICALDRIVE0  Samsung SSD 840 EVO 250GB    5           250056737280
```

In my case my disk is `WD Elements 107C USB Device` at `\\.\PHYSICALDRIVE5`.

As you can see it has only one partition. I happen to know it is of type Ext4 which the WSL kernel can natively understand so all I have to do to mount my disk is run 

```pwsh
wsl --mount \\.\PHYSICALDRIVE5
```

And now the disk will be mounted in my WSL at /mnt/wsl/PHYSICALDRIVE5

### Going deeper

If you have more than one partition you will have to specify the partition number you want to mount like so

```pwsh
wsl --mount \\.\PHYSICALDRIVE5 --partition 3
```

This does mean you need to know which partition contains your Linux filesystem.  

To find that out we can mount the disk as 'bare' which basically means that Windows passes through the disk to WSL but does not actually try to mount it to the Linux filesystem.

```pwsh
wsl --mount \\.\PHYSICALDRIVE5 --bare
```

Then identify the device number for your hard disk with `lsblk`

The output will look something like this:

```
➜  ~ lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
loop0    7:0    0 429.6M  1 loop /mnt/wsl/docker-desktop/cli-tools
loop1    7:1    0 343.4M  1 loop
sda      8:0    0 347.4M  1 disk
sdb      8:16   0   256G  0 disk /mnt/wsl/docker-desktop/docker-desktop-proxy
sdc      8:32   0   256G  0 disk /mnt/wsl/docker-desktop-data/isocache
sdd      8:48   0   3.7T  0 disk
└─sdd1   8:49   0   3.7T  0 part 
sde      8:64   0   256G  0 disk /
```

If you don't immediately recognize your disk from this list based on the size you can use the following command to get all physical drives attached:

`sudo lshw -class disk`

The output should look like this:

```
➜  ~ sudo lshw -class disk
  *-disk:3
       description: SCSI Disk
       product: Elements 107C
       vendor: WD
       physical id: 0.0.3
       bus info: scsi@0:0.0.3
       logical name: /dev/sdd
       version: 1065
       serial: WCC4E6TTZ6S6
       size: 3725GiB (4TB)
       capabilities: partitioned partitioned:dos
       configuration: ansiversion=6 logicalsectorsize=4096 sectorsize=4096 signature=db4bf07b
```

Here you can find the disk by it's name and model which you can compare with the `wmic diskdrive list brief` command from Windows. See the disk is listed as `/dev/sdd` for me.

So now we know which device is our disk but we still don't know anything about the partitions on the disk. For that we need  to go back to `lsblk`. Find our disk in the list based on the device id (`/dev/sdd`). Now for every partition listed for this device you have to run `blkid <device-id><partition>`. In my case since I have only one partition this is as simple as `sudo blkid /dev/sdd1`

```
➜  ~ sudo blkid /dev/sdd1
/dev/sdd1: UUID="6d7e2d05-454d-d701-605c-2d05454dd701" TYPE="ext4" PARTUUID="03f49424-1d7a-324e-84f6-2f405947782b"
```

If you have multiple partitions you will have to run this command for each of them untill you find the partition you need.

As you can see in the output my partition is of type ext4 which means it is supported.

At this point you can go back to [mounting the partition in Windows]({{< relref "#going-deeper" >}} "mounting the partition in Windows") and follow the first step.

### Bonus points

As we saw earlier WSL mounts the partitions automatically in `/mnt/wsl` based on the physical device name and the partition id. I wasn't particularly happy with this default as a physical device name tells me nothing about which disk it is. No matter though because as we learned we can mount the disk `bare` and have the device show up in Linux anyway. Using this information and the information from `blkid /dev/sdd1` I realized that I could simply mount the partitions in Linux instead!

First I created a mount point (directory) in `/mnt` called `data` with `mkdir /mnt/data`.

```
➜  ~ ls /mnt
b  c  d  data  e  g  wsl  wslg
```

Then I edited /etc/fstab (the 'mount configuration' file in linux) with nano: `sudo nano /etc/fstab` and added a line to mount my Linux partition on `/mnt/data`.

The entry looks like this:

`UUID=6d7e2d05-454d-d701-605c-2d05454dd701 /mnt/data ext4 defaults`

Notice that the UUID comes from the output of `sudo blkdid /dev/sdd1`, the next part of the line is where to mount. Then come the filesystems and the mount options which I left as 'defaults'. Now run `sudo mount -a` and you'll have access to your drive from WSL!

And there you have it, a completely dedicated disk for WSL.

I have not yet figured out how to mount this automatically on startup due to needing to run the command `wsl --mount \\.\PHYSICALDRIVE5 --bare` as administrator (could probably use a scheduled task for this) but that is a small price to pay for the awesome performance and increased WSL disk space I now have. Enjoy!
