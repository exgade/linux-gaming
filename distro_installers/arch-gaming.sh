#!/bin/bash

# Basic System
microcode_install="true"

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
gamemode_install="true"

# automatic installation - use this with care and only if you know what you're doing
# this question will answer every question pacman asks with the default answer - it may break your system
option_noconfirm="false"

##### end configuration #####

# argument handler
for arg in "$@" ; do
	if [[ "$arg" = "--force" || "$arg" = "-f" ]] ; then
		option_noconfirm="true"
	elif [[ "$arg" = "nolutris" ]] ; then
		lutris_install="false"
	elif [[ "$arg" = "nosteam" ]] ; then
		steam_install="false"
	elif [[ "$arg" = "nowinetricks" ]] ; then
		winetricks_install="false"
	elif [[ "$arg" = "nots3" ]] ; then
		teamspeak_install="false"
	elif [[ "$arg" = "nomumble" ]] ; then
		mumble_install="false"
	elif [[ "$arg" = "nodiscord" ]] ; then
		discord_install="false"
	elif [[ "$arg" = "nvidia" ]] ; then
		nvidia_install="true"
		echo "Debug: Nvidia installation"
	elif [[ "$arg" = "amd" ]] ; then
		amd_install="true"
		echo "Debug: AMD installation"
	elif [[ "$arg" = "intel" ]] ; then
		intel_install="true"
		echo "Debug: Intel installation"
	elif [[ "$arg" = "--help" || "$arg" = "-h" ]] ; then
		echo "usage: ./arch-gaming.sh [OPTIONS]"
		echo "--force       - no questions while installing / uninstalling packages - this might break your system"
		echo "nolutris      - don't install Lutris"
		echo "nosteam       - don't install Steam"
		echo "nowinetricks  - don't install Winetricks"
		echo "nots3         - don't install Teamspeak3"
		echo "nomumble      - don't install Mumble"
		echo "nodiscord     - don't install Discord"
		echo "nvidia        - force installation of nvidia drivers"
		echo "amd           - force installation of amd drivers"
		echo "intel         - force installation of intel drivers"

		exit
	fi
done

# abort if not root and no sudo was used
if [ "$(whoami)" != "root" ] ; then
	echo "### Error: you have to run this script as root or via sudo"
	echo "Installation canceled"
	exit
fi

# noconfirm logic
installer_addition=""
if [ "${option_noconfirm}" = "true" ] ; then
	installer_addition="--noconfirm"
fi

# autodetect graphic cards
if [ "${autodetect_graphics}" = "true" ] ; then
	if [ "$(lspci | grep -i nvidia | grep VGA -c)" != "0" ] ; then
		nvidia_install="true"
	fi
	if [ "$(lspci | grep -i amd | grep VGA -c)" != "0" ] ; then
		amd_install="true"
	fi
	if [ "$(lspci | grep -i intel | grep VGA -c)" != "0" ] ; then
		intel_install="true"
	fi
fi

# setting os-release
ID="unknown"
if [ -f /etc/os-release ] ; then
	source /etc/os-release
fi

if [ "${microcode_install}" = "true" ] ; then
	echo "### Detecting CPU for Microcode installation"
	if (lscpu | grep Intel > /dev/null) then
		echo "### Intel CPU detected"
		pacman -S intel-ucode --needed ${installer_addition}
	fi
	if (lscpu | grep AMD > /dev/null) then
		echo "### AMD CPU detected"
		pacman -S amd-ucode --needed ${installer_addition}
	fi
fi

