#!/usr/bin/env bash

LIBRARIES="lib"

if [ ! -d "$LIBRARIES" ]; then
    echo "creating directory $LIBRARIES"
    mkdir -p $LIBRARIES
fi

declare -a URLS=(
    "https://raw.githubusercontent.com/bakpakin/Fennel/master/fennel.lua"
)

for url in "${URLS[@]}"
do
    file=${url##*/}

    if [ ! -f "$LIBRARIES/$file" ]; then
        echo "fetching $file from GitHub"
        curl -sSL $url -o $LIBRARIES/$file
    else
        echo "$LIBRARIES/$file already exists"
    fi
done
