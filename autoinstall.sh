#!/bin/bash
workdir="`dirname $0`"
distrodetect=""
distroinstaller=""
if [ -f /etc/os-release ] ; then
	if [ "`cat /etc/os-release | grep 'ID=manjaro' | wc -l`" = "1" ] ; then
		distrodetect="Manjaro"
		distroinstaller="manjaro"
	elif [ "`cat /etc/os-release | grep 'ID=arch' | wc -l`" = "1" ] ; then
		distrodetect="Arch Linux"
		distroinstaller="arch"
	fi
else
	distrochk="`distro | grep Name: | sed "s/Name: //" -`"
	if [ "${distrochk}" = "Artix Linux" ] ; then
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

