/*----------------------------------------------------------------------
   Program Name:  create_billing.sql
   Author Name:   Michael McLaughlin
   Date:          26-Dec-2016
  ----------------------------------------------------------------------*/

DROP TABLE bill;
DROP SEQUENCE bill_s;

CREATE TABLE bill
( bill_id      NUMBER
, bill_number  VARCHAR2(20)
, bill_text    VARCHAR2(20));

CREATE SEQUENCE bill_s;

DROP TABLE detail;
DROP SEQUENCE detail_s;

CREATE TABLE detail
( detail_id      NUMBER
, bill_id        NUMBER
, detail_number  VARCHAR2(20)
, detail_text    VARCHAR2(20));

CREATE SEQUENCE detail_s;


COL bill_id        FORMAT 9999    HEADING "Bill|ID #"
COL bill_number    FORMAT A10     HEADING "Bill|Number"
COL bill_text      FORMAT A10     HEADING "Bill Text"
COL detail_id      FORMAT 999999  HEADING "Detail|ID #"
COL detail_number  FORMAT A10     HEADING "Detail|Number"
COL detail_text    FORMAT A10     HEADING "Detail Text"
SELECT b.bill_id
,      b.bill_number
,      b.bill_text
,      d.bill_id
,      d.detail_id
,      d.detail_number
,      d.detail_text
FROM   bill b JOIN detail d
ON     b.bill_id = d.bill_id;