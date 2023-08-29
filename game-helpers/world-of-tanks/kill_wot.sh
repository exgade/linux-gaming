#!/usr/bin/bash
killedany="false"

killall WorldOfTanks.exe 2> /dev/null && echo "killed all WorldOfTanks.exe Applications" && killedany="true"
killall WargamingErrorMonitor.exe 2> /dev/null && echo "killed all WargamingErrorMonitor.exe Applications" && killedany="true"
killall wgc.exe 2> /dev/null && echo "killed all wgc.exe Applications" && killedany="true"
killall wgc_renderer.exe 2> /dev/null && echo "killed all wgc_renderer.exe Applications" && killedany="true"

if (pgrep WorldOfTanks > /dev/null); then
	kill -9 "$(pgrep WorldOfTanks)" && echo "killed all applications with WorldOfTanks in name with -9" && killedany="true"
fi
if (pgrep WargamingErrorMonitor > /dev/null); then
	kill -9 "$(pgrep WargamingErrorMonitor)" && echo "killed all applications with WargamingErrorMonitor in name with -9" && killedany="true"
fi
if (pgrep wgc.exe > /dev/null); then
	kill -9 "$(pgrep wgc.exe)" && echo "killed all applications with wgc.exe in name with -9" && killedany="true"
fi
if (pgrep wgc_renderer > /dev/null); then
	kill -9 "$(pgrep wgc_renderer)" && echo "killed all applications with wgc_renderer in name with -9)" && killedany="true"
fi

if [ "${killedany}" = "true" ] ; then
	echo "successfully killed processes"
else
	echo "there was no need to kill processes"
fi

