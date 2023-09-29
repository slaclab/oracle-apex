drop TABLE SSRL_RSW_DOCUMENT;	
CREATE TABLE SSRL_RSW_DOCUMENT (	
DOC_ID		NUMBER NOT NULL, 
FORM_ID		NUMBER NOT NULL, 
DOC_NAME	VARCHAR2(500), 
URL		VARCHAR2(2000), 
CREATED_BY	VARCHAR2(30), 
CREATED_DATE	DATE, 
MODIFIED_BY	VARCHAR2(30), 
MODIFIED_DATE	DATE
);

alter table ssrl_rsw_document
add constraint ssrl_rsw_document_PK PRIMARY KEY (DOC_ID)
using index;

CREATE INDEX ssrl_rsw_document_IDX1 ON ssrl_rsw_document (FORM_ID);


drop TABLE SSRL_RSW_DOCUMENT_JN;	
CREATE TABLE ssrl_rsw_document_JN (	
JN_OPERATION	VARCHAR2(3) NOT NULL , 
JN_ORACLE_USER	VARCHAR2(30) NOT NULL , 
JN_DATETIME	DATE NOT NULL , 
JN_NOTES	VARCHAR2(240), 
JN_APPLN	VARCHAR2(30), 
JN_SESSION	NUMBER(38), 
DOC_ID		NUMBER NOT NULL, 
FORM_ID	NUMBER, 
DOC_NAME	VARCHAR2(500), 
URL		VARCHAR2(2000), 
CREATED_BY	VARCHAR2(30), 
CREATED_DATE	DATE, 
MODIFIED_BY	VARCHAR2(30), 
MODIFIED_DATE	DATE
);

drop SEQUENCE  ssrl_rsw_document_SEQ;  
CREATE SEQUENCE  ssrl_rsw_document_SEQ  
MINVALUE 1 
MAXVALUE 999999999999999999999999999 
INCREMENT BY 1 
START WITH 1 
NOCACHE  
NOORDER  
NOCYCLE ;

CREATE OR REPLACE TRIGGER ssrl_rsw_document_BIUDR 
BEFORE INSERT OR UPDATE OR DELETE
  on ssrl_rsw_document for each row
DECLARE
    jn_operation VARCHAR2(3);
begin
 if inserting then
  if :NEW.DOC_ID is null then 
    select ssrl_rsw_document_SEQ.nextval into :NEW.DOC_ID from dual; 
  end if; 

  if :new.created_by is null then
    :new.created_by := NVL(V('APP_USER'),USER);
    :new.created_date := sysdate;
  end if;
 end if;
 --
  if updating then
    :new.modified_by := NVL(V('APP_USER'),USER);
    :new.modified_date := sysdate;
  end if;
--
    IF INSERTING THEN
       jn_operation := 'INS';
    ELSIF UPDATING THEN
       jn_operation := 'UPD';
    ELSIF DELETING THEN
       jn_operation := 'DEL';
    END IF;
    IF INSERTING OR UPDATING THEN
       INSERT INTO ssrl_rsw_document_JN
       ( JN_OPERATION, JN_ORACLE_USER, JN_DATETIME, JN_NOTES, JN_APPLN, JN_SESSION
       , DOC_ID, FORM_ID, DOC_NAME, URL
       , CREATED_BY, CREATED_DATE, MODIFIED_BY, MODIFIED_DATE
       ) VALUES (jn_operation, NVL(V('APP_USER'),USER), SYSDATE, NULL, NULL,
userenv('sessionid')
       , :NEW.DOC_ID, :NEW.FORM_ID, :NEW.DOC_NAME, :NEW.URL
       , :NEW.CREATED_BY, :NEW.CREATED_DATE, :NEW.MODIFIED_BY, :NEW.MODIFIED_DATE
        );
    END IF;
    IF DELETING THEN
       INSERT INTO ssrl_rsw_document_JN
       ( JN_OPERATION, JN_ORACLE_USER, JN_DATETIME, JN_NOTES, JN_APPLN, JN_SESSION
       , DOC_ID, FORM_ID, DOC_NAME, URL
       , CREATED_BY, CREATED_DATE, MODIFIED_BY, MODIFIED_DATE
       ) VALUES (jn_operation, NVL(V('APP_USER'),USER), SYSDATE, NULL, NULL,
userenv('sessionid')
       , :OLD.DOC_ID, :OLD.FORM_ID, :OLD.DOC_NAME, :OLD.URL
       , :OLD.CREATED_BY, :OLD.CREATED_DATE, :OLD.MODIFIED_BY, :OLD.MODIFIED_DATE
        );
    END IF;
--
end;
/
