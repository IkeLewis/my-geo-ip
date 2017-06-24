#!/bin/bash

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#              applications via a MySQL database.
# Copyright (C) 2016 Isaac Lewis

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

## User Customizable Variables

if [ ! "$geo_ip_root_env" ]; then

    # Include flag (don't edit)
    geo_ip_root_env=1

    # 'mysql' variables
    mysql_root_pass=$(pwgen 12 1)
    mysql_geo_ip_pass=$(pwgen 12 1)
    mysql_geo_ip_updater_pass=$(pwgen 12 1)

    # This environment variable is used by the official MySQL docker
    # image.
    export MYSQL_ROOT_PASSWORD=${mysql_root_pass}
    export ${!geo_ip_*} ${!mysql_*}

fi
