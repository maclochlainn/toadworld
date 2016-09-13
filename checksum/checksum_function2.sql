/*
||  Name:    checksum_function2.sql
||  Author:  Michael McLaughlin
||  Date:    30-Aug-2016
|| -------------------------------------------------------------------
||  Description:
||    - Creates a checksum function, supporting types, and test case.
||
|| -------------------------------------------------------------------
||  Instructions:
||    You should run this as any user, or change the user_source
||    to dba_source when run as a privileged user.
||
|| -------------------------------------------------------------------
||  Revisions:
||    
||
*/

/* Drop from dependent to independent types. */
DROP TYPE size_tab;
DROP TYPE size_set;

/* Create an object type. */
CREATE OR REPLACE
  TYPE size_set IS OBJECT
  ( nrows  NUMBER
  , nsize  NUMBER );
/

/* Create a SQL collection of an object type. */
CREATE OR REPLACE
  TYPE size_tab IS TABLE OF size_set;
/

/* Create a check sum function for stored libraries. */
CREATE OR REPLACE
  FUNCTION check_sum
  ( pv_name  VARCHAR2
  , pv_type  VARCHAR2
  , pv_link  VARCHAR2 ) RETURN size_tab IS

  /* Declare a record type and variable of the record type. */  
  TYPE line IS RECORD (text VARCHAR2(200));
  TYPE coll IS TABLE OF line;

  /* Declare a counter and generic statement. */
  lv_size    NUMBER := 0;
  lv_char    NUMBER;
  lv_line    NUMBER;
  lv_coll    COLL;
  lv_tab     SIZE_TAB := size_tab(size_set(null,null));
  lv_stmt    VARCHAR2(4000);
  lv_cursor  SYS_REFCURSOR;
BEGIN
  /* Declare dynamic cursor as a string.
  ||  - Table name should be user_source for local schema.
  ||  - Table name should be dba_source for global schemas.
  */
  lv_stmt := 'SELECT   text'||CHR(10)
          || 'FROM     user_source@'||pv_link||CHR(10)
          || 'WHERE    name = '''||pv_name||''''||CHR(10)
          || 'AND      type = '''||pv_type||'''';

  /* Conditional compilation debugging. */
  $IF $$DEBUG = 1 $THEN parse_rows(lv_stmt); $END

  /* Open and read cursor. */
  OPEN lv_cursor FOR lv_stmt;
  FETCH lv_cursor BULK COLLECT INTO lv_coll;
  CLOSE lv_cursor;

  /* Sum the ASCII characters of lines into a total. */
  FOR i IN 1..lv_coll.COUNT LOOP
    lv_line := 0;
    FOR j IN 1..LENGTH(lv_coll(i).text) LOOP
      lv_char := ASCII(SUBSTR(lv_coll(i).text,j,1));
      lv_line := lv_line + lv_char;
    END LOOP;
    lv_size := lv_size + lv_line;
  END LOOP;

  /* Translate to object structure. */
  lv_tab(1).nrows := lv_coll.COUNT;
  lv_tab(1).nsize := lv_size;

  /* Return code length. */
  RETURN lv_tab;
END;
/

/* Test function against local schema. */
SELECT *
FROM   TABLE(check_sum('CHECK_SUM','FUNCTION','XE'));