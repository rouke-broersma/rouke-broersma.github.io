#!/bin/bash
export HUGO_VERSION=0.107.0
docker run --rm -it \
  --volume="$(pwd):/src" \
  --workdir="/src" \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
  shell
sudo chown -R "$USER:$USER" src
