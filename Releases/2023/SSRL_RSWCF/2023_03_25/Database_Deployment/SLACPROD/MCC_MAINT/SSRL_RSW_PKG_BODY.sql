set define off;
--------------------------------------------------------
--  File created - Friday-January-27-2023   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body SSRL_RSW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MCC_MAINT"."SSRL_RSW_PKG" 
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
     p_s4_wrkr_id is not null and
     p_s4_operator_ack is not null
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
--else
--   p_form_status_id := p_form_status_id;
--apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '12 value of p_status_id_out= '|| p_status_id_out);
end if;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'end');
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


PROCEDURE EMAIL_SSRL_RSW_FORM
(pi_form_rec_new	SSRL_RSW_FORM%rowtype
,pi_form_rec_old	SSRL_RSW_FORM%rowtype
,pi_from		varchar2 := c_from_email
,pi_operation		varchar2
) is
	c_proc          constant varchar2(100) := 'SSRL_RSW_PKG.EMAIL_SSRL_RSW_FORM ';

    l_apex_url_prefix            varchar2(100);
    l_instance                   varchar2(100) := 'slacprod';

    l_form_url   varchar2(1000);-- := 'https://oraweb.slac.stanford.edu/apex/' || pi_instance || '/f?p=273:3:::NO:2:P3_SSRL_FORM_ID:' || pi_form_rec_new.ssrl_form_id;

	l_url_prefix		varchar2(200);
	l_edit_url              varchar2(1000);
	l_edit_link             varchar2(1000);

--	l_form_rec_new           SSRL_RSW_FORM%rowtype;
--	l_form_rec_old           SSRL_RSW_FORM%rowtype;
	l_operation              varchar2(1);
	l_changer_email          varchar2(100);
	l_message_type           varchar2(10);
	l_form_id	number;
	l_page_name	varchar2(100);
	l_descr		varchar2(200);
	l_subject	varchar2(500);
	l_body		varchar2(1000);
	l_body1		varchar2(200) := '';
	l_body2		varchar2(500);
	l_var_body	varchar2(500);
	l_email_other	varchar2(1000);
	l_email_to	varchar2(1000);
	l_email_to_final	varchar2(1000);

	l_email_to_s1_task_person_old	person.MAILDISP%type;
	l_email_to_s3_sso_old		person.MAILDISP%type;
	l_email_to_s3_am_old		person.MAILDISP%type;
	l_email_to_s3_rp_old		person.MAILDISP%type;
	l_email_to_s4_do_old		person.MAILDISP%type;
	l_email_to_s4_wrkr_old		person.MAILDISP%type;
	l_email_to_s4_assign_wrkr_old	person.MAILDISP%type;
	l_email_to_s5_rp_old		person.MAILDISP%type;
	l_email_to_s5_sso_old		person.MAILDISP%type;
	l_email_to_s5_rpfo_old		person.MAILDISP%type;
	l_email_to_s5_pps_old		person.MAILDISP%type;
	l_email_to_s5_do_old		person.MAILDISP%type;
	l_email_to_other1_old		person.MAILDISP%type;
	l_email_to_other2_old		person.MAILDISP%type;
	l_email_to_other3_old		person.MAILDISP%type;
	l_email_to_other1_ack_old	person.MAILDISP%type;
	l_email_to_other2_ack_old	person.MAILDISP%type;
	l_email_to_other3_ack_old	person.MAILDISP%type;

	l_email_to_s1_task_person_new	person.MAILDISP%type;
	l_email_to_s3_task_person_new	 person.MAILDISP%type;
	l_email_to_s3_sso_new		person.MAILDISP%type;
	l_email_to_s3_am_new		person.MAILDISP%type;
	l_email_to_s3_rp_new		person.MAILDISP%type;
	l_email_to_s4_do_new		person.MAILDISP%type;
	l_email_to_s4_wrkr_new		person.MAILDISP%type;
	l_email_to_s4_assign_wrkr_new	person.MAILDISP%type;
	l_email_to_s5_rp_new		person.MAILDISP%type;
	l_email_to_s5_sso_new		person.MAILDISP%type;
	l_email_to_s5_rpfo_new		person.MAILDISP%type;
	l_email_to_s5_pps_new		person.MAILDISP%type;
	l_email_to_s5_do_new		person.MAILDISP%type;
	l_email_to_s6_do_new		person.MAILDISP%type;
	l_email_to_s6_sso_new		person.MAILDISP%type;
	l_email_to_other1_new		person.MAILDISP%type;
	l_email_to_other2_new		person.MAILDISP%type;
	l_email_to_other3_new		person.MAILDISP%type;
	l_email_to_other1_ack_new	person.MAILDISP%type;
	l_email_to_other2_ack_new	person.MAILDISP%type;
	l_email_to_other3_ack_new	person.MAILDISP%type;


	l_email_to_s3_sso	person.MAILDISP%type;
	l_email_to_s3_am	person.MAILDISP%type;
	l_email_to_s3_rp	person.MAILDISP%type;
	l_email_to_s4_do	person.MAILDISP%type;
	l_s4_assign_wrkr_new	person.MAILDISP%type;
	l_email_to_s4_wrkr	person.MAILDISP%type;
	l_email_to_s5_rp	person.MAILDISP%type;
	l_email_to_s5_sso	person.MAILDISP%type;
	l_email_to_s5_rpfo	person.MAILDISP%type;
	l_email_to_s5_pps	person.MAILDISP%type;
	l_email_to_s5_do	person.MAILDISP%type;
	l_email_to_s6_do	person.MAILDISP%type;
	l_email_to_s6_sso	person.MAILDISP%type;
	l_email_to_other1	person.MAILDISP%type;
	l_email_to_other2	person.MAILDISP%type;
	l_email_to_other3	person.MAILDISP%type;
	l_email_to_other1_ack	person.MAILDISP%type;
	l_email_to_other2_ack	person.MAILDISP%type;
	l_email_to_other3_ack	person.MAILDISP%type;

	l_email_to_blm_rec	varchar2(50);
	l_email_to_blm		varchar2(500);
	l_email_to_bldo		varchar2(500);
	l_email_to_ops		varchar2(50);

	l_email_to_s3		varchar2(500);
	l_email_to_s4		varchar2(500);
	l_email_to_s5		varchar2(500);
	l_email_to_s6		varchar2(500);

	l_email_to_sso_grp	varchar2(500);
	l_email_to_am_grp	varchar2(500);
	l_email_to_rp_grp	varchar2(500);
	l_email_to_rpfo_grp	varchar2(500);
	l_email_to_pps_grp	varchar2(500);
	l_email_id		number;
	l_email_flag		number(2) := 0;
	l_signed_by		PERSONS.PERSON.NAME%TYPE;
	l_created_by		PERSONS.PERSON.NAME%TYPE;
	l_created_by_email	varchar2(50) := NULL;
	l_modified_by		PERSONS.PERSON.NAME%TYPE;
	l_modified_by_email	varchar2(50) := NULL;
	l_old_form_status	SSRL_RSW_FORM_STATUS.STATUS%TYPE;
	l_new_form_status	SSRL_RSW_FORM_STATUS.STATUS%TYPE;

	l_created_date		DATE;
	l_modified_date		DATE;
	l_area			varchar2(50) := NULL;

