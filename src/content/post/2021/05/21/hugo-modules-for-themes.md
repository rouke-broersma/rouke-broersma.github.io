---
title: "Hugo Modules for Themes"
date: 2021-05-21T19:56:08Z
subtitle: "Instead of git submodules"
summary: "The hugo tutorial tells you to use git submodules for themes. 
However hugo has a better system for dependencies called modules. 
I' ll show you how to switch from git submodules to hugo modules!"
image: ""
tags: ["hugo"]
---

The [tutorial](https://gohugo.io/getting-started/quick-start/) for Hugo tells you how to install themes in step 3. 
This is great because you probably want to pick one of the hundreds of beautiful 3rd party themes to get hugo to do what you want it to do.

```bash
git init
git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke
echo theme = \"ananke\" >> config.toml
```

This has some problems. 
Mainly that I don't want to learn how to work with git submodules 😄 but also.. I don't understand git submodules 🙄.
But I don't have to! Apparently Hugo has created the concept of [Hugo modules](https://gohugo.io/hugo-modules/use-modules/). 
They are basically [Go modules](https://blog.golang.org/using-go-modules).

### How do you use them?

Firstly you have to make your site a Go module, hugo can help you with this.

`hugo mod init <any-name-you-want>`

Then you add your themes/modules to a hugo module config.

```toml
[[imports]]
    path = "github.com/theNewDynamic/gohugo-theme-ananke"
```
_Notice that the path does not include `https://` or `.git`. Don't add them, it won't work._

Lastly delete the git submodules in `/themes`, git submodule config (`.gitsubmodules` file) and the `theme = "ananke"` from `config.toml`. Done!

As a little extra here are some nice hugo modules I've recently started using, which you can try to add as a hu(go) module!

1. [social media metadata](https://github.com/msfjarvis/hugo-social-metadata)
1. [colourful notices to use in your pages to highlight warnings etc](https://github.com/martignoni/hugo-notice)
