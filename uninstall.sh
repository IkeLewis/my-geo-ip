#!/bin/bash -x

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#               applications via a MySQL database.
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

# Load all required environment variables.
source env.sh

# Set any traps.
source trap.sh

##

# Set the type of action being performed.
geo_ip_act="Uninstall"

# Remove all temporary files.
[ -e $geo_ip_tmp ] && rm -rf $geo_ip_tmp

# Remove the user's crontab if it exists.
[ -e /var/spool/cron/crontabs/geo-ip ] && crontab -u "geo-ip" -r

# Remove the user and all files owned by the user.
quiet id "geo-ip" && deluser --remove-home --quiet "geo-ip"

# This line is here to prevent the shell from returning the exit
# status of the condition in the previous line.
true
