#!/bin/bash

if [ "$(mount | grep ' on / type btrfs' -c)" = "1" ] ; then
	echo "### BTRFS detected, running optimizations"
	if [ "$(mount | grep 'on /home' -c)" = "0" ] ; then
		echo "### BTRFS: running optimizations in /home"
		for loopdir in /home/*; do
			loopuser="${loopdir/\/home\//}"
			if [ "${loopdir}" = "/home/${loopuser}" ]; then
				realuser="$(grep "${loopuser}:" /etc/passwd -c)"
				if [ "$realuser" = "1" ] ; then
					echo "### optimizing for user ${loopuser}"
					# Winetricks Default Directory for Wine Bottles
					if [ ! -d "${loopdir}/.local/share/wineprefixes" ] ; then
						mkdir -p "${loopdir}/.local/share/wineprefixes"
						chown "${loopuser}" "${loopdir}/.local/"
						chown "${loopuser}" "${loopdir}/.local/share/"
						chown "${loopuser}" "${loopdir}/.local/share/wineprefixes"
					fi
					chattr +C -R "${loopdir}/.local/share/wineprefixes"
					# default ~/.cache directory
					if [ ! -d "${loopdir}/.cache" ] ; then
						mkdir "${loopdir}/.cache"
						chown "${loopuser}" "${loopdir}/.cache"
					fi
					chattr +C -R "${loopdir}/.cache"
					# Lutris default Game Directory
					if [ ! -d "${loopdir}/Games" ] ; then
						mkdir "${loopdir}/Games"
						chown "${loopuser}" "${loopdir}/Games"
					fi
					chattr +C -Rf "${loopdir}/Games"
					# Nvidia GL Cache
					if [ ! -d "${loopdir}/.nv/GLCache" ] ; then
						mkdir -p "${loopdir}/.nv/GLCache"
						chown "${loopuser}" "${loopdir}/.nv"
						chown "${loopuser}" "${loopdir}/.nv/GLCache"
					fi
					chattr +C -R "${loopdir}/.nv/GLCache"
					# Flatpak .var/app
					if [ ! -d "${loopdir}/.var/app" ] ; then
						mkdir -p "${loopdir}/.var/app"
						chown "${loopuser}" "${loopdir}/.var"
						chown "${loopuser}" "${loopdir}/.var/app"
					fi
					chattr +C -R "${loopdir}/.var/app"
					# Steam Default Directory for Downloads, etc.
					if [ ! -d "${loopdir}/.steam" ] ; then
						mkdir "${loopdir}/.steam"
						chown "${loopuser}" "${loopdir}/.steam"
					fi
					# less error messages (-f), since there are a lot of symlinks
					chattr +C -Rf "${loopdir}/.steam"
					# Steam Default Directory for Downloads, etc.
					if [ ! -d "${loopdir}/.local/share/Steam" ] ; then
						mkdir "${loopdir}/.local/share/Steam"
						chown "${loopuser}" "${loopdir}/.local/share/Steam"
					fi
					# less error messages (-f), since there are probably a lot of symlinks
					chattr +C -Rf "${loopdir}/.local/share/Steam"
				fi
			else
				echo "### Error: Folder ${loopdir} ignored: is it not in /home/ ?"
			fi
		done
	fi
	# arch pkg cache
	if [ -d "/var/cache/pacman/pkg" ] ; then
		echo "### BTRFS: running pacman cache optimization"
		chattr +C -R /var/cache/pacman/pkg
	fi
	# debian/ ubuntu apt cache
	if [ -d "/var/cache/apt" ] ; then
		echo "### BTRFS: running apt cache optimization"
		chattr +C -R /var/cache/apt
	fi
fi
