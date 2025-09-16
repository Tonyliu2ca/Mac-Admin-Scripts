#!/bin/bash
scriptpath=$(dirname "$0")
cd "$scriptpath" || return
"$scriptpath"/mk3InstallerMultiDisks -v -d disk+