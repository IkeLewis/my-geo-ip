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
