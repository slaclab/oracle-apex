create or replace procedure ssrl_rswcf_send_email (
 pi_ssrl_form_id		in pls_integer
,pi_app_id			in pls_integer
,pi_from_name			in varchar2
,pi_from_email			in varchar2
)
as
        l_email_id		NUMBER;
	l_instance		varchar2(100);
	l_url_prefix		varchar2(200);
	l_edit_url              varchar2(1000);
	l_edit_link             varchar2(1000);

  l_email_to		VARCHAR2(4000) := NULL;
  l_other_email		varchar2(500) := NULL;
  l_task_person_email	varchar2(50) := NULL;
  l_pps_email		varchar2(100) := NULL;
  l_rad_email		varchar2(100) := NULL;
  l_rpfo_email		varchar2(100) := NULL;
  l_operator_email	varchar2(100) := NULL;
  l_other1_email	varchar2(50) := NULL;
  l_other2_email	varchar2(50) := NULL;
  l_other3_email	varchar2(50) := NULL;
  l_subject		varchar2(500);
  MSG			VARCHAR2(4000);

  l_s1_task_person_id	number;
  l_s5_other1_id	number;
  l_s5_other2_id	number;
  l_s5_other3_id	number;

  l_s5_operator_chk	char(1);
  l_s5_rad_chk		char(1);
  l_s5_pps_chk		char(1);
  l_s5_rpfo_chk		char(1);
  l_s5_task_person_chk	char(1);

  c_proc                 constant varchar2(100) := 'ssrl_rswcf_send_email ';
begin
   select S5_OPERATOR_CHK,S5_PPS_CHK,
          S5_RAD_CHK,S5_RPFO_CHK,S5_TASK_PERSON_CHK,
	  S1_TASK_PERSON_ID, S5_OTHER1_ID, S5_OTHER2_ID, S5_OTHER3_ID
      into l_s5_operator_chk,l_s5_pps_chk,
           l_s5_rad_chk,l_s5_rpfo_chk,l_s5_task_person_chk,
	   l_s1_task_person_id, l_s5_other1_id, l_s5_other2_id, l_s5_other3_id
   from ssrl_rsw_form
   where ssrl_form_id = pi_ssrl_form_id;
   --
   IF l_s5_task_person_chk = 'Y' THEN
      l_task_person_email := getval('EMAIL_ID', l_s1_task_person_id);
   END IF;
   --
   IF l_s5_other1_id is not null THEN
      l_other1_email := getval('EMAIL_ID', l_s5_other1_id);
   END IF;
   --
   IF l_s5_other2_id is not null THEN
      l_other2_email := getval('EMAIL_ID', l_s5_other2_id);
   END IF;
   --
   IF l_s5_other3_id is not null THEN
      l_other3_email := getval('EMAIL_ID', l_s5_other3_id);
   END IF;
   --
   IF l_s5_operator_chk = 'Y' THEN
	l_operator_email := 'ssrl-bldo@slac.stanford.edu';
   END IF;
   --
   IF l_s5_pps_chk = 'Y' THEN
	l_pps_email := ssrl_rsw_pkg.email_addresses('PPS');
   END IF;
   --
   IF l_s5_rad_chk = 'Y' THEN
	l_rad_email := ssrl_rsw_pkg.email_addresses('RP');
   END IF;
   --
   IF l_s5_rpfo_chk = 'Y' THEN
	l_rpfo_email := ssrl_rsw_pkg.email_addresses('RPFO');
   END IF;
   --
   l_other_email := l_task_person_email || ';' || l_other1_email || ';' || l_other2_email || ';' || l_other3_email;
   l_email_to := l_pps_email || ';' || l_rad_email || l_rpfo_email || ';' || l_operator_email || ';' || l_other_email;
   l_email_to := l_email_to ||';'||'poonam@slac.stanford.edu' ;
   l_email_to := trim(both ';' from replace(l_email_to,' ',''));
   l_email_to := replace(l_email_to,';;;;',';');
   l_email_to := replace(l_email_to,';;;',';');
   l_email_to := replace(l_email_to,';;',';');
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'AFTER TRIM l_email_to = '|| l_email_to );

   l_subject := 'PLEASE DISREGARD: TESTING ONLY. You have been assigned a new SSRL RSWCF #'|| pi_ssrl_form_id;
   --
   l_instance := sys_context('USERENV','INSTANCE_NAME');
   l_url_prefix := 'https://oraweb.slac.stanford.edu/apex/'||lower(l_instance)||'/';
   l_edit_url := l_url_prefix ||'f?p='||pi_app_id;
--   l_edit_url := l_url_prefix ||'f?p='||pi_app_id||':3:::NO::P3_SSRL_FORM_ID:' || pi_ssrl_form_id ;

 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_edit_url = '|| l_edit_url );

  l_edit_link := '<a href="' || l_edit_url || '" target="_blank">' || 'Edit Form' || '</a>';

   MSG := 'PLEASE DISREGARD: TESTING ONLY. '|| chr(10)|| '<br>' ||
          'A new SSRL Rad Safety Form #'|| pi_ssrl_form_id ||' has been created by '||pi_from_name||
   '.  Please review and sign off for your part' || chr(10)|| '<br>' ||
   ' Click on the link below to review the form' || chr(10) || '<br><br>' || l_edit_link;

    apps_util.qm_email_pkg.send_email
    (p_app_name   => 'SSRL RSWCF'
    ,p_page_name  => 'SSRL_RSWCF_SEND_EMAIL'
    ,p_email_from => pi_from_email
    ,p_email_to   => l_email_to||';'|| 'poonam@slac.stanford.edu'
    ,p_email_cc   => null
    ,p_email_bcc  => null
    ,p_subject    => l_subject
    ,p_body       => MSG
    ,p_is_html    => 'Y'
    ,p_is_active  => 'Y'
    ,p_email_id   => l_email_id
    );
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_email_id = '|| l_email_id );
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'end' );
   exception
   WHEN OTHERS THEN
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' Exception '|| chr(10) || SQLERRM);
       plsql_mail.contact_smtpsrv('oracle.slac.stanford.edu','poonam@slac.stanford.edu');
        plsql_mail.send_header('From', 'poonam@slac.stanford.edu');
        plsql_mail.send_header('To', 'poonam@slac.stanford.edu');
        plsql_mail.send_header('Subject','Error in Procedure SSRL_RSWCF_SEND_EMAIL');
        plsql_mail.send_body('Error in Procedure SSRL_RSWCF_SEND_EMAIL - pi_ssrl_form_id= ' || 
	                      pi_ssrl_form_id || chr(10) || SQLERRM);
        plsql_mail.signoff_smtpsrv;

end;
/