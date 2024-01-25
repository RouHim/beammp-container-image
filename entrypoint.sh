#!/bin/sh

echo ""
echo "⚠️ Your server does not start? There was a breaking change in the container image. Please follow this link: ⚠️"
echo "https://github.com/RouHim/beammp-container-image#%EF%B8%8F-breaking-change-and-migration-guide-%EF%B8%8F"
echo ""

# Make the server folder read and writable, hide error log
chmod 777 -R /beammp/ 2> /dev/null

# Start the BeamMP server executable
/beammp/beammp-server
