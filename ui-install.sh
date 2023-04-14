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
	local question="$1"
	local default="${2:-y}"
	local answer

	local prompt="[Y/n]"
	[[ "$default" =~ ^[yY]$ || "$default" = "" ]] || prompt="[y/N]"

	if [[ "${force_install}" != "true" ]]; then
		read -rp "$question $prompt" answer
	else
		answer="${default}"
		echo "${default} (autoselected)"
	fi

	[[ "${answer}" =~ ^[yY]$ || ( "${default}" = "y" && -z "${answer}" ) ]]
}

#if ! askQuestion "Install Lutris?" ; then
#	installer_arguments="${installer_arguments} nolutris"
#fi
#echo

#if ! askQuestion "Install Steam?" ; then
#	installer_arguments="${installer_arguments} nosteam"
#fi
#echo

#if ! askQuestion "Install Winetricks?" ; then
#	installer_arguments="${installer_arguments} nowinetricks"
#fi
#echo

if ! askQuestion "Install Teamspeak3?" ; then
	installer_arguments="${installer_arguments} nots3"
fi
echo

if ! askQuestion "Install Mumble?" ; then
	installer_arguments="${installer_arguments} nomumble"
fi
echo

if ! askQuestion "Install Discord?" ; then
	installer_arguments="${installer_arguments} nodiscord"
fi

cd "${workdir}" && ./distro_installers/autoinstall.sh $installer_arguments
