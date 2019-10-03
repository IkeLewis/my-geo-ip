#!/bin/bash

#source /usr/share/mysql/mysql-helpers

mysql_start () {
    mysqld &
    STARTTIMEOUT=10
    verify_server start
}

mysql_stop () {
    STOPTIMEOUT=10
    killall -u mysql
    verify_server stop
}

# Fetch value from config files
# Usage: get_mysql_option [section] [option] [default value]
get_mysql_option() {
    if pathfind my_print_defaults; then
	RESULT=$(my_print_defaults --show "$1" | sed -n "s/^--$2=//p" | tail -n 1)
    fi
    if [ -z "$RESULT" ]; then
	RESULT="$3"
    fi
    echo $RESULT
}
