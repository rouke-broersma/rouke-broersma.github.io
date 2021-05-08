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

git submodule update
docker run --rm \
  --volume="$(pwd):/project" \
  --publish 1313:1313 \
  --workdir="/project/src" \
  klakegg/hugo:alpine \
  new --kind post "post/$title"
sudo chown -R "$USER:$USER" src
