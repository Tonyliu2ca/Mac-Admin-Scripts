#!/bin/bash

# 
# Find the wallpaper picture file and reveal it in Finder.
# 
# Suitable macOS:
#   tested on macOS 12.4, it may work on from macOS 10.14
#
# Claim:
#   This script is for fun and demonstration purpose only. it doesn't work in certain situations.
#
# Author：
#    Tony Liu, 2022-07-15
#
# GPLv3
#

# if needed, clear the tables first.
#/usr/bin/sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db 'DELETE FROM preferences; DELETE FROM pictures;'

getLoopFile()
{
	bgPath=""
	bgFile=""
	lastOne=""
	i=20;
	while [ $i -ge 0 ]; do 
		line=$(/usr/bin/sqlite3 -readonly ~/Library/Application\ Support/Dock/desktoppicture.db "SELECT * FROM data LIMIT 1 OFFSET $i;")
		if [ -n "$line" ]; then
			if [ "$line" != "0" ] && [ "$line" != "5.0" ] && [ "$line" != "1" ]; then
				if [ -z "$bgFile" ]; then 
					# get the picture file
					bgFile="$line";
				elif  [ -z "$bgPath" ]; then
					# Get the picture folder
					bgPath="$line"
					if [ "$lastOne" = "1" ]; then bgPath=$(/usr/bin/dirname "$bgPath"); fi
					echo "$bgPath/$bgFile"
					break
				fi
			fi
		fi;
		i=$((i-1))
		lastOne="$line"
	done
}

getSingleFile()
{
	bgPath=""
	bgFile=""
	i=20;
	while [ $i -ge 0 ]; do 
		line=$(/usr/bin/sqlite3 -readonly ~/Library/Application\ Support/Dock/desktoppicture.db "SELECT * FROM data LIMIT 1 OFFSET $i;")
		if [ -n "$line" ]; then
			if ! [ "$line" -eq "$line" ] 2>/dev/null; then
				if [ -z "$bgFile" ]; then 
					# Get the file with full path
					bgFile="$line";
					echo "$bgFile"
					break
				fi
			fi
		fi;
		i=$((i-1))
	done
}

isLoop=$(/usr/bin/sqlite3 -readonly ~/Library/Application\ Support/Dock/desktoppicture.db "SELECT * FROM data WHERE value=1;")
if [ "$isLoop" = "1" ]; then 
	myfile=$(getLoopFile)
else
	myfile=$(getSingleFile)
fi
myfile=$(echo "${myfile/\~/$HOME}")
echo "path=[$myfile]"
open -R "$myfile"
