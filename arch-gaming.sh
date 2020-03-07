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
teamspeak_install="true"
mumble_install="true"
discord_install="true"

if [ "`whoami`" != "root" ] ; then
	echo "### Error: you have to run this script as root or via sudo"
	echo "Installation canceled"
	exit
fi

# autodetect graphic cards
if [ "${autodetect_graphics}" = "true" ] ; then
	if [ "`lspci -v | grep -i nvidia | grep VGA`" != "0" ] ; then
		nvidia_install="true"
	fi
	if [ "`lspci -v | grep -i amd | grep VGA`" != "0" ] ; then
		amd_install="true"
	fi
	if [ "`lspci -v | grep -i intel | grep VGA`" != "0" ] ; then
		intel_install="true"
	fi
fi

# setting graphic drivers to install
# More Info Driver Installation: https://github.com/lutris/lutris/wiki/Installing-drivers
pkg_graphics_install=""
if [[ "${nvidia_install}" = "true" || "${amd_install}" = "true" || "${intel_install}" = "true" ]] ; then
	pkg_graphics_install="${pkg_graphics_install}vulkan-icd-loader lib32-vulkan-icd-loader "
	if [ "${nvidia_install}" = "true" ] ; then
		pkg_graphics_install="${pkg_graphics_install}nvidia nvidia-utils lib32-nvidia-utils lib32-vulkan-driver "
		if [ "`cat /etc/os-release | grep 'ID=manjaro' | wc -l`" = "0" ] ; then
			# manjaro doesn't have the package nvidia-settings
			pkg_graphics_install="${pkg_graphics_install}nvidia-settings "
		fi
	fi
	if [[ "${amd_install}" = "true" || "${intel_install}" = "true" ]] ; then
		pkg_graphics_install="${pkg_graphics_install}lib32-mesa vulkan-mesa-layer "
	fi
	if [ "${amd_install}" = "true" ] ; then
		pkg_graphics_install="${pkg_graphics_install}vulkan-radeon lib32-vulkan-radeon "
	fi
	if [ "${intel_install}" = "true" ] ; then
		pkg_graphics_install="${pkg_graphics_install}vulkan-intel lib32-vulkan-intel "
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
if [ "${teamspeak_install}" = "true" ] ; then
	pkg_additional_install="${pkg_additional_install}teamspeak3 "
fi
if [ "${mumble_install}" = "true" ] ; then
	pkg_additional_install="${pkg_additional_install}mumble "
fi
if [ "${discord_install}" = "true" ] ; then
	pkg_additional_install="${pkg_additional_install}discord "
fi

# btrfs tuning if possible
# if you dont want this - just delete the file general/btrfs-tuning.sh
workdir="`dirname $0`"
if [ -d "${workdir}/general" ] && [ -f "${workdir}/general/btrfs-tuning.sh" ] ; then
	echo "### optimizing btrfs, if needed"
	${workdir}/general/btrfs-tuning.sh
	echo "### if you see one error (per user) regarding to an steam folder, this can be ignored"
fi

pacman -Syyu


if [ -f /etc/pacman.conf.orig ] ; then
	echo Backup already existent, please delete or rename file /etc/pacman.conf.orig first
else
	echo "### activating multilib..."
	perl -0777 -i.orig -pe "s/#\[multilib\]\n#Include = \/etc\/pacman.d\/mirrorlist/\[multilib\]\nInclude = \/etc\/pacman.d\/mirrorlist/" /etc/pacman.conf
fi


echo "### installing graphics support"
if [ "${pkg_graphics_install}" = "" ] ; then
	echo "no graphic drivers to install"
else
	echo "installing graphic drivers ${pkg_graphics_install}"
	pacman -S ${pkg_graphics_install} --needed
fi

# if wine is installed, remove it to avoid conflict with wine-staging
if [[ "`pacman -Q wine | wc -l`" = "1" && "`pacman -Q wine | grep wine-staging | wc -l`" = "0" ]] ; then
	echo "### detected that wine is installed, we need to remove the wine package to install wine-staging"
	echo "### sadly we also need to remove packages depending on wine to avoid conflicts later on"
	pacman -Rc wine
fi
# different libraries and wine-staging (have to be installed before winetricks)
pacman -S wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader --needed

# dependencies for a lot of games
pacman -S wine-gecko wine-mono lib32-gnutls lib32-libldap lib32-libgpg-error lib32-sqlite lib32-libpulse vkd3d lib32-vkd3d lib32-libvdpau libvdpau --needed

# Starting Software installation
echo "### installing additional gaming tools"
if [ "${pkg_additional_install}" = "" ] ; then
	echo "no additional tools to install"
else
	echo "installing additional tools ${pkg_additional_install}"
	pacman -S ${pkg_additional_install} --needed
fi

if [ "`cat /etc/os-release | grep 'ID=manjaro' | wc -l`" = "1" ] ; then
	echo "### ATTENTION - Manjaro specific:"
        echo "### you should check your manjaro settings -> hardware now. "
	echo "### if you see old drivers there, you have to remove old drivers/ configurations and then auto install proprietary drivers afterwards"
fi


