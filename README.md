## gdc-client docker image

*   Source: https://github.com/sbamin/gdc-client
*   Docker: https://hub.docker.com/r/sbamin/gdc-client
*   Based on `gdc-client` Ubuntu x64 binary at https://gdc.cancer.gov/access-data/gdc-data-transfer-tool

### manpage

```
docker run sbamin/gdc-client # show help
docker run sbamin/gdc-client download --help
docker run sbamin/gdc-client upload --help
```

#### To download open access data

*   In the host machine (where you've installed `docker`): Create or preferably mount an external disk to store sequence data, e.g., `/mnt/scratch/`.

>To avoid potential issues with file permissions on the host machine, avoid mounting entire home directory or path to critical data as a docker shared volume. I usually prefer creating a new directory for shared volume.

*   download and keep GDC manifest file for `open` access files in the shared directory.

```
cd /mnt/scratch

docker run -d -v /mnt/scratch:/scratch sbamin/gdc-client download -v -n 4 -m open_manifest.tsv
```

>Here, we run docker in daemon mode, mount `/mnt/scratch` (supply full path and not relative) directory on the host machine to `/scratch` location within docker container. Then we start, `gdc-client download` with 4 threads and fetch data from the downloaded manifest. `-v` is for verbose mode to track download progress (see below).

*   **PS:** At the `-m` flag, only specify name of the manifest file, e.g., `open_manifest.tsv` and not the whole path. docker container will start with work directory, `/scratch` which is mapped to `/mnt/scratch` on the host machine. So, docker container would look for `open_manifest.tsv` in the mounted `/scratch` directory, i.e., `/mnt/scratch/open_manifest.tsv` location on the host machine!

#### To download controlled access data

*   Download user API token from https://portal.gdc.cancer.gov and place it as `token.key` in `/mnt/scratch`. 
*   When mounted as `/scratch` volume for docker container, `token.key` will be seen by running docker container at `/scratch/token.key`
*   Download and place controlled data manifest in `/mnt/scratch/controlled_manifest.tsv` on the host machine.

```
cd /mnt/scratch

docker run -v /mnt/scratch:/scratch sbamin/gdc-client download -v -n 4 -t token.key -m controlled_manifest.tsv
```

*   For controlled access data, avoid using daemon mode with `-d` flag before testing that API token is working else you may end up requesting too many login requests and get blocked of further data access.
*   In case of authorization failure, kill docker container using `docker kill <container ID>` command. Check container ID using command to check running docker processes: `docker ps` 

#### To track download progress:

```
docker ps
docker logs <container NAME or ID>
```

#### To parallelize downloads

Instead of supplying download manifest, you can supply `analysis id`, i.e., first column value of the manifest, and run multiple docker instances using one the above two command for open or controlled access data, respectively.

#### To debug

>Get into interactive mode and get bash prompt of docker container:

```
docker run -it -v /mnt/scratch:/scratch --entrypoint=/bin/bash sbamin/gdc-client
```

END

