#!/bin/bash
#
# Description:
#     This script tests the beammp-server container image.
#
# Example usage:
#     ./test-image.sh
#
# Environment variables:
#     BEAMMP_AUTH_KEY: The auth key to use for the BeamMP server.
#
##################

# Spin up a BeamMP server
echo "🚀 Spinning up a test container"
sed -i "s/BEAMMP_AUTH_KEY=.*/BEAMMP_AUTH_KEY=${BEAMMP_AUTH_KEY}/g" .env
docker-compose up -d

# Loop until the string is found
echo "🔍 Checking for the desired string in the logs..."
while true; do
  # Check if the desired string is in the logs
  if docker-compose logs | grep -q "ALL SYSTEMS STARTED SUCCESSFULLY, EVERYTHING IS OKAY"; then
    echo "✅ Dedicated server started successfully"
    break
  fi

  echo "📃 Desired string not found in the logs, printing the last 5 lines of the logs:"
  echo "========================================"
  docker-compose logs --tail 5
  echo "========================================"

  echo "⏳ Waiting for 1 seconds before checking again..."
  sleep 1
done

# Cleanup and exit with 0
docker-compose kill && docker-compose down --volumes
echo "✅ Done, everything looks good"
exit 0
