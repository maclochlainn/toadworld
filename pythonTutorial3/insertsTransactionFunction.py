# ----------------------------------------------------------------------
#  Program Name:  insertsTransactionFunction.py
#  Author Name:   Michael McLaughlin
#  Date:          26-Dec-2016
# ----------------------------------------------------------------------

# Import the Oracle library.
import cx_Oracle
import re
import sys

# Declare variables.
sBillNumber = '2016-004'
sBillText = 'Invoice'
sDetailNumber = '01'
sDetailText = 'Mileagexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

# Hold return value.
fRetVal = 0

# Create a sequence for a procedure call.
param = (sBillNumber, sBillText, sDetailNumber, sDetailText)

try:
  # Create a connection.
  db = cx_Oracle.connect("student/student@xe")

  # Create a cursor.
  cursor = db.cursor()

  # Call a stored procedure.
  fRetVal = cursor.callfunc( 'insert_bill_detail_func', cx_Oracle.NUMBER, param)

  # Check for successful function call or failure number.
  if fRetVal == 0:
    print "Success"
  else:
    print "Failure [" + str(int(fRetVal)) + "]"

except cx_Oracle.DatabaseError, e:
  error, = e.args
  print >> sys.stderr, "Oracle-Error-Code:", error.code
  print >> sys.stderr, "Oracle-Error-Message:", error.message
 
finally:
  # Close cursor and connection. 
  cursor.close()
  db.close()