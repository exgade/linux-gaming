#!/bin/bash
workdir="`dirname $0`"
distrodetect=""
distroinstaller=""
if [ -f /etc/os-release ] ; then
	if [ "`grep 'ID=manjaro' /etc/os-release | wc -l`" = "1" ] ; then
		distrodetect="Manjaro"
		distroinstaller="manjaro"
	elif [ "`grep 'ID=arch' /etc/os-release | wc -l`" = "1" ] ; then
		distrodetect="Arch Linux"
		distroinstaller="arch"
	elif [ "`grep 'ID=debian' /etc/os-release | wc -l`" = "1" ] ; then
		distrodetect="Debian"
		distroinstaller="debian"
	fi
elif [ -f /usr/lib/os-release ] ; then
	if [ "`grep 'ID=artix' /etc/os-release | wc -l`" = "1" ] ; then
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

