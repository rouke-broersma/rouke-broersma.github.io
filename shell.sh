#!/bin/bash
source common.sh 

docker run --rm -it \
  --user 1000:1000 \
  --volume="$(pwd)/cache:/cache" \
  --volume="$(pwd)/dist:/dist" \
  --volume="$(pwd):/src" \
  --env-file hugo-environment-variables.env \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
  shell
