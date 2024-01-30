#!/bin/sh
echo -ne '\033c\033]0;My First Game\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/My First Game.x86_64" "$@"
