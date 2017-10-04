#!/bin/bash

## USAGE:
## 	_script_ [-r|-t|-m <path>] [-u|-a|-U <username>] [-q] [-h]
## 
## DESCRIPTION:
## 	Script to remove/show/move (to a path) MS Office 2016 from macOS
## 	Copyright (C) 2017, Tony Liu
## 
## WHERE:
## 	Actions:
## 		-r  to remove, need root privilege
## 		-t  to show the processed files, this is the default action if no action assigned
## 		-m <path> move all to the specific <path>, need root privilege
## 
## 	User choice:
## 		do not evaluate user configurations by default
## 		-u  current user
## 		-U <username> specify which <username>
## 		-a  all local users
## 
## 	Options:
## 		-q  quiet mode
## 		-h  show this help
## 
## EXAMPLES:
## 	-rq
## 		remove all quietly
## 		
## 	-m /Users/Shared/Office2016
## 		Move all to folder /Users/Shared/Office2016
## 
## 	-ra
## 		remove all global and all users local configurations
## 

# ----------------------------------------------------------------------------------------
# Remove Office 2016 for Mac totally
# Remove apps and app data global and user
#
# Ref: https://support.office.com/zh-cn/article/%E9%80%9A%E8%BF%87%E5%9C%A8%E9%87%8D%E6%96%B0%E5%AE%89%E8%A3%85%E4%B9%8B%E5%89%8D%E5%AE%8C%E5%85%A8%E5%8D%B8%E8%BD%BD%E6%9D%A5%E8%A7%A3%E5%86%B3-Office-2016-for-Mac-%E9%97%AE%E9%A2%98-ec3aa66e-6a76-451f-9d35-cba2e14e94c0
# Ref: https://support.office.com/en-us/article/Uninstall-Office-2016-for-Mac-eefa1199-5b58-43af-8a3d-b73dc1a8cae3
# ----------------------------------------------------------------------------------------

sUsage()
{
#  scName=$(basename "$0" .sh)
  [ "$*" ] && echo "$0: $*"
  sed -n -e "s/_script_/$(basename "$0" .sh)/" -e "/^##/,/^$/s/^## \{0,1\}//p" "$0"
}


declare -a LibPrefs=(\
"com.microsoft.autoupdate*" \
"com.microsoft.office*" \
"com.microsoft.excel*" \
"com.microsoft.onenote*" \
"com.microsoft.outlook*" \
"com.microsoft.powerpoint*" \
"com.microsoft.word*" \
"Microsoft/uls")

cmd="echo "
mod=0
mvPath=""
username=""
userMode=0
# userMode=0 : do not touch user settings
# userMode=1 : current user
# userMode=1 : specific user, use username
# userMode=-1 : all users

# check if run as root
if ! [ $(id -u) = 0 ]; then
   echo "Please run me as root!"
   exit 1
fi

# Remove all Office apps.
# Printf "Removing all MS Office apps in /Applications folder...\n"

# ----------------------------------------------------------------------------------------
# Description: it use the appropriate command to do the real work.
# Arguments:
#		$1 = the destination file
# Dependence:
#    Global: cmd， mvPath
# ----------------------------------------------------------------------------------------
goProcess()
{
	if [ -e "$1" ]; then 
		case $cmd in
		R)
			[[ $mod > 0 ]] && rm -fr "$1" &>/dev/null || rm -fr "$1" 
			;;
		T)
			[[ $mod > 0 ]] && echo "$1" &>/dev/null || echo "$1"
			;;
		M)
			[[ $mod > 0 ]] && mv "$1" "$mvPath" &>/dev/null || mv "$1" "$mvPath"
			;;
		esac	
	fi
}

# ----------------------------------------------------------------------------------------
# Description: It traverse array to retrieve each element pass to goProcess.
# Arguments:
#		$1 = the array
# Dependence: N/A
# ----------------------------------------------------------------------------------------
process1Array()
{
	declare -a argAry=("${!1}")
	for each in ${argAry[*]}; do
		goProcess "$each"
	done
}

