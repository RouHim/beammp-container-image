#!/bin/sh

# Make the server folder read and writable, hide error log
chmod 777 -R /beammp/ 2> /dev/null

# Start the BeamMP server executable
/beammp/beammp-server
