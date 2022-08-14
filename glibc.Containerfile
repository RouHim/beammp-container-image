####################
#   Build Image    #
####################
FROM ubuntu:22.10 AS builder
# Select branch of BeamMP to build, default is latest stable
ARG BUILD_BRANCH

# Setup required build dependencies
RUN apt update && \
    apt install -y git make cmake build-essential libboost-dev liblua5.3-dev zlib1g-dev rapidjson-dev libcurl4-openssl-dev libssl-dev

# Grab the latest released source code
RUN git clone -j$(nproc) --recurse-submodules "https://github.com/BeamMP/BeamMP-Server" /beammp
WORKDIR /beammp

# Switch to the latest tag
RUN git checkout $(git tag --sort=creatordate | tail -1)

# If BUILD_BRANCH is set, checkout the specified branch
RUN [ -n $BUILD_BRANCH ] && \
    git checkout $BUILD_BRANCH

# Ensure all git submodules are initialized
RUN git submodule update --init --recursive

# Build the server
# We have to specify the lua path manually, because it is not set correctly during apk setup
# We use Release mode to reduce binary size, improve speed and remove debug symbols automatically
# We are disabling the sentry backend as it is not needed for our custom build.
RUN cmake -DLUA_LIBRARY=/usr/lib/x86_64-linux-gnu/liblua5.3.so.0 -DCMAKE_BUILD_TYPE=Release -DSENTRY_BACKEND=none .

# Build the 'BeamMP-Server' executable using all available CPU cores
RUN make -j $(nproc)

####################
#    Run Image     #
####################
FROM ubuntu:22.10
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
RUN apt update && \
    apt install -y zlib1g liblua5.3-0 libcrypto++8 openssl libcurl4

# Copy the previously built executable
COPY --from=builder /beammp/BeamMP-Server ./beammp-server
RUN chmod +x beammp-server

# Disable package manager
RUN rm -f /sbin/apk && \
    rm -rf /etc/apk && \
    rm -rf /lib/apk && \
    rm -rf /usr/share/apk && \
    rm -rf /var/lib/apk

# Prepare user
RUN groupadd -g 1000 someone && \
    useradd -u 1000 -g 1000 -m -s /bin/bash someone
RUN chown -R someone:someone . && chmod -R 775 .

USER someone

# Specify entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
