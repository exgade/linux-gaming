#!/bin/bash
workdir="$(dirname "${0}")"
distrodetect=""
distroinstaller=""
option_noconfirm="false"
installer_arguments=""
for arg in "$@" ; do
	if [[ "$arg" = "--force" || "$arg" = "-f" ]] ; then
		installer_arguments="${installer_arguments} --force"
	elif [[ "$arg" = "nolutris" ]] ; then
		installer_arguments="${installer_arguments} nolutris"
	elif [[ "$arg" = "nosteam" ]] ; then
		installer_arguments="${installer_arguments} nosteam"
	elif [[ "$arg" = "nowinetricks" ]] ; then
		installer_arguments="${installer_arguments} nowinetricks"
	elif [[ "$arg" = "nots3" ]] ; then
		installer_arguments="${installer_arguments} nots3"
	elif [[ "$arg" = "nomumble" ]] ; then
		installer_arguments="${installer_arguments} nomumble"
	elif [[ "$arg" = "nodiscord" ]] ; then
		installer_arguments="${installer_arguments} nodiscord"
	elif [[ "$arg" = "--help" || "$arg" = "-h" ]] ; then
		echo "usage: ./autoinstall.sh [OPTIONS]"
		echo "--force - no questions while installing / uninstalling packages - this might break your system"
		echo "nolutris - don't install Lutris"
		echo "nosteam - don't install Steam"
		echo "nowinetricks - don't install Winetricks"
		echo "nots3 - don't install Teamspeak3"
		echo "nomumble - don't install Mumble"
		echo "nodiscord - don't install Discord"

		exit
	fi
done

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

