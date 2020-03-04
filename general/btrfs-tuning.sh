#!/bin/bash

if [ "`mount | grep ' on / type btrfs' | wc -l`" = "1" ] ; then
	if [ "`mount | grep 'on /home' | wc -l`" = "0" ] ; then
	echo "### BTRFS detected, running optimizations"
		for loopdir in /home/*; do
			loopuser="${loopdir/\/home\//}"
			if [ "${loopdir}" = "/home/${loopuser}" ]; then
				realuser="`cat /etc/passwd | grep \"${loopuser}:\" | wc -l`"
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
					# Steam Default Directory for Downloads, etc.
					if [ ! -d "${loopdir}/.steam" ] ; then
						mkdir "${loopdir}/.steam"
						chown "${loopuser}" "${loopdir}/.steam"
					fi
					# less error messages (-f), since there are a lot of symlinks
					chattr +C -Rf "${loopdir}/.steam"
				fi
			else
				echo "### Error: Folder ${loopfolder} ignored: is it not in /home/ ?"
			fi
		done
	fi
	# arch pkg cache
	if [ -d "/var/cache/pacman/pkg" ] ; then
		chattr +C -R /var/cache/pacman/pkg
	fi
	# debian/ ubuntu apt cache
	if [ -d "/var/cache/apt" ] ; then
		chattr +C -R /var/cache/apt
	fi
fi
