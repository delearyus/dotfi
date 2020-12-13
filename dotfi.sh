#!/bin/bash

if [ "$#" != 1 ]; then
    printf "Usage: %s <theme>\n" "$0"
    exit 1
fi

cd ~/dots

for dot in *.rkt; do
    ./$dot themes/$1.rkt
done

bspc wm -r
