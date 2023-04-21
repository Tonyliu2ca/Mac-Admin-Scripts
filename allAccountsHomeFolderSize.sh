#!/bin/zsh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#    Show all accounts home folder size sorted by numerical with SI suffix value on macOS
#
#    Copyright (C) 2023  Tony Liu.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#  This script collect all system accounts with home folder path, then count the foler size
#  using du command, combine all results, sort and show by largest size on top.
#
#  VERSION: v 1.0
#
#  REQUIREMENTS:
#           - Root or admin user to deploy
#           - macOS Clients running version 10.10.5 or later
#
#  Created On: 2023-04-21
#
#  Updated History:
#    2023-04-21: first version tested on Ventura 13.3.1
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ "$EUID" -ne 0 ]; then echo " error! Please run as root"; exit 1; fi

## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# all user accounts
sysAllUsers=$(dscl . list /Users)

homeString=""
while IFS= read -r eachUser; do 
	homeUser=$(echo $eachUser | awk '{print $1}')
	homePath=$(echo $eachUser | awk '{$1=""; print $0}' | xargs)
	homeSize=$(du -hs "$homePath" 2>/dev/null)
	# echo $homeUser, $homePath, $homeSize
	[ ! -z "$homeSize" ] && homeString="$homeString
$homeSize"
done <<< "$(dscl . list /Users NFSHomeDirectory)"

echo " - $(date) -"; 
echo $homeString | sort -hbr
