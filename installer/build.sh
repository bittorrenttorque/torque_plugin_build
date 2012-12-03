#!/bin/sh
#XCODE_ROOT=`xcode-select -print-path`
#PKG_MAKER="$XCODE_ROOT/usr/bin/packagemaker"
PKG_MAKER=/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker

if [ ! -x $PKG_MAKER ]; then
	echo "packagemaker not found"
	exit 0
fi

if [ ! -d ../BTLauncher/SoShare.plugin ]; then
	echo "Release build of SoShare.plugin not found. Build it first."
	exit 0
fi

rm -f SoShare.pkg
$PKG_MAKER -d SoShare.pmdoc  -o SoShare.pkg
$PKG_MAKER --sign SoShare.pkg -c 'Developer ID Installer: Gyre, Inc'


if [ ! -d ../BTLauncher/Torque.plugin ]; then
    echo "Release build of Torque.plugin not found. Build it first."
    exit 0
fi

rm -f Torque.pkg
$PKG_MAKER -d Torque.pmdoc -o Torque.pkg
$PKG_MAKER --sign Torque.pkg -c 'Developer ID Installer: BitTorrent, Inc'

