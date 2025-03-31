---
title: "Talos Linux and Dynamic Resource Allocation (Beta)"
date: 2025-03-29T16:38:34Z
subtitle: ""
image: ""
summary: ""
tags: [kubernetes, talos, dra, cdi]
series: []
---

I upgraded my Kubernetes cluster to 1.32 recently and the changelog mentioned that Dynamic Resource Allocation (DRA) had been graduated to Beta.
I had been using the [Intel GPU Device Plugin](https://github.com/intel/intel-device-plugins-for-kubernetes/blob/main/cmd/gpu_plugin/README.md) to schedule pods with Hardware Device requirements until now. This seemed like a good opportunity to try out and switch to DRA. Surprisingly, this was fairly simple! I initially ran into some speedbumps but now that I figured it out it's fairly straightforward.

Since I use Talos Linux in my Homelab some of the following steps and requirements are Talos specific.

## Requirements

- Containerd 1.7+
- Kubernetes 1.32+
- Container Device Interface (CDI) enabled and configured
- DRA feature gates enabled in Kubernetes
- Deploy DRA capable device driver

Let's start with some straightforward steps.

## Containerd, Kubernetes and CDI

Update Talos to a minimum version of [1.9.0](https://github.com/siderolabs/talos/releases/tag/v1.9.0). 
Talos 1.9 contains Containerd 2.0 and has support for Kubernetes 1.32. 
Containerd 2.0 enabled CDI by default, so this fully covers the first three requirements. Almost fully, more on that later.

## Enable DRA Feature 

The DRA beta feature is not enabled by default in Kubernetes 1.32. To enable the feature gates in Talos you need to apply the following configuration:
```yaml
cluster:
  apiServer:
    extraArgs:
      feature-gates: DynamicResourceAllocation=true
      runtime-config: resource.k8s.io/v1beta1=true # Enables the API (CRD)
  controllerManager:
    extraArgs:
      feature-gates: DynamicResourceAllocation=true
  scheduler:
    extraArgs:
      feature-gates: DynamicResourceAllocation=true

machine:
  kubelet:
    extraArgs:
      feature-gates: DynamicResourceAllocation=true
```

References:



Apply the configuration to all nodes, then execute `kubectl get deviceclasses`. If the response is `No resources found` you have successfully enabled DRA!

## Configure CDI in Talos

CDI uses the following default host paths to store configuration for discovered devices (called cdi spec dirs): `["/etc/cdi", "/var/run/cdi"]`
This is a problem because /etc is read-only in Talos. To use CDI with Talos we need to modify these paths. Add the following Talos configuration:

```yaml
machine:
  files:
  - path: /etc/cri/conf.d/20-customization.part
    op: create
    content: |
      # Set cdi dirs to /var/ because default locations are not writeable in talos
      [plugins."io.containerd.cri.v1.runtime"]
        cdi_spec_dirs = ["/var/cdi/static", "/var/cdi/dynamic"]
```

## Deploy and use Device Driver

Now deploy your device driver with modified config for the cdi spec dirs. I used the [Intel GPU Resource Driver](https://github.com/intel/helm-charts/tree/main/charts/intel-gpu-resource-driver) Helm chart, which does not contain sufficient configuration options to modify the CDI Spec Dirs, so for now I apply these modifications by hand.

Once you've followed these steps you should be able to execute `kubectl get resourceslices` which should list all hardware devices your DRA enabled resource driver found in the cluster.

All that's left is claiming the resource slice in a Pod. Similar to persistent volumes, resources can be claimed statically or dynamically. I have multiple of the same resource available in my cluster so I decided to use a dynamic `ResourceClaimTemplate`. The template creates the resource claim on Pod scheduling, and release the resource claim when the pod is descheduled.

```yaml
apiVersion: resource.k8s.io/v1beta1
kind: ResourceClaimTemplate
metadata:
  name: i915
spec:
  spec:
    devices:
      requests:
      - name: i915
        deviceClassName: gpu.intel.com
```

I then requested and allocated the resource to my Pod by specifying the claim in my StatefulSet and mounting the claim to my Pod:


```yaml
apiVersion: apps/v1
kind: StatefulSet
...
      containers:
        volumeMounts:
        - name: tmp
        resources: 
          claims:
          - name: i915
...
      volumes:
      - emptyDir: {}
        name: tmp
      resourceClaims:
      - name: i915
        resourceClaimTemplateName: i915
```

Deploy your app and if all goes well you should now be able to access the GPU device from inside the Pod. You can validate that the device is available inside the Pod by checking the following file paths:
- /dev/dri/renderD128
- /dev/dri/card0

And there you have it, you should now be able to use DRA and CDI to schedule your Pods with Hardware Device resource access.

References:
- [1] https://www.talos.dev/v1.9/reference/configuration/v1alpha1/config/
- [2] https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/#enabling-dynamic-resource-allocation
- [3] https://github.com/containerd/containerd/blob/main/docs/cri/config.md#full-configuration
