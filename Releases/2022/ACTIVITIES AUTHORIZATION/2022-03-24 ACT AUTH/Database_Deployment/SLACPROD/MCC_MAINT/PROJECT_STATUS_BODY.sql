--------------------------------------------------------
--  File created - Thursday-March-24-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body PROJECT_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MCC_MAINT"."PROJECT_STATUS" 
as

procedure set_project_status
(pi_project_id		in swe_project.id%type
,pi_current_status	in pls_integer
,pi_status_change_flag	in varchar2
,pi_review_flag		in varchar2
,pi_change_source       in varchar2
,pi_close_ticket        in varchar2
,pi_closer_id           in swe_project.closer_id%type
,pi_from_email		in varchar2
,pi_app_id		in pls_integer
,po_status              out pls_integer
)
as
l_minstatus_appr         pls_integer;
l_count_appr             pls_integer;
l_minstatus_review         pls_integer;
l_count_review             pls_integer;
l_minstatus_task         pls_integer;
l_count_task             pls_integer;
l_current_status         pls_integer;
l_status                 pls_integer;
l_proj_reviewed		 varchar2(1);
l_review_flag		 varchar2(1);
l_closer_id              number;
c_proc                      constant varchar2(100) := 'project_status.set_project_status ';

begin
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin ');
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_current_status= '|| pi_current_status || ',pi_project_id= '|| pi_project_id);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_change_source= '|| pi_change_source );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_status_change_flag= '|| pi_status_change_flag );
--
IF (pi_change_source = 'e') and (nvl(pi_review_flag,'N') = 'Y') THEN
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_review_flag= '|| pi_review_flag );
 begin
  update SWE_EMAIL_REVIEW
  set review_flag = 'Y'
  where project_id = pi_project_id;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'Updated the review flag ');
 exception
   WHEN OTHERS THEN
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'Inserting data into SWE_EMAIL_REVIEW');
      insert into SWE_EMAIL_REVIEW (project_id, review_flag)
      values (pi_project_id, 'Y');
 end;
END IF;
--
--
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_review_flag= '|| l_review_flag );

       get_min_appr_status
       (pi_project_id     => pi_project_id
       ,pi_status_change_flag  => pi_status_change_flag
       ,pi_change_source  => pi_change_source
       ,po_minstatus_appr => l_minstatus_appr
       ,po_count_appr     => l_count_appr
       );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_minstatus_appr= '|| l_minstatus_appr || ',l_count_appr= '|| l_count_appr);
        --
       get_min_review_status
       (pi_project_id       => pi_project_id
       ,po_minstatus_review => l_minstatus_review
       ,po_count_review     => l_count_review
       );
       --
       get_min_task_status
       (pi_project_id     => pi_project_id
       ,po_minstatus_task => l_minstatus_task
       ,po_count_task     => l_count_task
       );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_minstatus_task= '|| l_minstatus_task || ',l_count_task= '|| l_count_task);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_proj_reviewed= '|| l_proj_reviewed || ',l_review_flag= '|| l_review_flag);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_close_ticket= '|| pi_close_ticket || ',pi_closer_id= '|| pi_closer_id);

       l_status := get_project_status
                (pi_current_status	   => pi_current_status
		,pi_count_appr             => l_count_appr
		,pi_count_review           => l_count_review
                ,pi_count_task		   => l_count_task
                ,pi_minstatus_appr         => l_minstatus_appr
                ,pi_minstatus_review	   => l_minstatus_review
                ,pi_minstatus_task	   => l_minstatus_task
		,pi_status_change_flag	   => pi_status_change_flag
		,pi_review_flag		   => pi_review_flag
                ,pi_close_ticket           => pi_close_ticket
                ,pi_closer_id              => l_closer_id
                );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_status= '|| l_status );

    if  pi_change_source in ('a','t','e','r')
    and pi_current_status != l_status
    then
        project_status.update_project_status(pi_project_id,l_status, pi_review_flag, pi_status_change_flag);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_status= '|| l_status);
    else
        po_status := l_status;
    end if;

    apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_current_status= '|| pi_current_status);
    apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_status= '|| l_status);
     if pi_current_status != l_status then
	 send_email
	(pi_project_id     => pi_project_id
	,pi_status	   => l_status
	,pi_count_appr     => l_count_appr
	,pi_count_review   => l_count_review
        ,pi_count_task	   => l_count_task
	,pi_from_email	   => pi_from_email
	,pi_app_id	   => pi_app_id
	);
      else
         if (pi_current_status = c_status_closed) and
            (pi_close_ticket = 'Y' and pi_closer_id is NOT NULL) then
		 send_email
		(pi_project_id     => pi_project_id
		,pi_status	   => l_status
		,pi_count_appr     => l_count_appr
		,pi_count_review   => l_count_review
		,pi_count_task	   => l_count_task
		,pi_from_email	   => pi_from_email
		,pi_app_id	   => pi_app_id
		);
	 end if;
      end if;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'po_status= '|| po_status);
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'end' );

