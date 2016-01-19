#!/bin/bash

# Copyright (c) 2015 Isaac Lewis all rights reserved. 

# Exit immediately if a pipeline exits with a non-zero status.
set -e

# Set the shell options.
shopt -s extglob

# Load all required environment variables.
source env.sh

# Set any traps.
source trap.sh

# Set the type of action being performed.
geo_ip_act="Install"

# Remove any previous installations.
quiet id "geo-ip" && echo "Removing any previous installations" && ./uninstall.sh

# Create the geo-ip user.
adduser --system "geo-ip" --shell /bin/bash

# Create the downloads directory.
mkdir -p "$geo_ip_home/downloads"

# Copy the required files to the user's home dir.
cp -r !(makefile||*install.sh||*~) "$geo_ip_home"

# Create an empty log file
touch "$geo_ip_home/log.txt"

# Read the MySQL passwords.
[ ! "$mysql_root_pass" ] && read -p "Enter the (previously set) MySQL root password: " mysql_root_pass
[ ! "$mysql_geo_ip_pass" ] && read -p "Set the password for the MySQL user 'geo_ip': " mysql_geo_ip_pass
[ ! "$mysql_geo_ip_updater_pass" ] && read -p "Set the password for the MySQL user 'geo_ip_updater': " mysql_geo_ip_updater_pass

# Create the empty geo-ip database and two users.*
eval "envsubst < templates/create.sql.tp | mysql -t -u root --password=\"$mysql_root_pass\""

# Update the geo-ip database.
source update.sh

# Create a crontab to keep the database current.
envsubst < templates/crontab.tp | crontab -u "geo-ip" '-'
