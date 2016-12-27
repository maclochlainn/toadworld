# ----------------------------------------------------------------------
#  Program Name:  basicLookup.py
#  Author Name:   Michael McLaughlin
#  Date:          26-Nov-2016
# ----------------------------------------------------------------------

# Import the Oracle library.
import cx_Oracle
import re
import sys

dvd = ('DVD_FULL_SCREEN','DVD_WIDE_SCREEN')

try:
  # Create a connection.
  db = cx_Oracle.connect("student/student@xe")

  # Create a cursor.
  cursor = db.cursor()

  # Execute a query.
  stmt = "SELECT common_lookup_id"                   + "\n" + \
         "FROM   common_lookup"                      + "\n" + \
         "WHERE  common_lookup_table = 'ITEM'"       + "\n" + \
         "AND    common_lookup_column = 'ITEM_TYPE'" + "\n" + \
         "AND    common_lookup_type IN (:x,:y)"

  # Parse the statement by replacing line returns with a single
  # whitespace, replacing multiple whitespaces with single spaces.
  stmt = re.sub('\s+',' ',stmt.replace('\n',' ').replace('\r',''))

  # Declare a dynamic statement with a sequence.
  cursor.execute(stmt, x = dvd[0], y = dvd[1])

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