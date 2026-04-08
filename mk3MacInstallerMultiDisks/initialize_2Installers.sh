#!/bin/bash
scriptpath=$(dirname "$0")
cd "$scriptpath" || return
sudo "$scriptpath"/mk3InstallerMultiDisks -p 2 -d disk+ -c "$scriptpath"