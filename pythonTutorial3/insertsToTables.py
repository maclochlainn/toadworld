# ----------------------------------------------------------------------
#  Program Name:  insertsToTables.py
#  Author Name:   Michael McLaughlin
#  Date:          26-Dec-2016
# ----------------------------------------------------------------------

# Import the Oracle library.
import cx_Oracle
import re
import sys

# Declare variables.
sBillNumber = '2016-001'
sBillText = 'Invoice'
sDetailNumber = '01'
sDetailText = 'Mileage'

try:
  # Create a connection.
  db = cx_Oracle.connect("student/student@xe")

  # Set a starting transaction point.
  db.begin()

  # Create a cursor.
  cursor = db.cursor()

  # Execute an INSERT statement.
  stmt = "INSERT"            + "\n" + \
         "INTO   bill"       + "\n" + \
         "( bill_id"         + "\n" + \
         ", bill_number"     + "\n" + \
         ", bill_text )"     + "\n" + \
         "VALUES"            + "\n" + \
         "( bill_s.nextval"  + "\n" + \
         ", :bBillNumber"    + "\n" + \
         ", :bBillText )"

  # Parse the statement by replacing line returns with a single
  # whitespace, replacing multiple whitespaces with single spaces.
  stmt = re.sub('\s+',' ',stmt.replace('\n',' ').replace('\r',''))

  # Declare a dynamic statement.
  cursor.execute(stmt, bBillNumber = sBillNumber         \
                     , bBillText = sBillText )

  # Create a cursor.
  cursor = db.cursor()

  # Execute an INSERT statement.
  stmt = "INSERT"              + "\n" + \
         "INTO   detail"       + "\n" + \
         "( detail_id"         + "\n" + \
         ", bill_id"           + "\n" + \
         ", detail_number"     + "\n" + \
         ", detail_text )"     + "\n" + \
         "VALUES"              + "\n" + \
         "( detail_s.nextval"  + "\n" + \
         ", bill_s.currval"    + "\n" + \
         ", :bDetailNumber"    + "\n" + \
         ", :bDetailText )"

  # Parse the statement by replacing line returns with a single
  # whitespace, replacing multiple whitespaces with single spaces.
  stmt = re.sub('\s+',' ',stmt.replace('\n',' ').replace('\r',''))

  # Declare a dynamic statement.
  cursor.execute(stmt, bDetailNumber = sDetailNumber         \
                     , bDetailText = sDetailText )


  # Commit the inserted value.
  db.commit()
 
except cx_Oracle.DatabaseError, e:
  error, = e.args
  db.rollback()
  print >> sys.stderr, "Oracle-Error-Code:", error.code
  print >> sys.stderr, "Oracle-Error-Message:", error.message
 
finally:
  # Close cursor and connection. 
  cursor.close()
  db.close()