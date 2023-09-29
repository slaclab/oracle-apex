create or replace TRIGGER MAGNET_STRING_BIUDR
BEFORE INSERT OR UPDATE OR DELETE ON MAGNET_STRING FOR EACH ROW
DECLARE
  ERRMSG VARCHAR2(500);
  c_user constant varchar2(100) := nvl(v('APP_USER'),user);
  l_osuser  varchar2(200);
  l_host  varchar2(200);
  l_ip_address  varchar2(200);
  l_machine varchar2(240);
  L_PS_CONFIG  magnet_polynomial.ps_config%TYPE;
  L_ELEMENT	lcls_elements.element%TYPE;
  l_engineering_name	lcls_elements.engineering_name%TYPE;
  L_EPICS_CHANNEL_ACCESS_NAME	varchar2(250);
  l_parent_psc_type	magnet_string.psc_type%TYPE;

   l_poly_id		number;
   --
  C_PROC    CONSTANT   VARCHAR2(30) := 'MAGNET_STRING_BIUDR';

BEGIN
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' Begin');
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' :new.SAFETY_SYSTEM= '||:new.SAFETY_SYSTEM);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' :old.SAFETY_SYSTEM= '||:old.SAFETY_SYSTEM);
  IF (nvl(:new.SAFETY_SYSTEM,0) != nvl(:old.SAFETY_SYSTEM,0)) then
    IF (:new.SAFETY_SYSTEM = 0) THEN
  	:new.SAFETY_BCS := 0;
  	:new.SAFETY_MPS := 0;
  	:new.SAFETY_PPS := 0;
    ELSIF (:new.SAFETY_SYSTEM = 1) THEN
	:new.SAFETY_BCS := 1;
    ELSIF (:new.SAFETY_SYSTEM = 2) THEN
	:new.SAFETY_PPS := 1;
    ELSIF (:new.SAFETY_SYSTEM = 3) THEN
	:new.SAFETY_BCS := 1;
 	:new.SAFETY_PPS := 1;
    ELSIF (:new.SAFETY_SYSTEM = 4) THEN
	:new.SAFETY_MPS := 1;
    ELSIF (:new.SAFETY_SYSTEM = 5) THEN
	:new.SAFETY_BCS := 1;
 	:new.SAFETY_MPS := 1;
    ELSIF (:new.SAFETY_SYSTEM = 6) THEN
 	:new.SAFETY_MPS := 1;
  	:new.SAFETY_PPS := 1;
    ELSIF (:new.SAFETY_SYSTEM = 7) THEN
	:new.SAFETY_BCS := 1;
  	:new.SAFETY_MPS := 1;
  	:new.SAFETY_PPS := 1;
    END IF;    -- IF (:new.SAFETY_SYSTEM = 0)
  END IF;      -- IF (nvl(:new.SAFETY_SYSTEM,0) != nvl(:old.SAFETY_SYSTEM,0)) 

  --
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
    begin
	select poly_id
	into :new.poly_id
	from magnet_polynomial
	where barcode = :new.barcode;
	dbms_output.put_line(':new.barcode= '|| :new.barcode);
	ERRMSG := ':new.barcode: '||:new.barcode ||', :new.poly_id: '|| :new.poly_id ;

   exception
	  WHEN OTHERS THEN 
	   :new.poly_id := NULL;
   end;
   --
  ELSIF UPDATING THEN
      :new.UPDATED_BY := c_user;
      :new.DATE_UPDATED := SYSDATE;
  END IF;
