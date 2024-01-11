####################
#   Build Image    #
####################
FROM docker.io/ubuntu:24.04 AS builder
# Select branch of BeamMP to build, default is latest stable
ARG BUILD_BRANCH

# Setup required build dependencies
RUN apt update && \
    apt install -y git build-essential cmake liblua5.3-dev curl zip unzip tar ninja-build libboost-all-dev zlib1g-dev

# Grab the latest released source code
RUN git clone -j$(nproc) --recurse-submodules "https://github.com/BeamMP/BeamMP-Server" /beammp
WORKDIR /beammp

# Switch to the latest tag
RUN git checkout $(curl -s https://api.github.com/repos/BeamMP/BeamMP-Server/releases/latest | grep "tag_name" | cut -d '"' -f 4)

# If BUILD_BRANCH is set, checkout the specified branch
RUN if [ -z "$BUILD_BRANCH" ]; \
    then \
        echo "No build branch defined, working on:"; \
        git describe --tags --abbrev=0; \
    else \
        echo "Build branch is set to: $BUILD_BRANCH"; \
        git checkout "$BUILD_BRANCH"; \
    fi

# Ensure all git submodules are initialized
RUN git submodule update --init --recursive

# Build the server
# We use Release mode to reduce binary size, improve speed and remove debug symbols automatically
ENV VCPKG_FORCE_SYSTEM_BINARIES 1
ENV VCPKG_DISABLE_METRICS 1
RUN ./vcpkg/bootstrap-vcpkg.sh
RUN cmake . -B bin \
    -DCMAKE_TOOLCHAIN_FILE=./vcpkg/scripts/buildsystems/vcpkg.cmake \
    -DCMAKE_BUILD_TYPE=Release

# Build the 'BeamMP-Server' executable
RUN cmake --build bin --parallel -t BeamMP-Server
RUN strip bin/BeamMP-Server

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
RUN apt update && \
    apt install -y liblua5.3-0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the previously built executable
COPY --from=builder /beammp/bin/BeamMP-Server ./beammp-server

# Prepare user
RUN groupadd -r beammp && \
    useradd -r -g beammp beammp && \
    chown -R beammp:beammp . && chmod -R 775 .
USER beammp

# Specify entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
