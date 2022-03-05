#!/bin/bash
justcheck="false"

for arg in "$@" ; do
	if [[ "$arg" = "-h" || "$arg" == "--help" ]] ; then
		echo "usage: ./ge-proton-shaupdate.sh options"
		echo "options:"
		echo "check - just check for a new version"
		exit
	elif [[ "$arg" = "check" ]] ; then
		justcheck="true"
	fi
done

latest_release="$(curl https://github.com/GloriousEggroll/proton-ge-custom/releases/latest | sed 's/[^0-9]*//' - | sed 's/\".*//')"

if [ "${latest_release}" != "" ] ; then
	echo "Latest Release: ${latest_release}"
	if [ "$justcheck" != "true" ] ; then
		cd /tmp || exit
		if [ ! -f /tmp/Proton-"${latest_release}".tar.gz ] ; then
			releasefolder="${latest_release}"
			releasefilename="Proton-${latest_release}.tar.gz"
			if [[ "${latest_release}" = "7-3" || "${latest_release}" = "7-8" ]] ; then
				releasefolder="GE-Proton${latest_release}"
				releasefilename="GE-Proton${latest_release}.tar.gz"
			fi
			wget "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${releasefolder}/${releasefilename}"
		fi
		echo "sha256sum: $(sha256sum /tmp/${releasefilename})"
		rm "/tmp/${releasefilename}"
	fi
else
	echo "Error determining last release"
fi
