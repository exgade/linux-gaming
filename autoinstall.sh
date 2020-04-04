#!/bin/bash
workdir="`dirname $0`"
distrodetect=""
distroinstaller=""
if [ -f /etc/os-release ] ; then
	source /etc/os-release
	if [ "${ID}" = "manjaro" ] ; then
		distrodetect="Manjaro"
		distroinstaller="manjaro"
	elif [ "${ID}" = "arch" ] ; then
		distrodetect="Arch Linux"
		distroinstaller="arch"
	elif [ "${ID}" = "debian" ] ; then
		distrodetect="Debian"
		distroinstaller="debian"
	fi
elif [ -f /usr/lib/os-release ] ; then
	source /usr/lib/os-release
	if [ "${ID}" = "artix" ] ; then
		distrodetect="Artix Linux"
		distroinstaller="arch"	
	fi
fi

if [ "${distrodetect}" = "" ] ; then
	echo "No Distribution detected"
else
	echo "Detected Distribution ${distrodetect}, using installer ${distroinstaller}-gaming.sh"
	cd "${workdir}" && ./${distroinstaller}-gaming.sh
fi

