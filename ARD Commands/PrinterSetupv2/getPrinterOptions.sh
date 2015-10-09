#!/bin/bash

#
# Retrieve printer setup options for a specific printer.
# Return:
#   Manufacturer: HP | Xerox
#   Driver: 
#   [Options]:
#    < *
#  --------------------------------------------------------------------------
#   Copyright [2015] Liu, Tony (Tie Song)
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#  --------------------------------------------------------------------------
#

# --------------------
# Global parameters
# --------------------
usage="
Usage: $(basename "$0") ppdFILE
Where:
   ppdFILE:   installed printer PPD filename
Example:
    $(basename "$0") \"/etc/cups/ppd/P404MFP2.ppd\"

   Copyright [2015] Liu, Tony (Tie Song)
   Licensed under the Apache License, Version 2.0 (the "License");"

PPDPATH="/Library/Printers/PPDs/Contents/Resources"

# ----------------------------------------------------
# Print the fileA and fileB different lines in fileA
# input:
#    fileA: the first file
#    fileB: the second file
# ----------------------------------------------------
# parametersList() { diff "$1" "$2" | grep '^< *' | sed 's/^< \*//g' | sed 's/: /=/g'; }
parametersList() { diff "$1" "$2" | grep '^< *' | sed 's/: /=/g' | sed "s/\*Default//"; }

# ----------------------------------------------------
# unzip the .gz file to a temp real PPD file.
#
#    $1: Model of the printer
#       example: HP\ LaserJet\ M9040\ M9050\ MFP.gz
# ----------------------------------------------------
tempPPD ()
{
   local ppdGZ="$1"
   local ppdFile=$(mktemp -t PPD)
   gunzip -c "$ppdGZ" > "$ppdFile"
   echo "$ppdFile"
}

getModel () { grep "\*ModelName" "$1" | awk -F ": " '{print $2}' | sed 's/\"//g'; }
getManufacturer () { grep "\*Manufacturer" "$1" | sed 's/^\*//g' | sed 's/\"//g'; }

# ----------------------------------------------------
# MAIN
# ----------------------------------------------------
printerModel=$(getModel "$1")
getManufacturer "$1"
#echo printerModel=\"$printerModel\"
ppdGZ="${PPDPATH}/${printerModel}.gz"
echo Driver: "$ppdGZ"

if [ -z "$1" ] || [ ! -f "$ppdGZ" ] || [ ! -f "$1" ] ; then echo "$usage"; exit 1; fi

printerPPD=$1
ppdModelFile=$(tempPPD "$ppdGZ")
#echo " . ppdModelFile=${ppdModelFile}"
paraList=$(parametersList "$printerPPD" "$ppdModelFile")
echo "${paraList[@]}"
exit 0
