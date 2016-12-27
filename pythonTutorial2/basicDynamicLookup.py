# ----------------------------------------------------------------------
#  Program Name:  basicDynamicLookup.py
#  Author Name:   Michael McLaughlin
#  Date:          26-Nov-2016
# ----------------------------------------------------------------------

# Import the Oracle library.
import cx_Oracle
import re
import sys

# Define an alphabetic indexing tuple.
ind = tuple('abcdefghijklmnopqrstuvwxyz') 

# Define a parameter list and empty target list.
typ = ('DVD_FULL_SCREEN','DVD_WIDE_SCREEN','BLU-RAY')
mat = {}

try:
  # Create a connection.
  db = cx_Oracle.connect("student/student@xe")

  # Create a cursor.
  cursor = db.cursor()

  # Define a dynamic query.
  stmt = "SELECT common_lookup_id"                   + "\n" + \
         ",      common_lookup_type"                 + "\n" + \
         ",      common_lookup_meaning"              + "\n" + \
         "FROM   common_lookup"                      + "\n" + \
         "WHERE  common_lookup_table = 'ITEM'"       + "\n" + \
         "AND    common_lookup_column = 'ITEM_TYPE'" + "\n" + \
         "AND    common_lookup_type IN ("

  # Build dictionary and append dynamic bind list to statement.
  for i, e in enumerate(typ):
    mat[str(ind[i])] = typ[i]
    if i == len(typ) - 1:
      stmt = stmt + ":" + str(ind[i])
    else:
      stmt = stmt + ":" + str(ind[i]) + ", "

  # Close lookup value set.
  stmt =  stmt + ")" + "\n" \
         "ORDER BY 1"
  print stmt
  # Parse the statement by replacing line returns with a single
  # whitespace, replacing multiple whitespaces with single spaces.
  stmt = re.sub('\s+',' ',stmt.replace('\n',' ').replace('\r',''))

  # Declare a dynamic statement.
  cursor.execute(stmt, mat)

  # Read the contents of the cursor.
  for row in cursor:
    print (row)
 
except cx_Oracle.DatabaseError, e:
  error, = e.args
  print >> sys.stderr, "Oracle-Error-Code:", error.code
  print >> sys.stderr, "Oracle-Error-Message:", error.message
 
finally:
  # Close cursor and connection. 
  cursor.close()
  db.close()