#!/bin/bash

# Copyright (c) 2015 Isaac Lewis all rights reserved. 

# Exit immediately if a pipeline exits with a non-zero status.
set -e

# Load all required environment variables.
source env.sh

# Set any traps.
source trap.sh

# Set the type of action being performed.
geo_ip_act="Build"