# setting graphic drivers to install
# More Info Driver Installation: https://github.com/lutris/lutris/wiki/Installing-drivers
pkg_graphics_install=""
if [[ "${nvidia_install}" = "true" || "${amd_install}" = "true" || "${intel_install}" = "true" ]] ; then
	if [ "${nvidia_install}" = "true" ] ; then
		if [ "${ID}" = "manjaro" ] ; then
			for nvdrv in "440" ; do
				echo "### checking for old ${nvdrv} nvidia drivers to uninstall"
				if [ "$(pacman -Q nvidia-${i}440xx-utils | wc -l 2>&1)" = "1" ] ; then
					echo "### uninstalling nvidia-${nvdrv} drivers"
					for i in $(mhwd-kernel -li | sed 's/\s\s\s\*\s//g' - | grep -E '^linux[0-9]+$') ; do
						pacman -R "${i}-nvidia-${nvdrv}xx" ${installer_addition}
					done
					for i in $(mhwd-kernel -li | sed 's/\s\s\s\*\s//g' - | grep -E '^linux[0-9]+-rt$') ; do
						pacman -R "${i}-nvidia-${nvdrv}xx" ${installer_addition}
					done
					pacman -R "nvidia-${nvdrv}xx-utils" "lib32-nvidia-${nvdrv}xx-utils" ${installer_addition}
				fi
			done
			echo "### autodetecting manjaro kernel and installing nvidia driver depending on that"
			if [ "$(mhwd-kernel -li | sed 's/\s\s\s\*\s//g' - | grep -E '^linux[0-9]+$')" != "" ] ; then
				manj_nvidia=""
				for i in $(mhwd-kernel -li | sed 's/\s\s\s\*\s//g' - | grep -E '^linux[0-9]+$') ; do
					manj_nvidia="${i}-nvidia-450xx ${manj_nvidia}"
				done
				for i in $(mhwd-kernel -li | sed 's/\s\s\s\*\s//g' - | grep -E '^linux[0-9]+-rt$') ; do
					manj_nvidia="${i}-nvidia-450xx ${manj_nvidia}"
				done
				echo "### installing manjaro specific packages for nvidia"
				sudo pacman -S ${manj_nvidia} lib32-nvidia-450xx-utils --needed ${installer_addition}
			else
				echo "### ERROR while autodetecting installed kernels"
				echo "### installation abort"
				exit
			fi
		fi
		pkg_graphics_install="${pkg_graphics_install}nvidia nvidia-utils lib32-nvidia-utils lib32-vulkan-driver "
		if [ "${ID}" != "manjaro" ] ; then
			# manjaro doesn't have the package nvidia-settings
			pkg_graphics_install="${pkg_graphics_install}nvidia-settings "
		fi
	fi
	if [[ "${amd_install}" = "true" || "${intel_install}" = "true" ]] ; then
		pkg_graphics_install="${pkg_graphics_install}mesa lib32-mesa vulkan-mesa-layers "
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
if [ "${gamemode_install}" = "true" ] ; then
	pkg_additional_install="${pkg_additional_install}gamemode lib32-gamemode "
fi


# btrfs tuning if possible
# if you dont want this - just delete the file general/btrfs-tuning.sh
workdir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
if [ -d "${workdir}/../general" ] && [ -f "${workdir}/../general/btrfs-tuning.sh" ] ; then
	echo "### optimizing btrfs, if needed"
	"${workdir}"/../general/btrfs-tuning.sh
	echo "### if you see one error (per user) regarding to an steam folder, this can be ignored"
fi

pacman -Syyu ${installer_addition}


if [ -f /etc/pacman.conf.orig ] ; then
	echo Backup already existent, please delete or rename file /etc/pacman.conf.orig first
else
	echo "### activating multilib..."
	perl -0777 -i.orig -pe "s/#\[multilib\]\n#Include = \/etc\/pacman.d\/mirrorlist/\[multilib\]\nInclude = \/etc\/pacman.d\/mirrorlist/" /etc/pacman.conf
	echo "### updating pacman to load multilib..."
	pacman -Sy ${installer_addition}
fi


echo "### installing graphics support"
if [ "${pkg_graphics_install}" = "" ] ; then
	echo "no graphic drivers to install"
else
	echo "installing graphic drivers ${pkg_graphics_install}"
	pacman -S ${pkg_graphics_install} --needed ${installer_addition}
fi

# if wine is installed, remove it to avoid conflict with wine-staging
if [[ "$(pacman -Q wine | wc -l)" = "1" && "$(pacman -Q wine | grep wine-staging -c)" = "0" ]] ; then
	echo "### detected that wine is installed, we need to remove the wine package to install wine-staging"
	echo "### sadly we also need to remove packages depending on wine to avoid conflicts later on"
	pacman -Rc wine ${installer_addition}
fi
# different libraries and wine-staging (have to be installed before winetricks)
pacman -S wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader --needed ${installer_addition}

# dependencies for a lot of games
pacman -S wine-gecko wine-mono lib32-gnutls lib32-libldap lib32-libgpg-error lib32-sqlite lib32-libpulse vkd3d lib32-vkd3d lib32-libvdpau libvdpau lib32-libxml2 lib32-sdl2 lib32-freetype2 lib32-dbus sdl_image sdl_mixer --needed ${installer_addition}

# Starting Software installation
echo "### installing additional gaming tools"
if [ "${pkg_additional_install}" = "" ] ; then
	echo "no additional tools to install"
else
	echo "installing additional tools ${pkg_additional_install}"
	pacman -S ${pkg_additional_install} --needed ${installer_addition}
fi

echo "### installation complete"
