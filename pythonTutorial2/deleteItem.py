# ----------------------------------------------------------------------
#  Program Name:  deleteItem.py
#  Author Name:   Michael McLaughlin
#  Date:          26-Nov-2016
# ----------------------------------------------------------------------

# Import the Oracle library.
import cx_Oracle
import re
import sys

# Declare variables.
sItemTitle = 'Star Trek Beyond'

try:
  # Create a connection.
  db = cx_Oracle.connect("student/student@xe")

  # Create a cursor.
  cursor = db.cursor()

  # Execute a query.
  stmt = "DELETE FROM item"                + "\n" + \
         "WHERE  item_title = :bItemTitle"

  print stmt

  # Parse the statement by replacing line returns with a single
  # whitespace, replacing multiple whitespaces with single spaces.
  stmt = re.sub('\s+',' ',stmt.replace('\n',' ').replace('\r',''))

  # Declare a dynamic statement.
  cursor.execute(stmt, bItemTitle = sItemTitle )

  # Commit the inserted value.
  db.commit()
 
except cx_Oracle.DatabaseError, e:
  error, = e.args
  print >> sys.stderr, "Oracle-Error-Code:", error.code
  print >> sys.stderr, "Oracle-Error-Message:", error.message
 
finally:
  # Close cursor and connection. 
  cursor.close()
  db.close()