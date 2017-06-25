[![Build Status](https://travis-ci.org/IkeLewis/my-geo-ip.svg?branch=master)](https://travis-ci.org/IkeLewis/my-geo-ip)

my-geo-ip 
==========

The my-geo-ip repository provides country-level geo-ip services to
applications via a MySQL database. The data comes from the freely
available GeoLite2 databases provided by http://maxmind.com. Maxmind
currently offers the GeoLite2 databases in 2 formats MMDB (a
proprietary format) and a CSV format. If a distributed storage model
is desired, Maxmind's database may be more appropriate.  This repo
uses a centralized storage model. The API is written in SQL and stored
on the database so that an application only needs to be able to log in
to MySQL as the geo-ip user to use geo-ip services.

Supported Operating Systems
---------------------------

Currently only Debian 8 is supported. The code has not been tested on
other Linux systems yet.

Security Considerations
-----------------------

The MySQL user 'geo_ip' has read-only access to the database. However,
all input should still be sanitized before it is used in a query.  A
separate MySQL user 'geo_ip_updater' is used to keep the database
current. All updates to the database are made by the system user
'geo_ip' (not to be confused with the MySQL user of the same name)
using the MySQL user account 'geo_ip_updater'.  All downloads are made
with wget with 'https' as the specified protocol.

Installation
------------

Super user privileges are required to install my-geo-ip.

1) Install MySQL if it's not already installed.

```
$ apt-get install mysql-server
```

2) Extract the files to a location of your choice.

```
$ tar -xf my-geo-ip*
```

3) Set the current directory to the location of the extracted files,
and then type the standard 'make' commands:

```
$ cd my-geo*

$ make

$ make install
```

4) Enter the (previously set) MySQL root password.

5) Set the password for the MySQL user 'geo_ip'. 

6) Set the password for the MySQL user 'geo_ip_updater'.

A bunch of output should appear and then after a pause the words
'Install successful'. Please be patient while the 170,000+ rows are
being inserted. In repeated tests on a modest laptop, the installation
took from 15 to 23 seconds.

Updates
-------

All updates occur automatically on the first Tuesday of each month.

Removal
-------

Super user privileges are required to remove my-geo-ip.

There are two equivalent ways to perform the removal:

```
$ make clean
```
or

```
$ make uninstall
```

Api Usage Examples
------------------

## Example 1 (Terminal):

At a SSH or local terminal type:

```
$ mysql -u 'geo_ip' --password=<geo_ip_pass>

$ mysql > CALL geo_ip.info('012.034.056.078')\G
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