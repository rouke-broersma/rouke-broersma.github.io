#!/bin/bash
source common.sh 

docker run --rm \
  --user 1000:1000 \
  --volume="$(pwd)/cache:/cache" \
  --volume="$(pwd)/dist:/dist" \
  --volume="$(pwd):/src" \
  --workdir /src/src \
  --env-file hugo-environment-variables.env \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
  mod get -u

docker run --rm \
  --user 1000:1000 \
  --volume="$(pwd)/cache:/cache" \
  --volume="$(pwd)/dist:/dist" \
  --volume="$(pwd):/src" \
  --workdir /src/src \
  --env-file hugo-environment-variables.env \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
  mod tidy