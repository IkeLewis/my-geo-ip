#!/bin/bash -x

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#              applications via a MySQL database.
#
# Copyright (C) 2016-2019 Isaac Lewis

## Setup environment variables and error handling.

$bash_set_cmd

# Set the shell options.
shopt -s extglob

# Load all required environment variables.
source env.sh

# Set any traps.
source trap.sh

##

# MySQL passwords to use when running a my-geo-ip container

if [ ! "$set_passwords" ]; then

    # Include flag (don't edit)
    export set_passwords=1

    ## Read new passwords (into their corresponding environment
    ## variables unless those variables are already set).

    if [[ ! "$mysql_root_pass" && -e /run/secrets/mysql_root_pass ]]; then
	mysql_root_pass=$(cat /run/secrets/mysql_root_pass)
    fi

    if [[ ! "$mysql_geo_ip_pass" && -e /run/secrets/mysql_geo_ip_pass ]]; then
	mysql_geo_ip_pass=$(cat /run/secrets/mysql_geo_ip_pass)
    fi

    if [[ ! "$mysql_geo_ip_updater_pass" && -e /run/secrets/mysql_geo_ip_updater_pass ]]; then
	mysql_geo_ip_updater_pass=$(cat /run/secrets/mysql_geo_ip_updater_pass)
    fi

    ##

    # Usage: set_user_password user_name host_name pass
    mysql_set_user_password () {
	echo "USE geo_ip; source /my-geo-ip/lib-admin.sql; CALL SET_USER_PASSWORD(\"$1\",\"$2\",\"$3\")" | mysql
    }

    ## Update the passwords (using the non-empty password-environment
    ## variables).

    if [ -n "$mysql_root_pass" ]; then
	mysql_set_user_password "root" "localhost" "$mysql_root_pass"
	# Generate the MySQL config for the root system user.
	envsubst < templates/root.my.cnf.tp  > "/root/.my.cnf"
    fi

    if [ -n "$mysql_geo_ip_pass" ]; then
	mysql_set_user_password "geo_ip" "%" "$mysql_geo_ip_pass"
    fi

    if [ -n "$mysql_geo_ip_updater_pass" ]; then
	mysql_set_user_password "geo_ip_updater" "localhost" "$mysql_geo_ip_updater_pass"
	# Generate the MySQL config for the geo-ip system user.
	envsubst < templates/geo-ip.my.cnf.tp > "$geo_ip_home/.my.cnf"
	chown geo-ip:geo-ip "$geo_ip_home/.my.cnf"

    fi

    ##
fi
