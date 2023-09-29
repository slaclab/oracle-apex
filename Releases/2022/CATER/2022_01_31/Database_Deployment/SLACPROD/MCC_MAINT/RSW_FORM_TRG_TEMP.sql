-- Disabled all of the checks and updates to various fields due to issues with manual updates to
-- Forms 5991/6009/6116. The status is changing from Closed to Work Not Approved.
-- This is because they do not have the person responsible signature in section which was not implemented until 2015.
-- and the logic is forcing status=Work not approved for this case.

create or replace TRIGGER RSW_FORM_TRG_TEMP
  before insert or update or delete
  ON rsw_form for each row
declare
    c_proc          constant varchar2(100) := 'RSW_FORM_TRG_TEMP ';

  jn_operation                         varchar2(3);
  l_current_user_sid                   number;
  l_current_user                       varchar2(30) := lower(nvl(v('APP_USER'),user));
  l_desc_min_length           constant pls_integer  := 20;
  l_work_requirement_count             pls_integer;
  l_missing_worker_text_count          pls_integer;
  l_s3_complete                        boolean      := false;
  l_s3_adso_entry_complete             boolean      := false;
  l_but_sid		   but.but_sid%type;

    l_form_rec_new           RSW_FORM%rowtype;
    l_form_rec_old           RSW_FORM%rowtype;

  cursor rsw_email_rules_cur is
  select rsw_form_col_name
	from rsw_email_rules
	where status_ai_chk = 'A'
	and   nvl(email_on_chg,'N') = 'Y'
	order by email_rule_id;
 begin
    if inserting and :new.form_id is null then
      select rsw_form_seq.nextval into :new.form_id from dual;
    end if;

    if inserting then
      :new.created_by := l_current_user;
      :new.created_date := sysdate;
    end if;

    if updating then
      :new.modified_by := l_current_user;
      :new.modified_date := sysdate;
    end if;

    if inserting then
      jn_operation := 'INS';
    elsif updating then
      jn_operation := 'UPD';
    elsif deleting then
      jn_operation := 'DEL';
    end if;

	l_form_rec_new.FORM_ID           := :new.FORM_ID;
	l_form_rec_new.PROB_ID           := :new.PROB_ID;
	l_form_rec_new.JOB_ID           := :new.JOB_ID;
	l_form_rec_new.TRANS_ID           := :new.TRANS_ID;
	l_form_rec_new.S1_DESCR           := :new.S1_DESCR;
	l_form_rec_new.S1_WORK           := :new.S1_WORK;
	l_form_rec_new.S1_TASK_PERSON_ID           := :new.S1_TASK_PERSON_ID;
	l_form_rec_new.S1_TASK_PERSON_DATE           := :new.S1_TASK_PERSON_DATE;
	l_form_rec_new.S1_AREA_ID           := :new.S1_AREA_ID;
	l_form_rec_new.S1_AREA_MGR_ID           := :new.S1_AREA_MGR_ID;
	l_form_rec_new.S1_AREA_MGR_DATE           := :new.S1_AREA_MGR_DATE;
	l_form_rec_new.S1_AREA_MGR_MODIFIED_BY           := :new.S1_AREA_MGR_MODIFIED_BY;
	l_form_rec_new.S1_PPS_ZONE_ID           := :new.S1_PPS_ZONE_ID;
	l_form_rec_new.S1_GROUP_ID           := :new.S1_GROUP_ID;
	l_form_rec_new.S2_REQMTS_NEEDED           := :new.S2_REQMTS_NEEDED;
	l_form_rec_new.S2_DESCR           := :new.S2_DESCR;
	l_form_rec_new.S2_REQS           := :new.S2_REQS;
	l_form_rec_new.S2_ADSO_ID           := :new.S2_ADSO_ID;
	l_form_rec_new.S2_ADSO_DATE           := :new.S2_ADSO_DATE;
	l_form_rec_new.S2_ADSO_MODIFIED_BY           := :new.S2_ADSO_MODIFIED_BY;
	l_form_rec_new.S2_RAD_ID           := :new.S2_RAD_ID;
	l_form_rec_new.S2_RAD_DATE           := :new.S2_RAD_DATE;
	l_form_rec_new.S2_RAD_MODIFIED_BY           := :new.S2_RAD_MODIFIED_BY;
	l_form_rec_new.S2_EOIC_ID           := :new.S2_EOIC_ID;
	l_form_rec_new.S2_EOIC_DATE           := :new.S2_EOIC_DATE;
	l_form_rec_new.S2_EOIC_MODIFIED_BY           := :new.S2_EOIC_MODIFIED_BY;
	l_form_rec_new.S3_ADSO_WORK_REQSEL           := :new.S3_ADSO_WORK_REQSEL;
	l_form_rec_new.S3_ADSO_WRK_RQMTS_ADSO           := :new.S3_ADSO_WRK_RQMTS_ADSO;
	l_form_rec_new.S3_ADSO_WRK_RQMTS_ADSO_DATE           := :new.S3_ADSO_WRK_RQMTS_ADSO_DATE;
	l_form_rec_new.S3_ADSO_WRK_RQMTS_ADSO_NAME           := :new.S3_ADSO_WRK_RQMTS_ADSO_NAME;
	l_form_rec_new.S3_ADSO_WRK_RQMTS_WRKR           := :new.S3_ADSO_WRK_RQMTS_WRKR;
	l_form_rec_new.S3_ADSO_WRK_RQMTS_WRKR_DATE           := :new.S3_ADSO_WRK_RQMTS_WRKR_DATE;
	l_form_rec_new.S3_ADSO_WRK_RQMTS_WRKR_NAME           := :new.S3_ADSO_WRK_RQMTS_WRKR_NAME;
	l_form_rec_new.S3_ADSO_WRK_RQMTS_ADSO_APID           := :new.S3_ADSO_WRK_RQMTS_ADSO_APID;
	l_form_rec_new.S3_ADSO_WRK_RQMTS_ADSO_APDT           := :new.S3_ADSO_WRK_RQMTS_ADSO_APDT;
	l_form_rec_new.S3_ADSO_WRK_RQMTS_ADSO_APNM           := :new.S3_ADSO_WRK_RQMTS_ADSO_APNM;
	l_form_rec_new.S3_REM_OR_BYP_ADSO           := :new.S3_REM_OR_BYP_ADSO;
	l_form_rec_new.S3_REM_OR_BYP_ADSO_DATE           := :new.S3_REM_OR_BYP_ADSO_DATE;
	l_form_rec_new.S3_REM_OR_BYP_ADSO_NAME           := :new.S3_REM_OR_BYP_ADSO_NAME;
	l_form_rec_new.S3_REM_OR_BYP_WRKR           := :new.S3_REM_OR_BYP_WRKR;
	l_form_rec_new.S3_REM_OR_BYP_WRKR_DATE           := :new.S3_REM_OR_BYP_WRKR_DATE;
	l_form_rec_new.S3_REM_OR_BYP_WRKR_NAME           := :new.S3_REM_OR_BYP_WRKR_NAME;
	l_form_rec_new.S3_REM_OR_BYP_ADSO_APID           := :new.S3_REM_OR_BYP_ADSO_APID;
	l_form_rec_new.S3_REM_OR_BYP_ADSO_APDT           := :new.S3_REM_OR_BYP_ADSO_APDT;
	l_form_rec_new.S3_REM_OR_BYP_ADSO_APNM           := :new.S3_REM_OR_BYP_ADSO_APNM;
	l_form_rec_new.S3_REIN_OR_UNBYP_ADSO           := :new.S3_REIN_OR_UNBYP_ADSO;
	l_form_rec_new.S3_REIN_OR_UNBYP_ADSO_DATE           := :new.S3_REIN_OR_UNBYP_ADSO_DATE;
	l_form_rec_new.S3_REIN_OR_UNBYP_ADSO_NAME           := :new.S3_REIN_OR_UNBYP_ADSO_NAME;
	l_form_rec_new.S3_REIN_OR_UNBYP_WRKR           := :new.S3_REIN_OR_UNBYP_WRKR;
	l_form_rec_new.S3_REIN_OR_UNBYP_WRKR_DATE           := :new.S3_REIN_OR_UNBYP_WRKR_DATE;
	l_form_rec_new.S3_REIN_OR_UNBYP_WRKR_NAME           := :new.S3_REIN_OR_UNBYP_WRKR_NAME;
	l_form_rec_new.S3_REIN_OR_UNBYP_ADSO_APID           := :new.S3_REIN_OR_UNBYP_ADSO_APID;
	l_form_rec_new.S3_REIN_OR_UNBYP_ADSO_APDT           := :new.S3_REIN_OR_UNBYP_ADSO_APDT;
	l_form_rec_new.S3_REIN_OR_UNBYP_ADSO_APNM           := :new.S3_REIN_OR_UNBYP_ADSO_APNM;
	l_form_rec_new.S3_WRK_COMP_ADSO           := :new.S3_WRK_COMP_ADSO;
	l_form_rec_new.S3_WRK_COMP_ADSO_DATE           := :new.S3_WRK_COMP_ADSO_DATE;
	l_form_rec_new.S3_WRK_COMP_ADSO_NAME           := :new.S3_WRK_COMP_ADSO_NAME;
	l_form_rec_new.S3_WRK_COMP_WRKR           := :new.S3_WRK_COMP_WRKR;
	l_form_rec_new.S3_WRK_COMP_WRKR_DATE           := :new.S3_WRK_COMP_WRKR_DATE;
	l_form_rec_new.S3_WRK_COMP_WRKR_NAME           := :new.S3_WRK_COMP_WRKR_NAME;
	l_form_rec_new.S3_WRK_COMP_ADSO_APID           := :new.S3_WRK_COMP_ADSO_APID;
	l_form_rec_new.S3_WRK_COMP_ADSO_APDT           := :new.S3_WRK_COMP_ADSO_APDT;
	l_form_rec_new.S3_WRK_COMP_ADSO_APNM           := :new.S3_WRK_COMP_ADSO_APNM;
	l_form_rec_new.S3_PPS_ADSO           := :new.S3_PPS_ADSO;
	l_form_rec_new.S3_PPS_ADSO_DATE           := :new.S3_PPS_ADSO_DATE;
	l_form_rec_new.S3_PPS_ADSO_NAME           := :new.S3_PPS_ADSO_NAME;
	l_form_rec_new.S3_PPS_WRKR           := :new.S3_PPS_WRKR;
	l_form_rec_new.S3_PPS_WRKR_DATE           := :new.S3_PPS_WRKR_DATE;
	l_form_rec_new.S3_PPS_WRKR_NAME           := :new.S3_PPS_WRKR_NAME;
	l_form_rec_new.S3_PPS_ADSO_APID           := :new.S3_PPS_ADSO_APID;
	l_form_rec_new.S3_PPS_ADSO_APDT           := :new.S3_PPS_ADSO_APDT;
	l_form_rec_new.S3_PPS_ADSO_APNM           := :new.S3_PPS_ADSO_APNM;
	l_form_rec_new.S3_RAD_PHYS_ADSO           := :new.S3_RAD_PHYS_ADSO;
	l_form_rec_new.S3_RAD_PHYS_ADSO_DATE           := :new.S3_RAD_PHYS_ADSO_DATE;
	l_form_rec_new.S3_RAD_PHYS_ADSO_NAME           := :new.S3_RAD_PHYS_ADSO_NAME;
	l_form_rec_new.S3_RAD_PHYS_WRKR           := :new.S3_RAD_PHYS_WRKR;
	l_form_rec_new.S3_RAD_PHYS_WRKR_DATE           := :new.S3_RAD_PHYS_WRKR_DATE;
	l_form_rec_new.S3_RAD_PHYS_WRKR_NAME           := :new.S3_RAD_PHYS_WRKR_NAME;
	l_form_rec_new.S3_RAD_PHYS_ADSO_APID           := :new.S3_RAD_PHYS_ADSO_APID;
	l_form_rec_new.S3_RAD_PHYS_ADSO_APDT           := :new.S3_RAD_PHYS_ADSO_APDT;
	l_form_rec_new.S3_RAD_PHYS_ADSO_APNM           := :new.S3_RAD_PHYS_ADSO_APNM;
	l_form_rec_new.S3_BCS_ADSO           := :new.S3_BCS_ADSO;
	l_form_rec_new.S3_BCS_ADSO_DATE           := :new.S3_BCS_ADSO_DATE;
	l_form_rec_new.S3_BCS_ADSO_NAME           := :new.S3_BCS_ADSO_NAME;
	l_form_rec_new.S3_BCS_WRKR           := :new.S3_BCS_WRKR;
	l_form_rec_new.S3_BCS_WRKR_DATE           := :new.S3_BCS_WRKR_DATE;
	l_form_rec_new.S3_BCS_WRKR_NAME           := :new.S3_BCS_WRKR_NAME;
	l_form_rec_new.S3_BCS_ADSO_APID           := :new.S3_BCS_ADSO_APID;
	l_form_rec_new.S3_BCS_ADSO_APDT           := :new.S3_BCS_ADSO_APDT;
	l_form_rec_new.S3_BCS_ADSO_APNM           := :new.S3_BCS_ADSO_APNM;
	l_form_rec_new.S3_RPFO_ADSO           := :new.S3_RPFO_ADSO;
	l_form_rec_new.S3_RPFO_ADSO_DATE           := :new.S3_RPFO_ADSO_DATE;
	l_form_rec_new.S3_RPFO_ADSO_NAME           := :new.S3_RPFO_ADSO_NAME;
	l_form_rec_new.S3_RPFO_WRKR           := :new.S3_RPFO_WRKR;
	l_form_rec_new.S3_RPFO_WRKR_DATE           := :new.S3_RPFO_WRKR_DATE;
	l_form_rec_new.S3_RPFO_WRKR_NAME           := :new.S3_RPFO_WRKR_NAME;
	l_form_rec_new.S3_RPFO_ADSO_APID           := :new.S3_RPFO_ADSO_APID;
	l_form_rec_new.S3_RPFO_ADSO_APDT           := :new.S3_RPFO_ADSO_APDT;
	l_form_rec_new.S3_RPFO_ADSO_APNM           := :new.S3_RPFO_ADSO_APNM;
	l_form_rec_new.S3_OPNS_ADSO           := :new.S3_OPNS_ADSO;
	l_form_rec_new.S3_OPNS_ADSO_DATE           := :new.S3_OPNS_ADSO_DATE;
	l_form_rec_new.S3_OPNS_ADSO_NAME           := :new.S3_OPNS_ADSO_NAME;
	l_form_rec_new.S3_OPNS_WRKR           := :new.S3_OPNS_WRKR;
	l_form_rec_new.S3_OPNS_WRKR_DATE           := :new.S3_OPNS_WRKR_DATE;
	l_form_rec_new.S3_OPNS_WRKR_NAME           := :new.S3_OPNS_WRKR_NAME;
	l_form_rec_new.S3_OPNS_ADSO_APID           := :new.S3_OPNS_ADSO_APID;
	l_form_rec_new.S3_OPNS_ADSO_APDT           := :new.S3_OPNS_ADSO_APDT;
	l_form_rec_new.S3_OPNS_ADSO_APNM           := :new.S3_OPNS_ADSO_APNM;
	l_form_rec_new.S3_BAS_CHG_ADSO           := :new.S3_BAS_CHG_ADSO;
	l_form_rec_new.S3_BAS_CHG_ADSO_DATE           := :new.S3_BAS_CHG_ADSO_DATE;
	l_form_rec_new.S3_BAS_CHG_ADSO_NAME           := :new.S3_BAS_CHG_ADSO_NAME;
	l_form_rec_new.S3_BAS_CHG_WRKR           := :new.S3_BAS_CHG_WRKR;
	l_form_rec_new.S3_BAS_CHG_WRKR_DATE           := :new.S3_BAS_CHG_WRKR_DATE;
	l_form_rec_new.S3_BAS_CHG_WRKR_NAME           := :new.S3_BAS_CHG_WRKR_NAME;
	l_form_rec_new.S3_BAS_CHG_ADSO_APID           := :new.S3_BAS_CHG_ADSO_APID;
	l_form_rec_new.S3_BAS_CHG_ADSO_APDT           := :new.S3_BAS_CHG_ADSO_APDT;
	l_form_rec_new.S3_BAS_CHG_ADSO_APNM           := :new.S3_BAS_CHG_ADSO_APNM;
	l_form_rec_new.S3_OTHER_ADSO           := :new.S3_OTHER_ADSO;
	l_form_rec_new.S3_OTHER_ADSO_DATE           := :new.S3_OTHER_ADSO_DATE;
	l_form_rec_new.S3_OTHER_ADSO_NAME           := :new.S3_OTHER_ADSO_NAME;
	l_form_rec_new.S3_OTHER_WRKR           := :new.S3_OTHER_WRKR;
	l_form_rec_new.S3_OTHER_WRKR_DATE           := :new.S3_OTHER_WRKR_DATE;
	l_form_rec_new.S3_OTHER_WRKR_NAME           := :new.S3_OTHER_WRKR_NAME;
	l_form_rec_new.S3_OTHER_ADSO_APID           := :new.S3_OTHER_ADSO_APID;
	l_form_rec_new.S3_OTHER_ADSO_APDT           := :new.S3_OTHER_ADSO_APDT;
	l_form_rec_new.S3_OTHER_ADSO_APNM           := :new.S3_OTHER_ADSO_APNM;
	l_form_rec_new.S3_OTHER1_ADSO           := :new.S3_OTHER1_ADSO;
	l_form_rec_new.S3_OTHER1_ADSO_DATE           := :new.S3_OTHER1_ADSO_DATE;
	l_form_rec_new.S3_OTHER1_ADSO_NAME           := :new.S3_OTHER1_ADSO_NAME;
	l_form_rec_new.S3_OTHER1_WRKR           := :new.S3_OTHER1_WRKR;
	l_form_rec_new.S3_OTHER1_WRKR_DATE           := :new.S3_OTHER1_WRKR_DATE;
	l_form_rec_new.S3_OTHER1_WRKR_NAME           := :new.S3_OTHER1_WRKR_NAME;
	l_form_rec_new.S3_OTHER1_ADSO_APID           := :new.S3_OTHER1_ADSO_APID;
	l_form_rec_new.S3_OTHER1_ADSO_APDT           := :new.S3_OTHER1_ADSO_APDT;
	l_form_rec_new.S3_OTHER1_ADSO_APNM           := :new.S3_OTHER1_ADSO_APNM;
	l_form_rec_new.S3_OTHER2_ADSO           := :new.S3_OTHER2_ADSO;
	l_form_rec_new.S3_OTHER2_ADSO_DATE           := :new.S3_OTHER2_ADSO_DATE;
	l_form_rec_new.S3_OTHER2_ADSO_NAME           := :new.S3_OTHER2_ADSO_NAME;
	l_form_rec_new.S3_OTHER2_WRKR           := :new.S3_OTHER2_WRKR;
	l_form_rec_new.S3_OTHER2_WRKR_DATE           := :new.S3_OTHER2_WRKR_DATE;
	l_form_rec_new.S3_OTHER2_WRKR_NAME           := :new.S3_OTHER2_WRKR_NAME;
	l_form_rec_new.S3_OTHER2_ADSO_APID           := :new.S3_OTHER2_ADSO_APID;
	l_form_rec_new.S3_OTHER2_ADSO_APDT           := :new.S3_OTHER2_ADSO_APDT;
	l_form_rec_new.S3_OTHER2_ADSO_APNM           := :new.S3_OTHER2_ADSO_APNM;
	l_form_rec_new.S4_ADSO_ID           := :new.S4_ADSO_ID;
	l_form_rec_new.S4_ADSO_DATE           := :new.S4_ADSO_DATE;
	l_form_rec_new.S4_ADSO_MODIFIED_BY           := :new.S4_ADSO_MODIFIED_BY;
	l_form_rec_new.S4_EOIC_ID           := :new.S4_EOIC_ID;
	l_form_rec_new.S4_EOIC_DATE           := :new.S4_EOIC_DATE;
	l_form_rec_new.S4_EOIC_MODIFIED_BY           := :new.S4_EOIC_MODIFIED_BY;
	l_form_rec_new.S4_READY_FOR_BEAM_REQMTS           := :new.S4_READY_FOR_BEAM_REQMTS;
	l_form_rec_new.S4_CLOSE           := :new.S4_CLOSE;
	l_form_rec_new.FILE_ID           := :new.FILE_ID;
	l_form_rec_new.FORM_STATUS_ID           := :new.FORM_STATUS_ID;
	l_form_rec_new.RESET_WORK_COMPLETE           := :new.RESET_WORK_COMPLETE;
	l_form_rec_new.CREATED_BY           := :new.CREATED_BY;
	l_form_rec_new.CREATED_DATE           := :new.CREATED_DATE;
	l_form_rec_new.MODIFIED_BY           := :new.MODIFIED_BY;
	l_form_rec_new.MODIFIED_DATE           := :new.MODIFIED_DATE;
	l_form_rec_new.STATUS_HAS_BEEN_WORK_APPROVED           := :new.STATUS_HAS_BEEN_WORK_APPROVED;
	l_form_rec_new.S2_DESCR_DATE           := :new.S2_DESCR_DATE;
	l_form_rec_new.S2_DESCR_MODIFIED_BY           := :new.S2_DESCR_MODIFIED_BY;
	l_form_rec_new.STATUS_HAS_BEEN_WORK_APDT           := :new.STATUS_HAS_BEEN_WORK_APDT;
	l_form_rec_new.S2_TASK_PERSON_ACK_ID           := :new.S2_TASK_PERSON_ACK_ID;
	l_form_rec_new.S2_TASK_PERSON_ACK_DATE           := :new.S2_TASK_PERSON_ACK_DATE;
	l_form_rec_new.S2_TASK_PERSON_ACK_MODIFIED_BY           := :new.S2_TASK_PERSON_ACK_MODIFIED_BY;
	l_form_rec_new.EMAIL_CHK           := :new.EMAIL_CHK;

	if updating
	then
		l_form_rec_old.FORM_ID           := :old.FORM_ID;
		l_form_rec_old.PROB_ID           := :old.PROB_ID;
		l_form_rec_old.JOB_ID           := :old.JOB_ID;
		l_form_rec_old.TRANS_ID           := :old.TRANS_ID;
		l_form_rec_old.S1_DESCR           := :old.S1_DESCR;
		l_form_rec_old.S1_WORK           := :old.S1_WORK;
		l_form_rec_old.S1_TASK_PERSON_ID           := :old.S1_TASK_PERSON_ID;
		l_form_rec_old.S1_TASK_PERSON_DATE           := :old.S1_TASK_PERSON_DATE;
		l_form_rec_old.S1_AREA_ID           := :old.S1_AREA_ID;
		l_form_rec_old.S1_AREA_MGR_ID           := :old.S1_AREA_MGR_ID;
		l_form_rec_old.S1_AREA_MGR_DATE           := :old.S1_AREA_MGR_DATE;
		l_form_rec_old.S1_AREA_MGR_MODIFIED_BY           := :old.S1_AREA_MGR_MODIFIED_BY;
		l_form_rec_old.S1_PPS_ZONE_ID           := :old.S1_PPS_ZONE_ID;
		l_form_rec_old.S1_GROUP_ID           := :old.S1_GROUP_ID;
		l_form_rec_old.S2_REQMTS_NEEDED           := :old.S2_REQMTS_NEEDED;
		l_form_rec_old.S2_DESCR           := :old.S2_DESCR;
		l_form_rec_old.S2_REQS           := :old.S2_REQS;
		l_form_rec_old.S2_ADSO_ID           := :old.S2_ADSO_ID;
		l_form_rec_old.S2_ADSO_DATE           := :old.S2_ADSO_DATE;
		l_form_rec_old.S2_ADSO_MODIFIED_BY           := :old.S2_ADSO_MODIFIED_BY;
		l_form_rec_old.S2_RAD_ID           := :old.S2_RAD_ID;
		l_form_rec_old.S2_RAD_DATE           := :old.S2_RAD_DATE;
		l_form_rec_old.S2_RAD_MODIFIED_BY           := :old.S2_RAD_MODIFIED_BY;
		l_form_rec_old.S2_EOIC_ID           := :old.S2_EOIC_ID;
		l_form_rec_old.S2_EOIC_DATE           := :old.S2_EOIC_DATE;
		l_form_rec_old.S2_EOIC_MODIFIED_BY           := :old.S2_EOIC_MODIFIED_BY;
		l_form_rec_old.S3_ADSO_WORK_REQSEL           := :old.S3_ADSO_WORK_REQSEL;
		l_form_rec_old.S3_ADSO_WRK_RQMTS_ADSO           := :old.S3_ADSO_WRK_RQMTS_ADSO;
		l_form_rec_old.S3_ADSO_WRK_RQMTS_ADSO_DATE           := :old.S3_ADSO_WRK_RQMTS_ADSO_DATE;
		l_form_rec_old.S3_ADSO_WRK_RQMTS_ADSO_NAME           := :old.S3_ADSO_WRK_RQMTS_ADSO_NAME;
		l_form_rec_old.S3_ADSO_WRK_RQMTS_WRKR           := :old.S3_ADSO_WRK_RQMTS_WRKR;
		l_form_rec_old.S3_ADSO_WRK_RQMTS_WRKR_DATE           := :old.S3_ADSO_WRK_RQMTS_WRKR_DATE;
		l_form_rec_old.S3_ADSO_WRK_RQMTS_WRKR_NAME           := :old.S3_ADSO_WRK_RQMTS_WRKR_NAME;
		l_form_rec_old.S3_ADSO_WRK_RQMTS_ADSO_APID           := :old.S3_ADSO_WRK_RQMTS_ADSO_APID;
		l_form_rec_old.S3_ADSO_WRK_RQMTS_ADSO_APDT           := :old.S3_ADSO_WRK_RQMTS_ADSO_APDT;
		l_form_rec_old.S3_ADSO_WRK_RQMTS_ADSO_APNM           := :old.S3_ADSO_WRK_RQMTS_ADSO_APNM;
		l_form_rec_old.S3_REM_OR_BYP_ADSO           := :old.S3_REM_OR_BYP_ADSO;
		l_form_rec_old.S3_REM_OR_BYP_ADSO_DATE           := :old.S3_REM_OR_BYP_ADSO_DATE;
		l_form_rec_old.S3_REM_OR_BYP_ADSO_NAME           := :old.S3_REM_OR_BYP_ADSO_NAME;
		l_form_rec_old.S3_REM_OR_BYP_WRKR           := :old.S3_REM_OR_BYP_WRKR;
		l_form_rec_old.S3_REM_OR_BYP_WRKR_DATE           := :old.S3_REM_OR_BYP_WRKR_DATE;
		l_form_rec_old.S3_REM_OR_BYP_WRKR_NAME           := :old.S3_REM_OR_BYP_WRKR_NAME;
		l_form_rec_old.S3_REM_OR_BYP_ADSO_APID           := :old.S3_REM_OR_BYP_ADSO_APID;
		l_form_rec_old.S3_REM_OR_BYP_ADSO_APDT           := :old.S3_REM_OR_BYP_ADSO_APDT;
		l_form_rec_old.S3_REM_OR_BYP_ADSO_APNM           := :old.S3_REM_OR_BYP_ADSO_APNM;
		l_form_rec_old.S3_REIN_OR_UNBYP_ADSO           := :old.S3_REIN_OR_UNBYP_ADSO;
		l_form_rec_old.S3_REIN_OR_UNBYP_ADSO_DATE           := :old.S3_REIN_OR_UNBYP_ADSO_DATE;
		l_form_rec_old.S3_REIN_OR_UNBYP_ADSO_NAME           := :old.S3_REIN_OR_UNBYP_ADSO_NAME;
		l_form_rec_old.S3_REIN_OR_UNBYP_WRKR           := :old.S3_REIN_OR_UNBYP_WRKR;
		l_form_rec_old.S3_REIN_OR_UNBYP_WRKR_DATE           := :old.S3_REIN_OR_UNBYP_WRKR_DATE;
		l_form_rec_old.S3_REIN_OR_UNBYP_WRKR_NAME           := :old.S3_REIN_OR_UNBYP_WRKR_NAME;
		l_form_rec_old.S3_REIN_OR_UNBYP_ADSO_APID           := :old.S3_REIN_OR_UNBYP_ADSO_APID;
		l_form_rec_old.S3_REIN_OR_UNBYP_ADSO_APDT           := :old.S3_REIN_OR_UNBYP_ADSO_APDT;
		l_form_rec_old.S3_REIN_OR_UNBYP_ADSO_APNM           := :old.S3_REIN_OR_UNBYP_ADSO_APNM;
		l_form_rec_old.S3_WRK_COMP_ADSO           := :old.S3_WRK_COMP_ADSO;
		l_form_rec_old.S3_WRK_COMP_ADSO_DATE           := :old.S3_WRK_COMP_ADSO_DATE;
		l_form_rec_old.S3_WRK_COMP_ADSO_NAME           := :old.S3_WRK_COMP_ADSO_NAME;
		l_form_rec_old.S3_WRK_COMP_WRKR           := :old.S3_WRK_COMP_WRKR;
		l_form_rec_old.S3_WRK_COMP_WRKR_DATE           := :old.S3_WRK_COMP_WRKR_DATE;
		l_form_rec_old.S3_WRK_COMP_WRKR_NAME           := :old.S3_WRK_COMP_WRKR_NAME;
		l_form_rec_old.S3_WRK_COMP_ADSO_APID           := :old.S3_WRK_COMP_ADSO_APID;
		l_form_rec_old.S3_WRK_COMP_ADSO_APDT           := :old.S3_WRK_COMP_ADSO_APDT;
		l_form_rec_old.S3_WRK_COMP_ADSO_APNM           := :old.S3_WRK_COMP_ADSO_APNM;
		l_form_rec_old.S3_PPS_ADSO           := :old.S3_PPS_ADSO;
		l_form_rec_old.S3_PPS_ADSO_DATE           := :old.S3_PPS_ADSO_DATE;
		l_form_rec_old.S3_PPS_ADSO_NAME           := :old.S3_PPS_ADSO_NAME;
		l_form_rec_old.S3_PPS_WRKR           := :old.S3_PPS_WRKR;
		l_form_rec_old.S3_PPS_WRKR_DATE           := :old.S3_PPS_WRKR_DATE;
		l_form_rec_old.S3_PPS_WRKR_NAME           := :old.S3_PPS_WRKR_NAME;
		l_form_rec_old.S3_PPS_ADSO_APID           := :old.S3_PPS_ADSO_APID;
		l_form_rec_old.S3_PPS_ADSO_APDT           := :old.S3_PPS_ADSO_APDT;
		l_form_rec_old.S3_PPS_ADSO_APNM           := :old.S3_PPS_ADSO_APNM;
		l_form_rec_old.S3_RAD_PHYS_ADSO           := :old.S3_RAD_PHYS_ADSO;
		l_form_rec_old.S3_RAD_PHYS_ADSO_DATE           := :old.S3_RAD_PHYS_ADSO_DATE;
		l_form_rec_old.S3_RAD_PHYS_ADSO_NAME           := :old.S3_RAD_PHYS_ADSO_NAME;
		l_form_rec_old.S3_RAD_PHYS_WRKR           := :old.S3_RAD_PHYS_WRKR;
		l_form_rec_old.S3_RAD_PHYS_WRKR_DATE           := :old.S3_RAD_PHYS_WRKR_DATE;
		l_form_rec_old.S3_RAD_PHYS_WRKR_NAME           := :old.S3_RAD_PHYS_WRKR_NAME;
		l_form_rec_old.S3_RAD_PHYS_ADSO_APID           := :old.S3_RAD_PHYS_ADSO_APID;
		l_form_rec_old.S3_RAD_PHYS_ADSO_APDT           := :old.S3_RAD_PHYS_ADSO_APDT;
		l_form_rec_old.S3_RAD_PHYS_ADSO_APNM           := :old.S3_RAD_PHYS_ADSO_APNM;
		l_form_rec_old.S3_BCS_ADSO           := :old.S3_BCS_ADSO;
		l_form_rec_old.S3_BCS_ADSO_DATE           := :old.S3_BCS_ADSO_DATE;
		l_form_rec_old.S3_BCS_ADSO_NAME           := :old.S3_BCS_ADSO_NAME;
		l_form_rec_old.S3_BCS_WRKR           := :old.S3_BCS_WRKR;
		l_form_rec_old.S3_BCS_WRKR_DATE           := :old.S3_BCS_WRKR_DATE;
		l_form_rec_old.S3_BCS_WRKR_NAME           := :old.S3_BCS_WRKR_NAME;
		l_form_rec_old.S3_BCS_ADSO_APID           := :old.S3_BCS_ADSO_APID;
		l_form_rec_old.S3_BCS_ADSO_APDT           := :old.S3_BCS_ADSO_APDT;
		l_form_rec_old.S3_BCS_ADSO_APNM           := :old.S3_BCS_ADSO_APNM;
		l_form_rec_old.S3_RPFO_ADSO           := :old.S3_RPFO_ADSO;
		l_form_rec_old.S3_RPFO_ADSO_DATE           := :old.S3_RPFO_ADSO_DATE;
		l_form_rec_old.S3_RPFO_ADSO_NAME           := :old.S3_RPFO_ADSO_NAME;
		l_form_rec_old.S3_RPFO_WRKR           := :old.S3_RPFO_WRKR;
		l_form_rec_old.S3_RPFO_WRKR_DATE           := :old.S3_RPFO_WRKR_DATE;
		l_form_rec_old.S3_RPFO_WRKR_NAME           := :old.S3_RPFO_WRKR_NAME;
		l_form_rec_old.S3_RPFO_ADSO_APID           := :old.S3_RPFO_ADSO_APID;
		l_form_rec_old.S3_RPFO_ADSO_APDT           := :old.S3_RPFO_ADSO_APDT;
		l_form_rec_old.S3_RPFO_ADSO_APNM           := :old.S3_RPFO_ADSO_APNM;
		l_form_rec_old.S3_OPNS_ADSO           := :old.S3_OPNS_ADSO;
		l_form_rec_old.S3_OPNS_ADSO_DATE           := :old.S3_OPNS_ADSO_DATE;
		l_form_rec_old.S3_OPNS_ADSO_NAME           := :old.S3_OPNS_ADSO_NAME;
		l_form_rec_old.S3_OPNS_WRKR           := :old.S3_OPNS_WRKR;
		l_form_rec_old.S3_OPNS_WRKR_DATE           := :old.S3_OPNS_WRKR_DATE;
		l_form_rec_old.S3_OPNS_WRKR_NAME           := :old.S3_OPNS_WRKR_NAME;
		l_form_rec_old.S3_OPNS_ADSO_APID           := :old.S3_OPNS_ADSO_APID;
		l_form_rec_old.S3_OPNS_ADSO_APDT           := :old.S3_OPNS_ADSO_APDT;
		l_form_rec_old.S3_OPNS_ADSO_APNM           := :old.S3_OPNS_ADSO_APNM;
		l_form_rec_old.S3_BAS_CHG_ADSO           := :old.S3_BAS_CHG_ADSO;
		l_form_rec_old.S3_BAS_CHG_ADSO_DATE           := :old.S3_BAS_CHG_ADSO_DATE;
		l_form_rec_old.S3_BAS_CHG_ADSO_NAME           := :old.S3_BAS_CHG_ADSO_NAME;
		l_form_rec_old.S3_BAS_CHG_WRKR           := :old.S3_BAS_CHG_WRKR;
		l_form_rec_old.S3_BAS_CHG_WRKR_DATE           := :old.S3_BAS_CHG_WRKR_DATE;
		l_form_rec_old.S3_BAS_CHG_WRKR_NAME           := :old.S3_BAS_CHG_WRKR_NAME;
		l_form_rec_old.S3_BAS_CHG_ADSO_APID           := :old.S3_BAS_CHG_ADSO_APID;
		l_form_rec_old.S3_BAS_CHG_ADSO_APDT           := :old.S3_BAS_CHG_ADSO_APDT;
		l_form_rec_old.S3_BAS_CHG_ADSO_APNM           := :old.S3_BAS_CHG_ADSO_APNM;
		l_form_rec_old.S3_OTHER_ADSO           := :old.S3_OTHER_ADSO;
		l_form_rec_old.S3_OTHER_ADSO_DATE           := :old.S3_OTHER_ADSO_DATE;
		l_form_rec_old.S3_OTHER_ADSO_NAME           := :old.S3_OTHER_ADSO_NAME;
		l_form_rec_old.S3_OTHER_WRKR           := :old.S3_OTHER_WRKR;
		l_form_rec_old.S3_OTHER_WRKR_DATE           := :old.S3_OTHER_WRKR_DATE;
		l_form_rec_old.S3_OTHER_WRKR_NAME           := :old.S3_OTHER_WRKR_NAME;
		l_form_rec_old.S3_OTHER_ADSO_APID           := :old.S3_OTHER_ADSO_APID;
		l_form_rec_old.S3_OTHER_ADSO_APDT           := :old.S3_OTHER_ADSO_APDT;
		l_form_rec_old.S3_OTHER_ADSO_APNM           := :old.S3_OTHER_ADSO_APNM;
		l_form_rec_old.S3_OTHER1_ADSO           := :old.S3_OTHER1_ADSO;
		l_form_rec_old.S3_OTHER1_ADSO_DATE           := :old.S3_OTHER1_ADSO_DATE;
		l_form_rec_old.S3_OTHER1_ADSO_NAME           := :old.S3_OTHER1_ADSO_NAME;
		l_form_rec_old.S3_OTHER1_WRKR           := :old.S3_OTHER1_WRKR;
		l_form_rec_old.S3_OTHER1_WRKR_DATE           := :old.S3_OTHER1_WRKR_DATE;
		l_form_rec_old.S3_OTHER1_WRKR_NAME           := :old.S3_OTHER1_WRKR_NAME;
		l_form_rec_old.S3_OTHER1_ADSO_APID           := :old.S3_OTHER1_ADSO_APID;
		l_form_rec_old.S3_OTHER1_ADSO_APDT           := :old.S3_OTHER1_ADSO_APDT;
		l_form_rec_old.S3_OTHER1_ADSO_APNM           := :old.S3_OTHER1_ADSO_APNM;
		l_form_rec_old.S3_OTHER2_ADSO           := :old.S3_OTHER2_ADSO;
		l_form_rec_old.S3_OTHER2_ADSO_DATE           := :old.S3_OTHER2_ADSO_DATE;
		l_form_rec_old.S3_OTHER2_ADSO_NAME           := :old.S3_OTHER2_ADSO_NAME;
		l_form_rec_old.S3_OTHER2_WRKR           := :old.S3_OTHER2_WRKR;
		l_form_rec_old.S3_OTHER2_WRKR_DATE           := :old.S3_OTHER2_WRKR_DATE;
		l_form_rec_old.S3_OTHER2_WRKR_NAME           := :old.S3_OTHER2_WRKR_NAME;
		l_form_rec_old.S3_OTHER2_ADSO_APID           := :old.S3_OTHER2_ADSO_APID;
		l_form_rec_old.S3_OTHER2_ADSO_APDT           := :old.S3_OTHER2_ADSO_APDT;
		l_form_rec_old.S3_OTHER2_ADSO_APNM           := :old.S3_OTHER2_ADSO_APNM;
		l_form_rec_old.S4_ADSO_ID           := :old.S4_ADSO_ID;
		l_form_rec_old.S4_ADSO_DATE           := :old.S4_ADSO_DATE;
		l_form_rec_old.S4_ADSO_MODIFIED_BY           := :old.S4_ADSO_MODIFIED_BY;
		l_form_rec_old.S4_EOIC_ID           := :old.S4_EOIC_ID;
		l_form_rec_old.S4_EOIC_DATE           := :old.S4_EOIC_DATE;
		l_form_rec_old.S4_EOIC_MODIFIED_BY           := :old.S4_EOIC_MODIFIED_BY;
		l_form_rec_old.S4_READY_FOR_BEAM_REQMTS           := :old.S4_READY_FOR_BEAM_REQMTS;
		l_form_rec_old.S4_CLOSE           := :old.S4_CLOSE;
		l_form_rec_old.FILE_ID           := :old.FILE_ID;
		l_form_rec_old.FORM_STATUS_ID           := :old.FORM_STATUS_ID;
		l_form_rec_old.RESET_WORK_COMPLETE           := :old.RESET_WORK_COMPLETE;
		l_form_rec_old.CREATED_BY           := :old.CREATED_BY;
		l_form_rec_old.CREATED_DATE           := :old.CREATED_DATE;
		l_form_rec_old.MODIFIED_BY           := :old.MODIFIED_BY;
		l_form_rec_old.MODIFIED_DATE           := :old.MODIFIED_DATE;
		l_form_rec_old.STATUS_HAS_BEEN_WORK_APPROVED           := :old.STATUS_HAS_BEEN_WORK_APPROVED;
		l_form_rec_old.S2_DESCR_DATE           := :old.S2_DESCR_DATE;
		l_form_rec_old.S2_DESCR_MODIFIED_BY           := :old.S2_DESCR_MODIFIED_BY;
		l_form_rec_old.STATUS_HAS_BEEN_WORK_APDT           := :old.STATUS_HAS_BEEN_WORK_APDT;
		l_form_rec_old.S2_TASK_PERSON_ACK_ID           := :old.S2_TASK_PERSON_ACK_ID;
		l_form_rec_old.S2_TASK_PERSON_ACK_DATE           := :old.S2_TASK_PERSON_ACK_DATE;
		l_form_rec_old.S2_TASK_PERSON_ACK_MODIFIED_BY           := :old.S2_TASK_PERSON_ACK_MODIFIED_BY;
		l_form_rec_old.EMAIL_CHK           := :old.EMAIL_CHK;

	end if;
