#!/bin/bash

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#              applications via a MySQL database.
#
# Copyright (C) 2016-2019 Isaac Lewis

# MySQL passwords used when building the my-geo-ip docker image

if [ ! "$build_passwords" ]; then

    # Include flag (don't edit)
    export build_passwords=1

    # 'mysql' passwords
    mysql_root_pass=$(pwgen -n 12 1)
    mysql_geo_ip_pass=$(pwgen -n 12 1)
    mysql_geo_ip_updater_pass=$(pwgen -n 12 1)

    # This environment variable is used by the official MySQL docker
    # image.
    export ${!mysql_*}

fi
