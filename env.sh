#!/bin/bash -x

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#              applications via a MySQL database.
#
# Copyright (C) 2016-2019 Isaac Lewis

## Load all required environment variables

if [ ! "$geo_ip_env" ]; then

    # Include flag (don't edit)
    geo_ip_env=1

    # Load the user environment variables.
    if [ -e "$(id -un)-env.sh" ]; then
    	source "$(id -un)-env.sh"
    fi

    # Load global non-user environment variables.
    source global-env.sh

    export ${!geo_ip_*}

fi

##
