#!/bin/bash
xdg-open http://localhost:1313

source common.sh
source update-modules.sh

docker run --rm \
  --user $UID:$UID \
  --volume="$(pwd)/cache:/cache" \
  --volume="$(pwd)/dist:/dist" \
  --volume="$(pwd):/src" \
  --env-file hugo-environment-variables.env \
  --publish 1313:1313 \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
  server \
  --source "/src/src"