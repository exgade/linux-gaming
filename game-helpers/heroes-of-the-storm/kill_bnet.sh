#!/bin/bash

killedprocess="false"
if [ "$(killall HeroesOfTheStorm_x64.exe 2>&1)" == "" ] ; then
	killedprocess="true"
fi
if [ "$(killall Battle.net.exe 2>&1)" == "" ] ; then
	killedprocess="true"
fi
if [ "$(killall Agent.exe 2>&1)" == "" ] ; then
	killedprocess="true"
fi
if [ "$killedprocess" = "true" ] ; then
	echo "Prozesse erfolgreich beendet"
else
	echo "No need to kill any processes"
fi
