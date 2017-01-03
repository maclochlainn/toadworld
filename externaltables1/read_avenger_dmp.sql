/*
||  Name:    read_avengers_dmp.sql
||  Author:  Michael McLaughlin
||  Date:    03-Jan-2017
|| -------------------------------------------------------------------
||  Description:
||    - Creates an Oracle external file.
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
( avenger_id      NUMBER
, first_name      VARCHAR2(20)
, last_name       VARCHAR2(20)
, character_name  VARCHAR2(20))
  ORGANIZATION EXTERNAL
  ( TYPE oracle_datapump
    DEFAULT DIRECTORY upload
    LOCATION ('avenger_export.dmp'));