#!/bin/sh
#
# This shell script is the entrypoint of the 'rouhim/beammp-server' docker image.
#
# It does the following:
#   1. Recreate the Server.cfg file everytime the container starts with the passed environment variables
#   2. Starts the actual BeamMP server
#
######################

# Recreate the Server.cfg. Never ever change me if you dont know!
cat <<EOF >/beammp/ServerConfig.toml
# This is the BeamMP Server Configuration File v0.60
[General]
AuthKey = "${AUTH_KEY}"               # Auth Key
Debug = ${DEBUG}                      # true or false to enable debug console output
Private = ${PRIVATE}                  # Is this a private server
Description = "${DESC}"               # Description of the server
Name = "${NAME}"                      # Name of the server
Map = "${MAP}"                        # The default map
MaxCars = ${CARS}                     # Max cars for every player
MaxPlayers = ${MAX_PLAYERS}           # Max player
Port = ${PORT}                        # Port to run the server on UDP and TCP
ResourceFolder = "/beammp/Resources"  # Resources folder
EOF

# If the additional ServerConfig.toml env variable is set
# append it
if [ -n "$ADDITIONAL_SERVER_CONFIG_TOML" ]; then
  echo "${ADDITIONAL_SERVER_CONFIG_TOML}" >>/beammp/ServerConfig.toml
fi

# If debug enabled print the whole server config
if [ -n "$DEBUG" ]; then
  echo "Content of ServerConfig.toml"
  cat /beammp/ServerConfig.toml
fi

# Start the BeamMP server executable
/beammp/beammp-server