# ----------------------------------------------------------------------------------------
declare -a OfficeApps=(\
"/Applications/Microsoft Excel.app" \
"/Applications/Microsoft OneNote.app" \
"/Applications/Microsoft Outlook.app" \
"/Applications/Microsoft PowerPoint.app" \
"/Applications/Microsoft Word.app")

# ----------------------------------------------------------------------------------------
# Description: It deal with the Office applications from the Office Application array.
# Arguments: N/A
# Dependence:
#    Global: OfficeApps
# ----------------------------------------------------------------------------------------
pOfficeApps ()
{
	process1Array OfficeApps[@]
}


# ----------------------------------------------------------------------------------------
# Description: Use pkgutil to forget all the packages.
# Arguments: N/A
# Dependence:
#    Global: OfficeApps
# ----------------------------------------------------------------------------------------
pForgetPKG()
{
	pkgutil --forget com.microsoft.pkg.licensing.volume
	pkgutil --forget com.microsoft.package.Proofing_Tools
	pkgutil --forget com.microsoft.pkg.licensing
	pkgutil --forget com.microsoft.package.Fonts
	pkgutil --forget com.microsoft.package.Frameworks
	pkgutil --forget com.microsoft.package.Microsoft_AutoUpdate.app
	pkgutil --forget com.microsoft.package.Microsoft_Excel.app
	pkgutil --forget com.microsoft.package.Microsoft_OneNote.app
	pkgutil --forget com.microsoft.package.Microsoft_Outlook.app
	pkgutil --forget com.microsoft.package.Microsoft_PowerPoint.app
	pkgutil --forget com.microsoft.package.Microsoft_Word.app	
}

# ----------------------------------------------------------------------------------------
declare -a sLibPLaunch=(\
"/Library/LaunchDaemons/com.microsoft.office.licensingV2.helper.plist" \
"/Library/LaunchDaemons/com.microsoft.autoupdate.helper.plist")
declare -a sLibPrivs=(\
"/Library/PrivilegedHelperTools/com.microsoft.office.licensingV2.helper" \
"/Library/PrivilegedHelperTools/com.microsoft.autoupdate.helper")
declare -a sLibAppSupt=(\
"/Library/Application\ Support/Microsoft/MAU2.0" \
"/Library/Application\ Support/Microsoft/MERP*" \
"/Library/Preferences/com.microsoft.office.licensingV2.plist")
# ----------------------------------------------------------------------------------------
# Description: It deal with the system level Library from System Library arrays.
# Arguments: N/A
# Dependence:
#    Global: sLibPLaunch, sLibPrivs and sLibAppSupt
# ----------------------------------------------------------------------------------------
pSysLibrary ()
{
	# Launchd
	process1Array sLibPLaunch[@]
	#PrivilegedHelperTools
	process1Array sLibPrivs[@]
	# Application Support
	process1Array [@]

	for each in ${sLibAppSupt[@]}; do
			for file in "${user}/Library/Preferences/${each}"; do goProcess "$file"; done
	done
	# Preferences
	for each in ${LibPrefs[@]}; do
		for file in "/Library/Preferences/$each"; do goProcess "$file"; done
	done
}

# ----------------------------------------------------------------------------------------
declare -a uLibContainers=(\
"/Library/Containers/com.microsoft.errorreporting" \
"/Library/Containers/com.microsoft.Excel" \
"/Library/Containers/com.microsoft.netlib.shipassertprocess" \
"/Library/Containers/com.microsoft.Office365ServiceV2" \
"/Library/Containers/com.microsoft.Outlook" \
"/Library/Containers/com.microsoft.Powerpoint" \
"/Library/Containers/com.microsoft.RMS-XPCService" \
"/Library/Containers/com.microsoft.Word" \
"/Library/Containers/com.microsoft.onenote.mac")
declare -a uLibGContainers=(\
"/Library/Group Containers/UBF8T346G9.OfficeOsfWebHost" \
"/Library/Group Containers/UBF8T346G9.Office" \
"/Library/Group Containers/UBF8T346G9.ms")
declare -a uLibAppScripts=(\
"/Library/Application Scripts/com.microsoft.Office365ServiceV2" \
"/Library/Application Scripts/com.microsoft.Word" \
)

