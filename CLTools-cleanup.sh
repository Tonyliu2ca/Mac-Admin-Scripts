#!/bin/bash

Vol="/Library/Apple/System"
if [ "$(csrutil status | awk -F': ' '{print $2}')" = "disabled." ]; then
	/usr/sbin/pkgutil --pkgs="com.apple.pkg.CLTools_.*" --volume "$Vol" | while read -r pkg; do
		/usr/sbin/pkgutil --forget "$pkg" --volume "$Vol"
	done
	rm -rf /Library/Developer/CommandLineTools
	# xcode-select -p
else
	echo "After disbale SIP, run this command again, and then enable SIP."
fi
