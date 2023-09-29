-- Create Database Trigger --
SET DEFINE OFF;
CREATE OR REPLACE TRIGGER SSRL_RSW_BEAMLINE_MGR_BIUDR
    BEFORE INSERT OR UPDATE OR DELETE ON SSRL_RSW_BEAMLINE_MGR
    FOR EACH ROW
begin

     if inserting 
     -- and :new.created_by is null  
     then
        :new.created_by := nvl(v('APP_USER'),user);
        :new.created_date := sysdate;
    end if;
    if updating then
        :new.modified_by := nvl(v('APP_USER'),user);
        :new.modified_date := sysdate;
    end if;
end;
/