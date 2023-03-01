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

source common.sh 

docker run --rm \
  --user $UID:$UID \
  --volume="$(pwd)/cache:/cache" \
  --volume="$(pwd)/dist:/dist" \
  --volume="$(pwd):/src" \
  --env-file hugo-environment-variables.env \
  klakegg/hugo:ext-alpine \
  new "$title" \
  --source "/src/src"
sudo chown -R "$USER:$USER" src
