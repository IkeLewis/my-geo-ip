#!/bin/bash -x

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#              applications via a MySQL database.
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
geo_ip_act="Build"
