#!/bin/bash
workdir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
"${workdir}"/promod/install_promod.sh && "${workdir}"/replay-manager/install_replay-manager.sh
