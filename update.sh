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

### Update the geo-ip MySQL database.

## Setup environment variables and error handling.

# Exit immediately if a pipeline exits with a non-zero status.
set -e

# Load all required environment variables.
source env.sh

# Set any traps.
source trap.sh

# Set the type of action being performed.
[ "$geo_ip_act" != "Install" ] && geo_ip_act="Update"

## Process any command line arguments.

usage="update.sh [OPTION]\n"
short="Attempts to update the local geo-ip MySQL database.\n"
opt="
-s, --skip-download\tDon't attempt to download an archive.  Use\n
                   \ta local one instead."

help="$usage$short$opt"

# Set the default option values.
skip_download=0;

if (( $# > 1 )); then
    geo_ip_error "Too many arguments:\n$help"
elif (( $# == 1 )); then
    case $1 in
	( "-s" | "--skip-download" ) skip_download=1;;
	(*) geo_ip_error "Invalid option:\n$help";;
    esac
fi

## Select an archive file to use.

if (( ! $skip_download )); then
    # Use a downloaded archive.
    source download.sh
elif [ -e $geo_ip_fn ]; then
    # Use an archive already on disk.
    # Set 'geo_ip_archive_date' to the date parsed from the archive
    # contents.
    geo_ip_archive_date=$( unzip -l $geo_ip_fn | grep -m 1 -o $geo_ip_date_rx );
else
    geo_ip_error "No existing archive file!"
fi

# Remove any temporary files created by previous updates.
rm -rf $geo_ip_tmp

# Make sure the necessary directories exist
mkdir -p $geo_ip_tmp

# Extract the database to a temporary (world readable) location.
unzip -d $geo_ip_tmp $geo_ip_fn

# Expand the path names in these environment variables.
geo_ip_cl_fn="$( realpath $geo_ip_cl_fn )"
geo_ip_cb_fn="$( realpath $geo_ip_cb_fn )"

# For debugging purposes:
# envsubst < templates/update.sql.tp > update.sql

# Load the temporary CSV database into the MySQL database.
eval "envsubst < templates/update.sql.tp | mysql -t -u geo_ip_updater --password=\"$mysql_geo_ip_updater_pass\""
