#!/bin/bash

#mkdir /tmp/379tp.1; curl -o /tmp/379tp.1/install.sh "http://s379ees2.edu.cbe.ab.ca/dmg/installPrinters.sh"; curl -o /tmp/379tp.1/379.plist "http://s379ees2.edu.cbe.ab.ca/dmg/379_Printers.plist"; /tmp/379tp.1/install.sh -v -p /tmp/379tp.1/379.plist
# ---------------------------------------------------------
# Install printers on teacher laptops
# File: installPrinters_4Teachers.sh
#   Depends on OS X system commands:
#     /usr/bin/curl, /usr/libexec/PlistBuddy
#  Date:
#    2015-09-29:
#      Support for remove Open Directory.
#      Support adding users to _lpOperrator and _lpadmin
#    2015-10-06:
#      Support reset CUPS
#    2015-10-13:
#      Support everyone, RemovePrinterLis, and match options.
# ---------------------------------------------------------
plBuddy="/usr/libexec/PlistBuddy -c"

# ---------------------------
# Help
# ---------------------------
sname=$(basename "$0")
usage="$sname version 2.1, Tony Liu (bug reports github.com/Tonyliu2ca)
have readme.txt for details about the two plist configuration files.

Usage: $sname <options>
<options>:
  -h|--help|-?          show this help text
  -v|--verbose          verbose mode to display detail infomation
  -c|--config <config>  (must have) printer configuration plist
  -l|--list <config>    (must have) printer list plist file for specific group computer
Example: $sname -v -c ./pc.plist -l ./pl.plist
"

# ===================================
# Don't change the following codes. #
# ===================================
# ---------------------------
# Variables
# ---------------------------
pConfig=""
pList=""
Verbose=false
log_file="/var/log/installPrinters.log"
log_tag="[Install_Printers v.2]"

ardCompuField=""
listVersion=""


# --------------------------Support Section-----------------------------
abspath() { pushd . > /dev/null; if [ -d "$1" ]; then cd "$1"; dirs -l +0; else cd "`dirname \"$1\"`"; cur_dir=`dirs -l +0`; if [ "$cur_dir" == "/" ]; then echo "$cur_dir`basename \"$1\"`"; else echo "$cur_dir/`basename \"$1\"`"; fi; fi; popd > /dev/null; }

# ----------------------------------
# to support verbose mode and logs #
# ----------------------------------
logme() { if [ -n "$log_file" ]; then printf "$1\n" >> "$log_file"; fi; }
vecho() { if $Verbose; then echo "$1"; fi; logme "$1"; }
initialLog() { if [ -n "$log_file" ]; then touch "$log_file"; fi; logme "`date`: $1 starting ... "; }
closeLog() { logme "`date`: $1 is done ... "; }

# ---------------------------CUPS Section-------------------------------
stopCUPS() { cancel -a; launchctl stop org.cups.cupsd; sleep 2; }
startCUPS() { launchctl start org.cups.cupsd; }
backupCUPS()
{
   local spaces="  $1"
   seconds=`date +%s`
   backupDIR="/private/etc/cups/backup.${seconds}"
   
   mkdir $backupDIR
   cp -a /private/etc/cups/PPD $backupDIR/PPD
   cp -a /private/etc/cups/printers.* $backupDIR/
   cp -a /private/etc/cups/cupsd.* $backupDIR/
   vecho "${spaces}[backupCUPS] CUPS backup -> $backupDIR"
}

