#!/bin/bash

# ------------------------------------------------------------------------------------
# continueEncrypt.sh
#
# Purpose:
#    Prevent system from sleep or shutdown if the defined condition not satisfied.
#
# Process:
#    0. read system energy sleep settings, count the highest possible interval
#    1. During the initializing period:
#       create launchd plist file, copy self to destination and launch it, then quit.
#    2. System launchd will invoke this daemon script upon the interval reached.
#    3. everytime it's launched, it does step 0 and 1, then call noSleep to prevent system
#       going to sleep.
#    4. If system sleep is changed, it update launch daemons interval accordingly.
#    5. Check if can not Stop, quit with nothing changed.
#    5.1 Check if has a login user, bypass do nothing.
#    5.1.1 if no lgoin user, cleanup and restart.
#
# How to install:
#    if the launchdaemon plist file not exists, script installs itself.
#
# How to test:
#    Run the following commands:
#       Check if scheduled or repeat are all gone
#          pmset -g sched
#       Check if the daemon loaded
#          launchctl list | grep edu.sample.continueEncrypt
#       Check its log
#          cat /var/log/edu.sample.continueEncrypt.log
#          tail -n40 /var/log/continueEncrypt.log
#       Launch it immediately & manually:
#          launchctl kickstart system/edu.sample.continueEncrypt
#         or
#          /usr/local/bin/continueEncrypt.sh
#       Read / check launchd settings:
#          defaults read /Library/LaunchDaemons/edu.sample.continueEncrypt.plist
#
# History:
#   2017-05-04: prototype, version 0.1
#   2017-05-10, version = 1.0
#
# Author:
#   Tony Liu, TonyLiu2ca@yahoo.com
# ------------------------------------------------------------------------------------

# The daemon identification string
identify="edu.sample.continueEncrypt"
# Log file name
logFile="/var/log/${identify}.log"
# The daemon plist file fullpath
daemon="/Library/LaunchDaemons/$identify.plist"
# The script file name
prgName="continueEncrypt.sh"
# The fullpath of the script file
prgFullPath="/usr/local/bin/$prgName"
# The system default none stop delay
nonestopDelay=1200
# restart time with 24 hours number, 1 = 1:00AM
restartTime=1
# 
miniTimer=0

# ----------------------------------------------------------------------------------------
# personal adding log function
# Return:
#    N/A
# ----------------------------------------------------------------------------------------
mylog()
{
   /bin/echo "$(date) : $1" >> "$logFile"
}

mylogprintf()
{
   /usr/bin/printf "%s\n" "$1" >> "$logFile"
}

# ----------------------------------------------------------------------------------------
# prevent system goes to sleep by emulate user active and cancel all repeat and schedules.
# Return:
#    N/A
#
# Launchd does not allow daemons to nohup or disown, so the following not working.
#		nohup caffeinate -imu -t $nonestopDelay &
#		nohup caffeinate -t $((nonestopDelay-30)) & disown
# ----------------------------------------------------------------------------------------
noSleep()
{
	mylog "noSleep: ..."
	/usr/bin/caffeinate -u -t1; /usr/bin/pmset repeat cancel; /usr/bin/pmset schedule cancelall
	pmsetStatus=$(pmset -g|sed 's/^/       /')
	mylog "noSleep: Power Management status:"
	mylogprintf "$pmsetStatus"
	mylog "noSleep: (sent user is active signal and cancel all repeat and schedules)"
}

# ----------------------------------------------------------------------------------------
# Self cleanup and restart the machine
# Return:
#    N/A
# ----------------------------------------------------------------------------------------
cleanup()
{
	mylog "cleanup: ..."
	/sbin/shutdown -r +1; /bin/rm "$daemon"
	mylog "cleanup: done"
	rm "$0"
}

# ----------------------------------------------------------------------------------------
# Test if a user logged in
# Return:
#    0: YES
#    1: No
# ----------------------------------------------------------------------------------------
ifLoginUser()
{
	mylog "ifLoginUser: ..."
	condition="N/A"; iReturn=0
	anyuser=$(/usr/bin/who)
	[ -n "$anyuser" ] && { condition="$anyuser"; iReturn=1; }
	mylog "ifLoginUser: $condition, $iReturn"; return $iReturn
}


# ----------------------------------------------------------------------------------------
# Test if it is after 2:00AM
# Return:
#    0: YES
#    1: NO
# ----------------------------------------------------------------------------------------
midRestart()
{
	condition="No"
	iReturn=1
   mylog "midRestart: ..."
   hour=$(/bin/date +"%H")
   (( hour < restartTime )) && { condition="Yes"; iReturn=0; }
   mylog "midRestart: $condition, $iReturn"; return $iReturn
}

