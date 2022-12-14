#!/bin/bash

dest="$HOME/Desktop"
pkgPath="/tmp/HPDrive_Temp"
rm -fr "$pkgPath" >/dev/null 2>&1
mkdir -p "$pkgPath"

# Download from Apple office website
# Ref: https://support.apple.com/kb/DL1888
# Check with HP for update: https://support.hp.com/lv-en/product/hp-easy-start/7376041/model/7376046/document/c03785459
curl -o "$pkgPath/HPDriver5.1.dmg" https://updates.cdn-apple.com/2020/macos/001-41745-20201210-DBC9B46B-88B2-4032-87D9-449AF1D20804/HewlettPackardPrinterDrivers.dmg

# Load and extract
hdiutil attach "$pkgPath/HPDriver5.1.dmg"
pkgutil --expand /Volumes/HP_PrinterSupportManual/HewlettPackardPrinterDrivers.pkg "$pkgPath/expaneded"
hdiutil eject /Volumes/HP_PrinterSupportManual

# Udpate 12.0 to 13.0
sed -i '' 's/12.0/14.0/' "$pkgPath/expaneded/Distribution"

# Repack
pkgutil --flatten "$pkgPath/expaneded" "$dest/HPDrivers5.1_Monterey.pkg"
echo "Have the package 'HPDrivers5.1_Monterey.pkg' file on $dest folder."

# Clean up
rm -fr "$pkgPath"

# install the driver
sudo installer -pkg "$dest/HPDrivers5.1_Monterey.pkg" -target /
