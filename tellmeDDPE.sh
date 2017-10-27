#!/bin/bash
# ----------------------------------------------------------------------------------------
# DDPE client installation and status report
#
# Test on:
#    OS X: 10.10.5, 10.11.4, 10.11.6, and 10.12.6
#    DDPE: 8.1.3.5902，8.6.1.6659, 8.7.1.6829, 8.11.1.8168, 8.15.0.8263
#
# Author:
#    Tony Liu, 2017-09-14
#
# History:
#    ver 1.0.3: 2017-10-20
#       add more DDPE client middle condiftions.
#    ver 1.0.2: 2017-09-19
#       deal with two different version of client software situations.
#    ver 1.0.1: 2017-09-18
#       first release
# ----------------------------------------------------------------------------------------

WasEncryptionInstalled=`pkgutil --pkgs| grep com.dell.ems.`
WasEncryptionInstalled1=`pkgutil --pkgs| grep Encryption`
prefPaneName=$(ls -td /Library/PreferencePanes/Dell* 2>/dev/null | sed -n 1p)
tempPlist="/tmp/DDPE_status__9_9.plist"

# ------------------------------------------------
# macOS system information
# ------------------------------------------------
echo $(system_profiler SPSoftwareDataType | grep "System Version" |awk -F ":" '{print $2}')

# ------------------------------------------------
# DDPE Client installation status
# ------------------------------------------------
if [ -n "$WasEncryptionInstalled" ] || [ -n "$WasEncryptionInstalled1" ]
then echo "Installation: Yes"; else echo "Installation: No"; exit 1; fi;

# ------------------------------------------------
# trigger ddpe_fixexcluded to start installation
# /usr/local/jamf/bin/jamf policy -trigger ddpe_fixexcluded
# ------------------------------------------------

# ------------------------------------------------
# version compare:
# Return:
#   0 = $1 = $2
#   1 = $1 > $2
#   2 = $1 < $2
# ------------------------------------------------
verComp()
{
	[[ "$1" == "$2" ]] && { echo "="; return 0; }
	local IFS=.; local i m v1=($1) v2=($2)
	[ "${#v1[@]}" -gt "${#v2[@]}" ] \
 && { for ((i=${#v2[@]}; i<${#v1[@]}; i++)); do v2[i]=0; done; m=${#v1[@]}; }\
 || { for ((i=${#v1[@]}; i<${#v2[@]}; i++)); do v1[i]=0; done; m=${#v2[@]}; }
	for ((i=0; i<m; i++)); do
		[ "${v1[i]}" -gt "${v2[i]}" ] && { echo ">"; return 1; }
		[ "${v1[i]}" -lt "${v2[i]}" ] && { echo "<"; return 2; }
	done
	echo "="; return 0
}

# ------------------------------------------------
# Partition  info
# ------------------------------------------------
IsDriveEncrypted=`diskutil list | grep 46860E2C-2310-4F96-99F6-616D0B4CB55D | awk '{print $2}'`
[ -n "$IsDriveEncrypted" ] && echo "Partition: Yes" || echo "Partition: No"

# ------------------------------------------------
# DDPE Client test
# ------------------------------------------------
[ -e "$prefPaneName/Contents/Helpers/client" ] || { echo "Error: DDPE client not found."; exit 2; }

# ------------------------------------------------
# DDPE Client version
# ------------------------------------------------
ddpeVersion=`"$prefPaneName"/Contents/Helpers/client -v`
endpointUniqueId=$("$prefPaneName"/Contents/Helpers/client -e|grep endpointUniqueId|awk '{print $3}')
echo "Client Version: $ddpeVersion"
echo "Client UniqueID: $endpointUniqueId"

# ------------------------------------------------
# DDPE Client activation status
# ------------------------------------------------
isActivated=`"$prefPaneName"/Contents/Helpers/client -t 2>&1 | grep activate`
[ ${#isActivated} -gt 2 ] &&  printf "Activation: Yes\nActivation Info: $isActivated\n" || echo "Activation: No."

major=$(echo $ddpeVersion | awk -F "." '{print $1}')
minor=$(echo $ddpeVersion | awk -F "." '{print $2}')
version=$(echo $major.$minor)
verComp $ddpeVersion "8.6.1" &>-
[ "$?" -ne "1" ]  && { echo "Warning: DDPE version<8.6.1, cannot get further information."; exit 3; }

# ---------------------------------------------------------
# Display the encryption status in GB of total and percent
# ---------------------------------------------------------
"$prefPaneName"/Contents/Helpers/client -d -plist > "$tempPlist" 2> /dev/null

# client returns no plist file.
[ ! -e "$tempPlist" ] && { echo " Warning: Unknown condition, try to log back in."; exit 4; }

# client return plist file and adminKetStatus=filePresent, need to restart after repartition done.
adminKeyStatus=$(/usr/libexec/Plistbuddy -c "print :disk0s2:adminKeyStatus" "$tempPlist" 2> /dev/null)
[ "$adminKeyStatus" = "filePresent" ] && { echo " Encryption Status: restart and log in to start encryption."; exit 5; }

# client return plist file but no statusText, means it's installing or log off and log in to trigger installation.
/usr/libexec/Plistbuddy -c "print :disk0s2:statusText" "$tempPlist" &> /dev/null
[ "$?" -ne "0" ] && { echo " Warning: Waiting for initializing. you may want to log back in."; exit 6; }

# client return plist file and adminKetStatus!=filePresent. Encryption is started.
percentDone=$(/usr/libexec/Plistbuddy -c "print :disk0s2:policies:0:PercentDone" "$tempPlist" 2> /dev/null)
percentDone=$(echo "$percentDone*100" | bc); percentDone=${percentDone%.*}
StatusEncryption=$(/usr/libexec/Plistbuddy -c "print :disk0s2:statusText" "$tempPlist" 2> /dev/null)
echo " Encryption Status: $StatusEncryption"
echo " Encryption Done: $percentDone%"

# read the total and current bytes numbers
current=$(/usr/libexec/Plistbuddy -c "print :disk0s2:policies:0:Frontier" "$tempPlist" 2> /dev/null)
total=$(/usr/libexec/Plistbuddy -c "print :disk0s2:policies:1:Frontier" "$tempPlist" 2> /dev/null)
percentDone=$(/usr/libexec/Plistbuddy -c "print :disk0s2:policies:0:PercentDone" "$tempPlist" 2> /dev/null)
# bypass error by any chance
(( $(bc <<< "$total == $total" 2>/dev/null) )) || total=1
(( $(bc <<< "$current == $current" 2>/dev/null) )) || currentGB=0
(( $(bc <<< "$percentDone == $percentDone" 2>/dev/null) )) || percentDone=0

# convert to GB
if [ "$total" -lt "$current" ]; then 
	currentGB=$(echo "scale=2; $current/1000000000" | bc)
	totalGB=$currentGB
	percent=100
else
	currentGB=$(echo "scale=2; $current/1000000000" | bc)
	totalGB=$(echo "scale=2; $total/1000000000" | bc)
	percent=$(echo "scale=2; $current*100/$total" | bc)
fi
echo " Detail Status: $currentGB GB of $totalGB GB ($percent% finished)"
rm "$tempPlist"
exit 0

