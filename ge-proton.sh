#!/bin/bash
workdir="$( cd "$(dirname "$0")" >/dev/null 2>&1 || exit ; pwd -P )"
available() { command -v "$1" >/dev/null; }

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
	gerelease="8-32"
	gechecksum="8fbdd675daca620c257da8d3565cf234594a2db36da6acbd69597bd43eaf582768279a97042cf2e9144b6a3f34032a97dcf3d9d90b1a74699ee48a94a4c5cfe3"
elif [[ "$1" = "" || "$1" = "both" || "$1" = "latest" ]] ; then
	gerelease="9-2"
	gechecksum="0fb39d59d83421de1039df0381fcd942296414fcd23cde6c37a8827b21af873f5b473b538e7992aca2c6b541f899f89d912a25c53d3c6344bd217984f59f08d9"
#elif [[ "$1" = "dev" ]] ; then
#	gerelease="5.9-GE-2-MF"
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
	for tmpdir in Proton-{5,6}.{1,2,3,4,5,6,7,8,9}{,1,2,3,4,5,6,7,8,9,0}-GE-{1,2,3,4,5,6,7,8,9}{,-ST,-MF} ; do
		delete_proton "${tmpdir}"
	done
	for tmpdir in GE-Proton7-{1,2,3,4,5,6,7,8,9}{,1,2,3,4,5,6,7,8,9,0} ; do
		delete_proton "${tmpdir}"
	done
	oldversions="Proton-6.9-GE-2-github-actions-test Proton-7.0rc2-GE-1 Proton-7.0rc6-GE-1 Proton-7.1-GE-2 Proton-7.2-GE-2"
	oldversions="${oldversions} GE-Proton8-1 GE-Proton8-3 GE-Proton8-4 GE-Proton8-6 GE-Proton8-9 GE-Proton8-11 GE-Proton8-13 GE-Proton8-15 GE-Proton8-22 GE-Proton8-25"
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

if ! available wget ; then
	echo "Error: please install wget first"
	exit
fi

if [ ! -d "${steamcompatdir}" ] ; then
	mkdir -p "${steamcompatdir}"
fi
cd "${steamcompatdir}/" || exit
if [[ ! -d "${steamcompatdir}/GE-Proton${gerelease}" && ! -f "${steamcompatdir}/Proton-${gerelease}.tar.gz" ]] ; then
	echo Downloading Glorious Eggroll Proton...
	if [[ ! -f /usr/local/bin/wget || "$(readlink -f /usr/local/bin/wget)" = "/usr/bin/firejail" && -f /usr/bin/wget ]] ;then
		cmd_wget="/usr/bin/wget"
	else
		cmd_wget="wget"
	fi
	releasefolder="GE-Proton${gerelease}"
	releasefilename="GE-Proton${gerelease}.tar.gz"
	${cmd_wget} "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${releasefolder}/${releasefilename}" -P ~/.steam/root/compatibilitytools.d/ -O Proton-${gerelease}.tar.gz

	echo checksum check...
	hashtype="sha256sum"
	if [[ "$gechecksum" =~ ^[0-9a-fA-F]{128}$ ]]; then
		hashtype="sha512sum"
	fi
	if [ "$("${hashtype}" "${steamcompatdir}/Proton-${gerelease}.tar.gz" | grep ${gechecksum} -c)" = "1" ] ; then
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
