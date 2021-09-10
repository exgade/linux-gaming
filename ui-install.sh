#!/bin/bash
workdir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
installer_arguments=""
force_install="false"
for arg in "$@" ; do
	if [[ "$arg" = "--force" || "$arg" = "-f" ]] ; then
		installer_arguments="${installer_arguments} --force"
		force_install="true"
	elif [[ "$arg" = "nvidia" ]] ; then
		installer_arguments="${installer_arguments} nvidia"
	elif [[ "$arg" = "amd" ]] ; then
		installer_arguments="${installer_arguments} amd"
	elif [[ "$arg" = "intel" ]] ; then
		installer_arguments="${installer_arguments} intel"
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
	if [ "${force_install}" != "true" ] ; then
		read -n 1 answer
	else
		answer="${default}"
		echo "${default} (autoselected)"
	fi
	if [[ "${answer}" =~ ^[Yy]$ || ( "${default}" = "y" && "${answer}" = "" ) ]];then
		answer="true"
	else
		answer="false"
	fi
}

default="y"
#question="Install Lutris?"
#askQuestion
#if [ "${answer}" != "true" ] ; then
#	installer_arguments="${installer_arguments} nolutris"
#fi
#echo

#question="Install Steam?"
#askQuestion
#if [ "${answer}" != "true" ] ; then
#	installer_arguments="${installer_arguments} nosteam"
#fi
#echo

#question="Install Winetricks?"
#askQuestion
#if [ "${answer}" != "true" ] ; then
#	installer_arguments="${installer_arguments} nowinetricks"
#fi
#echo

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

cd "${workdir}" && ./distro_installers/autoinstall.sh $installer_arguments
