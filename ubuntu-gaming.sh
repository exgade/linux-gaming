#!/bin/bash

# Graphic Driver Install
nvidia_install="false"
amd_install="false"
intel_install="false"
autodetect_graphics="true"

# Gaming Tools Installer
lutris_install="true"
steam_install="true"
winetricks_install="true"
#teamspeak_install="true"
mumble_install="true"
#discord_install="true"

# automatic installation - use this with care and only if you know what you're doing
# this question will answer every question pacman asks with the default answer - it may break your system
option_noconfirm="false"

##### end configuration #####

# argument handler
for arg in "$@" ; do
	if [ "$arg" = "--force" ] ; then
		option_noconfirm="true"
	elif [[ "$arg" = "--help" || "$arg" = "-h" ]] ; then
		echo "usage: ./ubuntu-gaming.sh [OPTIONS]"
		echo "--force - no questions while installing / uninstalling packages - this might break your system"
		exit
	fi
done

if [ "`grep -P '^NAME=\"Pop\!' /etc/os-release | wc -l`" = "1" ] ; then
	echo "Error: Pop! OS Detected, this distribution is unsupported"
	exit
fi

#load os-release variables
source /etc/os-release

if [ "`whoami`" != "root" ] ; then
	echo "### Error: you have to run this script as root or via sudo"
	echo "Installation canceled"
	exit
fi

# noconfirm logic
installer_addition=""
if [ "${option_noconfirm}" = "true" ] ; then
	installer_addition="-y"
fi

# autodetect graphic cards
if [ "${autodetect_graphics}" = "true" ] ; then
	if [ "`lspci | grep -i nvidia | grep VGA | wc -l`" != "0" ] ; then
		nvidia_install="true"
	fi
	if [ "`lspci | grep -i amd | grep VGA | wc -l`" != "0" ] ; then
		amd_install="true"
	fi
	if [ "`lspci | grep -i intel | grep VGA | wc -l`" != "0" ] ; then
		intel_install="true"
	fi
fi

# setting additional packages to install
pkg_additional_install=""
if [ "${lutris_install}" = "true" ] ; then
	pkg_additional_install="${pkg_additional_install}lutris "
fi
if [ "${steam_install}" = "true" ] ; then
	pkg_additional_install="${pkg_additional_install}steam "
fi
if [ "${winetricks_install}" = "true" ] ; then
	pkg_additional_install="${pkg_additional_install}winetricks "
fi
if [ "${mumble_install}" = "true" ] ; then
	pkg_additional_install="${pkg_additional_install}mumble "
fi

apt update && apt upgrade ${installer_addition}

apt install wget ${installer_addition}

# install add-apt-repository command
apt install software-properties-common ${installer_addition}

if [[ "${UBUNTU_CODENAME}" = "fossa" || "${UBUNTU_CODENAME}" = "eoan" ]] ; then
	# add winehq repo
	if [ "`grep -E '^deb https://dl.winehq.org' /etc/apt/sources.list | wc -l`" = "0" ] ; then
		mkdir -p /root/.aptkeys
		if [ ! -f /root/.aptkeys/winehq.key ] ; then
			cd /root/.aptkeys/
			wget -nc https://dl.winehq.org/wine-builds/winehq.key
			apt-key add winehq.key
		fi
		if [ "`sha256sum /root/.aptkeys/winehq.key | grep 78b185fabdb323971d13bd329fefc8038e08559aa51c4996de18db0639a51df6 | wc -l`" = "1" ] ; then
			echo "### checksumme gültig, installiere repository für winehq"
			apt-add-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ ${UBUNTU_CODENAME} main"
		else
			echo "### Error: checksum invalid on winehq repository, aborting..."
			exit
		fi
	else
		echo "### winehq repository scheint schon installiert zu sein"
	fi
	if [ "${UBUNTU_CODENAME}" = "focal" ] ; then
		echo "### hotfixing focal fossa winehq repo to eoan"
		sed -i "s/dl\.winehq\.org\/wine-builds\/ubuntu\/ focal/dl.winehq.org\/wine-builds\/ubuntu\/ eoan/g" /etc/apt/sources.list
	fi