cursor blm_email is
        select name, maildisp
          from persons.person
         where key in (select BEAMLINE_MGR_ID from ssrl_rsw_beamline_mgr
                        where area_id = pi_form_rec_new.S1_AREA_ID); 
begin

    apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin');
     begin
        select name, maildisp
          into l_created_by, l_created_by_email
          from persons.person
         where key in (select max(but_sid) from but 
                        where upper(but_kid) = pi_form_rec_new.CREATED_BY);
     exception
       when no_data_found then 
         l_created_by := 'UnAssigned';
         l_created_by_email := NULL;
       when others then raise;
     end;
    --
     begin
        select name, maildisp
          into l_modified_by, l_modified_by_email
          from persons.person
         where key in (select max(but_sid) from but 
                        where upper(but_kid) = pi_form_rec_new.MODIFIED_BY);
     exception
       when no_data_found then 
         l_modified_by := Null;
         l_modified_by_email := NULL;
       when others then raise;
     end;
    --
	l_form_id := pi_form_rec_new.SSRL_FORM_ID;
	l_email_to_sso_grp := ssrl_rsw_pkg.email_addresses('SSO');
	l_email_to_am_grp := ssrl_rsw_pkg.email_addresses('AREA MANAGER');
	l_email_to_rp_grp := ssrl_rsw_pkg.email_addresses('RP');
	l_email_to_rpfo_grp := ssrl_rsw_pkg.email_addresses('RPFO');
	l_email_to_pps_grp := ssrl_rsw_pkg.email_addresses('PPS');

	l_area := getval('SSRL_AREA',pi_form_rec_new.S1_AREA_ID);

