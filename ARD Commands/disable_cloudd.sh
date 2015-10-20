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
# Version 1.0
# Tony Liu, 2015
#

defaults read /System/Library/LaunchAgents/com.apple.cloudd.plist

if [ -f "/System/Library/LaunchAgents/com.apple.cloudd.plist" ]; then
   defaults write /System/Library/LaunchAgents/com.apple.cloudd.plist Diabled -bool True
   chmod +r /System/Library/LaunchAgents/com.apple.cloudd.plist
   chown root:wheel /System/Library/LaunchAgents/com.apple.cloudd.plist
fi

defaults read /System/Library/LaunchAgents/com.apple.cloudd.plist

# ----------------------------------
# For recovering to system default:
# defaults delete /System/Library/LaunchAgents/com.apple.cloudd.plist Diabled
# chmod +r /System/Library/LaunchAgents/com.apple.cloudd.plist
# chown root:wheel /System/Library/LaunchAgents/com.apple.cloudd.plist
#
