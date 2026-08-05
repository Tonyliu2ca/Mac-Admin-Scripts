#!/bin/bash
# Description:
#   Download HP 5.1.1 driver from Apple, modify to allow on macOS Sequoia, install the driver, and put the new installer pacakge on your desktop.
#   Delete the HPDrivers5.1.1_Sequoia.pkg from your Desktop if desired.
#
# Update: 2025-02-25
#         2026-08-05: support macOS version to 99.9 and other minor updates

# Note:
#   1. Local drive MUST have 2 GB free spaces at least to run this script
#   2. Give Termial app full disk access privilege in Privacy & Security system settings
#
#   Download from Apple official website: HP 5.1.1 Printer Software Update
#   Ref: https://support.apple.com/en-ca/106385
#   Some model need: https://ftp.hp.com/pub/softlib/software12/HP_Quick_Start/osx/HP_Easy_Start.app.zip
#   The HP 5.1 driver in case needed：
#     curl -o "$pkgPath/HPDriver5.1.dmg" https://updates.cdn-apple.com/2020/macos/001-41745-20201210-DBC9B46B-88B2-4032-87D9-449AF1D20804/HewlettPackardPrinterDrivers.dmg

dest="$HOME/Desktop"
pkgPath="/tmp/HPDrive_Temp"
rm -fr "$pkgPath" >/dev/null 2>&1
mkdir -p "$pkgPath"

# Download
echo " - downloading HPDriver5.1.1.dmg."
curl -o "$pkgPath/HPDriver5.1.1.dmg" https://updates.cdn-apple.com/2021/macos/071-46903-20211101-0BD2764A-901C-41BA-9573-C17B8FDC4D90/HewlettPackardPrinterDrivers.dmg

# Load and extract
hdiutil attach -quiet "$pkgPath/HPDriver5.1.1.dmg"
echo " - HPDriver5.1.1.dmg is attached."
pkgutil --expand /Volumes/HP_PrinterSupportManual/HewlettPackardPrinterDrivers.pkg "$pkgPath/expaneded"
echo " - HPDriver5.1.1.dmg is expanded."
hdiutil eject -quiet /Volumes/HP_PrinterSupportManual

# Udpate 12.0 to 99.9
echo " - Updating the version check scripts."
sed -i '' 's/15.0/99.9/' "$pkgPath/expaneded/Distribution"

# Repack
pkgutil --flatten "$pkgPath/expaneded" "$dest/HPDrivers5.1.1_Sequoia.pkg"
echo " - a new package 'HPDrivers5.1.1_Sequoia.pkg' is saved in $dest folder."

# Clean up
rm -fr "$pkgPath"

# install the driver
echo " - installing the HP printer driver 5.1 on this computer."
sudo installer -pkg "$dest/HPDrivers5.1.1_Sequoia.pkg" -target /

# Clean up
echo " - deleting temporary data. all done."
rm -f "$dest/HPDrivers5.1.1_Sequoia.pkg"

