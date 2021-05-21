#!/bin/bash
export HUGO_VERSION=0.82.0
mkdir -p dist
docker run --rm \
  --volume="$(pwd)/dist:/dist" \
  --volume="$(pwd):/project" \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
   --source "/project/src" \
   --environment production
sudo chown -R "$USER:$USER" src
sudo chown -R "$USER:$USER" dist
