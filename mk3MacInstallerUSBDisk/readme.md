
The purpose of these script set are to initialize, create and update macOS installers
on one USB drive, and support new macOS in the future if it does the same way as Sonoma
to create installer disk.

Features:
	1. Auto detect external USB drive attached
	2. Add macOS Installer version to the end of Installer volume
	3. Repartition is needed
	4. Initialized one time, then create and update without erasing data
  5. Update individual Installer whenever a new version is available


What in the tool set:
    "initialize.sh" is for initializing your USB drive(s) one time
    "Sonoma.sh" is to create/update Sonoma installer on USB drive
    "Ventura.sh" is to create/update Ventura installer on USB drive
    "Monterey.sh" is to create/update Monterey installer on USB drive

#########################################
# HOW-TO  - Basic
#########################################

----------------------------------------
| Get Ready:
----------------------------------------
    1. Copy this "mk3Installer_Disk" folder to your Mac desktop
    2. Make all executable, e.g.
          chmod -R +x ~/Desktop/mk3Installer_Disk


--------------------------------------------
| Initialize
--------------------------------------------
Warning: Backup if needed, it will erase and repartition the attached USB disk
    1. Disconnect all USB storage device
    2. Attach one tech USB disk, Allow accessory to connect if prompts
    3. Run "initialize.sh" as root (i.e. sudo) if the disk hasn't been initialized
    4. Key in "y" to continue

------------------------
| Create/Update (basic)
------------------------
    1. Disconnect all USB storage device and then attach one tech USB disk, Allow accessory to connect if prompts
    2. Put a macOS installer app in the "mk3Installer_Disk" folder
    3. Run corresponding script to create installer disk
       For example:
        1> copy "macOS Sonoma Install.app" into "mk3Installer_Disk" folder
        2> run "sudo Sonoma.sh" as root to create Sonoma Installer on the attached disk
    4. When step 3 completes, repeat step 2 for other macOS installers if needed,
       like Ventura, Monterey and etc.
    5. After all done, disconnect your USB disk.


------------------------
| Reminders:
------------------------
Run these scripts one after another.


------------------------
| Change Logs:
------------------------
2024-02-12: improve script prompts 
2024-01-24: First Release


------------------------
| Thanks to:
------------------------
Hugo Zhao - time on testing, reports and contributions with great ideas.


------------------------
| Contact
------------------------
Questions, comments, and suggestions are very welcome
Tony Liu (toliu@cbe.ab.ca)
