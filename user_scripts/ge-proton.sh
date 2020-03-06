#!/bin/bash

gerelease="5.2-GE-2"
gechecksum="affc68e5956e84d679c9e801011448fe6a228cd08bc19dd5e9d7ae6e2d24d5cd"

if [ "`whoami`" = "root" ] ; then
	echo "this script should NOT be run as root or via sudo"
	echo "please use this with your user account"
	exit
fi

if [ ! -d ~/.steam/root/compatibilitytools.d ] ; then
	mkdir -p ~/.steam/root/compatibilitytools.d
fi
cd ~/.steam/root/compatibilitytools.d

if [ ! -f ~/.steam/root/compatibilitytools.d/Proton-${gerelease}.tar.gz ] ; then
	echo Downloading Glorious Eggroll Proton...
	wget "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${gerelease}/Proton-${gerelease}.tar.gz"

	echo checksum check...

	if [ "`sha256sum ~/.steam/root/compatibilitytools.d/Proton-${gerelease}.tar.gz | grep ${gechecksum} | wc -l`" = "1" ] ; then
		echo "checksum ok, extracting tar.gz..."
		tar xzf "Proton-${gerelease}.tar.gz"
		echo "removing tar.gz file"
		rm "Proton-${gerelease}.tar.gz"
		echo "installation complete, restart steam now"
	else
		echo "checksum not ok"
	fi
else
	echo "Error: Download already started or done. You may want to force a new download by: "
	echo "rm ~/.steam/root/compatibilitytools.d/Proton-${gerelease}.tar.gz"
fi
