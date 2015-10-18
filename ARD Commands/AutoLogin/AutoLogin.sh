#!/bin/sh 
USERNAME="username"
PASSWORD="passsword" 

logger "AutoLogin Start…."
sleep 3

PID=`ps -ax | grep loginwindow.app | grep -v grep | tail -n 1 | awk '{print $1}'` 

launchctl bsexec $PID osascript -e "tell application \"System Events\" to keystroke \"\"" 
launchctl bsexec $PID osascript -e "tell application \"System Events\" to keystroke \"$USERNAME\"" 
sleep 2 
launchctl bsexec $PID osascript -e "tell application \"System Events\" to keystroke return" 
sleep 2 
launchctl bsexec $PID osascript -e "tell application \"System Events\" to keystroke \"$PASSWORD\"" 
sleep 2 
launchctl bsexec $PID osascript -e "tell application \"System Events\" to keystroke return" 

logger "AutoLogin End…."
exit 0