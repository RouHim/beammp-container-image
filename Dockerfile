####################
#   Build Image    #
####################
FROM alpine AS builder
## Build args
ARG GIT_URL="https://github.com/BeamMP/BeamMP-Server"
## Build the server
WORKDIR /
RUN apk update && \
    apk add git make cmake g++ boost-dev lua5.3-dev zlib-dev rapidjson-dev curl-dev openssl-dev
RUN git clone --recursive $GIT_URL beammp
WORKDIR /beammp
RUN cmake -DLUA_LIBRARY=/usr/lib/lua5.3/liblua.so .
# produce the 'BeamMP-Server' executable
RUN make

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
    apk add lua5.3 libgcc zlib rapidjson curl openssl
RUN rm -f /sbin/apk && \
    rm -rf /etc/apk && \
    rm -rf /lib/apk && \
    rm -rf /usr/share/apk && \
    rm -rf /var/lib/apk

# Prepare executable
COPY --from=builder /beammp/BeamMP-Server ./beammp-server
RUN chmod +x beammp-server

# Prepare user
RUN addgroup -S beammp
RUN adduser -S beammp -G beammp
RUN chown -R ${GID}:${UID} .

EXPOSE 30814/tcp
EXPOSE 30814/udp
COPY entrypoint.sh /
ENTRYPOINT /entrypoint.sh