---
title: "Wsl and Vpn's"
date: 2021-08-21T14:33:33Z
subtitle: "Why you get TLS handshake errors in WSL"
image: "/content/wsl-and-vpns/unsecure-connection-warn.png"
summary: "WSL does not play nice with VPN's and you likely won't realize this is the problem at first. Luckily the problem is usually easy to fix. Changing the MTU value of your WSL network adapter is a good start if you're having issues!"
tags: ["wsl"]
---

When I first started out with WSL I tried to install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt). Strangely I kept having TLS handshake errors while trying to install the microsoft package repository private key. As a workaround I used the macOS package manager [Brew](https://brew.sh/) instead.
This solved my immediate problem but over the next few weeks I kept having to perform certain actions in Windows instead of in WSL because on some domains I would have TLS handshake issues and on others I would not. This was getting ridiculous.
Eventually I realized I did not have this problem when not connected to my corporate VPN! With this knowledge I started looking for a solution and soon enough I found [this](https://github.com/microsoft/WSL/issues/4698) GitHub issue. After reading plenty of comments I found the solution [here](https://github.com/microsoft/WSL/issues/4698#issuecomment-814259640).

The problem is likely that the [MTU](https://homenetworkgeek.com/mtu-size/) (maximum single packet size) set by your VPN operator is not the default `1500` of Ethernet, while the default of the WSL network interface is set to `1500`. This causes packets from your WSL distro to be larger than the maximum allowed by your VPN. This causes your VPN network adapter to drop/lose/block some of your packets or parts of the packets. This malforms the TLS traffic which causes a failed handshake. Fix the MTU value of the WSL network adapter and your should be good to go. To fix this:

TLDR;

In windows find out what the MTU value is of your VPN network adapter by opening PowerShell as Administrator:
```pwsh
netsh.exe interface ipv4 show interfaces
```

The result should look a little something like this:

![List of network adapters](/content/wsl-and-vpns/windows-network-adapters.png)

From this list pick your VPN and look at the MTU column to find the MTU value. In my case the MTU is `1400`.

Now in your WSL open your `~/.profile` or `~/.zprofile` (or whichever shell dotfile you prefer in your system) and add the following line:

```zsh
sudo ip link set dev eth0 mtu 1400
```

And there you go, no more TLS handshake errors!

&nbsp;

{{<notice info>}}
If you still have TLS handshake errors or if you're experiencing other networking issues, try the suggestions in this blog post by [Baruch Odem](https://bscstudent.netlify.app/wsl-troubleshooting/). I did not need this but perhaps it is useful to you.
{{</notice>}}
