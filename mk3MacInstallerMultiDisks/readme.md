# 
--------------------------------------------------------------------------------------
ATTENTION: Initializing process will erase your external drive, backup before continue
--------------------------------------------------------------------------------------

# [How to initialize your CTS USB flash drives]

- before initialize, unplug all USB devices and then connect your flash drive(s) only
- run the info.sh to show current system recognized external drive(s)' information (optional step)
- run initialize.sh
     * The "Total" section shows all the current attached external drives
       The "Target" section shows which external drives will be erased, partitioned and formated
       the rest is what will be done on the target drive(s) and other info
     * press "y" to continue | "n" to quit
     * all processes are prompted
     * after initialization done, it unmounts all "Target" USB storages, and you can disconnect them (or run macOS installer scripts) right away. 
     * Once it's done, it says "all done" (adjust your volume ahead)
- Once your flash drives are initialized, four JHFS+ volumes are created on the "Target" drive(s), this "mk3MacInstallerMultiDisks" folder will be copied to the uData volume, uData can be used as your own storage, it won't be used for macOS Installer. 
-You are ready to run the macOS installer scripts


# [Make macOS Installer on to CTS USB flash drive(s)]

-----------------------------
Info:
* run each macOS version script to make attached flash drive(s) as macOS Installer
* all these scripts run similar steps
* macOS Installer app can be from:
    1. Current Mac local drive
    2. network share, like image$, but very slow
    3. A CTS USB flash drive, which has the macOS installer you want

-----------------------------
Steps:
   1. drag & drop a macOS scripts, i.e. Sequoia.sh and etc., to one terminal window
   2. drag & drop the macOS installer to the same terminal window
   3. press return to run
   4. if it asks for password, key in the current administrator account's password

# LICENSE
    Copyright (c) Tony Liu 2024-
    The MIT License (MIT)
