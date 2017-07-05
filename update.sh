#!/bin/bash -x

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

### Update the my-geo-ip database if necessary.

## Setup environment variables and error handling.

# Exit immediately if a pipeline exits with a non-zero status.
set -e

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
