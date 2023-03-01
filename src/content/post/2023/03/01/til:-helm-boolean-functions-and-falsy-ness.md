---
title: "Til: Helm Boolean Functions and Falsy-Ness"
date: 2023-03-01T09:46:05Z
summary: "Did you know Yaml is a superset of Json? Probably. Did you realize this means Yaml inherits some of the issues of Json? You’ve probably encountered this before yourself. But did you realize that helm template functions also inherit some of the Json issues? I sure didn’t until it bit me!"
tags: ["helm", "yaml"]
series: ["TIL"]
---
Did you know Yaml is a superset of Json? Probably. Did you realize this means Yaml inherits some of the issues of Json? You've probably encountered this before yourself.
But did you realize that helm template functions also inherit some of the Json issues? I sure didn't until it bit me!

Now a very common basic helm construct for dealing with default values is the following:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-cm
data:
  mybool: {{ .Values.myapp.mybool | default true }}
```

Let's use this values file to set the bool to false for a specific deployment:
```yaml
myapp:
  mybool: false
```

What I expected is a generated template looking like this:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-cm
data:
  mybool: false
```

But what I got was:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-cm
data:
  mybool: true
```

Heh? Well, the helm template function is falsy. It treats false as an input to the `default` function the same as `undefined`, so it returns `true`, the default value.
Apparently I wasn't the only one to get tricked into using this construct, there is a fairly long Github issue with potential workarounds on [the helm repo](https://github.com/helm/helm/issues/3308).

In the end I chose this construct out of the many proposed solutions:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-cm
data:
  {{- if list nil true | has .Values.myapp.mybool }}
  mybool: true
  {{- else }}
  mybool: {{ .Values.myapp.mybool }}
  {{- end }}
```

Which solution do you prefer? Let me know!