--	l_email_to_bldo := 'ssrl-bldo@slac.stanford.edu';
	l_email_to_bldo := ssrl_rsw_pkg.email_addresses('DO');
	l_email_to_ops := 'spearops@slac.stanford.edu';

	l_email_to_s3_rp_new := getval('EMAIL_ID',pi_form_rec_new.S3_RAD_ID);
	l_email_to_s3_sso_new := getval('EMAIL_ID',pi_form_rec_new.S3_SSO_ID);
	l_email_to_s3_am_new := getval('EMAIL_ID',pi_form_rec_new.S3_AREA_MGR_ID);
	l_email_to_s3_task_person_new := getval('EMAIL_ID',pi_form_rec_new.S3_TASK_PERSON_ACK_ID);

	l_email_to_s4_do_new  := getval('EMAIL_ID',pi_form_rec_new.S4_OPERATOR_ID);
	l_email_to_s4_wrkr_new := getval('EMAIL_ID', pi_form_rec_new.S4_WRKR_ID);

	l_email_to_s5_rp_new := getval('EMAIL_ID',pi_form_rec_new.S5_RAD_ID);
	l_email_to_s5_sso_new := getval('EMAIL_ID',pi_form_rec_new.S5_SSO_ID);
	l_email_to_s5_rpfo_new := getval('EMAIL_ID',pi_form_rec_new.S5_RPFO_ID);
	l_email_to_s5_pps_new := getval('EMAIL_ID',pi_form_rec_new.S5_PPS_ID);
	l_email_to_s5_do_new := getval('EMAIL_ID',pi_form_rec_new.S5_OPERATOR_ID);
	l_email_to_s6_do_new := getval('EMAIL_ID',pi_form_rec_new.S6_OPERATOR_ID);
	l_email_to_s6_sso_new := getval('EMAIL_ID',pi_form_rec_new.S6_SSO_ID);

	l_email_to_s1_task_person_old := getval('EMAIL_ID', pi_form_rec_old.S1_TASK_PERSON_ID);
	l_email_to_s1_task_person_new := getval('EMAIL_ID', pi_form_rec_new.S1_TASK_PERSON_ID);

	l_email_to_other1_new := getval('EMAIL_ID', pi_form_rec_new.S5_OTHER1_ID);
	l_email_to_other2_new := getval('EMAIL_ID', pi_form_rec_new.S5_OTHER2_ID);
	l_email_to_other3_new := getval('EMAIL_ID', pi_form_rec_new.S5_OTHER3_ID);
	l_email_to_other1_ack_new := getval('EMAIL_ID', pi_form_rec_new.S5_OTHER1_ACK_ID);
	l_email_to_other2_ack_new := getval('EMAIL_ID', pi_form_rec_new.S5_OTHER2_ACK_ID);
	l_email_to_other3_ack_new := getval('EMAIL_ID', pi_form_rec_new.S5_OTHER3_ACK_ID);

	l_email_to_s3 := l_email_to_s3_rp_new ||';'|| l_email_to_s3_sso_new ||';'|| l_email_to_s3_am_new ||';'|| l_email_to_s3_task_person_new;
	l_email_to_s4 := l_email_to_s4_do_new ||';'|| l_email_to_s4_wrkr_new;
	l_email_to_s5 := l_email_to_s5_do_new ||';'|| l_email_to_s5_rp_new ||';'|| l_email_to_s5_sso_new ||';'|| l_email_to_s5_rpfo_new ||';'|| l_email_to_s5_pps_new;
	l_email_to_s6 := l_email_to_s6_do_new ||';'|| l_email_to_s6_sso_new;

	l_email_other := l_email_to_other1_new ||';'|| l_email_to_other2_new ||';'|| l_email_to_other3_new ||';'|| l_email_to_other1_ack_new ||';'|| l_email_to_other2_ack_new ||';'|| l_email_to_other3_ack_new;
	--
	l_email_to := l_email_to_s3 ||';'|| l_email_to_s4 ||';'|| l_email_to_s5 ||';'|| l_email_to_s6 ||';'|| l_email_other;
	l_email_to := trim(';' FROM l_email_to);
	--
	l_email_to := l_email_to ||';'|| l_created_by_email;
	l_email_to_final := trim(';' FROM l_email_to);
	--

	l_descr := substr(pi_form_rec_new.S1_DESCR,1,200);
	l_old_form_status := getval('SSRL_FORM_STATUS', pi_form_rec_old.FORM_STATUS_ID);
	l_new_form_status := getval('SSRL_FORM_STATUS', pi_form_rec_new.FORM_STATUS_ID);

	l_created_date := pi_form_rec_new.created_date;
	l_modified_date := pi_form_rec_new.modified_date;

	FOR blm_email_rec in blm_email LOOP
	  l_email_to_blm_rec := blm_email_rec.maildisp;
	  l_email_to_blm := l_email_to_blm_rec ||';'||l_email_to_blm;
	END LOOP;

    cater_ui.get_apex_url_prefix(po_apex_url_prefix => l_apex_url_prefix, po_instance => l_instance);
    l_form_url := APEX_UTIL.PREPARE_URL(p_url => 'f?p=273:3:::NO:3:P3_SSRL_FORM_ID:' || pi_form_rec_new.ssrl_form_id);
    l_edit_url := l_apex_url_prefix || l_form_url;
    l_edit_link := '<a href="' || l_edit_url || '" target="_blank">' || 'Edit Form' || '</a>';

   l_instance := sys_context('USERENV','INSTANCE_NAME');
   l_url_prefix := 'https://oraweb.slac.stanford.edu/apex/'||lower(l_instance)||'/';
--   l_body1 := 'SSRL electronic RSWCF #'||l_form_id||', please approve if required. '|| chr(10)|| '<br><br>';
   l_body2 := ' Last Signed by: '|| l_modified_by ||chr(10)|| '<br><br>' ||
	      ' Last Signed Date: '|| l_modified_date ||chr(10)|| '<br><br>' ||
              ' Work Description: '||l_descr||chr(10)|| '<br><br>' ||
              ' This RSWCF was originally generated by: '||l_created_by||chr(10)|| '<br><br>' ||
	      ' Click on the link below to review the form' || chr(10) || '<br><br>' || l_edit_link;


-- *******************  Form Status in Released/Completed **************
    IF (pi_form_rec_new.EMAIL_CHK = 'Y' and pi_form_rec_new.email_rule > 20)
    THEN
     IF pi_form_rec_new.email_rule = 21
     THEN
        l_email_flag := 1;
	l_signed_by := getval('NAME', pi_form_rec_new.S4_WRKR_ID);
	l_email_to_final := l_email_to_blm ||';'|| l_email_to_ops||';'||l_email_to_bldo ||';'|| l_email_to_final ;
        l_page_name := 'Sec 4 : Work Released';
	l_subject := 'SSRL RSWCF #'||l_form_id;
        l_var_body := 'The form is now Work Released.'||chr(10)|| '<br><br>'||
	 'The work was released to perform work at '||l_area||' covered by Radiation Safety Work Control Form #'||l_form_id||chr(10)|| '<br><br>'||
         'SSRL RSWCF #'||l_form_id||' was signed off for '||l_signed_by||' as Person doing the Work.'||chr(10)|| '<br><br>'||
