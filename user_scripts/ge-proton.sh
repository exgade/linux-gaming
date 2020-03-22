#!/bin/bash
workdir="`pwd`/`dirname $0`"
if [ "$1" = "last" ] ; then
	gerelease="5.2-GE-2"
	gechecksum="affc68e5956e84d679c9e801011448fe6a228cd08bc19dd5e9d7ae6e2d24d5cd"
elif [[ "$1" = "" || "$1" = "both" ]] ; then
	gerelease="5.4-GE-2"
	gechecksum="ef8b91bc6a01cde30d43aa85692dfd252f99546cf629b7a4f04d8e39460f7635"
else
	echo unknown operation
	exit
fi

if [ "`whoami`" = "root" ] ; then
	echo "this script should NOT be run as root or via sudo"
	echo "please use this with your user account"
	exit
fi

if [ "`whereis wget | grep \/bin | wc -l`" = "0" ] ; then
	echo "Error: please install wget first"
	exit
fi

if [ ! -d ~/.steam/root/compatibilitytools.d ] ; then
	mkdir -p ~/.steam/root/compatibilitytools.d
fi
cd ~/.steam/root/compatibilitytools.d/
if [[ ! -d ~/.steam/root/compatibilitytools.d/Proton-${gerelease} && ! -f ~/.steam/root/compatibilitytools.d/Proton-${gerelease}.tar.gz ]] ; then
	echo Downloading Glorious Eggroll Proton...
	if [ "`ls -la /usr/local/bin/wget | grep /usr/bin/firejail | wc -l`" = "1" ] ;then
		cmd_wget="/usr/bin/wget"
	else
		cmd_wget="wget"
	fi
	${cmd_wget} "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${gerelease}/Proton-${gerelease}.tar.gz" -P ~/.steam/root/compatibilitytools.d/ -O Proton-${gerelease}.tar.gz

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
	echo "Error: Download of Proton ${gerelease} already started or installation already done."
	if [ ! -d ~/.steam/root/compatibilitytools.d/Proton-${gerelease} ] ; then
		echo "Delete an broken Download with this and restart: "
		echo "rm ~/.steam/root/compatibilitytools.d/Proton-${gerelease}.tar.gz"
	fi
fi
if [[ "$1" = "both" ]] ; then
	${workdir}/ge-proton.sh last
fi
