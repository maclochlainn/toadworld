/*----------------------------------------------------------------------
   Program Name:  create_procedure.sql
   Author Name:   Michael McLaughlin
   Date:          26-Dec-2016
  ----------------------------------------------------------------------*/

DROP PROCEDURE insert_bill_detail;

CREATE PROCEDURE insert_bill_detail
( pv_bill_number    VARCHAR2
, pv_bill_text      VARCHAR2
, pv_detail_number  VARCHAR2
, pv_detail_text    VARCHAR2 ) IS

BEGIN
  /* Declare a save point. */
  SAVEPOINT all_or_nothing;

  /* Insert into the bill table. */
  INSERT
  INTO   bill
  ( bill_id
  , bill_number
  , bill_text )
  VALUES
  ( bill_s.nextval
  , pv_bill_number
  , pv_bill_text );

  /* Insert into the detail table. */
  INSERT
  INTO   detail
  ( detail_id
  , bill_id
  , detail_number
  , detail_text )
  VALUES
  ( detail_s.nextval
  , bill_s.currval
  , pv_detail_number
  , pv_detail_text );

  /* Commit both insert statements. */
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
