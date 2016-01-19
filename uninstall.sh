#!/bin/bash

# Copyright (c) 2015 Isaac Lewis all rights reserved. 

# Exit immediately if a pipeline exits with a non-zero status.
set -e

# Load all required environment variables.
source env.sh

# Set any traps.
source trap.sh

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
