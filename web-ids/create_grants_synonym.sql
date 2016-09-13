/*
||  Name:    create_grants_synonym.sql
||  Author:  Michael McLaughlin
||  Date:    17-May-2016
|| -------------------------------------------------------------------
||  Description:
||    - Creates a set of grants and synonyms to support the examples.
||
|| -------------------------------------------------------------------
||  Instructions:
||    You should run this as the SYSTEM user.
||
|| -------------------------------------------------------------------
||  Revisions:
||    
||
*/

-- Conditionally revoke privileges on stored procedure.
BEGIN
  FOR i IN (SELECT grantor||'.'||table_name
            FROM   dba_tab_privs
            WHERE  grantee = 'ANONYMOUS'
            AND    grantor = 'STUDENT'
            AND    table_name = 'HTML_TABLE_RANGE') LOOP
    EXECUTE IMMEDIATE 'REVOKE EXECUTE ON student.html_table_range FROM anonymous';
  END LOOP;
END;
/

-- Grant execute on stored procedure.
GRANT EXECUTE ON student.html_table_range TO anonymous;

-- Conditionally drop synonym on stored procedure.
BEGIN
  FOR i IN (SELECT synonym_name
            FROM   dba_synonyms
            WHERE  synonym_name = 'HTML_TABLE_RANGE'
            AND    owner = 'ANONYMOUS') LOOP
    EXECUTE IMMEDIATE 'DROP SYNONYM anonymous.html_table_range';
  END LOOP;
END;
/

-- Create synonym to stored procedure.
CREATE SYNONYM anonymous.html_table_range FOR student.html_table_range;

-- Conditionally revoke privileges on stored procedure.
BEGIN
  FOR i IN (SELECT grantor||'.'||table_name
            FROM   dba_tab_privs
            WHERE  grantee = 'ANONYMOUS'
            AND    grantor = 'STUDENT'
            AND    table_name = 'HTML_TABLE_IDS') LOOP
    EXECUTE IMMEDIATE 'REVOKE EXECUTE ON student.html_table_ids FROM anonymous';
  END LOOP;
END;
/

-- Grant execute on stored procedure.
GRANT EXECUTE ON student.html_table_ids TO anonymous;

-- Conditionally drop synonym on stored procedure.
BEGIN
  FOR i IN (SELECT synonym_name
            FROM   dba_synonyms
            WHERE  synonym_name = 'HTML_TABLE_IDS'
            AND    owner = 'ANONYMOUS') LOOP
    EXECUTE IMMEDIATE 'DROP SYNONYM anonymous.html_table_ids';
  END LOOP;
END;
/

-- Create synonym to stored procedure.
CREATE SYNONYM anonymous.html_table_ids FOR student.html_table_ids;

-- Conditionally revoke privileges on stored procedure.
BEGIN
  FOR i IN (SELECT grantor||'.'||table_name
            FROM   dba_tab_privs
            WHERE  grantee = 'ANONYMOUS'
            AND    grantor = 'STUDENT'
            AND    table_name = 'HTML_TABLE_VALUES') LOOP
    EXECUTE IMMEDIATE 'REVOKE EXECUTE ON student.html_table_values FROM anonymous';
  END LOOP;
END;
/

-- Grant execute on stored procedure.
GRANT EXECUTE ON student.html_table_values TO anonymous;

-- Conditionally drop synonym on stored procedure.
BEGIN
  FOR i IN (SELECT synonym_name
            FROM   dba_synonyms
            WHERE  synonym_name = 'HTML_TABLE_VALUES'
            AND    owner = 'ANONYMOUS') LOOP
    EXECUTE IMMEDIATE 'DROP SYNONYM anonymous.html_table_values';
  END LOOP;
END;
/

-- Create synonym to stored procedure.
CREATE SYNONYM anonymous.html_table_values FOR student.html_table_values;

