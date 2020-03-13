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
	elif [ "`grep 'ID=ubuntu' /etc/os-release | wc -l`" = "1" ] ; then
		distrodetect="Ubuntu"
		distroinstaller="ubuntu"
	elif [ "`grep 'ID_LIKE=ubuntu' /etc/os-release | wc -l`" = "1" ] ; then
		if [ "`grep 'ID=elementary' /etc/os-release | wc -l`" = "1" ] ; then
			distrodetect="Elementary"
		elif [ "`grep 'ID=elementary' /etc/os-release | wc -l`" = "1" ] ; then
			distrodetect="Linux Mint"
		else
			distrodetect="Unknown Ubuntu"
			echo "WARNING: this ubuntu distribution is unknown, you might face a broken system if you continue."
			echo "To abort press CTRL+C, continue anyway with ENTER"
			read
		fi
		distroinstaller="ubuntu"
	fi
elif [ -f /usr/lib/os-release ] ; then
	if [ "`grep 'ID=artix' /usr/lib/os-release | wc -l`" = "1" ] ; then
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

