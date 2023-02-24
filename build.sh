#!/bin/bash
source common.sh 

sudo chown -R $UID:$UID .

docker run --rm \
  --user $UID:$UID \
  --volume="$(pwd)/cache:/cache" \
  --volume="$(pwd)/dist:/dist" \
  --volume="$(pwd):/src" \
  --env-file hugo-environment-variables.env \
  --env HUGO_ENV=production \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
   --source "/src/src"
