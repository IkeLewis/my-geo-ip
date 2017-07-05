#!/bin/bash -x

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#              applications via a MySQL database.
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

### Install my-geo-ip.

## Setup environment variables and error handling.

# Exit immediately if a pipeline exits with a non-zero status.
set -e

# Set the shell options.
shopt -s extglob

# Load all required environment variables.
source env.sh

# Set any traps.
source trap.sh

##

# Set the type of action being performed.
geo_ip_act="Install"

# Remove any previous installations.
quiet id "geo-ip" && echo "Removing any previous installations" && ./uninstall.sh

## Setup the geo-ip system user.

# Create the geo-ip system user.
useradd --user-group --create-home --shell /bin/bash --system "geo-ip"

# Add the geo-ip user to the MySQL group (for access to
# /var/lib/mysql-files).
usermod -a -G mysql geo-ip

# Create the downloads directory.
mkdir -p "$geo_ip_home/downloads"

# Copy the required files to the user's home dir.
cp -r !(makefile||*install.sh||*~) "$geo_ip_home"

# Create an empty log file.
touch "$geo_ip_home/log.txt"

# Make sure all files in geo-ip's home dir are owned by geo-ip.
chown -R geo-ip:geo-ip /home/geo-ip

##

## Install the necessary MySQL directories.

mkdir -p $mysql_my_geo_ip_dir
mkdir -p $mysql_data_dir

# Create the directory that my-geo-ip will use to load SQL files.  The
# directory must be listed in the value of the MySQL variable
# 'secure_file_priv' (see 'global-env.h' for more details).
mkdir -p $mysql_geo_ip_load_dir

cp "lib-admin.sql" $mysql_geo_ip_load_dir

# Allow users in the mysql group to write to the load dir and deny all
# other users access.
chmod -R u=+rwx,g=+rwx,o=-rwx $mysql_load_dir

# Make sure mysql owns all files in the $mysql_my_geo_ip_dir.
chown -R mysql:mysql $mysql_my_geo_ip_dir

##

## Configure MySQL.

# Generate the MySQL passwords.
source build-passwords.sh

# Generate the MySQL config for the system user root.
envsubst < templates/root.my.cnf.tp  > "/root/.my.cnf"

# Generate the MySQL config for the system user geo-ip.
envsubst < templates/geo-ip.my.cnf.tp > "$geo_ip_home/.my.cnf"
chown geo-ip /home/geo-ip/.my.cnf

# Include this for 'mysql_start'.
source lib-mysql-helpers.sh

# Initialize MySQL.
mysqld --initialize-insecure

##

## Install the geo-ip database.

# Start the MySQL server.
mysql_start

# Create the empty geo-ip database.
eval "envsubst < templates/create-database.sql.tp | mysql --table --password=\"\""

# Create users for the geo-ip database.
eval "envsubst < templates/create-users.sql.tp | mysql --table --password=\"\""

# Update the geo-ip database.
source update.sh

# Perform a basic test.
echo "CALL geo_ip.info('012.034.056.078')\G" | mysql --table

# Create a crontab to keep the database current.
envsubst < templates/crontab.tp | crontab -u "geo-ip" '-'

# Shutdown the MySQL server.
mysql_stop

##
