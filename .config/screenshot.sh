#!/bin/env bash

currenddir=$(pwd)
cd ~/Screenshots

grim -g "$(slurp -w 0)"
wl-copy < $(pwd)/$(ls --ignore={.,..} -1 -t | head -n 1)

cd $currentdir