--         'SSRL RSWCF #'||l_form_id||' was signed off by '||l_modified_by||' for '||l_signed_by||' as Person doing the Work.'||chr(10)|| '<br><br>'||
	 'Section 4 - Person doing Work Signed.'||chr(10)|| '<br><br>';   

	l_body := l_var_body || l_body2;
      ELSIF pi_form_rec_new.email_rule = 22
      THEN
        l_email_flag := 1;
	l_email_to_final := l_email_to_sso_grp ||';'||l_created_by_email;
	l_page_name := 'Sec 6 : SSO Signoff Request';
        l_var_body := 'As SSRL Safety Officer, Please review the work done and signoff to close SSRL RSWCF #'||l_form_id||chr(10)|| '<br><br>' ||
		  ' Section 6: SSO review' || chr(10)|| '<br><br>';
 	l_body := l_body1 ||l_var_body || l_body2;
     ELSIF pi_form_rec_new.email_rule = 23
     THEN
	l_email_flag := 1;
	l_signed_by := getval('NAME', pi_form_rec_new.S6_OPERATOR_ID);
	l_email_to_final := l_email_to_blm ||';'|| l_email_to_ops||';'||l_email_to_bldo||';'||l_email_to_final ;
	l_email_to_final := trim(';' FROM l_email_to_final);

	l_page_name := 'Sec 6 : DO Signed';

	l_var_body := ' SSRL RSWCF #'||l_form_id||' is now ' || l_new_form_status ||chr(10)|| '<br><br>' ||
	          'Radiation Safety Work Control Form #'||l_form_id||' that covered work at '||l_area||' is now Closed.'||chr(10)|| '<br><br>'||
		  'SSRL RSWCF #'||l_form_id||' was signed off for '||l_signed_by||', as the Duty Operator.'|| chr(10)|| '<br><br>'||
--		  'RSWCF #'||l_form_id||' was signed off for the Duty Operator by '||l_modified_by||' for '||l_signed_by||chr(10)|| '<br><br>'||
		  'Section 6 - DO Signed.'||chr(10)|| '<br><br>';

	l_body := l_var_body || l_body2;
--
     ELSIF pi_form_rec_new.email_rule = 24
     THEN
	l_email_flag := 1;
	l_email_to_final := l_email_to_blm ||';'|| l_email_to_ops||';'||l_email_to_bldo||';'||l_email_to_final ;
	l_email_to_final := trim(';' FROM l_email_to_final);

	l_page_name := 'Sec 4 : Form Dropped';

	l_var_body := ' SSRL RSWCF #'||l_form_id||' is now ' || l_new_form_status ||chr(10)|| '<br><br>' ||
	          'Radiation Safety Work Control Form #'||l_form_id||' that covered work at '||l_area||' is now Dropped.'||chr(10)|| '<br><br>'||
		  'SSRL RSWCF #'||l_form_id||' was dropped by '||l_modified_by||', as a valid user.'|| chr(10)|| '<br><br>'||
		  'Section 4 - Form Dropped.'||chr(10)|| '<br><br>';

	l_body := l_var_body || l_body2;
--
      END IF; -- email_rule = 22 (Form Status in Complete)
	--

    END IF; -- email_rule > 20 (Form Status in Released/Completed)
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 2) l_email_flag = '||l_email_flag);
    --
-- *******************  Form Status = Transferred **************
    IF (pi_form_rec_new.EMAIL_CHK = 'Y' and pi_form_rec_new.email_rule = 19)
    THEN
      l_email_flag := 1;
      l_page_name := 'Form Transferred';
      l_subject := 'SSRL RSWCF #'||l_form_id||' is now '||l_new_form_status||' to #'||pi_form_rec_new.SSRL_FORM_ID_TRANSFER_TO;
      l_var_body := ' Please note that SSRL RSWCF #'||l_form_id||' is now '||l_new_form_status||' to #'||
	          pi_form_rec_new.SSRL_FORM_ID_TRANSFER_TO||' and cannot be modified anymore' || chr(10)|| '<br><br>' ;
	l_body := l_body1 ||l_var_body || l_body2;
    END IF; -- email_rule = 19 (Form Status = Transferred)
    --
