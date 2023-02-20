---
title: "Azure AKS Private Clusters"
subtitle: "Securely manage multiple private clusters without headaches"
image: "/content/azure-aks-private-clusters/header_image_security.jpg"
summary: ""
tags: ["Azure", "AKS", "Kubernetes", "Private Link"]
draft: true
---

### What is the point of AKS private clusters

When using Kubernetes it is considered good practice to limit API server access as much as possible. When using a cloud managed kubernetes offering you are not by default in control of the networks used by kubernetes. To provide you access to your cluster the default configuration usually exposes the API server on the public internet. This is fine when you're giving it a try but once you start using kubernetes more seriously you will probably want to start locking down access. Most cloud providers provide mechanisms to limit access with IP whitelisting and [private clusters](https://docs.microsoft.com/en-us/azure/aks/private-clusters) (API server has a private instead of a public IP).

There are downsides to locking down access to your AKS API server. Locking down access means you need to be on the private network used by AKS to be able to manage the workloads you want to run on the cluster. There are many ways to gain network access, ranging from jump host virtual machines in the cluster to VPNs or even express routes. This can become a problem when you manage more than a single cluster. You risk having to connect multiple unrelated networks together through network peering and VPN gateways or express routes which adds the extra burden of having to solve overlapping network range issues as well. Or you need to manage jumphosts in every network you deploy AKS to, just so you can access the cluster. That is not ideal either.

### Azure private link

If you are familiar with azure private network you probably know about azure private link, which AKS uses to enable the private cluster feature.
For those that are not familiar, private link enables you to connect your azure resources to your azure private virtual networks so you can disable public networks access. With private link you can connect one azure resource to multiple (limits apply but are quite high) endpoints in private virtual networks across subscriptions, azure ad tenants and azure regions. This makes network setups for azure resources very flexible without traditional concerns like overlapping network space. 

Like me you might now think great! We create the private link endpoints for multiple private AKS clusters in the same virtual network so you can manage our clusters from a single location! Now how would we go and do that?

#### Let's see how that works

I will be using the az-cli for the most part.

```bash
az login --tenant <your-tenant.domain> # login to tenant
az account set -s <your_subscription> # choose subscription

az group create -l westeu -n private-aks # create resource group for aks resources
az aks create -n 20220227-private-aks-broersma -g private-aks --load-balancer-sku standard --enable-private-cluster # create AKS with private cluster enabled
```

```csharp {linenos=table}
public static main(string args[])
{
    string MyProp {get; set;}
}
```

_Cover photo by [vishnu vijayan ](https://pixabay.com/users/vishnu_kv-3192151/) on [pixabay](https://pixabay.com/photos/cyber-security-online-computer-2296269/)_
