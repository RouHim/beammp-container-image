# beammp-docker

This project provides a docker container for the [beammp](https://beammp.com) game server 
and shows its usage in a docker-compose environment.
The prebuilt linux binary files from the beammp server is used.

## Parameter

Variable name   | description                                                                                   | default value
--------------- |---------------------------------------------------------------------------------------------- | -------- 
DEBUG           | Set to true to enable debug output in the console                                             | false
PRIVATE         | Set to true if you don't want to show up in the Server Browser                                | true
CARS            | How many vehicles a player is allowed to have at the same time                                | 1
MAX_PLAYER      | How many players your server can hold at a time                                               | 10
MAP             | What the server map is                                                                        | /levels/gridmap/info.json
NAME            | What your server is called. This shows up in the Server Browser                               | BeamMP New Server
DESC            | What shows under the name when you click on the server                                        | BeamMP Default Description
AUTH_KEY        | The authentication key used by the server. It is used to identify your server and is mandatory| empty

## Usage
The sections below provide use cases for docker and docker-compose.

### docker
Quick start:

```bash
docker run --name beammp-server -p 30814:30814 \
           -e NAME='My first awesome Server' \
           -e AUTH_KEY='<insert auth-key>' \
           rouhim/beammp-server:latest
```

### docker-compose
Check `docker-compose.yml` if interested.
But the configuration should be done within the `.env` file.

To get started copy `.env.example` to `.env`. 
```bash
cp .env.example .env
```

Adjust the values in the `.env` to your needs and run:
```bash
docker-compose up -d
```

## Mods
In the first place you should consider reading [the official mods guide](https://wiki.beammp.com/en/home/server-installation#how-to-add-mods-to-your-server).

> The folder `mods` is created automatically during the first startup,
> but can also be created manually beforehand.

### Vehicle mods:
Just copy the downloaded zip file into the `mods` folder.

### Custom maps:
First Copy the downloaded zip file into the `mods` folder.

Now we have to find out the custom map path name (e.g.: `/levels/car_jump_arena/info.json`),
to set it later in the as map to load.

To do so: 
1. Execute the shell command below, or open the zip file manually.
2. Copy the absolute path to the `info.json` location (`/levels/{map-name}/info.json`).
3. Set in .env file: `MAP=/levels/{map-name}/info.json`. 
   Example: `MAP=/levels/car_jump_arena/info.json` 

A simple way to print the full map path including info.json (_unzip_, _grep_ and _awk_ is required):
```shell
unzip -l PATH/TO/MAP.zip \
  | grep 'levels/.*/info.json' \
  | awk '{split($0,a," "); print "/"a[4]}'
```

## Tag versions

The following table lists all versions available of the docker image. 
The table also references the beammp server release used for each version.

Image Tag   | Beammp server version                                                                                    
----------- | ---------------------------------------------------------------------------------  
latest      | references to the latest version available                                            
1.20        | [v1.20-linux](https://github.com/BeamMP/BeamMP-Server/releases/tag/v1.20-linux)                                            


## Used materials

- Official server installation guide: https://wiki.beammp.com/en/home/server-installation
- BeamMP linux server repository: https://github.com/BeamMP/BeamMP-Server
- Inspired by: https://github.com/mastamic-ian/BeamMP_docker
