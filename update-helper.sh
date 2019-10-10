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

## Time/date variables

# All dates are in 'YYYYMMDD' format. If the date contained in
# filenames of the the remote database archive is more recent, than
# the date contained in the filenames of the local database archive,
# then an attempt is made to update the local database.  To avoid
# semantic inconsistencies (like the previous month being considered
# the same as current month) all dates & times are calculated relative
# to a single fixed date (the date at which this script starts) rather
# than the current date.

# Determine the first tuesday of the month $first_tues.

# Date at which this script starts
start_date=$( date +%Y%m%d )
# Year of the start date (YYYY)
y=$( date -d $start_date +%-Y )
# Month of the start date (1-12)
m=$( date -d $start_date +%-m )
# Day of the month of the start date (1-31)
d=$( date -d $start_date +%-d )
# Day of the week of the start date (0-6)
dow=$( date -d $start_date +%-u )

# Checks to determine if the remote database has been updated coincide
# exactly with Maxmind's release schedule: the first Tuesday of each
# month.

# Date of the 1st Tues of the start month
first_tues=$( date --date="$y-$m-$(( 1 + ($d - $dow + 8) % 7 ))" +%Y%m%d )
# Previous month
pm=$(( $m - 1 ))
# Day of the week of the 1st of the previous month
dow_1st_pm=$( date --date="$y-$pm-1" +%-u )
# Date of the 1st Tues of the previous month
first_tues_pm=$( date --date="$y-$pm-$(( 1+(1-$dow_1st_pm+8)%7 ))" +%Y%m%d )

# Determine the date (if any) of the last update
# (geo_ip_archive_date).
if [ -e "$geo_ip_fn" ]; then
    # Extract the date from the filenames in the archive $geo_ip_fn.
    geo_ip_archive_date=$( unzip -l $geo_ip_fn | grep -m 1 -o $geo_ip_date_rx )
else
    geo_ip_archive_date=0
fi

##

# Download a new archive if the date of the last update is before the
# first tuesday of the start month and the start date is after the
# first tuesday.
if [[ $geo_ip_archive_date -lt $first_tues && $start_date -ge $first_tues ]]; then
    source download.sh
fi

# Remove any temporary files created by previous updates.
rm -rf $geo_ip_tmp

# Make sure the necessary directories exist.
mkdir -p $geo_ip_tmp

# Extract the database to a temporary location.
unzip -d $geo_ip_tmp $geo_ip_fn

# Expand the path names in these environment variables.
geo_ip_cl_fn="$( realpath $geo_ip_cl_fn )"
geo_ip_cb_fn="$( realpath $geo_ip_cb_fn )"

# For debugging purposes:
# envsubst < templates/update.sql.tp > update.sql

# Load the temporary CSV database into the MySQL database.
eval "envsubst < templates/update.sql.tp | mysql --table"

###
