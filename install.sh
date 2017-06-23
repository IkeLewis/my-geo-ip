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
adduser --system --group --shell /bin/bash --home $geo_ip_home "geo-ip"

# Create the downloads directory.
mkdir -p "$geo_ip_home/downloads"

# Copy the required files to the user's home dir.
cp -R download.sh lib-admin.sql env.sh update.sh global-env.sh trap.sh \
templates $geo_ip_home

# Create an empty log file
touch "$geo_ip_home/log.txt"

# Set file ownership
chown -R geo-ip:geo-ip $geo_ip_home

# Read the MySQL passwords.
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

# Update the mysql config
echo -e "[mysqld]\nsecure_file_priv=\"\"" > /etc/mysql/conf.d/my-geo-ip.cnf

# Restart mysql
service mysql restart

# Create the empty geo-ip database and two users.*
eval "envsubst < templates/create.sql.tp | mysql -t -u root --password=\"$mysql_root_pass\""

# Update the geo-ip database.
source update.sh

# Create a crontab to keep the database current.
envsubst < templates/crontab.tp | crontab -u "geo-ip" '-'
