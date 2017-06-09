#!/bin/bash

# ------------------------------------------------------------------------------------
# createPackage.sh
#
# Purpose:
# ------------------------------------------------------------------------------------

package="noSleep4Encryption"
identifier="com.github.$package"
version="1.0"

homePath=$(dirname "$0")
pushd "$homePath"
#pkgbuild --scripts ./scripts --nopayload --identifier "com.github.wait" wait.pkg
rm -f ./scripts/.DS_Store
pkgbuild --nopayload --scripts ./scripts --identifier "$identifier" --version "$version" "${package}.pkg"
popd
