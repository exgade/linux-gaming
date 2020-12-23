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
prefix_name="world-of-tanks"
#prefix_name="world-of-warships"
wotprefix="${lutrisPath}${prefix_name}/"
wotfolder="${wotprefix}drive_c"
wineversion="$(grep -h -m1 "version:" "${HOME}/.config/lutris/games/${prefix_name}*.yml" | head -n1 | sed "s/\s\sversion: //g" -)"
systemwine="false"
#systemwine="true"
if [[ "$wineversion" = "" || "$(echo "${wineversion}" | sed "s/lutris-[0-9]\.[0-9]\(\|-[0-9]\(\|[0-9]\)\)-x86_64//g" -)" != "" ]] ; then
	echo "problem detecting wine version"
	wineversion="lutris-5.7-11-x86_64"
fi
winefolder="${HOME}/.local/share/lutris/runners/wine/${wineversion}/"
if [ "${systemwine}" = "true" ] ; then
	wineexec="wine"
elif [ -f "${winefolder}dist/bin/wine" ] ; then
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
if [ -f "xvm_latest.zip" ] ; then
	rm "xvm_latest.zip"
fi
wget "https://nightly.modxvm.com/download/master/xvm_latest.zip"
unzip -o "xvm_latest.zip"