end set_project_status;

procedure update_project_status
(pi_project_id        in  pls_integer
,pi_project_status    in  pls_integer
,pi_review_flag	      in varchar2
,pi_status_change_flag  in  varchar2
) as
c_proc                      constant varchar2(100) := 'PROJECT_STATUS.update_project_status ';
begin
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin');
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_project_status= '|| pi_project_status);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_review_flag= '|| pi_review_flag);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_status_change_flag= '|| pi_status_change_flag);

IF nvl(pi_status_change_flag,'N') = 'Y' then
    update swe_project
    set status_id = c_status_proposed
    where id = pi_project_id;
    --
ELSE
    update swe_project
    set status_id = pi_project_status
    where id = pi_project_id;
END IF;

end update_project_status;

procedure get_min_appr_status
(pi_project_id     in  pls_integer
,pi_status_change_flag  in  varchar2
,pi_change_source  in  varchar2
,po_minstatus_appr out pls_integer
,po_count_appr     out pls_integer
) as
        c_proc                 constant varchar2(100) := 'project_status.get_min_appr_status ';
begin
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin');
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_status_change_flag= '|| pi_status_change_flag);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_change_source= '|| pi_change_source);
 IF nvl(pi_status_change_flag,'N') = 'Y' AND
    pi_change_source in ('s','t','r')
 THEN
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'Inside IF');
   begin
      update SWE_PROJECT_CUSTOMER
      set approved = '',
          approved_date = '',
	  approved_by = ''
      where project_id = pi_project_id
      and   approved = 'Y';
   exception
      WHEN NO_DATA_FOUND THEN NULL;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '1) EXCEPTION NO_DATA_FOUND for Approvers');
   end;
   --
   begin
    update SWE_EMAIL_REVIEW
    set review_flag = 'N'
    where project_id = pi_project_id
    and   nvl(review_flag,'N') = 'Y';
   exception
      WHEN NO_DATA_FOUND THEN NULL;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '2) EXCEPTION NO_DATA_FOUND for Approvers');
   end;
   --
   begin
    update swe_project_reviewer
    set reviewed = '',
	reviewed_by = '',
        reviewed_date = ''
    where project_id = pi_project_id
    and   nvl(reviewed,'N') = 'Y';
   exception
      WHEN NO_DATA_FOUND THEN NULL;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '3) EXCEPTION NO_DATA_FOUND for Approvers');
   end;
   --
  END IF;
   --
  begin
    select case to_char(min(nvl(approved,-1)))
           when 'Y' then '1'
           when 'N' then '0'
           else null
           end
    ,count(*)
    into po_minstatus_appr
        ,po_count_appr
    from SWE_PROJECT_CUSTOMER
    where project_id = pi_project_id;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'po_minstatus_appr= '|| po_minstatus_appr);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'po_count_appr= '|| po_count_appr);

  exception
    when no_data_found then
      po_minstatus_appr := 0;
      po_count_appr     := 0;
  end;
--
end get_min_appr_status;

procedure get_min_review_status
(pi_project_id     in  pls_integer
,po_minstatus_review out pls_integer
,po_count_review     out pls_integer
) as
    c_proc                      constant varchar2(100) := 'project_status.get_min_review_status ';
begin
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin');

    select case to_char(min(nvl(reviewed,-1)))
           when 'Y' then '1'
           when 'N' then '0'
           else null
           end
    ,count(*)
    into po_minstatus_review
        ,po_count_review
    from SWE_PROJECT_REVIEWER
    where project_id = pi_project_id;

apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'po_minstatus_review= '|| po_minstatus_review);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'po_count_review= '|| po_count_review);

exception
    when no_data_found then
      po_minstatus_review := 0;
      po_count_review     := 0;
end get_min_review_status;

