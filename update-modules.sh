#!/bin/bash
docker run --rm \
  --volume="$(pwd):/project" \
  --publish 1313:1313 \
  --workdir="/project/src" \
  klakegg/hugo:alpine \
  mod get -u ./...
sudo chown -R "$USER:$USER" src
