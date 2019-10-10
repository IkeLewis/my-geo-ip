#!/bin/bash -x

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#              applications via a MySQL database.
#
# Copyright (C) 2016-2019 Isaac Lewis

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
