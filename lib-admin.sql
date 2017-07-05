-- my-geo-ip -- The my-geo-ip package provides geo-ip services to
--               applications via a MySQL database.
-- Copyright (C) 2016 Isaac Lewis

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

-- Copyright (c) 2015 Isaac Lewis all rights reserved. 

-- A small library of SQL utility functions.

-- TODO: consider modifying the 'EVAL' function to handle user
-- variables automatically; this would free the user from having to
-- use CONCAT.

DROP PROCEDURE IF EXISTS EVAL;
DELIMITER //
CREATE PROCEDURE EVAL(str VARCHAR(2048))
BEGIN
-- SELECT str;
SET @str2 = str;
PREPARE st FROM @str2;
EXECUTE st;
END //
DELIMITER ;

-- Note: the following may be used to obtain the correct data types
-- (for 'user', 'host', and 'password').
--
-- SHOW COLUMNS FROM mysql.user WHERE Field='user' OR Field='host' OR
-- Field='authentication_string'\G

DROP PROCEDURE IF EXISTS DROP_USER_IF_EXISTS;
DELIMITER //
CREATE PROCEDURE DROP_USER_IF_EXISTS(user_name VARCHAR(32), host_name VARCHAR(60))
BEGIN
IF (SELECT user FROM mysql.user WHERE user=user_name AND host=host_name) IS NOT NULL THEN
CALL EVAL(CONCAT("DROP USER '", user_name, "'@'", host_name, "';"));
END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS CREATE_USER;
DELIMITER //
CREATE PROCEDURE CREATE_USER(user_name VARCHAR(32), host_name VARCHAR(60), pass TEXT)
BEGIN
CALL EVAL(CONCAT("CREATE USER '", user_name, "'@'", host_name, "' IDENTIFIED BY '", pass, "';"));
END //
DELIMITER ;

DROP FUNCTION IF EXISTS USER_AUTH_STRING;
DELIMITER //
CREATE FUNCTION USER_AUTH_STRING(user_name CHAR(32))
RETURNS TEXT  DETERMINISTIC
BEGIN
RETURN (SELECT authentication_string FROM mysql.user WHERE USER=user_name);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS SET_USER_PASSWORD;
DELIMITER //
CREATE PROCEDURE SET_USER_PASSWORD(user_name CHAR(32), host_name CHAR(60), pass TEXT)
BEGIN
CALL EVAL(CONCAT("ALTER USER '", user_name, "'@'", host_name, "' IDENTIFIED BY '", pass, "';"));
END //
DELIMITER ;
