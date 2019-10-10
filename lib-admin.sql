-- my-geo-ip -- The my-geo-ip package provides geo-ip services to
--               applications via a MySQL database.
--
-- Copyright (C) 2015-2019 Isaac Lewis

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
