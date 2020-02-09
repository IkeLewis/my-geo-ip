#!/bin/bash -x

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#              applications via a MySQL database.
#
# Copyright (C) 2016-2019 Isaac Lewis

### Set the global environment variables

if [ ! "$global_env" ]; then

    # Include flag (don't edit)
    global_env=1

    ## Bash config vars
    # 'set -e'/'set +e' -- Exit/Don't exit immediately if a pipeline
    # exits with a non-zero status.
    bash_set_cmd="set -e"

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

    ## 'geo_ip' vars

    # Type of action being performed: "Install", "Update", or "Uninstall"
    geo_ip_act=

    # Leave this blank to use the latest archive; format is "YYYYMMDD"
    geo_ip_archive_date=

    # Set this to true when debugging
    geo_ip_debug="true"

    geo_ip_debug_no_sql=""

    # Home directory of the geo-ip user
    geo_ip_home="/home/geo-ip"

    # Temporary directory
    geo_ip_tmp="$mysql_geo_ip_load_dir/tmp"

    # Country locations filename
    geo_ip_tmp_cl_fn="$geo_ip_tmp/*Country*/*Country*Locations*en.csv"

    # Country blocks filename
    geo_ip_tmp_cb_fn="$geo_ip_tmp/*Country*/*Country*Blocks*IPv4.csv"

    # Current version
    geo_ip_ver="2.0"

    ## 'maxmind' vars

    # This variable may be set when 'docker run' is called, e.g.
    # docker run -emaxmind_license_key=<your-license-key> ...
    if [ ! -v maxmind_license_key ]; then
       maxmind_license_key=
    fi

    ## 'wget_' variables

    # Maximum download size
    wget_quota="10m"

    # Pretend wget is the Iceweasel/Firefox browser
    wget_user_agent="Mozilla/5.0 \
                     (X11; Linux x86_64; rv:38.0) \
		     Gecko/20100101 Firefox/38.0 Iceweasel/38.2.1"

    export ${!geo_ip_*} ${!bash_*} ${!wget_*} ${!mysql_*}

fi
