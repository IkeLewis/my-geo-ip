#!/bin/bash -x

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#              applications via a MySQL database.
#
# Copyright (C) 2016-2019 Isaac Lewis

### Update the MySQL geo_ip database.

## Setup environment variables and error handling.

$bash_set_cmd

# Load all required environment variables.
source env.sh

# Set any traps.
source trap.sh

##

# Make sure this script only runs as the geo-ip user.
if [ "$USER" != "geo-ip" ]; then
    geo_ip_error "update-helper.sh must be run as the geo-ip user"
fi

cd "$geo_ip_home"

# Set the type of action being performed.
[ "$geo_ip_act" != "Install" ] && geo_ip_act="Update"

# Download the latest archive
source download.sh

# Validate the checksum
if [[ $(sha256sum -c "${geo_ip_checksum_fn}") -ne 0 ]]; then
    # Another way of checking the hash:
    # if [ "$(sha256sum "${geo_ip_fn}" | cut -b -64)" != "$(cat "${geo_ip_checksum_fn}")" ] ; then
    rm "${geo_ip_fn}"
    geo_ip_error "Invalid checksum for ${geo_ip_fn}"
fi

# Remove any old archive and checksum files.
rm -f $(ls ${geo_ip_home}/downloads/GeoLite2-Country-CSV_* | \
	grep --invert-match "${geo_ip_archive_date}")

# Remove any temporary files created by previous updates.
rm -rf $geo_ip_tmp

# Make sure the necessary directories exist.
mkdir -p $geo_ip_tmp

# Extract the CSV databases from the zip file to a temporary location.
unzip -d $geo_ip_tmp $geo_ip_fn

# Expand the path names in these environment variables.
geo_ip_tmp_cl_fn="$( realpath $geo_ip_tmp_cl_fn )"
geo_ip_tmp_cb_fn="$( realpath $geo_ip_tmp_cb_fn )"

# For debugging purposes:
# envsubst < templates/update.sql.tp > update.sql

# Load the temporary CSV databases into the MySQL database.
eval "envsubst < templates/update.sql.tp | mysql --table"