# ----------------------------------------------------------------------------------------
# Description: It deal with the user level Library from user global arrays.
# Arguments:
#   $1 = the user homepath
# Dependence:
#    Global: LibPrefs, uLibContainers, uLibGContainers
# ----------------------------------------------------------------------------------------
pUserLibrary()
{
	user="%1"
	if [ -d "$user/Library" ]; then
		# Preferences, ByHost, Caches, Application Support
		for each in ${LibPrefs[@]}; do
			for file in "${user}/Library/Preferences/${each}"; do goProcess "$file"; done
			for file in "${user}/Library/Preferences/ByHost/${each}"; do goProcess "$file"; done
			for file in "${user}/Library/Caches/${each}"; do goProcess "$file"; done
		done
		for file in "${user}/Library/Application\ Support/Microsoft/Office*"; do goProcess "$file"; done
		# goProcess "${user}/Caches/Microsoft/uls/com.microsoft.autoupdate.fba"
		# Containers
		process1Array uLibContainers[@]
		# Group Containers
		process1Array uLibGContainers[@]

		# Keychains
		# Microsoft Office Identities Cache 2
		# Microsoft Office Identities Settings 2
	fi
}

# ----------------------------------------------------------------------------------------
# Description: Get the given user home directory and process it.
# Arguments:
#   $1 = username
# Dependence: N/A
# ----------------------------------------------------------------------------------------
pUserSingle()
{	
	home=`dscl . read /Users/"$1" NFSHomeDirectory | awk '{print $2}'`
	pUserLibrary "$home"
}

# ----------------------------------------------------------------------------------------
# Description: Get all local host none-system users and pass to pUserSingle to process.
# Arguments: N/A
# Dependence: N/A
# ----------------------------------------------------------------------------------------
pUserAll()
{
	allUsers=`dscl . list /Users UniqueID | awk '$2 > 500 {print $1}'`
	for user in $allUsers; do
		pUserSingle $user
	done
}

# ----------------------------------------------------------------------------------------
# Description: Start with user mode.
# Arguments: N/A
# Dependence:
#   Global: userMode, destUser
# ----------------------------------------------------------------------------------------
pUserMode()
{
	case $userMode in
	1)
		pUserSingle "$destUser"
		;;
	-1)
		pUserAll
		;;
	esac
}

# ----------------------------------------------------------------------------------------
while getopts ":rqtm:uU:ah" opt; do
	case $opt in
		r)
			#echo "-r to remove!"
			cmd="R"
			;;
		t)
			#echo "-t test mode."
			cmd="T"
			;;
		m)
			#echo "-m to move!"
			cmd="M"
			mvPath="$OPTARG"
			;;
		u)
			#echo "-u to current user!"
			destUser=$(users)
			userMode=1
			;;
		U)
			#echo "-U to specific user!"
			destUser="$OPTARG"
			userMode=1
			;;
		a)
			#echo "-a all users!"
			destUser=""
			userMode=-1
			;;
		q)
			#echo "-q verbose mode."
			mod=1
			;;
		:)
			#echo "Option -$OPTARG requires an argument." >&2
			sUsage >&2
			#echo "$usage" >&2
			exit 2
			;;
		\?)
			#echo "Invalid option: -$OPTARG" >&2
			sUsage >&2
			#echo "$usage" >&2
			;;
		h)
			sUsage 
			#echo "$usage"
			exit 1
			;;	
	esac
done

pOfficeApps
pSysLibrary
pUserMode
exit 0
