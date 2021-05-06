#!/bin/bash
git submodule update
export HUGO_VERSION=0.82.0
docker run --rm -it \
  --volume="$(pwd):/project" \
  --publish 1313:1313 \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
  shell \
  --environment development
sudo chown -R "$USER:$USER" src
