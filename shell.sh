#!/bin/bash
git submodule update
export HUGO_VERSION=0.82.0
docker run --rm -it \
  --volume="$(pwd):/project" \
  --publish 1313:1313 \
  --workdir="/project/src" \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
  shell
sudo chown -R "$USER:$USER" src
