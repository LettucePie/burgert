#!/bin/sh
echo -ne '\033c\033]0;burgert\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/burgert.arm64" "$@"
