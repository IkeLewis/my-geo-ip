#!/bin/bash -x

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#              applications via a MySQL database.
#
# Copyright (C) 2016-2019 Isaac Lewis

## Perform the download with wget.

# Make sure this script only runs as the geo-ip user.
if [ "$USER" != "geo-ip" ]; then
    geo_ip_error "download.sh must be run as the geo-ip user"
fi

# Try up to 'max_tries' times to download the updated database file
# waiting approximately 1hr between attempts. The actual wait time is
# pseudo-randomly selected to be between 0.5 hrs and 1 hrs. The date
# check in the while loop below forces the script to wait for the
# updated file to become available on the server.

i=1
max_tries=48
while (( 1 ))
do

    # Make sure the download directory exists.
    [ ! -e "$wget_dirp" ] && mkdir -p "$wget_dirp"

    # Backup the previous archive if any.
    [ -e "$geo_ip_fn" ] && mv $geo_ip_fn "$geo_ip_fn.bak"

    # Attempt to download the archive.
    eval $wget_command

    wget_st=$?

    if [ $wget_st -eq 0 ]; then

	geo_ip_archive_date=$( unzip -l $geo_ip_fn | grep -m 1 -o $geo_ip_date_rx )

	# If the start date is before the 1st Tuesday, then the
	# filenames of the updated archive should contain the date of
	# the 1st Tuesday of the previous month. Otherwise they should
	# contain the 1st Tuesday of the start month.

	if [ $d -lt $( date -d $first_tues +%-d ) ]; then
	    updated_date=$first_tues_pm
	else
	    updated_date=$first_tues
	fi

	# Check that the updated file has been downloaded.
	if [ $geo_ip_archive_date -ge $updated_date ]; then
	    [ -e "$geo_ip_fn.bak" ] && rm -f "$geo_ip_fn.bak"
	    break 1
	else
	    echo "Updated file is not yet available."
	fi
    fi

    if [ $i -eq $max_tries ]; then
	[ -e "$geo_ip_fn.bak" ] && mv "$geo_ip_fn.bak" "$geo_ip_fn"
	if [ $wget_st -eq 0 ]; then
 	    geo_ip_error "Updated file is not available."
	else
	    geo_ip_error "Download failed."
	fi
    fi

    # Wait at least 0.5 hrs but not more than 1 hr before the
    # next try.
    wt=$(( 30 + $RANDOM % 31 ))
    echo "Retrying in $wt minutes."
    sleep ${wt}m

    (( i++ ))

done
##
