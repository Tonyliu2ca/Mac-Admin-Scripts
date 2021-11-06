#!/bin/bash

dest="$HOME/Desktop"
path="/tmp/HPDrive_Temp"
rm -fr "$path" >/dev/null 2>&1
mkdir -p "$path"

# Download from Apple office website
# Ref: https://support.apple.com/kb/DL1888
curl -o "$path/HPDriver5.1.dmg" https://updates.cdn-apple.com/2020/macos/001-41745-20201210-DBC9B46B-88B2-4032-87D9-449AF1D20804/HewlettPackardPrinterDrivers.dmg

# Load and extract
hdiutil attach "$path/HPDriver5.1.dmg"
pkgutil --expand /Volumes/HP_PrinterSupportManual/HewlettPackardPrinterDrivers.pkg "$path/expaneded"
hdiutil eject /Volumes/HP_PrinterSupportManual

# Udpate 12.0 to 13.0
sed -i '' 's/12.0/13.0/' "$path/expaneded/Distribution"

# Repack
pkgutil --flatten "$path/expaneded" "$dest/HPDrivers5.1_Monterey.pkg"
echo "Have the package 'HPDrivers5.1_Monterey.pkg' file on $dest folder."

# Clean up
rm -fr "$path"

# install the driver
sudo installer -pkg "$dest/HPDrivers5.1_Monterey.pkg" -target /
