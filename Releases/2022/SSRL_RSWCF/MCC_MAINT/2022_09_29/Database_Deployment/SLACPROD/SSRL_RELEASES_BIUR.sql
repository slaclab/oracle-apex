--------------------------------------------------------
--  DDL for Trigger SSRL_RELEASES_BIUR
--------------------------------------------------------

CREATE OR REPLACE TRIGGER MCC_MAINT.SSRL_RELEASES_BIUR 
BEFORE INSERT OR UPDATE
ON SSRL_RELEASES FOR EACH ROW
  
declare

    v_user          varchar2(100) := nvl(v('APP_USER'),user);
    v_jn_operation  varchar2(3);
    v_now           date          := sysdate;
    v_session       number        := userenv('sessionid');

begin
  
    if inserting then
         select ssrl_releases_seq.nextval 
	 into :new.release_id 
	 from dual;
	 --
        :new.created_by   := v_user;
        :new.created_date := sysdate;
    end if;
    
    if updating
    then
        :new.modified_by   := v_user;
        :new.modified_date := sysdate;
    end if;
    
end; 
/
