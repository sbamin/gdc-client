################################
# Dockerfile for NCI gdc-client
################################

# Based on Ubuntu 14.04 x64 binary for 16.04 x64 image
# Source: https://gdc.cancer.gov/access-data/gdc-data-transfer-tool
FROM	ubuntu:16.04
## For questions, visit https:
MAINTAINER "Samir B. Amin" <tweet:sbamin; https://sbamin.com/contact>

LABEL version="1.3.0_75237be" \
	mode="gdc-client-1.3.0_75237be" \
	description="docker image to run NCI gdc-client" \
	website="https://github.com/sbamin/gdc-client" \
	issues="https://github.com/sbamin/gdc-client/issues" \
	upstream_repo="https://github.com/NCI-GDC/gdc-client" \
	upstream_branch="develop" \
	upstream_commit="75237be04b827e8293c170462d37520200e55b06" \
	upstream_lastmod="2018-03-29"	

RUN	umask 0022 && apt-get update && \
	apt-get install -y wget zip unzip rsync sudo git python python-pip python-dev libxml2-dev libxslt1-dev zlib1g-dev build-essential

RUN mkdir -p /opt && \
	cd /opt && \
	git clone https://github.com/NCI-GDC/gdc-client.git && \
	cd gdc-client && \
	git checkout develop && \
	pip install -r requirements.txt && \
	pip install -r dev-requirements.txt && \
	python setup.py install && \
	pip freeze

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
	mkdir -p /opt/bin && \
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
CMD ["gdc-client", "-h"]

## download manpage
# docker run sbamin/gdc-client download --help
# See README for more details at https://github.com/sbamin/gdc-client

## END
