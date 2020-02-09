[![Build Status](https://travis-ci.org/IkeLewis/my-geo-ip.svg?branch=master)](https://travis-ci.org/IkeLewis/my-geo-ip)

my-geo-ip
==========

The my-geo-ip docker repository provides country-level geo-ip services
to clients via a MySQL database. The data comes from the freely
available GeoLite2 databases provided by
https://www.maxmind.com. Maxmind currently offers the GeoLite2
databases in 2 formats MMDB (a proprietary format) and a CSV
format. If a distributed storage model is desired, Maxmind's database
may be more appropriate.  This repo uses a centralized storage
model. The API is written in SQL and stored on the database so that an
application only needs to be able to log in to MySQL as the geo-ip
user to use geo-ip services.

Use Cases
---------

My-geo-ip may be used in stateful firewalls and public servers
(e.g. mail & web servers) for classifying IP's.  Also, it may be used
to improve internationalization support for websites.

API
---

The API consists of a single SQL function:

```SQL
info(<ip-address>)
```

The info function takes a single IP address as a string argument and
returns the geo-IP information associated with that address (see API
Usage Examples below).

Security Considerations
-----------------------

To enhance security, my-geo-ip runs in an isolated docker container
that exposes the port 3306 (MySQL) to its host.

Considerable thought was given to within-container security; MySQL is
configured to only accept remote connections for the user 'geo_ip' who
has read-only access to the database.  The updating process always
runs as a non-root system user (geo-ip) inside the docker container.
All downloads are made with wget with 'https' as the specified
protocol.

Installation
------------

1) Obtain a license key from maxmind for the GeoLite2 databases.

2) At a terminal type

```
$ docker pull ikelewis/my-geo-ip

$ docker run --rm --name my-geo-ip -emaxmind_license_key=<license-key> \
-emysql_geo_ip_pass="test" -d ikelewis/my-geo-ip
```

API Usage Examples
------------------

## Example 1 (Terminal):

For the basic installation

```
$ docker run -it --link my-geo-ip:mysql --rm mysql sh -c 'exec mysql \
-h"$MYSQL_PORT_3306_TCP_ADDR" -P"3306" -ugeo_ip -p"test"'
```

You should now be at a mysql prompt.

```
mysql > CALL geo_ip.info('012.034.056.078')\G
```
Sample Output

```
*************************** 1. row ***************************
                          date: 2015-11-03
                    geoname_id: 6252001
                        min_ip: 203554816
                        max_ip: 203620351
 registered_country_geoname_id: 6252001
represented_country_geoname_id:
            is_anonymous_proxy: 0
         is_satellite_provider: 0
                   locale_code: en
                continent_code: NA
                continent_name: North America
              country_iso_code: US
                  country_name: United States
1 row in set (0.01 sec)

Query OK, 0 rows affected (0.03 sec)
```
## Example 2 (Java):

This is a partial example; in order for it to work the code below
needs to be able to connect to my-geo-ip. One solution (for
production) is to run the code in a java container linked to
my-geo-ip.  Another solution (for development) is to run the java code
on your host and bind my-geo-ip's MySQL port to your host's MySQL
port.

```java
import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;

public class JavaExample {

	public static void main(String[] args) throws SQLException {
		//Get a connection to the database.
		Connection conn = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306","geo-ip", "<pass>");

		//Make a call to 'geo_ip.info' via the public API.
		CallableStatement cs = conn.prepareCall("CALL geo_ip.info('74.26.183.54');");
		cs.execute();

		//Store the result set and the result set's meta data.
		ResultSet rs = cs.getResultSet();
		ResultSetMetaData rsm = rs.getMetaData();

		//Print all column names and their values.
		cs.getResultSet().first();
		for (int i = 1; i <= rsm.getColumnCount(); i++) {
			System.out.println(rsm.getColumnName(i)+": "+rs.getString(i));
		}

		//Print just the value of the 'country_name' column.
		System.out.println("\n" + cs.getResultSet().getString("country_name"));
	}

}
```
Sample Output

```
date: 2015-11-03
geoname_id: 6252001
min_ip: 1242562560
max_ip: 1243611135
registered_country_geoname_id: 6252001
represented_country_geoname_id:
is_anonymous_proxy: 0
is_satellite_provider: 0
locale_code: en
continent_code: NA
continent_name: North America
country_iso_code: US
country_name: United States

United States
```

Updates
-------

* Clients don't have to wait for updates to complete.

* Clients may receive updated results before an update is complete.

* Updates occur automatically.

As an example suppose that an update is only 70% complete when an
application makes a request to my-geo-ip.  If the request can be
satisfied using the updated rows of the database, my-geo-ip will do
so, otherwise the request will be satisfied with the rows that haven't
been updated yet.

Removal
-------

```
$ docker rmi ikelewis/my-geo-ip
```

References
----------

[1] https://dev.maxmind.com/geoip/geoip2/geolite2/