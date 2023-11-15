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

# automatic installation - answer every question apt asks with yes
# use this option with caution, it may break your system
option_noconfirm="false"

##### end configuration #####

if [ "$(whoami)" != "root" ] ; then
	echo "### Error: you have to run this script as root or via sudo"
	echo "Installation canceled"
	exit
fi

# noconfirm logic
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
	elif [[ "$arg" = "amd" ]] ; then
		amd_install="true"
	elif [[ "$arg" = "intel" ]] ; then
		intel_install="true"
	elif [[ "$arg" = "--help" || "$arg" = "-h" ]] ; then
		echo "usage: ./debian-gaming.sh [OPTIONS]"
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
installer_addition=""
if [ "${option_noconfirm}" = "true" ] ; then
	installer_addition="-y"
fi

pkg_extra=""
if [ "${lutris_install}" = "true" ] ; then
	pkg_extra="${pkg_extra}lutris "
fi
if [ "${steam_install}" = "true" ] ; then
	pkg_extra="${pkg_extra}steam "
fi
if [ "${winetricks_install}" = "true" ] ; then
	pkg_extra="${pkg_extra}winetricks "
fi
if [ "${mumble_install}" = "true" ] ; then
	pkg_extra="${pkg_extra}mumble "
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

# graphic card pkgs
pkg_graphic=""
if [[ "${nvidia_install}" = "true" || "${amd_install}" = "true" || "${intel_install}" = "true" ]] ; then
	pkg_graphic="${pkg_graphic}firmware-linux-nonfree "
	if [ "${nvidia_install}" = "true" ] ; then
		pkg_graphic="${pkg_graphic}nvidia-driver "
	fi
	if [ "${amd_install}" = "true" ] ; then
		pkg_graphic="${pkg_graphic}libgl1-mesa-dri libgl1-mesa-dri:i386 xserver-xorg-video-ati xserver-xorg-video-amdgpu mesa-vulkan-drivers mesa-vulkan-drivers:i386 "
	fi
fi

# btrfs tuning if possible
workdir="$( cd "$(dirname "$0")" >/dev/null 2>&1 || exit ; pwd -P )"
if [ -d "${workdir}/../general" ] && [ -f "${workdir}/../general/btrfs-tuning.sh" ] ; then
	"${workdir}"/../general/btrfs-tuning.sh
	echo "### if you see one error regarding to a not operation in a steam folder, this can be ignored"
fi

if [ "$(grep ' main' /etc/apt/sources.list | grep 'contrib' -c)" = "0" ] ; then
	chk1="$(grep ' main' /etc/apt/sources.list | grep non-free -c)"
	chk2="$(grep ' main' /etc/apt/sources.list | grep contrib -c)"
	chk3="$(grep ' main' /etc/apt/sources.list | grep non-free-firmware -c)"
	chk4="$(grep ' main' /etc/apt/sources.list -c)"
	if [[ "$chk1" = "$chk2" && "$chk1" = "0" && ! -f /etc/apt/sources.list.bck ]] ; then
		echo "### installing contrib / non-free sources"
		cp /etc/apt/sources.list /etc/apt/sources.list.bck
		sed -i "s/ main/ main contrib non-free/g" /etc/apt/sources.list
	elif [[ "$chk3" = "$chk4" && "$chk3" != "$chk2" && "$chk2" = "0" && ! -f /etc/apt/sources.list.bck ]] ; then
		echo "### installing contrib / non-free sources by adding to existing non-free-firmware"
		cp /etc/apt/sources.list /etc/apt/sources.list.bck
		sed -i "s/ main non-free-firmware/ main contrib non-free non-free-firmware/g" /etc/apt/sources.list
	else
		echo "### can't automatically install contrib / non-free repos, aborting"
		exit
	fi
fi


# update sources.list to https (if this is not working, you might want to select a mirror deb.debian.org for everything that is not security updates)
# should work on most installations, but commented out for the moment
#sed -i "s/http:/https:/g" /etc/apt/sources.list
#sed -i "s/security\.debian\.org/cdn-aws.deb.debian.org/g" /etc/apt/sources.list

apt update && apt full-upgrade ${installer_addition}

apt install wget ${installer_addition}

# Check Checksums for Lutris & Winehq
if [ ! -d ~/.aptkeys ] ; then
	mkdir ~/.aptkeys
fi
if [[ "${lutris_install}" = "true" && ! -f ~/.aptkeys/LutrisDebian12.key ]] ; then
	echo "### downloading lutris key"
	cd ~/.aptkeys || exit
	wget https://download.opensuse.org/repositories/home:/strycore/Debian_12/Release.key -O ~/.aptkeys/LutrisDebian12.key
