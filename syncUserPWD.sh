#!/bin/bash

# 
# Test if a user account password is changed by any other reason
# logout and reset password to initial password
#
# Condition:
#    initialization:
#       save password change date&time and password as initial_password_time and initial_password
#    Test on login:
#    If the account password change data&time is different from initial_password_time
#    then restore user's initial_password
#

sysUserID="test"
sysUserTimeProperty="accountPolicyData"
sysUserIniitialTimeProperty="${sysUserTimeProperty}_Initial"
sysUserPWDProperty="ShadowHashData"
sysUserIniitialPWDProperty="${sysUserPWDProperty}_Initial"
sysUserShell="UserShell"
sysUserInitialShell="${sysUserShell}_Initial"

StatusChanged=True
StatusNotChanged=False

readUserStatus () { dscl . -read /users/$sysUserID "$1" | grep -A1 "passwordLastSetTime" }
writeUserStatus () { dscl . -create /users/$sysUserID "$1" "$2" }
readUserPWD () { dscl . -read /users/$sysUserID "$1" | tail -1 | tr -dc 0-9a-f }
writeUserPWD () { dscl . -create /users/$sysUserID "$1" "$2" }
readUserShell () { dscl . -read /Users/$sysUserID "$1" | awk '{ print $2}' }
writeUserShell () { dscl . -create /Users/$sysUserID "$1" "$2" }

initialUserStatus () {
    userPWD="$(readUserPWD "$sysUserPWDProperty")"
    writeUserPWD "$sysUserIniitialPWDProperty" "$userPWD"
    userPWDDate="$(readUserStatus "$sysUserTimeProperty")"
    writeUserStatus "$sysUserIniitialTimeProperty" "$userPWDDate"
    userShell=$(readUserShell "$sysUserShell")
    writeUserShell "$sysUserInitialShell" "$userShell"
}

logoutUser () {
    if [[ stat -f "%Su" /dev/console == "$sysUserID" ]]; then
        launchctl bootout user/$sysUserID
    fi
}

disableUser () {
    logoutUser
    orgShell=$(dscl . -read /Users/$sysUserID UserShell | awk '{ print $2}')
    dscl . -create /Users/UserShell_Orginal "$orgShell"
    dscl . -create /Users/UserShell_Orginal "/usr/bin/false"
}

restoreStatus () {
    userPWD="$(readUserPWD "$sysUserIniitialPWDProperty")"
    writeUserPWD "$sysUserPWDProperty" "$userPWD"
    userPWDDate="$(readUserStatus "$sysUserTimeProperty")"
    writeUserStatus "$sysUserIniitialTimeProperty" "$userPWDDate"
}

enableUser () {
    orgShell=$(dscl . -read /Users/$sysUserID "$sysUserInitialShell" | awk '{ print $2}')
    dscl . -create /Users/UserShell "$orgShell"
    restoreStatus
}

testUserStatusChged () {
    userStatus="$(readUserStatus "$sysUserTimeProperty")"
    userInitialStatus="$(readUserStatus "$sysUserIniitialTimeProperty")"
    [ "$userStatus" = "$userInitialStatus" ] && return true || return false
}

[[ -z "$(readUserStatus "$sysUserIniitialTimeProperty")" ]] && initialUserStatus
[[ -z "$(readUserPWD "$sysUserIniitialPWDProperty")" ]] && initialUserStatus

if [ testUserStatusChged = true ]; then
    # logoutUser
    disableUser
    sleep 20
    enableUser
fi
