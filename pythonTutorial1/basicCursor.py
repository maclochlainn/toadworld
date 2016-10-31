# ----------------------------------------------------------------------
#  Program Name:  basicCursor.py
#  Author Name:   Michael McLaughlin
#  Date:          30-Oct-2016
# ----------------------------------------------------------------------

# Import the Oracle library.
import cx_Oracle
 
try:
  # Create a connection.
  db = cx_Oracle.connect("student/student@xe")
 
  # Create a cursor.
  cursor = db.cursor()
 
  # Execute a query.
  cursor.execute("SELECT 'Hello world!' FROM dual")
 
  # Read the contents of the cursor.
  for row in cursor:
    print (row[0]) 
 
except cx_Oracle.DatabaseError, e:
  error, = e.args
  print >> sys.stderr, "Oracle-Error-Code:", error.code
  print >> sys.stderr, "Oracle-Error-Message:", error.message
 
finally:
  # Close cursor and connection. 
  cursor.close()
  db.close()