fi
if [ ! -f ~/.aptkeys/winehq.key ] ; then
	echo "### downloading winehq key"
	cd ~/.aptkeys || exit
	wget https://dl.winehq.org/wine-builds/winehq.key -O ~/.aptkeys/winehq.key
fi

# Check sha256 checksum for winehq repo
if [ "$(sha256sum ~/.aptkeys/winehq.key | awk '{print $1}')" = "78b185fabdb323971d13bd329fefc8038e08559aa51c4996de18db0639a51df6" ] ; then
	echo "### Checksum of WineHQ OK, adding key"
	cp ~/.aptkeys/winehq.key /etc/apt/trusted.gpg.d/winehq.asc
else
	echo "### Aborting: Checksum of WineHQ NOT OK!"
	exit
fi
# Check sha256 checksum for lutris repo
if [[ "${lutris_install}" = "true" && "$(sha256sum ~/.aptkeys/LutrisDebian12.key | awk '{print $1}')" = "a77a7f3f09d0952d38bcf7178c84bf3eedbcc9b0d30c362b2a93bae6dff578fc" ]] ; then
	echo "### Checksum of Lutris OK, adding key"
	cd ~/.aptkeys || exit
	if [ -f ~/.aptkeys/LutrisDebian12.key.gpg ] ; then
		rm ~/.aptkeys/LutrisDebian12.key.gpg
	fi
	gpg --dearmor ~/.aptkeys/LutrisDebian12.key
	cp ~/.aptkeys/LutrisDebian12.key.gpg /etc/apt/keyrings/lutris.gpg
else
	echo "### Aborting: Checksum of Lutris NOT OK!"
	exit
fi

#add winehq repo
echo "### adding winehq repository"
if [ "$(grep bookworm /etc/os-release -c)" != "0" ] ; then
	echo "deb https://dl.winehq.org/wine-builds/debian/ bookworm main" > /etc/apt/sources.list.d/winehq.list
elif [ "$(grep bullseye /etc/os-release -c)" = "1" ] ; then
	echo "deb https://dl.winehq.org/wine-builds/debian/ bullseye main" > /etc/apt/sources.list.d/winehq.list
else
	echo "deb https://dl.winehq.org/wine-builds/debian/ buster main" > /etc/apt/sources.list.d/winehq.list
fi

if [ "${lutris_install}" = "true" ] ; then
	#add lutris repo
	echo "### adding lutris repository"
	echo "deb [signed-by=/etc/apt/keyrings/lutris.gpg] https://download.opensuse.org/repositories/home:/strycore/Debian_12/ ./" > /etc/apt/sources.list.d/lutris.list
fi

echo "### installing dxvk, vkd3d, corefonts, xboxdrv"
dpkg --add-architecture i386 && apt update && apt install ttf-mscorefonts-installer dxvk dxvk-wine32-development dxvk-wine64-development libvkd3d1 xboxdrv vulkan-tools ${installer_addition}

echo "### installing winehq-staging with recommendations"
apt install --install-recommends winehq-staging wine32 wine64 ${installer_addition}

if [ "${pkg_graphic}" != "" ] ; then
	echo "### installing proprietary drivers: ${pkg_graphic}"
	apt install ${pkg_graphic} ${installer_addition}
fi

echo "### installing some dependencies for many games"
apt install libgnutls30:i386 libldap-2.4-2:i386 libgpg-error0:i386 libsqlite3-0:i386 libxml2:i386 libsdl2-2.0-0:i386 libfreetype6:i386 libdbus-1-3:i386 libsdl-image1.2 libsdl-mixer1.2 ${installer_addition}

if [ "${pkg_extra}" != "" ] ; then
	echo "### installing winetricks, steam and lutris, depending on configuration"
	apt install ${pkg_extra} ${installer_addition}
fi
if [[ "${teamspeak_install}" = "true" || "${discord_install}" = "true" ]] ; then
	echo "### install flatpak if not needed"
	apt install flatpak ${installer_addition}
	echo "### updating flatpak and cleaning up"
	flatpak update
	flatpak remove --unused
	echo "### starting additional software install with flatpak / flathub"
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	if [ "${teamspeak_install}" = "true" ] ; then
		echo "### installing Teamspeak3 via Flatpak"
		flatpak install flathub com.teamspeak.TeamSpeak ${installer_addition}
	fi
	if [[ "${discord_install}" = "true" ]] ; then
		echo "### installing Discord via Flatpak"
		flatpak install flathub com.discordapp.Discord ${installer_addition}
	fi
fi
