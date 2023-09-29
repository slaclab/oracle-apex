create or replace TRIGGER ART_PROBLEMS_BIUDR_TRG
BEFORE INSERT OR UPDATE OR DELETE ON ART_PROBLEMS FOR EACH ROW
declare

    c_proc                       constant varchar2(30)  := 'ART_PROBLEMS_BIUDR_TRG';
    c_user                       constant varchar2(100) := nvl(v('APP_USER'),user);
    c_now                        constant date := sysdate;

    v_errmsg                     varchar2(300) := null;
    jn_operation                 varchar2(3);

begin

    if inserting
    then

        jn_operation := 'INS';

        if :new.prob_id is null
        then
            :new.prob_id := art_problems_seq.nextval;
        end if;

        if :new.created_by is null
        then
            :new.created_by := c_user;
        end if;

        if :new.created_date is null
        then
            :new.created_date := c_now;
        end if;

        :new.modified_by   := null;
        :new.modified_date := null;

    elsif updating
    then

        jn_operation := 'UPD';

        :new.modified_by   := c_user;
        :new.modified_date := c_now;

        if :old.date_closed is null and :new.closer_id is not null
        then
            :new.date_closed := c_now;
        end if;

    elsif deleting
    then

        jn_operation := 'DEL';
        null;

    end if;

    if inserting or updating
    then
        insert into art_problems_jn
        (jn_operation
        ,jn_oracle_user
        ,jn_datetime
        ,jn_notes
        ,jn_appln
        ,jn_session
        ,prob_id
        ,area_id
        ,shop_alt_id
        ,subsystem_id
        ,shop_main_id
        ,div_code_id
        ,closer_id
        ,areamgr_id
        ,bldgmgr_id
        ,asst_bldgmgr_id
        ,assignedto_id
        ,modifier_id
        ,building_id
        ,facility_id
        ,created_by
        ,created_date
        ,modified_by
        ,modified_date
        ,status_chk
        ,comments
        ,display
        ,micro
        ,micro_other
        ,primary
        ,unit
        ,osmo_review_chk
        ,osmo_review_date
        ,osmo_review_comment
        ,osmo_close_date
        ,old_cater_prim_unit
        ,group_resp
        ,date_closed
        ,error_message
        ,terminal_type
        ,estimated_fix_time
        ,inspection_date
        ,installation_date
        ,date_end
        ,date_start
        ,date_due_next
        ,repeat_interval
        ,prob_type_chk
        ,bookeeping
        ,urgency
        ,reproducible_chk
        ,description
        ,review_date
        ,modifier_history
        ,problem_history
        ,display_order
        ,watch_and_wait_date
        ,watch_and_wait_comment
        ,report_classification_group
        ,search_criteria
        ,checkbox_date_flagged
        ,printer_email_history
        ,priority_chk
        ,cef_tracking_no
        ,due_date
        ,attachment_history
        ,cef_request_submitted_chk
        ,hop_chk
        ,watch_and_wait_history
        ,micro_or_ioc_chk
        ,pv_name
        ,old_assigned_to
        ,old_modifier_id
        ,old_created_by
        ,area_mgr_review_date
        ,area_mgr_review_comments
        ,project_id
        ,problem_title
        ,sw_request_type
        ,group_id
        ,estimated_hrs
	,email_chk
	,prob_type_dtl_id
	,related_prob_id
        )values
        (jn_operation
        ,c_user
        ,c_now
        ,null
        ,null
        ,userenv('sessionid')
        ,:new.prob_id
        ,:new.area_id
        ,:new.shop_alt_id
        ,:new.subsystem_id
        ,:new.shop_main_id
        ,:new.div_code_id
        ,:new.closer_id
        ,:new.areamgr_id
        ,:new.bldgmgr_id
        ,:new.asst_bldgmgr_id
        ,:new.assignedto_id
        ,:new.modifier_id
        ,:new.building_id
        ,:new.facility_id
        ,:new.created_by
        ,:new.created_date
        ,:new.modified_by
        ,:new.modified_date
        ,:new.status_chk
        ,:new.comments
        ,:new.display
        ,:new.micro
        ,:new.micro_other
        ,:new.primary
        ,:new.unit
        ,:new.osmo_review_chk
        ,:new.osmo_review_date
        ,:new.osmo_review_comment
        ,:new.osmo_close_date
        ,:new.old_cater_prim_unit
        ,:new.group_resp
        ,:new.date_closed
        ,:new.error_message
        ,:new.terminal_type
        ,:new.estimated_fix_time
        ,:new.inspection_date
        ,:new.installation_date
        ,:new.date_end
        ,:new.date_start
        ,:new.date_due_next
        ,:new.repeat_interval
        ,:new.prob_type_chk
        ,:new.bookeeping
        ,:new.urgency
        ,:new.reproducible_chk
        ,:new.description
        ,:new.review_date
        ,:new.modifier_history
        ,:new.problem_history
        ,:new.display_order
        ,:new.watch_and_wait_date
        ,:new.watch_and_wait_comment
        ,:new.report_classification_group
        ,:new.search_criteria
        ,:new.checkbox_date_flagged
        ,:new.printer_email_history
        ,:new.priority_chk
        ,:new.cef_tracking_no
        ,:new.due_date
        ,:new.attachment_history
        ,:new.cef_request_submitted_chk
        ,:new.hop_chk
        ,:new.watch_and_wait_history
        ,:new.micro_or_ioc_chk
        ,:new.pv_name
        ,:new.old_assigned_to
        ,:new.old_modifier_id
        ,:new.old_created_by
        ,:new.area_mgr_review_date
        ,:new.area_mgr_review_comments
        ,:new.project_id
        ,:new.problem_title
        ,:new.sw_request_type
        ,:new.group_id
        ,:new.estimated_hrs
	,:new.email_chk
	,:new.prob_type_dtl_id
	,:new.related_prob_id
        );
    end if;

    if deleting
    then
       insert into art_problems_jn
       (jn_operation
       ,jn_oracle_user
       ,jn_datetime
       ,jn_notes
       ,jn_appln
       ,jn_session
       ,prob_id
       ,area_id
       ,shop_alt_id
       ,subsystem_id
       ,shop_main_id
       ,div_code_id
       ,closer_id
       ,areamgr_id
       ,bldgmgr_id
       ,asst_bldgmgr_id
       ,assignedto_id
       ,modifier_id
       ,building_id
       ,facility_id
       ,created_by
       ,created_date
       ,modified_by
       ,modified_date
       ,status_chk
       ,comments
       ,display
       ,micro
       ,micro_other
       ,primary
       ,unit
       ,osmo_review_chk
       ,osmo_review_date
       ,osmo_review_comment
       ,osmo_close_date
       ,old_cater_prim_unit
       ,group_resp
       ,date_closed
       ,error_message
       ,terminal_type
       ,estimated_fix_time
       ,inspection_date
       ,installation_date
       ,date_end
       ,date_start
       ,date_due_next
       ,repeat_interval
       ,prob_type_chk
       ,bookeeping
       ,urgency
       ,reproducible_chk
       ,description
       ,review_date
       ,modifier_history
       ,problem_history
       ,display_order
       ,watch_and_wait_date
       ,watch_and_wait_comment
       ,report_classification_group
       ,search_criteria
       ,checkbox_date_flagged
       ,printer_email_history
       ,priority_chk
       ,cef_tracking_no
       ,due_date
       ,attachment_history
       ,cef_request_submitted_chk
       ,hop_chk
       ,watch_and_wait_history
       ,micro_or_ioc_chk
       ,pv_name
       ,old_assigned_to
       ,old_modifier_id
       ,old_created_by
       ,area_mgr_review_date
       ,area_mgr_review_comments
       ,project_id
       ,problem_title
       ,sw_request_type
       ,group_id
       ,estimated_hrs
       ,email_chk
       ,prob_type_dtl_id
       ,related_prob_id
       )values
       (jn_operation
       ,c_user
       ,c_now
       ,null
       ,null
       ,userenv('sessionid')
       ,:old.prob_id
       ,:old.area_id
       ,:old.shop_alt_id
       ,:old.subsystem_id
       ,:old.shop_main_id
       ,:old.div_code_id
       ,:old.closer_id
       ,:old.areamgr_id
       ,:old.bldgmgr_id
       ,:old.asst_bldgmgr_id
       ,:old.assignedto_id
       ,:old.modifier_id
       ,:old.building_id
       ,:old.facility_id
       ,:old.created_by
       ,:old.created_date
       ,:old.modified_by
       ,:old.modified_date
       ,:old.status_chk
       ,:old.comments
       ,:old.display
       ,:old.micro
       ,:old.micro_other
       ,:old.primary
       ,:old.unit
       ,:old.osmo_review_chk
       ,:old.osmo_review_date
       ,:old.osmo_review_comment
       ,:old.osmo_close_date
       ,:old.old_cater_prim_unit
       ,:old.group_resp
       ,:old.date_closed
       ,:old.error_message
       ,:old.terminal_type
       ,:old.estimated_fix_time
       ,:old.inspection_date
       ,:old.installation_date
       ,:old.date_end
       ,:old.date_start
       ,:old.date_due_next
       ,:old.repeat_interval
       ,:old.prob_type_chk
       ,:old.bookeeping
       ,:old.urgency
       ,:old.reproducible_chk
       ,:old.description
       ,:old.review_date
       ,:old.modifier_history
       ,:old.problem_history
       ,:old.display_order
       ,:old.watch_and_wait_date
       ,:old.watch_and_wait_comment
       ,:old.report_classification_group
       ,:old.search_criteria
       ,:old.checkbox_date_flagged
       ,:old.printer_email_history
       ,:old.priority_chk
       ,:old.cef_tracking_no
       ,:old.due_date
       ,:old.attachment_history
       ,:old.cef_request_submitted_chk
       ,:old.hop_chk
       ,:old.watch_and_wait_history
       ,:old.micro_or_ioc_chk
       ,:old.pv_name
       ,:old.old_assigned_to
       ,:old.old_modifier_id
       ,:old.old_created_by
       ,:old.area_mgr_review_date
       ,:old.area_mgr_review_comments
       ,:old.project_id
       ,:old.problem_title
       ,:old.sw_request_type
       ,:old.group_id
       ,:old.estimated_hrs
       ,:old.email_chk
       ,:old.prob_type_dtl_id
       ,:old.related_prob_id
       );
    end if;

end;
/