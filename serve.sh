#!/bin/bash
export HUGO_VERSION=0.82.0
docker run --rm \
  --volume="$(pwd):/project" \
  --publish 1313:1313 \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
  server \
  --source "/project/src"
sudo chown -R "$USER:$USER" src
