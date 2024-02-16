#!/bin/bash
scriptpath=$(dirname "$0")
cd "$scriptpath" || return
"$scriptpath"/mk3InstallerDisk -p 3
