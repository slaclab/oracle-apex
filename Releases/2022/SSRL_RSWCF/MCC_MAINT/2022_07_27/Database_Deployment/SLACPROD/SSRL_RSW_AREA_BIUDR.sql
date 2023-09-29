create or replace TRIGGER SSRL_RSW_AREA_BIUDR 
 BEFORE INSERT OR UPDATE OR DELETE 
 ON SSRL_RSW_AREA  FOR EACH ROW
DECLARE
    jn_operation VARCHAR2(3);
 BEGIN
 
    if inserting and :new.area_ID is null then
        select SSRL_RSW_AREA_SEQ.nextval 
	into :new.area_ID
	from dual;
    end if;
    if inserting 
    -- and :new.created_by is null  
    then
        :new.created_by := NVL(V('APP_USER'),USER);
        :new.created_date := sysdate;
        :new.area := upper(:new.area);
    end if;
    if updating then
        :new.modified_by := NVL(V('APP_USER'),USER);
        :new.modified_date := sysdate;
        :new.area := upper(:new.area);
    end if;
END;
/