/*
  -- Initializing each time.
  :new.email_chk := 'N';

   -- Poonam - New changes as per Zoe's request
   begin
    select but_sid
    into l_but_sid
    from but
    where but_lid = lower(l_current_user)
    and rownum = 1;
   exception
       when no_data_found then
        apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_but_sid not found');
       when others then raise;
   end;

-- As per Sean, send emails always
    IF (nvl(:new.S2_ADSO_ID,l_but_sid) != l_but_sid) or
	(nvl(:new.S2_RAD_ID,l_but_sid) != l_but_sid) or
	(nvl(:new.S2_EOIC_ID,l_but_sid) != l_but_sid) or
	(nvl(:new.S2_TASK_PERSON_ACK_ID,l_but_sid) != l_but_sid) THEN
	  IF (RSW_PKG.rsw_email_rules (l_form_rec_new, l_form_rec_old)) THEN
	     :new.email_chk := 'Y';
	  ELSE
	     :new.email_chk := 'N';
	  END IF;

    END IF;

       --
       -- section 1 changes
       --
       if (nvl(:new.s1_area_mgr_id,0) != nvl(:old.s1_area_mgr_id,0))
       then
         :new.s1_area_mgr_date        := sysdate;
         :new.s1_area_mgr_modified_by := l_current_user;
       end if;


       --
       -- section 2 changes
       --
	IF :new.S2_TASK_PERSON_ACK_ID is not null then
	  IF :new.S2_TASK_PERSON_ACK_ID != :new.S1_TASK_PERSON_ID THEN
	     :new.S2_TASK_PERSON_ACK_ID := NULL;
	  END IF;
	END IF;

-- Poonam - 7/11/2014 - Added the New fields logic
       if (nvl(:new.S2_TASK_PERSON_ACK_ID,0) != nvl(:old.S2_TASK_PERSON_ACK_ID,0))
       then
         :new.S2_TASK_PERSON_ACK_DATE        := sysdate;
	 :new.S2_TASK_PERSON_ACK_MODIFIED_BY := l_current_user;
       end if;

       if (nvl(:new.s2_descr,'NULL') != nvl(:old.s2_descr,'NULL'))
--       or (:new.s2_descr is not null and :old.s2_descr is null)
       then
         :new.s2_descr_date        := sysdate;
         :new.s2_descr_modified_by := l_current_user;
       end if;

       if (nvl(:new.s2_adso_id,0) != nvl(:old.s2_adso_id,0))
--       or (:new.s2_adso_id is not null and :old.s2_adso_id is null)
       then
         :new.s2_adso_date        := sysdate;
         :new.s2_adso_modified_by := l_current_user;
       end if;

       if (nvl(:new.s2_rad_id,0) != nvl(:old.s2_rad_id,0))
--       or (:new.s2_rad_id is not null and :old.s2_rad_id is null)
       then
         :new.s2_rad_date        := sysdate;
         :new.s2_rad_modified_by := l_current_user;
       end if;

       if (nvl(:new.s2_eoic_id,0) != nvl(:old.s2_eoic_id,0))
--       or (:new.s2_eoic_id is not null and :old.s2_eoic_id is null)
       then
         :new.s2_eoic_date        := sysdate;
         :new.s2_eoic_modified_by := l_current_user;
       end if;

  -- Poonam - New changes as per Zoe's request
  -- Poonam - 12/8/2014 - Added the extra OR and AND conditions below the OR
  -- Original - if :new.email_chk = 'Y' and :new.form_status_id = 1 then

         if :new.email_chk = 'Y' and
	    (:new.form_status_id = 1 OR
	      (:old.form_status_id = 1 and
	       :new.form_status_id != :old.form_status_id))
         then
	   if (:new.S2_ADSO_ID is NOT NULL) and
	      (:new.S2_ADSO_ID != l_but_sid) then
	      :new.S2_ADSO_ID := NULL;
	      :new.s2_adso_date        := sysdate;
              :new.s2_adso_modified_by := l_current_user;
	   end if;
	   --
	   if (:new.S2_RAD_ID is NOT NULL) and
	      (:new.S2_RAD_ID != l_but_sid) then
	      :new.S2_RAD_ID := NULL;
              :new.s2_rad_date        := sysdate;
              :new.s2_rad_modified_by := l_current_user;
	   end if;
	   --
	   if (:new.S2_EOIC_ID is NOT NULL) and
	      (:new.S2_EOIC_ID != l_but_sid)then
	    :new.S2_EOIC_ID := NULL;
            :new.s2_eoic_date        := sysdate;
            :new.s2_eoic_modified_by := l_current_user;
	   end if;
	   --
	   if (:new.S2_TASK_PERSON_ACK_ID is NOT NULL) and
	      (:new.S2_TASK_PERSON_ACK_ID != l_but_sid) then
	    :new.S2_TASK_PERSON_ACK_ID := NULL;
            :new.S2_TASK_PERSON_ACK_DATE        := sysdate;
	    :new.S2_TASK_PERSON_ACK_MODIFIED_BY := l_current_user;
	   end if;
         end if;

-- Poonam - 10/27
    if :new.S2_ADSO_ID is null or
       :new.S2_RAD_ID is null  then
       if :new.S2_TASK_PERSON_ACK_ID is not null then
            :new.S2_TASK_PERSON_ACK_ID := NULL;
            :new.S2_TASK_PERSON_ACK_DATE        := sysdate;
	    :new.S2_TASK_PERSON_ACK_MODIFIED_BY := l_current_user;
       end if;
    end if;

       --
       -- section 3 changes
       --

       if (nvl(:new.s3_adso_wrk_rqmts_adso,'x') != nvl(:old.s3_adso_wrk_rqmts_adso,'x'))
       then
           :new.s3_adso_wrk_rqmts_adso_date := sysdate;
           :new.s3_adso_wrk_rqmts_adso_name := l_current_user;
       end if;

       if (nvl(:new.s3_adso_wrk_rqmts_wrkr,'x') != nvl(:old.s3_adso_wrk_rqmts_wrkr,'x'))
       then
         :new.s3_adso_wrk_rqmts_wrkr_date := sysdate;
         :new.s3_adso_wrk_rqmts_wrkr_name := l_current_user;
       end if;

       if (nvl(:new.s3_adso_wrk_rqmts_adso_apid,0) != nvl(:old.s3_adso_wrk_rqmts_adso_apid,0))
       then
         :new.s3_adso_wrk_rqmts_adso_apdt := sysdate;
         --:new.s3_adso_wrk_rqmts_adso_apnm := util.get_name_for_sid(:new.s3_adso_wrk_rqmts_adso_apid);
         :new.s3_adso_wrk_rqmts_adso_apnm := l_current_user;
       end if;

       if  (:new.s3_adso_wrk_rqmts_adso_date is not null and
            :new.s3_adso_wrk_rqmts_wrkr_date is not null and
	    :new.s3_adso_wrk_rqmts_adso_apid is not null)
       and ((:new.s3_adso_wrk_rqmts_adso_date > :new.s3_adso_wrk_rqmts_wrkr_date) or
            (:new.s3_adso_wrk_rqmts_wrkr_date > :new.s3_adso_wrk_rqmts_adso_apdt))
       then
         :new.s3_adso_wrk_rqmts_adso_apid := null;
         :new.s3_adso_wrk_rqmts_adso_apnm := null;
         :new.form_status_id              := 2;
       end if;


       if (nvl(:new.s3_rem_or_byp_adso,'x') != nvl(:old.s3_rem_or_byp_adso,'x'))
       then
         :new.s3_rem_or_byp_adso_date := sysdate;
         :new.s3_rem_or_byp_adso_name := l_current_user;
       end if;

       if (nvl(:new.s3_rem_or_byp_wrkr,'x') != nvl(:old.s3_rem_or_byp_wrkr,'x'))
       or (:new.s3_rem_or_byp_wrkr is not null and :old.s3_rem_or_byp_wrkr is null)
       then
         :new.s3_rem_or_byp_wrkr_date := sysdate;
         :new.s3_rem_or_byp_wrkr_name := l_current_user;
       end if;

       if (nvl(:new.s3_rem_or_byp_adso_apid,0) != nvl(:old.s3_rem_or_byp_adso_apid,0))
       then
         :new.s3_rem_or_byp_adso_apdt := sysdate;
         :new.s3_rem_or_byp_adso_apnm := l_current_user;
       end if;

       if  (:new.s3_rem_or_byp_adso_date is not null and
            :new.s3_rem_or_byp_wrkr_date is not null and
	    :new.s3_rem_or_byp_adso_apid is not null)
       and ((:new.s3_rem_or_byp_adso_date > :new.s3_rem_or_byp_wrkr_date) or
            (:new.s3_rem_or_byp_wrkr_date > :new.s3_rem_or_byp_adso_apdt))
       then
         :new.s3_rem_or_byp_adso_apid := null;
         :new.s3_rem_or_byp_adso_apnm := null;
         :new.form_status_id          := 2;
       end if;


       if (nvl(:new.s3_rein_or_unbyp_adso,'x') != nvl(:old.s3_rein_or_unbyp_adso,'x'))
       then
         :new.s3_rein_or_unbyp_adso_date := sysdate;
         :new.s3_rein_or_unbyp_adso_name := l_current_user;
      end if;

       if (nvl(:new.s3_rein_or_unbyp_wrkr,'x') != nvl(:old.s3_rein_or_unbyp_wrkr,'x'))
       then
         :new.s3_rein_or_unbyp_wrkr_date := sysdate;
         :new.s3_rein_or_unbyp_wrkr_name := l_current_user;
       end if;

       if (nvl(:new.s3_rein_or_unbyp_adso_apid,0) != nvl(:old.s3_rein_or_unbyp_adso_apid,0))
       then
         :new.s3_rein_or_unbyp_adso_apdt := sysdate;
         :new.s3_rein_or_unbyp_adso_apnm := l_current_user;
       end if;

       if  (:new.s3_rein_or_unbyp_adso_date is not null and
            :new.s3_rein_or_unbyp_wrkr_date is not null and
	    :new.s3_rein_or_unbyp_adso_apid is not null)
       and ((:new.s3_rein_or_unbyp_adso_date > :new.s3_rein_or_unbyp_wrkr_date) or
            (:new.s3_rein_or_unbyp_wrkr_date > :new.s3_rein_or_unbyp_adso_apdt))
       then
         :new.s3_rein_or_unbyp_adso_apid := null;
         :new.s3_rein_or_unbyp_adso_apnm := null;
         :new.form_status_id             := 2;
       end if;


       if (nvl(:new.s3_wrk_comp_adso,'x') != nvl(:old.s3_wrk_comp_adso,'x'))
       then
         :new.s3_wrk_comp_adso_date := sysdate;
         :new.s3_wrk_comp_adso_name := l_current_user;
       end if;

       if (nvl(:new.s3_wrk_comp_wrkr,'x') != nvl(:old.s3_wrk_comp_wrkr,'x'))
       then
         :new.s3_wrk_comp_wrkr_date := sysdate;
         :new.s3_wrk_comp_wrkr_name := l_current_user;
       end if;

       if (nvl(:new.s3_wrk_comp_adso_apid,0) != nvl(:old.s3_wrk_comp_adso_apid,0))
       then
         :new.s3_wrk_comp_adso_apdt := sysdate;
         :new.s3_wrk_comp_adso_apnm := l_current_user;
       end if;

       if  (:new.s3_wrk_comp_adso_date is not null and
            :new.s3_wrk_comp_wrkr_date is not null and
	    :new.s3_wrk_comp_adso_apid is not null)
       and ((:new.s3_wrk_comp_adso_date > :new.s3_wrk_comp_wrkr_date) or
            (:new.s3_wrk_comp_wrkr_date > :new.s3_wrk_comp_adso_apdt))
       then
         :new.s3_wrk_comp_adso_apid := null;
         :new.s3_wrk_comp_adso_apnm := null;
         :new.form_status_id        := 2;
       end if;


       if (nvl(:new.s3_pps_adso,'x') != nvl(:old.s3_pps_adso,'x'))
       then
         :new.s3_pps_adso_date := sysdate;
         :new.s3_pps_adso_name := l_current_user;
       end if;

       if (nvl(:new.s3_pps_wrkr,'x') != nvl(:old.s3_pps_wrkr,'x'))
       then
         :new.s3_pps_wrkr_date := sysdate;
         :new.s3_pps_wrkr_name := l_current_user;
       end if;

       if (nvl(:new.s3_pps_adso_apid,0) != nvl(:old.s3_pps_adso_apid,0))
       then
         :new.s3_pps_adso_apdt := sysdate;
         :new.s3_pps_adso_apnm := l_current_user;
       end if;

       if  (:new.s3_pps_adso_date is not null and
            :new.s3_pps_wrkr_date is not null and
	    :new.s3_pps_adso_apid is not null)
       and ((:new.s3_pps_adso_date > :new.s3_pps_wrkr_date) or
            (:new.s3_pps_wrkr_date > :new.s3_pps_adso_apdt))
       then
         :new.s3_pps_adso_apid := null;
         :new.s3_pps_adso_apnm := null;
         :new.form_status_id   := 2;
       end if;


       if (nvl(:new.s3_rad_phys_adso,'x') != nvl(:old.s3_rad_phys_adso,'x'))
       then
         :new.s3_rad_phys_adso_date := sysdate;
         :new.s3_rad_phys_adso_name := l_current_user;
       end if;

       if (nvl(:new.s3_rad_phys_wrkr,'x') != nvl(:old.s3_rad_phys_wrkr,'x'))
       then
         :new.s3_rad_phys_wrkr_date := sysdate;
         :new.s3_rad_phys_wrkr_name := l_current_user;
       end if;

       if (nvl(:new.s3_rad_phys_adso_apid,0) != nvl(:old.s3_rad_phys_adso_apid,0))
       then
         :new.s3_rad_phys_adso_apdt := sysdate;
         :new.s3_rad_phys_adso_apnm := l_current_user;
       end if;

       if  (:new.s3_rad_phys_adso_date is not null and
            :new.s3_rad_phys_wrkr_date is not null and
	    :new.s3_rad_phys_adso_apid is not null)
       and ((:new.s3_rad_phys_adso_date > :new.s3_rad_phys_wrkr_date) or
            (:new.s3_rad_phys_wrkr_date > :new.s3_rad_phys_adso_apdt))
       then
         :new.s3_rad_phys_adso_apid := null;
         :new.s3_rad_phys_adso_apnm := null;
         :new.form_status_id        := 2;
       end if;


       if (nvl(:new.s3_bcs_adso,'x') != nvl(:old.s3_bcs_adso,'x'))
       then
         :new.s3_bcs_adso_date := sysdate;
         :new.s3_bcs_adso_name := l_current_user;
      end if;

       if (nvl(:new.s3_bcs_wrkr,'x') != nvl(:old.s3_bcs_wrkr,'x'))
       then
         :new.s3_bcs_wrkr_date := sysdate;
         :new.s3_bcs_wrkr_name := l_current_user;
       end if;

       if (nvl(:new.s3_bcs_adso_apid,0) != nvl(:old.s3_bcs_adso_apid,0))
       then
         :new.s3_bcs_adso_apdt := sysdate;
         :new.s3_bcs_adso_apnm := l_current_user;
       end if;

       if  (:new.s3_bcs_adso_date is not null and
            :new.s3_bcs_wrkr_date is not null and
	    :new.s3_bcs_adso_apid is not null)
       and ((:new.s3_bcs_adso_date > :new.s3_bcs_wrkr_date) or
            (:new.s3_bcs_wrkr_date > :new.s3_bcs_adso_apdt))
       then
         :new.s3_bcs_adso_apid := null;
         :new.s3_bcs_adso_apnm := null;
         :new.form_status_id   := 2;
       end if;


       if (nvl(:new.s3_rpfo_adso,'x') != nvl(:old.s3_rpfo_adso,'x'))
       then
         :new.s3_rpfo_adso_date := sysdate;
         :new.s3_rpfo_adso_name := l_current_user;
       end if;

       if (nvl(:new.s3_rpfo_wrkr,'x') != nvl(:old.s3_rpfo_wrkr,'x'))
       then
         :new.s3_rpfo_wrkr_date := sysdate;
         :new.s3_rpfo_wrkr_name := l_current_user;
       end if;

       if (nvl(:new.s3_rpfo_adso_apid,0) != nvl(:old.s3_rpfo_adso_apid,0))
       then
         :new.s3_rpfo_adso_apdt := sysdate;
         :new.s3_rpfo_adso_apnm := l_current_user;
       end if;

       if  (:new.s3_rpfo_adso_date is not null and
            :new.s3_rpfo_wrkr_date is not null and
	    :new.s3_rpfo_adso_apid is not null)
       and ((:new.s3_rpfo_adso_date > :new.s3_rpfo_wrkr_date) or
            (:new.s3_rpfo_wrkr_date > :new.s3_rpfo_adso_apdt))
       then
         :new.s3_rpfo_adso_apid := null;
         :new.s3_rpfo_adso_apnm := null;
         :new.form_status_id    := 2;
       end if;


       if (nvl(:new.s3_opns_adso,'x') != nvl(:old.s3_opns_adso,'x'))
       then
         :new.s3_opns_adso_date := sysdate;
         :new.s3_opns_adso_name := l_current_user;
       end if;

       if (nvl(:new.s3_opns_wrkr,'x') != nvl(:old.s3_opns_wrkr,'x'))
       then
         :new.s3_opns_wrkr_date := sysdate;
         :new.s3_opns_wrkr_name := l_current_user;
       end if;

       if (nvl(:new.s3_opns_adso_apid,0) != nvl(:old.s3_opns_adso_apid,0))
       then
         :new.s3_opns_adso_apdt := sysdate;
         :new.s3_opns_adso_apnm := l_current_user;
       end if;

       if  (:new.s3_opns_adso_date is not null and
            :new.s3_opns_wrkr_date is not null and
	    :new.s3_opns_adso_apid is not null)
       and ((:new.s3_opns_adso_date > :new.s3_opns_wrkr_date) or
            (:new.s3_opns_wrkr_date > :new.s3_opns_adso_apdt))
       then
         :new.s3_opns_adso_apid := null;
         :new.s3_opns_adso_apnm := null;
         :new.form_status_id    := 2;
       end if;


       if (nvl(:new.s3_bas_chg_adso,'x') != nvl(:old.s3_bas_chg_adso,'x'))
       then
         :new.s3_bas_chg_adso_date := sysdate;
         :new.s3_bas_chg_adso_name := l_current_user;
      end if;

       if (nvl(:new.s3_bas_chg_wrkr,'x') != nvl(:old.s3_bas_chg_wrkr,'x'))
       then
         :new.s3_bas_chg_wrkr_date := sysdate;
         :new.s3_bas_chg_wrkr_name := l_current_user;
       end if;

       if (nvl(:new.s3_bas_chg_adso_apid,0) != nvl(:old.s3_bas_chg_adso_apid,0))
       then
         :new.s3_bas_chg_adso_apdt := sysdate;
         :new.s3_bas_chg_adso_apnm := l_current_user;
       end if;

       if  (:new.s3_bas_chg_adso_date is not null and
            :new.s3_bas_chg_wrkr_date is not null and
	    :new.s3_bas_chg_adso_apid is not null)
       and ((:new.s3_bas_chg_adso_date > :new.s3_bas_chg_wrkr_date) or
            (:new.s3_bas_chg_wrkr_date > :new.s3_bas_chg_adso_apdt))
       then
         :new.s3_bas_chg_adso_apid := null;
         :new.s3_bas_chg_adso_apnm := null;
         :new.form_status_id       := 2;
       end if;


       if (nvl(:new.s3_other_adso,'x') != nvl(:old.s3_other_adso,'x'))
       then
         :new.s3_other_adso_date := sysdate;
         :new.s3_other_adso_name := l_current_user;
       end if;

       if (nvl(:new.s3_other_wrkr,'x') != nvl(:old.s3_other_wrkr,'x'))
       then
         :new.s3_other_wrkr_date := sysdate;
         :new.s3_other_wrkr_name := l_current_user;
       end if;

       if (nvl(:new.s3_other_adso_apid,0) != nvl(:old.s3_other_adso_apid,0))
       then
         :new.s3_other_adso_apdt := sysdate;
         :new.s3_other_adso_apnm := l_current_user;
       end if;

       if  (:new.s3_other_adso_date is not null and
            :new.s3_other_wrkr_date is not null and
	    :new.s3_other_adso_apid is not null)
       and ((:new.s3_other_adso_date > :new.s3_other_wrkr_date) or
            (:new.s3_other_wrkr_date > :new.s3_other_adso_apdt))
       then
         :new.s3_other_adso_apid := null;
         :new.s3_other_adso_apnm := null;
         :new.form_status_id     := 2;
       end if;


       if (nvl(:new.s3_other1_adso,'x') != nvl(:old.s3_other1_adso,'x'))
       then
         :new.s3_other1_adso_date := sysdate;
         :new.s3_other1_adso_name := l_current_user;
       end if;

       if (nvl(:new.s3_other1_wrkr,'x') != nvl(:old.s3_other1_wrkr,'x'))
       then
         :new.s3_other1_wrkr_date := sysdate;
         :new.s3_other1_wrkr_name := l_current_user;
       end if;

       if (nvl(:new.s3_other1_adso_apid,0) != nvl(:old.s3_other1_adso_apid,0))
       then
         :new.s3_other1_adso_apdt := sysdate;
         :new.s3_other1_adso_apnm := l_current_user;
       end if;

       if  (:new.s3_other1_adso_date is not null and
            :new.s3_other1_wrkr_date is not null and
	    :new.s3_other1_adso_apid is not null)
       and ((:new.s3_other1_adso_date > :new.s3_other1_wrkr_date) or
            (:new.s3_other1_wrkr_date > :new.s3_other1_adso_apdt))
       then
         :new.s3_other1_adso_apid := null;
         :new.s3_other1_adso_apnm := null;
         :new.form_status_id      := 2;
       end if;


       if (nvl(:new.s3_other2_adso,'x') != nvl(:old.s3_other2_adso,'x'))
       then
         :new.s3_other2_adso_date := sysdate;
         :new.s3_other2_adso_name := l_current_user;
       end if;

       if (nvl(:new.s3_other2_wrkr,'x') != nvl(:old.s3_other2_wrkr,'x'))
       then
         :new.s3_other2_wrkr_date := sysdate;
         :new.s3_other2_wrkr_name := l_current_user;
       end if;

       if (nvl(:new.s3_other2_adso_apid,0) != nvl(:old.s3_other2_adso_apid,0))
       then
         :new.s3_other2_adso_apdt := sysdate;
         :new.s3_other2_adso_apnm := l_current_user;
       end if;

       if  (:new.s3_other2_adso_date is not null and
            :new.s3_other2_wrkr_date is not null and
	    :new.s3_other2_adso_apid is not null)
       and ((:new.s3_other2_adso_date > :new.s3_other2_wrkr_date) or
            (:new.s3_other2_wrkr_date > :new.s3_other2_adso_apdt))
       then
         :new.s3_other2_adso_apid := null;
         :new.s3_other2_adso_apnm := null;
         :new.form_status_id      := 2;
       end if;

       --
       -- section 4 changes
       --

       if (nvl(:new.s4_adso_id,0) != nvl(:old.s4_adso_id,0))
--       or (:new.s4_adso_id is not null and :old.s4_adso_id is null)
       then
         :new.s4_adso_date        := sysdate;
         :new.s4_adso_modified_by := l_current_user;
       end if;

       if (nvl(:new.s4_eoic_id,0) != nvl(:old.s4_eoic_id,0))
--       or (:new.s4_eoic_id is not null and :old.s4_eoic_id is null)
       then
         :new.s4_eoic_date        := sysdate;
         :new.s4_eoic_modified_by := l_current_user;
       end if;

--Poonam - 12/10/2014 - added for the bug where these values become null
--     but the Form status changes to Work Approved.
   if :new.form_status_id != 7
   then
     if :new.form_status_id != 1 and
        (:new.S2_TASK_PERSON_ACK_ID is null or
         :new.S2_RAD_ID is null or
         :new.S2_ADSO_ID is null or
         :new.S2_EOIC_ID is null)
     then
      :new.form_status_id := 1;
     end if;
   end if;
----------------------------------------------------------------------
        if :new.form_status_id = 2
        then
          :new.status_has_been_work_approved := 1;
          :new.status_has_been_work_apdt     := sysdate;
        end if;
*/
       if inserting or updating
       then

           insert into rsw_form_jn
           (jn_operation
           ,jn_oracle_user
           ,jn_datetime
           ,jn_notes
           ,jn_appln
           ,jn_session
           ,form_id
           ,prob_id
           ,job_id
           ,trans_id
           ,s1_descr
           ,s1_work
           ,s1_task_person_id
           ,s1_task_person_date
           ,s1_area_id
           ,s1_area_mgr_id
           ,s1_area_mgr_date
           ,s1_area_mgr_modified_by
           ,s1_pps_zone_id
           ,s1_group_id
           ,s2_reqmts_needed
           ,s2_descr
           ,s2_descr_date
           ,s2_descr_modified_by
           ,s2_reqs
           ,s2_adso_id
           ,s2_adso_date
           ,s2_adso_modified_by
           ,s2_rad_id
           ,s2_rad_date
           ,s2_rad_modified_by
           ,s2_eoic_id
           ,s2_eoic_date
           ,s2_eoic_modified_by
           ,s3_adso_work_reqsel
           ,s3_adso_wrk_rqmts_adso
           ,s3_adso_wrk_rqmts_adso_date
           ,s3_adso_wrk_rqmts_adso_name
           ,s3_adso_wrk_rqmts_wrkr
           ,s3_adso_wrk_rqmts_wrkr_date
           ,s3_adso_wrk_rqmts_wrkr_name
           ,s3_adso_wrk_rqmts_adso_apid
           ,s3_adso_wrk_rqmts_adso_apdt
           ,s3_adso_wrk_rqmts_adso_apnm
           ,s3_rem_or_byp_adso
           ,s3_rem_or_byp_adso_date
           ,s3_rem_or_byp_adso_name
           ,s3_rem_or_byp_wrkr
           ,s3_rem_or_byp_wrkr_date
           ,s3_rem_or_byp_wrkr_name
           ,s3_rem_or_byp_adso_apid
           ,s3_rem_or_byp_adso_apdt
           ,s3_rem_or_byp_adso_apnm
           ,s3_rein_or_unbyp_adso
           ,s3_rein_or_unbyp_adso_date
           ,s3_rein_or_unbyp_adso_name
           ,s3_rein_or_unbyp_wrkr
           ,s3_rein_or_unbyp_wrkr_date
           ,s3_rein_or_unbyp_wrkr_name
           ,s3_rein_or_unbyp_adso_apid
           ,s3_rein_or_unbyp_adso_apdt
           ,s3_rein_or_unbyp_adso_apnm
           ,s3_wrk_comp_adso
           ,s3_wrk_comp_adso_date
           ,s3_wrk_comp_adso_name
           ,s3_wrk_comp_wrkr
           ,s3_wrk_comp_wrkr_date
           ,s3_wrk_comp_wrkr_name
           ,s3_wrk_comp_adso_apid
           ,s3_wrk_comp_adso_apdt
           ,s3_wrk_comp_adso_apnm
           ,s3_pps_adso
           ,s3_pps_adso_date
           ,s3_pps_adso_name
           ,s3_pps_wrkr
           ,s3_pps_wrkr_date
           ,s3_pps_wrkr_name
           ,s3_pps_adso_apid
           ,s3_pps_adso_apdt
           ,s3_pps_adso_apnm
           ,s3_rad_phys_adso
           ,s3_rad_phys_adso_date
           ,s3_rad_phys_adso_name
           ,s3_rad_phys_wrkr
           ,s3_rad_phys_wrkr_date
           ,s3_rad_phys_wrkr_name
           ,s3_rad_phys_adso_apid
           ,s3_rad_phys_adso_apdt
           ,s3_rad_phys_adso_apnm
           ,s3_bcs_adso
           ,s3_bcs_adso_date
           ,s3_bcs_adso_name
           ,s3_bcs_wrkr
           ,s3_bcs_wrkr_date
           ,s3_bcs_wrkr_name
           ,s3_bcs_adso_apid
           ,s3_bcs_adso_apdt
           ,s3_bcs_adso_apnm
           ,s3_rpfo_adso
           ,s3_rpfo_adso_date
           ,s3_rpfo_adso_name
           ,s3_rpfo_wrkr
           ,s3_rpfo_wrkr_date
           ,s3_rpfo_wrkr_name
           ,s3_rpfo_adso_apid
           ,s3_rpfo_adso_apdt
           ,s3_rpfo_adso_apnm
           ,s3_opns_adso
           ,s3_opns_adso_date
           ,s3_opns_adso_name
           ,s3_opns_wrkr
           ,s3_opns_wrkr_date
           ,s3_opns_wrkr_name
           ,s3_opns_adso_apid
           ,s3_opns_adso_apdt
           ,s3_opns_adso_apnm
           ,s3_bas_chg_adso
           ,s3_bas_chg_adso_date
           ,s3_bas_chg_adso_name
           ,s3_bas_chg_wrkr
           ,s3_bas_chg_wrkr_date
           ,s3_bas_chg_wrkr_name
           ,s3_bas_chg_adso_apid
           ,s3_bas_chg_adso_apdt
           ,s3_bas_chg_adso_apnm
           ,s3_other_adso
           ,s3_other_adso_date
           ,s3_other_adso_name
           ,s3_other_wrkr
           ,s3_other_wrkr_date
           ,s3_other_wrkr_name
           ,s3_other_adso_apid
           ,s3_other_adso_apdt
           ,s3_other_adso_apnm
           ,s3_other1_adso
           ,s3_other1_adso_date
           ,s3_other1_adso_name
           ,s3_other1_wrkr
           ,s3_other1_wrkr_date
           ,s3_other1_wrkr_name
           ,s3_other1_adso_apid
           ,s3_other1_adso_apdt
           ,s3_other1_adso_apnm
           ,s3_other2_adso
           ,s3_other2_adso_date
           ,s3_other2_adso_name
           ,s3_other2_wrkr
           ,s3_other2_wrkr_date
           ,s3_other2_wrkr_name
           ,s3_other2_adso_apid
           ,s3_other2_adso_apdt
           ,s3_other2_adso_apnm
           ,s4_adso_id
           ,s4_adso_date
           ,s4_adso_modified_by
           ,s4_eoic_id
           ,s4_eoic_date
           ,s4_eoic_modified_by
           ,s4_ready_for_beam_reqmts
           ,s4_close
           ,file_id
           ,form_status_id
           ,reset_work_complete
           ,status_has_been_work_approved
           ,status_has_been_work_apdt
           ,created_by
           ,created_date
           ,modified_by
           ,modified_date
	   ,S2_TASK_PERSON_ACK_ID
	   ,S2_TASK_PERSON_ACK_DATE
	   ,S2_TASK_PERSON_ACK_MODIFIED_BY
	   ,EMAIL_CHK
           )
           values
           (jn_operation
           ,l_current_user
           ,sysdate
           ,'Data was updated by disabling triggers, as status changed from Closed to Work not approved due to trigger rules'
           ,null
           ,userenv('sessionid')
           ,:new.form_id
           ,:new.prob_id
           ,:new.job_id
           ,:new.trans_id
           ,:new.s1_descr
           ,:new.s1_work
           ,:new.s1_task_person_id
           ,:new.s1_task_person_date
           ,:new.s1_area_id
           ,:new.s1_area_mgr_id
           ,:new.s1_area_mgr_date
           ,:new.s1_area_mgr_modified_by
           ,:new.s1_pps_zone_id
           ,:new.s1_group_id
           ,:new.s2_reqmts_needed
           ,:new.s2_descr
           ,:new.s2_descr_date
           ,:new.s2_descr_modified_by
           ,:new.s2_reqs
           ,:new.s2_adso_id
           ,:new.s2_adso_date
           ,:new.s2_adso_modified_by
           ,:new.s2_rad_id
           ,:new.s2_rad_date
           ,:new.s2_rad_modified_by
           ,:new.s2_eoic_id
           ,:new.s2_eoic_date
           ,:new.s2_eoic_modified_by
           ,:new.s3_adso_work_reqsel
           ,:new.s3_adso_wrk_rqmts_adso
           ,:new.s3_adso_wrk_rqmts_adso_date
           ,:new.s3_adso_wrk_rqmts_adso_name
           ,:new.s3_adso_wrk_rqmts_wrkr
           ,:new.s3_adso_wrk_rqmts_wrkr_date
           ,:new.s3_adso_wrk_rqmts_wrkr_name
           ,:new.s3_adso_wrk_rqmts_adso_apid
           ,:new.s3_adso_wrk_rqmts_adso_apdt
           ,:new.s3_adso_wrk_rqmts_adso_apnm
           ,:new.s3_rem_or_byp_adso
           ,:new.s3_rem_or_byp_adso_date
           ,:new.s3_rem_or_byp_adso_name
           ,:new.s3_rem_or_byp_wrkr
           ,:new.s3_rem_or_byp_wrkr_date
           ,:new.s3_rem_or_byp_wrkr_name
           ,:new.s3_rem_or_byp_adso_apid
           ,:new.s3_rem_or_byp_adso_apdt
           ,:new.s3_rem_or_byp_adso_apnm
           ,:new.s3_rein_or_unbyp_adso
           ,:new.s3_rein_or_unbyp_adso_date
           ,:new.s3_rein_or_unbyp_adso_name
           ,:new.s3_rein_or_unbyp_wrkr
           ,:new.s3_rein_or_unbyp_wrkr_date
           ,:new.s3_rein_or_unbyp_wrkr_name
           ,:new.s3_rein_or_unbyp_adso_apid
           ,:new.s3_rein_or_unbyp_adso_apdt
           ,:new.s3_rein_or_unbyp_adso_apnm
           ,:new.s3_wrk_comp_adso
           ,:new.s3_wrk_comp_adso_date
           ,:new.s3_wrk_comp_adso_name
           ,:new.s3_wrk_comp_wrkr
           ,:new.s3_wrk_comp_wrkr_date
           ,:new.s3_wrk_comp_wrkr_name
           ,:new.s3_wrk_comp_adso_apid
           ,:new.s3_wrk_comp_adso_apdt
           ,:new.s3_wrk_comp_adso_apnm
           ,:new.s3_pps_adso
           ,:new.s3_pps_adso_date
           ,:new.s3_pps_adso_name
           ,:new.s3_pps_wrkr
           ,:new.s3_pps_wrkr_date
           ,:new.s3_pps_wrkr_name
           ,:new.s3_pps_adso_apid
           ,:new.s3_pps_adso_apdt
           ,:new.s3_pps_adso_apnm
           ,:new.s3_rad_phys_adso
           ,:new.s3_rad_phys_adso_date
           ,:new.s3_rad_phys_adso_name
           ,:new.s3_rad_phys_wrkr
           ,:new.s3_rad_phys_wrkr_date
           ,:new.s3_rad_phys_wrkr_name
           ,:new.s3_rad_phys_adso_apid
           ,:new.s3_rad_phys_adso_apdt
           ,:new.s3_rad_phys_adso_apnm
           ,:new.s3_bcs_adso
           ,:new.s3_bcs_adso_date
           ,:new.s3_bcs_adso_name
           ,:new.s3_bcs_wrkr
           ,:new.s3_bcs_wrkr_date
           ,:new.s3_bcs_wrkr_name
           ,:new.s3_bcs_adso_apid
           ,:new.s3_bcs_adso_apdt
           ,:new.s3_bcs_adso_apnm
           ,:new.s3_rpfo_adso
           ,:new.s3_rpfo_adso_date
           ,:new.s3_rpfo_adso_name
           ,:new.s3_rpfo_wrkr
           ,:new.s3_rpfo_wrkr_date
           ,:new.s3_rpfo_wrkr_name
           ,:new.s3_rpfo_adso_apid
           ,:new.s3_rpfo_adso_apdt
           ,:new.s3_rpfo_adso_apnm
           ,:new.s3_opns_adso
           ,:new.s3_opns_adso_date
           ,:new.s3_opns_adso_name
           ,:new.s3_opns_wrkr
           ,:new.s3_opns_wrkr_date
           ,:new.s3_opns_wrkr_name
           ,:new.s3_opns_adso_apid
           ,:new.s3_opns_adso_apdt
           ,:new.s3_opns_adso_apnm
           ,:new.s3_bas_chg_adso
           ,:new.s3_bas_chg_adso_date
           ,:new.s3_bas_chg_adso_name
           ,:new.s3_bas_chg_wrkr
           ,:new.s3_bas_chg_wrkr_date
           ,:new.s3_bas_chg_wrkr_name
           ,:new.s3_bas_chg_adso_apid
           ,:new.s3_bas_chg_adso_apdt
           ,:new.s3_bas_chg_adso_apnm
           ,:new.s3_other_adso
           ,:new.s3_other_adso_date
           ,:new.s3_other_adso_name
           ,:new.s3_other_wrkr
           ,:new.s3_other_wrkr_date
           ,:new.s3_other_wrkr_name
           ,:new.s3_other_adso_apid
           ,:new.s3_other_adso_apdt
           ,:new.s3_other_adso_apnm
           ,:new.s3_other1_adso
           ,:new.s3_other1_adso_date
           ,:new.s3_other1_adso_name
           ,:new.s3_other1_wrkr
           ,:new.s3_other1_wrkr_date
           ,:new.s3_other1_wrkr_name
           ,:new.s3_other1_adso_apid
           ,:new.s3_other1_adso_apdt
           ,:new.s3_other1_adso_apnm
           ,:new.s3_other2_adso
           ,:new.s3_other2_adso_date
           ,:new.s3_other2_adso_name
           ,:new.s3_other2_wrkr
           ,:new.s3_other2_wrkr_date
           ,:new.s3_other2_wrkr_name
           ,:new.s3_other2_adso_apid
           ,:new.s3_other2_adso_apdt
           ,:new.s3_other2_adso_apnm
           ,:new.s4_adso_id
           ,:new.s4_adso_date
           ,:new.s4_adso_modified_by
           ,:new.s4_eoic_id
           ,:new.s4_eoic_date
           ,:new.s4_eoic_modified_by
           ,:new.s4_ready_for_beam_reqmts
           ,:new.s4_close
           ,:new.file_id
           ,:new.form_status_id
           ,:new.reset_work_complete
           ,:new.status_has_been_work_approved
           ,:new.status_has_been_work_apdt
           ,:new.created_by
           ,:new.created_date
           ,:new.modified_by
           ,:new.modified_date
	   ,:new.S2_TASK_PERSON_ACK_ID
	   ,:new.S2_TASK_PERSON_ACK_DATE
	   ,:new.S2_TASK_PERSON_ACK_MODIFIED_BY
	   ,:new.EMAIL_CHK
           );

       elsif deleting then

           insert into rsw_form_jn
           (jn_operation
           ,jn_oracle_user
           ,jn_datetime
           ,jn_notes
           ,jn_appln
           ,jn_session
           ,form_id
           ,prob_id
           ,job_id
           ,trans_id
           ,s1_descr
           ,s1_work
           ,s1_task_person_id
           ,s1_task_person_date
           ,s1_area_id
           ,s1_area_mgr_id
           ,s1_area_mgr_date
           ,s1_area_mgr_modified_by
           ,s1_pps_zone_id
           ,s1_group_id
           ,s2_reqmts_needed
           ,s2_descr
           ,s2_descr_date
           ,s2_descr_modified_by
           ,s2_reqs
           ,s2_adso_id
           ,s2_adso_date
           ,s2_adso_modified_by
           ,s2_rad_id
           ,s2_rad_date
           ,s2_rad_modified_by
           ,s2_eoic_id
           ,s2_eoic_date
           ,s2_eoic_modified_by
           ,s3_adso_work_reqsel
           ,s3_adso_wrk_rqmts_adso
           ,s3_adso_wrk_rqmts_adso_date
           ,s3_adso_wrk_rqmts_adso_name
           ,s3_adso_wrk_rqmts_wrkr
           ,s3_adso_wrk_rqmts_wrkr_date
           ,s3_adso_wrk_rqmts_wrkr_name
           ,s3_adso_wrk_rqmts_adso_apid
           ,s3_adso_wrk_rqmts_adso_apdt
           ,s3_adso_wrk_rqmts_adso_apnm
           ,s3_rem_or_byp_adso
           ,s3_rem_or_byp_adso_date
           ,s3_rem_or_byp_adso_name
           ,s3_rem_or_byp_wrkr
           ,s3_rem_or_byp_wrkr_date
           ,s3_rem_or_byp_wrkr_name
           ,s3_rem_or_byp_adso_apid
           ,s3_rem_or_byp_adso_apdt
           ,s3_rem_or_byp_adso_apnm
           ,s3_rein_or_unbyp_adso
           ,s3_rein_or_unbyp_adso_date
           ,s3_rein_or_unbyp_adso_name
           ,s3_rein_or_unbyp_wrkr
           ,s3_rein_or_unbyp_wrkr_date
           ,s3_rein_or_unbyp_wrkr_name
           ,s3_rein_or_unbyp_adso_apid
           ,s3_rein_or_unbyp_adso_apdt
           ,s3_rein_or_unbyp_adso_apnm
           ,s3_wrk_comp_adso
           ,s3_wrk_comp_adso_date
           ,s3_wrk_comp_adso_name
           ,s3_wrk_comp_wrkr
           ,s3_wrk_comp_wrkr_date
           ,s3_wrk_comp_wrkr_name
           ,s3_wrk_comp_adso_apid
           ,s3_wrk_comp_adso_apdt
           ,s3_wrk_comp_adso_apnm
           ,s3_pps_adso
           ,s3_pps_adso_date
           ,s3_pps_adso_name
           ,s3_pps_wrkr
           ,s3_pps_wrkr_date
           ,s3_pps_wrkr_name
           ,s3_pps_adso_apid
           ,s3_pps_adso_apdt
           ,s3_pps_adso_apnm
           ,s3_rad_phys_adso
           ,s3_rad_phys_adso_date
           ,s3_rad_phys_adso_name
           ,s3_rad_phys_wrkr
           ,s3_rad_phys_wrkr_date
           ,s3_rad_phys_wrkr_name
           ,s3_rad_phys_adso_apid
           ,s3_rad_phys_adso_apdt
           ,s3_rad_phys_adso_apnm
           ,s3_bcs_adso
           ,s3_bcs_adso_date
           ,s3_bcs_adso_name
           ,s3_bcs_wrkr
           ,s3_bcs_wrkr_date
           ,s3_bcs_wrkr_name
           ,s3_bcs_adso_apid
           ,s3_bcs_adso_apdt
           ,s3_bcs_adso_apnm
           ,s3_rpfo_adso
           ,s3_rpfo_adso_date
           ,s3_rpfo_adso_name
           ,s3_rpfo_wrkr
           ,s3_rpfo_wrkr_date
           ,s3_rpfo_wrkr_name
           ,s3_rpfo_adso_apid
           ,s3_rpfo_adso_apdt
           ,s3_rpfo_adso_apnm
           ,s3_opns_adso
           ,s3_opns_adso_date
           ,s3_opns_adso_name
           ,s3_opns_wrkr
           ,s3_opns_wrkr_date
           ,s3_opns_wrkr_name
           ,s3_opns_adso_apid
           ,s3_opns_adso_apdt
           ,s3_opns_adso_apnm
           ,s3_bas_chg_adso
           ,s3_bas_chg_adso_date
           ,s3_bas_chg_adso_name
           ,s3_bas_chg_wrkr
           ,s3_bas_chg_wrkr_date
           ,s3_bas_chg_wrkr_name
           ,s3_bas_chg_adso_apid
           ,s3_bas_chg_adso_apdt
           ,s3_bas_chg_adso_apnm
           ,s3_other_adso
           ,s3_other_adso_date
           ,s3_other_adso_name
           ,s3_other_wrkr
           ,s3_other_wrkr_date
           ,s3_other_wrkr_name
           ,s3_other_adso_apid
           ,s3_other_adso_apdt
           ,s3_other_adso_apnm
           ,s3_other1_adso
           ,s3_other1_adso_date
           ,s3_other1_adso_name
           ,s3_other1_wrkr
           ,s3_other1_wrkr_date
           ,s3_other1_wrkr_name
           ,s3_other1_adso_apid
           ,s3_other1_adso_apdt
           ,s3_other1_adso_apnm
           ,s3_other2_adso
           ,s3_other2_adso_date
           ,s3_other2_adso_name
           ,s3_other2_wrkr
           ,s3_other2_wrkr_date
           ,s3_other2_wrkr_name
           ,s3_other2_adso_apid
           ,s3_other2_adso_apdt
           ,s3_other2_adso_apnm
           ,s4_adso_id
           ,s4_adso_date
           ,s4_adso_modified_by
           ,s4_eoic_id
           ,s4_eoic_date
           ,s4_eoic_modified_by
           ,s4_ready_for_beam_reqmts
           ,s4_close
           ,file_id
           ,form_status_id
           ,reset_work_complete
           ,status_has_been_work_approved
           ,status_has_been_work_apdt
           ,created_by
           ,created_date
           ,modified_by
           ,modified_date
	   ,S2_TASK_PERSON_ACK_ID
	   ,S2_TASK_PERSON_ACK_DATE
	   ,S2_TASK_PERSON_ACK_MODIFIED_BY
	   ,EMAIL_CHK
           )
           values
           (jn_operation
           ,l_current_user
           ,sysdate
           ,null
           ,null
           ,userenv('sessionid')
           ,:old.form_id
           ,:old.prob_id
           ,:old.job_id
           ,:old.trans_id
           ,:old.s1_descr
           ,:old.s1_work
           ,:old.s1_task_person_id
           ,:old.s1_task_person_date
           ,:old.s1_area_id
           ,:old.s1_area_mgr_id
           ,:old.s1_area_mgr_date
           ,:old.s1_area_mgr_modified_by
           ,:old.s1_pps_zone_id
           ,:old.s1_group_id
           ,:old.s2_reqmts_needed
           ,:old.s2_descr
           ,:old.s2_descr_date
           ,:old.s2_descr_modified_by
           ,:old.s2_reqs
           ,:old.s2_adso_id
           ,:old.s2_adso_date
           ,:old.s2_adso_modified_by
           ,:old.s2_rad_id
           ,:old.s2_rad_date
           ,:old.s2_rad_modified_by
           ,:old.s2_eoic_id
           ,:old.s2_eoic_date
           ,:old.s2_eoic_modified_by
           ,:old.s3_adso_work_reqsel
           ,:old.s3_adso_wrk_rqmts_adso
           ,:old.s3_adso_wrk_rqmts_adso_date
           ,:old.s3_adso_wrk_rqmts_adso_name
           ,:old.s3_adso_wrk_rqmts_wrkr
           ,:old.s3_adso_wrk_rqmts_wrkr_date
           ,:old.s3_adso_wrk_rqmts_wrkr_name
           ,:old.s3_adso_wrk_rqmts_adso_apid
           ,:old.s3_adso_wrk_rqmts_adso_apdt
           ,:old.s3_adso_wrk_rqmts_adso_apnm
           ,:old.s3_rem_or_byp_adso
           ,:old.s3_rem_or_byp_adso_date
           ,:old.s3_rem_or_byp_adso_name
           ,:old.s3_rem_or_byp_wrkr
           ,:old.s3_rem_or_byp_wrkr_date
           ,:old.s3_rem_or_byp_wrkr_name
           ,:old.s3_rem_or_byp_adso_apid
           ,:old.s3_rem_or_byp_adso_apdt
           ,:old.s3_rem_or_byp_adso_apnm
           ,:old.s3_rein_or_unbyp_adso
           ,:old.s3_rein_or_unbyp_adso_date
           ,:old.s3_rein_or_unbyp_adso_name
           ,:old.s3_rein_or_unbyp_wrkr
           ,:old.s3_rein_or_unbyp_wrkr_date
           ,:old.s3_rein_or_unbyp_wrkr_name
           ,:old.s3_rein_or_unbyp_adso_apid
           ,:old.s3_rein_or_unbyp_adso_apdt
           ,:old.s3_rein_or_unbyp_adso_apnm
           ,:old.s3_wrk_comp_adso
           ,:old.s3_wrk_comp_adso_date
           ,:old.s3_wrk_comp_adso_name
           ,:old.s3_wrk_comp_wrkr
           ,:old.s3_wrk_comp_wrkr_date
           ,:old.s3_wrk_comp_wrkr_name
           ,:old.s3_wrk_comp_adso_apid
           ,:old.s3_wrk_comp_adso_apdt
           ,:old.s3_wrk_comp_adso_apnm
           ,:old.s3_pps_adso
           ,:old.s3_pps_adso_date
           ,:old.s3_pps_adso_name
           ,:old.s3_pps_wrkr
           ,:old.s3_pps_wrkr_date
           ,:old.s3_pps_wrkr_name
           ,:old.s3_pps_adso_apid
           ,:old.s3_pps_adso_apdt
           ,:old.s3_pps_adso_apnm
           ,:old.s3_rad_phys_adso
           ,:old.s3_rad_phys_adso_date
           ,:old.s3_rad_phys_adso_name
           ,:old.s3_rad_phys_wrkr
           ,:old.s3_rad_phys_wrkr_date
           ,:old.s3_rad_phys_wrkr_name
           ,:old.s3_rad_phys_adso_apid
           ,:old.s3_rad_phys_adso_apdt
           ,:old.s3_rad_phys_adso_apnm
           ,:old.s3_bcs_adso
           ,:old.s3_bcs_adso_date
           ,:old.s3_bcs_adso_name
           ,:old.s3_bcs_wrkr
           ,:old.s3_bcs_wrkr_date
           ,:old.s3_bcs_wrkr_name
           ,:old.s3_bcs_adso_apid
           ,:old.s3_bcs_adso_apdt
           ,:old.s3_bcs_adso_apnm
           ,:old.s3_rpfo_adso
           ,:old.s3_rpfo_adso_date
           ,:old.s3_rpfo_adso_name
           ,:old.s3_rpfo_wrkr
           ,:old.s3_rpfo_wrkr_date
           ,:old.s3_rpfo_wrkr_name
           ,:old.s3_rpfo_adso_apid
           ,:old.s3_rpfo_adso_apdt
           ,:old.s3_rpfo_adso_apnm
           ,:old.s3_opns_adso
           ,:old.s3_opns_adso_date
           ,:old.s3_opns_adso_name
           ,:old.s3_opns_wrkr
           ,:old.s3_opns_wrkr_date
           ,:old.s3_opns_wrkr_name
           ,:old.s3_opns_adso_apid
           ,:old.s3_opns_adso_apdt
           ,:old.s3_opns_adso_apnm
           ,:old.s3_bas_chg_adso
           ,:old.s3_bas_chg_adso_date
           ,:old.s3_bas_chg_adso_name
           ,:old.s3_bas_chg_wrkr
           ,:old.s3_bas_chg_wrkr_date
           ,:old.s3_bas_chg_wrkr_name
           ,:old.s3_bas_chg_adso_apid
           ,:old.s3_bas_chg_adso_apdt
           ,:old.s3_bas_chg_adso_apnm
           ,:old.s3_other_adso
           ,:old.s3_other_adso_date
           ,:old.s3_other_adso_name
           ,:old.s3_other_wrkr
           ,:old.s3_other_wrkr_date
           ,:old.s3_other_wrkr_name
           ,:old.s3_other_adso_apid
           ,:old.s3_other_adso_apdt
           ,:old.s3_other_adso_apnm
           ,:old.s3_other1_adso
           ,:old.s3_other1_adso_date
           ,:old.s3_other1_adso_name
           ,:old.s3_other1_wrkr
           ,:old.s3_other1_wrkr_date
           ,:old.s3_other1_wrkr_name
           ,:old.s3_other1_adso_apid
           ,:old.s3_other1_adso_apdt
           ,:old.s3_other1_adso_apnm
           ,:old.s3_other2_adso
           ,:old.s3_other2_adso_date
           ,:old.s3_other2_adso_name
           ,:old.s3_other2_wrkr
           ,:old.s3_other2_wrkr_date
           ,:old.s3_other2_wrkr_name
           ,:old.s3_other2_adso_apid
           ,:old.s3_other2_adso_apdt
           ,:old.s3_other2_adso_apnm
           ,:old.s4_adso_id
           ,:old.s4_adso_date
           ,:old.s4_adso_modified_by
           ,:old.s4_eoic_id
           ,:old.s4_eoic_date
           ,:old.s4_eoic_modified_by
           ,:old.s4_ready_for_beam_reqmts
           ,:old.s4_close
           ,:old.file_id
           ,:old.form_status_id
           ,:old.reset_work_complete
           ,:old.status_has_been_work_approved
           ,:old.status_has_been_work_apdt
           ,:old.created_by
           ,:old.created_date
           ,:old.modified_by
           ,:old.modified_date
	   ,:old.S2_TASK_PERSON_ACK_ID
	   ,:old.S2_TASK_PERSON_ACK_DATE
	   ,:old.S2_TASK_PERSON_ACK_MODIFIED_BY
	   ,:old.EMAIL_CHK
           );

       end if;

     end;
     /