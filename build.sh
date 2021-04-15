#!/bin/bash
export JEKYLL_VERSION=3.8
docker run --rm \
  --volume="$PWD/dist:/srv/jekyll/dist" \
  --volume="$PWD/src:/srv/jekyll/src" \
  -it jekyll/minimal:$JEKYLL_VERSION \
  jekyll build -s /srv/jekyll/src -d /srv/jekyll/dist