# ----------------------------------------------------------------------------------------
# Test if can stop
# Return:
#    0: STOP
#    1: continue
# ----------------------------------------------------------------------------------------
canStop()
{
   mylog "canStop: ..."
	condition="No"; iReturn=1
	if [ -f /Library/PreferencePanes/Dell\ Data\ Protection.prefPane/Contents/Helpers/client ]; then 
		percentDone=$(/Library/PreferencePanes/Dell\ Data\ Protection.prefPane/Contents/Helpers/client -d 2>&1 | grep PercentDone | awk '{ print $3}'  | head -n 1)
	   mylog "canStop: percentDone=[$percentDone]"
		[[ "$percentDone" = "1;" ]] && { condition="Yes"; iReturn=0; }
	else
		condition="Yes"; iReturn=0;
	fi
	mylog "canStop: $condition, $iReturn"; return $iReturn
}

# ----------------------------------------------------------------------------------------
# computer the minimum delay time in seconds
# Return:
#    time in seconds
# ----------------------------------------------------------------------------------------
getMinimumTimer()
{
	mylog "getMinimumTimer: ..."
	timer=$(/usr/bin/pmset -g custom | /usr/bin/grep " sleep" | /usr/bin/awk '{print $2}'|/usr/bin/sort -n | head -n1)
	mylog "getMinimumTimer: = $timer (minutes)"
	for miniTimer in $timer; do
		(( miniTimer != 0 )) && break
	done
	miniTimer=$((miniTimer*60))
	mylog "getMinimumTimer: minimum time=$miniTimer (seconds)"
}

# ----------------------------------------------------------------------------------------
# Computer the none stop delay seconds
#
# set to 5 minutes.
# If the minimum delay seconds:
#   > 59: will start 20 seconds earlier.
#   else: mean system do no sleep, but we still check every hour, or any interval like.
#
# Return:
#    nonestopDeply in seconds
# ----------------------------------------------------------------------------------------
setTimer()
{
	mylog "setTimer: ..."
	getMinimumTimer
	mylog "setTimer: minimum sleep = $miniTimer"
	(( miniTimer < 300 )) && nonestopDelay=$((miniTimer-20)) || nonestopDelay=300
	mylog "setTimer: nonestopDelay = $nonestopDelay"
}

# ----------------------------------------------------------------------------------------
# Update daemon internal if needed
#
# If the current deplay internal is different from plist one, update the plist file
#
# Return:
#    N/A
# ----------------------------------------------------------------------------------------
updateService()
{
	mylog "updateService: ..."
	if [ -f "$daemon" ]; then
		curTimer=$(/usr/bin/defaults read $daemon StartInterval)
		(( curTimer != nonestopDelay )) && /usr/bin/defaults write $daemon StartInterval $nonestopDelay
		mylog "updateService: updated from $curTimer to $nonestopDelay"
	fi
}

# ----------------------------------------------------------------------------------------
# Initiallizing process
#
# If the daemon plist file doesn't exist, it's no initialized, then
#   create the plist, copy scriptm and launch daemon
#
# Return:
#    0: initializing is done
#    1: bypass initializing
# ----------------------------------------------------------------------------------------
initialized()
{
   mylog "initializing: ..."
	if [ ! -f "$daemon" ]; then
		/bin/cat <<EOF >$daemon
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$identify</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/bash</string>
		<string>$prgFullPath</string>
	</array>
	<key>RootDirectory</key>
	<string>/usr/local/bin</string>
	<key>RunAtLoad</key>
	<true/>
	<key>StandardErrorPath</key>
	<string>/dev/null</string>
	<key>StandardOutPath</key>
	<string>/dev/null</string>
	<key>StartInterval</key>
	<integer>$nonestopDelay</integer>
	<key>WorkingDirectory</key>
	<string>/usr/local/bin</string>
</dict>
</plist>
EOF
		/bin/cp "$0" "$prgFullPath"
		nohup /usr/bin/caffeinate -ismu -w 1 </dev/null >/dev/null 2>&1 & disown
		/bin/chmod 777 "$prgFullPath"
		/bin/launchctl load $daemon
		/bin/sleep 2
		#		launchctl kickstart system/$identify
	   mylog "initializing: done"
		return 1
	else
	   mylog "initializing: bypass"
	   return 0
	fi
}


if [ ! -f "$logFile" ]; then touch "$logFile"; fi
mylog "--- Starting ---"
setTimer
if initialized; then 
	noSleep
	updateService
	if canStop; then
		if ifLoginUser; then
			mylog " . no login user."
			cleanup
		fi
		if midRestart; then	
			mylog " . midRestart."
			cleanup
		fi
	fi
else
	/bin/rm "$0"
fi
mylog "--- e n d i n g"

