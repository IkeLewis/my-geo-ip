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

#### Set the global environment variables

if [ ! "$geo_ip_global_env" ]; then

    # Include flag (don't edit)
    geo_ip_global_env=1

    ## 'mysql_' vars

    mysql_my_geo_ip_dir="/var/lib/my-geo-ip"
    mysql_data_dir="$mysql_my_geo_ip_dir/data"

    # If the mysql server is started with the 'secure_file_priv'
    # option enabled, then mysql can only read from directories listed
    # in the value of the 'secure_file_priv' variable.  The value may
    # be obtained with the following query:
    #
    # SHOW VARIABLES LIKE "secure_file_priv"
    mysql_load_dir="$mysql_my_geo_ip_dir/load"

    mysql_geo_ip_load_dir="$mysql_load_dir/geo-ip"

    ##

    ## Mostly 'geo_ip_' vars

    # Current version
    geo_ip_ver="1.0"

    # Type of action being performed: "Install", "Update", or "Uninstall"
    geo_ip_act=

    # Home directory of the geo-ip user
    geo_ip_home="/home/geo-ip"

    # Temporary directory
    geo_ip_tmp="$mysql_geo_ip_load_dir/tmp"

    # Date reg-ex used to parse a date from the archive contents
    geo_ip_date_rx="\([0-9]\{8\}\)"

    # Date parsed from the archive contents
    geo_ip_archive_date=

    # Country locations filename
    geo_ip_cl_fn="$geo_ip_tmp/*Country*/*Country*Locations*en.csv"

    # Country blocks filename
    geo_ip_cb_fn="$geo_ip_tmp/*Country*/*Country*Blocks*IPv4.csv"

    ##

    ## Mostly 'wget_' variables

    # Download URL for the geo-ip database
    wget_url="https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country-CSV.zip"

    # Maximum download size
    wget_quota="10m"

    # Pretend wget is the Iceweasel/Firefox browser
    wget_user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0 Iceweasel/38.2.1"

    # Directory for downloads
    wget_dirp="$geo_ip_home/downloads"

    # Archive filename
    geo_ip_fn="$wget_dirp/$( basename $wget_url )"

    # IMPORTANT: To manually test the following wget command, use 'eval
    # $wget_command'.

    # Build up the wget command from the previous wget options.
    wget_command="wget --inet4-only --server-response \
    --quota=$wget_quota --tries=1 --directory-prefix=\"$wget_dirp\" \
    --user-agent=\"$wget_user_agent\" \"$wget_url\""

    ##

    export ${!geo_ip_*} ${!wget_*} ${!mysql_*}

fi