--
-- *******************  Form Status = Work Approved (not yet Released) **************
--
    IF (pi_form_rec_new.EMAIL_CHK = 'Y' and pi_form_rec_new.email_rule = 20)
    THEN
	l_signed_by := getval('NAME', pi_form_rec_new.S3_TASK_PERSON_ACK_ID);
	l_email_to := l_email_to_blm ||';'||l_created_by_email ||';'|| l_email_to_s3;
        l_page_name := 'Sec 3 : Work Approved (not yet Released)';
        l_var_body := 'The form is now Work Approved, but not yet Released.'||chr(10)|| '<br><br>'||
	 'Radiation Safety Work Control Form #'||l_form_id||'  was opened to cover work at '||l_area||chr(10)|| '<br><br>'||
         'SSRL RSWCF #'||l_form_id||' was signed off for '||l_signed_by||' as Person Responsible.'||chr(10)|| '<br><br>'||     
	 'Section 3 - Person Responsible Signed.'||chr(10)|| '<br><br>';   

	l_body := l_var_body || l_body2;
	l_email_to_final := trim(';' FROM l_email_to);

	l_page_name := 'Sec 3 : PR Signed';
   	begin

	    email_form
	    (pi_form_id    => l_form_id
	    ,pi_instance   => l_instance
	    ,pi_page_name  => l_page_name
	    ,pi_email_to   => l_email_to_final
	    ,pi_email_cc   => null
	    ,pi_email_from => null
	    ,pi_subject    => l_subject
	    ,pi_body       => l_body
	    ,po_email_id   => l_email_id
	    );
	end;

-- Email for Sign Off Required
	l_email_to := l_email_to_s1_task_person_new||';'||l_email_to_bldo ||';'||l_created_by_email;
	l_email_to_final := trim(';' FROM l_email_to);

	l_var_body := ' As the Duty Operator, Please review and release work for SSRL RSWCF #'||l_form_id||chr(10)|| '<br><br>' ||
          ' Please also assign the person doing the work, which has been pre-approved by RP, SSO and Area Manager.' ||chr(10)|| '<br><br>'||
          ' Section 4: DO Signoff.' ||chr(10)|| '<br><br>' ;

	l_body := l_body1 ||l_var_body || l_body2;
	l_page_name := 'Sec 4: DO Signoff Request';
   	begin

	    email_form
	    (pi_form_id    => l_form_id
	    ,pi_instance   => l_instance
	    ,pi_page_name  => l_page_name
	    ,pi_email_to   => l_email_to_final
	    ,pi_email_cc   => null
	    ,pi_email_from => null
	    ,pi_subject    => l_subject
	    ,pi_body       => l_body
	    ,po_email_id   => l_email_id
	    );
	end;
	l_email_flag := 0;    
    
    END IF; -- email_rule = 20 (Form Status = Work Approved (not yet Released))



-- *******************  S3_RP signed off *******************  
    IF (pi_form_rec_new.EMAIL_CHK = 'Y' and pi_form_rec_new.email_rule = 1)
    THEN

-- Email for Signed Off process
	l_signed_by := getval('NAME', pi_form_rec_new.S3_RAD_ID);
	l_email_to := l_email_to_rp_grp ||';'||l_created_by_email;

--	l_var_body := 'RSWCF #'||l_form_id||' was signed off for Radiation Physicist by '|| l_modified_by ||' for '|| l_signed_by ||chr(10)|| '<br><br>'||
	l_var_body := 'SSRL RSWCF #'||l_form_id||' was signed off for Radiation Physicist for '|| l_signed_by ||chr(10)|| '<br><br>'||
		  'You are no longer required to sign this form.'||chr(10)|| '<br><br>'||
		  'Section 3 - RP Signed.'||chr(10)|| '<br><br>';

	l_body := l_var_body || l_body2;
	l_email_to_final := trim(';' FROM l_email_to);

	l_page_name := 'Sec 3 : RP Signed';
   	begin
		l_email_to_final := trim(';' FROM l_email_to_final);

	    email_form
	    (pi_form_id    => l_form_id
	    ,pi_instance   => l_instance
	    ,pi_page_name  => l_page_name
	    ,pi_email_to   => l_email_to_final
	    ,pi_email_cc   => null
	    ,pi_email_from => null
	    ,pi_subject    => l_subject
	    ,pi_body       => l_body
	    ,po_email_id   => l_email_id
	    );
	end;

-- Email for Sign Off Required
	l_email_to := l_email_to_sso_grp ||';'||l_created_by_email;
	l_email_to_final := trim(';' FROM l_email_to);

	l_var_body := ' As SSRL Safety Officer, Please review and pre-approve SSRL RSWCF #'||l_form_id||chr(10)|| '<br><br>' ||
	              ' Section 3: SSO approval.' || chr(10)|| '<br><br>' ;

	l_body := l_body1 ||l_var_body || l_body2;
	l_page_name := 'Sec 3 : SSO Signoff Request';
   	begin
		l_email_to_final := trim(';' FROM l_email_to_final);

	    email_form
	    (pi_form_id    => l_form_id
	    ,pi_instance   => l_instance
	    ,pi_page_name  => l_page_name
	    ,pi_email_to   => l_email_to_final
	    ,pi_email_cc   => null
	    ,pi_email_from => null
	    ,pi_subject    => l_subject
	    ,pi_body       => l_body
	    ,po_email_id   => l_email_id
	    );
	end;
	l_email_flag := 0;

    END IF; --(Sec 3 RP Signed)
    --
-- *******************  S3_SSO_ID signed off *******************  
    IF (pi_form_rec_new.EMAIL_CHK = 'Y' and pi_form_rec_new.email_rule = 2)
    THEN

-- Email for Signed Off process
	l_signed_by := getval('NAME', pi_form_rec_new.S3_SSO_ID);
	l_email_to := l_email_to_sso_grp ||';'||l_created_by_email;

