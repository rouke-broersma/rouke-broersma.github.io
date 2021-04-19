#!/bin/bash
mkdir -p dist
sudo chown "$USER:$USER" dist
export JEKYLL_VERSION=3.8
docker run --rm \
  --env JEKYLL_UID=$USER \
  --env JEKYLL_GID=$USER \
  --volume="$PWD/dist:/srv/jekyll/dist" \
  --volume="$PWD/src:/srv/jekyll/src" \
  jekyll/minimal:$JEKYLL_VERSION \
  jekyll build -s /srv/jekyll/src -d /srv/jekyll/dist
