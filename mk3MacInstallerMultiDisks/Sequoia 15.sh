#!/bin/bash

scriptpath=$(dirname "$0")

cd "$scriptpath" || return
app=""
if [ -z "$1" ]; then
    app="./Install macOS Sequoia.app"
else
    if [ -x "$1/Contents/Resources/createinstallmedia" ]; then
        app="$1"
    fi
fi
[ -n "$app" ] && yes | sudo ./mk3InstallerMultiDisks -1 "$app" -d disk+