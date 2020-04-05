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

if [ "`grep -P '^NAME=\"Pop\!' /etc/os-release | wc -l`" = "1" ] ; then
	echo "Error: Pop! OS Detected, this distribution is unsupported"
	exit
fi

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

apt update && apt full-upgrade ${installer_addition}

apt install wget ${installer_addition}

# install add-apt-repository command
apt install software-properties-common ${installer_addition}

# add lutris ppa
if [ "`grep lutris /etc/apt/sources.list.d/* | wc -l`" = "0" ] ; then
	echo "### adding lutris ppa"
	add-apt-repository ppa:lutris-team/lutris
else
	echo "### lutris repository already added, skipping..."
fi
echo "### adding 32 Bit support and updating apt"
dpkg --add-architecture i386 && apt update

#echo "### installing wine-devel with recommendations"
#apt install --install-recommends wine-development wine32-development wine64-development ${installer_addition}

echo "### installing wine-staging with recommendations"
apt install --install-recommends wine-staging wine-staging-amd64 wine-staging-i386:i386 ${installer_addition}

echo "### installing winetricks, dxvk, basic wine, corefonts, xboxdrv"
# missing in elementary or also on ubuntu? dxvk-wine32-development dxvk-wine64-development
apt install winetricks ttf-mscorefonts-installer xboxdrv ${installer_addition}

if [ "${nvidia_install}" = "true" ] ; then
	if [ '`apt list nvidia-driver-* | grep -i "\[inst" | wc -l`' = "0" ] ; then
		echo "### installing nvidia proprietary driver - no installation candidate for ubuntu"
		apt install nvidia-settings nvidia-driver-435 nvidia-utils-435 ${installer_addition}
	else
		echo "### it seems that nvidia drivers are already installed"
	fi
fi
if [[ "${amd_install}" = "true" || "${intel_install}" = "true" ]] ; then
	echo "### installing intel/amd drivers"
	apt install libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386
fi

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
