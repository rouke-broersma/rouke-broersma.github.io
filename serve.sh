#!/bin/bash
export JEKYLL_VERSION=3.8
docker run --rm \
  --volume="$PWD/src:/srv/jekyll" \
  -p 4000:4000 \
  -p 5000:5000 \
  -it jekyll/jekyll:$JEKYLL_VERSION \
  jekyll serve --livereload --livereload-port 4000 --port 5000