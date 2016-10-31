# ----------------------------------------------------------------------
#  Program Name:  basicDynamicTable.py
#  Author Name:   Michael McLaughlin
#  Date:          30-Oct-2016
# ----------------------------------------------------------------------

# Import the Oracle library.
import cx_Oracle

sRate = 'PG-13'

try:
  # Create a connection.
  db = cx_Oracle.connect("student/student@xe")

  # Define a dynamic statment.
  stmt = "SELECT item_title, item_rating FROM item WHERE item_rating = :rating"

  # Create a cursor.
  cursor = db.cursor()

  # Execute a statement with a bind variable.
  cursor.execute(stmt, rating = sRate)

  # Read the contents of the cursor.
  for row in cursor:
    print (row[0], row[1]) 
 
except cx_Oracle.DatabaseError, e:
  error, = e.args
  print >> sys.stderr, "Oracle-Error-Code:", error.code
  print >> sys.stderr, "Oracle-Error-Message:", error.message
 
finally:
  # Close cursor and connection. 
  cursor.close()
  db.close()

