#!/bin/bash
source common.sh 

docker run --rm \
  --user $UID:$UID \
  --volume="$(pwd)/cache:/cache" \
  --volume="$(pwd)/dist:/dist" \
  --volume="$(pwd):/src" \
  --env-file hugo-environment-variables.env \
  --workdir /src/src \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
  mod get -u

docker run --rm \
  --user $UID:$UID \
  --volume="$(pwd)/cache:/cache" \
  --volume="$(pwd)/dist:/dist" \
  --volume="$(pwd):/src" \
  --env-file hugo-environment-variables.env \
  --workdir /src/src \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
  mod tidy