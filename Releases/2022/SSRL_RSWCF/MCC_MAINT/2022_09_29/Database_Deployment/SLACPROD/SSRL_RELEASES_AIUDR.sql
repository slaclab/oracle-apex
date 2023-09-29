--------------------------------------------------------
--  DDL for Trigger SSRL_RELEASES_AIUDR
--------------------------------------------------------

CREATE OR REPLACE TRIGGER MCC_MAINT.SSRL_RELEASES_AIUDR 
AFTER INSERT OR UPDATE OR DELETE
ON SSRL_RELEASES FOR EACH ROW
declare

    v_user          varchar2(100) := nvl(v('APP_USER'),user);
    v_jn_operation  varchar2(3);
    v_now           date          := sysdate;
    v_session       number        := userenv('sessionid');
begin
    IF INSERTING THEN
        v_jn_operation := 'INS';
    ELSIF UPDATING THEN
        v_jn_operation := 'UPD';
    ELSIF DELETING THEN
        v_jn_operation := 'DEL';
    END IF;
    
    if inserting or updating
    then
        insert into SSRL_RELEASES_JN
        (jn_operation
        ,jn_oracle_user
        ,jn_datetime
        ,jn_notes
        ,jn_appln
        ,jn_session
        ,release_id
        ,prod_install_date
        ,version
        ,description
        ,created_by
        ,created_date
        ,modified_by
        ,modified_date
        ) 
        values
        (v_jn_operation
        ,v_user
        ,v_now
        ,null
        ,null
        ,v_session
        ,:new.release_id
        ,:new.prod_install_date
        ,:new.version
        ,:new.description
        ,:new.created_by
        ,:new.created_date
        ,:new.modified_by
        ,:new.modified_date
        );
    end if;
    
    if deleting
    then
        insert into SSRL_RELEASES_JN
        (jn_operation
        ,jn_oracle_user
        ,jn_datetime
        ,jn_notes
        ,jn_appln
        ,jn_session
        ,release_id
        ,prod_install_date
        ,version
        ,description
        ,created_by
        ,created_date
        ,modified_by
        ,modified_date
        )
        values
        (v_jn_operation
        ,v_user
        ,v_now
        ,null
        ,null
        ,v_session
        ,:old.release_id
        ,:old.prod_install_date
        ,:old.version
        ,:old.description
        ,:old.created_by
        ,:old.created_date
        ,:old.modified_by
        ,:old.modified_date
        );
    end if;
end; 
/
