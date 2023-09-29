create or replace TRIGGER MAGNET_STRING_BIUDR
BEFORE INSERT OR UPDATE OR DELETE ON MAGNET_STRING FOR EACH ROW
DECLARE
  ERRMSG VARCHAR2(500);
  c_user constant varchar2(100) := nvl(v('APP_USER'),user);
  l_osuser  varchar2(200);
  l_host  varchar2(200);
  l_ip_address  varchar2(200);
  l_machine varchar2(240);

  PK_CHG_ERROR           EXCEPTION;
  C_PROC    CONSTANT   VARCHAR2(30) := 'MAGNET_STRING_BIUDR';

BEGIN
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' Begin');

IF INSERTING OR UPDATING THEN

    SELECT SYS_CONTEXT('USERENV','OS_USER') into l_osuser FROM dual;
    SELECT SYS_CONTEXT('USERENV','HOST') into l_host FROM dual;
    SELECT SYS_CONTEXT('USERENV','IP_ADDRESS') into l_ip_address FROM dual;

    l_machine := l_osuser||' - '||l_host||' - '||l_ip_address;
    --
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' :old.PSC_DEVICE= '|| :old.PSC_DEVICE ||', :new.PSC_DEVICE= '|| :new.PSC_DEVICE);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' :old.PSC_TYPE= '|| :old.PSC_TYPE || ', :new.PSC_TYPE= '|| :new.PSC_TYPE);
    IF :new.PSC_DEVICE is not null THEN
     IF nvl(:new.PSC_TYPE,'x') != nvl(:old.PSC_TYPE,'x') OR
        nvl(:new.PSC_DEVICE,'x') != nvl(:old.PSC_DEVICE,'x')
     THEN
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' Going into the IF Condition');
      IF :new.PSC_TYPE in ('EPSC') THEN
        :new.PSC_NODE := lower(replace(:new.PSC_DEVICE,':','-'));
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' :new.PSC_NODE= '|| :new.PSC_NODE);
      ELSIF :new.PSC_TYPE = 'MCOR' THEN
        :new.MCOR_CRATE_NUM := substr(:new.PSC_DEVICE, 
                                      regexp_instr(:new.PSC_DEVICE,':',1,2)+1,
                                      (length(:new.PSC_DEVICE)-(regexp_instr(:new.PSC_DEVICE,':',1,2))-2));
        :new.MCOR_CRATE_CHAN := to_number(substr(:new.PSC_DEVICE,-2));
      ELSIF :new.PSC_TYPE = 'EMCOR' THEN
      :new.MCOR_CRATE_NUM := substr(:new.PSC_DEVICE, 
                                    regexp_instr(:new.PSC_DEVICE,':',1,2)+1,
                                    (length(:new.PSC_DEVICE)-(regexp_instr(:new.PSC_DEVICE,':',1,2))-2));
      :new.MCOR_CRATE_CHAN := to_number(substr(:new.PSC_DEVICE,-2));
      --
       begin
        select
        'cpu-' || 
        lower(substr(:new.PSC_DEVICE,regexp_instr(:new.PSC_DEVICE,':',1,1)+1,(regexp_instr(:new.PSC_DEVICE,':',1,2))-(regexp_instr(:new.PSC_DEVICE,':',1,1)+1)))
        || '-mg' || 
        decode(length(substr(:new.PSC_DEVICE, regexp_instr(:new.PSC_DEVICE,':',1,2)+1,
                            (length(:new.PSC_DEVICE)-(regexp_instr(:new.PSC_DEVICE,':',1,2))-2))),
              1, '0' || substr(:new.PSC_DEVICE, regexp_instr(:new.PSC_DEVICE,':',1,2)+1,
	                       (length(:new.PSC_DEVICE)-(regexp_instr(:new.PSC_DEVICE,':',1,2))-2)),
              substr(:new.PSC_DEVICE, regexp_instr(:new.PSC_DEVICE,':',1,2)+1,
	             (length(:new.PSC_DEVICE)-(regexp_instr(:new.PSC_DEVICE,':',1,2))-2)))
       into :new.PSC_NODE 
       from dual;
      exception
       WHEN OTHERS THEN
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' Exception :old.PSC_DEVICE= '|| :old.PSC_DEVICE);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' Exception :new.PSC_DEVICE= '|| :new.PSC_DEVICE);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' Exception :old.PSC_TYPE= '|| :old.PSC_TYPE);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' Exception :new.PSC_TYPE= '|| :new.PSC_TYPE);
      end;
    END IF; -- :new.PSC_TYPE
   END IF; -- nvl(:new.PSC_TYPE,'x') != nvl(:old.PSC_TYPE,'x')
  END IF; -- :new.PSC_DEVICE is not null

apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' :old.PSC_NODE= '|| :old.PSC_NODE ||', :new.PSC_NODE= '|| :new.PSC_NODE);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' :old.PSC_DEVICE= '|| :old.PSC_DEVICE ||', :new.PSC_DEVICE= '|| :new.PSC_DEVICE);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' :old.PSC_TYPE= '|| :old.PSC_TYPE || ', :new.PSC_TYPE= '|| :new.PSC_TYPE);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' :new.MCOR_CRATE_NUM= '|| :new.MCOR_CRATE_NUM || ', :new.MCOR_CRATE_CHAN= '|| :new.MCOR_CRATE_CHAN);

--
END IF; -- INSERTING OR UPDATING

  --------------------------------------

  IF INSERTING THEN

    IF ( :new.PSC_ID IS NULL ) THEN
      SELECT MAGNET_STRING_SEQ.NEXTVAL
        INTO :new.PSC_ID
        FROM DUAL;
    END IF;

    IF ( :new.CREATED_BY IS NULL ) THEN
      :new.CREATED_BY := c_user;
    END IF;

    IF ( :new.DATE_CREATED IS NULL ) THEN
      :new.DATE_CREATED := SYSDATE;
    END IF;

    :new.UPDATED_BY := NULL;
    :new.DATE_UPDATED := NULL;
    --
ELSIF UPDATING THEN
      :new.UPDATED_BY := c_user;
      :new.DATE_UPDATED := SYSDATE;
END IF;
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' End');

EXCEPTION
  WHEN PK_CHG_ERROR THEN
    RAISE_APPLICATION_ERROR(-20100, ERRMSG);
  WHEN OTHERS THEN
    ERRMSG := SUBSTR(SQLERRM,1,500);
    RAISE_APPLICATION_ERROR(-20120, ERRMSG);
END;
/