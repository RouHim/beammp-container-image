#!/bin/bash
#
# Description:
#     This script tests the beammp-server docker image
#
##################
# abort with code 1 on any failure
set -e

# Function to
cleanup() {
  docker kill test-container
}

# Spin up a BeamMP server
docker run -d --name test-container -e AUTH_KEY='c651d053-f8f3-4d25-b8d8-8fc4b02a60e1' rouhim/beammp-server

# Wait some time
sleep 10

# Test successful authentication
docker logs test-container | grep -i "authenticated"
if [ "$?" -ne "0" ]; then
  echo "Could not authenticate:"
  docker logs test-container && docker kill test-container
  exit 1
fi

# Test for errors in log
docker logs test-container | grep -i "[ERROR]"
if [ "$?" -ne "0" ]; then
  echo "Found errors in server.log:"
  docker logs test-container && docker kill test-container
  exit 1
fi

cleanup
exit 0
