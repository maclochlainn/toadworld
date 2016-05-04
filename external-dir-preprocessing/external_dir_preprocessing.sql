/*
||  Name:    setup_virtual_dir.sql
||  Author:  Michael McLaughlin
||  Date:    30-Apr-2016
|| -------------------------------------------------------------------
||  Description:
||    - Designed to show you how to create virtual directories and
||      grant privileges on the virtual tables to the STUDENT user.
|| -------------------------------------------------------------------
||  Instructions:
||    You should run this as the SYSTEM user.
|| -------------------------------------------------------------------
||  Revisions:
||    
||
*/

/* Creates a virtual directory for the Windows OS. The following
   is remarked out because Linux or Unix is more common. If you
   are running Windows OS remove the single line comments. */
-- CREATE DIRECTORY upload AS 'C:\Data\Upload';
-- CREATE DIRECTORY log AS 'C:\Data\Log';
-- CREATE DIRECTORY preproc AS 'C:\Data\Preproc';

/* Creates a virtual directory for the Linux/Unix OS. If you are
   running the Windows OS put single line comments in front of
   the following Linux or Unix commands. */
CREATE DIRECTORY upload AS '/u01/app/oracle/upload';
CREATE DIRECTORY log AS '/u01/app/oracle/log';
CREATE DIRECTORY preproc AS '/u01/app/oracle/preproc';

/* Grants privileges to the virtual directories. */
GRANT read ON DIRECTORY upload TO student;
GRANT read, write ON DIRECTORY log TO student;
GRANT read, execute ON DIRECTORY preproc TO student;