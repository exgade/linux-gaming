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
#mumble_install="true"
#discord_install="true"

if [ "`whoami`" != "root" ] ; then
	echo "### Error: you have to run this script as root or via sudo"
	echo "Installation canceled"
	exit
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

# btrfs tuning if possible
workdir="`dirname $0`"
if [ -d "${workdir}/general" ] && [ -f "${workdir}/general/btrfs-tuning.sh" ] ; then
	${workdir}/general/btrfs-tuning.sh
	echo "### if you see one error regarding to a not operation in a steam folder, this can be ignored"
fi

if [ "`cat /etc/apt/sources.list | grep ' main' | grep 'contrib' | grep 'non-free' | wc -l`" = "0" ] ; then
	chk1="`cat /etc/apt/sources.list | grep ' main' | grep non-free | wc -l`"
	chk2="`cat /etc/apt/sources.list | grep ' main' | grep contrib | wc -l`"
	if [[ "$chk1" = "$chk2" && "$chk1" = "0" && ! -f /etc/apt/sources.list.bck ]] ; then
		echo "### installing contrib / non-free sources"
		cp /etc/apt/sources.list /etc/apt/sources.list.bck
		sed -i "s/ main/ main contrib non-free/g" /etc/apt/sources.list
	else
		echo "### can't automatically install contrib / non-free repos, aborting"
		exit
	fi
fi


# update sources.list to https (if this is not working, you might want to select a mirror deb.debian.org for everything that is not security updates)
# should work on most installations, but commented out for the moment
#sed -i "s/http:/https:/g" /etc/apt/sources.list
#sed -i "s/security\.debian\.org/cdn-aws.deb.debian.org/g" /etc/apt/sources.list

apt update && apt full-upgrade -y

apt install wget -y

# Check Checksums for Lutris & Winehq
if [ ! -d ~/.aptkeys ] ; then
	mkdir ~/.aptkeys
fi
if [ ! -f ~/.aptkeys/LutrisDebian10.key ] ; then
	echo "### downloading lutris key"
	cd ~/.aptkeys
	wget https://download.opensuse.org/repositories/home:/strycore/Debian_9.0/Release.key -O ~/.aptkeys/LutrisDebian10.key
fi
if [ ! -f ~/.aptkeys/winehq.key ] ; then
	echo "### downloading winehq key"
	cd ~/.aptkeys
	wget https://dl.winehq.org/wine-builds/winehq.key -O ~/.aptkeys/winehq.key
fi
	
# Check sha256 checksum for winehq repo
if [ "`sha256sum ~/.aptkeys/winehq.key | awk '{print $1}'`" = "78b185fabdb323971d13bd329fefc8038e08559aa51c4996de18db0639a51df6" ] ; then
	echo "### Checksum of WineHQ OK, adding key"
	apt-key add ~/.aptkeys/winehq.key
else
	echo "### Aborting: Checksum of WineHQ NOT OK!"
	exit
fi
# Check sha256 checksum for lutris repo
if [ "`sha256sum ~/.aptkeys/LutrisDebian10.key | awk '{print $1}'`" = "8f43b344d71eb648c3ec687ab4e13521db42666c777560d1845d917458f6b35a" ] ; then
	echo "### Checksum of Lutris OK, adding key"
	apt-key add ~/.aptkeys/LutrisDebian10.key
else
	echo "### Aborting: Checksum of Lutris NOT OK!"
	exit
fi

#add winehq repo
echo "### adding winehq repository"
if [ "`cat /etc/os-release | grep bullseye | wc -l`" = "1" ] ; then
	echo "deb https://dl.winehq.org/wine-builds/debian/ bullseye main" > /etc/apt/sources.list.d/winehq.list
else
	echo "deb https://dl.winehq.org/wine-builds/debian/ buster main" > /etc/apt/sources.list.d/winehq.list
fi

#add lutris repo
echo "### adding lutris repository"
echo "deb https://download.opensuse.org/repositories/home:/strycore/Debian_10/ /" > /etc/apt/sources.list.d/home:strycore.list

echo "### installing dxvk, corefonts, xboxdrv"
dpkg --add-architecture i386 && apt update && apt install ttf-mscorefonts-installer dxvk-wine32-development dxvk-wine64-development xboxdrv -y

echo "### installing winehq-staging with recommendations"
apt install --install-recommends winehq-staging -y

if [ "$nvidia_install" = "true" ] ; then
	echo "### installing nvidia proprietary driver"
	apt install nvidia-driver nvidia-driver-libs-i386 -y
fi

echo "### installing some dependencies for many games"
apt install libgnutls30:i386 libldap-2.4-2:i386 libgpg-error0:i386 libsqlite3-0:i386 -y

if [ "${pkg_extra}" != "" ] ; then
	echo "### installing winetricks, steam and lutris, depending on configuration"
	apt install ${pkg_extra} -y
fi