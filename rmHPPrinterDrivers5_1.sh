#!/bin/bash

#
# Remove "HewlettPackardPrinterDrivers5.1"
#

declare -a deList=(
 "/Library/Image\\ Capture/Devices/HP*.app"
 '/Library/Extensions/hp_io_enabler_compound.kext'
 '/Library/Printers/PPDs/Contents/Resources/HP*.gz'
 '/Library/Printers/hp'
 '/usr/libexec/cups/backend/hpfax'
 '/usr/libexec/cups/backend/hpFaxbackend'
)
 
i=0
while [ "x${deList[$i]}" != "x" ]; do
   echo " -- ${deList[$i]}"
   i=$(( $i + 1 ))
done

read -p "Do you want to continue removing installed HP Priner Drivers 5.1? (Yes/No) " YorN

if [ "$YorN" = "Yes" ]; then
   echo "File removing: "
   i=0
   echo "  Removing: /Library/Image\ Capture/Devices/HP*.app"
   sudo rm -rf /Library/Image\ Capture/Devices/HP*.app
   echo "  Removing: /Library/Extensions/hp_io_enabler_compound.kext"
   sudo rm -rf /Library/Extensions/hp_io_enabler_compound.kext
   echo "  Removing: /Library/Printers/PPDs/Contents/Resources/HP*.gz"
   sudo rm -rf /Library/Printers/PPDs/Contents/Resources/HP*.gz
   echo "  Removing: /Library/Printers/hp"
   sudo rm -rf /Library/Printers/hp
   echo "  Removing: /usr/libexec/cups/backend/hpfax"
   sudo rm -rf /usr/libexec/cups/backend/hpfax
   echo "  Removing: /usr/libexec/cups/backend/hpFaxbackend"
   sudo rm -rf /usr/libexec/cups/backend/hpFaxbackend
   echo "File removing is done."
   sudo pkgutil --forget com.apple.pkg.HewlettPackardPrinterDrivers > /dev/null 2>&1
   echo "Package database is cleaned."
fi
