-- <copyright file="RAISE_MESSAGE_UDF.sql" company="Snowflake Inc">
--        Copyright (c) 2019-2025 Snowflake Inc. All rights reserved.
-- </copyright>

CREATE OR REPLACE PROCEDURE PUBLIC.RAISE_MESSAGE_UDF(LEVEL VARCHAR, MESSAGE VARCHAR, ARGS VARIANT)
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "udf",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
AS
$$
    DECLARE
        MY_EXCEPTION EXCEPTION (-20002, 'To view the EXCEPTION MESSAGE, you need to check the log.');
        SC_RAISE_MESSAGE VARCHAR;
    BEGIN
        SC_RAISE_MESSAGE := STRING_FORMAT_UDF(MESSAGE, ARGS);
        IF (LEVEL = 'EXCEPTION') THEN
            SYSTEM$LOG_ERROR(SC_RAISE_MESSAGE);
            RAISE MY_EXCEPTION;
        ELSEIF (LEVEL = 'WARNING') THEN
            SYSTEM$LOG_WARN(SC_RAISE_MESSAGE);
            RETURN 'Warning printed successfully';
        ELSE
            SYSTEM$LOG_INFO(SC_RAISE_MESSAGE);
            RETURN 'Message printed successfully';
        END IF;
    END;
$$;
