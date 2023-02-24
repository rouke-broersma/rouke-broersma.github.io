#!/bin/bash
xdg-open http://localhost:1313

source common.sh
source update-modules.sh

docker run --rm \
  --user 1000:1000 \
  --volume="$(pwd)/cache:/cache" \
  --volume="$(pwd)/dist:/dist" \
  --volume="$(pwd):/src" \
  --publish 1313:1313 \
  --env-file hugo-environment-variables.env \
  klakegg/hugo:$HUGO_VERSION-ext-alpine \
  server \
  --source "/src/src"