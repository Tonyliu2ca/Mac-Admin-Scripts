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
sUserPWDTime="accountPolicyData"
sUserHashPWD="ShadowHashData"
sUserShell="UserShell"
sUserInitPWDTime="${sUserPWDTime}_Initial"
sUserInitHashPWD="${sUserHashPWD}_Initial"
sUserInitShell="${sUserShell}_Initial"

StatusChanged=0
StatusNotChanged=1

readUserPWDTime () { dscl . -read /users/$sUserID "$sUserPWDTime" | grep -A1 "passwordLastSetTime" &>/dev/null }
readUserHashPWD () { dscl . -read /users/$sUserID "$sUserHashPWD" | tail -1 | tr -dc 0-9a-f &>/dev/null }
readUserShell   () { dscl . -read /Users/$sUserID "$sUserShell" | awk '{ print $2}' &>/dev/null }
readUserInitPWDTime () { dscl . -read /users/$sUserID "$sUserInitPWDTime" &>/dev/null }
readUserInitHashPWD () { dscl . -read /users/$sUserID "$sUserInitHashPWD" &>/dev/null }
readUserInitShell   () { dscl . -read /Users/$sUserID "$sUserInitShell" &>/dev/null }
updateUserProperty  () { dscl . -create /users/$sUserID "$1" "$2" &>/dev/null }
# writeUserPWD () { dscl . -create /users/$sUserID "$1" "$2" }
# writeUserStatus () { dscl . -create /users/$sUserID "$1" "$2" }
# writeUserShell () { dscl . -create /Users/$sUserID "$1" "$2" }

initialUserStatus () {
   if [[ $(readUserInitPWDTime) ]]; then
      userPWDTime=$(readUserPWDTime "$sUserPWDTime")
      userPWD=$(readUserHashPWD "$sUserHashPWD")
      userShell=$(readUserShell "$sUserShell")
      updateUserProperty "$sUserInitPWDTime" "$userPWDTime"
      updateUserProperty "$sUserInitHashPWD" "$userPWD"
      updateUserProperty "$sUserInitShell" "$userShell"
   }
}

logoutUser () {
   while true; do
      [[ "$(stat -f "%Su" /dev/console)" == "$sUserID" ]] \
         && launchctl bootout user/$sUserID \
         || break
      sleep 5
   done
}

disableUser () {
   logoutUser
   updateUserProperty "$sUserShell" "/usr/bin/false"
}

restoreStatus () {
   userPWD=$(readUserHashPWD "$sUserInitHashPWD")
   updateUserProperty "$sUserHashPWD" "$userPWD"
   userPWDDate=$(readUserPWDTime "$sUserPWDTime")
   updateUserProperty "$sUserInitPWDTime" "$userPWDDate"
}

enableUser () {
   logoutUser
   updateUserProperty "$sUserShell" "$(readUserInitShell)"
   restoreStatus
}

testUserStatusChged () {
    userStatus=$(readUserPWDTime "$sUserPWDTime")
    userInitStatus=$(readUserPWDTime "$sUserInitPWDTime")
    [ "$userStatus" = "$userInitStatus" ] && return 1 || return 0
}

if [[ ! -z "${sUserID// }" ]]; then
   initialUserStatus
   if [ testUserStatusChged ]; then
       disableUser
       sleep 20
       enableUser
   fi
fi
