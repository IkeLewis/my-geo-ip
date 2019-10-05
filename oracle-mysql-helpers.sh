# Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

# Wait for server to start up (this requires the client package)
pinger () {
	while /bin/true ; do
		sleep 1
		mysqladmin ping >/dev/null 2>&1 && break
	done
}

# To avoid having hardcoded paths in the script, we do a search on the path, as suggested at:
# https://www.debian.org/doc/manuals/developers-reference/ch06.en.html#bpp-debian-maint-scripts
pathfind() {
	OLDIFS="$IFS"
	IFS=:
	for p in $PATH; do
		if [ -x "$p/$*" ]; then
			IFS="$OLDIFS"
			return 0
		fi
	done
	IFS="$OLDIFS"
	return 1
}

# Fetch value from config files
# Usage: get_mysql_option [section] [option] [default value]
get_mysql_option() {
	if pathfind my_print_defaults; then
		RESULT=$(my_print_defaults "$1" | sed -n "s/^--$2=//p" | tail -n 1)
	fi
	if [ -z "$RESULT" ]; then
		RESULT="$3"
	fi
	echo $RESULT
}

# Check if server is running
get_running () {
	MYSQLDATA=$(get_mysql_option mysqld datadir "/var/lib/mysql")
	PIDFILE=$(get_mysql_option mysqld_safe pid-file "")
	if [ -z "$PIDFILE" ]; then
		PIDFILE=$(get_mysql_option mysqld pid-file "$MYSQLDATA/$(hostname).pid")
	fi
	if [ -e "$PIDFILE" ] && [ -d "/proc/$(cat "$PIDFILE")" ]; then
		echo 1
	else
		echo 0
	fi
}

# Runs an arbitrary init sql file supplied in $1. Does not require login access
run_init_sql() {
	tmpdir=$(mktemp -d)
	chown mysql:mysql "$tmpdir"
	mysqld --user=mysql --init-file="$1" --socket="$tmpdir/mysqld.sock" --pid-file="$tmpdir/mysqld.pid" > /dev/null 2>&1
	result=$?
	rm -rf "$tmpdir"
	return $result
}

# Verify that everything the server needs to run is set up
verify_ready() {

		MYSQLDATA=$(get_mysql_option mysqld datadir "/var/lib/mysql")
		MYSQLFILES=$(get_mysql_option mysqld secure-file-priv "/var/lib/mysql-files")
		MYSQLKEYRING=$(dirname $(get_mysql_option mysqld keyring-file-data "/var/lib/mysql-keyring/keyring"))
		MYSQLLOG=$(dirname $(get_mysql_option mysqld log-error "/var/log/mysql/error.log"))
		MYSQLRUN=/var/run/mysqld

		if ! getent group mysql >/dev/null; then
			addgroup --system mysql >/dev/null
		fi

		if ! getent passwd mysql >/dev/null; then
			adduser --ingroup mysql --system --disabled-login --no-create-home --home ${MYSQLDATA} --shell /bin/false --gecos "MySQL Server" mysql >/dev/null
		fi
		ERROR_FLAG=0
		if [ ! -d ${MYSQLDATA} -a ! -L ${MYSQLDATA} ]; then
			if [ "$(dirname "${MYSQLDATA}")" = "/var/lib" ]; then
				install -d -m0750 -omysql -gmysql ${MYSQLDATA}
			else
				echo "Error: Datadir ${MYSQLDATA} does not exist. For security reasons the service will not automatically create directories outside /var/lib.."
				ERROR_FLAG=1
			fi
		fi

		if [ ! -d ${MYSQLFILES} -a ! -L ${MYSQLFILES} ]; then
			if [ "$(dirname "${MYSQLFILES}")" = "/var/lib" -o ${MYSQLFILES} = NULL ]; then
				install -d -m0770 -omysql -gmysql ${MYSQLFILES}
			else
				echo "Error: Secure-file-priv dir ${MYSQLFILES} does not exist. For security reasons the service will not automatically create directories outside /var/lib."
				ERROR_FLAG=1
			fi
		fi

		if [ ! -d ${MYSQLKEYRING} -a ! -L ${MYSQLKEYRING} ]; then
			if [ "$(dirname "${MYSQLKEYRING}")" = "/var/lib" ]; then
				install -d -m0750 -omysql -gmysql ${MYSQLKEYRING}
			else
				echo "Warning: Keyring dir ${MYSQLKEYRING} does not exist. For security reasons the service will not automatically create directories outside /var/lib. The server may not start correctly."
			fi
		fi

		if [ ! -d ${MYSQLLOG} -a ! -L ${MYSQLLOG} ]; then
			if [ "$(dirname "${MYSQLLOG}")" = "/var/log" ]; then
				install -d -m0750 -omysql -gadm ${MYSQLLOG}
				install /dev/null -m0640 -omysql -gadm ${MYSQLLOG}/error.log
			else
				echo "Error: Log dir ${MYSQLLOG} does not exist. For security reasons the service will not automatically create directories outside /var/log."
				ERROR_FLAG=1
			fi
		fi

		if [ ${ERROR_FLAG} = 1 ]; then
			echo "Errors found. Aborting."
			exit 1
		fi

		if [ ! -d ${MYSQLRUN} -a ! -L ${MYSQLRUN} ]; then
			install -d -m0755 -omysql -gmysql ${MYSQLRUN}
		fi
}

# Verify the database exists and is ssl ready
verify_database() {
	MYSQLDATA=$(get_mysql_option mysqld datadir "/var/lib/mysql")
	MYSQLFILES=$(get_mysql_option mysqld secure-file-priv "/var/lib/mysql-files")

	if [ ! -d "${MYSQLDATA}/mysql" ] && [ -d "${MYSQLFILES}" ]; then
		su - mysql -s /bin/bash -c "/usr/sbin/mysqld --initialize-insecure > /dev/null"
		SQL=$(mktemp -u ${MYSQLFILES}/XXXXXXXXXX)
		install /dev/null -m0600 -omysql -gmysql "${SQL}"
		cat << EOF > ${SQL}
USE mysql;
INSTALL PLUGIN auth_socket SONAME 'auth_socket.so';
ALTER USER 'root'@'localhost' IDENTIFIED WITH 'auth_socket';
SHUTDOWN;
EOF
		run_init_sql "$SQL"
		rm -f "$SQL"
	fi

	if [ -x /usr/bin/mysql_ssl_rsa_setup -a ! -e "${MYSQLDATA}/server-key.pem" ]; then
		mysql_ssl_rsa_setup --datadir="${MYSQLDATA}" --uid=mysql >/dev/null 2>&1
	fi
}

verify_server () {
	TIMEOUT=0
	if [ "${1}" = "start" ]; then
		TIMEOUT=${STARTTIMEOUT}
	elif [ "${1}" = "stop" ]; then
		TIMEOUT=${STOPTIMEOUT}
	fi

	COUNT=0
	while [ ${COUNT} -lt ${TIMEOUT} ];
	do
		COUNT=$(( COUNT+1 ))
		echo -n .
		if [ "${1}" = "start" ] && [ "$(get_running)" = 1 ]; then
			if [ -z ${2} ]; then
				echo
			fi
			return 0
		fi
		if [ "${1}" = "stop" ] && [ "$(get_running)" = 0 ]; then
			if [ -z ${2} ]; then
				echo
			fi
			return 0
		fi
		sleep 1
	done
	return 1
}
