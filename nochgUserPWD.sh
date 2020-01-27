#!/bin/bash

# ------------------------------------------------------------------------------------
# Name: nochgUserPWD.sh
# ------------------------------------------------------------------------------------
#
# ---------------------
# Description:
#    Test if a user account password is changed by other than customized service
#    and then logout and reset password to initial password
#
# ---------------------
# Condition:
#    1. Initialization:
#       if initial_password_time or initial_password are not set, then save "password 
#       changed time"" and "password" as initial_password_time and initial_password
#
#    2. Test on login:
#       If the account's "password changed time" is different from initial_password_time
#       then restore user's initial_password and set initial_password_time
#
# ---------------------
# History:
#    2020-02-20, Initial version 0.2
#
# ---------------------
# License: MIT License
#
# Copyright (c) 2020- Tony Liu
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ------------------------------------------------------------------------------------


sUserID=${1:-}
#loginUser=$(stat -f "%Su" /dev/console)
loginUser="$1"
userPWDlog="/tmp/nochgUserPWD.log"

echo "------- $(date) ($sUserID) -------"  >> "$userPWDlog"

#sUserPWDTime="accountPolicyData"
sUserHashPWD="ShadowHashData"
sUserShell="UserShell"
#sUserInitPWDTime="${sUserPWDTime}_Initial"
sUserInitHashPWD="${sUserHashPWD}_Initial"
sUserInitShell="${sUserShell}_Initial"

#readUserPWDTime () { 
#  dscl . -read /users/"$sUserID" accountPolicyData  | tail -n +2 > /tmp/accountPolicyData.plist 
#  defaults read /tmp/accountPolicyData.plist passwordLastSetTime
#}
#readUserInitPWDTime () { dscl . -read /users/"$sUserID" "$sUserInitPWDTime"; }
# readUserShell   () { dscl . -read /Users/"$sUserID" "$sUserShell" | awk '{ print $2}'; }
# readUserInitShell   () { dscl . -read /Users/"$sUserID" "$sUserInitShell"; }
readUserShell   () { dscl . -read /Users/"$sUserID" "$1" | awk '{ print $2}'; }
writeUserShell  () { dscl . -create /users/"$sUserID" "$1" "$2"; }

# readUserHashPWD () { defaults read /var/db/dslocal/nodes/Default/users/"$sUserID".plist "$sUserHashPWD"; }
#readUserInitHashPWD () { defaults read /var/db/dslocal/nodes/Default/users/"$sUserID".plist "$sUserInitHashPWD"; }
readUserHashPWD () { defaults read /var/db/dslocal/nodes/Default/users/"$sUserID".plist "$1"; }
writeUserPWD () { defaults write /var/db/dslocal/nodes/Default/users/"$sUserID".plist "$1" "$2"; }

initialUserStatus () {
   echo " -initialUserStatus:" >> "$userPWDlog"
   initPWD=$(readUserHashPWD "$sUserInitHashPWD" 2>/dev/null)
   if [[ "$initPWD" = "" ]]; then
      echo "  -initializing: ($sUserInitHashPWD)" >> "$userPWDlog"
#      userPWDTime=$(readUserPWDTime)
      uPWD=$(readUserHashPWD "$sUserHashPWD")
#      userShell=$(readUserShell "$sUserShell")
      echo "   - uPWD=$uPWD;" >> "$userPWDlog"
      writeUserPWD "$sUserInitHashPWD" "$uPWD"
      # writeUserShell "sUserInitShell" "$userShell"
   else
      echo "  -was initialized:($sUserInitHashPWD)" >> "$userPWDlog"
   fi
}

logoutUser () {
   echo " -logoutUser:" >> "$userPWDlog"
#   shutdown -r +2
   killall loginwindow
}

disableUser () {
   echo " -disableUser:" >> "$userPWDlog"
   # updateUserProperty "$sUserShell" "/usr/bin/false"
   # logoutUser
}

restoreStatus () {
   echo " -restoreUserStatus" >> "$userPWDlog"
   userPWD=$(readUserHashPWD "$sUserInitHashPWD")
   writeUserPWD "$sUserHashPWD" "$userPWD"
   # userPWDDate=$(readUserPWDTime)
   # updateUserProperty "$sUserInitPWDTime" "$userPWDDate"
}

enableUser () {
   echo " -enableUser:" >> "$userPWDlog"
   # updateUserProperty "$sUserShell" "$(readUserInitShell)"
   restoreStatus
   logoutUser
}

testUserStatusChged () {
    echo " -testUserStatusChged:" >> "$userPWDlog"
    currentPWD=$(readUserHashPWD "$sUserHashPWD")
    echo "   -currentPWD=$currentPWD" >> "$userPWDlog"
    initPWD=$(readUserHashPWD "$sUserInitHashPWD")
    echo "   -initPWD=$initPWD" >> "$userPWDlog"
    [ "$currentPWD" = "$initPWD" ] && return 1 || return 0
}

echo "Start: Init_user=$sUserID" >> "$userPWDlog"
if [[ -n "${sUserID// }" ]]; then
   echo "     : current user=$(id -un); login user=$loginUser" >> "$userPWDlog"
   if [ "$sUserID" = "$loginUser" ]; then
      echo "     : InitUser is $loginUser continue..." >> "$userPWDlog"
      initialUserStatus
      if testUserStatusChged; then
          echo "     : $(id -un) password CHANGED." >> "$userPWDlog"
          disableUser
          # sleep 20
          enableUser
      else
         echo "     : $(id -un) password OK." >> "$userPWDlog"
      fi
   fi
else
   echo "     : need a user command line argument." >> "$userPWDlog"
fi
