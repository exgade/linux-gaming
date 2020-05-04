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
	elif [[ "$arg" = "--help" || "$arg" = "-h" ]] ; then
		echo "usage: ./fedora-gaming.sh [OPTIONS]"
		echo "--force       - no questions while installing / uninstalling packages - this might break your system"
		echo "nolutris      - don't install Lutris"
		echo "nosteam       - don't install Steam"
		echo "nowinetricks  - don't install Winetricks"
		echo "nots3         - don't install Teamspeak3"
		echo "nomumble      - don't install Mumble"
		echo "nodiscord     - don't install Discord"

		exit
	fi
done

#load os-release variables
source /etc/os-release

if [ "$(whoami)" != "root" ] ; then
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
if [ "${discord_install}" = "true" ] ; then
	pkg_additional_install="${pkg_additional_install}discord "
fi

# btrfs tuning if possible
# if you dont want this - just delete the file general/btrfs-tuning.sh
workdir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
if [ -d "${workdir}/general" ] && [ -f "${workdir}/general/btrfs-tuning.sh" ] ; then
	echo "### optimizing btrfs, if needed"
	"${workdir}"/general/btrfs-tuning.sh
	echo "### if you see one error (per user) regarding to an steam folder, this can be ignored"
fi

dnf update ${installer_addition}
dnf install wget ${installer_addition}

# winehq
#if [ "${VERSION_ID}" = "32" ] ; then
#	echo "### Temporary workaround: adding Fedora 31 repositories for winehq"
#	dnf config-manager --add-repo "https://dl.winehq.org/wine-builds/fedora/31/winehq.repo" ${installer_addition}
#else
#	echo "### Adding Fedora ${VERSION_ID} Repositories for winehq"
#	dnf config-manager --add-repo "https://dl.winehq.org/wine-builds/fedora/${VERSION_ID}/winehq.repo" ${installer_addition}
#fi

#echo "### installing wine-staging from winehq with recommendations"
#if [ "$(dnf list winehq-stable | grep -i inst -c)" != "0" ] ; then
#	echo "### detected that winehq-stable is installed. to install winehq-staging it needs to be uninstalled"
#	dnf remove winehq-stable ${installer_addition}
#fi
#dnf install winehq-staging --allowerasing ${installer_addition}

if [ "$(dnf repolist | grep WineHQ -c)" != "0" ] ; then
	echo "### disabling WineHQ Repository"
	dnf config-manager --disable WineHQ
fi

echo "### installing wine-staging"
dnf install wine-staging wine-core wine-common --allowerasing ${installer_addition}

echo "### installing vulkan"
dnf install vulkan vulkan-loader vulkan-loader.i686 ${installer_addition}

if [[ "${nvidia_install}" = "true" || "${steam_install}" = "true" || "${discord_install}" = "true" ]] ; then
	echo "### enable rpm fusion free repository"
	sudo dnf install "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" ${installer_addition}
fi
if [[ "${nvidia_install}" = "true" || "${steam_install}" = "true" || "${discord_install}" = "true" ]] ; then
	echo "### enable rpm fusiion nonfree repository"
	sudo dnf install "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" ${installer_addition}
fi

# install common required libraries
echo "### installing libraries/ dependencies that are need for many games"
dnf install vdpauinfo libva-vdpau-driver libva-utils libvdpau gamemode sqlite SDL SDL_image SDL_mixer ${installer_addition}

if [ "${nvidia_install}" = "true" ] ; then
	echo "### installing nvidia drivers"
	dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda ${installer_addition}
fi
#if [[ "${amd_install}" = "true" || "${intel_install}" = "true" ]] ; then
#	echo "### installing intel/amd drivers"
#fi

# Starting Software installation
echo "### installing additional gaming tools"
if [ "${pkg_additional_install}" = "" ] ; then
	echo "no additional tools to install"
else
	echo "installing additional tools ${pkg_additional_install}"
	dnf install ${pkg_additional_install} ${installer_addition}
fi

if [ "${teamspeak_install}" = "true" ] ; then
	dnf install flatpak ${installer_addition}
	echo "### installing teamspeak3 with flatpak"
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install flathub com.teamspeak.TeamSpeak ${installer_addition}
fi

