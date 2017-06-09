Why need it:
============
   In my production environment, using Dell Data Protection software to encrypt macOS whole drive instead of FileVault 2. One of the thing we find out is that the whole system perfermence is slow while it's encrypting, it comes back to normal once the encryption is done.
   Once a Mac is reimaged, the encryption software installation is kicked in as a globle enterprise policy enforced by Jamf. for current 
   DDP version 8.9.x and 8.11.x, we have to log in twice to get the encryption process started, the first stage it modify partition and update to central certification escrow server, second login it starts encrypting. once encryption  starts, no other user action is needed.
   Then encryption takes more than 12 hours on a 500GB HDD approximately. So it's better to let a Mac powered on and continue running until its encryption is done.
   
   The most of Mac laptops are stored in laptop carts and the moden cart slots may not have enough space to leave the Mac laptop lid open, once the lid  closed, the laptop goes to sleep and the encryption is suspended until the next time the system is woke up.

   So need a way to keey a Mac up and running even when lid is closed and it can stop, clean up itself once the encryption done, and leave the logs for audit.

What to mke it happen:
=====================
  Utilizing the power management assertion is one of the way to prevent a Mac goes to sleep. This is the core technology what I use here. For Xcode or swift developer, believe their's a way to do the same thing as caffeinate does. As an admin with script knowledge, caffeinate command is preferred.
  
  Launchd is used to make a period launch daemons to check system status chang, log all stats and reports, even self clean-up. crontab should do the same job.
  
  Cron is also used to run caffeinate command to deal with system restarts, upon the test, launchd doesn't support disown and/or nohup. so far cron works perfect.

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
