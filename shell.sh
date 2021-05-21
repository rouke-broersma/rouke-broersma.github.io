#!/bin/bash
export HUGO_VERSION=0.82.0
docker run --rm -it \
  --volume="$(pwd):/project" \
  --workdir="/project/src" \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
  shell
sudo chown -R "$USER:$USER" src
