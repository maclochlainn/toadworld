/*
||  Name:    xdb_setup2.sql
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

/* Enable the anonymous account. */
ALTER USER anonymous ACCOUNT UNLOCK;
ALTER USER anonymous IDENTIFIED BY null;

/* Create a HTML page for the STUDENT user. */
CREATE OR REPLACE PROCEDURE student.helloworld AS
BEGIN
  /* Set an HTML meta tag and render page. */
  owa_util.mime_header('text/html');  -- <META Content-type:text/html>
  htp.htmlopen;                       -- <HTML>
  htp.headopen;                       -- <HEAD>
  htp.htitle('Hello World!');         -- <TITLE>HelloWorld!</TITLE>
  htp.headclose;                      -- </HEAD>
  htp.bodyopen;                       -- <BODY>
  htp.line;                           -- <HR>
  htp.print('Hello ['||USER||']!');   -- Hello [dynamic user_name]!
  htp.line;                           -- <HR>
  htp.bodyclose;                      -- </BODY>
  htp.htmlclose;                      -- </HTML>
END HelloWorld;
/

/* Configure the XDB Server. */
SET SERVEROUTPUT ON
DECLARE
  lv_configxml XMLTYPE;
  lv_value     VARCHAR2(5) := 'true'; -- (true/false)
BEGIN
  lv_configxml := DBMS_XDB.cfg_get();

  /* Check for node element. */
  IF lv_configxml.existsNode('/xdbconfig/sysconfig/protocolconfig/httpconfig/allow-repository-anonymous-access') = 0 THEN
    /* Add element to node. */
    SELECT insertChildXML
             ( lv_configxml
             , '/xdbconfig/sysconfig/protocolconfig/httpconfig'
             , 'allow-repository-anonymous-access'
             , XMLType('<allow-repository-anonymous-access xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd">'
               || lv_value
               || '</allow-repository-anonymous-access>')
             , 'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
    INTO   lv_configxml
    FROM   dual;

    dbms_output.put_line('Element inserted.');
  ELSE
    /* Update existing element. */
    SELECT updateXML
             ( dbms_xdb.cfg_get()
             , '/xdbconfig/sysconfig/protocolconfig/httpconfig/allow-repository-anonymous-access/text()'
             , lv_value
             , 'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
    INTO   lv_configxml
    FROM   dual;

    dbms_output.put_line('Element updated.');
  END IF;

  /* Configure the node element. */
  dbms_xdb.cfg_update(lv_configxml);
  dbms_xdb.cfg_refresh;
END;
/

GRANT EXECUTE ON student.helloworld TO anonymous;
CREATE SYNONYM anonymous.helloworld FOR student.helloworld;

/* Block creates a data access descriptor (DAD) when one does not exist. */
DECLARE
  /* Declare variables. */
  lv_path_name  VARCHAR2(80) := '/db/*';
  lv_dad_name   VARCHAR2(80) := 'GENERIC_DAD';
  lv_result     VARCHAR2(1);

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
  FETCH c INTO lv_result;
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
  /* Create record type for authorization cursor. */
  TYPE dad_authorization IS RECORD
  ( dad_name     VARCHAR2(80)
  , username     VARCHAR2(80)
  , auth_schema  VARCHAR2(80));

  /* Declare variables. */
  lv_dad_name   VARCHAR2(80) := 'STUDENT_DAD';
  lv_authority  AUTH_SCHEMA;

  /* Declare DAD discovery. */
  CURSOR c
  ( cv_dad_name   VARCHAR2 ) IS
    SELECT   deda.username
    FROM     dba_epg_dad_authorization deda
    WHERE    deda.dad_name = lv_dad_name;

  /* Verify a DAD authorization. */
  CURSOR v
  ( cv_dad_name  VARCHAR2 ) IS
    SELECT   cfg.dad_name
    ,        cfg.username
    ,        CASE
               WHEN cfg.username = 'ANONYMOUS' THEN 'Anonymous'
               WHEN auth.username IS NULL THEN
                 CASE
                   WHEN cfg.username IS NULL THEN 'Dynamic'
                   ELSE 'Dynamic Restricted'
                 END
               ELSE 'Static'
             END auth_schema
    FROM    (SELECT   extractValue( value(dad)
                      ,            '/servlet/servlet-name'
                      ,            'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') dad_name
             ,        extractValue( value(dad)
                      ,            '/servlet/plsql/database-username'
                      ,            'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') username
             FROM     xdb.xdb$config cfg CROSS JOIN
                      TABLE(XMLSequence(extract( cfg.object_value
                                       ,        '/xdbconfig/sysconfig/protocolconfig/httpconfig'
                                       ||       '/webappconfig/servletconfig/servlet-list'
                                       ||       '/servlet[servlet-language="PL/SQL"]'
                                       ,        'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"'))) dad) cfg,
                      dba_epg_dad_authorization auth
    WHERE    cfg.dad_name = auth.dad_name(+)
    AND      cfg.username = auth.username(+)
    AND      cfg.dad_name = cv_dad_name;
BEGIN
  FOR i IN c(lv_dad_name) LOOP
    OPEN v(lv_dad_name);
    FETCH v INTO lv_authority;
    IF v%NOTFOUND THEN
      dbms_epg.authorize_dad(
        dad_name => lv_dad_name
      , user => i.username);
    END IF;
    CLOSE v;
  END LOOP;
END;
/

DECLARE
  /* Declare a local collection type. */
  TYPE list IS TABLE OF VARCHAR2(80);

  /* Declare a local list of local collection type. */
  lv_parameter_list  LIST := list('database-username'
                                 ,'nls-language');

  /* Declare a local record structure. */
  TYPE dad_parameter IS RECORD
  ( dad_name         VARCHAR2(80)
  , parameter_name   VARCHAR2(80)
  , parameter_value  VARCHAR2(80));

  /* Declare Database Attribute Descriptor (DAD). */
  lv_dad_name   VARCHAR2(80) := 'GENERIC_DAD';
  lv_parameter  DAD_PARAMETER;

  /* Declare a cursor to discover attributes. */
  CURSOR c 
  ( cv_dad_name   VARCHAR2
  , cv_parameter  VARCHAR2 ) IS
    SELECT   extractValue( value(dad)
             ,            '/servlet/servlet-name'
             ,            'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') dad_name
    ,        value(param).getRootElement() param_name
    ,        extractValue(value(param), '/*') param_value
    FROM     xdb.xdb$config cfg CROSS JOIN
             TABLE(XMLSequence(extract( cfg.object_value
                               ,       '/xdbconfig/sysconfig/protocolconfig/httpconfig'
                               ||      '/webappconfig/servletconfig/servlet-list'
                               ||      '/servlet[servlet-language="PL/SQL"]'
                               ,       'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"'))) dad CROSS JOIN
             TABLE(XMLSequence(extract( value(dad)
                               ,       '/servlet/plsql/*'
                               ,       'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"'))) param
    WHERE    extractValue( value(dad)
             ,            '/servlet/servlet-name'
             ,            'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') = cv_dad_name
    AND      value(param).getRootElement() = cv_parameter;
BEGIN
  FOR i IN 1..lv_parameter_list.COUNT LOOP
    OPEN c (lv_dad_name, lv_parameter_list(i));
    FETCH c INTO lv_parameter;
    IF c%NOTFOUND THEN
      dbms_epg.set_dad_attribute(
          dad_name => lv_parameter.dad_name
        , attr_name => lv_parameter.parameter_name
        , attr_value => lv_parameter.parameter_value);
    END IF;
    CLOSE c;
  END LOOP;
END;
/
