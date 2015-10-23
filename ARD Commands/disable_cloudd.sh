#/bin/sh

# -----------------------------------------------------------------
# Disabled com.apple.cloudd to launch for all users
#
# UPDATE: As of 2015-10-23, found the reason why cloudd crashes
#    every 10 seconds. We have a directory redirection setup
#    on server for guest computers in Workgroup Manager, it's old
#    technology, reality is I have to deal with it. Ok, lets
#    start. It links user Caches folder ~/Library/Caches to a 
#    subfolder in /tmp. cloudd doesn't like soft links! this folder
#    redirection breaks it!.
#    If you have the similiar issue, check it first.
#
# HISTORY:
#   2015-10-20: added version detection
#   2015-10-23: changed from editing plist file to using launchctl
#      check root privelege first.
#   *********************************************
#   PLEASE SEE THE UPDATE ABOVE BEFORE CONTINUING
#   *********************************************
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
#    Run this script with root privilege.
#    This' tested on 10.10.3 only.
#
# Version 1.3
# Tony Liu, 2015
#

# must run as root
if [ “$(id -u)” != “0” ]; then printf "$sname must be run as root.\n"; exit 1; fi

osver=$(sw_vers -productVersion)
if [ "$osver" != "10.10.3" ]; then
   printf "Current OS is NOT 10.10.3, will quit without any changes."
   exit 1
fi

# defaults read /System/Library/LaunchAgents/com.apple.cloudd.plist

if [ -f "/System/Library/LaunchAgents/com.apple.cloudd.plist" ]; then
   launchtl disable system/com.apple.cloudd
#   defaults write /System/Library/LaunchAgents/com.apple.cloudd.plist Diabled -bool True
#   chmod +r /System/Library/LaunchAgents/com.apple.cloudd.plist
#   chown root:wheel /System/Library/LaunchAgents/com.apple.cloudd.plist
   # launchctl unload -wF /System/Library/LaunchAgents/com.apple.cloudd.plist
fi

# defaults read /System/Library/LaunchAgents/com.apple.cloudd.plist

# printf "Current OS is 10.10.3, disabled iCloudd, please restart your machine."

# ----------------------------------
# For recovering to system default:
# defaults delete /System/Library/LaunchAgents/com.apple.cloudd.plist Diabled
# chmod +r /System/Library/LaunchAgents/com.apple.cloudd.plist
# chown root:wheel /System/Library/LaunchAgents/com.apple.cloudd.plist
#

exit 0
