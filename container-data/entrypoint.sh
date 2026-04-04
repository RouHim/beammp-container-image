#!/bin/sh

# Make the server folder read and writable, hide error log
chmod 777 -R /beammp/ 2> /dev/null

# Start the BeamMP server executable
/beammp/beammp-server

# Check if TEMP_SETTINGS_FILE is set and overwrite existing config in case such a file exists
if [ -n "${TEMP_SETTINGS_FILE+isset}" ] && [ -f "/beammp/${TEMP_SETTINGS_FILE}" ]; then
        cat "/beammp/${TEMP_SETTINGS_FILE}" > /beammp/ServerConfig.toml && rm "/beammp/${TEMP_SETTINGS_FILE}"
fi
