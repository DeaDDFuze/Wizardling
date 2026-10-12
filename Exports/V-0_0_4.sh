#!/bin/sh
printf '\033c\033]0;%s\a' Wizardling
base_path="$(dirname "$(realpath "$0")")"
"$base_path/V-0_0_4.x86_64" "$@"
