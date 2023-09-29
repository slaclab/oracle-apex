--------------------------------------------------------
--  File created - Monday-July-25-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger SSRL_RSW_FORM_BIUDR
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "MCC_MAINT"."SSRL_RSW_FORM_BIUDR" 
 BEFORE INSERT OR UPDATE OR DELETE
 ON SSRL_RSW_FORM  FOR EACH ROW
DECLARE
	jn_operation	VARCHAR2(3);
	l_current_user	varchar2(30) := lower(nvl(v('APP_USER'),user));
	c_proc		constant varchar2(100) := 'SSRL_RSW_FORM_BIUDR ';
BEGIN

if inserting and :new.SSRL_FORM_ID is null then
    select SSRL_RSW_FORM_seq.nextval into :new.SSRL_FORM_ID
    from dual;
end if;
--
if inserting and :new.created_by is null  then
    :new.created_by := NVL(V('APP_USER'),USER);
    :new.created_date := sysdate;
end if;
--
if updating then
    :new.modified_by := NVL(V('APP_USER'),USER);
    :new.modified_date := sysdate;
    :new.EMAIL_CHK := 'N';	
    :new.email_rule := 0;
    --
    if (nvl(:new.s3_rad_id,0) != nvl(:old.s3_rad_id,0))
    then
         :new.s3_rad_date        := sysdate;
         :new.s3_rad_modified_by := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 1;
    end if;
    --
    if (nvl(:new.s3_sso_id,0) != nvl(:old.s3_sso_id,0))
    then
         :new.s3_sso_date        := sysdate;
         :new.s3_sso_modified_by := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 2;
    end if;
    --
    if (nvl(:new.s3_area_mgr_id,0) != nvl(:old.s3_area_mgr_id,0))
    then
         :new.s3_area_mgr_date        := sysdate;
         :new.s3_area_mgr_modified_by := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 3;
    end if;
    --
    IF :new.S3_TASK_PERSON_ACK_ID is not null then
	IF :new.S3_TASK_PERSON_ACK_ID != :new.S1_TASK_PERSON_ID THEN
	   :new.S3_TASK_PERSON_ACK_ID := NULL;
           :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 4;
	END IF;
    END IF;
    --
    if (nvl(:new.S3_TASK_PERSON_ACK_ID,0) != nvl(:old.S3_TASK_PERSON_ACK_ID,0))
    then
         :new.S3_TASK_PERSON_ACK_DATE        := sysdate;
         :new.S3_TASK_PERSON_ACK_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
 	 :new.email_rule := 5;
    end if;
    --
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '1 value of :new.s3_rad_id = '|| :new.s3_rad_id );
    -- we make all the 3 RP, SSO & AM ids also NULL
    -- Any change of Sec 1/2a/2b
    IF	(:new.S1_TASK_PERSON_ID	!=	:old.S1_TASK_PERSON_ID	OR
	:new.S1_AREA_ID		!=	:old.S1_AREA_ID		OR
	:new.S1_START_TIME	!=	:old.S1_START_TIME	OR
	:new.S1_DESCR		!=	:old.S1_DESCR		OR
	:new.S2_DESCR_BEFORE	!=	:old.S2_DESCR_BEFORE	OR
	:new.S2_DESCR_AFTER	!=	:old.S2_DESCR_AFTER)	
    THEN
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 6;
	 --
	:new.S3_RAD_ID := NULL;
--	:new.S3_RAD_DATE        := NULL;
--	:new.S3_RAD_MODIFIED_BY := NULL;
	:new.S3_SSO_ID := NULL;
--	:new.S3_SSO_DATE        := NULL;
--	:new.S3_SSO_MODIFIED_BY := NULL;
	:new.S3_AREA_MGR_ID := NULL;
--	:new.S3_AREA_MGR_DATE        := NULL;
--	:new.S3_AREA_MGR_MODIFIED_BY := NULL;
	:new.S3_TASK_PERSON_ACK_ID        := NULL;
--	:new.S3_TASK_PERSON_ACK_DATE        := NULL;
--	:new.S3_TASK_PERSON_ACK_MODIFIED_BY := NULL;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '2 value of :new.s3_rad_id = '|| :new.s3_rad_id );
    END IF; -- Any change of Sec 1/2a/2b

apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '3 value of :new.s3_rad_id = '|| :new.s3_rad_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '4 value of :old.s3_rad_id = '|| :old.s3_rad_id );
      IF (:new.s3_rad_id is null and :old.s3_rad_id is not null) OR
	 (:new.s3_sso_id is null and :old.s3_sso_id is not null) OR
	 (:new.s3_area_mgr_id is null and :old.s3_area_mgr_id is not null)
      THEN
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '4 value of :new.s3_rad_id = '|| :new.s3_rad_id );
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 6;
	 --
    END IF; -- Any change of Sec 3 signoffs
    --
    if (nvl(:new.S4_OPERATOR_ID,0) != nvl(:old.S4_OPERATOR_ID,0))
    then
         :new.S4_OPERATOR_DATE        := sysdate;
         :new.S4_OPERATOR_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
 	 :new.email_rule := 7;
    end if;
    --
    if (nvl(:new.S4_ASSIGN_WRKR_ID,0) != nvl(:old.S4_ASSIGN_WRKR_ID,0))
    then
         :new.S4_ASSIGN_WRKR_DATE        := sysdate;
         :new.S4_ASSIGN_WRKR_MODIFIED_BY := l_current_user;
 	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 20; -- ??????????????????????????????????????????????????
   end if;
    --
    if (nvl(:new.S4_WRKR_ID,0) != nvl(:old.S4_WRKR_ID,0))
    then
         :new.S4_WRKR_DATE        := sysdate;
         :new.S4_WRKR_MODIFIED_BY := l_current_user;
 	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 8;
   end if;
    --
   --
   if (nvl(:new.S5_TASK_PERSON_ACK_ID,0) != nvl(:old.S5_TASK_PERSON_ACK_ID,0))
    then
         :new.S5_TASK_PERSON_ACK_DATE        := sysdate;
         :new.S5_TASK_PERSON_ACK_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 9;
    end if;
    --
    if (nvl(:new.S5_PPS_ID,0) != nvl(:old.S5_PPS_ID,0))
    then
         :new.S5_PPS_DATE        := sysdate;
         :new.S5_PPS_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 10;
    end if;
    --
    if (nvl(:new.S5_SSO_ID,0) != nvl(:old.S5_SSO_ID,0))
    then
         :new.S5_SSO_DATE        := sysdate;
         :new.S5_SSO_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 10;
    end if;
    --
    if (nvl(:new.s5_rad_id,0) != nvl(:old.s5_rad_id,0))
    then
         :new.s5_rad_date        := sysdate;
         :new.s5_rad_modified_by := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 11;
    end if;
    --
    if (nvl(:new.S5_OPERATOR_ID,0) != nvl(:old.S5_OPERATOR_ID,0))
    then
         :new.S5_OPERATOR_DATE        := sysdate;
         :new.S5_OPERATOR_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 12;
    end if;
    --
    if (nvl(:new.S5_RPFO_ID,0) != nvl(:old.S5_RPFO_ID,0))
    then
         :new.S5_RPFO_DATE        := sysdate;
         :new.S5_RPFO_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 13;
    end if;
    --
    if (:new.S5_OTHER1_CHK is null and :old.S5_OTHER1_CHK = 'Y') AND
       (:new.S5_OTHER1_ID is NOT NULL) THEN
       :new.S5_OTHER1_ID := NULL;
    end if;
    --
    if (:new.S5_OTHER2_CHK is null and :old.S5_OTHER2_CHK = 'Y') AND
       (:new.S5_OTHER2_ID is NOT NULL) THEN
       :new.S5_OTHER2_ID := NULL;
    end if;
    --
    if (:new.S5_OTHER3_CHK is null and :old.S5_OTHER3_CHK = 'Y') AND
       (:new.S5_OTHER3_ID is NOT NULL) THEN
       :new.S5_OTHER3_ID := NULL;
    end if;
    --
    if (nvl(:new.S5_OTHER1_ACK_ID,0) != nvl(:old.S5_OTHER1_ACK_ID,0))
    then
         :new.S5_OTHER1_ACK_DATE        := sysdate;
         :new.S5_OTHER1_ACK_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 14;
    end if;
    --
    if (nvl(:new.S5_OTHER2_ACK_ID,0) != nvl(:old.S5_OTHER2_ACK_ID,0))
    then
         :new.S5_OTHER2_ACK_DATE        := sysdate;
         :new.S5_OTHER2_ACK_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 14;
    end if;
    --
    if (nvl(:new.S5_OTHER3_ACK_ID,0) != nvl(:old.S5_OTHER3_ACK_ID,0))
    then
         :new.S5_OTHER3_ACK_DATE        := sysdate;
         :new.S5_OTHER3_ACK_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 14;
    end if;
    --
