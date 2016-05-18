/*
||  Name:    create_html_range.sql
||  Author:  Michael McLaughlin
||  Date:    17-May-2016
|| -------------------------------------------------------------------
||  Description:
||    - Creates a dynamic web page that uses an array of values.
||
||    - The parameter names are all "ids" and values are 30 character
||      variable length strings.
||
|| -------------------------------------------------------------------
||  Instructions:
||    You should run this as the STUDENT user.
||
||    You can call this with the following URL if you're testing on
||    a standalone instance on the localhost:
||
||    http://localhost:8080/db/html_table_range?ids=1006&ids=1014
||
|| -------------------------------------------------------------------
||  Revisions:
||    
||
*/

CREATE OR REPLACE
  PROCEDURE html_table_range
  ( ids  OWA_UTIL.IDENT_ARR ) IS

    css  CLOB := '<style>'||CHR(10)
              ||   'table {background-color:aaaaaa}'||CHR(10)
              ||   'th.c1 {font-size:18px;font-family:Verdana, Verdana, san-serif;color:#ffffff;font-weight:bold;text-align:center;background-color:#3bbfff;width:50px;}'||CHR(10)
              ||   'th.c2 {font-size:18px;font-family:Verdana, Verdana, san-serif;color:#ffffff;font-weight:bold;text-align:center;background-color:#3bbfff;width:550px;}'||CHR(10)
              ||   'th.c3 {font-size:18px;font-family:Verdana, Verdana, san-serif;color:#ffffff;font-weight:bold;text-align:center;background-color:#3bbfff;width:100px;}'||CHR(10)
              ||   'td.c1 {font-size:16px;font-family:Verdana, Verdana, san-serif;color:#000000;text-align:center;background-color:#eeeeee;}'||CHR(10)
              ||   'td.c2 {font-size:16px;font-family:Verdana, Verdana, san-serif;color:#000000;text-align:left;background-color:#eeeeee;}'||CHR(10)
              ||   'td.c3 {font-size:16px;font-family:Verdana, Verdana, san-serif;color:#000000;text-align:right;background-color:#eeeeee;}'||CHR(10)
              || '</style>';

    /* Declare a range determined list of film items. */
    CURSOR get_items
    ( start_id  NUMBER
    , end_id    NUMBER ) IS
      SELECT   item_id AS item_id
      ,        item_title
      ||       CASE
                 WHEN item_subtitle IS NOT NULL THEN
                   ': '|| item_subtitle
               END AS item_title
      ,        release_date AS release_date
      FROM     item
      WHERE    item_id BETWEEN start_id AND end_id
      ORDER BY item_id;

  BEGIN
    /* Open HTML page with the PL/SQL toolkit. */
    htp.print('<!DOCTYPE html>');
    htp.print(css);
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
    FOR i IN get_items(ids(1),ids(2)) LOOP
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