--	l_var_body := 'SSRL electronic RSWCF #'||l_form_id||' was signed off for SSRL Safety Officer by '|| l_modified_by ||' for '|| l_signed_by ||chr(10)|| '<br><br>'||
	l_var_body := 'SSRL electronic RSWCF #'||l_form_id||' was signed off for '|| l_signed_by ||', as SSRL Safety Officer.'||chr(10)|| '<br><br>'||
		  'You are no longer required to sign this form.'||chr(10)|| '<br><br>'||
		  'Section 3 - SSO Signed.'||chr(10)|| '<br><br>';

	l_body := l_var_body || l_body2;
	l_email_to_final := trim(';' FROM l_email_to);

	l_page_name := 'Sec 3 : SSO Signed';
   	begin
		l_email_to_final := trim(';' FROM l_email_to_final);

	    email_form
	    (pi_form_id    => l_form_id
	    ,pi_instance   => l_instance
	    ,pi_page_name  => l_page_name
	    ,pi_email_to   => l_email_to_final
	    ,pi_email_cc   => null
	    ,pi_email_from => null
	    ,pi_subject    => l_subject
	    ,pi_body       => l_body
	    ,po_email_id   => l_email_id
	    );
	end;

-- Email for Sign Off Required
	l_email_to := l_email_to_am_grp ||';'||l_created_by_email;
	l_email_to_final := trim(';' FROM l_email_to);

	l_var_body := ' As Area Manager, Please review and pre-approve SSRL RSWCF #'||l_form_id||chr(10)|| '<br><br>' ||
	              ' Section 3: Area Manager approval.' || chr(10)|| '<br><br>' ;

	l_body := l_body1 ||l_var_body || l_body2;
	l_page_name := 'Sec 3 : AM Signoff Request';
   	begin
		l_email_to_final := trim(';' FROM l_email_to_final);

	    email_form
	    (pi_form_id    => l_form_id
	    ,pi_instance   => l_instance
	    ,pi_page_name  => l_page_name
	    ,pi_email_to   => l_email_to_final
	    ,pi_email_cc   => null
	    ,pi_email_from => null
	    ,pi_subject    => l_subject
	    ,pi_body       => l_body
	    ,po_email_id   => l_email_id
	    );
	end;
	l_email_flag := 0;

    END IF; -- email_rule = 2 (Sec 3 SSO Signed)
    --
-- *******************  S3_AREA_MGR_ID signed off *******************  
    IF (pi_form_rec_new.EMAIL_CHK = 'Y' and pi_form_rec_new.email_rule = 3)
    THEN

-- Email for Signed Off process
	l_signed_by := getval('NAME', pi_form_rec_new.S3_AREA_MGR_ID);
	l_email_to := l_email_to_am_grp ||';'||l_created_by_email;

--	l_var_body := 'RSWCF #'||l_form_id||' was signed off for Area Manager by '|| l_modified_by ||' for '|| l_signed_by ||chr(10)|| '<br><br>'||
	l_var_body := 'SSRL RSWCF #'||l_form_id||' was signed off for '|| l_signed_by ||', as Area Manager.'|| chr(10)|| '<br><br>'||
		  'You are no longer required to sign this form.'||chr(10)|| '<br><br>'||
		  'Section 3 - Area Manager Signed.'||chr(10)|| '<br><br>';

	l_body := l_var_body || l_body2;
	l_email_to_final := trim(';' FROM l_email_to);

	l_page_name := 'Sec 3 : AM Signed';
   	begin
		l_email_to_final := trim(';' FROM l_email_to_final);

	    email_form
	    (pi_form_id    => l_form_id
	    ,pi_instance   => l_instance
	    ,pi_page_name  => l_page_name
	    ,pi_email_to   => l_email_to_final
	    ,pi_email_cc   => null
	    ,pi_email_from => null
	    ,pi_subject    => l_subject
	    ,pi_body       => l_body
	    ,po_email_id   => l_email_id
	    );
	end;
	--
-- Email for Sign Off Required
	l_email_to := l_email_to_s1_task_person_new ||';'||l_created_by_email;
	l_email_to_final := trim(';' FROM l_email_to);

	l_var_body := ' As the Person Responsible, Please review and signoff  SSRL RSWCF #'||l_form_id||
                      ', which has been pre-approved by RP, SSO and Area Manager.' ||chr(10)|| '<br><br>' ||
                      ' Section 3 - Person Responsible Signoff.'||chr(10)|| '<br><br>' ;

	l_body := l_body1 ||l_var_body || l_body2;
	l_page_name := 'Sec 3 : PR Signoff Request';
   	begin
		l_email_to_final := trim(';' FROM l_email_to_final);

	    email_form
	    (pi_form_id    => l_form_id
	    ,pi_instance   => l_instance
	    ,pi_page_name  => l_page_name
	    ,pi_email_to   => l_email_to_final
	    ,pi_email_cc   => null
	    ,pi_email_from => null
	    ,pi_subject    => l_subject
	    ,pi_body       => l_body
	    ,po_email_id   => l_email_id
	    );
	end;
	l_email_flag := 0;

    END IF; -- email_rule = 3 (Sec 3 Area Manager Signed)
    --
-- *******************  S4_OPERATOR_ID signed off *******************  
    IF (pi_form_rec_new.EMAIL_CHK = 'Y' and pi_form_rec_new.email_rule = 7)
    THEN
