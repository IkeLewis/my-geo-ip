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

# Extend the official MySQL Base Image
FROM mysql:8.0

RUN /bin/bash -x -c '\
                  # All lines except for the last one (and comments)
                  # end with '&& \'.

		  apt-get update && \
		  apt-get upgrade -y && \
                  apt-get install -y cron git gettext make policycoreutils procps strace unzip wget && \
		  cd / && \

		  # This dummy line is included so that we may simply
		  # toggle commenting on lines without having to
		  # remove '&& \' from the last line.

		  test 1 -eq 1\
		  '

RUN /bin/bash -x -c '\
                  # All lines except for the last one (and comments)
                  # end with '&& \'.

		  git clone https://github.com/IkeLewis/my-geo-ip && \
		  cd my-geo-ip && \
		  make && \
		  make install && \

		  test 1 -eq 1\
		  '

VOLUME /root
VOLUME /home/geo-ip
VOLUME /var/lib/my-geo-ip

ENTRYPOINT ["/my-geo-ip/docker-entrypoint.sh"]