emptyCUPs()
{
   local spaces="  $1"
   stopCUPS; rm -fr /private/etc/cups/PPD/*; rm -fr /private/etc/cups/printers.conf
   vecho "${spaces}[emptyCUPs] reset CUPS system done"; startCUPS
   #cp -f /private/etc/cups/cupsd.conf.default /private/etc/cups/cupsd.conf
}

# --------------------------------------------------
# remove all printers.
# --------------------------------------------------
rmAllPrinters()
{
   local spaces="  $1"
#	vecho "${spaces}[rmAllPrinters] ==Initial print queue list=="
#	lpstat -v| awk '{print $3 $4}' | while read printer; do
#  	vecho "  ${spaces} == $printer"
#	done
#	vecho "${spaces}[rmAllPrinters] --------------------------------------------------"
   lpstat -p | awk '{print $2}' | while read printer; do
		lpadmin -x $printer &>/dev/null
		vecho "${spaces}[rmAllPrinters] printer <$printer> is removed."
	done
}

# ---------------------------Printer Driver Section-----------------------------------
# ---------------------------
# Constance
# ---------------------------
# Driver definitions
# Explain:
#  the supported setting names are in constance array <c_pConfigName>
#  the supported printer options name in viriable <c_pOptionName> 
#  the index of each setting is depending on where they appear in <c_pConfigName>
#  like the first "Brand" index is 0, pBrand=0
c_dConfigName=("Brand" "Path" "Protocol" "Username" "Password")
c_dBrand=0
c_dPath=1
c_dProtocol=2
c_dUsername=3
c_dPassword=4

dTempFile="/tmp/$(basename "$0").XXXXXX"
dPackage=$(/usr/bin/mktemp "$dTempFile")

# -----------------------------
# seek brand printer driver.  #
#   $1 = driver index         #
#   $2 = brand name           #
#   $3 = config file          #
#   return: 1 = no match      #
#     2 = no more driver      #
#     0 = found               #
# -----------------------------
seekBrandDriver()
{
   local index="$1"
   local brand="$2"
   local configFile="$3"
   local spaces="  $4"
   iBrand=$($plBuddy "print :Drivers:Drivers:$index:${c_dConfigName[$c_dBrand]}" "$configFile" 2>&-)
   if (( $? != 0 )); then return 2; fi
   # to lower case
	iBrand=`echo ${iBrand//[[:space:]]/} | awk '{print tolower($0)}'`
	brand=`echo ${brand//[[:space:]]/} | awk '{print tolower($0)}'`
	if [[ $brand == *"$iBrand"* ]]; then
		vecho "${spaces}[seekBrandDriver] found driver <$2>, index of <$index>."
		return 0
	else
		vecho "${spaces}[seekBrandDriver] driver brand <$2> not found, index of <$index>."
		return 1
	fi
}

# --------------------------------
# download Brand printer driver. #
#   $1 = driver index				#
#   $2 = config file					#
# --------------------------------
dlBrandPDriver()
{
	local index="$1"
	local configFile="$2"
   local spaces="  $3"
	vecho "${spaces}[dlBrandPDriver] starting download driver index <$1>"
   local purl=$($plBuddy "print :Drivers:Drivers:${index}:${c_dConfigName[c_dProtocol]}" "$configFile" 2>&-)
   local url=$($plBuddy "print :Drivers:Drivers:${index}:${c_dConfigName[c_dPath]}" "$configFile" 2>&-)
   url="${purl}://${url}"
	vecho "${spaces}[dlBrandPDriver] package from <$url>..."
   /usr/bin/curl -o "$dPackage" "$url" 2>&-
	if (( $? != 0 )); then vecho "[dlBrandPDriver] driver DMG file <$url> download failed."; return -1; fi
	vecho "${spaces}[dlBrandPDriver] save driver to <$dPackage>..."
	return 0
}

# ------------------------------
# install the given package.   #
#   $1 = full path of dmg file #
#   return: 0 = installed      #
#           1 = DMG error      #
#           2 = install failed #
# ------------------------------
instPackage()
{
   local spaces="  $1"
   vecho "${spaces}[instPackage] starting."
	local tempMountDir=`/usr/bin/mktemp -d "$dTempFile"`;
	hdiutil attach "$1" -mountpoint "$tempMountDir" -nobrowse -noverify -noautoopen 2>&-
	if (( $? != 0 )); then vecho "${spaces}[instPackage] attach DMG <$1> error."; return 1; fi
	vecho "${spaces}[instPackage] dmg attach to <$tempMountDir>."
	/usr/sbin/installer -pkg "$(/usr/bin/find $tempMountDir -maxdepth 1 \( -iname \*\.pkg -o -iname \*\.mpkg \))" -target "/";
	if (( $? != 0 )); then vecho "${spaces}[instPackage] attach DMG <$1> error."; return 2; fi

	/usr/bin/hdiutil detach "$tempMountDir";
	/bin/rm -rf "$tempMountDir";
	/bin/rm -rf "$1";
   vecho "${spaces}[instPackage] successed."
}


# --------------------------------
# install Brand printer driver.  #
#   $1 = brand name              #
#   $2 = config file             #
#   return:  1 = install failed  #
#            2 = no driver found #
#            0 = installed       #
# --------------------------------
instBrandPDriver()
{
	local brand="$1"
	local confgFile="$2"
   local spaces="  $3"
   vecho "${spaces}[instBrandPDriver] installing <$brand> printer driver."
   #local driveIndex=$($plBuddy "print :Drivers:${BrandIndex}:${brand}" "$configFile" 2>&-)
   local index=0
   local go=true
   local ireturn=0
   while $go; do
   	seekBrandDriver "$index" "$brand" "$confgFile" "$spaces"
   	ierror=$?
   	if (( $ierror == 0 )); then
         dlBrandPDriver "$index" "$confgFile" "$spaces"
	   	if (( $? == 0 )); then
	   	   instPackage "$dPackage" "$spaces"
	   	   if (( $? == 0 )); then
   	         vecho "${spaces}[instBrandPDriver] Printer[$index], driver installed."
               go=false
   	         ireturn=0
   	      else
   	         vecho "${spaces}[instBrandPDriver] Printer[$index], driver install failed."
            	let "index++"
   	         ireturn=1
   	      fi
   	   else
   	      let "index++"
         fi
      else if (( $ierror == 2 )); then
         vecho "${spaces}[instBrandPDriver] Printer[$index] driver NOT found."
         go=false
         ireturn=2
      else
      	let "index++"
      fi; fi
   done
   if (( $ireturn == 0 )); then vecho "${spaces}[instBrandPDriver] <$brand> printer driver installed."; \
   else  vecho "${spaces}[instBrandPDriver] <$brand> printer driver install failed."; fi
   return $ireturn
}

# ---------------------------Printer Section-----------------------------------
# ---------------------------
# Printer Config Constances #
# ---------------------------
# Explain:
#  the supported setting names are in constance array <c_pConfigName>
#  the supported printer options name in viriable <c_pOptionName> 
#  the index of each setting is depending on where they appear in <c_pConfigName>
#  like the first "Brand" index is 0, pBrand=0
pFeatureArray=()
c_pConfigName=("Brand" "Driver" "IP" "Location" "Device" "Protocol" "Description")
c_pBrand=0
c_pDriver=1
c_pIP=2
c_pLocation=3
c_pDevice=4
c_pProtocol=5
c_pDesciption=6

c_pOptionName="Options"
pOptionStr=""

# the list of printers have definition in configure file, create by readPConfigPrinters_Array
pConfigListArray=()
# the list of printers to be installed, create by readPrinterList_Array
pPrinterListArray=()

reachablePrinter() 
{ 
   local spaces="  $2"
   ping -c1 -W10 $1 &>/dev/null;
   if (( $? == 0)); then
      vecho "${spaces}[reachablePrinter] printer <$1> is reachable."; 
      return 0
   else 
      vecho "${spaces}[reachablePrinter] printer <$1> is NOT reachable."; 
      return 1
	fi
}

# ----------------------------------------------------------
# read all printers in printer configure file              #
# to global array variable pConfigListArray                #
# Input:
#   $1 = the index of compGroup 					              #
#   $2 = printer list file 						              #
# Return:
#   0: no printer config found
#   n: the number of printer config read
# Example:
#   readPrinterList_Array "$compGroup" "$pList" "$spaces"  #
# ----------------------------------------------------------
readPrinterList_Array()
{
	local compGroup="$1"
	local sPList="$2"
	local spaces="  $3"
	local index=0
	local count=0

	while true; do
		pName=$($plBuddy "print :CompGroups:$compGroup:PrinterList:$count" "$sPList" 2>&-)
		if (( $? != 0 )); then return $count; fi;
		pPrinterListArray[count]="$pName"
		vecho "${spaces}[readPrinterList_Array] read printer <$pName> at <$count>."
		let "count++"
	done
}

# -------------------------------------------------
# read all printers in printer configure file     #
# to global array variable pConfigListArray       #
# Input:
#   $1 = printer config file  						  #
# Return:
#   0: no printer config found
#   n: the number of printer config read
# Example:
#   readPConfigPrinters_Array "$pConfig" "$spaces"#
# -------------------------------------------------
readPConfigPrinters_Array()
{
	local pConfig="$1"
	local spaces="  $2"
	local index=0

	while true; do
		rname=$($plBuddy "print :Printers:$index:Description" "$pConfig" 2>&-)
		if (( $? != 0 )); then return $index; fi;
		pConfigListArray[index]="$rname"
		vecho "${spaces}[readPConfigPrinters_Array] read printer <$rname> at <$index>."
		let "index++"
	done
}


# ------------------------------------------------
# read given Name printer settings to global     #
# array <pFeatureArray> and <pOptionsStr>        #
# Input:
#   $1 = index of printer								 #
#   $2 = config file										 #
# Return:
#   
# Example:
#   readPrinterConfig "$pName" "$pConfig" "$spaces"
# ------------------------------------------------
readPrinterConfig()
{
   local pName="$1"
   local pConfig="$2"
	local spaces="  $3"

   local count=0
   local found=false
   local index=0
	local rname=""
	
   # Search for the printer and get the index.
	for field in "${pConfigListArray[@]}"; do
		if [ "$pName" = "$field" ]; then found=true; break; else let "index++"; fi;
	done
	if ! $found; then vecho "${spaces}[readPrinterConfig] printer <$pName> configuration not found." return -1; 
	else vecho "${spaces}[readPrinterConfig] printer <$pName> configuration index is <$index>."; fi

   # read printer configures
	for field in "${c_pConfigName[@]}"; do
		pFeatureArray[$count]=$($plBuddy "print :Printers:$index:$field" "$pConfig" 2>&-)
		vecho "${spaces}[readPrinterConfig] Printer[$index]: <$field>=<${pFeatureArray[$count]}>"
		count=$((count+1))
	done
	
	# Read Options if any
   count=0
   pOptionStr=""
   while true; do
      #$plBuddy "print :Printers:$index:$c_pOptionName:$count" "$configFile"
      option=$($plBuddy "print :Printers:$index:$c_pOptionName:$count" "$pConfig" 2>&-)
		if (( $? != 0 )); then
			break;
      else
         pOptionStr="$pOptionStr $option"
	   	let "count++"
   	fi
   done
   vecho "${spaces}[readPrinterConfig] Printer[$index]: Options=<$pOptionStr>, total=<$count>"
   return 0
}

# --------------------------------------------------------------
# setup all printers defined in print list file                #
# Input:
#    $1=computer group index                                   #
#    $2=print list file
#    $3= printer config file								            #
# Return: 
#    how many errores                                          #
# CALL:
#   	setupPrinters "$compGroup" "$pList" "$pConfig" "$spaces" #
# --------------------------------------------------------------
setupPrinters()
{
   # vecho "[setupPrinters] going..."
   local compGroup="$1"
   local pList="$2"
   local pConfig="$3"
   local spaces="  $4"

   local count=0
   local pName=""
   local ireturn=0
   local printerOK=0
   local go=true

	vecho "${spaces}[setupPrinters] start."
	readPConfigPrinters_Array "$pConfig" "$spaces"
	ireturn=$?
	if (( $ireturn < 1 )); then
		vecho "${spaces}[setupPrinters] ERROR: Printer Configuration file has <$ireturn> printer listed."
		return -1;
	fi
	#echo "compGroup=$compGroup"
	readPrinterList_Array "$compGroup" "$pList" "$spaces"
	ireturn=$?
	if (( $ireturn < 1 )); then
		vecho "${spaces}[setupPrinters] computer group <$compGroup> has <$ireturn> printer in Printer List file."
		return -2;
	fi

	for pName in "${pPrinterListArray[@]}"; do
		vecho "${spaces}[setupPrinters] Processing printer[$count] <$pName>."
		readPrinterConfig "$pName" "$pConfig" "$spaces"
		if (( $? == 0 )); then
			# test if the printer driver exist.			
			if [ ! -f "${pFeatureArray[$c_pDriver]}" ]; then
				instBrandPDriver "${pFeatureArray[$c_pBrand]}" "$pConfig" "$spaces"
			fi
			if [ -f "${pFeatureArray[$c_pDriver]}" ]; then
				# test if printer is reachable.
				reachablePrinter "${pFeatureArray[$c_pIP]}" "$spaces"
				if (( $? != 0 )); then vecho "${spaces}[setupPrinters] Warning: Printer <$count> is not online."; fi
					# Install the printer
					local sDes="${pFeatureArray[$c_pDesciption]}"
					local sLoc="${pFeatureArray[$c_pLocation]}"
					local sDev="${pFeatureArray[$c_pDevice]}"
					local sAddr="${pFeatureArray[$c_pProtocol]}://${pFeatureArray[$c_pIP]}"
					local sPPD="${pFeatureArray[$c_pDriver]}"
					lpadmin -p "$sDev" -E -L "$sLoc" -D "$sDes" -v "$sAddr" -P "$sPPD"
					if (( $? != 0 )); then vecho "${spaces}[setupPrinters] warning: printer set up failed <$?>..."; 
					else vecho "${spaces}[setupPrinters] printer <$sDes> has been set up."; let "printerOK++"; fi
					lpadmin -p "$sDev" -o "$pOptionStr"
					if (( $? != 0 )); then vecho "${spaces}[setupPrinters] warning: set printer options failed <$?>.."; fi
			else
				echo "${spaces}[setupPrinters] Printer PPD file <${pFeatureArray[$c_pDriver]}> not exist."
			fi
		fi
		let "count++"
		vecho ""
	done
   vecho "${spaces}[setupPrinters] done, $count printer(s) processed, $printerOK printer(s) setup successful."
   return $ireturn
}

# ----------------------------------------------------------
# Seek for the computer group that contains computer info  #
# Input:
#    $1 = computer Info field name
#    $2 = printer list file
# Return:
#    the index of the CompGroups in printer list file
#    -1: not found
# ----------------------------------------------------------
function seekCompGroup()
{
	local sField="$1"
	local sPList="$2"
	local spaces="  $3"
	local index=0
	local defaultindex=-1
	local found=false
	local myReturn=-1
	local sDefault=false
	
   sText=$(defaults read /Library/Preferences/com.apple.RemoteDesktop $sField)
	sText=$(echo ${sText//[[:space:]]/} | awk '{print tolower($0)}')
   vecho "${spaces}[testCompID] current ComputerInfo field <$sField>=<$sText>."
	# turn to lower case and delete all spaces
   while true; do
		sID=$($plBuddy "print CompGroups:$index:ComputerID" "$sPList" 2>&-)
		if (( $? == 0 )); then
			sID=`echo ${sID//[[:space:]]/} | awk '{print tolower($0)}'`
			if [[ $sText == *"$sID"* ]]; then
				vecho "${spaces}[seekCompGroup] found computer group[$index]=$sID."
				found=true; myReturn=$index; break;
			fi
		else
			found=false; break; 
		fi
		sDefault=$($plBuddy "print CompGroups:$index:Default" "$sPList" 2>&-)
		if $sDefault; then defaultindex=$index; fi
		let "index++";
   done
   if ! $found; then 
   	if (( $defaultindex >= 0 )) ; then
   		myReturn=$defaultindex
   		vecho "${spaces}[seekCompGroup] NOT found computer group, use default <$defaultindex>."
   	else
   		myReturn=-1
   		vecho "${spaces}[seekCompGroup] NOT found computer group and no default found."
   	fi
   fi
	return $myReturn
}

# ------------------------------
# read settings in config file #
#   $1 = config file				 #
# ------------------------------
initRPrinterList()
{
   local sPList="$1"
   local spaces="  $2"
   vecho "${spaces}[initRPrinterList] sPlist=<$1>."
   ardCompuField=$($plBuddy "print ComputerInfo" "$sPList" 2>&-)
	listVersion=$($plBuddy "print Version" "$sPList" 2>&-)
   vecho "${spaces}		ardCompuField=<$ardCompuField>"
   vecho "${spaces}		Version=<$listVersion>"
   vecho "${spaces}		Fnished reading common fields from printer list <$1>."
}

# ---------------------------Permissions Section-----------------------------------
# -------------------------------------------------------
# Adding group/users to _lpoperator group               #
# Input:
#    $1 = the compGroups index
#    $2 = printer list file
# Return:
#    N/A
# CALL:
#	  set_lpOperators "$compGroup" "$pList" "$spaces"
# -------------------------------------------------------
set_lpOperators()
{
	local index="$1"
	local sPlist="$2"
   local spaces="  $3"
	local count=0
	local group=""
	local member=""
	
	while true; do
		group=$($plBuddy "print :CompGroups:$index:PrinterOperator:$count:group" "$sPlist" 2>&-)
		member=$($plBuddy "print :CompGroups:$index:PrinterOperator:$count:member" "$sPlist" 2>&-)
		if (( $? != 0 )); then
			break;
		else
		   dseditgroup -o edit -a "$member" -t $group _lpoperator &>/dev/null
			if (( $? != 0 )); then
				vecho "${spaces}[set_lpOperators] ERROR $?: adding member <$member> as <$group>."
		   else
				vecho "${spaces}[set_lpOperators] added member <$member> as <$group>."
			fi
		fi
		let "count++";
	done
	vecho "${spaces}[set_lpOperators] added <$count> group/user to printer operator group."
}

# -------------------------------------------------------
# Adding group/users to _lpadmin group  #
# Input:
#    $1 = the compGroups index
#    $2 = printer list file
# Return:
#    N/A
# CALL:
#    set_lpAdmin "$compGroup" "$pList" "$spaces"
# -------------------------------------------------------
set_lpAdmin()
{
	local index="$1"
	local sPlist="$2"
   local spaces="  $3"
	local count=0
	local group=""
	local member=""
	
	while true; do
		group=$($plBuddy "print :CompGroups:$index:PrinterAdmin:$count:group" "$sPlist" 2>&-)
		member=$($plBuddy "print :CompGroups:$index:PrinterAdmin:$count:member" "$sPlist" 2>&-)
		if (( $? != 0 )); then
			break;
		else
		   dseditgroup -o edit -a "$member" -t $group _lpadmin &>/dev/null
			if (( $? != 0 )); then
				vecho "${spaces}[set_lpAdmin] ERROR $?: adding member <$member> as <$group>."
		   else
				vecho "${spaces}[set_lpAdmin] added member <$member> as <$group>."
			fi
		fi
		let "count++";
	done
	vecho "${spaces}[set_lpAdmin] added <$count> group/user to printer admin group."
}


# -------------------------------------------------------
# Compare two strings, like <left> <match> <right>  #
# Input:
#    $1 = left side
#    $2 = right side
#    $3 = match string
# Return:
#    0: if match
#    1: if NOT match
# CALL:
#    isMatchString "$name" "$device" "$match" "$spaces"
# -------------------------------------------------------
isMatchString()
{
   local left="$1"
   local right="$2"
   local match="$3"
   local spaces="  $4"
   local iret=1
   
	case "$match" in
		"like")
			if [[ "$left" = *"$right"* ]]; then
				vecho "${spaces}[isMatchString] <$left> match($match) <$right>"
				iret=0
			fi
		;;
		"!like")
			if [[ "$left" != *"$right"* ]]; then
				vecho "${spaces}[isMatchString] <$left> match($match) <$right>"
				iret=0
			fi
		;;
		"is"|"=")
			if [[ "$left" == "$right" ]]; then
				vecho "${spaces}[isMatchString] <$left> match($match) <$right>"
				iret=0
			fi
		;;
		"!is"|"!=")
			if [[ "$left" != "$right" ]]; then
				vecho "${spaces}[isMatchString] <$left> match($match) <$right>"
				iret=0
			fi
		;;
		"-z"|"null")
			if [ -z "$left" ]; then
				vecho "${spaces}[isMatchString] <$left> match($match) <$right>"
				iret=0
			fi
		;;
		"-n"|"!null")
			if [ -z "$left" ]; then
				vecho "${spaces}[isMatchString] <$left> match($match) <$right>"
				iret=0
			fi
		;;
		">"|"gt")
			if [[ "$left" > "$right" ]]; then
				vecho "${spaces}[isMatchString] <$left> match($match) <$right>"
				iret=0
			fi
		;;
		"<"|"lt")
			if ! [[ "$left" > "$right" ]]; then
				vecho "${spaces}[isMatchString] <$left> match($match) <$right>"
				iret=0
			fi
		;;
		">="|"nl")
			if ! [ "$left" < "$right" ]; then
				vecho "${spaces}[isMatchString] <$left> match($match) <$right>"
				iret=0
			fi
		;;
	esac
	return $iret
}

# -------------------------------------------------------
# Remove descritpion matched printers  #
# Input:
#    $1 = description name
#    $2 = match string
# Return:
#    N/A
# CALL:
#    rmPrinterDescrition "$name" "$spaces"
# -------------------------------------------------------
rmPrinterDescrition()
{
	local name="$1"
	local match="$2"
   local spaces="  $3"
	local count=0
	
#	vecho "${spaces}[rmPrinterDescrition] initial print queue list=="
#	lpstat -v 2>&- | sed -e "s/^/  ${spaces}-> /"
	# stopCUPS
	
	for printer in `lpstat -p | awk '{print $2}' | grep -v "unknow"`; do
#   lpstat -p 2>&- | awk '{print $2}' | while read printer; do
		lpstat -v $printer &>/dev/null
		if (( $? == 0 )); then
			#device=`lpstat -v $printer | awk '{print $3}' | sed 's/:$//'`
			device="$printer"
			description=`lpstat -l -p $printer | grep Description | awk -F ":" '{print $2}'`
			isMatchString "$description" "$name" "$match" "$spaces"
			if (( $? == 0 )); then
				lpadmin -x $printer 2>&-
				let "count++";
				vecho "${spaces}[rmPrinterDescrition] .Delete Printer($count): $printer , description match($match) <$name>"
			fi
		fi
	done 
#	vecho "${spaces}[rmPrinterDescrition] current print queue list=="
#	lpstat -v 2>&- | sed -e "s/^/  ${spaces}-> /"
	#startCUPS
   return $count
}

# -------------------------------------------------------
# Remove Device matched printers  #
# Input:
#    $1 = Device name
#    $2 = match string
# Return:
#    N/A
# CALL:
#    rmPrinterDevice "$name" "$spaces"
# -------------------------------------------------------
rmPrinterDevice()
{
	local name="$1"
	local match="$2"
   local spaces="  $3"
   local count=0
#	vecho "${spaces}[rmPrinterDevice] initial print queue list=="
#	lpstat -v 2>&- | sed -e "s/^/  ${spaces}-> /"
	# stopCUPS
	
	for printer in `lpstat -p | awk '{print $2}' | grep -v "unknow"`; do
#   lpstat -p 2>&- | awk '{print $2}' | while read printer; do
		lpstat -v $printer &>/dev/null
		if (( $? == 0 )); then
			#device=`lpstat -v $printer | awk '{print $3}' | sed 's/:$//'`
			device="$printer"
			description=`lpstat -l -p $printer | grep Description | awk -F ":" '{print $2}'`
			isMatchString "${device/:/}" "$name" "$match" "$spaces"
			if (( $? == 0 )); then
				lpadmin -x $printer 2>&-
				let "count++";
				vecho "${spaces}[rmPrinterDevice] .Delete Printer($count): $printer , Device match <$name>"
			fi
		fi
	done 
#	vecho "${spaces}[rmPrinterDevice] current print queue list=="
#	lpstat -v 2>&- | sed -e "s/^/  ${spaces}-> /"
	#startCUPS
	return $count
}

# -------------------------------------------------------
# Remove Protocol matched printers  #
# Input:
#    $1 = Protocol name
#    $2 = match string
# Return:
#    N/A
# CALL:
#    rmPrinterProtocol "$name" "$spaces"
# -------------------------------------------------------
rmPrinterProtocol()
{
	local count=0
	local name="$1"
	local match="$2"
   local spaces="  $3"
   
	# stopCUPS
	for printer in `lpstat -p | awk '{print $2}' | grep -v "unknow"`; do
#   lpstat -p 2>&- | awk '{print $2}' | while read printer; do
		lpstat -v $printer &>/dev/null
		if (( $? == 0 )); then
			# device=`lpstat -v $printer | awk '{print $4}'`
			# device=`lpstat -v $printer | awk '{print $3}' | sed 's/:$//'`
			device="$printer"
			description=`lpstat -l -p $printer | grep Description | awk -F ":" '{print $2}'`
			# protocol=`lpstat -v $printer | awk '{print $4}'| cut -f1 -d":"`
			protocol=`lpstat -v $printer | awk '{print $4}'`
			isMatchString "$protocol" "$name" "$match" "$spaces"
			if (( $? == 0 )); then
				lpadmin -x $printer 2>&-
		   	let "count++";
				vecho "${spaces}[rmPrinterProtocol] .Delete Printer($count): $printer, protocol match <$name>."
			fi
		fi
	done 
	return $count
}

# -------------------------------------------------------
# Remove printers defined in RemovePrinterList array  #
# Input:
#    $1 = the compGroups index
#    $2 = printer list file
# Return:
#    N/A
# CALL:
#    removePrinterList "$compGroup" "$pList" "$spaces"
# -------------------------------------------------------
removePrinterList()
{
	local index="$1"
	local sPlist="$2"
   local spaces="  $3"
	local count=0
	local type=""
	local name=""
	local match=""
	local ireturn=0
	
#	vecho "${spaces}[removePrinterList] start remove printer list."
	vecho "${spaces}[removePrinterList] initial print queue list=="
	lpstat -v 2>&- | sed -e "s/^/  ${spaces}-> /"

	while true; do
		type=$($plBuddy "print :CompGroups:$index:RemovePrinterList:$count:Type" "$sPlist" 2>&-)
		name=$($plBuddy "print :CompGroups:$index:RemovePrinterList:$count:Name" "$sPlist" 2>&-)
		match=$($plBuddy "print :CompGroups:$index:RemovePrinterList:$count:Compare" "$sPlist" 2>&-)
		if (( $? != 0 )); then
			break;
		else
			vecho "${spaces}[removePrinterList] processing: type=<$type> match=<$match> name=<$name>."
			case $type in
				Description)
				rmPrinterDescrition "$name" "$match" "$spaces"
				ireturn=$?
				;;
				DeviceName)
				rmPrinterDevice "$name" "$match" "$spaces"
				ireturn=$?
				;;
				Protocol)
				rmPrinterProtocol "$name" "$match" "$spaces"
				ireturn=$?
				;;
			esac
			vecho "${spaces}[removePrinterList] removed <$ireturn> printer(s): whoes type=<$type> matches <$match> name=<$name>."
#			vecho ""
		fi
		let "count++";
	done

	vecho "${spaces}[removePrinterList] current print queue list=="
	lpstat -v 2>&- | sed -e "s/^/  ${spaces}-> /"
	vecho ""
#	vecho "${spaces}[removePrinterList] <$count> records of removePrinters have been processed."
}


# ----------------------------------------------------------
# remove from OD binding  #
# Input:
#    $1 = the compGroups index
#    $2 = printer list file
# Return:
#    N/A
# CALL:
#	  removeODBind "$compGroup" "$pList" "$spaces"
# ----------------------------------------------------------
removeODBind()
{
	local index="$1"
	local sPlist="$2"
   local spaces="  $3"
	local removeOD=false
	
	removeOD=$($plBuddy "print CompGroups:$index:removeOD" "$sPlist" 2>&-)
	if  (( $? == 0 )) && $removeOD ; then
		od=$(dscl localhost -list /LDAPv3 2>&-)
		if [ -n "$od" ]; then
		   dsconfigldap -fr "$od" 2>&-
		   vecho "${spaces}[removeODBind] removeOD=$removeOD, OD is unbound."
		else
			vecho "${spaces}[removeODBind] removeOD=$removeOD, no OD binding."
		fi;
	else
	   vecho "${spaces}[removeODBind] removeOD=$removeOD, OD binding not touched."
	fi
	return 0
}


# ----------------------------------------------------------
# reset CUPS printers  #
# Input:
#    $1 = the compGroups index
#    $2 = printer list file
# Return:
#    N/A
# CALL:
#	  resetCUPS "$compGroup" "$pList" "$spaces"
# ----------------------------------------------------------
resetCUPS()
{
	local index="$1"
	local sPlist="$2"
   local spaces="  $3"
	local ifreset=false
	
	ifreset=$($plBuddy "print CompGroups:$index:resetCUPS" "$sPlist" 2>&-)
	if  (( $? == 0 )) && $ifreset ; then
#	if  $ifreset; then
		rmAllPrinters "$spaces"
		vecho "${spaces}[resetCUPS] removed all printers."
	else
	   vecho "${spaces}[resetCUPS] CUPS has no change."
	fi
	return 0
}

# ----------------------------------------------------------
# reset CUPS printers  #
# Input:
#    $1 = the compGroups index
#    $2 = printer list file
# Return:
#    N/A
# CALL:
#	  resetCUPS "$compGroup" "$pList" "$spaces"
# ----------------------------------------------------------
setEveryone()
{
	local index="$1"
	local sPlist="$2"
   local spaces="  $3"
	local ifreset=false
	
	ifreset=$($plBuddy "print CompGroups:$index:everyone" "$sPList" 2>&-)
	if  (( $? == 0 )) && $ifreset ; then
		dseditgroup -o edit -a everyone -t group _lpadmin 2>&-
		vecho "${spaces}[setEveryone] added everyone to _lpadmin."
	else
		dseditgroup -o edit -d everyone -t group _lpadmin 2>&-
	   vecho "${spaces}[setEveryone] deleted everyone from _lpadmin."
	fi
	return 0
}


# ---------------------------Main Section-----------------------------------
# main function #
start()
{
   local spaces=" ."
   local iRet=0
   
	vecho "${spaces}[Start] start."
	if [ ! -f "$pConfig" ]; then vecho "${spaces}[Start] printer configuration file <$pConfig> not exist." 1>&2; exit -1; fi
	if [ ! -f "$pList" ]; then vecho "${spaces}[Start] printer list file <$pList> not exist." 1>&2; exit -1; fi
   initRPrinterList "$pList" "$spaces"
   seekCompGroup "$ardCompuField" "$pList" "$spaces"
   compGroup=$?
	if (( $compGroup < 255 )); then
		removeODBind "$compGroup" "$pList" "$spaces"
		resetCUPS "$compGroup" "$pList" "$spaces"
		set_lpOperators "$compGroup" "$pList" "$spaces"
		set_lpAdmin "$compGroup" "$pList" "$spaces"
		removePrinterList "$compGroup" "$pList" "$spaces"
		setEveryone "$compGroup" "$pList" "$spaces"
		setupPrinters "$compGroup" "$pList" "$pConfig" "$spaces"

		vecho "${spaces}>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
		vecho "${spaces} current printers:"
		lpstat -v 2>&- | sed -e "s/^/  ${spaces}-> /"
		vecho "${spaces}<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
		vecho ""
	fi
	vecho "${spaces}[start] done."
}

#---------
# Main
#---------
#run as root
if [ “$(id -u)” != “0” ]; then printf "$sname must be run as root.\n"; exit 1; fi
initialLog "$log_tag"
options=""
for i in "$@"; do
	case $i in
		-h|--help|-\?) printf "$usage\n"; 	exit;  ;;
		-v|--verbose)	Verbose=true; 		shift; ;;
		--config|-c)	options="-c";		shift; ;;
		--list|-l)		options="-l";		shift; ;;
		*)	if [ "$options" = "-c" ]; then pConfig="$i";	fi;
			if [ "$options" = "-l" ]; then pList="$i";	fi;	;;
	esac
done
#echo "pConfig=$pConfig", "pList=$pList"
if [ -f "$pConfig" ] && [ -f "$pList" ]; then start; else printf "$usage\n"; fi;
closeLog "$log_tag" "$spaces"
exit 0
