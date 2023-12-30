<p align="center">
  <img src="https://raw.githubusercontent.com/RouHim/beammp-container-image/main/logo.svg" width="250">
</p>

<p align="center">
    <a href="https://github.com/RouHim/beammp-container-image/actions/workflows/beammp_release.yml"><img src="https://github.com/RouHim/beammp-container-image/actions/workflows/beammp_release.yml/badge.svg?branch=main" alt="Release Pipe"></a>
    <a href="https://github.com/RouHim/beammp-container-image/actions/workflows/beammp_unstable.yml"><img src="https://github.com/RouHim/beammp-container-image/actions/workflows/beammp_unstable.yml/badge.svg?branch=main" alt="Unstable release Pipe"></a>
    <a href="https://hub.docker.com/r/rouhim/beammp-server"><img src="https://img.shields.io/docker/pulls/rouhim/beammp-server.svg" alt="Docker Hub pulls"></a>
    <a href="https://hub.docker.com/r/rouhim/beammp-server"><img src="https://img.shields.io/docker/image-size/rouhim/beammp-server" alt="Docker Hub size"></a>
    <a href="https://github.com/aquasecurity/trivy"><img src="https://img.shields.io/badge/trivy-protected-blue" alt="trivy"></a>
    <a href="https://hub.docker.com/r/rouhim/beammp-server/tags"><img src="https://img.shields.io/badge/ARCH-amd64_arm64/v7-blueviolet" alt="os-arch"></a>
    <a href="https://buymeacoffee.com/rouhim"><img alt="Donate me" src="https://img.shields.io/badge/-buy_me_a%C2%A0coffee-gray?logo=buy-me-a-coffee"></a>
</p>

<p align="center">
    This project provides a container image for the <a href="https://beammp.com">BeamMP</a> 
    game server and shows its usage in a docker-compose environment.
</p>

## Motivation

Because there were no well-documented BeamMP server container images out there, I did one by myself.

## Variants

There are [two tags](https://hub.docker.com/r/rouhim/beammp-server/tags) of this container image available, that are
built nightly:

* **latest** - [Stable](https://github.com/BeamMP/BeamMP-Server/releases/latest) version of BeamMP
* **unstable** - [Unstable](https://github.com/BeamMP/BeamMP-Server) version of BeamMP (reflecting
  the [master](https://github.com/BeamMP/BeamMP-Server/tree/master) branch)

## Usage

The sections below provides use cases for docker and docker-compose.

### docker

Quick start:

```bash
docker run --name beammp-server \
           -p 30814:30814/tcp -p 30814:30814/udp \
           -e NAME='My first awesome Server' \
           -e AUTH_KEY='<insert auth-key>' \
           rouhim/beammp-server
```

> If you want to interact with the server console, just add the `-it` flag to the docker run command.

### docker-compose

First clone this repository and check `docker-compose.yml` if interested. The configuration should be done within
the `.env` file.

To get started copy `.env.example` to `.env` and create the mod folder.

```bash
cp .env.example .env && mkdir client-mods server-mods
```

Adjust the values in the `.env` to your needs and run:

```bash
docker-compose pull && docker-compose up -d

```

### Server interaction

To connect to the interactive game server console, you need to start the server in detached (docker / -compose `-d`
flag) mode.
Then run the following command to attach to the server console:

```bash
docker attach <container-name>
```

## Environment parameter

| Variable name | description                                                                                                   | default value                |
|---------------|---------------------------------------------------------------------------------------------------------------|------------------------------|
| AUTH_KEY      | Mandatory! The authentication key used by the server. It is used to identify your server and is not optional. | <empty>                      |
| DEBUG         | Set to true to enable debug output in the console.                                                            | false                        |
| PRIVATE       | Set to true if you don't want to show up in the Server Browser.                                               | true                         |
| CARS          | How many vehicles a player is allowed to have at the same time.                                               | 1                            |
| MAX_PLAYER    | How many players your server can hold at a time.                                                              | 10                           |
| MAP           | What the server map is.                                                                                       | /levels/gridmap_v2/info.json |
| NAME          | What your server is called. This shows up in the Server Browser.                                              | BeamMP New Server            |
| DESC          | What shows under the name when you click on the server.                                                       | BeamMP Default Description   |
| PORT          | This value must be identical to the containers exposed port.                                                  | 30814                        |

A new AUTH_KEY can be claimed on [this site](https://beammp.com/k/dashboard), you will need
a [Discord](https://discord.com) account for this. Note that the IP entered there does *not* matter, despite what the
site claims. For more information refer
to [this wiki page](https://wiki.beammp.com/en/home/server-installation#h-2-obtaining-an-authentication-key).

## Client mods

In the first place you should consider
reading [the official mods guide](https://wiki.beammp.com/en/home/server-installation#how-to-add-mods-to-your-server).
Mods can be downloaded from the [official BeamNG resources website](https://www.beamng.com/resources/). Just copy the
downloaded zip file into the `client-mods` folder.

### Custom maps

Copy the downloaded zip file into the `client-mods` folder.

Then have to find out the custom map path name (e.g.: `/levels/car_jump_arena/info.json`), to set it later as the map to
load. To do so:

1. Execute the shell command below, or open the zip file manually.
2. Copy the absolute path to the `info.json` location (`/levels/{map-name}/info.json`).
3. Set in .env file: `MAP=/levels/{map-name}/info.json`. Example: `MAP=/levels/car_jump_arena/info.json`

A simple way to print the full map path including info.json (_unzip_, _grep_ and _awk_ is required):

```shell
unzip -l PATH/TO/MAP.zip \
  | grep 'levels/.*/info.json' \
  | awk '{split($0,a," "); print "/"a[4]}'
```

## Server mods

Server mods can be found in the [BeamMP forum](https://forum.beammp.com/c/resource-plugin-area/server-resources).
Installation and configuration instructions are provided by each mod.

### Augment ServerConfig.toml

If you want to specify additional values for a mod in the `ServerConfig.toml` file, just specify this environment
variable in your `.env`
file:

```toml
ADDITIONAL_SERVER_CONFIG_TOML = '
[SomeMod]
MyKey = "This is \'quoted\'"

[OtherMod]
enabled = true
some_numbers = [1, 2, 3]
'
```

> Note that the single quotation marks are important at the beginning and end.
> If you want to use single quotes in the toml value they must be escaped with a
> backslash: `key = "this is a \'quote\'"`

## Resources

- BeamMP server repository: https://github.com/BeamMP/BeamMP-Server
- Official server maintenance guide: https://wiki.beammp.com/en/home/server-maintenance
- Official server installation guide: https://wiki.beammp.com/en/home/server-installation
- Inspired by: https://github.com/mastamic-ian/BeamMP_docker
- Built from: https://github.com/RouHim/beammp-container-image
- Built to: https://hub.docker.com/r/rouhim/beammp-server
