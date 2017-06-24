#!/bin/bash -x

# Exit immediately if a pipeline exits with a non-zero status.
set -e

echo "--------------------------------------------"
echo "| User                      | Pass         |"
echo "--------------------------------------------"
echo "| mysql_root_pass           | ${mysql_root_pass} |"
echo "| mysql_geo_ip_pass         | ${mysql_geo_ip_pass} |"
echo "| mysql_geo_ip_updater_pass | ${mysql_geo_ip_updater_pass} |"
echo "--------------------------------------------"
echo
echo "These passwords are stored in root-env.sh"
