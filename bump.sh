#!/bin/bash
# Stamp a new build id into index.html and version.txt (run before committing).
cd "$(dirname "$0")"
B=$(date +%Y%m%d-%H%M%S)
sed -i '' "s/const BUILD='[^']*';/const BUILD='$B';/" index.html
echo "$B" > version.txt
echo "build $B"
