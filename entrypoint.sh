#!/bin/sh
#
# This shell script is the entrypoint of the 'rouhim/beammp-server' docker image.
#
# It does the following:
#   1. Recreate the Server.cfg file everytime the container starts with the passed environment variables
#   2. Adjust the permissions, to enable non-root-docker user to modify server files.
#   3. Starts the actual beammp server
#
######################

# Recreate the Server.cfg. Never ever change me if you dont know!
cat <<EOF >/beammp/Server.cfg
# This is the BeamMP Server Configuration File v0.60
Debug = ${DEBUG} # true or false to enable debug console output
Private = ${PRIVATE} # Private?
Port = ${PORT} # Port to run the server on UDP and TCP
Cars = ${CARS} # Max cars for every player
MaxPlayers = ${MAX_PLAYERS} # Maximum Amount of Clients
Map = "${MAP}" # Default Map
Name = "${NAME}" # Server Name
Desc = "${DESC}" # Server Description
use = "${USE}" # Resource file name
AuthKey = "${AUTH_KEY}" # Auth Key
EOF

# Adjust the server files permissions
chown -R "$GID":"$UID" /beammp

# Start the beammp server executable
exec /beammp/beammp-server