FROM debian:stable-slim
MAINTAINER Rouven Himmelstein rouvenhimmelstein@gmail.com

## Build args
ARG DOWNLOAD_URL="https://github.com/BeamMP/BeamMP-Server/releases/download/v1.20-linux/BeamMP-Server-debian"

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
RUN mkdir beammp
WORKDIR /beammp

# Install game server required packages
RUN apt update -q && \
    apt upgrade -q -y && \
    apt install -y liblua5.3-dev libz-dev rapidjson-dev libcurl4-openssl-dev

# Prepare executable
ADD $DOWNLOAD_URL beammp-server
RUN chmod +x beammp-server

# Prepare user
RUN groupadd -g ${GID} beammp
RUN useradd -u ${UID} -g beammp -s /bin/sh beammp
RUN chown -R ${GID}:${UID} .

EXPOSE 30814
COPY entrypoint.sh /
ENTRYPOINT /entrypoint.sh