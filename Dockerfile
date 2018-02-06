################################
# Dockerfile for NCI gdc-client
################################

# Based on Ubuntu 14.04 x64 binary
# Source: https://gdc.cancer.gov/access-data/gdc-data-transfer-tool
FROM	ubuntu:14.04
## For questions, visit https:
MAINTAINER "Samir B. Amin" <tweet:sbamin; sbamin.com/contact>

LABEL version="1.3.0" \
	mode="gdc-client-1.3.0" \	
	description="docker image to run NCI gdc-client" \
	contact="https://github.com/sbamin/gdc-client"

RUN	umask 0022 && apt-get update && \
	apt-get install -y wget zip unzip && \
	mkdir -p /opt/bin && \
	chmod 755 /opt/bin && \
	cd /opt/bin

RUN wget https://gdc.cancer.gov/system/files/authenticated%20user/0/gdc-client_v1.3.0_Ubuntu14.04_x64.zip && \
	unzip gdc-client_v1.3.0_Ubuntu14.04_x64.zip && \
	rm -f gdc-client_v1.3.0_Ubuntu14.04_x64.zip

####### Setup non-root docker env #######
## copy setup files in the container ##
ADD ./setup/ /tempdir/

# Create non-root user, foo with passwordless sudo privileges
# set uid 1000 for user and add to a secondary group: staff
RUN ls -alh /tempdir/* && \
	useradd -m -d /home/foo -s /bin/bash -c "Docker User" -u 1000 -G staff foo && \
	echo "%sudo  ALL=(ALL) NOPASSWD:ALL" | (EDITOR="tee -a" visudo) && \
	mkdir -p /scratch && \
	chmod 775 /scratch && \
	chown -R foo:staff /scratch && \
	chmod 755 /etc/profile && \
	mkdir -p /etc/profile.d && \
	chmod 755 /etc/profile.d && \
	rsync -avhP /tempdir/profile.d/ /etc/profile.d/ && \
	chmod 755 /etc/profile.d/*.sh && \
	rsync -avhP /tempdir/bin/ /opt/bin/ && \
	chmod 755 /opt/bin/startup && \
	chmod 755 /opt/bin/userid_mapping.sh && \
	rm -rf /tempdir && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

## /scratch where gdc-client can store downloaded data
## use docker volume mount option to mount host directory to docker:/scratch
WORKDIR	/scratch

#### Default runtime env ####

ENV PATH=/opt/bin:/home/foo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"${PATH:+:$PATH}"

## startup helper script
ENTRYPOINT ["/opt/bin/startup"]

## download manpage
# docker run sbamin/gdc-client download --help
# See README for more details at https://github.com/sbamin/gdc-client

## END
