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
		echo "usage: ./ui-install.sh [OPTIONS]"
		echo "--force - no questions while installing / uninstalling packages - this might break your system"
		exit
	fi
done

# abort if not root and no sudo was used
if [ "$(whoami)" != "root" ] ; then
	echo "### Error: you have to run this script as root or via sudo"
	echo "Installation canceled"
	exit
fi

function askQuestion {
	if [ "$default" = "" ] ; then
		default="y"
	fi
	if [ "$default" = "y" ] ; then
		echo -n "$question [Y/n] "
	else
		echo -n "$question [y/N] "
	fi
	read -n 1 answer
	if [[ "${answer}" = "Y" || "${answer}" = "y" || ( "${default}" = "y" && "${answer}" = "" ) ]];then
		answer="true"
	else
		answer="false"
	fi
}
#if [ "${option_noconfirm}" = "false" ] ; then
#	default="n"
#	question="Install all forced? This might damage your system"
#	askQuestion
#	if [ "${answer}" = "true" ] ; then
#		option_noconfirm="true"
#	fi
#fi

if [ "$option_noconfirm" = "true" ] ; then
	installer_arguments="--force"
fi

default="y"
question="Install Lutris?"
askQuestion
if [ "${answer}" != "true" ] ; then
	installer_arguments="${installer_arguments} nolutris"
fi
echo

question="Install Steam?"
askQuestion
if [ "${answer}" != "true" ] ; then
	installer_arguments="${installer_arguments} nosteam"
fi
echo

question="Install Winetricks?"
askQuestion
if [ "${answer}" != "true" ] ; then
	installer_arguments="${installer_arguments} nowinetricks"
fi
echo

question="Install Teamspeak 3?"
askQuestion
if [ "${answer}" != "true" ] ; then
	installer_arguments="${installer_arguments} nots3"
fi
echo

question="Install Mumble?"
askQuestion
if [ "${answer}" != "true" ] ; then
	installer_arguments="${installer_arguments} nomumble"
fi
echo

question="Install Discord?"
askQuestion
if [ "${answer}" != "true" ] ; then
	installer_arguments="${installer_arguments} nodiscord"
fi

echo $installer_arguments

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

