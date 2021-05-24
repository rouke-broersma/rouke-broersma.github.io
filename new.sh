#!/bin/bash
if [ "$1" == "draft" ]; then
  title=$2
  title=${title,,}
  title=${title// /-}
  title="draft/$title.md"
else
  title=$1

  if [ -z "$title" ]; then
    echo "Argument missing: Post title"
    exit 1
  fi

  title=${title,,}
  title=${title// /-}
  year=$(date +'%Y')
  month=$(date +'%m')
  day=$(date +'%d')

  title="post/$year/$month/$day/$title.md"
fi

docker run --rm \
  --volume="$(pwd):/project" \
  --workdir="/project/src" \
  klakegg/hugo:ext-alpine \
  new "$title"
sudo chown -R "$USER:$USER" src
