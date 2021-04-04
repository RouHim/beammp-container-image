####################
#   Build Image    #
####################
FROM alpine AS builder

## Build args
ARG GIT_URL="https://github.com/BeamMP/BeamMP-Server"
WORKDIR /

# Setup required build dependencies
RUN apk update && \
    apk add git make cmake g++ boost-dev lua5.3-dev zlib-dev rapidjson-dev curl-dev openssl-dev

# Grab the latest release source code
RUN git clone --recursive $GIT_URL beammp
WORKDIR /beammp
RUN LATEST_GIT_TAG=`git tag --sort=taggerdate | tail -1`
RUN git checkout $LATEST_GIT_TAG

# Build the server
# We have to specify the lua path manually, because it is not set correctly during apk setup
RUN cmake -DLUA_LIBRARY=/usr/lib/lua5.3/liblua.so .

# Build the 'BeamMP-Server' executable
RUN make -j4

####################
#    Run Image     #
####################
FROM alpine
MAINTAINER Rouven Himmelstein rouvenhimmelstein@gmail.com

## System parameter
ENV TZ "Europe/Berlin"
ENV UID 1000
ENV GID 1000

## Game server parameter and their defaults
ENV DEBUG "false"
ENV PRIVATE "true"
ENV PORT "30814"
ENV CARS "1"
ENV MAX_PLAYERS "10"
ENV MAP "/levels/gridmap/info.json"
ENV NAME "BeamMP New Server"
ENV DESC "BeamMP Default Description"
ENV USE "Resources"
ENV AUTH_KEY ""

# Create game server folder
RUN mkdir /beammp
WORKDIR /beammp

# Install game server required packages
RUN apk update && \
    apk add -U tzdata lua5.3 libgcc zlib rapidjson curl openssl
# Disable package manager
RUN rm -f /sbin/apk && \
    rm -rf /etc/apk && \
    rm -rf /lib/apk && \
    rm -rf /usr/share/apk && \
    rm -rf /var/lib/apk

# Copy the previously built executable
COPY --from=builder /beammp/BeamMP-Server ./beammp-server
RUN chmod +x beammp-server

# Prepare user
RUN addgroup -S beammp
RUN adduser -S beammp -G beammp
RUN chown -R ${GID}:${UID} .

# We need tcp and udp
EXPOSE 30814/tcp
EXPOSE 30814/udp

# Specify entrypoint
COPY entrypoint.sh /
ENTRYPOINT /entrypoint.sh