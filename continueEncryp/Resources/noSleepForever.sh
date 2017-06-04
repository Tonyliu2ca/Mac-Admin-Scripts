#!/bin/bash

# ------------------------------------------------------------------------------------
# noSleepForever.sh
#
# Purpose:
#    Prevent system from sleep or shutdown if the defined condition not satisfied.
#
#
# History:
#   2017-06-01, version = 1.0
#
# Tony Liu, TonyLiu2ca@yahoo.com
# ------------------------------------------------------------------------------------
#/usr/bin/caffeinate -u -t1; /usr/bin/pmset repeat cancel; /usr/bin/pmset schedule cancelall

# Need a real user login for -u
# nohup /usr/bin/caffeinate -isu -w 1 </dev/null >/dev/null 2>&1 & disown

# Test with ssh login: 
#   run it and disconnect from ssh, close lid,still wakeup with network connected.
#   it has to be running on AC power (-s).
#   -d (keep display on) is optional
#   -m (keep disk on) is optional
#   -s (prevent system from sleeping) is MUST
nohup caffeinate -dms </dev/null >/dev/null 2>&1 & disown
