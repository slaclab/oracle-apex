-- Journaling code for MCC_MAINT.SSRL_RSW_USER_ROLES --
-- Create Journaling Table --
drop table SSRL_RSW_USER_ROLES_JN;
CREATE TABLE MCC_MAINT.SSRL_RSW_USER_ROLES_JN 
     (JN_OPERATION	VARCHAR2(3) NOT NULL 
     ,JN_ORACLE_USER	VARCHAR2(30) NOT NULL 
     ,JN_DATETIME	DATE NOT NULL 
     ,JN_NOTES		VARCHAR2(240) 
     ,JN_APPLN		VARCHAR2(30) 
     ,JN_SESSION	NUMBER(38) 
     ,USER_ROLE_ID	NUMBER
     ,ROLE_ID		NUMBER
     ,USER_ID		NUMBER
     ,STATUS_AI_CHK	VARCHAR2(1)
     ,CREATED_BY	VARCHAR2(30)
     ,CREATED_DATE	DATE 
     ,MODIFIED_BY	VARCHAR2(30)
     ,MODIFIED_DATE	DATE 
    );

drop SEQUENCE SSRL_RSW_USER_ROLES_SEQ;
CREATE SEQUENCE SSRL_RSW_USER_ROLES_SEQ
MINVALUE 1 
MAXVALUE 999999999999999999999999999 
INCREMENT BY 1 
START WITH 90 
NOCACHE  
NOORDER  
NOCYCLE;


-- Create Database Trigger --
SET DEFINE OFF;
create or replace TRIGGER SSRL_RSW_USER_ROLES_BIUR
BEFORE INSERT OR UPDATE ON SSRL_RSW_USER_ROLES FOR EACH ROW
declare
    jn_operation varchar2(3);
begin

  if inserting and :new.USER_ROLE_ID is null
  then
    select SSRL_RSW_USER_ROLES_SEQ.nextval into :new.USER_ROLE_ID from dual;
  end if;

  if inserting and :new.created_by is null
  then
    :new.created_by := nvl(v('APP_USER'),user);
    :new.created_date := sysdate;
  end if;

  if updating
  then
    :new.modified_by := nvl(v('APP_USER'),user);
    :new.modified_date := sysdate;
  end if;
end;
/

CREATE OR REPLACE TRIGGER MCC_MAINT.SSRL_RSW_USER_ROLES_AIUDR
    AFTER INSERT OR UPDATE OR DELETE ON SSRL_RSW_USER_ROLES
    FOR EACH ROW
DECLARE
    JN_OPERATION VARCHAR2(3);
BEGIN
    IF INSERTING THEN
        JN_OPERATION := 'INS';
    ELSIF UPDATING THEN
        JN_OPERATION := 'UPD';
    ELSIF DELETING THEN
        JN_OPERATION := 'DEL';
    END IF;
    IF INSERTING OR UPDATING THEN
        INSERT INTO SSRL_RSW_USER_ROLES_JN 
        ( JN_OPERATION, JN_ORACLE_USER, JN_DATETIME, JN_NOTES, JN_APPLN, JN_SESSION
         , USER_ROLE_ID, ROLE_ID, USER_ID
         , STATUS_AI_CHK, CREATED_BY, CREATED_DATE, MODIFIED_BY
         , MODIFIED_DATE
         ) VALUES (jn_operation, NVL(V('APP_USER'),USER), SYSDATE, NULL, NULL, userenv('sessionid')
         , :NEW.USER_ROLE_ID, :NEW.ROLE_ID, :NEW.USER_ID
         , :NEW.STATUS_AI_CHK, :NEW.CREATED_BY, :NEW.CREATED_DATE, :NEW.MODIFIED_BY
         , :NEW.MODIFIED_DATE
         );
     END IF;
     IF DELETING THEN
         INSERT INTO SSRL_RSW_USER_ROLES_JN 
         ( JN_OPERATION, JN_ORACLE_USER, JN_DATETIME, JN_NOTES, JN_APPLN, JN_SESSION
         , USER_ROLE_ID, ROLE_ID, USER_ID
         , STATUS_AI_CHK, CREATED_BY, CREATED_DATE, MODIFIED_BY
         , MODIFIED_DATE
         ) VALUES (jn_operation, NVL(V('APP_USER'),USER), SYSDATE, NULL, NULL,userenv('sessionid')
         , :OLD.USER_ROLE_ID, :OLD.ROLE_ID, :OLD.USER_ID
         , :OLD.STATUS_AI_CHK, :OLD.CREATED_BY, :OLD.CREATED_DATE, :OLD.MODIFIED_BY
         , :OLD.MODIFIED_DATE );
         END IF; 
END;
/
