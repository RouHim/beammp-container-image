####################
#   Build Image    #
####################
FROM docker.io/ubuntu:24.04 AS builder

RUN mkdir -p /work
WORKDIR /work

# Detect the latest release version (expect pre-releases)
# AND Download "BeamMP-Server.ubuntu.22.04.$ARCH"
# Where arch is either x86_64 or arm64
# And download to current dir as "BeamMP-Server"
#RUN export LATEST_VERSION=$(curl -s https://api.github.com/repos/BeamMP/BeamMP-Server/releases/latest | grep "tag_name" | cut -d '"' -f 4) && \
#    export CURRENT_ARCH=$(uname -m) && \
#    export CURRENT_OS="ubuntu.22.04" && \
#    export DOWNLOAD_URL="https://github.com/BeamMP/BeamMP-Server/releases/download/$LATEST_VERSION/BeamMP-Server.$CURRENT_OS.$CURRENT_ARCH" && \
#    echo "Downloading $DOWNLOAD_URL" && \
#    curl -L -o BeamMP-Server $DOWNLOAD_URL

# As a temporary workaround, copy the binary instead of downloading it
COPY BeamMP-Server ./BeamMP-Server
RUN chmod +x BeamMP-Server

####################
#    Run Image     #
####################
FROM docker.io/ubuntu:24.04
LABEL maintainer="Rouven Himmelstein rouven@himmelstein.info"

## Game server parameter and their defaults
ENV DEBUG "false"
ENV PRIVATE "true"
ENV PORT "30814"
ENV CARS "1"
ENV MAX_PLAYERS "10"
ENV MAP "/levels/gridmap_v2/info.json"
ENV NAME "BeamMP New Server"
ENV DESC "BeamMP Default Description"
ENV AUTH_KEY ""
ENV ADDITIONAL_SERVER_CONFIG_TOML ""

# Create game server folder
RUN mkdir -p /beammp/Resources/Server /beammp/Resources/Client
WORKDIR /beammp

# Install game server required packages
# and disable clean up to reduce image size
RUN apt update && apt upgrade -y && \
    apt install -y liblua5.3-0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the previously downloaded executable
COPY --from=builder /work/BeamMP-Server ./beammp-server

# Prepare user
RUN groupadd -r beammp && \
    useradd -r -g beammp beammp && \
    chown -R beammp:beammp . && chmod -R 775 .
USER beammp

# Specify entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
