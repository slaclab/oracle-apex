set define off;
create or replace PACKAGE BODY SSRL_RSW_PKG
as
printvar varchar2(4000);

break           varchar2(10) := '<br>';

procedure ssrl_rsw_get_status 
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
,p_s5_operator_id		in  number
,p_s5_other_id			in  number
,p_s6_sso_id			in  number
,p_s6_operator_id		in  number
,p_s4_operator_ack		in  varchar2
,p_s5_pps_chk			in  varchar2
,p_s5_rad_chk			in  varchar2
,p_s5_operator_chk		in  varchar2
,p_s5_other_chk			in  varchar2
,p_s6_operator_ack		in  varchar2
,p_form_status_id		in out number
--,p_status_id_out		out number
)
is

  l_s5_complete number(1) := 0;
  l_current_status number(2);
  l_new_status number(2);
  MSG			VARCHAR2(4000);
  c_proc                 constant varchar2(100) := 'SSRL_RSW_PKG.SSRL_RSW_GET_STATUS ';
BEGIN
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin');
l_current_status := p_form_status_id;

--l_new_status := 1; -- New

apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_form_status_id = '|| p_form_status_id);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of l_current_status = '|| l_current_status );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '1 value of l_new_status = '|| l_new_status);
--apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'value of p_status_id_out = '|| p_status_id_out);
--
if p_s3_task_person_ack_id is not null and
   p_s3_area_mgr_id is not null and
   p_s3_sso_id is not null and
   p_s3_rad_id is not null 
then
  l_new_status := 2; -- Work Approved (not yet Released)
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '2 value of l_new_status = '|| l_new_status );
else
  l_new_status := 1; -- New
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '3 value of l_new_status = '|| l_new_status );
end if;
--
if l_new_status = 2 then
  if p_s4_operator_id is not null and
     p_s4_wrkr_id is not null and
     p_s4_operator_ack is not null 
  then
     l_new_status := 3; -- Work Released
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '4 value of l_new_status = '|| l_new_status );
  end if;
end if;
--
if l_new_status = 3 and
   p_s5_task_person_ack_id is not null 
then
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '5 value of l_new_status = '|| l_new_status );
  l_s5_complete := 1;
  --
  if p_s5_pps_chk = 'Y' and p_s5_pps_id is null then
      l_s5_complete := 0;
  else
    if p_s5_rad_chk = 'Y' and p_s5_rad_id is null then
      l_s5_complete := 0;
    else
      if p_s5_operator_chk = 'Y' and p_s5_operator_id is null then
        l_s5_complete := 0;
      else
        if p_s5_other_chk = 'Y' and p_s5_other_id is null then
          l_s5_complete := 0;
        end if;  -- p_s5_other_chk
      end if;    -- p_s5_operator_chk
    end if;      -- p_s5_rad_chk
  end if;        -- p_s5_pps_chk
  --
else
  l_s5_complete := 0;
end if; -- p_s5_task_person_ack_id
--
if l_s5_complete = 1 then
  l_new_status := 4; -- Work complete
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '6 value of l_new_status = '|| l_new_status );
end if;
--
-- ???????????? is there a review to close step ?????????
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '7 value of l_new_status = '|| l_new_status );
--
if l_new_status = 4 
then
  if p_s6_sso_id is not null and
     p_s6_operator_id is not null and
     p_s6_operator_ack is not null
  then
     l_new_status := 6; -- Closed
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '8 value of l_new_status = '|| l_new_status );
  end if;
end if;
--
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '9 value of l_new_status = '|| l_new_status );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '10 value of l_current_status= '|| l_current_status);
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
end ssrl_rsw_get_status;

function get_form_status
(p_status_id  number
) return varchar2 as
c_proc              constant varchar2(100) := 'Function ssrl_rsw_pkg.get_form_status, ';

  l_status  varchar2(100);

begin
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin ');

  select status
  into l_status
  from ssrl_rsw_form_status
  where form_status_id = p_status_id;

  return l_status;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' l_status= '|| l_status);

exception
  when no_data_found then null;
end get_form_status;

-- Poonam 5/5/22 - Added extra clause for rownum<2, as a user can have multiple roles.
procedure get_user_role
(pi_person_id      in  number
,po_role_id   out number
,po_role      out varchar2
) is
begin

    select dur.role_id
          ,ur.role
    into po_role_id
        ,po_role
    from ssrl_rsw_user_roles dur
        ,ssrl_rsw_roles      ur
    where dur.ROLE_ID = ur.ROLE_ID
    and   dur.user_id = pi_person_id
    and   nvl(dur.status_ai_chk,'A') = 'A'
	AND rownum < 2;

