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
wineversion="$(grep -h -m1 "version:" "$HOME"/.config/lutris/games/world-of-tanks*.yml | head -n1 | sed "s/\s\sversion: //g" -)"
if [[ "$wineversion" = "" || "$(echo "${wineversion}" | sed "s/lutris-[0-9]\.[0-9]\(\|-[0-9]\(\|[0-9]\)\)-x86_64//g" -)" != "" ]] ; then
	echo "problem detecting wine version"
	wineversion="lutris-5.6-2-x86_64"
fi
winefolder="${HOME}/.local/share/lutris/runners/wine/${wineversion}/"
wotversion="$(grep "<version>" "$wotfolder/Games/World_of_Tanks_EU/version.xml" | awk '{print $2}' | sed "s/v\.//" -)"
if [[ "${wotversion}" = "" || "$(echo $wotversion | sed "s/[0-9]\.[0-9]\(\|[0-9]\)\.[0-9]\.[0-9]//g" -)" != "" ]] ; then
	echo "error determining wot version"
	exit
fi
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


