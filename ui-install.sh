#!/bin/bash
workdir="$(dirname "${0}")"
distrodetect=""
distroinstaller=""
option_noconfirm="false"
installer_arguments=""
for arg in "$@" ; do
	if [[ "$arg" = "--force" || "$arg" = "-f" ]] ; then
		installer_arguments="${installer_arguments} --force"
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
	if [[ "$default" = "" || "$default" =~ ^[Yy]$ ]] ; then
		default="y"
		echo -n "$question [Y/n] "
	else
		echo -n "$question [y/N] "
	fi
	read -n 1 answer
	if [[ "${answer}" =~ ^[Yy]$ || ( "${default}" = "y" && "${answer}" = "" ) ]];then
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

cd "${workdir}" && ./autoinstall.sh $installer_arguments