---------------------------------------------------------
IF INSERTING OR UPDATING THEN

    SELECT SYS_CONTEXT('USERENV','OS_USER') into l_osuser FROM dual;
    SELECT SYS_CONTEXT('USERENV','HOST') into l_host FROM dual;
    SELECT SYS_CONTEXT('USERENV','IP_ADDRESS') into l_ip_address FROM dual;

    l_machine := l_osuser||' - '||l_host||' - '||l_ip_address;
    --
    --
    -- set UNIT_DISPLAY value --------------------
    --
    begin
          select ps_config
	  into l_ps_config
	  from magnet_polynomial
	  where barcode = :new.barcode;
    exception
      WHEN NO_DATA_FOUND THEN
        :new.UNIT_DISPLAY := '';
      WHEN OTHERS THEN
	 ERRMSG := SUBSTR(SQLERRM,1,500);
	 RAISE_APPLICATION_ERROR(-20120, ERRMSG);
    end;   
    --
    IF l_ps_config = 'STRING' THEN
      :new.UNIT_DISPLAY := 'mgnt_unit_slave';
    ELSE
	:new.UNIT_DISPLAY := 'mgnt_unit2';
    END IF;
    --
    -- set HW_AREA value --------------------
    --
    begin
          select element, EPICS_CHANNEL_ACCESS_NAME, ENGINEERING_NAME
	  into l_element, l_epics_channel_access_name, l_engineering_name
	  from V_LCLS_ELEMENTS_REPORT
	  where element = :new.element;
    exception
      WHEN NO_DATA_FOUND THEN
        :new.HW_AREA := '';
      WHEN OTHERS THEN
	 ERRMSG := SUBSTR(SQLERRM,1,500);
	 RAISE_APPLICATION_ERROR(-20120, ERRMSG);
    end;  
    --
    IF :new.element is not null then
      IF :new.HW_AREA is NULL THEN
        IF :new.PSC_TYPE in ('MCOR','EMCOR') THEN
	  :new.HW_AREA := substr(:new.PSC_DEVICE, 
				  instr(:new.PSC_DEVICE,':',1)+1, 
				((instr(:new.PSC_DEVICE,':',-1,1)) - (instr(:new.PSC_DEVICE,':',1)+1)));
	ELSE
          :new.HW_AREA := substr(l_epics_channel_access_name, 
				 instr(l_epics_channel_access_name,':',1)+1, 
			       ((instr(l_epics_channel_access_name,':',-1,1)) - (instr(l_epics_channel_access_name,':',1)+1)));
        END IF;  -- :new.PSC_TYPE in ('MCOR','EMCOR')
      END IF;    -- :new.HW_AREA is NULL
    ELSE
        :new.HW_AREA := '';
    END IF;      -- :new.element is not null
    --
    -- set HW_DISPLAY values --------------------
    --
      IF :new.PSC_TYPE is not null THEN
        IF (:new.PSC_TYPE != nvl(:old.PSC_TYPE,'x')) THEN
	 begin
	  select 
	    decode(:new.PSC_TYPE,'MCOR','mgnt_mcor','EMCOR','mgnt_emcor','EPSC','mgnt_epsc','PLC','mgnt_kick','')
	    into :new.HW_DISPLAY
          from dual;
         exception
          WHEN OTHERS THEN 
	   :new.HW_DISPLAY := '';
	 end;
	END IF;    -- (:new.PSC_TYPE != nvl(:old.PSC_TYPE,'x'))
      ELSE
	:new.HW_DISPLAY := '';
      END IF;    -- :new.PSC_TYPE is not null
    --
    -- set LIMIT_DISPLAY value --------------------
    --
    --
    IF (nvl(:new.PSC_TYPE,'x') != nvl(:old.PSC_TYPE,'x')) THEN     
     IF :new.HW_DISPLAY = 'mgnt_epsc' THEN
        :new.LIMIT_DISPLAY := 'mgnt_limits_aux';
      ELSE     
	:new.LIMIT_DISPLAY := 'mgnt_limits';
      END IF;
    END IF;   -- (:new.PSC_TYPE != :old.PSC_TYPE)       
   --

