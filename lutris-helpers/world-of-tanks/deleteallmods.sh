#!/bin/bash
# Installer to get oldskools promod working and updated in world of tanks installed by lutris
lutrisPath="$(grep game_path "${HOME}/.config/lutris/system.yml" | sed "s/\s\sgame_path: //" -)/"
wotprefix="${lutrisPath}world-of-tanks/"
wotfolder="${wotprefix}drive_c"
wotversion="$(grep "<version>" "$wotfolder/Games/World_of_Tanks_EU/version.xml" | awk '{print $2}' | sed "s/v\.//" -)"

echo "WARNING: This will clear all your Mod Files, press Enter to continue or STRG+C to abort"
read

rm -Rdf ${wotfolder}/Games/World_of_Tanks_EU/mods
rm -Rdf ${wotfolder}/Games/World_of_Tanks_EU/res_mods
mkdir -p ${wotfolder}/Games/World_of_Tanks_EU/mods/"${wotversion}"
mkdir -p ${wotfolder}/Games/World_of_Tanks_EU/res_mods/"${wotversion}"

echo "deletion complete"