-- Email for Sec 4 Duty Operator Signed
      IF (nvl(pi_form_rec_old.S4_OPERATOR_ID,0) != nvl(pi_form_rec_new.S4_OPERATOR_ID,0))
      THEN
	l_signed_by := getval('NAME', pi_form_rec_new.S4_OPERATOR_ID);
	l_email_to := l_email_to_bldo ||';'||l_created_by_email;

--	l_var_body := 'RSWCF #'||l_form_id||' was signed off for the Duty Operator by '|| l_modified_by ||' for '|| l_signed_by ||chr(10)|| '<br><br>'||
	l_var_body := 'SSRL RSWCF #'||l_form_id||' was signed off for '|| l_signed_by ||', as the Duty Operator.'||chr(10)|| '<br><br>'||
          ' The form is now Work Approved, but not yet Released.'||chr(10)|| '<br><br>'||
	  ' You are no longer required to sign this form.'||chr(10)|| '<br><br>'||
          ' Section 4 - DO Approved.'||chr(10)|| '<br><br>';

	l_body := l_var_body || l_body2;
	l_email_to_final := trim(';' FROM l_email_to);

	l_page_name := 'Sec 4 : DO Signed';
	--
   	begin
		l_email_to_final := trim(';' FROM l_email_to_final);

	    email_form
	    (pi_form_id    => l_form_id
	    ,pi_instance   => l_instance
	    ,pi_page_name  => l_page_name
	    ,pi_email_to   => l_email_to_final
	    ,pi_email_cc   => null
	    ,pi_email_from => null
	    ,pi_subject    => l_subject
	    ,pi_body       => l_body
	    ,po_email_id   => l_email_id
	    );
	end;

      END IF; -- (Sec 4 Duty Operator Signed)
-- Sec 4 Assigned Worker changes
      IF (nvl(pi_form_rec_old.S4_ASSIGN_WRKR_ID,0) != nvl(pi_form_rec_new.S4_ASSIGN_WRKR_ID,0))
      THEN
	l_s4_assign_wrkr_new := getval('NAME',pi_form_rec_new.S4_ASSIGN_WRKR_ID);
	l_email_to_s4_assign_wrkr_new := getval('EMAIL_ID', pi_form_rec_new.S4_ASSIGN_WRKR_ID);
	l_email_to_s4_assign_wrkr_old := getval('EMAIL_ID', pi_form_rec_old.S4_ASSIGN_WRKR_ID);
	l_email_to := l_created_by_email ||';'|| l_email_to_s4_assign_wrkr_new ||';'||l_email_to_s4_assign_wrkr_old;

	l_email_to_final := trim(';' FROM l_email_to);

	l_page_name := 'Sec 4 : Worker Signoff Request';
	l_var_body := ' This work is now assigned to '|| l_s4_assign_wrkr_new || chr(10)|| '<br><br>' ||
          ' Please review and verify with the Duty Operator hazard controls before doing work and signoff SSRL RSWCF #'||l_form_id|| 
	  ', ' ||chr(10)|| '<br><br>'||
          ' which has been pre-approved by RP, SSO, Area Manager and Person Responsible for this form.' ||chr(10)|| '<br><br>'||
          ' Section 4: Worker Assigned.' ||chr(10)|| '<br><br>' ;
	l_body := l_var_body || l_body2;
   	begin
		l_email_to_final := trim(';' FROM l_email_to_final);

	    email_form
	    (pi_form_id    => l_form_id
	    ,pi_instance   => l_instance
	    ,pi_page_name  => l_page_name
	    ,pi_email_to   => l_email_to_final
	    ,pi_email_cc   => null
	    ,pi_email_from => null
	    ,pi_subject    => l_subject
	    ,pi_body       => l_body
	    ,po_email_id   => l_email_id
	    );
	end;
      END IF; -- (Sec 4 Assigned Worker)
      --
      l_email_flag := 0;
      --
    END IF; -- email_rule = 7 (Sec 4 changes)
    --

-- *******************  S6_SSO_ID signed off *******************  
    IF (pi_form_rec_new.EMAIL_CHK = 'Y' and pi_form_rec_new.email_rule = 15)
    THEN

-- Email for Signed Off process
	l_signed_by := getval('NAME', pi_form_rec_new.S6_SSO_ID);
	l_email_to := l_email_to_sso_grp ||';'||l_created_by_email;

--	l_var_body := 'RSWCF #'||l_form_id||' was signed off for SSRL Safety Officer by '|| l_modified_by ||' for '|| l_signed_by ||chr(10)|| '<br><br>'||
	l_var_body := 'SSRL RSWCF #'||l_form_id||' was signed off for '|| l_signed_by ||', as SSRL Safety Officer.'|| chr(10)|| '<br><br>'||
		  'You are no longer required to sign this form.'||chr(10)|| '<br><br>'||
		  'Section 6 - SSO Approved.'||chr(10)|| '<br><br>';

	l_body := l_var_body || l_body2;
	l_email_to_final := trim(';' FROM l_email_to);

	l_page_name := 'Sec 6 : SSO Signed';
   	begin
		l_email_to_final := trim(';' FROM l_email_to_final);

	    email_form
	    (pi_form_id    => l_form_id
	    ,pi_instance   => l_instance
	    ,pi_page_name  => l_page_name
	    ,pi_email_to   => l_email_to_final
	    ,pi_email_cc   => null
	    ,pi_email_from => null
	    ,pi_subject    => l_subject
	    ,pi_body       => l_body
	    ,po_email_id   => l_email_id
	    );
	end;

