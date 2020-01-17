#!/bin/bash

# Get a file's creation date (original date) from its metadata
# and Set file's POSIX birth date to it's creation date
#
# NOTE:
#   This' a demo of how to retrieve metadata and set file birth date.
#
# command line:
#   setOriginalDate.sh "/full/path/to/file"
#
# Author
#   Tony Liu 2020-01-17
#

echo " File ($1) current file creation dates:"
stat -f "  Birth  (Btime): %SB" "$1"

# Get Picture creation date
exif=$(mdls "$1" | grep "kMDItemContentCreationDate " | cut -c 42-60)
echo " File ($1) exif info creation UTC date = $exif"
UTC=$(mdls "$1" | grep "kMDItemContentCreationDate " | cut -c 42-60 | tr " " T)

# Convert to local time
cDate=$(date -jf "%Y-%m-%dT%H:%M:%S %z" "${UTC} +0000" "+%m/%d/%Y %H:%M:%S")
#cDate=$(date -jf "%Y-%m-%dT%H:%M:%S %z" -v "${2}H" "${UTC} +0000" "+%m/%d/%Y %H:%M:%S")
echo " File ($1) exif info creation local date = $cDate"

# set creation date
setFile -d "$cDate" "$1"
echo " File ($1) creation date is changed to:"
stat -f "   Birth  (Btime): %SB" "$1"