procedure get_min_task_status
(pi_project_id     in  pls_integer
,po_minstatus_task out pls_integer
,po_count_task     out pls_integer
) as
    c_proc                      constant varchar2(100) := 'project_status.get_min_task_status ';
begin
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin');

    select case to_char(min(nvl(complete_flag,-1)))
           when 'Y' then '1'
           when 'N' then '0'
           else null
           end
    ,count(*)
    into po_minstatus_task
        ,po_count_task
    from SWE_PROJECT_TASK
    where project_id = pi_project_id;

exception
    when no_data_found then
      po_minstatus_task := 0;
      po_count_task     := 0;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'po_minstatus_task= '|| po_minstatus_task);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'po_count_task= '|| po_count_task);
end get_min_task_status;

function project_status_color
(pi_project_status   number
) return varchar2 as
    c_proc                      constant varchar2(100) := 'project_status.project_status_color ';
    l_project_status_color  varchar2(100);

begin
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin');
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_project_status= '|| pi_project_status);
  case pi_project_status
  when 0 then l_project_status_color := 'red';
  when 1 then l_project_status_color := 'orange';
  when 2 then l_project_status_color := 'yellow';
  when 3 then l_project_status_color := 'green';
  when 4 then l_project_status_color := 'black';
  when 5 then l_project_status_color := 'black';
  else        l_project_status_color := 'red';
  end case;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_project_status_color= '|| l_project_status_color);

  return l_project_status_color;

end project_status_color;

function get_project_status
(pi_current_status	   pls_integer
,pi_count_appr             pls_integer
,pi_count_review           pls_integer
,pi_count_task		   pls_integer
,pi_minstatus_appr         pls_integer
,pi_minstatus_review       pls_integer
,pi_minstatus_task	   pls_integer
,pi_status_change_flag     varchar2
,pi_review_flag		   varchar2
,pi_close_ticket           varchar2
,pi_closer_id              swe_project.closer_id%type
) return pls_integer as

    c_proc                      constant varchar2(100) := 'project_status.get_project_status ';
    l_status pls_integer;

begin
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin');
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_current_status= '|| pi_current_status );

if nvl(pi_close_ticket,'N') = 'N' then
 if nvl(pi_status_change_flag,'N') = 'N' then
  if pi_count_review > 0 then
   if pi_minstatus_review > 0 then
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_minstatus_review= '|| pi_minstatus_review );
-- Assuming here that Approvers need to be allocated for the Project to move forward.*****
    if pi_count_appr > 0 then
     if nvl(pi_minstatus_appr,0) > 0 then
-- Assuming here that Tasks need to be setup for the Project to move forward.*****
      if pi_count_task > 0 then
       if pi_minstatus_task > 0 then
        l_status := c_status_review_to_close;
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_status 1 = '|| l_status );
       else
        l_status := c_status_in_progress;
  apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_status 2 = '|| l_status );
       end if;
      else
       l_status := c_status_proposed;
  apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_status 3 = '|| l_status );
      end if;
     else
      l_status := c_status_in_approval;
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_status 4 = '|| l_status );
     end if;
-- Poonam 11/15/2018 - Don't go In Approval if NO APPROVERS exist as yet.
    else
     l_status := c_status_in_review;
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_status 5 = '|| l_status );
    end if;
   else
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_review_flag= '|| pi_review_flag );
    if nvl(pi_review_flag,'N') = 'Y' then
      l_status := c_status_in_review;
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_status 6 = '|| l_status );
    else
      l_status := pi_current_status;
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_status 7 = '|| l_status );
    end if;
   end if;
  else
    l_status := c_status_proposed;
  apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_status 8 = '|| l_status );
  end if;
 elsif nvl(pi_status_change_flag,'N') = 'Y' then
   l_status := c_status_proposed;
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_status 9 = '|| l_status );
 end if;
 --
else
  l_status := c_status_closed;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_status 10 = '|| l_status);

end if;
--
-- Capture any not covered states above
if l_status is NULL then
   l_status := pi_current_status;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_status 11 = '|| l_status );
end if;
 --
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_status 12 = '|| l_status );
return l_status;
end;

