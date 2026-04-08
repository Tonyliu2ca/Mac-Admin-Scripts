#!/bin/bash
scriptpath=$(dirname "$0")
cd "$scriptpath" || return
sudo "$scriptpath"/mk3InstallerMultiDisks -p 3 -d disk+ -c "$scriptpath"