-- Any change of the Section 5 Checkboxes to Null
    IF ( :new.S5_PPS_CHK is null and :old.S5_PPS_CHK = 'Y') OR
	(:new.S5_RPFO_CHK is null and :old.S5_RPFO_CHK = 'Y') OR
	(:new.S5_RAD_CHK is null and :old.S5_RAD_CHK = 'Y') OR
	(:new.S5_SSO_CHK is null and :old.S5_SSO_CHK = 'Y') OR
	(:new.S5_OPERATOR_CHK is null and :old.S5_OPERATOR_CHK = 'Y') OR
	(:new.S5_OTHER1_CHK is null and :old.S5_OTHER1_CHK = 'Y') OR
	(:new.S5_OTHER2_CHK is null and :old.S5_OTHER2_CHK = 'Y') OR
	(:new.S5_OTHER3_CHK is null and :old.S5_OTHER3_CHK = 'Y') 
    THEN
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 6; 
	 --
	:new.S3_RAD_ID := NULL;
--	:new.S3_RAD_DATE        := NULL;
--	:new.S3_RAD_MODIFIED_BY := NULL;
	:new.S3_SSO_ID := NULL;
--	:new.S3_SSO_DATE        := NULL;
--	:new.S3_SSO_MODIFIED_BY := NULL;
	:new.S3_AREA_MGR_ID := NULL;
--	:new.S3_AREA_MGR_DATE        := NULL;
--	:new.S3_AREA_MGR_MODIFIED_BY := NULL;
	:new.S3_TASK_PERSON_ACK_ID        := NULL;
--	:new.S3_TASK_PERSON_ACK_DATE        := NULL;
--	:new.S3_TASK_PERSON_ACK_MODIFIED_BY := NULL;
	--
	:new.S4_OPERATOR_ID := NULL;
--	:new.S4_OPERATOR_DATE        := NULL;
--	:new.S4_OPERATOR_MODIFIED_BY := NULL;
	:new.S4_WRKR_ID := NULL;
--	:new.S4_WRKR_DATE        := NULL;
--	:new.S4_WRKR_MODIFIED_BY := NULL;
	:new.S4_ASSIGN_WRKR_ID := NULL;
--	:new.S4_ASSIGN_WRKR_DATE        := NULL;
--	:new.S4_ASSIGN_WRKR_MODIFIED_BY := NULL;
	--
	:new.S5_TASK_PERSON_ACK_ID        := NULL;
--	:new.S5_TASK_PERSON_ACK_DATE        := NULL;
--	:new.S5_TASK_PERSON_ACK_MODIFIED_BY := NULL;
	:new.S5_PPS_ID        := NULL;
--	:new.S5_PPS_DATE        := NULL;
--	:new.S5_PPS_MODIFIED_BY := NULL;
	:new.S5_RAD_ID        := NULL;
--	:new.S5_RAD_DATE        := NULL;
--	:new.S5_RAD_MODIFIED_BY := NULL;
	:new.S5_SSO_ID        := NULL;
	:new.S5_RPFO_ID        := NULL;
--	:new.S5_RPFO_DATE        := NULL;
--	:new.S5_RPFO_MODIFIED_BY := NULL;
	:new.S5_OPERATOR_ID        := NULL;
--	:new.S5_OPERATOR_DATE        := NULL;
--	:new.S5_OPERATOR_MODIFIED_BY := NULL;
	:new.S5_OTHER1_ACK_ID        := NULL;
--	:new.S5_OTHER1_ACK_DATE        := NULL;
--	:new.S5_OTHER1_ACK_MODIFIED_BY := NULL;
	:new.S5_OTHER2_ACK_ID        := NULL;
--	:new.S5_OTHER2_ACK_DATE        := NULL;
--	:new.S5_OTHER2_ACK_MODIFIED_BY := NULL;
	:new.S5_OTHER3_ACK_ID        := NULL;
