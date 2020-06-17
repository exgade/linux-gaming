#!/bin/bash
# Installer to get oldskools promod working and updated in world of tanks installed by lutris
lutrisPath="$(grep game_path "${HOME}/.config/lutris/system.yml" | sed "s/\s\sgame_path: //" -)/"
wotprefix="${lutrisPath}world-of-tanks/"
wotfolder="${wotprefix}drive_c"
winefolder="${HOME}/.local/share/lutris/runners/wine/lutris-5.6-2-x86_64/"
wotversion="1.9.1.1"
modversion="3.4.9"
if [ -f "${winefolder}dist/bin/wine" ] ; then
	# define wine executable for proton wine
	wineexec="${winefolder}dist/bin/wine"
elif [ -f "${winefolder}bin/wine" ] ; then
	# define wine executable for lutris wine
	wineexec="${winefolder}bin/wine"
else
	echo "unknown wine folder - please select an lutris or steam wine folder"
	exit
fi

if [ ! -d "${wotfolder}" ] ; then
	wotfolder="$(grep -h -m1 prefix "${HOME}/.config/lutris/games/world-of-tanks*.yml" | head -n1 | sed "s/\s\sprefix: //" -)"
	if [ ! -d "${wotfolder}" ] ; then
		echo "problem detecting world of tanks folder, aborting"
		exit
	fi
fi
if [ ! -d "${wotfolder}/Games/World_of_Tanks_EU/" ] ; then
	echo "problem detecting world of tanks folder, aborting"
	exit
fi

cd "${wotfolder}/Games/World_of_Tanks_EU/" || exit
if [ -f "${wotversion}_ReplaysManager_${modversion}.zip" ] ; then
	rm "${wotversion}_ReplaysManager_${modversion}.zip"
fi
wget "https://modp.wgcdn.co/media/mod_files/${wotversion}_ReplaysManager_${modversion}.zip"
unzip -o "${wotversion}_ReplaysManager_${modversion}.zip"


