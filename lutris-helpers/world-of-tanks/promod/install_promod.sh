#!/bin/bash
# Installer to get oldskools promod working and updated in world of tanks installed by lutris
lutrisPath="$(grep "game_path" "${HOME}"/.config/lutris/system.yml | sed "s/\s\sgame_path: //" -)/"
wotprefix="${lutrisPath}world-of-tanks/"
wotfolder="${wotprefix}drive_c"
wineversion="$(grep -h -m1 "version:" "$HOME"/.config/lutris/games/world-of-tanks*.yml | sed "s/\s\sversion: //g" -)"
if [[ "$wineversion" = "" || "$(echo "${wineversion}" | sed "s/lutris-[0-9]\.[0-9]-[0-9]-x86_64//g" -)" != "" ]] ; then
	echo "problem detecting wine version"
	wineversion="lutris-5.6-2-x86_64"
fi
winefolder="${HOME}/.local/share/lutris/runners/wine/${wineversion}/"
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
	wotfolder="$(grep -h -m1 "prefix" "${HOME}"/.config/lutris/games/world-of-tanks*.yml | head -n1 | sed "s/\s\sprefix: //" -)"
	if [ ! -d "${wotfolder}" ] ; then
		echo "problem detecting world of tanks folder, aborting"
		exit
	fi
fi

cd "${wotfolder}"
if [ -f "ProMod.zip" ] ; then
	rm ProMod.zip
fi
wget https://www.oldskool.vip/promod/ProMod.zip
if [ -f ProMod.exe ] ; then
	unzip -fo ProMod.zip
else
	unzip ProMod.zip
fi
WINEPREFIX="${wotprefix}" "${wineexec}" ProMod.exe

echo "deactivating reserve feature from wot"
sed -i "s/    remove |= not filters\[PREFS.RESERVE\]/    #remove \|= not filters[PREFS.RESERVE]/g" "${wotfolder}/Games/World_of_Tanks_EU/res_mods/mods/xfw_packages/xvm_tankcarousel/python/filter_popover.py"
sed -i "s/    remove |= filters\[PREFS.RESERVE\]/    #remove \|= filters[PREFS.RESERVE]/g" "${wotfolder}/Games/World_of_Tanks_EU/res_mods/mods/xfw_packages/xvm_tankcarousel/python/filter_popover.py"
