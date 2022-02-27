#!/bin/bash
docker run --rm \
  --volume="$(pwd):/project" \
  --workdir="/project/src" \
  klakegg/hugo:ext-alpine \
  mod get -u ./...
sudo chown -R "$USER:$USER" src
