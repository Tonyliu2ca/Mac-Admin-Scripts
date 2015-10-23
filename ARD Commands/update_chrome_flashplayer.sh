#!/bin/sh

#
# ---------------------------------------------------------------------
# update to the most current Google Chrome browser and/or Flash Player
#
# DESCTIPTION:
#   If you org doesn't have a automatic updating policy setup, or you
#   would like to take the control of it, or whatever reason, try this.
#   It download the most current installation package from their offcial
#   home website, unpack it and install or copy it over.
#   For Google Chrome, it copies to /Application folder, so it's better
#   to quit any running Chrome instance.
#   For Flahs Player, user may have to close and relaunch Safari to
#   got it catch up the update.
#
#   How to use?
#      please read the online readme, just fire it with -h option.
#   Examples:
#      $ update_chrom_Flashplay.sh -h
#      Get the online help/readme
#      $ update_chrom_Flashplay.sh -a
#      Update both of them
#      $ update_chrom_Flashplay.sh -i chrome
#      Update Google Chrome only
#      $ update_chrom_Flashplay.sh -i flash
#      Update Flahs Player only
#
# HISTORY:
#   2015-10-10: Initial
#   2015-10-23: comments update
#
# Note/Causion:
#    Run this script with root privilege.
#    The download link coud be changed anytime
#
# Version 1.1
# Tony Liu, 2015
#

# ---------------------------
# Help
# ---------------------------
usage="$(basename "$0") [-h|--help] [-a|--all] [-i [options]]

where:
    -h|--help    show this help text
    -a|--all     install all
    -i|--install [options]
       chrome   install Google Chrome web browser
       flash    install Flash Player"
    
# ---------------------------
# Install Google Chrome.app
# ---------------------------
install_chrome()
{
   fileURL="https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
   temp_dmg="/tmp/googlechrome.dmg"
   /usr/bin/curl --output "$temp_dmg" "$fileURL";
	ls -la $temp_dmg

	TMPMOUNT=`/usr/bin/mktemp -d /tmp/googlechrome.XXXX`;
	hdiutil attach "$temp_dmg" -mountpoint "$TMPMOUNT" -nobrowse -noverify -noautoopen;
	ls -la $TMPMOUNT

	#/usr/sbin/installer -pkg "$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*\.pkg -o -iname \*\.mpkg \))" -target "/";
	cp -Rf $TMPMOUNT/Google\ Chrome.app /Applications/
	xattr -c -r /Applications/Google\ Chrome.app

	/usr/bin/hdiutil detach "$TMPMOUNT";
	/bin/rm -rf "$TMPMOUNT";
	/bin/rm -rf "$temp_dmg";
}

# jamf policy -trigger CBE_Adobe_Flash_Player
# ---------------------------
# Install Adobe_Flash_Player
# ---------------------------
install_flashplayer()
{
	osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
	flash_major_version=`/usr/bin/curl --silent http://fpdownload2.macromedia.com/get/flashplayer/update/current/xml/version_en_mac_pl.xml | cut -d , -f 1 | awk -F\" '/update version/{print $NF}'`
	fileURL="http://fpdownload.macromedia.com/get/flashplayer/current/licensing/mac/install_flash_player_"$flash_major_version"_osx_pkg.dmg";
	flash_dmg="/tmp/flash.dmg";
	if [[ ${osvers} -lt 6 ]]; then 
	  echo "Adobe Flash Player is not available for Mac OS X 10.5.8 or below.";
	fi
	if [[ ${osvers} -ge 6 ]]; then
	 /usr/bin/curl --output "$flash_dmg" "$fileURL";
	 TMPMOUNT=`/usr/bin/mktemp -d /tmp/flashplayer.XXXX`;
	 hdiutil attach "$flash_dmg" -mountpoint "$TMPMOUNT" -nobrowse -noverify -noautoopen;
	 /usr/sbin/installer -pkg "$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*\.pkg -o -iname \*\.mpkg \))" -target "/";
	 /usr/bin/hdiutil detach "$TMPMOUNT";
	 /bin/rm -rf "$TMPMOUNT";
	 /bin/rm -rf "$flash_dmg";
	fi
}

for i in "$@"
do
case $i in
    -h|--help)
    EXTENSION="${i#*=}"
    echo "$usage"
    ;;
    -a|--all)
    install_flashplayer
    install_chrome
    exit 0
    ;;
    -i|--install)
    options="${i#*=}"
    shift # past argument=value
    ;;
    *)
       if [ "$options" = "-i" ]; then
          options="${i#*=}"
       fi
       # unknown option
    ;;
esac
done

echo "Options=$options"
case $options in
	chrome)
      install_chrome
   ;;	
	flash)
      install_flashplayer
   ;;
esac

echo "Done!"
exit 0
