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

echo "WARNING: This will clear all heavyweight Cached Files, press Enter to continue or STRG+C to abort"
read

rm -Rdf "${wotfolder}"/users/[a-zA-Z-]*/Application\ Data/Wargaming.net/WorldOfTanks/web_cache/*
rm -Rdf "${wotfolder}"/users/[a-zA-Z-]*/Application\ Data/Wargaming.net/WorldOfTanks/profile/cef_cache

echo "WARNING: Now all replays will be deleted, if you continue with ENTER"
read

rm "$wotfolder"/Games/World_of_Tanks_EU/replays/*

echo "deletion complete"
