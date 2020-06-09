#!/bin/bash -x

source trap.sh

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#              applications via a MySQL database.
#
# Copyright (C) 2016-2019 Isaac Lewis

# Returns the most recent tuesday in yyyymmdd format.
most_recent_tuesday() {

    date --date="$datein -$(( ($(date --date="$datein" +%u) + 5) % 7 )) days" +%Y%m%d

}

# Download the file from the URL specified in the first argument to
# the absolute path specified in the second argument.
wget_file() {

    local wget_url=$1;

    wget --clobber \
         --inet4-only \
	 --output-document="$2" \
	 --quota="${wget_quota}" \
	 --tries="1" \
	 --user-agent="${wget_user_agent}" \
	 --server-response \
	 "${wget_url}"

}

i=1
max_tries=48
while (( 1 ))
do

# Make sure this script only runs as the geo-ip user.
if [ "$USER" != "geo-ip" ]; then
    geo_ip_error "download.sh must be run as the geo-ip user"
fi

geo_ip_archive_date="$(most_recent_tuesday)"

if [ -z "$maxmind_license_key" ]; then
    geo_ip_error "variable maxmind_license_key must be set to a valid license key"
fi

# URL for the archive file
wget_url_fn="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=${maxmind_license_key}&suffix=zip"

# Desired absolute path to the archive file
geo_ip_fn="${geo_ip_home}/downloads/GeoLite2-Country-CSV_${geo_ip_archive_date}.zip"

## Perform the download with wget.

# Make sure the download directory exists.
mkdir -p "$(dirname ${geo_ip_fn})"

# If the archive file does not exist, download it.
if [ ! -e "${geo_ip_fn}" ] ; then
    wget_file $wget_url_fn $geo_ip_fn
fi

# URL for the checksum file
wget_url_checksum_fn="${wget_url_fn}.sha256"

# Desired absolue path to the corresponding checksum file
geo_ip_checksum_fn="${geo_ip_fn}.sha256"

# If the checksum file does not exist, download it.
if [ ! -e "${geo_ip_checksum_fn}" ] ; then
    wget_file $wget_url_checksum_fn $geo_ip_checksum_fn
fi

# If both of the requested files have been downloaded, exit the loop.
if [[ -e "${geo_ip_fn}" && -e "${geo_ip_checksum_fn}" ]] ; then
    break;
fi

# If the maximum number of tries has been reached, then raise an
# error.
if [ $i -eq $max_tries ]; then
    geo_ip_error "Download(s) failed."
fi

# Wait at least 30 min but not more than 1 hr before the next try.
wt=$(( 30 + $RANDOM % 31 ))
echo "Retrying in $wt minutes."
sleep ${wt}m

(( i++ ))
done
