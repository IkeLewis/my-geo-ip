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

## Setup environment variables and error handling.

# Exit immediately if a pipeline exits with a non-zero status.
set -e

cd /my-geo-ip

# Load all required environment variables.
source env.sh

# Set any traps.
source trap.sh

##

# If no command is specified, then
if [ -z "$@" ]; then

    # Include this for 'mysql_start'.
    source lib-mysql-helpers.sh

    mysql_start

    # Set the MySQL passwords.
    source set-passwords.sh

    # Update the database if necessary.
    source update.sh

    # Launch cron to keep the database updated.
    cron

    wait
else
    # Execute the given command.
    exec "$@"

fi
