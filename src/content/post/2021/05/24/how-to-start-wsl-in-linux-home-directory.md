---
title: "How to Start Wsl in Linux User Home"
subtitle: "When using Windows Terminal"
tags: ["wsl"]
date: 2021-05-24T17:56:49Z
summary: "While using the Windows Terminal with WSL and Ubuntu I was bothered by the fact that I would always start in my Windows user home. 
Luckily there are ways to fix that."
image: "/content/how-to-start-wsl-in-linux-homedir/gia-oris-start-here-unsplash.jpg"
---
I have been using WSL and the new Windows Terminal to run Linux apps on Windows for a couple months now and one thing that started to bother me was that the Windows Terminal always started my distro in my Windows user home directory.
I purposefully use the Linux root filesystem instead of the Windows filesystem mounted into Linux because the performance is much better. 
This can be especially noticeable when using git as git touches a lot of files during normal operation.

Every time I used my WSL distro I had to `cd ~/` to get to the files I needed. 
This is not ideal.. 
Luckily there are a number of ways you can fix this. 
One way is to add the `cd ~/` to your `.bashrc` or `.zshrc`. 
Another is to set the starting directory in the Windows Terminal settings. 
This is the method I used.

It's very simple but it's easy to make a mistake due to the unfamiliar filepath syntax you need to use to get this going.

First open the Windows Terminal settings by clicking on the down arrow and choosing Settings, or use `CTRL+,`.

![press ctrl+, to open settings](/content/how-to-start-wsl-in-linux-homedir/windows-terminal-settings.png)

Now find the profile for which you want to set the starting directory, in my case it's `Ubuntu`. 
On the `General` tab you'll find the `starting directory` option.
Fill this with a path according to this format: `\\wsl$\<distro-name>\home\<your-user-name>`. 
In my case it looks like `\\wsl$\Ubuntu\home\rouke`. 
Save it and start a new tab for your distro's profile. 
You should now start in your Linux and not your Windows filesystem!

{{<notice note>}}
The default when the given path cannot be found is to use the Windows user homedir, so if you do not end up in your Linux homedir after changing the starting directory setting then there must be a typo in the given path. For example: The distro name needs to be the name of the directory where the distro is installed and not the name of the profile. The name of the profile is user editable. Check `\\wsl$` for the directory name corresponding to your profile.
{{</notice>}}

_Cover photo by [Gia Oris](https://unsplash.com/@giabyte?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/s/photos/start?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)_
