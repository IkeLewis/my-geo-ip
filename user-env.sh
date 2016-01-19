#!/bin/bash

# Copyright (c) 2015 Isaac Lewis all rights reserved. 

### User Customizable Variables

if [ ! "$geo_ip_user_env" ]; then

    # Include flag (don't edit)
    geo_ip_user_env=1    

    ## 'mysql' variables
    mysql_root_pass=
    mysql_geo_ip_pass=
    mysql_geo_ip_updater_pass=

    export ${!mysql_*}

fi
