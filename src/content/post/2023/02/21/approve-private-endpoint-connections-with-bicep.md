---
title: "Approve Private Endpoint Connections"
date: 2023-02-23
subtitle: "With Bicep"
image: "/content/approve-private-endpoint-connections-with-bicep/taylor-vick-M5tzZtFCOfs-unsplash.jpg"
summary: "Managing private endpoint connections - especially across Azure AD tenants - can be a chore. In many cases you will have to do this manually and often you will need elevated permissions. Though usually your deployment pipeline already has sufficient permissions on the resource to approve the endpoint connection, so it would be much more convenient if we could make the approval a part of our desired state config."
tags: ["Azure", "AKS", "Kubernetes", "Private Link", "Private Endpoint"]
series: ["Private Link"]
---

Managing private endpoint connections - especially across Azure AD tenants - can be a chore. In many cases you will have to do this manually and often you will need elevated permissions. Though usually your deployment pipeline already has sufficient permissions on the resource to approve the endpoint connection, so it would be much more convenient if we could make the approval a part of our desired state config.

### Approve a private endpoint with Bicep

It is actually very simple to approve a private endpoint using Bicep because the private endpoint connection - which is the link between the private endpoint and the target resource - is a child resource of the target resource. 

This means that if we have an Azure SQL Server that looks like this:

```
resource dbserver 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: 'broersma'
  location: 'westeurope'
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}
```

And we have a pending private endpoint connection:

![Pending Azure SQL Private Endpoint Connection](/content/approve-private-endpoint-connections-with-bicep/pending-pe-azuresql.png)

We can now export the Azure SQL Server template and see that the private endpoint connection is a child resource of the Azure SQL Server!
```json
{
    "type": "Microsoft.Sql/servers/privateEndpointConnections",
    "apiVersion": "2022-05-01-preview",
    "name": "broersma/pe-azuresql-broersma-5c1e262d-42af-40f8-8b1b-e766be1ea324",
    "properties": {
        "privateLinkServiceConnectionState": {
            "status": "Pending",
            "description": "Please approve"
        }
    }
}
```

We can approve the endpoint like this

```json
{
    "type": "Microsoft.Sql/servers/privateEndpointConnections",
    "apiVersion": "2022-05-01-preview",
    "name": "broersma/pe-azuresql-broersma-5c1e262d-42af-40f8-8b1b-e766be1ea324",
    "properties": {
        "privateLinkServiceConnectionState": {
            "status": "Approved",
            "description": "Approved by pipeline"
        }
    }
}
```

Or as Bicep

```
resource privateEndpointConnection 'Microsoft.Sql/servers/privateEndpointConnections@2022-05-01-preview' = {
    name: 'broersma/pe-azuresql-broersma-5c1e262d-42af-40f8-8b1b-e766be1ea324'
    properties: {
        privateLinkServiceConnectionState: {
            status: 'Approved' 
            description: 'Approved by pipeline'
        }
    }
}
```

As we've seen in [the previous post]({{< ref "azure-aks-private-clusters" >}} "Azure AKS Private Clusters") it is sometimes impossible to approve the private endpoint connection through the azure portal or the azure cli.
Luckily the ARM (Bicep) api is very consistent which is going to help us out here.

The private endpoint connection approval for an AKS API server would look like this:

```
resource privateEndpointConnection 'Microsoft.ContainerService/managedClusters/privateEndpointConnections@2022-05-01-preview' = {
    name: 'private-aks-broersma/ppe-private-aks-broersma-c578f695-5826-44e0-b6a5-fb322b2e1915'
    properties: {
        privateLinkServiceConnectionState: {
            status: 'Approved' 
            description: 'Approved by pipeline'
        }
    }
}
```

There is one downside to this method. You will have to collect the private endpoint connection name yourself, because this name is not entirely deterministic.
As you can see in the examples above the name contains a guid (`c578f695-5826-44e0-b6a5-fb322b2e1915`), presumably to protect against name collisions since private endpoint names are not globally unique (thank god).

This can be done by exporting the template in the azure portal, using azure cli or by using the arm api like so:

```
subscriptionId="09b13d6b-29c5-425f-b451-935c2c89a30b"
resourceGroup="private-aks"
apiGroup="Microsoft.ContainerService/managedClusters"
resourceName="private-aks-broersma"
GET `https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/$apiGroup/$resourceName/privateEndpointConnections`
```

_Cover photo by [Taylor Vick](https://unsplash.com/@tvick) on [unsplash](https://unsplash.com/photos/M5tzZtFCOfs)_
