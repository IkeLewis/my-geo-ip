#!/bin/bash -x

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#              applications via a MySQL database.
#
# Copyright (C) 2016-2019 Isaac Lewis

### Update the my-geo-ip database if necessary.

## Setup environment variables and error handling.

$bash_set_cmd

# Load all required environment variables.
source env.sh

# Set any traps.
source trap.sh

##

if [ "$(id -un)" == "geo-ip" ]; then
    # This is used by cron.
    source /home/geo-ip/update-helper.sh
elif [ "$(id -un)" == "root" ]; then
    # This is used during install.
    su --login --command="/home/geo-ip/update-helper.sh" geo-ip
else
    geo_ip_error "can't run update.sh as $USER; update.sh must be run as root or geo-ip"
fi

###
