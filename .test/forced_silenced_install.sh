#!/bin/bash
workdir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
"${workdir}/../ui-install.sh" -f amd intel nvidia
