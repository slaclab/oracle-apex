  CREATE OR REPLACE TRIGGER SSRL_RSW_ATTACHMENT_BIUDR 
BEFORE INSERT OR UPDATE OR DELETE
ON SSRL_RSW_ATTACHMENT  FOR EACH ROW
DECLARE
    jn_operation VARCHAR2(3);
 BEGIN

    if inserting and :new.file_ID is null then
        select ssrl_rsw_attachment_seq.nextval into :new.file_ID
from dual;
    end if;
    if inserting and :new.created_by is null  then
        :new.created_by := NVL(V('APP_USER'),USER);
        :new.created_date := sysdate;
    end if;
    if updating then
        :new.modified_by := NVL(V('APP_USER'),USER);
        :new.modified_date := sysdate;
    end if;

    IF :NEW.CREATED_BY = 'STATUS_CHECK' THEN
       RETURN;
    ELSIF INSERTING THEN
       jn_operation := 'INS';
    ELSIF UPDATING THEN
       jn_operation := 'UPD';
    ELSIF DELETING THEN
       jn_operation := 'DEL';
    END IF;
    IF INSERTING OR UPDATING THEN
       INSERT INTO SSRL_RSW_ATTACHMENT_JN
       ( JN_OPERATION, JN_ORACLE_USER, JN_DATETIME, JN_NOTES, JN_APPLN, JN_SESSION
       , FILE_ID, FORM_ID, NAME, ID
       , BLOB_CONTENT, MIME_TYPE, DOC_SIZE, COMMENTS
       , CREATED_BY, CREATED_DATE, MODIFIED_BY, MODIFIED_DATE
       ) VALUES (jn_operation, NVL(V('APP_USER'),USER), SYSDATE, NULL, NULL,
userenv('sessionid')
       , :NEW.FILE_ID, :NEW.FORM_ID, :NEW.NAME, :NEW.ID
       , :NEW.BLOB_CONTENT, :NEW.MIME_TYPE, :NEW.DOC_SIZE, :NEW.COMMENTS
       , :NEW.CREATED_BY, :NEW.CREATED_DATE, :NEW.MODIFIED_BY, :NEW.MODIFIED_DATE
        );
    END IF;
    IF DELETING THEN
       INSERT INTO ssrl_rsw_attachment_JN
       ( JN_OPERATION, JN_ORACLE_USER, JN_DATETIME, JN_NOTES, JN_APPLN, JN_SESSION
       , FILE_ID, FORM_ID, NAME, ID
       , BLOB_CONTENT, MIME_TYPE, DOC_SIZE, COMMENTS
       , CREATED_BY, CREATED_DATE, MODIFIED_BY, MODIFIED_DATE
       ) VALUES (jn_operation, NVL(V('APP_USER'),USER), SYSDATE, NULL, NULL,
userenv('sessionid')
       , :OLD.FILE_ID, :OLD.FORM_ID, :OLD.NAME, :OLD.ID
       , :OLD.BLOB_CONTENT, :OLD.MIME_TYPE, :OLD.DOC_SIZE, :OLD.COMMENTS
       , :OLD.CREATED_BY, :OLD.CREATED_DATE, :OLD.MODIFIED_BY, :OLD.MODIFIED_DATE
       );
    END IF;
END;
/
