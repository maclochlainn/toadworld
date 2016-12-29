/*----------------------------------------------------------------------
   Program Name:  create_function.sql
   Author Name:   Michael McLaughlin
   Date:          26-Dec-2016
  ----------------------------------------------------------------------*/

DROP FUNCTION insert_bill_detail_func;

CREATE FUNCTION insert_bill_detail_func
( pv_bill_number    VARCHAR2
, pv_bill_text      VARCHAR2
, pv_detail_number  VARCHAR2
, pv_detail_text    VARCHAR2 ) RETURN NUMBER IS

  /* Decalre a return variable. */
  lv_return  NUMBER := 0;

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

  /* Return the default return value. */
  RETURN lv_return;
EXCEPTION
  WHEN OTHERS THEN
    lv_return := ABS(SQLCODE);
    ROLLBACK;
    RETURN lv_return;
END;
/
