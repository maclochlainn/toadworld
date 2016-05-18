/*
||  Name:    create_html_items.sql
||  Author:  Michael McLaughlin
||  Date:    17-May-2016
|| -------------------------------------------------------------------
||  Description:
||    - Creates a dynamic web page that uses an array of values.
||
||    - The parameter names are all "ids" and values are 32,000 character
||      variable length strings.
||
|| -------------------------------------------------------------------
||  Instructions:
||    You should run this as the STUDENT user.
||
||    You can call this with the following URL if you're testing on
||    a standalone instance on the localhost:
||
||    http://localhost:8080/db/html_table_items?ids=1002&ids=1007&ids=1015&ids=1021
||
|| -------------------------------------------------------------------
||  Revisions:
||    
||
*/

-- Manage a SQL data type.
BEGIN
  FOR i IN (SELECT table_name
            FROM   user_tables
            WHERE  table_name = 'CSS') LOOP
    EXECUTE IMMEDIATE 'DROP TABLE '||i.table_name;
  END LOOP;
END;
/

-- Create a css table.
CREATE TABLE css
( css_id    NUMBER
, css_name  VARCHAR2(30)
, css_text  VARCHAR2(4000));

BEGIN
  FOR i IN (SELECT sequence_name
            FROM   user_sequences
            WHERE  sequence_name = 'CSS_S') LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE '||i.sequence_name;
  END LOOP;
END;
/

-- Create a sequence for the css table.
CREATE SEQUENCE css_s START WITH 1001;

-- Seed a cascading style sheet.
BEGIN
  INSERT INTO css
  ( css_id, css_name, css_text )
  VALUES
  (  css_s.NEXTVAL
  , 'blue-gray'
  , '<style>'||CHR(10)
  ||'  table {background-color:#ffffff}'||CHR(10)
  ||'  th.c1 {font-size:18px;font-family:Verdana, Verdana, san-serif;color:#ffffff;font-weight:bold;text-align:center;background-color:#3bbfff;width:50px;}'||CHR(10)
  ||'  th.c2 {font-size:18px;font-family:Verdana, Verdana, san-serif;color:#ffffff;font-weight:bold;text-align:center;background-color:#3bbfff;width:550px;}'||CHR(10)
  ||'  th.c3 {font-size:18px;font-family:Verdana, Verdana, san-serif;color:#ffffff;font-weight:bold;text-align:center;background-color:#3bbfff;width:100px;}'||CHR(10)
  ||'  td.c1 {font-size:16px;font-family:Verdana, Verdana, san-serif;color:#000000;text-align:center;background-color:#eeeeee;}'||CHR(10)
  ||'  td.c2 {font-size:16px;font-family:Verdana, Verdana, san-serif;color:#000000;text-align:left;background-color:#eeeeee;}'||CHR(10)
  ||'  td.c3 {font-size:16px;font-family:Verdana, Verdana, san-serif;color:#000000;text-align:right;background-color:#eeeeee;}'||CHR(10)
  ||'</style>');
END;
/

-- Commit the work.
COMMIT;

-- Verify cascading style sheet.
SET linesize 160
COL css_text FORMAT A160
SELECT css_text
FROM   css
WHERE  css_name = 'blue-gray';

-- Reset line size.
COL css_text FORMAT A80

-- Manage a SQL data type.
BEGIN
  FOR i IN (SELECT type_name
            FROM   user_types
            WHERE  type_name = 'LIST_IDS') LOOP
    EXECUTE IMMEDIATE 'DROP TYPE '||i.type_name;
  END LOOP;
END;
/

-- Create a collection type.
CREATE OR REPLACE
  TYPE list_ids IS TABLE OF NUMBER;
/

-- Create or replace stored procedure.
CREATE OR REPLACE
  PROCEDURE html_table_ids
  ( ids  OWA_UTIL.VC_ARR ) IS

    /* Declare a variable of the local ADT collection. */
    lv_list  LIST_IDS := list_ids();

    /* Declare a local Cascading Style Sheet. */
    lv_css  VARCHAR2(4000);

    /* Declare a range determined list of film items. */
    CURSOR get_items
    ( cv_ids  LIST_IDS ) IS
      SELECT   item_id AS item_id
      ,        item_title
      ||       CASE
                 WHEN item_subtitle IS NOT NULL THEN
                   ': '|| item_subtitle
               END AS item_title
      ,        release_date AS release_date
      FROM     item
      WHERE    item_id IN (SELECT *
                           FROM   TABLE(cv_ids))
      ORDER BY item_id;

  BEGIN
    /* Convert OWA_UTIL PL/SQL collection to SQL collection. */
    FOR i IN 1..ids.COUNT LOOP
       lv_list.EXTEND;
       lv_list(lv_list.COUNT) := ids(i);
    END LOOP;

    /* Assign the css to a local variable. */
    FOR i IN (SELECT css_text
              FROM   css
              WHERE  css_name = 'blue-gray') LOOP
      lv_css   := i.css_text;
    END LOOP;

    /* Open HTML page with the PL/SQL toolkit. */
    htp.print('<!DOCTYPE html>');
    htp.print(lv_css);
    htp.htmlopen;
    htp.headopen;
    htp.htitle('Item List');
    htp.headclose;
    htp.bodyopen;
    htp.line;

    /* Build HTML table with the PL/SQL toolkit. */
    htp.tableopen( cborder => 'style="border-style:solid;border-width: 5px;"');
    htp.tablerowopen;
    htp.tableheader( cvalue      => '#'
                   , cattributes => 'class="c1"' );
    htp.tableheader( cvalue      => 'Film Title'
                   , cattributes => 'class="c2"' );
    htp.tableheader( cvalue      => 'Release Date'
                   , cattributes => 'class="c3"' );
    htp.tablerowclose;

    /* Read the cursor values into the HTML table. */
    FOR i IN get_items(lv_list) LOOP
      htp.tablerowopen;
      htp.tabledata( cvalue      => i.item_id
                   , cattributes => 'class="c1"');
      htp.tabledata( cvalue      => i.item_title
                   , cattributes => 'class="c2"');
      htp.tabledata( cvalue      => i.release_date
                   , cattributes => 'class="c3"');
      htp.tablerowclose;
    END LOOP;

    /* Close HTML table. */
    htp.tableclose;

    /* Close HTML page. */
    htp.line;
    htp.bodyclose;
    htp.htmlclose;
END;
/







