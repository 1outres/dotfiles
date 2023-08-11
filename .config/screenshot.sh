#!/bin/env bash

cd ~/Screenshots

GRIM_DEFAULT_DIR="$HOME/Screenshots"

grim -g "$(slurp -w 0)"
wl-copy < $(pwd)/$(ls --ignore={.,..} -1 -t | head -n 1)