procedure send_email
(pi_project_id     in pls_integer
,pi_status	   in pls_integer
,pi_count_appr     in pls_integer
,pi_count_review   in pls_integer
,pi_count_task	   in pls_integer
,pi_from_email     in varchar2
,pi_app_id	   in pls_integer
)
as
  cursor c_approver is
    select GETVAL('EMAIL_ID',person_id) as approver_email
    from swe_project_customer
    where project_id = pi_project_id;
    --
  cursor c_reviewer is
    select GETVAL('EMAIL_ID',person_id) as reviewer_email,
           nvl(reviewed,'N') as reviewed_flag
    from swe_project_reviewer
    where project_id = pi_project_id;
    --
  cursor c_task_person is
    select GETVAL('EMAIL_ID',assigned_to) as task_person_email
    from swe_project_task
    where project_id = pi_project_id;
    --
	l_email_to VARCHAR2(4000) := NULL;
	APPR_NAMES VARCHAR2(1000) := NULL;
	REVIEW_NO_NAMES VARCHAR2(1000) := NULL;
	REVIEWER_NAMES_ALL VARCHAR2(1000) := NULL;
	TASK_PERSON_NAMES VARCHAR2(1000) := NULL;
	SEP VARCHAR2(1) := NULL;
	l_status	varchar2(30);
	l_subject	varchar2(500);
	MSG		VARCHAR2(4000);
	MSG_PART	VARCHAR2(2000);
	MSG_PART1	VARCHAR2(2000);
	MSG_PART2	VARCHAR2(2000);
	DH_MSG_PART	VARCHAR2(2000);
	APPR_MSG_PART	VARCHAR2(2000);
	l_dept_head_email	varchar2(100) := NULL;
	l_project_lead_email	varchar2(100);
	l_requester_email	varchar2(100);
	l_instance		varchar2(100);
	l_url_prefix		varchar2(200);
	l_edit_url              varchar2(1000);
	l_edit_link             varchar2(1000);
        l_email_id		NUMBER;
	l_proj_name		SWE_PROJECT.PROJ_NAME%TYPE;
        c_proc                 constant varchar2(100) := 'project_status.send_email ';
--

begin
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin');
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'pi_status = '|| pi_status );
  --
  l_status := GETVAL('PROJ_STATUS',pi_status);
  l_instance := sys_context('USERENV','INSTANCE_NAME');
  l_url_prefix := 'https://oraweb.slac.stanford.edu/apex/'||lower(l_instance)||'/';
--  l_edit_url := l_url_prefix ||'f?p=207:11:::NO::P11_PROJECT_ID,P11_RT:' || pi_project_id || ',10';
-- Poonam 3/24/2022 - Modified temporarirly as CHECKSUM error for landing on Page 11. So, landing on Reports page instead.
--  l_edit_url := l_url_prefix ||'f?p='||pi_app_id||':11:::NO::P11_PROJECT_ID,P11_RT:' || pi_project_id || ',10';

  l_edit_url := l_url_prefix ||'f?p='||pi_app_id||':10:::NO:::';

  l_edit_link := '<a href="' || l_edit_url || '" target="_blank">' || 'Edit Form' || '</a>';

   MSG_PART1 := 'Please review Work release Form #'|| pi_project_id ||' entered in the online Work Release application. ';
   MSG_PART2 := ' Click on the link below to see the project' || chr(10) || '<br><br>' || l_edit_link;
   --
  l_subject := 'Please Review Work Release Form #'|| pi_project_id;
  SEP := ';';
  l_email_to := 'poonam@slac.stanford.edu' ;

DH_MSG_PART := 'Please review Work Release Form #'|| pi_project_id ||' entered in the online Work Release application for scope, cost, schedule, and resource(s) allocation. '||
                chr(10)||'<br>'||
		'You have been identified as a main resource manager to review scope, cost, schedule, and resource allocation for this work.'||
		chr(10)||'<br>'||
		'Please add appropriate resource manager(s) as an approver.'||chr(10)||'<br><br>'||
		'You may edit fields, send emails from within the application, and enter Review Y/N. ';

APPR_MSG_PART := 'Please approve (Y/N) Work Release Form #'|| pi_project_id ||' entered in the online Work Release application for scope, cost, schedule and resource assignment, as you have been identified as being responsible.'||
                chr(10)||'<br><br>'||
		' These fields have been reviewed by the Dept Head listed. If you have any questions, please use the "Email" button within the application for context.';
--
  IF pi_count_appr > 0 then
    FOR c_approver_rec in c_approver loop
     appr_names := APPR_NAMES || SEP || c_approver_rec.approver_email;
    END LOOP;
  END IF;
  appr_names := trim(both ';' FROM appr_names);
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'appr_names = '|| appr_names );
  --
