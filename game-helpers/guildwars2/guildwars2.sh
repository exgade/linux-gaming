#!/usr/bin/bash
echo "Warning: Work in Progress, continue with ENTER, abort with strg+c"; read
killedany="false"

killall CoherentUI_Host.exe 2> /dev/null && echo "killed all CoherentUI_Host Applications" && killedany="true"
killall GW2-64.exe 2> /dev/null && echo "killed all GW2-64 Applications" && killedany="true"

if (pgrep CoherentUI_Host > /dev/null); then
	kill -9 "$(pgrep CoherentUI_Host)" && echo "killed all applications with CoherentUI_Host in name with -9" && killedany="true"
fi
if (pgrep GW2-64 > /dev/null); then
	kill -9 "$(pgrep GW2-64)" && echo "killed all applications with GW2-64 in name with -9" && killedany="true"
fi

if [ "${killedany}" = "true" ] ; then
	echo "successfully killed processes"
else
	echo "there was no need to kill processes"
fi

