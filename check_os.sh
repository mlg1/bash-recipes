#!/bin/bash
#
# Description: Checks the name and version of the distribution.
# Author: Nedelin Petkov
# Version: 0.1
#
# Exit codes:
# 0 - OK
# 1 - Error

OS_RELEASE="/etc/os-release"

# If os-release file not exist exit with error code
if [ ! -f "$OS_RELEASE" ]; then
	exit 1
fi

# Load os-release file
source $OS_RELEASE

# Check OS
if [ "$NAME" == "CentOS Linux" ] && [ "$VERSION_ID" == "7" ]; then
	echo '{ "os": "'$NAME'", "version": "'$VERSION_ID'" }'
	exit 0
else
	exit 1
fi
