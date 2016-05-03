/*
||  Name:    encrypt.sql
||  Author:  Michael McLaughlin
||  Date:    30-Apr-2016
|| -------------------------------------------------------------------
||  Description:
||    - Designed to show you how to encrypt a clear text password,
||      and how to verify an encrypted password with user credentials.
|| -------------------------------------------------------------------
||  Instructions:
||    You should run this as the SYSTEM user inside 
|| -------------------------------------------------------------------
||  Revisions:
||    
||
*/

/* Create an encrypt function. */
CREATE OR REPLACE
  FUNCTION encrypt( password  VARCHAR2 ) RETURN RAW IS
    /* Declare local variables for encryption. */
    lv_key_string        VARCHAR2(40)  := 'EncryptKey'; 
    lv_key               RAW(64);
    lv_raw               RAW(64);
    lv_encrypted_data    RAW(64);
  BEGIN
    /* Dynamic assignment. */
    IF password IS NOT NULL THEN    
      /* Cast the password to a raw type. */
      lv_raw := utl_raw.cast_to_raw(password);
 
      /* Convert to a RAW 64-character key. */
      lv_key := utl_raw.cast_to_raw(lv_key_string);
      lv_key := RPAD(lv_key,64,'0');   
 
      /* Encrypt the salary before assigning it to the object type attribute */
      lv_encrypted_data := dbms_crypto.encrypt( lv_raw
                                              , dbms_crypto.encrypt_aes256
                                                + dbms_crypto.chain_cbc
                                                + dbms_crypto.pad_pkcs5
                                              , lv_key);
    ELSE
      /* Raise an application error. */
      RAISE_APPLICATION_ERROR(-20001,'An empty string does not encrypt.');
    END IF;

    /* Return a value from the function. */
    RETURN lv_encrypted_data;
  END encrypt;
  /

/* Test the query. */
COL encrypted_data FORMAT A64
COL encrypted_size FORMAT 999
SELECT  encrypt('Kitty@Spencer!1234') AS encrypted_data
,       length(encrypt('Kitty@Spencer!1234')) AS encrypted_size
FROM    dual;

/* Conditionally drop table. */ 
BEGIN
  FOR i IN (SELECT table_name
            FROM   user_tables
            WHERE  table_name = 'APP_USER') LOOP
    EXECUTE IMMEDIATE 'DROP TABLE app_user';
  END LOOP;
END;
/

/* Create APP_USER test table. */
CREATE TABLE app_user
( app_user_id    NUMBER CONSTRAINT pk_app_user PRIMARY KEY
, app_user_name  VARCHAR2(30)
, app_password   VARCHAR2(64));

/* Conditionally drop table. */ 
BEGIN
  FOR i IN (SELECT sequence_name
            FROM   user_sequences
            WHERE  sequence_name = 'APP_USER_S') LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE app_user_s';
  END LOOP;
END;
/

/* Create APP_USER_S sequence. */
CREATE SEQUENCE app_user_s START WITH 1001;

/* Insert user and encrypted password into table. */
INSERT INTO app_user
VALUES
( app_user_s.NEXTVAL
,'Johann Schmidt'
, encrypt('Kitty@Spencer!1234'));

/* Commit work. */
COMMIT;

/* Create a verification function. */
CREATE OR REPLACE
  FUNCTION verify
  ( user_name  VARCHAR2
  , password   VARCHAR2 ) RETURN NUMBER IS

  /* Default return value. */
  lv_result  NUMBER := 0;

  /* Application user cursor. */
  CURSOR c (cv_user_name  VARCHAR2) IS
    SELECT   app_password
    FROM     app_user
    WHERE    app_user_name = cv_user_name;
BEGIN
  /* Compare encrypted password. */
  FOR i IN c(user_name) LOOP
    IF encrypt(password) = i.app_password THEN
      lv_result := 1;
    END IF;
  END LOOP;

  /* Return the value. */
  RETURN lv_result;
END;
/

SHOW ERRORS

/* Query the verify function. */
SELECT   verify('Johann Schmidt','Kitty@Spencer!1234') AS result
FROM     dual;

/* Testing block. */
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  /* Declare print variable. */
  lv_output  VARCHAR2(64);
BEGIN
  /* Test function returns:
  || ======================
  ||  - True returns 1
  ||  - False returns 0
  */
  IF verify('Johann Schmidt','Kitty@Spencer!1234') = 1 THEN
    dbms_output.put_line('Result [It worked!]');
  ELSE
    dbms_output.put_line('Result [It failed!]');
  END IF;
END;
/
