create or replace procedure SSRL_RSW_GET_STATUS
(p_form_id			in  number
,p_s3_task_person_ack_id	in  number
,p_s3_area_mgr_id		in  number
,p_s3_sso_id			in  number
,p_s3_rad_id			in  number
,p_s4_operator_id		in  number
,p_s4_wrkr_id			in  number
,p_s5_task_person_ack_id	in  number
,p_s5_pps_id			in  number
,p_s5_rad_id			in  number
,p_s5_sso_id			in  number
,p_s5_operator_id		in  number
,p_s5_rpfo_id			in  number
,p_s5_other1_ack_id		in  number
,p_s5_other2_ack_id		in  number
,p_s5_other3_ack_id		in  number
,p_s6_sso_id			in  number
,p_s6_operator_id		in  number
,p_s6_operator_ack		in  varchar2
,p_s5_pps_chk			in  varchar2
,p_s5_rad_chk			in  varchar2
,p_s5_sso_chk			in  varchar2
,p_s5_operator_chk		in  varchar2
,p_s5_rpfo_chk			in  varchar2
,p_s5_other1_chk		in  varchar2
,p_s5_other1_id			in  number
,p_s5_other2_chk		in  varchar2
,p_s5_other2_id			in  number
,p_s5_other3_chk		in  varchar2
,p_s5_other3_id			in  number
,p_form_status_id		in out number
--,p_status_id_out		out number
)
as

  l_s5_complete number(1) := 0;
  l_current_status number(2);
  l_new_status number(2);
  MSG			VARCHAR2(4000);
  c_proc                 constant varchar2(100) := 'SSRL_RSW_GET_STATUS ';
BEGIN
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin');
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_form_status_id = '|| p_form_status_id);
/*
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_form_id = '|| p_form_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s3_task_person_ack_id = '|| p_s3_task_person_ack_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s3_area_mgr_id = '|| p_s3_area_mgr_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s3_sso_id = '|| p_s3_sso_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s3_rad_id = '|| p_s3_rad_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s4_operator_id = '|| p_s4_operator_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s4_wrkr_id = '|| p_s4_wrkr_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s5_pps_chk = '|| p_s5_pps_chk );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s5_pps_id = '|| p_s5_pps_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s5_rad_chk = '|| p_s5_rad_chk );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s5_rad_id = '|| p_s5_rad_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s5_sso_chk = '|| p_s5_sso_chk );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s5_sso_id = '|| p_s5_sso_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s5_operator_chk = '|| p_s5_operator_chk );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s5_operator_id = '|| p_s5_operator_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s5_rpfo_chk = '|| p_s5_rpfo_chk );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s5_rpfo_id = '|| p_s5_rpfo_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s5_task_person_ack_id = '|| p_s5_task_person_ack_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s6_operator_id = '|| p_s6_operator_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_s6_sso_id = '|| p_s6_sso_id );
*/
l_current_status := p_form_status_id;

--l_new_status := 1; -- New

--
if p_s3_task_person_ack_id is not null and
   p_s3_area_mgr_id is not null and
   p_s3_sso_id is not null and
   p_s3_rad_id is not null
then
  l_new_status := 2; -- Work Approved (not yet Released)
else
  l_new_status := 1; -- New
end if;
--
if l_new_status = 2 then
  if p_s4_operator_id is not null and
     p_s4_wrkr_id is not null
--   and  p_s4_operator_ack is not null
  then
     l_new_status := 3; -- Work Released
  end if;
end if;
--
if l_new_status = 3 and
   p_s5_task_person_ack_id is not null
then
  l_s5_complete := 1;
  --
  if nvl(p_s5_pps_chk,'N') = 'Y' and p_s5_pps_id is null then
      l_s5_complete := 0;
  else
    if nvl(p_s5_rad_chk,'N') = 'Y' and p_s5_rad_id is null then
      l_s5_complete := 0;
    else
     if nvl(p_s5_sso_chk,'N') = 'Y' and p_s5_sso_id is null then
      l_s5_complete := 0;
     else
      if nvl(p_s5_rpfo_chk,'N') = 'Y' and p_s5_rpfo_id is null then
        l_s5_complete := 0;
      else
        if nvl(p_s5_operator_chk,'N') = 'Y' and p_s5_operator_id is null then
           l_s5_complete := 0;
        else
          if nvl(p_s5_other1_chk,'N') = 'Y' and
	     p_s5_other1_id is not null and
	     p_s5_other1_ack_id is null
	  then
             l_s5_complete := 0;
          else
            if nvl(p_s5_other2_chk,'N') = 'Y' and
	       p_s5_other2_id is not null and
	       p_s5_other2_ack_id is null
	    then
               l_s5_complete := 0;
            else
              if nvl(p_s5_other3_chk,'N') = 'Y' and
	         p_s5_other3_id is not null and
	         p_s5_other3_ack_id is null
	      then
                 l_s5_complete := 0;
              end if;  -- p_s5_other3_chk
            end if;  -- p_s5_other2_chk
          end if;  -- p_s5_other1_chk
        end if;  -- p_s5_operator_chk
      end if;    -- p_s5_rpfo_chk
     end if;      -- p_s5_sso_chk
    end if;      -- p_s5_rad_chk
  end if;        -- p_s5_pps_chk
  --
else
  l_s5_complete := 0;
end if; -- p_s5_task_person_ack_id
--
if l_s5_complete = 1 then
  l_new_status := 4; -- Work complete
end if;
--
--
if l_new_status = 4
then
  if p_s6_sso_id is not null and
     p_s6_operator_id is not null and
     p_s6_operator_ack is not null
  then
     l_new_status := 6; -- Closed
  end if;
end if;
--
--
if (nvl(l_current_status,0) != nvl(l_new_status,0))
then
   p_form_status_id := l_new_status;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '11 value of p_form_status_id= '|| p_form_status_id);
--else
--   p_form_status_id := p_form_status_id;
--apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '12 value of p_status_id_out= '|| p_status_id_out);
end if;
--
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'end');
--
end;
/