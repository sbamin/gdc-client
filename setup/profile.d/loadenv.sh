#!/bin/bash

# default path for /usr related bins (below) will be set via /etc/profile.d/vte-2.91.sh

##### START DO NOT EDIT #####
## default umask to 0022, equals 750 for dirs, 640 for files
umask 0022

#### SET USER ENV ####
export PATH=/opt/bin:/home/foo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"${PATH:+:$PATH}"

## END ##
