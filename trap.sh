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

function exit_handler () {
    st=$?
    # Remove temporary files.
    if [ -e "$geo_ip_tmp" ]; then
	rm -rf "$geo_ip_tmp"
	[ $? -eq 0 ] && echo "Removed temporary files"
	echo "";
    fi

    if [ $st -ne 0 ]; then
	caller
	echo "$geo_ip_act failed"
    else
	echo "$geo_ip_act successful"
    fi

}

function geo_ip_error () {

    # Raises a geo_ip_error
    # Optional:
    # $1 -- error message

    em=$1
    [ "$em" ] && { 1>&2 echo -e "$em"; }

    exit 1
}

function quiet () {

    # Executes a given command in a subshell where by default all
    # output is discarded.
    
    ( 1>/dev/null 2>&1 $@ )    
    
}

function exit_status () {

    # Prints the exit status for a given command.  The command is
    # executed in a subshell where by default errors are not trapped
    # and all output is discarded.
    
    ( set +e && quiet $@ )
    es=$?
    echo $es
}

trap exit_handler EXIT;
