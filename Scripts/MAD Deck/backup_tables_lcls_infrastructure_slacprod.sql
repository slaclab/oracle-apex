SET SERVEROUTPUT ON SIZE UNLIMITED
SET TIMING ON
SPOOL BACKUP_LCLS_INFRASTRUCTURE_TABLES_SLACPROD.LOG

PROMPT = BEGIN =

DECLARE
  V_TABLE_LIST     VARCHAR2(32767);
  V_ERRMSG         VARCHAR2(1000);
  V_DELIMITER      VARCHAR2(1) := ',';

  C_UI                   CONSTANT         VARCHAR2(200)   := USER || '@' || SYS_CONTEXT('USERENV', 'DB_NAME');

  BACKUP_PROCESS_ERROR    EXCEPTION;
  
BEGIN

  V_TABLE_LIST := 'BEAMLINES,LCLS_ELEMENTS,LCLS_ELEMENTS_JN,SYMBOLS_UPLOAD_LOG,SYMBOLS_UPLOAD,SYMBOLS_UPLOAD_JN,LTU_UPLOAD_LOG,LTU_UPLOAD,LTU_UPLOAD_JN,LCLS_INVENTORY,LCLS_INVENTORY_JN,LCLS_INVENTORY_DEVICES,LCLS_INVENTORY_DOCUMENTS,LCLS_INVENTORY_LOCATIONS,LCLS_INVENTORY_URLS';

  V_ERRMSG := NULL;
  
  --------
  
  LCLS_INFRASTRUCTURE.GLOBAL_PKG.MAKE_TABLE_BACKUP (V_TABLE_LIST, V_ERRMSG, V_DELIMITER);

  IF ( V_ERRMSG IS NULL ) THEN
    DBMS_OUTPUT.PUT_LINE('PROCESS: BACKUP TABLES FOR ' || C_UI ||' CREATED.');
  ELSE
    RAISE BACKUP_PROCESS_ERROR;
  END IF;
  
  RETURN;
  
  
  EXCEPTION
    WHEN BACKUP_PROCESS_ERROR THEN
      V_ERRMSG := SUBSTR(C_UI || ': ' || V_ERRMSG,1,1000);
      RAISE_APPLICATION_ERROR(-20010, V_ERRMSG);

    WHEN OTHERS THEN
      V_ERRMSG := SUBSTR(C_UI || ': OTHERS ERROR=>' || SQLERRM,1,1000);
      RAISE_APPLICATION_ERROR(-20020, V_ERRMSG);

END;
/

PROMPT = DONE =

SPOOL OFF