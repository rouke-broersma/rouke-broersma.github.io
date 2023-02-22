#!/bin/bash
export HUGO_VERSION=0.107.0
xdg-open http://localhost:1313
docker run --rm \
  --volume="$(pwd):/src" \
  --publish 1313:1313 \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
  server \
  --source "/src/src" \
  --environment development
sudo chown -R "$USER:$USER" src
