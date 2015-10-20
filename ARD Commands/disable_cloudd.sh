#/bin/sh

# -----------------------------------------------------------
# Disabled com.apple.cloudd to launch for all users
#
# As it crashes all the time for whatever reason on all
# of my 10.10 machines and crashreporter creats tons of 
# creash reports every couple seconds. it slows down
# my machines all the time.
# In my environments, no user will be using iCloud services,
# it's safe for me.
# 
# This should be a temp workaround, when the root problem
# is found out, this should be recovered.
#
# Note:
#    Restart is required after this change.
#    Run this script with root privilege.
#    This' tested on 10.10.3 only.
#
# Version 1.1
# Tony Liu, 2015
#
# History:
#   2015-10-20: added version detection
#

osver=$(sw_vers -productVersion)

if [ "$osver" != "10.10.3" ]; then
   printf "Current OS is NOT 10.10.3, will quit without any changes."
   exit 1
fi

defaults read /System/Library/LaunchAgents/com.apple.cloudd.plist

if [ -f "/System/Library/LaunchAgents/com.apple.cloudd.plist" ]; then
   defaults write /System/Library/LaunchAgents/com.apple.cloudd.plist Diabled -bool True
   chmod +r /System/Library/LaunchAgents/com.apple.cloudd.plist
   chown root:wheel /System/Library/LaunchAgents/com.apple.cloudd.plist
   # launchctl unload -wF /System/Library/LaunchAgents/com.apple.cloudd.plist
fi

defaults read /System/Library/LaunchAgents/com.apple.cloudd.plist

printf "Current OS is 10.10.3, disabled iCloudd, please restart your machine."

# ----------------------------------
# For recovering to system default:
# defaults delete /System/Library/LaunchAgents/com.apple.cloudd.plist Diabled
# chmod +r /System/Library/LaunchAgents/com.apple.cloudd.plist
# chown root:wheel /System/Library/LaunchAgents/com.apple.cloudd.plist
#

exit 0
