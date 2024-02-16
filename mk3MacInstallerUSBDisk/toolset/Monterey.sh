#!/bin/bash

scriptpath=$(dirname "$0")

cd "$scriptpath" || return
app=""
if [ -z "$1" ]; then
    app="./Install macOS Monterey.app"
else
    if [ -x "$1/Contents/Resources/createinstallmedia" ]; then
        app="$1"
    fi
fi
[ -n "$app" ] && yes | ./mk3InstallerDisk -2 "$app"
