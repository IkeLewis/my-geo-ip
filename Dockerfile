# Usage:
#
# 1) Change to the directory containing this Dockerfile.  Then run
#
# $ docker build --tag=my-geo-ip:latest .
#
# to build the my-geo-ip image.
#
# 2) Run the container (using the default data directory):
#
# $ docker run --name my-geo-ip -emysql_geo_ip_pass="test" -d
# my-geo-ip:latest
#
# 3) Connect to MySQL
#
# $ docker run -it --link my-geo-ip:mysql --rm mysql sh -c 'exec mysql
# -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -ugeo_ip
# -p"test"'
#
# See https://hub.docker.com/_/mysql/ for more MySQL options.
#

# Extend the official MySQL Base Image
FROM mysql:8.0.19

ARG maxmind_license_key

RUN /bin/bash -x -c 'apt-get update && \
                     apt-get upgrade -y && \
                     apt-get install -y cron git gettext make policycoreutils procps strace unzip wget'

RUN /bin/bash -x -c 'git clone https://github.com/IkeLewis/my-geo-ip && \
		     cd my-geo-ip && \
		     make && \
		     make install'

VOLUME /root
VOLUME /home/geo-ip
VOLUME /var/lib/my-geo-ip

ENTRYPOINT ["/my-geo-ip/docker-entrypoint.sh"]