exception
 when no_data_found then null;
    po_role_id := 8;
    po_role    := 'USER';
end get_user_role;

procedure get_user_information
(pi_person_id      in  number
,po_name           out varchar2
,po_email_address  out varchar2
,po_phone_ext      out varchar2
,po_bldg           out varchar2
,po_role_id	   out number
,po_role	   out varchar2
) is

begin

  select p.name           name
        ,p.sid_email      email
        ,p.ext            ext
        ,p.bldg           bldg
        ,ur.role_id       role_id
        ,ur.role          role
  into po_name
      ,po_email_address
      ,po_phone_ext
      ,po_bldg
      ,po_role_id
      ,po_role
  from ssrl_rsw_user_roles u
      ,ssrl_rsw_roles      ur
      ,person              p
  where u.user_id  = pi_person_id
  and   u.role_id  = ur.role_id
  and   u.user_id  = p.key
  and   nvl(u.status_ai_chk,'A') = 'A'
  and      rownum < 2;

exception

  when no_data_found then -- get info from cater
      po_role_id := 8;
      po_role    := 'USER';
  when OTHERS then NULL;

end get_user_information;

function email_addresses 
(p_role varchar2) 
return varchar2
is

  cursor email_cur is
    select sid_email
    from ssrl_rsw_user_roles ur
        ,ssrl_rsw_roles      r
        ,person              p
    where r.role = p_role
    and r.role_id = ur.role_id
    and ur.user_id = p.key
    and ur.STATUS_AI_CHK = 'A';

  l_emails varchar2(500);
  l_first_loop boolean := true;

begin

  for email_rec in email_cur loop

    if l_first_loop
    then
      l_first_loop := false;
    else
      l_emails := l_emails || ';';
    end if;

    l_emails := l_emails || email_rec.sid_email;

  end loop;

  return l_emails;

end email_addresses;

function form_status_color
(p_form_status_id number) return varchar2
is

  l_form_status_color  varchar2(100);

begin

  case p_form_status_id
  when 1 then l_form_status_color := 'red';
  when 2 then l_form_status_color := 'green';
  when 3 then l_form_status_color := 'green';
  when 4 then l_form_status_color := 'green';
  when 5 then l_form_status_color := 'green';
  when 6 then l_form_status_color := 'black';
  when 7 then l_form_status_color := 'black';
  else        l_form_status_color := 'red';
  end case;

  return l_form_status_color;

end form_status_color;

function get_ssrl_rsw_edit_url
(p_apex_url_prefix varchar2
,p_form_id         number
) return varchar2 is
    l_edit_url varchar2(1000);
begin
    l_edit_url := p_apex_url_prefix || 'f?p=273:3:::NO:3:P3_SSRL_FORM_ID:' || p_form_id;
    return l_edit_url;
end get_ssrl_rsw_edit_url;