-- Email for Sign Off Required
	l_email_to := l_email_to_bldo ||';'||l_created_by_email;
	l_email_to_final := trim(';' FROM l_email_to);

	l_var_body := ' As the Duty Operator, Please review and close SSRL RSWCF #'||l_form_id||chr(10)|| '<br><br>' ||
                      ' Section 6: DO Signoff.' ||chr(10)|| '<br><br>' ;

	l_body := l_body1 ||l_var_body || l_body2;
	l_page_name := 'Sec 6: DO Signoff Request';
   	begin
		l_email_to_final := trim(';' FROM l_email_to_final);

	    email_form
	    (pi_form_id    => l_form_id
	    ,pi_instance   => l_instance
	    ,pi_page_name  => l_page_name
	    ,pi_email_to   => l_email_to_final
	    ,pi_email_cc   => null
	    ,pi_email_from => null
	    ,pi_subject    => l_subject
	    ,pi_body       => l_body
	    ,po_email_id   => l_email_id
	    );
	end;
	l_email_flag := 0;

    END IF; -- email_rule = 15 (Sec 6 SSO Signed)
    --
-- *******************  Sec 1/2a/2b/3 any changes  *******************
    IF (pi_form_rec_new.EMAIL_CHK = 'Y' and pi_form_rec_new.email_rule = 6)
    THEN
	l_email_to_s3_rp_old := getval('EMAIL_ID',pi_form_rec_old.S3_RAD_ID);
	l_email_to_s3_sso_old := getval('EMAIL_ID',pi_form_rec_old.S3_SSO_ID);
	l_email_to_s3_am_old := getval('EMAIL_ID',pi_form_rec_old.S3_AREA_MGR_ID);

	l_email_to_s3 := l_email_to_s1_task_person_old ||';'|| l_email_to_s1_task_person_new ||';'|| l_email_to_s3_rp_old ||';'|| l_email_to_s3_sso_old ||';'|| 
	                 l_email_to_s3_am_old ||';'|| l_email_to_s3_rp_new ||';'|| l_email_to_s3_sso_new ||';'|| l_email_to_s3_am_new ;
	l_email_to := l_created_by_email ||';'|| l_email_to_s3 ;


	l_email_to_final := trim(';' FROM l_email_to);

	l_page_name := 'PreWork Approvals Nullified';
	l_var_body := ' PreWork Approvals were Nullified for SSRL RSWCF #'||l_form_id||
	              '. Please review the details again.'|| chr(10)|| '<br><br>';
	l_body := l_body1 ||l_var_body || l_body2;

	l_email_flag := 1;
    END IF; -- email_rule = 6 (Sec 1/2a/2b/3 any changes)
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 5) l_email_flag = '||l_email_flag);
    --
    IF  (l_email_flag = 1)
    THEN
	begin
	l_email_to_final := trim(';' FROM l_email_to_final);
	    email_form
	    (pi_form_id    => l_form_id
	    ,pi_instance   => l_instance
	    ,pi_page_name  => l_page_name
	    ,pi_email_to   => l_email_to_final
	    ,pi_email_cc   => null
	    ,pi_email_from => null
	    ,pi_subject    => l_subject
	    ,pi_body       => l_body
	    ,po_email_id   => l_email_id
	    );
	end;
    END IF; -- email_flag = 1
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ', end');

end  EMAIL_SSRL_RSW_FORM;

procedure email_form
(pi_form_id	in   number
,pi_instance	in   varchar2
,pi_page_name   in   varchar2
,pi_email_to    in   varchar2
,pi_email_cc    in   varchar2
,pi_email_from  in   varchar2
,pi_subject     in   varchar2
,pi_body	in   varchar2
,po_email_id	out  varchar2
)
is
  l_email_to_final	varchar2(1000);
  l_subject		varchar2(500);
  c_proc                 constant varchar2(100) := 'SSRL_RSW_PKG.EMAIL_FORM ';
begin
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'lower(pi_instance)= '|| lower(pi_instance));
  IF lower(pi_instance) != 'slacprod'
  THEN
	l_subject := upper(pi_instance) ||' TESTING ONLY - PLEASE DISREGARD - SSRL RSWCF #'|| pi_form_id;
  ELSE
	l_subject := 'SSRL RSWCF #'|| pi_form_id;
  END IF;
	l_email_to_final := trim(';' FROM pi_email_to);

	apps_util.qm_email_pkg.send_email
	(p_app_name   => 'SSRL_RSWCF'
	,p_page_name  => pi_page_name
	,p_email_from => 'SSRL_RSWCF@slac.stanford.edu'
	,p_email_to   => l_email_to_final ||';'|| 'poonam@slac.stanford.edu'
	,p_email_cc   => null
	,p_email_bcc  => null
	,p_subject    => l_subject 
	,p_body       => pi_body 
	,p_is_html    => 'Y'
	,p_is_active  => 'Y'     -- change this to for Prod - pi_active
	,p_email_id   => po_email_id
	);
exception
	  WHEN OTHERS THEN
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'Error in send_email for pi_page_name= '|| pi_page_name ||', po_email_id= '||po_email_id);
end email_form;

end SSRL_RSW_PKG;

/
