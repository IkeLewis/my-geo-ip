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
