####################
#   Build Image    #
####################
FROM docker.io/alpine:3 AS builder
# Select branch of BeamMP to build, default is latest stable
ARG BUILD_BRANCH

# Setup required build dependencies
RUN apk update && \
    apk add --no-cache git make cmake g++ boost-dev lua5.3-dev zlib-dev rapidjson-dev curl-dev openssl-dev

# Grab the latest released source code
RUN git clone -j$(nproc) --recurse-submodules "https://github.com/BeamMP/BeamMP-Server" /beammp
WORKDIR /beammp

# Switch to the latest tag
RUN git checkout $(git tag --sort=creatordate | tail -1)

# If BUILD_BRANCH is set, checkout the specified branch
RUN if [ -z "$BUILD_BRANCH" ]; \
    then \
        echo "No build branch defined, working on:"; \
        git tag --sort=creatordate | tail -1; \
    else \
        echo "Build branch is set to: $BUILD_BRANCH"; \
        git checkout "$BUILD_BRANCH"; \
    fi

# Ensure all git submodules are initialized
RUN git submodule update --init --recursive

# Build the server
# We have to specify the lua path manually, because it is not set correctly during apk setup
# We use Release mode to reduce binary size, improve speed and remove debug symbols automatically
# We are disabling the sentry backend as it is not needed for our custom build.
RUN cmake -DLUA_LIBRARY=/usr/lib/lua5.3/liblua.so -DCMAKE_BUILD_TYPE=Release -DSENTRY_BACKEND=none -DBUILD_TESTS=OFF .

# Build the 'BeamMP-Server' executable using all available CPU cores
RUN make -j $(nproc)

####################
#    Run Image     #
####################
FROM docker.io/alpine:3
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
RUN apk update && \
    apk add --no-cache zlib lua5.3 libcrypto1.1 openssl libcurl libstdc++

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
RUN addgroup -g 1000 -S beammp && adduser -u 1000 -S beammp -G beammp
RUN chown -R beammp:beammp . && chmod -R 775 .
USER beammp

# Specify entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]