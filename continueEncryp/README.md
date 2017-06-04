Why need it:
============
   In my production environment, using Dell Data protection software to encrypt macOS whole drive instead of FileVault 2. One of the drawback
   of this software is that it affects users experience significantly and slow down the whole system perfermence when it's encrypting. once
   the encryption is done, it still a bit slower than FileVault as well. But as a whole Windows and Mac platforms solution for middle to large
   bussiness, it's not bad at all, so far we had adopted it to our system for about couple years.
   
   Once a Mac is reimaged, the encryption software installation is kicked in as a globle enterprise policy enforced by Jamf. for current 
   version 8.9.x and 8.11.x, we have to log in twice to get the encryption process started, once it starts, no other user action is needed.
   Then encryption takes more than 12 hours on a 500GB HDD approximately. So it's better to let a Mac powered on and continue running until
   its encryption is done.
   
   The most of Mac laptops are stored in laptop carts and some of them may not have enough space to leave lid open, once the lid  closed, 
   the laptop goes to sleep and the encryption is suspended until the next time the system is woke up.
   
   So we do need a way to keey a Mac up and running evenwhen lid is closed and it can stop and clean up itself once the encryption is done.
   
What to mke it happen:
=====================
  Utilize the power management assertion is a way to prevent a Mac goes to sleep. This is the core technology what we use.
  if you are a xcode or swift developer, I believe their's a way to do the same thing as caffeinate does. As an admin with scrit knowledge
  I prefer to use caffeinate command.
  
  We also use launchd to make a period launch daemons to check system status chang, log all stats and reports, even self clean-up.
  
  cron is also used to run caffeinate command to deal with system restarts, as upon my test, launchd doesn't support disown and/or nohup. so
  far it works perfect.

Monitor:
========
  check the log file (default saved in /var/log/noSleep4EncryptionDone.log)
  "pmset -g" command to check the current power management status

Cleanup:
========
  remove files: com.github.tonyliu2ca.noSleep4EncryptionDone.plist, noSleep4EncryptionDone neverSleep and crontab file,
  if needed remve the log file as well to fully remove all footprints.

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
