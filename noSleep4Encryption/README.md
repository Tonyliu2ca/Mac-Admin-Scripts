Why need it:
============
   In my production environment, using Dell Data Protection software to encrypt macOS whole drive instead of FileVault 2. One of the thing we find out is that the whole system perfermence is slow while it's encrypting, it comes back to normal once the encryption is done.
   
   Once a Mac is reimaged, the encryption software installation is kicked in as a globle enterprise policy enforced by Jamf. With current DDP client version 8.9.x and 8.11.x, have to log in twice to get the encryption process started, the first stage modifies partition and sync to central certification escrow server. After a restart, another login starts encrypting. Once encryption starts, no other user action is needed.
   
   Then encryption may take more than 12 hours on a 500GB HDD approximately. So it's better to power on the Mac and let it continue running until the encryption is done over night.
   
   The most of Mac laptops are stored in laptop carts and the moden cart slots may not have enough space to leave the Mac laptop lid open. Once lid is closed, the laptop goes to sleep and the encryption is suspended until the next time the system is woke up.

   So it's needed to keey a Mac up and running even when lid is closed and the program can stop, clean up itself once the encryption done, and leave the logs for audit.

What to mke it happen:
=====================
   macOS power management assertion is one of the way to prevent a Mac goes to sleep. This is the core technology used. For Xcode or swift developer, believe their's a way to do the same thing as caffeinate does. As an admin with script knowledge, caffeinate command is preferred.
  
  Launchd is used to make a period launch daemons to check system status chang, log all stats and reports, and even self clean-up. crontab should do the same job.
  
  Cron is also used to run caffeinate command to deal with system restarts. Ipon the test on macOS 10.12.4, launchd doesn't support disown and/or nohup. So far cron job works perfect.

Monitor:
========
  check the log file (default saved in /var/log/noSleep4EncryptionDone.log)
  "pmset -g" command to check the current power management status

Cleanup:
========
  remove files: com.github.tonyliu2ca.noSleep4EncryptionDone.plist, noSleep4EncryptionDone neverSleep and crontab file,
  if needed, remove the log file as well to fully remove all footprints.

How to use:
===========


Potential issue:
===========
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
