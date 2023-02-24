#!/bin/bash
source common.sh 

docker run --rm \
  --user 1000:1000 \
  --volume="$(pwd)/cache:/cache" \
  --volume="$(pwd)/dist:/dist" \
  --volume="$(pwd):/src" \
  --env-file hugo-environment-variables.env \
  --env HUGO_ENV=production \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
   --source "/src/src"
