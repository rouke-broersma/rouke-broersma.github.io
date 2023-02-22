#!/bin/bash
export HUGO_VERSION=0.107.0
mkdir -p dist
docker run --rm \
  --volume="$(pwd)/dist:/dist" \
  --volume="$(pwd):/src" \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
   --source "/src/src" \
   --environment production
sudo chown -R "$USER:$USER" src
sudo chown -R "$USER:$USER" dist
