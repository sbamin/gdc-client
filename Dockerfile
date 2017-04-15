################################
# Dockerfile for NCI gdc-client
################################

# Based on Ubuntu 14.04 x64 binary
# Source: https://gdc.cancer.gov/access-data/gdc-data-transfer-tool
FROM	ubuntu:14.04
## For questions, visit https:
MAINTAINER "Samir B. Amin" <tweet:sbamin; sbamin.com/contact>

LABEL version="1.2.0" \
	  mode="gdc-client-1.2.0" \	
      description="docker image to run NCI gdc-client" \
      contact="https://github.com/sbamin/gdc-client"

RUN	apt-get update
RUN	apt-get install -y wget zip unzip
RUN	cd /opt && wget https://gdc.cancer.gov/files/public/file/gdc-client_v1.2.0_Ubuntu14.04_x64.zip && unzip gdc-client_v1.2.0_Ubuntu14.04_x64.zip
RUN	cp /opt/gdc-client /usr/local/bin/

## /scratch where gdc-client can store downloaded data
## use docker volume mount option to mount host directory to docker:/scratch
RUN mkdir /scratch
WORKDIR	/scratch

## set gdc-client as entrypoint with optional help arguments
ENTRYPOINT ["/usr/local/bin/gdc-client"]
CMD ["-h"]

## download manpage
# docker run sbamin/gdc-client download --help
# See README for more details at https://github.com/sbamin/gdc-client

## END
