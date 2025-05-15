####################
#   Build Image    #
####################
FROM debian:bookworm-slim AS builder

# Prepare environment
RUN mkdir /work
WORKDIR /work

# Install curl for downloading the latest release
RUN apt-get update && \
    apt-get install -y curl jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Detect the latest release version (expect pre-releases)
# AND Download "BeamMP-Server.$CURRENT_OS.$ARCH"
# Where arch is either x86_64 or arm64
# And download to current dir as "BeamMP-Server"
RUN set -eux; \
    LATEST_VERSION=$(curl -s https://api.github.com/repos/BeamMP/BeamMP-Server/releases/latest | jq -r .tag_name) && \
    BASE_OS=$(awk -F= '/^ID=/{gsub(/"/,""); print $2}' /etc/os-release || echo debian) && \
    BASE_VERSION=$(awk -F= '/^VERSION_ID=/{gsub(/"/,""); print $2}' /etc/os-release || echo 12) && \
    CURRENT_ARCH=$(uname -m | sed 's/aarch64/arm64/') && \
    echo "Latest version: ${LATEST_VERSION}" && \
    DOWNLOAD_URL="https://github.com/BeamMP/BeamMP-Server/releases/download/${LATEST_VERSION}/BeamMP-Server.${BASE_OS}.${BASE_VERSION}.${CURRENT_ARCH}" && \
    echo "Downloading ${DOWNLOAD_URL}" && \
    curl -fsSL -o BeamMP-Server "${DOWNLOAD_URL}" && \
    chmod +x BeamMP-Server


# Ensure the executable is present
RUN test -f /work/BeamMP-Server
RUN test -x /work/BeamMP-Server

####################
#    Run Image     #
####################
FROM debian:bookworm-slim

# Install only required packages, clean up in same layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends liblua5.3-0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create working directory and volumes
WORKDIR /beammp
RUN mkdir -p Resources/{Server,Client}

VOLUME ["/beammp/Resources/Server", "/beammp/Resources/Client"]

# Copy the binary and entrypoint
COPY --from=builder /work/BeamMP-Server ./beammp-server
COPY entrypoint.sh .

# Create non-root user and set permissions in one layer
RUN useradd -u 1000 -M beammp && \
    chown -R beammp:beammp /beammp && \
    chmod +x /beammp/beammp-server /beammp/entrypoint.sh

USER beammp
ENTRYPOINT ["/beammp/entrypoint.sh"]

EXPOSE 30814