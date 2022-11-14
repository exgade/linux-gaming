#!/bin/bash
workdir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [ "$(whoami)" = "root" ] ; then
	echo "this script should NOT be run as root or via sudo"
	echo "please use this with your user account"
	exit
fi

steamcompatdir="${HOME}/.steam/steam/compatibilitytools.d"
if [[ ! -d "${HOME}/.steam/root/compatibilitytools.d" && -d "${HOME}/.local/share/Steam/compatibilitytools.d" ]] ; then
	steamcompatdir="${HOME}/.local/share/Steam/compatibilitytools.d"
fi


if [ "$1" = "last" ] ; then
	gerelease="7-38"
	getag="${gerelease}"
	gechecksum="77e64e26e8c967a049d5c2d89cd7799bce1d05760afcc7f21bd1efc05ca2b5d1"
elif [[ "$1" = "" || "$1" = "both" || "$1" = "latest" ]] ; then
	gerelease="7-41"
	getag="${gerelease}"
	gechecksum="10f57577b5f9298576c1958ecd6d49ba3c414a8a6fbb3c08a18d7e997a2cc155"
#elif [[ "$1" = "dev" ]] ; then
#	gerelease="5.9-GE-2-MF"
#	getag="${gerelease}"
#	gechecksum="aedeeeeb5435cf7c5e6e062935e1d565562ce7dc34d5dbea8b6db7235fc69391"
elif [[ "$1" = "-h" || "$1" = "--help" ]] ; then
	echo "usage: ./ge-proton.sh <command (optional)>"
	echo "examples:"
	echo "./ge-proton.sh            load and install newest ge proton"
	echo "./ge-proton.sh latest     ~"
	echo "./ge-proton.sh last       load and install the second latest stable minor version"
	echo "./ge-proton.sh both       load and install both versions"
	echo "./ge-proton.sh --cleanup  delete old proton versions"
	exit
elif [[ "$1" = "--cleanup" ]] ; then
	delete_proton () {
		if [[ "$1" != "" && -d "${steamcompatdir}/$1" ]] ; then
			echo "$1 found, deleting..."
			rm -Rdf "${steamcompatdir:?}/${1:?}"
			deleted="true"
		fi
	}
	deleted="false"
	for tmpdir in Proton-5.{1,2,3,4,5,6,7,8,9}{,1,2,3,4,5,6,7,8,9,0}-GE-{1,2,3,4,5,6,7,8,9}{,-ST,-MF} ; do
		delete_proton "${tmpdir}"
	done
	oldversions="Proton-6.0-GE-1 Proton-6.1-GE-1 Proton-6.1-GE-2 Proton-6.4-GE-1 Proton-6.5-GE-1 Proton-6.5-GE-2 Proton-6.9-GE-2-github-actions-test Proton-6.10-GE-1 Proton-6.12-GE-1 Proton-6.13-GE-1 Proton-6.14-GE-2 Proton-6.15-GE-2 Proton-6.16-GE-1 Proton-6.19-GE-2 Proton-6.20-GE-1 Proton-6.21-GE-2 Proton-7.0rc2-GE-1 Proton-7.0rc6-GE-1 Proton-7.1-GE-2 Proton-7.2-GE-2 GE-Proton7-3 GE-Proton7-8 GE-Proton7-10 GE-Proton7-14 GE-Proton7-17 GE-Proton7-20 GE-Proton7-23 GE-Proton7-29 GE-Proton7-33 GE-Proton7-35 GE-Proton7-37"
	for tmpdir in $oldversions ; do
		delete_proton "${tmpdir}"
	done
	if [ "${deleted}" = "true" ] ; then
		echo "One or more Proton Versions have been deleted"
	else
		echo "No old Proton Versions found, no need to delete anything"
	fi
	exit
else
	echo unknown operation
	exit
fi

if [ "$(whereis wget | grep "/bin" -c)" = "0" ] ; then
	echo "Error: please install wget first"
	exit
fi

if [ ! -d "${steamcompatdir}" ] ; then
	mkdir -p "${steamcompatdir}"
fi
cd "${steamcompatdir}/" || exit
if [[ ! -d "${steamcompatdir}/Proton-${gerelease}" && ! -f "${steamcompatdir}/Proton-${gerelease}.tar.gz" ]] ; then
	echo Downloading Glorious Eggroll Proton...
	if [[ ! -f /usr/local/bin/wget || "$(readlink -f /usr/local/bin/wget)" = "/usr/bin/firejail" ]] ;then
		cmd_wget="/usr/bin/wget"
	else
		cmd_wget="wget"
	fi
	releasefolder="GE-Proton${gerelease}"
	releasefilename="GE-Proton${gerelease}.tar.gz"
	${cmd_wget} "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${releasefolder}/${releasefilename}" -P ~/.steam/root/compatibilitytools.d/ -O Proton-${gerelease}.tar.gz

	echo checksum check...

	if [ "$(sha256sum "${steamcompatdir}/Proton-${gerelease}.tar.gz" | grep ${gechecksum} -c)" = "1" ] ; then
		echo "checksum ok, extracting tar.gz..."
		tar xzf "Proton-${gerelease}.tar.gz"
		echo "removing tar.gz file"
		rm "Proton-${gerelease}.tar.gz"
		echo "installation complete, restart steam now"
	else
		echo "checksum not ok"
	fi
else
	echo "Error: Download of Proton ${gerelease} already started or installation already done."
	if [ ! -d "${steamcompatdir}/Proton-${gerelease}" ] ; then
		echo "Delete an broken Download with this and restart: "
		echo "rm ${steamcompatdir}/Proton-${gerelease}.tar.gz"
	fi
fi
if [[ "$1" = "both" ]] ; then
	"${workdir}"/ge-proton.sh last
fi
