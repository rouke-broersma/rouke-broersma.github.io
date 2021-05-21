#!/bin/bash
title=$1

if [ -z "$title" ]; then
  echo "Argument missing: Post title"
  exit 1
fi

year=$(date +'%Y')
month=$(date +'%m')
day=$(date +'%d')

title="$year/$month/$day/$title.md"

docker run --rm \
  --volume="$(pwd):/project" \
  --workdir="/project/src" \
  klakegg/hugo:ext-alpine \
  new --kind post "post/$title"
sudo chown -R "$USER:$USER" src
