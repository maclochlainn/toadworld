/*
||  Name:    xdb_setup1.sql
||  Author:  Michael McLaughlin
||  Date:    29-Feb-2016
|| -------------------------------------------------------------------
||  Description:
||    This checks for the default port and resets it when necessary,
||    creates a STUDENT_DAD, and authorizes the STUDENT_DAD.
|| -------------------------------------------------------------------
||  Revisions:
||    
||
*/

/* Block checks and resets default port. */
DECLARE
  lv_port  NUMBER;
BEGIN
  SELECT dbms_xdb.gethttpport()
  INTO   lv_port
  FROM dual;

  /* Check for default port and reset. */
  IF NOT lv_port = 8080 THEN
    EXECUTE dbms_xdb.sethttpport(8080);
  END IF;
END;
/

/* Block creates a data access descriptor (DAD). */
BEGIN
  dbms_epg.create_dad(
      dad_name => 'STUDENT_DAD'
    , path =>     '/studentdb/*');
END;
/

/* Block authorizes a data access descriptor (DAD). */
BEGIN
  dbms_epg.authorize_dad(
     dad_name => 'STUDENT_DAD'
   , user => 'STUDENT');
END;
/

