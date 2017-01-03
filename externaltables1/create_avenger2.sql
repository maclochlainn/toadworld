/*
||  Name:    create_avengers2.sql
||  Author:  Michael McLaughlin
||  Date:    03-Jan-2017
|| -------------------------------------------------------------------
||  Description:
||    - Creates a character specific reading external table.
||
|| -------------------------------------------------------------------
||  Instructions:
||    You should run this as your student user.
||
|| -------------------------------------------------------------------
||  Revisions:
||    
||
*/

-- Drop avenger table.
DROP TABLE avenger;

-- Create an avenger table.
CREATE TABLE avenger
( avenger_id     NUMBER
, first_name     VARCHAR2(20)
, last_name       VARCHAR2(20)
, character_name VARCHAR2(20))
  ORGANIZATION EXTERNAL
  ( TYPE oracle_loader
    DEFAULT DIRECTORY upload
    ACCESS PARAMETERS
    ( RECORDS DELIMITED BY NEWLINE CHARACTERSET US7ASCII
      BADFILE     'UPLOAD':'avenger.bad'
      DISCARDFILE 'UPLOAD':'avenger.dis'
      LOGFILE     'UPLOAD':'avenger.log'
      FIELDS
      MISSING FIELD VALUES ARE NULL
      ( avenger_id     CHAR(4)
      , first_name     CHAR(20)
      , last_name      CHAR(20)
      , character_name CHAR(15)))
    LOCATION ('avenger2.csv'))
REJECT LIMIT UNLIMITED;