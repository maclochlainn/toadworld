/*
||  Name:    xdb_setup1.sql
||  Author:  Michael McLaughlin
||  Date:    29-Feb-2016
|| -------------------------------------------------------------------
||  Description:
||    - Designed to configure standalone XDB Server for PL/SQL
||      programs that run from an unsecured HTTP URL.
||
||    - This checks for the default port and resets it when necessary,
||      necessary creates a STUDENT_DAD Data Access Descriptor (DAD),
||      and authorizes the STUDENT_DAD to run programs.
|| -------------------------------------------------------------------
||  Instructions:
||    You should run this as the SYSTEM user inside 
|| -------------------------------------------------------------------
||  Revisions:
||    
||
*/

/* Block checks and resets default port. */
DECLARE
  lv_port  NUMBER;
BEGIN
  SELECT dbms_xdb.gethttpport()
  INTO   lv_port
  FROM dual;

  /* Check for default port and reset. */
  IF NOT lv_port = 8080 THEN
    EXECUTE dbms_xdb.sethttpport(8080);
  END IF;
END;
/

/* Block creates a data access descriptor (DAD) when one does not exist. */
DECLARE
  /* Declare variables. */
  lv_path_name  VARCHAR2(80);
  lv_dad_name   VARCHAR2(80);

  /* Declare DAD discovery. */
  CURSOR c
  ( cv_path_name  VARCHAR2
  , cv_dad_name   VARCHAR2 ) IS
    SELECT   null
    FROM     xdb.xdb$config cfg CROSS JOIN
             TABLE(XMLSequence( extract(cfg.object_value
             ,                 '/xdbconfig/sysconfig/protocolconfig/httpconfig'
             ||                '/webappconfig/servletconfig/servlet-mappings'
             ||                '/servlet-mapping'))) map CROSS JOIN
             TABLE(XMLSequence( extract(cfg.object_value
             ,                 '/xdbconfig/sysconfig/protocolconfig/httpconfig'
             ||                '/webappconfig/servletconfig/servlet-list'
             ||                '/servlet[servlet-language="PL/SQL"]'
             ,                 'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"'))) dad
    WHERE    extractValue( value(map)
             ,            '/servlet-mapping/servlet-name'
             ,            'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') =
               extractValue( value(dad)
               ,            '/servlet/servlet-name'
               ,            'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
    AND      extractValue( value(map)
             ,            '/servlet-mapping/servlet-pattern'
             ,            'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') = cv_path_name
    AND      extractValue( value(map)
             ,            '/servlet-mapping/servlet-name'
             ,            'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') = cv_dad_name;

BEGIN
  OPEN c(lv_path_name, lv_dad_name);
  IF c%NOTFOUND THEN
    dbms_epg.create_dad(
      dad_name => lv_dad_name
    , path =>     lv_path_name);
  END IF;
  CLOSE c;
END;
/

/* Block authorizes a data access descriptor (DAD). */
DECLARE
  /* Declare variables. */
  lv_dad_name   VARCHAR2(80);

  /* Declare DAD discovery. */
  CURSOR c
  ( cv_dad_name   VARCHAR2 ) IS
    SELECT   deda.username
    FROM     dba_epg_dad_authorization deda
    WHERE    deda.dad_name = 'STUDENT_DAD';
BEGIN
  FOR i IN c(lv_dad_name) LOOP
    dbms_epg.authorize_dad(
      dad_name => lv_dad_name
    , user => i.username);
  END LOOP;
END;
/
