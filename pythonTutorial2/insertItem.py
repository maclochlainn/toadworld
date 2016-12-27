# ----------------------------------------------------------------------
#  Program Name:  insertItem.py
#  Author Name:   Michael McLaughlin
#  Date:          26-Nov-2016
# ----------------------------------------------------------------------

# Import the Oracle library.
import cx_Oracle
import re
import sys

# Declare variables.
sBarcode = 'B01IS31U6S'
sType = 1014
sTitle = 'Star Trek Beyond'
sRating = 'PG-13'
sRatingAgency = 'MPAA'
sReleaseDate = '01-NOV-16'
sCreatedBy = 1
sCreationDate = '26-NOV-2016'
sLastUpdatedBy = 1
sLastUpdateDate = '26-NOV-2016'

try:
  # Create a connection.
  db = cx_Oracle.connect("student/student@xe")

  # Create a cursor.
  cursor = db.cursor()

  # Execute a query.
  stmt = "INSERT"               + "\n" + \
         "INTO   item"          + "\n" + \
         "( item_id"            + "\n" + \
         ", item_barcode"       + "\n" + \
         ", item_type"          + "\n" + \
         ", item_title"         + "\n" + \
         ", item_desc"          + "\n" + \
         ", item_rating"        + "\n" + \
         ", item_rating_agency" + "\n" + \
         ", item_release_date"  + "\n" + \
         ", created_by"         + "\n" + \
         ", creation_date"      + "\n" + \
         ", last_updated_by"    + "\n" + \
         ", last_update_date )" + "\n" + \
         "VALUES"               + "\n" + \
         "( item_s1.nextval"    + "\n" + \
         ", :bBarcode"          + "\n" + \
         ", :bType"             + "\n" + \
         ", :bTitle"            + "\n" + \
         ",  empty_clob()"      + "\n" + \
         ", :bRating"           + "\n" + \
         ", :bRatingAgency"     + "\n" + \
         ", :bReleaseDate"      + "\n" + \
         ", :bCreatedBy"        + "\n" + \
         ", :bCreationDate"     + "\n" + \
         ", :bLastUpdatedBy"    + "\n" + \
         ", :bLastUpdateDate )"

  print stmt

  # Parse the statement by replacing line returns with a single
  # whitespace, replacing multiple whitespaces with single spaces.
  stmt = re.sub('\s+',' ',stmt.replace('\n',' ').replace('\r',''))

  # Declare a dynamic statement.
  cursor.execute(stmt, bBarcode = sBarcode               \
                     , bType = sType                     \
                     , bTitle = sTitle                   \
                     , bRating = sRating                 \
                     , bRatingAgency = sRatingAgency     \
                     , bReleaseDate = sReleaseDate       \
                     , bCreatedBy = sCreatedBy           \
                     , bCreationDate = sCreationDate     \
                     , bLastUpdatedBy = sLastUpdatedBy   \
                     , bLastUpdateDate = sLastUpdateDate )

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