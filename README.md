# Base Docker image for the SMuRF project

## Description

This docker image, named **smurf-base** contains all the base tools used by the SMuRF project.

It is based on ubuntu 18.04, and contains:
- Basic system tools,
- python3,
- Python3 modules
  - ipython,
  - numpy,
  - pyepics,
- EPICS base 3.15.5,
- SLAC IPMI wrappers,
- SLAC's FirmwareLoader and ProgramFPGA script.

## Source code

EPICS based (version 3.15.5) source code is downloaded from its github repository https://github.com/epics-base.

The IPMC package containing source code, libraries, and binaries was taken from SLAC's version, hosted internally. The package was manually copied into this repository in the form of a tarball.

The FirmwareLoader binary was taken from SLAC's version, hosted internally. The binary was manually copied into this repository in the form of a tarball.

## Building the image

When a tag is pushed to this github repository, a new Docker image is automatically built and push to its [Dockerhub repository](https://hub.docker.com/r/tidair/smurf-base) using travis.

The resulting docker image is tagged with the same git tag string (as returned by `git describe --tags --always`).

## How to get the container

To get the docker image, first you will need to install the docker engine in you host OS. Then you can pull a copy by running:

```
docker pull tidair/smurf-base:<TAG>
```

Where **<TAG>** represents the specific tagged version you want to use.

## How to run the container

To start the container just execute the following command:

```
docker run -ti --rm --name smurf-base tidair/smurf-base:<TAG>
```

Where **<TAG>** represents the specific tagged version you want to use.

You will be given a bash shell where you can run the any of the tools provided by this docker image. You can also add commands at the  of the docker run command, in this case the container will be started, the command will be run, and the container will be stopped.

Note that the container must be run in a server with access to the ATCA system you plan to use.