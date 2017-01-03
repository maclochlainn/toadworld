/*
||  Name:    create_avengers1.sql
||  Author:  Michael McLaughlin
||  Date:    03-Jan-2017
|| -------------------------------------------------------------------
||  Description:
||    - Creates a CSV reading external table.
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
      FIELDS TERMINATED BY ','
      OPTIONALLY ENCLOSED BY "'"
      MISSING FIELD VALUES ARE NULL)
    LOCATION ('avenger.csv'))
REJECT LIMIT UNLIMITED;