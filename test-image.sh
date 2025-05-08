#!/bin/bash
#
# Description:
#     This script tests the beammp-server container image.
#
# Example usage:
#     ./test-image.sh latest
#
# Environment variables:
#     BEAMMP_AUTH_KEY: The auth key to use for the BeamMP server.
#
# Parameter:
#     $1: The version of the image to test. If not provided, it defaults to "latest".
#
##################
set -e

image_name="rouhim/beammp-server"
image_tag="${1:-latest}"
image="$image_name:$image_tag"

# Kill all previous containers
echo "🛑 Removing old test containers"
docker kill test-container || true
docker rm test-container || true

# Spin up a BeamMP server
echo "🚀 Spinning up a test container"
docker run -d --name test-container -e BEAMMP_AUTH_KEY="$BEAMMP_AUTH_KEY" "$image"

# Loop until the string is found
echo "🔍 Checking for the desired string in the logs..."
EXPECTED_STRING="ALL SYSTEMS STARTED SUCCESSFULLY, EVERYTHING IS OKAY"
while true; do
  # Check if the desired string is in the logs
  if docker logs test-container | grep -q "$EXPECTED_STRING"; then
    echo "✅ Server started successfully"
    break
  fi

  echo "📃 Desired string not found in the logs, printing the last 5 lines of the logs:"
  echo "========================================"
  docker logs test-container --tail 5
  echo "========================================"

  echo "⏳ Waiting for 1 seconds before checking again..."
  sleep 1
done

# Cleanup and exit with 0
docker kill test-container && docker rm test-container
echo "✅ Done, everything looks good"
exit 0
