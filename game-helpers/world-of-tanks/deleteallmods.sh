#!/bin/bash
# Installer to get oldskools promod working and updated in world of tanks installed by lutris
lutrisPath="${HOME}"/Games/
if [ "$(grep "game_path" "${HOME}"/.config/lutris/system.yml | wc -l)" = "1" ] ; then
	lutrisPath="$(grep "game_path" "${HOME}"/.config/lutris/system.yml | sed "s/\s\sgame_path: //" -)/"
fi
if [ ! -d "${lutrisPath}" ] ; then
	echo "Problem detecting Lutris Path, aborting..."
	exit
fi
wotprefix="${lutrisPath}world-of-tanks/"
wotfolder="${wotprefix}drive_c"
wotversion="$(grep "<version>" "$wotfolder/Games/World_of_Tanks_EU/version.xml" | awk '{print $2}' | sed "s/v\.//" -)"
if [[ "${wotversion}" = "" || "$(echo $wotversion | sed "s/[0-9]\.[0-9]\(\|[0-9]\)\.[0-9]\.[0-9]//g" -)" != "" ]] ; then
	echo "error determining wot version"
	exit
fi

echo "WARNING: This will clear all your Mod Files, press Enter to continue or STRG+C to abort"
read

rm -Rdf ${wotfolder}/Games/World_of_Tanks_EU/mods
rm -Rdf ${wotfolder}/Games/World_of_Tanks_EU/res_mods
mkdir -p ${wotfolder}/Games/World_of_Tanks_EU/mods/"${wotversion}"
mkdir -p ${wotfolder}/Games/World_of_Tanks_EU/res_mods/"${wotversion}"

echo "deletion complete"
