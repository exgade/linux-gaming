#!/bin/bash

#following can be added to your crontab to get notifications every hour, when there is a new ge-proton version (without # at start)
#5 * * * * /path-to/linux-gaming/build-helpers/ge-notify-update.sh

scriptdir="$(dirname "$0")"
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${UID}/bus 
checkproton="$("$scriptdir"/ge-proton-shaupdate.sh check)"
if [[ "" = "${checkproton}" ]] ; then
	echo "Version number not found"
elif [[ "Latest Release: 6.12-GE-1" = "${checkproton}" ]] ; then
	echo "Version unchanged"
else
	echo "Version changed"
	DISPLAY=:0 /usr/bin/notify-send "GE Proton has been changed"
fi
