#!/bin/bash -x

# my-geo-ip -- The my-geo-ip package provides geo-ip services to
#              applications via a MySQL database.
#
# Copyright (C) 2016-2019 Isaac Lewis

# Require this file for 'geo_ip_error'.
source trap.sh

LAST_ACTION=
MYSQL_RUNTIME=0

mysql_running () {
    pgrep -x "mysqld"
}

clock_tick() {

    before_status=$(mysql_status)
    sleep 1
    after_status=$(mysql_status)

    echo -n .

    # Technically this is not the exact runtime but only a lower bound
    # for it.
    if [ "$before_status" = "$after_status" ] && [ "$after_status" = "RUNNING" ]; then
	MYSQL_RUNTIME=$(( MYSQL_RUNTIME + 1 ))
    else
	MYSQL_RUNTIME=0
    fi
}

mysql_status () {

    if [ $(mysql_running) ]; then
	if [ $MYSQL_RUNTIME -ge 5 ]; then
	    echo "STARTED"
	else
	    echo "RUNNING"
	fi
    elif [ "$LAST_ACTION" = "START" ] ; then
        echo "ERRORED"
    else
	echo "STOPPED"
    fi

}

mysql_wait_until () {

    # Desired status must be either "STARTED" or "STOPPED"
    DESIRED_STATUS=$1
    TIMEOUT=$2

    if [ "${DESIRED_STATUS}" = "STARTED" ]; then
	TIMEOUT_MSG_ACTION="START"
    elif [ "${DESIRED_STATUS}" = "STOPPED" ]; then
	TIMEOUT_MSG_ACTION="STOP"
    else
	geo_ip_error "Invalid status: status must be either \"STARTED\" or \"STOPPED\""
    fi

    COUNT=0
    while [ ${COUNT} -lt ${TIMEOUT} ];
    do
	mysql_status_res="$(mysql_status)"
	if [ "$mysql_status_res" = "${DESIRED_STATUS}" ]; then
	    return 0
	elif [ "$mysql_status_res" = "ERRORED" ]; then
	    return 0
	fi
	clock_tick
	COUNT=$(( COUNT+1 ))
    done

    geo_ip_error "Timed out waiting for the MySQL server to ${TIMEOUT_MSG_ACTION}"

}

mysql_start () {

    if [ "$(mysql_status)" = "STARTED" ]; then
	geo_ip_error "Error: The MySQL server is already running"
    else
	LAST_ACTION="START"
	mysqld &
	TIMEOUT=30
	mysql_wait_until "STARTED" $TIMEOUT
    fi

}

mysql_stop () {

    if [ "$(mysql_status)" = "STOPPED" ]; then
	geo_ip_error "Error: The MySQL server is not running"
    else
	LAST_ACTION="STOP"
	pkill -x mysqld
	TIMEOUT=30
	mysql_wait_until "STOPPED" $TIMEOUT
    fi

}
