Why need it:
============
   In my production environment, Dell Data Protection software is the critical technology used to encrypt macOS whole drive instead of FileVault 2, it has a version works on the PC side as well. One of the thing we find out is that the whole system perfermence is slow while it's encrypting, it comes back to normal once the encryption is done. This seem only Mac thing so far.
   
   Once a Mac is reimaged or jamf first enrollment is done, the encryption software installation is kicked in as a globle enterprise policy enforced by Jamf system. With current DDP client version 8.9.x and 8.11.x, we have to log in twice to get the encryption process started, the first stage modifies partition and sync to central certification escrow server. After a restart, another login needs to fire up the encryption. Once the encryption starts, no other furhter user action is needed.
   
   The encryption may take more than 12 hours on a 500GB HDD approximately. So it's better to power on the Mac and let it continue running until the encryption is done over night.
   
   The most of Mac laptops are stored in laptop carts, the moden cart slots may not have enough space to leave the Mac laptop lid open while laptop inside a slot. Once lid is closed, the laptop goes to sleep and the encryption is suspended until the next time the system is woke up.

   So we need to keep a Mac up and running even when lid is closed and the program can stop, clean up itself once the encryption done, and leave the logs for audit.

What to make it happen:
=====================
   macOS power management assertion is one way to prevent a Mac from going to sleep, ie. caffeinate command. This is the core technology. For Xcode or swift developer, believe they have more powerful way to do the same thing what caffeinate does. As an admin with script knowledge, caffeinate command is preferred.
  
  Launchd is used to make a period launch daemons to check system status chang, log all stats and reports, and even self clean-up. crontab could do the same job by the way.
  
  Cron is also used to run caffeinate command to deal with system restarts. Ipon the test on macOS 10.12.4, launchd doesn't support disown and/or nohup. So far cron job works perfect.

How it works
============
Startup
-------

Run periodically
----------------

Cleanup:
--------
  remove files: com.github.tonyliu2ca.noSleep4EncryptionDone.plist, noSleep4EncryptionDone neverSleep and crontab file,
  if needed, remove the log file as well to fully remove all footprints.


How to use:
===========
The main script can even be run or called invividually anytime you want. all the others are for building a installation package.

Modify the script
-----------------
You may find the viriables at the beginning of the script. The following are parameters are OK to be modified to suit in your environments.

- `iniString` and `fullCLEANUP` are string defined script arguments, that pass to the script to do specific works, Initialize or cleanup.

* `program` the name of the main script, it doesn't have to be the same as the one in your installation package. this is the main 

- `identity` is used for the launchd idendity, can be changed.

+ `logFile` can be anywhere you want to

+ `nonestopDelayDefault` default to run the script every 5 minutes (300 seconds). 

+ `restartTime` is set to the hour that can do a restart after encryption is done.

How to pack:
------------

Monitor:
========
  check the log file (default location is /var/log/noSleep4EncryptionDone.log)
  "pmset -g" command to check the current power management status


Potential issue:
================
   Issue: caffeinate prevent the system from sleeping assertion only works when the machine is running on AC power. it's common to reimage it some where and then unplug power cord and/or close lid for a while to take it to a cart, slid it in a slot and plug it back in. During this time of period, system may go to sleep, and this may break our approuch.
   Answer: Upon test, make sure let it go to sleep, you can tell from the breath led light, ping to it or just wait longer, once it's plugged in, it bring the system to a state wakeup and caffeinate assertion takes effect to prevent it go back to sleep again.


License:
========
    noSleep4EncryptionDone
    Copyright (C) 2017  Tony Liu

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
