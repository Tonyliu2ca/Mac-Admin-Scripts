2026-04-01 Updates:
  * new version 3.6.6

  * Starting from Tahoe 26.4, the disk volume size has to be about 21GB or larger, so all your Installer disks has to be re-intialized

  * new intialize scripts
     initialize_2Installers.sh: create two 21GB installer volumes on the target disks, the rest spaces is your uData volume
     initialize_3Installers.sh: create three 21GB installer volumes on the target disks, the rest spaces is your uData volume

  * Tahoe 26.sh: will be on the first volume (index 0)
  * Sequoia 15.sh: will be on the second volume (index 1)
  * Sonoma 14.sh: will be on the third volume (index 2)
  * All the old version macOS will be on the third volume, i.e. Ventura 13.sh and Monterey 12.sh.

  * You can customize the scripts to fit your needs
  * https://github.com/Tonyliu2ca/Mac-Admin-Scripts/tree/master/mk3MacInstallerMultiDisks