else
	echo "### avoid installation of winehq repositories on anything older than fossa or eoan"
	echo "### more info: https://forum.winehq.org/viewtopic.php?f=8&t=32192"
fi

# add lutris ppa
if [ ! -f "/etc/apt/sources.list.d/lutris-team-ubuntu-lutris-${UBUNTU_CODENAME}.list" ] ; then
	echo "### adding lutris ppa"
	add-apt-repository ppa:lutris-team/lutris
else
	echo "### lutris repository already added, skipping..."
fi
echo "### adding 32 Bit support and updating apt"
dpkg --add-architecture i386 && apt update

if [[ "${UBUNTU_CODENAME}" = "fossa" || "${UBUNTU_CODENAME}" = "eoan" ]] ; then
	echo "### installing wine-staging from winehq with recommendations"
	apt install --install-recommends winehq-staging ${installer_addition}
else
	echo "### installing wine-development as workaround if the winehq version isn't supported"
	apt install --install-recommends wine-development wine32-development wine64-development ${installer_addition}
fi

echo "### installing winetricks, dxvk, corefonts, xboxdrv"
# missing in elementary: dxvk-wine32-development dxvk-wine64-development
apt install winetricks dxvk ttf-mscorefonts-installer xboxdrv mono-runtime-common ${installer_addition}

if [ "${nvidia_install}" = "true" ] ; then
	if [ ! -f "/etc/apt/sources.list.d/graphics-drivers-ubuntu-ppa-${UBUNTU_CODENAME}.list" ] ; then
		echo "### adding ubuntu's GPU Drivers PPA, press ENTER to confirm"
                add-apt-repository ppa:graphics-drivers/ppa
                echo "### updating repositories for the new ppa"
                apt update
	else
		echo "### graphics-drivers ppa already installed, skipping"
	fi
	if [ "`apt list --installed nvidia-driver-440 | grep -i 'nvidia' | wc -l`" = "0" ] ; then
		echo "### installing nvidia proprietary driver"
		apt install nvidia-driver-440 libnvidia-gl-440 libnvidia-gl-440:i386 nvidia-settings nvidia-driver-440 nvidia-utils-440 ${installer_addition}
	else
		echo "### it seems that nvidia drivers are already installed"
	fi
fi
if [[ "${amd_install}" = "true" || "${intel_install}" = "true" ]] ; then
	echo "### installing intel/amd drivers"
	apt install libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 mesa-utils ${installer_addition}
fi

echo "### installing vulkan 64+32 bit"
apt install libvulkan1 libvulkan1:i386 ${installer_addition}

# Starting Software installation
echo "### installing additional gaming tools"
if [ "${pkg_additional_install}" = "" ] ; then
	echo "no additional tools to install"
else
	echo "installing additional tools ${pkg_additional_install}"
	apt install ${pkg_additional_install} ${installer_addition}
fi

# install common required libraries
echo "### installing libraries that are need for many games"
apt install libgnutls30:i386 libldap-2.4-2:i386 libgpg-error0:i386 libsqlite3-0:i386 libxml2:i386 libasound2-plugins:i386 libsdl2-2.0-0:i386 libfreetype6:i386 libdbus-1-3:i386

# software installation flathub
if [[ "${teamspeak_install}" = "true" || "${discord_install}" = "true" ]] ; then
	#echo "### starting additional software install with flatpak / flathub"
	#apt install flatpak ${installer_addition}
	#flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	#if [ "${teamspeak_install}" = "true" ] ; then
	#	flatpak install flathub com.teamspeak.TeamSpeak ${installer_addition}
	#fi
	#if [ "${discord_install}" = "true" ] ; then
	#	flatpak install flathub com.discordapp.Discord ${installer_addition}
	#fi
	echo "discord and teamspeak installation is disabled at the moment"
fi
