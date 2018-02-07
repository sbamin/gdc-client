### gdc-client docker image

<span><a href="https://hub.docker.com/r/sbamin/gdc-client"><img src="https://img.shields.io/badge/Docker-1.3.0-brightgreen.svg" alt="Docker 1.3.0" /></a> <a href="https://github.com/sbamin/gdc-client/issues"><img src="https://img.shields.io/github/issues/sbamin/gdc-client.svg" alt="GitHub issues" /></a></span>

>7-Feb-2018   
>v1.3.0   

*   Source: https://github.com/sbamin/gdc-client
*   Docker: https://hub.docker.com/r/sbamin/gdc-client
*   Based on `gdc-client` Ubuntu x64 binary at https://gdc.cancer.gov/access-data/gdc-data-transfer-tool

#### To download controlled access data

*   In the host machine (where you've installed `docker`): Create or preferably mount an external disk to store sequence data, e.g., `/mnt/myscratch/`.

>To avoid potential issues with file permissions on the host machine, **avoid mounting entire home directory or path to critical data** as a docker shared volume. I usually prefer creating a new directory for shared volume.  

*   Download and keep GDC manifest file in tsv/txt format for `open` access files in the shared directory.
*   Save GDC token file in the same director and do `chmod 600 gdc_token.key`
*   **IMPORTANT**: Make sure to pass valid (identical to host machine) user and group environment variables in `docker run` command else stored files may inherit root or strange user ownership.

```sh
## path where data will be stored on the host machine
export USERMOUNT="/mnt/myscratch"

cd "${USERMOUNT}"

## MAKE SURE TO GIVE PROPER USER AND GROUP IDs, matching to those of host machine
docker run -d -e HOSTUSER=$USER -e HOSTGROUP=staff -e HOSTUSERID=$UID -e HOSTGROUPID=10001 -v "${USERMOUNT}":/scratch sbamin/gdc-client "gdc-client download --log-file=download.log -n 4 -t gdc_token.key -m controlled_manifest.tsv"
```

>Here, we run docker in daemon mode, mount `/mnt/myscratch` (supply full path and not relative) directory on the host machine to `/scratch` location within docker container. Then we start, `gdc-client download` with 4 threads and fetch controlled access data from the downloaded manifest using download key. For logging, `-v` does not seem to work, so using `--log-file=download.log` to save file in in mounted host volume.

*   At the `-m` flag, only specify name of the manifest file, e.g., `controlled_manifest.tsv` and not the whole path. docker container will start with container work directory, `/scratch` which is mapped to `/mnt/myscratch` on the host machine. So, docker container would look for `controlled_manifest.tsv` in the mounted `/scratch` directory, i.e., `/mnt/myscratch/controlled_manifest.tsv` location on the host machine!

##### Notes:

*   For controlled access data, avoid using daemon mode with `-d` flag before testing that API token, `gdc_token.key` is working else you may end up requesting too many login requests and get blocked of further data access.
*   In case of authorization failure, kill docker container using `docker kill <container ID>` command. Check container ID using command to check running docker processes: `docker ps` 

#### To download open access data:

*   Remove `-t gdc_token.key` and replace `-m controlled_manifest.tsv` with `-m open_manifest.tsv`

```sh
## path where data will be stored on the host machine
export USERMOUNT="/fastscratch/amins/dump/gdc/test"

cd "${USERMOUNT}"

## MAKE SURE TO GIVE PROPER USER AND GROUP IDs, matching to those of host machine
docker run -d -e HOSTUSER=$USER -e HOSTGROUP=staff -e HOSTUSERID=$UID -e HOSTGROUPID=10001 -v "${USERMOUNT}":/scratch sbamin/gdc-client "gdc-client download --log-file=download.log -n 4 -m open_manifest.tsv"
```

#### To track download progress:

```sh
docker ps
docker logs <container NAME or ID>
```

*   To debug in case of download failure, add `--debug` flag. Not recommended if gdc-client download is working properly else this will increase write operations a lot!

```sh
docker run -d -e HOSTUSER=$USER -e HOSTGROUP=staff -e HOSTUSERID=$UID -e HOSTGROUPID=10001 -v "${USERMOUNT}":/scratch sbamin/gdc-client "gdc-client download --debug --log-file=download.log -n 4 -t gdc_token.key -m controlled_manifest.tsv"
```

#### To parallelize downloads

Instead of supplying download manifest, you can supply `analysis UUID`, i.e., first column value of the manifest, and run multiple (prefer not to run more than 2-3 on one compute node) docker instances using one the above two command for open or controlled access data, respectively.

#### manpage

*   PS: Valid volume mounts are required (see below) before executing `gdc-client`

```sh
docker run -e HOSTUSER=$USER -e HOSTGROUP=staff -e HOSTUSERID=$UID -e HOSTGROUPID=10001 -v "${USERMOUNT}":/scratch sbamin/gdc-client "gdc-client download --help"

docker run -e HOSTUSER=$USER -e HOSTGROUP=staff -e HOSTUSERID=$UID -e HOSTGROUPID=10001 -v "${USERMOUNT}":/scratch sbamin/gdc-client "gdc-client upload --help"
```

END

