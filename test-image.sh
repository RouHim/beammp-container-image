#!/bin/bash
#
# Description:
#     This script tests the beammp-server container image
#
##################

# Spin up a BeamMP server
echo "🚀 Spinning up a test container"
podman run -d --name test-container -e AUTH_KEY="$BEAMMP_AUTH_KEY" "$1"

# Wait some time
echo "😴 sleeping 10 seconds"
sleep 10

# Test for errors in log
echo "🧪 Testing for errors"
podman logs test-container | grep -i 'error'
if [ "$?" -eq 0 ]; then
  echo "❌ Found errors in server log:"
  echo "======================"
  podman logs test-container
  echo "======================"
  podman stop test-container && podman rm test-container
  exit 1
fi

# Cleanup and exit with 0
podman stop test-container && podman rm test-container
echo "✅ Done, everything looks good"
exit 0
