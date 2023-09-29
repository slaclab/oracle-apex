
  CREATE TABLE "CAPTAR"."CABLETYP" 
   (	"CABLETYPE" VARCHAR2(15 BYTE), 
	"MANUFACTURE" VARCHAR2(15 BYTE), 
	"CABDESC" VARCHAR2(25 BYTE), 
	"JACKET" VARCHAR2(12 BYTE), 
	"NUMCOND" NUMBER(3,0), 
	"CHKBY" VARCHAR2(12 BYTE), 
	"CHKDATE" DATE, 
	"TYPE_ID" NUMBER, 
	"CREATED_BY" VARCHAR2(30 BYTE), 
	"CREATED_DATE" DATE, 
	"MODIFIED_BY" VARCHAR2(30 BYTE), 
	"MODIFIED_DATE" DATE, 
	 CONSTRAINT "CABLETYP_TYPE_ID_PK" PRIMARY KEY ("TYPE_ID")
  USING INDEX (CREATE UNIQUE INDEX "CAPTAR"."CABLETYP_AREA_CODE_UNQ" ON "CAPTAR"."CABLETYP" ("TYPE_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "CAPTAR_DATA" )  ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 40960 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "CAPTAR_DATA" ;

   COMMENT ON TABLE "CAPTAR"."CABLETYP"  IS 'This catalog table describes each?cable characteristic including number of conductors, manufacture, and?jacket material. The cable type follows that used in the existin SLC?Wirelist database.';

  CREATE UNIQUE INDEX "CAPTAR"."CABLETYP_UI" ON "CAPTAR"."CABLETYP" ("CABLETYPE") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 40960 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "CAPTAR_INDEX" ;

  CREATE OR REPLACE EDITIONABLE TRIGGER "CAPTAR"."BIUDR_CABLETYP" 
 BEFORE INSERT OR UPDATE OR DELETE 
 ON CABLETYP FOR EACH ROW
 
 BEGIN
 
    if inserting and :new.TYPE_ID is null then
       select CABLETYP_TYPE_ID_SEQ.nextval 
           into :new.TYPE_ID from dual;
    end if;
 
    if inserting and :new.created_by is null  then
       :new.created_by := NVL(V('APP_USER'),USER);
       :new.created_date := sysdate;
    end if;
    
    if updating then
       :new.modified_by := NVL(V('APP_USER'),USER);
       :new.modified_date := sysdate;
    end if;

    if inserting or updating then 
       :new.cabletype := upper(:new.cabletype);
       :new.manufacture:= upper(:new.manufacture);
    end if; 
     

END;

--------------- CONNTYPE ------------------------------------------------------------------------ 

/
ALTER TRIGGER "CAPTAR"."BIUDR_CABLETYP" ENABLE;

  CREATE OR REPLACE EDITIONABLE TRIGGER "CAPTAR"."AIUDR_CABLETYP" 
AFTER INSERT OR UPDATE OR DELETE ON CABLETYP
FOR EACH ROW
DECLARE
  jn_operation VARCHAR2(3);
  V_USER            VARCHAR2(100) := NVL(V('APP_USER'),USER);
  V_ERRMSG       VARCHAR2(1000);
  C_PROC    CONSTANT   VARCHAR2(30) := 'AIUDR_CABLETYP';
BEGIN

  V_ERRMSG := NULL;
--
    IF INSERTING THEN
       jn_operation := 'INS';
    ELSIF UPDATING THEN
       jn_operation := 'UPD';
    ELSIF DELETING THEN
       jn_operation := 'DEL';
    END IF;
--
    IF INSERTING THEN
       INSERT INTO CABLETYP_JN
       (JN_OPERATION,
	JN_ORACLE_USER,
	JN_DATETIME,
	JN_NOTES,
	JN_APPLN,
	JN_SESSION,
	OLD_CABLETYPE,
	NEW_CABLETYPE,
	OLD_MANUFACTURE,
	NEW_MANUFACTURE,
	OLD_CABDESC,
	NEW_CABDESC,
	OLD_JACKET,
	NEW_JACKET,
	OLD_NUMCOND,
	NEW_NUMCOND,
	OLD_CHKBY,
	NEW_CHKBY,
	OLD_CHKDATE,
	NEW_CHKDATE,
	TYPE_ID,
	CREATED_BY,
	CREATED_DATE,
	MODIFIED_BY,
	MODIFIED_DATE
	)
       VALUES
       (jn_operation,
        NVL(V('APP_USER'),USER),
	SYSDATE,
	NULL,
	NULL,
	userenv('sessionid'),
	NULL,
	:NEW.CABLETYPE,
	NULL,
	:NEW.MANUFACTURE,
	NULL,
	:NEW.CABDESC,
	NULL,
	:NEW.JACKET,
	NULL,
	:NEW.NUMCOND,
	NULL,
	:NEW.CHKBY,
	NULL,
	:NEW.CHKDATE,
	:NEW.TYPE_ID,
        :NEW.CREATED_BY,
	:NEW.CREATED_DATE,
	NULL,
	NULL
        );
    ELSIF UPDATING THEN
       INSERT INTO CABLETYP_JN
       (JN_OPERATION,
	JN_ORACLE_USER,
	JN_DATETIME,
	JN_NOTES,
	JN_APPLN,
	JN_SESSION,
	OLD_CABLETYPE,
	NEW_CABLETYPE,
	OLD_MANUFACTURE,
	NEW_MANUFACTURE,
	OLD_CABDESC,
	NEW_CABDESC,
	OLD_JACKET,
	NEW_JACKET,
	OLD_NUMCOND,
	NEW_NUMCOND,
	OLD_CHKBY,
	NEW_CHKBY,
	OLD_CHKDATE,
	NEW_CHKDATE,
	TYPE_ID,
	CREATED_BY,
	CREATED_DATE,
	MODIFIED_BY,
	MODIFIED_DATE
	)
       VALUES
       (jn_operation,
        NVL(V('APP_USER'),USER),
	SYSDATE,
	NULL,
	NULL,
	userenv('sessionid'),
	:OLD.CABLETYPE,
	:NEW.CABLETYPE,
	:OLD.MANUFACTURE,
	:NEW.MANUFACTURE,
	:OLD.CABDESC,
	:NEW.CABDESC,
	:OLD.JACKET,
	:NEW.JACKET,
	:OLD.NUMCOND,
	:NEW.NUMCOND,
	:OLD.CHKBY,
	:NEW.CHKBY,
	:OLD.CHKDATE,
	:NEW.CHKDATE,
	:NEW.TYPE_ID,
        :OLD.CREATED_BY,
	:OLD.CREATED_DATE,
	:NEW.MODIFIED_BY,
	:NEW.MODIFIED_DATE
        );

    ELSIF DELETING THEN
       INSERT INTO CABLETYP_JN
       (JN_OPERATION,
	JN_ORACLE_USER,
	JN_DATETIME,
	JN_NOTES,
	JN_APPLN,
	JN_SESSION,
	OLD_CABLETYPE,
	NEW_CABLETYPE,
	OLD_MANUFACTURE,
	NEW_MANUFACTURE,
	OLD_CABDESC,
	NEW_CABDESC,
	OLD_JACKET,
	NEW_JACKET,
	OLD_NUMCOND,
	NEW_NUMCOND,
	OLD_CHKBY,
	NEW_CHKBY,
	OLD_CHKDATE,
	NEW_CHKDATE,
	TYPE_ID,
	CREATED_BY,
	CREATED_DATE,
	MODIFIED_BY,
	MODIFIED_DATE
	)
       VALUES
       (jn_operation,
        NVL(V('APP_USER'),USER),
	SYSDATE,
	NULL,
	NULL,
	userenv('sessionid'),
	:OLD.CABLETYPE,
	NULL,
	:OLD.MANUFACTURE,
	NULL,
	:OLD.CABDESC,
	NULL,
	:OLD.JACKET,
	NULL,
	:OLD.NUMCOND,
	NULL,
	:OLD.CHKBY,
	NULL,
	:OLD.CHKDATE,
	NULL,
	:OLD.TYPE_ID,
        :OLD.CREATED_BY,
	:OLD.CREATED_DATE,
	:OLD.MODIFIED_BY,
	:OLD.MODIFIED_DATE
        );
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    V_ERRMSG := SUBSTR('ERROR ('||C_PROC||')=>'||SQLERRM,1,1000);
    RAISE_APPLICATION_ERROR(-20010, V_ERRMSG);

END;
/
ALTER TRIGGER "CAPTAR"."AIUDR_CABLETYP" ENABLE;