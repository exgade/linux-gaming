#!/bin/bash
workdir="$(dirname "${0}")"
distrodetect=""
distroinstaller=""
option_noconfirm="false"
installer_arguments=""
for arg in "$@" ; do
	if [[ "$arg" = "--force" || "$arg" = "-f" ]] ; then
		option_noconfirm="true"
	elif [[ "$arg" = "--help" || "$arg" = "-h" ]] ; then
		echo "usage: ./autoinstall.sh [OPTIONS]"
		echo "--force - no questions while installing / uninstalling packages - this might break your system"
		exit
	fi
done
if [ "$option_noconfirm" = "true" ] ; then
	installer_arguments="--force"
fi
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
	elif [ "${ID}" = "ubuntu" ] ; then
		distrodetect="Ubuntu"
		distroinstaller="ubuntu"
	elif [ "${ID_LIKE}" = "ubuntu" ] ; then
		if [ "${ID}" = "elementary" ] ; then
			distrodetect="Elementary"
		elif [ "${ID}" = "linuxmint" ] ; then
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
	cd "${workdir}" && ./${distroinstaller}-gaming.sh $installer_arguments
fi

