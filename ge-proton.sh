#!/bin/bash
available() { command -v "$1" &>/dev/null; }

if [[ "$(whoami)" == "root" ]]; then
	echo "This script should NOT be run as root or via sudo"
	echo "Please use this with your user account"
	exit 1
fi

steamcompatdir="${HOME}/.steam/steam/compatibilitytools.d"
if [[ ! -d "${HOME}/.steam/root/compatibilitytools.d" && -d "${HOME}/.local/share/Steam/compatibilitytools.d" ]]; then
	steamcompatdir="${HOME}/.local/share/Steam/compatibilitytools.d"
fi
versions_deleted=0

get_latest_release() {
	curl -s https://github.com/GloriousEggroll/proton-ge-custom/releases/latest -I | grep "location:" | sed 's/[^0-9]*//' | tr -d '\r'
}

print_usage() {
	echo "usage: ./ge-proton.sh command"
	echo "examples:"
	echo "./ge-proton.sh -i --install  download and install newest ge proton"
	echo "./ge-proton.sh -h --help     shows this help"
	echo "./ge-proton.sh -c --cleanup  delete old proton versions"
}

download_proton() {
	local gerelease="$1"
	local releasefolder="GE-Proton${gerelease}"
	local releasehash="GE-Proton${gerelease}.sha512sum"
	local releasefilename="GE-Proton${gerelease}.tar.gz"

	cd /tmp || exit
	if [[ ! -f "/tmp/${releasehash}" ]]; then
		wget "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${releasefolder}/${releasehash}"
	fi
	gechecksum=$(awk '{print $1;}' "/tmp/${releasehash}")
	rm "/tmp/${releasehash}"

	if [[ -z "$gechecksum" ]]; then
		echo "Checksum invalid"
		exit 1
	fi
	echo "Checksum found: $gechecksum"

	if ! available wget; then
		echo "Error: please install wget first"
		exit 1
	fi

	if [[ ! -d "${steamcompatdir}/GE-Proton${gerelease}" && ! -f "${steamcompatdir}/Proton-${gerelease}.tar.gz" ]]; then
		echo "Downloading Glorious Eggroll Proton to ${steamcompatdir}..."
		cd "${steamcompatdir}" || exit 1
		local cmd_wget="wget"
		if [[ ! -f /usr/local/bin/wget || "$(readlink -f /usr/local/bin/wget)" = "/usr/bin/firejail" && -f /usr/bin/wget ]] ;then
			cmd_wget="/usr/bin/wget"
		fi
		${cmd_wget} "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${releasefolder}/${releasefilename}" -P "${steamcompatdir}" -O "Proton-${gerelease}.tar.gz"

		echo "Checksum check..."
		local hashtype="sha256sum"
		if [[ "$gechecksum" =~ ^[0-9a-fA-F]{128}$ ]]; then
			hashtype="sha512sum"
		fi
		if [[ "$("${hashtype}" "${steamcompatdir}/Proton-${gerelease}.tar.gz" | grep "${gechecksum}" -c)" -eq "1" ]]; then
			echo "Checksum ok, extracting tar.gz..."
			tar xzf "Proton-${gerelease}.tar.gz" -C "${steamcompatdir}"
			echo "Removing tar.gz file"
			rm "Proton-${gerelease}.tar.gz"
			echo "Installation complete, restart Steam now"
		else
			echo "Checksum not ok"
		fi
	else
		echo "Error: Download of Proton ${gerelease} already started or installation already done."
		if [[ ! -d "${steamcompatdir}/Proton-${gerelease}" ]]; then
			echo "Delete a broken download with this and restart:"
			echo "rm ${steamcompatdir}/Proton-${gerelease}.tar.gz"
		fi
	fi
}

cleanup_old_versions() {
	local versions=("$@")

	if [[ "${HOME}/.steam/steam/compatibilitytools.d" != "$steamcompatdir" && "${HOME}/.local/share/Steam/compatibilitytools.d" != "$steamcompatdir" ]]; then
		echo "invalid steamcompatdir"
		exit 1
	fi

	for version in "${versions[@]}"; do
		# Skip if version is empty or contains '/' or '.'
		if [[ -z "$version" || "$version" == */* || "$version" == *.* ]]; then
			continue
		fi
		if [[ -d "${steamcompatdir}/${version}" ]]; then
			echo "${version} found, deleting..."
			rm -Rdf "${steamcompatdir:?}/${version:?}" && ((versions_deleted++))
		fi
	done
}

main() {
	case $1 in
		-i|--install)
			local gerelease
			gerelease=$(get_latest_release)
			if [[ -z "$gerelease" ]]; then
				echo "Error determining last release"
				exit 1
			fi
			echo "Latest Release: $gerelease"
			download_proton "$gerelease"
			;;
		-c|--cleanup)
			for tmpProtonVer in Proton-{5,6}.{1,2,3,4,5,6,7,8,9}{,1,2,3,4,5,6,7,8,9,0}-GE-{1,2,3,4,5,6,7,8,9}{,-ST,-MF} ; do
				cleanup_old_versions "${tmpProtonVer}"
			done
			for tmpProtonVer in GE-Proton7-{1,2,3,4,5,6,7,8,9}{,1,2,3,4,5,6,7,8,9,0} ; do
				cleanup_old_versions "${tmpProtonVer}"
			done
			for tmpProtonVer in GE-Proton9-{1,2,3,4,5,6,7,8,9} ; do
				cleanup_old_versions "${tmpProtonVer}"
			done
			for tmpProtonVer in GE-Proton9-1{,1,2,3,4,5,6,7,8,9,0} ; do
				cleanup_old_versions "${tmpProtonVer}"
			done
			local oldversions=(
			"Proton-6.9-GE-2-github-actions-test" "Proton-7.0rc2-GE-1" "Proton-7.0rc6-GE-1" "Proton-7.1-GE-2" "Proton-7.2-GE-2"
			"GE-Proton8-1" "GE-Proton8-3" "GE-Proton8-4" "GE-Proton8-6" "GE-Proton8-9" "GE-Proton8-11" "GE-Proton8-13" "GE-Proton8-15"
			"GE-Proton8-22" "GE-Proton8-25" "GE-Proton8-32" "GE-Proton9-1" "GE-Proton9-2" "GE-Proton9-3" "GE-Proton9-4" "GE-Proton9-5"
			"GE-Proton9-6" "GE-Proton9-7" "GE-Proton9-8" "GE-Proton9-9" "GE-Proton9-10" "GE-Proton9-11" "GE-Proton9-12"
		)
		cleanup_old_versions "${oldversions[@]}"
		if [ "$versions_deleted" == "0" ]; then
			echo "no versions found for deletion"
		else
			echo "$versions_deleted old versions deleted"
		fi
		;;
	-h|--help)
		print_usage
		exit 0
		;;
	*)
		echo "Error: Unknown operation"
		print_usage
		exit 1
		;;
esac
}

main "$@"
