/*
||  Name:    setup_auth_function.sql
||  Author:  Michael McLaughlin
||  Date:    06-May-2016
|| -------------------------------------------------------------------
||  Description:
||    - Designed to configure a web authentication function, and
||      return a record structure that must be converted through
||      a query.
|| -------------------------------------------------------------------
||  Instructions:
||    You should run this as the STUDENT user inside 
|| -------------------------------------------------------------------
||  Revisions:
||    
||
*/

-- Set echo on.
SET ECHO ON

BEGIN
  FOR i IN (SELECT table_name
            FROM user_tables WHERE table_name = UPPER('application')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || i.table_name;
  END LOOP;
END;
/

DROP TABLE application_user;
CREATE TABLE application_user
( user_id         NUMBER       CONSTRAINT pk_application_user1  PRIMARY KEY
, user_name       VARCHAR2(20) CONSTRAINT nn_application_user1  NOT NULL
, user_password   VARCHAR2(40) CONSTRAINT nn_application_user2  NOT NULL
, user_role       VARCHAR2(20) CONSTRAINT nn_application_user3  NOT NULL
, user_group_id   NUMBER       CONSTRAINT nn_application_user4  NOT NULL
, user_type       NUMBER       CONSTRAINT nn_application_user5  NOT NULL
, start_date      DATE         CONSTRAINT nn_application_user6  NOT NULL
, end_date        DATE
, first_name      VARCHAR2(20) CONSTRAINT nn_application_user7  NOT NULL
, middle_name     VARCHAR2(20)
, last_name       VARCHAR2(20) CONSTRAINT nn_application_user8  NOT NULL
, created_by      NUMBER       CONSTRAINT nn_application_user9  NOT NULL
, creation_date   DATE         CONSTRAINT nn_application_user10 NOT NULL
, last_updated_by NUMBER       CONSTRAINT nn_application_user11 NOT NULL
, last_update_date DATE        CONSTRAINT nn_application_user12 NOT NULL
, CONSTRAINT un_application_user1 UNIQUE(user_name));

BEGIN
  FOR i IN (SELECT sequence_name
            FROM user_sequences WHERE sequence_name = UPPER('application_user_s')) LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || i.sequence_name;
  END LOOP;
END;
/
CREATE SEQUENCE application_user_s;

INSERT INTO application_user VALUES
( application_user_s.nextval
,'potterhj','c0b137fe2d792459f26ff763cce44574a5b5ab03'
,'System Admin', 2, 1, SYSDATE, null, 'Harry', 'James', 'Potter'
, 1, SYSDATE, 1, SYSDATE);
INSERT INTO application_user VALUES
( application_user_s.nextval
,'weasilyr','35675e68f4b5af7b995d9205ad0fc43842f16450'
,'Guest', 1, 1, SYSDATE, null, 'Ronald', null, 'Weasily'
, 1, SYSDATE, 1, SYSDATE);
INSERT INTO application_user VALUES
( application_user_s.nextval
,'longbottomn','35675e68f4b5af7b995d9205ad0fc43842f16450'
,'Guest', 1, 1, SYSDATE, null, 'Neville', null, 'Longbottom'
, 1, SYSDATE, 1, SYSDATE);
INSERT INTO application_user VALUES
( application_user_s.nextval
,'holmess','c0b137fe2d792459f26ff763cce44574a5b5ab03'
,'DBA', 3, 1, SYSDATE, null, 'Sherlock', null, 'Holmes'
, 1, SYSDATE, 1, SYSDATE);
INSERT INTO application_user VALUES
( application_user_s.nextval
,'watsonj','c0b137fe2d792459f26ff763cce44574a5b5ab03'
,'DBA', 3, 1, SYSDATE, null, 'John', 'H', 'Watson'
, 1, SYSDATE, 1, SYSDATE);

BEGIN
  FOR i IN (SELECT null
            FROM   user_tables
            WHERE  table_name = 'SYSTEM_SESSION') LOOP
    EXECUTE IMMEDIATE 'DROP TABLE system_session CASCADE CONSTRAINTS';
  END LOOP;
  FOR i IN (SELECT null
            FROM   user_sequences
            WHERE  sequence_name = 'SYSTEM_SESSION_S') LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE system_session_s';
  END LOOP;
END;
/

-- Create SYSTEM_SESSION table.
CREATE TABLE system_session
( session_id        NUMBER       CONSTRAINT pk_ss1 PRIMARY KEY
, session_number    VARCHAR2(30) CONSTRAINT nn_ss1 NOT NULL
, remote_address    VARCHAR2(15) CONSTRAINT nn_ss2 NOT NULL
, user_id           NUMBER       CONSTRAINT nn_ss3 NOT NULL
, created_by        NUMBER       CONSTRAINT nn_ss4 NOT NULL
, creation_date     DATE         CONSTRAINT nn_ss5 NOT NULL
, last_updated_by   NUMBER       CONSTRAINT nn_ss6 NOT NULL
, last_update_date  DATE         CONSTRAINT nn_ss7 NOT NULL);

-- Create sequence.
CREATE SEQUENCE system_session_s START WITH 1001;

-- Conditionally drop objects.
BEGIN
  FOR i IN (SELECT null
            FROM   user_tables
            WHERE  table_name = 'INVALID_SESSION') LOOP
    EXECUTE IMMEDIATE 'DROP TABLE invalid_session CASCADE CONSTRAINTS';
  END LOOP;
  FOR i IN (SELECT null
            FROM   user_sequences
            WHERE  sequence_name = 'INVALID_SESSION_S') LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE invalid_session_s';
  END LOOP;
END;
/

-- Create INVALID_SESSION table.
CREATE TABLE invalid_session
( session_id        NUMBER       CONSTRAINT pk_invalid_session1 PRIMARY KEY
, session_number    VARCHAR2(30) CONSTRAINT nn_invalid_session1 NOT NULL
, remote_address    VARCHAR2(15) CONSTRAINT nn_invalid_session2 NOT NULL
, created_by        NUMBER       CONSTRAINT nn_invalid_session3 NOT NULL
, creation_date     DATE         CONSTRAINT nn_invalid_session4 NOT NULL
, last_updated_by   NUMBER       CONSTRAINT nn_invalid_session5 NOT NULL
, last_update_date  DATE         CONSTRAINT nn_invalid_session6 NOT NULL);

-- Create sequence.
CREATE SEQUENCE invalid_session_s START WITH 1001;

-- DROP FUNCTION set_login;

CREATE OR REPLACE FUNCTION set_login
( pv_login_name  VARCHAR2 ) RETURN VARCHAR2 IS

  /* Declare a success flag to false. */
  lv_success_flag  NUMBER := 0;

  /* Declare a common name for a return variable. */
  client_info  VARCHAR2(64) := NULL;
 
  /* Declare variables to hold cursor return values. */
  lv_login_id  NUMBER;
  lv_group_id  NUMBER;
 
  /* Declare a cursor to return an authorized user id. */
  CURSOR authorize_cursor
  ( cv_login_name  VARCHAR2 ) IS
    SELECT   a.user_id
    ,        a.user_group_id
    FROM     application_user a
    WHERE    a.user_name = cv_login_name;

BEGIN

  /* Check whether login name something other than a null value. */
  IF pv_login_name IS NOT NULL THEN
    /* Open, fetch, and close cursor. */ 
    OPEN  authorize_cursor(pv_login_name);
    FETCH authorize_cursor INTO lv_login_id, lv_group_id;
    CLOSE authorize_cursor;
 
    /* Set the CLIENT_INFO flag. */
    dbms_application_info.set_client_info(LPAD(lv_login_id,5,' ') || LPAD(lv_group_id,5,' '));
    dbms_application_info.read_client_info(client_info);

    /* Set success flag to true. */
    IF client_info IS NOT NULL THEN
      lv_success_flag := 1;
    END IF;
  END IF;
 
  /* Return the success flag. */
  RETURN lv_success_flag;
END;
/

show errors

SET SERVEROUTPUT ON SIZE UNLIMITED

SELECT set_login('potterhj') AS output FROM dual;

SELECT USERENV('CLIENT_INFO') FROM dual;

SELECT SYS_CONTEXT('userenv','client_info') FROM dual;

BEGIN
  FOR i IN (SELECT view_name
            FROM user_views WHERE view_name = UPPER('authorized_user')) LOOP
    EXECUTE IMMEDIATE 'DROP VIEW ' || i.view_name;
  END LOOP;
END;
/

CREATE OR REPLACE VIEW authorized_user AS
SELECT   au.user_id
,        au.user_name
,        au.user_role
,        au.last_name || ', ' || au.first_name || ' ' || NVL(au.middle_name,'') AS full_name
FROM     application_user au CROSS JOIN
        (SELECT
            TO_NUMBER(SUBSTR(SYS_CONTEXT('USERENV','CLIENT_INFO'),1,5)) AS login_id
          , TO_NUMBER(SUBSTR(SYS_CONTEXT('USERENV','CLIENT_INFO'),6,5)) AS group_id
         FROM     dual) fq
WHERE   (au.user_group_id = 1
AND      au.user_group_id = fq.group_id
AND      au.user_id = fq.login_id)
OR       fq.group_id = 2
OR      (fq.group_id > 2
AND      au.user_group_id = fq.group_id);

/* Query from the view. */
SELECT set_login('potterhj') AS output FROM dual;
SELECT user_name 
,      user_role
FROM authorized_user;

SELECT set_login('weasilyr') AS output FROM dual;
SELECT user_name
,      user_role
FROM authorized_user;

SELECT set_login('longbottomn') AS output FROM dual;
SELECT user_name
,      user_role
FROM authorized_user;

SELECT set_login('holmess') AS output FROM dual;
SELECT user_name
,      user_role
FROM authorized_user;

BEGIN
  FOR i IN (SELECT   type_name
            FROM     user_types 
            WHERE    type_name IN ( UPPER('authentication_t')
                                  , UPPER('authentication_tab'))
            ORDER BY type_name DESC) LOOP
    EXECUTE IMMEDIATE 'DROP TYPE ' || i.type_name || ' FORCE';
  END LOOP;
END;
/

CREATE OR REPLACE
  TYPE authentication_t IS OBJECT
  ( username   VARCHAR2(20)
  , password   VARCHAR2(40)
  , sessionid  VARCHAR2(30));
/

CREATE OR REPLACE
  TYPE authentication_tab IS TABLE OF authentication_t;
/ 

CREATE OR REPLACE FUNCTION authorize
( pv_username  VARCHAR2
, pv_password  VARCHAR2
, pv_session   VARCHAR2
, pv_raddress  VARCHAR2 ) RETURN authentication_t IS

  /* Declare session variable. */
  lv_session  VARCHAR2(30);

  /* Declare authentication_t instance. */
  lv_authentication_t  AUTHENTICATION_T := authentication_t(null,null,null);

  /* Define an authentication cursor. */
  CURSOR authenticate
  ( cv_username  VARCHAR2
  , cv_password  VARCHAR2 ) IS
    SELECT   user_id
    ,        user_group_id
    FROM     application_user
    WHERE    user_name = cv_username
    AND      user_password = cv_password
    AND      SYSDATE BETWEEN start_date AND NVL(end_date,SYSDATE);

  /* Declare a cursor for existing sessions. */
  CURSOR valid_session
  ( cv_session   VARCHAR2
  , cv_raddress  VARCHAR2 ) IS
    SELECT   ss.session_id
    ,        ss.session_number
    FROM     system_session ss
    WHERE    ss.session_number = cv_session
    AND      ss.remote_address = cv_raddress
    AND     (SYSDATE - ss.last_update_date) <= .003472222;

  /* Create an autonomous transaction. */
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  /* Write authentication records. */
  FOR i IN authenticate(pv_username, pv_password) LOOP
     /* Assign existing session ID values. */
    FOR j IN valid_session(pv_session, pv_raddress) LOOP
       lv_session := j.session_number;
    END LOOP;

    /* Write new session or update existing session. */
    IF NOT lv_session IS NULL THEN
      /* Update existing session in system_session table. */
      UPDATE   system_session
      SET      last_update_date = SYSDATE
      WHERE    session_number = pv_session
      AND      remote_address = pv_raddress;
    ELSE
       /* Insert new session into invalid_session table. */
      INSERT INTO system_session
      VALUES
      ( system_session_s.nextval
      , pv_session
      , pv_raddress
      , i.user_id
      , i.user_id
      , SYSDATE
      , i.user_id
      , SYSDATE );

      /* Assign session ID number. */
      lv_session := pv_session;
    END IF;
  END LOOP;
  /* Allocate space, assign instance, and return session ID value. */
  lv_authentication_t := authentication_t( username  => pv_username
                                         , password  => pv_password
                                         , sessionid => pv_session );
  /* Commit the records. */
  COMMIT;
  /* Return a record structure. */
  RETURN lv_authentication_t;
END;
/

LIST
SHOW ERRORS

BEGIN
  FOR i IN (SELECT table_name
            FROM   user_tables WHERE table_name = UPPER('unit_test')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || i.table_name;
  END LOOP;
END;
/

CREATE TABLE unit_test
( message  VARCHAR2(30));

BEGIN
  FOR i IN (SELECT trigger_name
            FROM   user_triggers WHERE trigger_name = UPPER('system_session_t')) LOOP
    EXECUTE IMMEDIATE 'DROP TRIGGER ' || i.trigger_name;
  END LOOP;
END;
/


CREATE OR REPLACE TRIGGER system_session_t
  AFTER UPDATE OF last_update_date ON system_session
BEGIN
  INSERT INTO unit_test VALUES ('Updated');
END;
/
  
LIST
SHOW ERRORS

VARIABLE result VARCHAR2(30)

DECLARE
  /* Declare authentication_t instance. */
  lv_authentication_t  AUTHENTICATION_T;
BEGIN
  /* Create instance of authentication_t type. */
  lv_authentication_t := authorize('potterhj'
                                  ,'c0b137fe2d792459f26ff763cce44574a5b5ab03'
                                  ,'session_test'
                                  ,'127.0.0.1');
  /* Print object instance. */
  dbms_output.put_line('Username  [' || lv_authentication_t.username  || ']');
  dbms_output.put_line('Password  [' || lv_authentication_t.password  || ']');
  dbms_output.put_line('SessionID [' || lv_authentication_t.sessionid || ']');
END;
/

DECLARE
  /* Declare authentication_t instance. */
  lv_authentication_t  AUTHENTICATION_T;
BEGIN
  /* Create instance of authentication_t type. */
  lv_authentication_t := authorize('potterhj'
                                  ,'c0b137fe2d792459f26ff763cce44574a5b5ab03'
                                  ,'session_test'
                                  ,'127.0.0.1');
  /* Print object instance. */
  dbms_output.put_line('Username  [' || lv_authentication_t.username  || ']');
  dbms_output.put_line('Password  [' || lv_authentication_t.password  || ']');
  dbms_output.put_line('SessionID [' || lv_authentication_t.sessionid || ']');
END;
/

SELECT *
FROM   TABLE(
         SELECT CAST(
                  COLLECT(
                    authorize(
                        pv_username => 'potterhj'
                      , pv_password => 'c0b137fe2d792459f26ff763cce44574a5b5ab03'
                      , pv_session  => 'session_test'
                      , pv_raddress => '127.0.0.1')) AS authentication_tab)
         FROM   dual);

-- Query the result from the system_session table.
SELECT   session_number AS session_number
,        remote_address AS remote_address
,        user_id AS user_id
,        TO_CHAR(SYSDATE,'DD-MON-YY HH24:MI:SS') AS actual_time
,        TO_CHAR(last_update_date,'DD-MON-YY HH24:MI:SS') AS last_update
FROM     system_session;
