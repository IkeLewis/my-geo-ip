#!/bin/bash

# my-geio-ip -- The my-geo-ip package provides geo-ip services to
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

## Time/date variables 

# All dates are in 'YYYYMMDD' format. If the date contained in
# filenames of the the remote database archive is more recent, than
# the date contained in the filenames of the local database archive,
# then an attempt is made to update the local database.  To avoid
# semantic inconsistencies (like the previous month being considered
# the same as current month) all dates & times are calculated relative
# to a single fixed date (the date at which this script starts) rather
# than the current date.

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
# the previous month
pm=$(( $m - 1 ))
# Day of the week of the 1st of the previous month
dow_1st_pm=$( date --date="$y-$pm-1" +%-u )
# Date of the 1st Tues of the previous month
first_tues_pm=$( date --date="$y-$pm-$(( 1+(1-$dow_1st_pm+8)%7 ))" +%Y%m%d )

## Perform the download with wget

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
	if [ "$geo_ip_archive_date" == "$updated_date" ]; then
	    [ -e "$geo_ip_fn.bak" ] && rm "$geo_ip_fn.bak"
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
