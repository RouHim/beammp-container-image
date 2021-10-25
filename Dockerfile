####################
#   Build Image    #
####################
FROM alpine AS builder

# Setup required build dependencies
RUN apk update && \
    apk add git make cmake g++ boost-dev lua5.3-dev zlib-dev rapidjson-dev curl-dev openssl-dev

# Grab the latest released source code
RUN git clone --recurse-submodules "https://github.com/BeamMP/BeamMP-Server" /beammp
WORKDIR /beammp
RUN git checkout --recurse-submodules $(git tag --sort=taggerdate | tail -1)

# Build the server
# We have to specify the lua path manually, because it is not set correctly during apk setup
# We use Release mode to reduce binary size, improve speed and remove debug symbols automatically
# We are disabling the sentry backend as it is not needed for our custom build.
RUN cmake -DLUA_LIBRARY=/usr/lib/lua5.3/liblua.so -DCMAKE_BUILD_TYPE=Release -DSENTRY_BACKEND=none .

# Build the 'BeamMP-Server' executable using all available CPU cores
RUN make -j $(nproc)

####################
#    Run Image     #
####################
FROM alpine
MAINTAINER Rouven Himmelstein rouven@himmelstein.info

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
    apk add --no-cache zlib lua5.3 libcrypto1.1 openssl libgcc libcurl

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
ENTRYPOINT /entrypoint.sh
