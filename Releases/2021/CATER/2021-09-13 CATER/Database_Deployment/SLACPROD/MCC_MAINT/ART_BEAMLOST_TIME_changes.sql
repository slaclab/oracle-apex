alter table ART_BEAMLOST_TIME add (secondary_program_chk varchar2(1));

alter table art_beamlost_time_jn add (
LOST_DATE		DATE,
LOST_SHIFT_CHK		NUMBER,
SEPARATE_CHK		VARCHAR2(1),
SECONDARY_PROGRAM_CHK	VARCHAR2(1)
);

drop trigger BIUDR_ART_BEAMLOST_TIME_JN;
create or replace TRIGGER "MCC_MAINT"."ART_BEAMLOST_TIME_BIUDR" 
 BEFORE INSERT OR UPDATE OR DELETE 
 ON MCC_MAINT.ART_BEAMLOST_TIME  FOR EACH ROW
DECLARE
    jn_operation VARCHAR2(3);
 BEGIN
 
     if inserting and :new.created_by is null  and :new.btime_ID is null then
        select art_beamlost_seq.nextval into :new.btime_ID
from dual;
    end if;
    if inserting then
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
       INSERT INTO ART_BEAMLOST_TIME_JN 
       ( JN_OPERATION, JN_ORACLE_USER, JN_DATETIME, JN_NOTES, JN_APPLN, JN_SESSION
       , BTIME_ID, PROB_ID, PROG_ID
       , ID, TIMELOST, CREATED_BY, CREATED_DATE
       , MODIFIED_BY, MODIFIED_DATE
       , LOST_DATE, LOST_SHIFT_CHK, SEPARATE_CHK, SECONDARY_PROGRAM_CHK
       ) VALUES (jn_operation, NVL(V('APP_USER'),USER), SYSDATE, NULL, NULL,
userenv('sessionid')
       , :NEW.BTIME_ID, :NEW.PROB_ID, :NEW.PROG_ID
       , :NEW.ID, :NEW.TIMELOST, :NEW.CREATED_BY, :NEW.CREATED_DATE
       , :NEW.MODIFIED_BY, :NEW.MODIFIED_DATE
       , :NEW.LOST_DATE, :NEW.LOST_SHIFT_CHK, :NEW.SEPARATE_CHK, :NEW.SECONDARY_PROGRAM_CHK
        );
    END IF;
    IF DELETING THEN
       INSERT INTO ART_BEAMLOST_TIME_JN 
       ( JN_OPERATION, JN_ORACLE_USER, JN_DATETIME, JN_NOTES, JN_APPLN, JN_SESSION
       , BTIME_ID, PROB_ID, PROG_ID
       , ID, TIMELOST, CREATED_BY, CREATED_DATE
       , MODIFIED_BY, MODIFIED_DATE
       , LOST_DATE, LOST_SHIFT_CHK, SEPARATE_CHK, SECONDARY_PROGRAM_CHK
       ) VALUES (jn_operation, NVL(V('APP_USER'),USER), SYSDATE, NULL, NULL,
userenv('sessionid')
       , :OLD.BTIME_ID, :OLD.PROB_ID, :OLD.PROG_ID
       , :OLD.ID, :OLD.TIMELOST, :OLD.CREATED_BY, :OLD.CREATED_DATE
       , :OLD.MODIFIED_BY, :OLD.MODIFIED_DATE 
       , :OLD.LOST_DATE, :OLD.LOST_SHIFT_CHK, :OLD.SEPARATE_CHK, :OLD.SECONDARY_PROGRAM_CHK
      );
    END IF; 
END;