/*
--    IF (:new.PSC_TYPE != :old.PSC_TYPE) THEN     -- DISABLE TEMPORARILY FOR TESTING *************************
      IF :new.PSC_TYPE = 'EPSC' THEN
        :new.LIMIT_DISPLAY := 'mgnt_limits_aux';
      ELSIF :new.PSC_TYPE != 'NONE' THEN     --in ('MCOR','EMCOR','BECKHOFF','PLC','SERIAL') THEN
	:new.LIMIT_DISPLAY := 'mgnt_limits';
      ELSE
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' in the ELSE for LIMIT_DISPLAY, :new.PSC_TYPE= '|| :new.PSC_TYPE);
	SET_LIMIT_DISPLAY(:new.barcode, l_parent_psc_type);
--	l_parent_psc_type := GET_PARENT_EPSC(:new.barcode);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' in the ELSE for LIMIT_DISPLAY, l_parent_psc_type= '|| l_parent_psc_type);
	IF l_parent_psc_type = 'EPSC' THEN
           :new.LIMIT_DISPLAY := 'mgnt_limits_aux';
	ELSE
	   :new.LIMIT_DISPLAY := 'mgnt_limits';
	END IF; -- l_parent_psc_type = 'EPSC'
      END IF;   -- :new.PSC_TYPE = 'EPSC'
--    END IF;   -- (:new.PSC_TYPE != :old.PSC_TYPE)       -- DISABLE TEMPORARILY FOR TESTING *************************

 */
    --
    -- set ACSW_HOST, ACSW_PLUG, ACSW_NAME values --------------------
    --
      IF :new.ACSW_NODE is not null THEN
        IF (:new.ACSW_NODE != nvl(:old.ACSW_NODE,'x')) THEN
	  :new.ACSW_HOST := substr(:new.ACSW_NODE,1,14);
	  :new.ACSW_PLUG := substr(:new.ACSW_NODE,-1,1);
	  :new.ACSW_NAME := upper(replace(substr(:new.ACSW_NODE,1,14),'-',':'));
        END IF;    -- (:new.ACSW_NODE != nvl(:old.ACSW_NODE,'x'))
      ELSE
	:new.ACSW_HOST := '';
	:new.ACSW_PLUG := '';
	:new.ACSW_NAME := '';
      END IF;    -- :new.ACSW_NODE is not null
    --
    IF :new.PSC_DEVICE is not null THEN
     IF nvl(:new.PSC_TYPE,'x') != nvl(:old.PSC_TYPE,'x') OR
        nvl(:new.PSC_DEVICE,'x') != nvl(:old.PSC_DEVICE,'x')
     THEN
      IF :new.PSC_TYPE in ('EPSC') THEN
         :new.PSC_NODE := lower(replace(:new.PSC_DEVICE,':','-'));
      ELSIF :new.PSC_TYPE = 'MCOR' THEN
         :new.MCOR_CRATE_NUM := to_number(substr(:new.PSC_DEVICE, 
                                      regexp_instr(:new.PSC_DEVICE,':',1,2)+1,
                                      (length(:new.PSC_DEVICE)-(regexp_instr(:new.PSC_DEVICE,':',1,2))-2)));
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
        WHEN OTHERS THEN NULL;
/*
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' Exception :old.PSC_DEVICE= '|| :old.PSC_DEVICE);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' Exception :new.PSC_DEVICE= '|| :new.PSC_DEVICE);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' Exception :old.PSC_TYPE= '|| :old.PSC_TYPE);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' Exception :new.PSC_TYPE= '|| :new.PSC_TYPE);
*/
       end;
    END IF; -- :new.PSC_TYPE in ('EPSC')
   END IF; -- nvl(:new.PSC_TYPE,'x') != nvl(:old.PSC_TYPE,'x')
  END IF; -- :new.PSC_DEVICE is not null
/*
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' :old.PSC_DEVICE= '|| :old.PSC_DEVICE ||', :new.PSC_DEVICE= '|| :new.PSC_DEVICE);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' :old.PSC_TYPE= '|| :old.PSC_TYPE || ', :new.PSC_TYPE= '|| :new.PSC_TYPE);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' :new.MCOR_CRATE_NUM= '|| :new.MCOR_CRATE_NUM || ', :new.MCOR_CRATE_CHAN= '|| :new.MCOR_CRATE_CHAN);
*/
--
END IF; -- INSERTING OR UPDATING

  --------------------------------------

apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' End');

EXCEPTION
  WHEN OTHERS THEN
    ERRMSG := SUBSTR(SQLERRM,1,500);
    RAISE_APPLICATION_ERROR(-20120, ERRMSG);
END;
/