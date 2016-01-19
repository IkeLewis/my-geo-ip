#!/bin/bash

# Copyright (c) 2015 Isaac Lewis all rights reserved. 

## Load all required environment variables

if [ ! "$geo_ip_env" ]; then

    # Include flag (don't edit)
    geo_ip_env=1    

    # Load the user environment variables.
    source user-env.sh

    # Load global non-user environment variables.
    source global-env.sh

    export ${!geo_ip*}

fi
