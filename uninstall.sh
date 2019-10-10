#!/bin/bash -x

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#               applications via a MySQL database.
#
# Copyright (C) 2016-2019 Isaac Lewis

## Setup environment variables and error handling.

$bash_set_cmd

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

# Remove files in the data directory
rm -rf "$mysql_data_dir"

# This line is here to prevent the shell from returning the exit
# status of the condition in the previous line.
true
