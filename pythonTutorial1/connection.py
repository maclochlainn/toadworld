# ----------------------------------------------------------------------
#  Program Name:  connection.py
#  Author Name:   Michael McLaughlin
#  Date:          30-Oct-2016
# ----------------------------------------------------------------------

# Import the Oracle library.
import cx_Oracle

try:
  # Create a connection.
  db = cx_Oracle.connect("student/student@xe")

  # Print a message.
  print "Connected to the Oracle " + db.version + " database."

except cx_Oracle.DatabaseError, e:
  error, = e.args
  print >> sys.stderr, "Oracle-Error-Code:", error.code
  print >> sys.stderr, "Oracle-Error-Message:", error.message

finally:
  # Close connection. 
  db.close()
