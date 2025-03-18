#!/bin/bash
workdir="$(cd "$(dirname "$0")" && pwd -P)"
"${workdir}/../ui-install.sh" -f amd intel nvidia
