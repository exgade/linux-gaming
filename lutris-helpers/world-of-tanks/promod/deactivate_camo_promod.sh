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

for folder in ${wotfolder}/Games/World_of_Tanks_EU/mods/1.* ; do 
	newfolder="$(echo $folder | sed 's/\/mods\//\/mods_deactivated\//g' -)"
	echo "creating Folder: $newfolder/oldskool"
	mkdir -p "$newfolder/oldskool"
	if compgen -G "$folder/oldskool/oldskool.autoEquipment*" > /dev/null ; then
		echo "moving Addon autoEquipment from $folder to $newfolder"
		mv "$folder"/oldskool/oldskool.autoEquipment* "$newfolder/oldskool/"
	fi
	if compgen -G "$folder/oldskool/oldskool.crewReturn*" > /dev/null ; then
		echo "moving Addon crewReturn from $folder to $newfolder"
		mv "$folder"/oldskool/oldskool.crewReturn* "$newfolder/oldskool/"
	fi
done
