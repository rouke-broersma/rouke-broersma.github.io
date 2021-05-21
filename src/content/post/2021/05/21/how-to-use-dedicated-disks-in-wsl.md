---
title: "How to Use Dedicated Disks in WSL"
date: 2021-05-21T18:40:19Z
subtitle: ""
image: ""
tags: ["wsl"]
draft: true
---
I've recently started using [WSL](https://docs.microsoft.com/en-us/windows/wsl/about) and have fallen in love with it. 
The best of both worlds combined!
One of the major drawbacks however is that file access in wsl through the Windows filesystem is `slooooooooow..`.

I happen to have a lot of content on an external hard disk formatted to ntfs. 
Most of the software that accesses this content was moved to Docker in wsl some months ago which is awesome because I no longer need to run this software on 'my computer'. 
More importantly I don't need to have any of the dependencies installed on my computer!

But the content was still loaded through Windows and it was starting to bother me how slow my workflow had become. 
I was starting to realize the benefits might not be outweighing this drawback.

But then I thought "Hey why don't I just convert this disk to Ext4 and mount it directly to WSL?"! 
Well the answer is that currently you can't load external disks in WSL. 
Luckily I was not the only one that thought this might be useful. 
Microsoft is currently working on enabling mounting disks in WSL natively and the [feature]((https://docs.microsoft.com/en-us/windows/wsl/wsl2-mount-disk)) is available for preview through the [Windows Insiders Program](https://insider.windows.com/en-us/).

{{< notice warning >}}
If you decide to continue and join the Insiders Program, realize that this contains cutting edge Windows updates and can potentially break your system in an update.
{{< /notice >}}