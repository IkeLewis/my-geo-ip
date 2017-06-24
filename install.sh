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

# Add the geo-ip user to the MySQL group (for access to
# /var/lib/mysql-files).
usermod -a -G mysql geo-ip

# Create the downloads directory.
mkdir -p "$geo_ip_home/downloads"

# Copy the required files to the user's home dir.
cp -r !(makefile||*install.sh||root-env.sh||*~) "$geo_ip_home"

# Create an empty log file
touch "$geo_ip_home/log.txt"

# Make sure all files in geo-ip's home dir are owned by geo-ip.
chown -R geo-ip /home/geo-ip

# Read the MySQL passwords if they are not already set.
[ ! "$mysql_root_pass" ] && read -p "Enter the (previously set) MySQL root password: " mysql_root_pass
[ ! "$mysql_geo_ip_pass" ] && read -p "Set the password for the MySQL user 'geo_ip': " mysql_geo_ip_pass
[ ! "$mysql_geo_ip_updater_pass" ] && read -p "Set the password for the MySQL user 'geo_ip_updater': " mysql_geo_ip_updater_pass

## Save the passwords

# Don't substitute for these env vars
geo_ip_root_env='$geo_ip_root_env'
geo_ip_geo_ip_env='$geo_ip_geo_ip_env'

# Generate the password files
envsubst < templates/root-env.sh.tp  > root-env.sh
envsubst < templates/geo-ip-env.sh.tp > "$geo_ip_home/geo-ip-env.sh"

##

# Create the directory that my-geo-ip will use to load SQL files.  The
# directory must be listed in the value of the MySQL variable
# 'secure_file_priv' (see 'global-env.h' for more details).
mkdir -p $mysql_geo_ip_load_dir

cp "lib-admin.sql" $mysql_geo_ip_load_dir

# Make sure mysql owns all files in the load dir.
chown -R mysql:mysql $mysql_load_dir

# Allow users in the mysql group to write to the load dir and deny all
# other users access.
chmod -R u=+rwx,g=+rwx,o=-rwx $mysql_load_dir

# Start MySQL if it's not already running.
service mysql start

# Create the empty geo-ip database and two users.
eval "envsubst < templates/create.sql.tp | mysql -t -u root --password=\"$mysql_root_pass\""

# Update the geo-ip database.
source update.sh

# Create a crontab to keep the database current.
envsubst < templates/crontab.tp | crontab -u "geo-ip" '-'

# Print the passwords
source print-passwords.sh
