/*
||  Name:    create_avengers_dmp.sql
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
DROP TABLE avenger_export;

-- Create an avenger table.
CREATE TABLE avenger_export
  ORGANIZATION EXTERNAL
 ( TYPE oracle_datapump
   DEFAULT DIRECTORY upload 
   LOCATION ('avenger_export.dmp')) AS
   SELECT   avenger_id
   ,        first_name
   ,        last_name
   ,        character_name
   FROM     avenger_internal;