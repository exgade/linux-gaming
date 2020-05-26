#!/bin/bash
# Installer to get oldskools promod working and updated in world of tanks installed by lutris
lutrisPath="$(grep game_path "${HOME}/.config/lutris/system.yml" | sed "s/\s\sgame_path: //" -)/"
wotprefix="${lutrisPath}world-of-tanks/"
wotfolder="${wotprefix}drive_c"

for folder in ${wotfolder}/Games/World_of_Tanks_EU/mods/1.* ; do 
	newfolder="$(echo $folder | sed 's/\/mods\//\/mods_deactivated\//g' -)"
	echo "creating Folder: $newfolder/oldskool"
	mkdir -p "$newfolder/oldskool"
	if compgen -G "$newfolder/oldskool/oldskool.autoEquipment*" > /dev/null ; then
		echo "moving Addon autoEquipment from $newfolder to $folder"
		mv "$newfolder"/oldskool/oldskool.autoEquipment* "$folder/oldskool/"
	fi
	if compgen -G "$newfolder/oldskool/oldskool.crewReturn*" > /dev/null ; then
		echo "moving Addon crewReturn from $newfolder to $folder"
		mv "$newfolder"/oldskool/oldskool.crewReturn* "$folder/oldskool/"
	fi
done