--  IF pi_count_review > 0 then
    FOR c_reviewer_rec in c_reviewer loop
     IF c_reviewer_rec.reviewed_flag = 'N' THEN
       REVIEW_NO_NAMES := REVIEW_NO_NAMES || SEP || c_reviewer_rec.reviewer_email;
     END IF;
     --
     REVIEWER_NAMES_ALL := REVIEWER_NAMES_ALL || SEP || c_reviewer_rec.reviewer_email;
    END LOOP;
--  END IF;
  REVIEW_NO_NAMES := trim(both ';' FROM REVIEW_NO_NAMES);
  REVIEWER_NAMES_ALL := trim(both ';' FROM REVIEWER_NAMES_ALL);
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'REVIEW_NO_NAMES = '|| REVIEW_NO_NAMES );
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'REVIEWER_NAMES_ALL = '|| REVIEWER_NAMES_ALL );
  --
/* Debbie - No need to email the Task People ************************************
  IF pi_count_task > 0 then
    FOR c_task_person_rec in c_task_person loop
      task_person_names := task_person_names || SEP || c_task_person_rec.task_person_email;
    END LOOP;
  END IF;
  task_person_names := trim(both ';' FROM task_person_names);
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'task_person_names = '|| task_person_names );
*/
  --
   begin
    select GETVAL('EMAIL_ID',requester) as requester_email,
           GETVAL('EMAIL_ID',project_lead) as project_lead_email,
           GETVAL('EMAIL_ID',dept_head) as dept_head_email,
	   proj_name
    into l_requester_email,
         l_project_lead_email,
	 l_dept_head_email,
	 l_proj_name
    from swe_project
    where id = pi_project_id;
   exception
    when NO_DATA_FOUND then
     l_requester_email := '';
     l_project_lead_email := '';
     l_dept_head_email := '';
   end;
  --
  IF pi_status = c_status_proposed then
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '1) pi_status = '|| pi_status );
     l_email_to := l_email_to || SEP || L_REQUESTER_EMAIL || SEP || REVIEWER_NAMES_ALL;
     MSG := MSG_PART1 ||chr(10)||'<br><br>' || MSG_PART2;
  ELSIF pi_status = c_status_in_review then
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '2) pi_status = '|| pi_status );
     l_email_to := l_email_to || SEP || REVIEW_NO_NAMES;
     MSG := DH_MSG_PART ||chr(10)||'<br><br>' || MSG_PART2;
  ELSIF pi_status = c_status_in_approval then
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '3) pi_status = '|| pi_status );
     l_email_to := l_email_to || SEP || APPR_NAMES;
     l_subject := 'Please Approve Work Release Form #'|| pi_project_id;
     MSG := APPR_MSG_PART ||chr(10)||'<br><br>' || MSG_PART2;
  ELSIF pi_status = c_status_in_progress then
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '4) pi_status = '|| pi_status );
     l_email_to := l_email_to || SEP || L_DEPT_HEAD_EMAIL || SEP || REVIEWER_NAMES_ALL || SEP || APPR_NAMES;
     MSG := MSG_PART1 ||chr(10)||'<br><br>' || MSG_PART2;
  ELSIF pi_status = c_status_review_to_close then
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '5) pi_status = '|| pi_status );
     l_email_to := l_email_to || SEP || L_DEPT_HEAD_EMAIL;
     MSG := MSG_PART1 ||chr(10)||'<br><br>' || MSG_PART2;
  ELSIF pi_status = c_status_closed then
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '6) pi_status = '|| pi_status );
     l_email_to := l_email_to || SEP || REVIEWER_NAMES_ALL || SEP || APPR_NAMES;
     MSG := MSG_PART1 ||chr(10)||'<br><br>' || MSG_PART2;
  END IF;
   l_email_to := trim(both ';' from replace(l_email_to,' ',''));
   l_email_to := replace(l_email_to,';;;;',';');
   l_email_to := replace(l_email_to,';;;',';');
   l_email_to := replace(l_email_to,';;',';');
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'AFTER TRIM l_email_to = '|| l_email_to );

   l_subject := l_subject ||' - '|| l_proj_name;
    apps_util.qm_email_pkg.send_email
    (p_app_name   => c_app_name
    ,p_page_name  => null
    ,p_email_from => pi_from_email
    ,p_email_to   => l_email_to
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
end send_email;

end;

/
