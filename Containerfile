####################
#   Build Image    #
####################
FROM docker.io/debian:12 AS builder

# Create empty folder
RUN mkdir -p /empty-dir

# Prepare build environment
RUN mkdir -p /work
WORKDIR /work

# Install game server required packages
RUN apt update && apt upgrade -y && \
    apt install -y liblua5.3-0 curl

# Detect the latest release version (expect pre-releases)
# AND Download "BeamMP-Server.$CURRENT_OS.$ARCH"
# Where arch is either x86_64 or arm64
# And download to current dir as "BeamMP-Server"
RUN export LATEST_VERSION=$(curl -s https://api.github.com/repos/BeamMP/BeamMP-Server/releases/latest | grep "tag_name" | cut -d '"' -f 4) && \
    export CURRENT_ARCH=$(uname -m) && \
    export CURRENT_OS="debian.12" && \
    export DOWNLOAD_URL="https://github.com/BeamMP/BeamMP-Server/releases/download/$LATEST_VERSION/BeamMP-Server.$CURRENT_OS.$CURRENT_ARCH" && \
    echo "Downloading $DOWNLOAD_URL" && \
    curl -L -o BeamMP-Server $DOWNLOAD_URL && \
    chmod +x BeamMP-Server

####################
#    Run Image     #
####################
FROM gcr.io/distroless/base-debian12:nonroot
LABEL maintainer="Rouven Himmelstein rouven@himmelstein.info"

## Game server parameter and their defaults
ENV BEAMMP_PORT "30814"
ENV BEAMMP_NAME "BeamMP New Server"
ENV BEAMMP_MAP "/levels/gridmap_v2/info.json"
ENV BEAMMP_DESC "BeamMP Default Description"
ENV BEAMMP_CARS "1"
ENV BEAMMP_MAX_PLAYERS "10"
ENV BEAMMP_PRIVATE "true"
ENV BEAMMP_DEBUG "false"
ENV BEAMMP_AUTH_KEY ""

# Create game server folder by coping the empty folder from builder
#RUN mkdir -p /beammp/Resources/Server /beammp/Resources/Client
COPY --from=builder --chown=nonroot:nonroot /empty-dir /beammp
COPY --from=builder --chown=nonroot:nonroot /empty-dir /beammp/Resources
COPY --from=builder --chown=nonroot:nonroot /empty-dir /beammp/Resources/Server
COPY --from=builder --chown=nonroot:nonroot /empty-dir /beammp/Resources/Client
WORKDIR /beammp

# Copy liblua5.3.so.0 from builder
COPY --from=builder --chown=nonroot:nonroot /usr/lib/x86_64-linux-gnu/liblua5.3.so.0 /usr/lib/x86_64-linux-gnu/liblua5.3.so.0

# Copy libstdc++.so.6 from builder
COPY --from=builder --chown=nonroot:nonroot "/usr/lib/x86_64-linux-gnu/libstdc++.so.6" "/usr/lib/x86_64-linux-gnu/libstdc++.so.6"

# Copy libgcc_s.so.1 from builder
COPY --from=builder --chown=nonroot:nonroot /usr/lib/x86_64-linux-gnu/libgcc_s.so.1 /usr/lib/x86_64-linux-gnu/libgcc_s.so.1

# Copy the previously downloaded executable
COPY --from=builder --chown=nonroot:nonroot /work/BeamMP-Server ./beammp-server

# Use nonroot user
USER nonroot

# Specify entrypoint
ENTRYPOINT ["/beammp/beammp-server"]