--	:new.S5_OTHER3_ACK_DATE        := NULL;
--	:new.S5_OTHER3_ACK_MODIFIED_BY := NULL;

apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '2 value of :new.s3_rad_id = '|| :new.s3_rad_id );
    END IF; -- Any change of the Section 5 Checkboxes to Null
    --
    if (nvl(:new.s6_sso_id,0) != nvl(:old.s6_sso_id,0))
    then
         :new.s6_sso_date        := sysdate;
         :new.s6_sso_modified_by := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 15;
    end if;
    --
    if (nvl(:new.S6_OPERATOR_ID,0) != nvl(:old.S6_OPERATOR_ID,0))
    then
         :new.S6_OPERATOR_DATE        := sysdate;
         :new.S6_OPERATOR_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 16;
    end if;
    --
    if nvl(:new.drop_form_chk,'N') != 'Y' THEN
	SSRL_RSW_GET_STATUS 
	(p_form_id		=> :new.SSRL_FORM_ID
	,p_s3_task_person_ack_id	=> :new.S3_TASK_PERSON_ACK_ID
	,p_s3_area_mgr_id	=> :new.S3_AREA_MGR_ID
	,p_s3_sso_id		=> :new.S3_SSO_ID
	,p_s3_rad_id		=> :new.S3_RAD_ID
	,p_s4_operator_id	=> :new.S4_OPERATOR_ID
	,p_s4_wrkr_id		=> :new.S4_WRKR_ID
	,p_s5_task_person_ack_id	=> :new.S5_TASK_PERSON_ACK_ID
	,p_s5_pps_id		=> :new.S5_PPS_ID
	,p_s5_rad_id		=> :new.S5_RAD_ID
	,p_s5_sso_id		=> :new.S5_SSO_ID
	,p_s5_operator_id	=> :new.S5_OPERATOR_ID
	,p_s5_rpfo_id		=> :new.S5_RPFO_ID
	,p_s5_other1_ack_id	=> :new.S5_OTHER1_ACK_ID
	,p_s5_other2_ack_id	=> :new.S5_OTHER2_ACK_ID
	,p_s5_other3_ack_id	=> :new.S5_OTHER3_ACK_ID
	,p_s6_sso_id		=> :new.S6_SSO_ID
	,p_s6_operator_id	=> :new.S6_OPERATOR_ID
	,p_s5_pps_chk		=> :new.S5_PPS_CHK
	,p_s5_rad_chk		=> :new.S5_RAD_CHK
	,p_s5_sso_chk		=> :new.S5_SSO_CHK
	,p_s5_operator_chk	=> :new.S5_OPERATOR_CHK
	,p_s5_rpfo_chk		=> :new.S5_RPFO_CHK
	,p_s5_other1_chk	=> :new.S5_OTHER1_CHK
	,p_s5_other1_id	        => :new.S5_OTHER1_ID
	,p_s5_other2_chk	=> :new.S5_OTHER2_CHK
	,p_s5_other2_id	        => :new.S5_OTHER2_ID
	,p_s5_other3_chk	=> :new.S5_OTHER3_CHK
	,p_s5_other3_id	        => :new.S5_OTHER3_ID
	,p_form_status_id	=> :new.FORM_STATUS_ID
	);
    end if;
    --
    -- Form Status = COMPLETE - Email 
    if :new.form_status_id = 4 and
       :new.form_status_id != :old.form_status_id
    then
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 17;
    end if;
    --
    if :new.SSRL_FORM_ID_TRANSFER_TO is not null and
       :old.SSRL_FORM_ID_TRANSFER_TO is null
    then
         :new.form_status_id := 5; -- Transferred status
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 18;
    end if;
    --
    if :new.form_status_id in (6,7) and
       :new.form_status_id != :old.form_status_id
    then
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 19;
    end if;
    --
    -- Form Status = Work Released - Email 
    if :new.form_status_id = 3 and
       :new.form_status_id != :old.form_status_id
    then
	 :new.EMAIL_CHK := 'Y';	
	 :new.email_rule := 21;
    end if;
    --
end if; -- if updating

END;
/
ALTER TRIGGER "MCC_MAINT"."SSRL_RSW_FORM_BIUDR" ENABLE;
