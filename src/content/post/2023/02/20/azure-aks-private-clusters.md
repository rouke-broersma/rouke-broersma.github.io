---
title: "Azure Aks Private Clusters"
date: 2023-02-20T20:39:47Z
publishDate: 2023-02-21
subtitle: ""
image: "/content/azure-aks-private-clusters/header_image_security.jpg"
summary: "When using Kubernetes it is considered good practice to limit API server access as much as possible. When using a cloud managed kubernetes offering you are not by default in control of the networks used by kubernetes. To provide you access to your cluster the default configuration usually exposes the API server on the public internet. This is fine when you’re giving it a try but once you start using kubernetes more seriously you will probably want to start locking down access."
tags: ["Azure", "AKS", "Kubernetes", "Private Link", "Private Endpoint"]
series: ["Private Link"]
---

### What is the point of AKS private clusters

When using Kubernetes it is considered good practice to limit API server access as much as possible. When using a cloud managed kubernetes offering you are not by default in control of the networks used by kubernetes. To provide you access to your cluster the default configuration usually exposes the API server on the public internet. This is fine when you're giving it a try but once you start using kubernetes more seriously you will probably want to start locking down access. Most cloud providers provide mechanisms to limit access with IP whitelisting and [private clusters](https://docs.microsoft.com/en-us/azure/aks/private-clusters) (API server has a private instead of a public IP).

There are downsides to locking down access to your AKS API server. Locking down access means you need to be on the private network used by AKS to be able to manage the workloads you want to run on the cluster. There are many ways to gain network access, ranging from jump host virtual machines in the cluster to VPNs or even express routes. This can become a problem when you manage more than a single cluster. You risk having to connect multiple unrelated networks together through network peering and VPN gateways or express routes which adds the extra burden of having to solve overlapping network range issues as well. Or you need to manage jumphosts in every network you deploy AKS to, just so you can access the cluster. That is not ideal either.

### Azure private link

If you are familiar with azure private networks you probably know about azure private link, which AKS uses to enable the private cluster feature.
For those that are not familiar, private link enables you to connect your azure resources to your azure private virtual networks so you can disable public networks access. With private link you can connect one azure resource to multiple (limits apply but are quite high) endpoints in private virtual networks across subscriptions, azure ad tenants and azure regions. This makes network setups for azure resources very flexible without traditional concerns like overlapping network space. 

Like me you might now think great! We create the private link endpoints for multiple private AKS clusters in the same virtual network so you can manage our clusters from a single location! Now how would we go and do that?

### Let's create a private cluster

I will be using the az-cli for the most part. Let's create a small example cluster.

```bash
az login --tenant broersma.dev
az account set -s VS Enterprise

rgName="private-aks"
az group create --location westeurope --name $rgName

# create AKS with private cluster enable
aksName="private-aks-broersma"
az aks create --namen $aksName --resource-group $rgName \
    --load-balancer-sku standard --node-count 1 \
    --enable-private-cluster --no-ssh-key
```

If you now download the kubecontext and try to connect you will not be able to.

```bash
az aks get-credentials --name private-aks-broersma --resource-group private-aks
kubectl get nodes
  couldn't get current server API group list: Get
```

This is because our machine can't resolve the DNS record for the private API server. 
If you look in your subscription you will see a new resource group prefixed with MC_. This resource group is managed by AKS, and contains resources such as the cluster nodes, but also a private DNS zone, virtual network and private endpoint connecting to the API server.

By default AKS also creates a record pointing to our private IP in the azure public DNS.
If you query azure for the public fqdn  
```
az aks show --name $aksName \
     --resource-group $rgName --query "fqdn"
```  
and pass the result to nslookup and you' ll get the private IP of the api server, which is also configured in the private dns zone. Neat right? Fortunately you can disable this at cluster creation.

### Connecting to our private cluster

As said before, you can now connect to the cluster by deploying a jump host connected to the AKS network. The jump host will automatically pick up the DNS record for the private IP and use the private endpoint to connect to the API server. But I already have a VPN setup in another tenant I'm using. It would be much more convenient not to mention cheaper to use my existing setup, so let's create a private endpoint to my AKS cluster.

We will need to target the subresource (group-id) "management" and we will have to choose manual approval since we are creating a cross-tenant private endpoint.

```bash
# we're going to need the ID later
resourceId=$(az aks show --name $aksName --resource-group private-aks --query "id")

az login --tenant other.broersma.dev
az account set -s VS Enterprise Other

az network private-endpoint create --resource-group hub --name pe-$aksName \
    --connection-name $aksName \
    --vnet-name vnet-hub --subnet aks-clusters --manual-request --group-id "management" \
    --private-connection-resource-id $resourceId
```

And there we go, the private endpoint gets created! Of course since we created the private endpoint with manual approval, we will now have to approve the endpoint. You can confirm this by going to the private endpoint, you'll see the Connection status listed as 'Pending'.

If you've worked with manual approved private endpoints before you will likely think to go to [the private link center](https://portal.azure.com/#view/Microsoft_Azure_Network/PrivateLinkCenterBlade/~/pendingconnections) to perform the manual approval. However something stange is going on. We can see that the private endpoint is created and is pending approval, but we see no evidence of this on the target side.

The reason is that we didn't actually create a private endpoint to our AKS resource. We created a private endpoint to the managed API server which is a part of the Microsoft managed control plane. This resource is not actually in our control, so we can't approve the endpoint!

No worries you might think, we'll use the az cli to approve the endpoint. Let's give that a shot!

However if we look at the docs we immediately have a new problem, [az network private-endpoint-connection approve](https://learn.microsoft.com/en-us/cli/azure/network/private-endpoint-connection?view=azure-cli-latest#az-network-private-endpoint-connection-approve) requires an id which we don't have. The alternative method using the resource group, resource name and type is problematic because our resource type is not in the allowed list of resource types.

Let's try anyway. 

```
az network private-endpoint-connection approve \
    --name $aksName --resource-name $aksName --resource-group $rgName \
    --type "Microsoft.ContainerService/managedClusters"

  az network private-endpoint-connection approve: 
    'Microsoft.ContainerService/managedClusters' is not a valid value for '--type'.
```

Unfortunately no, we're simply not allowed..

Fear not, there is a solution! But that solution will have to wait for next time :heart:

_Cover photo by [vishnu vijayan ](https://pixabay.com/users/vishnu_kv-3192151/) on [pixabay](https://pixabay.com/photos/cyber-security-online-computer-2296269/)_
