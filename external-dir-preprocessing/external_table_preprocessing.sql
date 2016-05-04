/*
||  Name:    external_table_preprocessing.sql
||  Author:  Michael McLaughlin
||  Date:    30-Apr-2016
|| -------------------------------------------------------------------
||  Description:
||    - Designed to show you how to create virtual directories and
||      grant privileges on the virtual tables to the STUDENT user.
||
||    - Create an external table with a preprocessing shell script.
|| -------------------------------------------------------------------
||  Instructions:
||    You should run this as the SYSTEM user.
|| -------------------------------------------------------------------
||  Revisions:
||    
||
*/

/* Create a DIRECTORY_LIST external table with preprocessing. */
CREATE TABLE directory_list
( file_name VARCHAR2(60))
  ORGANIZATION EXTERNAL
  ( TYPE oracle_loader
    DEFAULT DIRECTORY preproc
    ACCESS PARAMETERS
    ( RECORDS DELIMITED BY NEWLINE CHARACTERSET US7ASCII
      PREPROCESSOR preproc:'list2dir.sh'
      BADFILE 'LOG':'dir.bad'
      DISCARDFILE 'LOG':'dir.dis'
      LOGFILE 'LOG':'dir.log'
      FIELDS TERMINATED BY ','
      OPTIONALLY ENCLOSED BY "'"
      MISSING FIELD VALUES ARE NULL)
    LOCATION ('list2dir.sh'))
  REJECT LIMIT UNLIMITED;