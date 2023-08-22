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

latest_release="$(curl https://github.com/GloriousEggroll/proton-ge-custom/releases/latest -I | grep "location:" | sed 's/[^0-9]*//' | sed 's/\".*//' | tr -d '\r' )"

if [ "${latest_release}" != "" ] ; then
	echo "Latest Release: ${latest_release}"
	if [ "$justcheck" != "true" ] ; then
		cd /tmp || exit
		releasefolder="GE-Proton${latest_release}"
		releasehash="GE-Proton${latest_release}.sha512sum"
		if [ ! -f "/tmp/${releasehash}" ] ; then
			wget "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${releasefolder}/${releasehash}"
		fi
		echo "sha512sum: $(cat "/tmp/${releasehash}")"
		rm "/tmp/${releasehash}"
	fi
else
	echo "Error determining last release"
fi
