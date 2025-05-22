#!/usr/bin/env bash
# Description:
#   This script downloads the latest or pre-release version of the BeamMP server
#
# Parameter:
#   First parameter $1 is either true or false - wether to download the latest or pre-release version
#
# Example:
#   ./download-beammp-server.sh true
#
#
set -e
PRE_RELEASE=$1

# Ensure that the first parameter is either true or false
if [ "$PRE_RELEASE" != "true" ] && [ "$PRE_RELEASE" != "false" ]; then
    echo "First parameter must be set and either true or false"
    exit 1
fi

# if pre release download from /latest otherwise from /releases
if [ "$PRE_RELEASE" = "true" ]; then
    LATEST_VERSION=$(curl -s https://api.github.com/repos/BeamMP/BeamMP-Server/releases | grep -m 1 "tag_name" | cut -d '"' -f 4)
    OS_VERSION="ubuntu.24.04"
else
    LATEST_VERSION=$(curl -s https://api.github.com/repos/BeamMP/BeamMP-Server/releases/latest | grep -m 1 "tag_name" | cut -d '"' -f 4)
    OS_VERSION="ubuntu.22.04"
fi

CURRENT_ARCH=$(uname -m | sed s/aarch64/arm64/g)
DOWNLOAD_URL="https://github.com/BeamMP/BeamMP-Server/releases/download/$LATEST_VERSION/BeamMP-Server.$OS_VERSION.$CURRENT_ARCH"

echo "Downloading $DOWNLOAD_URL"
curl -L -o BeamMP-Server "$DOWNLOAD_URL"

chmod +x BeamMP-Server

# Verify that the downloaded file is present and executable
if [ ! -f "BeamMP-Server" ]; then
    echo "Error: BeamMP-Server file not found!"
    exit 1
fi
if [ ! -x "BeamMP-Server" ]; then
    echo "Error: BeamMP-Server file is not executable!"
    exit 1
fi