/*
procedure email_form
(pi_form_id     number
,pi_email_to    varchar2
,pi_email_cc    varchar2
,pi_email_from  varchar2
,pi_subject     varchar2
,pi_comment     varchar2
,pi_instance    varchar2
,pi_active      varchar2
,pi_html        varchar2
) is

    l_email_id               apps_util.qm_emails.email_id%type;

    l_app_name               apps_util.qm_emails.app_name%type := 'SSRL_RSWCF';
    l_body                   apps_util.qm_emails.body%type;

    c_lf                     constant char(1) := chr(10);
    l_form                   ssrl_rsw_form%rowtype;

    l_task_person            person.name%type;
    l_area                   ssrl_rsw_area.area%type;
    l_area_manager_email     varchar2(500);
    l_rp_email		     varchar2(500);
    l_rpfo_email		     varchar2(500);
    l_pps_email		     varchar2(500);
    l_do_email		     varchar2(500);
    l_sso_email		     varchar2(500);

    l_status                 ssrl_rsw_form_status.status%type;
    l_area_manager_released  person.name%type;
    l_adso_approval          person.name%type;
    l_rp_approval            person.name%type;

    l_page_name              varchar2(100) := 'mail a form';

-- Poonam 5/26/2021 - Changes to remove oraweb hardcoding
    l_apex_url_prefix            varchar2(100);
    l_instance                   varchar2(100) := 'slacprod';
    l_form_url     varchar2(1000) := 'https://oraweb.slac.stanford.edu/apex/slacdev2/f?p=269:3:::NO:3:P3_SSRL_FORM_ID:' || pi_form_id;

-- Poonam Dec 2015 - Create a substr length of 500 only for Description - to avoid the superfluous "!" symbol in the emails.
    l_s1_descr		      varchar2(500);
begin

    begin
        select *
        into l_form
        from ssrl_rsw_form
        where ssrl_form_id = pi_form_id;
    exception
        when others then raise;
    end;

    begin
        select status
        into l_status
        from rsw_form_status
        where form_status_id = l_form.form_status_id;
    exception
        when others then raise;
    end;

    l_area_manager_email := email_addresses('AREA MANAGER');
    l_rp_email := email_addresses('RP');
    l_rpfo_email := email_addresses('RPFO');
    l_sso_email := email_addresses('SSO');
    l_do_email := email_addresses('DO');
    l_pps_email := email_addresses('PPS');

    l_rp_approval := getval('EMAIL_ID', l_form.s3_rad_id);
-- Bypass below select later
    begin
        select name
        into l_rp_approval
        from person
        where key = l_form.s3_rad_id;
    exception
        when no_data_found then null;
        when others then raise;
    end;
    --

-- Poonam 5/26/2021 - Changes to remove oraweb hardcoding
    cater_ui.get_apex_url_prefix(po_apex_url_prefix => l_apex_url_prefix, po_instance => l_instance);

    l_form_url := cater_ui.get_rsw_edit_url(p_apex_url_prefix=>l_apex_url_prefix,p_form_id=>pi_form_id);


    l_task_person  := util.get_name_for_sid(l_form.s1_task_person_id);
--    l_area_manager := util.get_name_for_sid(l_form.s1_area_mgr_id);

    l_s1_descr := substr(l_form.s1_descr,1,500);

    if pi_html = 'N'
    then
        l_body :=
            'SSRL Form Id:      ' || l_form.ssrl_form_id  || c_lf ||
            'Task Person:  ' || l_task_person   || c_lf ||
            'Description:  ' || l_s1_descr || c_lf;
    else
        l_body :=
            '<table style="font-family: arial, sans-serif;">' ||
            '<tr><td><b>' || 'Comment:'       || '</b></td><td>'          || pi_comment              ||                               '</td></tr>' ||
            '<tr><td><b>' || 'Form Id:'       || '</b></td><td><a href="' || l_form_url              || '">' || pi_form_id     ||     '</td></tr>' ||
            '<tr><td><b>' || 'Status:'        || '</b></td><td>'          || l_status                ||                               '</td></tr>' ||
            '<tr><td><b>' || 'Task Person:'   || '</b></td><td>'          || l_task_person           ||                               '</td></tr>' ||
            '<tr><td>' || '</td></tr>' ||
            '<tr><td><b>' || 'Description:'   || '</b></td><td>'          || l_s1_descr              ||                               '</td></tr>' ||
            '<tr><td>' || '</td></tr>' ||
--            '<tr><td><b>' || 'AM Reviewed:'   || '</b></td><td>'          || l_area_manager_released ||                               '</td><td>'  || to_char(l_form.s1_area_mgr_date,'mm/dd/yyyy hh24:mi:ss') || '</td></tr>' ||
--            '<tr><td><b>' || 'ADSO Review:' || '</b></td><td>'          || l_adso_approval         ||                               '</td><td>'  || to_char(l_form.s2_adso_date,    'mm/dd/yyyy hh24:mi:ss') || '</td></tr>' ||
--            '<tr><td><b>' || 'RP Approval:'   || '</b></td><td>'          || l_rp_approval           ||                               '</td><td>'  || to_char(l_form.s2_rad_date,     'mm/dd/yyyy hh24:mi:ss') || '</td></tr>' ||
            '</table>';
    end if;

    apps_util.qm_email_pkg.send_email
    (p_app_name   => l_app_name
    ,p_page_name  => l_page_name
    ,p_email_from => pi_email_from
    ,p_email_to   => replace(pi_email_to,':',';')
    ,p_email_cc   => pi_email_from
    ,p_email_bcc  => null
    ,p_subject    => pi_subject
    ,p_body       => l_body
    ,p_is_html    => pi_html
    ,p_is_active  => pi_active -- change this to 'Y' for prod
    ,p_email_id   => l_email_id
    );

end email_form;
*/
end SSRL_RSW_PKG;