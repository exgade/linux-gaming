#!/bin/bash
workdir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
if [ "$1" = "last" ] ; then
	gerelease="5.4-GE-3"
	getag="${gerelease}"
	gechecksum="3bd03323d6e2032a98e4309d510f6f82a443327cc4c128e6fd624586f50ec3ea"
elif [[ "$1" = "" || "$1" = "both" || "$1" = "latest" ]] ; then
	gerelease="5.8-GE-2-MF"
	getag="${gerelease}"
	gechecksum="78caef79712302dd076284fcdbc992404f4ced305de46e9cadb9f5031e7787d6"
elif [[ "$1" = "dev" ]] ; then
	gerelease="5.9-GE-2-MF"
	getag="${gerelease}"
	gechecksum="aedeeeeb5435cf7c5e6e062935e1d565562ce7dc34d5dbea8b6db7235fc69391"
elif [[ "$1" = "-h" || "$1" = "--help" ]] ; then
	echo "usage: ./ge-proton.sh <command (optional)>"
	echo "examples:"
	echo "./ge-proton.sh		load and install newest ge proton"
	echo "./ge-proton.sh latest	~"
	echo "./ge-proton.sh last	load and install the second latest stable minor version"
	echo "./ge-proton.sh both	load and install both versions"
	exit
else
	echo unknown operation
	exit
fi

if [ "$(whoami)" = "root" ] ; then
	echo "this script should NOT be run as root or via sudo"
	echo "please use this with your user account"
	exit
fi

if [ "$(whereis wget | grep "/bin" -c)" = "0" ] ; then
	echo "Error: please install wget first"
	exit
fi

if [ ! -d ~/.steam/root/compatibilitytools.d ] ; then
	mkdir -p ~/.steam/root/compatibilitytools.d
fi
cd ~/.steam/root/compatibilitytools.d/ || exit
if [[ ! -d ~/.steam/root/compatibilitytools.d/Proton-${gerelease} && ! -f ~/.steam/root/compatibilitytools.d/Proton-${gerelease}.tar.gz ]] ; then
	echo Downloading Glorious Eggroll Proton...
	if [[ ! -f /usr/local/bin/wget || "$(readlink -f /usr/local/bin/wget)" = "/usr/bin/firejail" ]] ;then
		cmd_wget="/usr/bin/wget"
	else
		cmd_wget="wget"
	fi
	${cmd_wget} "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${getag}/Proton-${gerelease}.tar.gz" -P ~/.steam/root/compatibilitytools.d/ -O Proton-${gerelease}.tar.gz

	echo checksum check...

	if [ "$(sha256sum ~/.steam/root/compatibilitytools.d/Proton-${gerelease}.tar.gz | grep ${gechecksum} -c)" = "1" ] ; then
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
	"${workdir}"/ge-proton.sh last
fi
