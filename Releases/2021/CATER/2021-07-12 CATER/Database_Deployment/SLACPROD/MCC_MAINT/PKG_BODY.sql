--------------------------------------------------------
--  File created - Thursday-June-24-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MCC_MAINT"."PKG" 
as

-- Poonam - 6/24/2021 - Added new fields into view_jn.
-- Poonam Jun 2017 - Modified view_sol_jn and view_job_jn to reflect the right job/soln
--    in the history body. It always said Job 1 or Solution 1, which is confusing.
-- Poonam Jan 2016 - Added new procedures for Job and Solution/Task history.

printvar              varchar2(4000);
break                 varchar2(10) := '<br>';


procedure flush_clob
(p_clob  clob,
    email varchar2 default 'NO')
is
   l_end_position     number;
    l_offset           number;
    l_amount           number default 32000;
    l_length           number;
    i number;

    l_line varchar2(32767);

 begin

    l_length := dbms_lob.getlength(p_clob);
    l_offset := 1;
    while l_offset < l_length loop
       -- Check on doctype declaration in case of html output! And resolve_entities
       -- for this particular line.
       l_amount := 32000;
       dbms_lob.read(p_clob, l_amount, l_offset, l_line);
      if email = 'YES' then
         plsql_mail.send_body(replace(l_line,chr(13)||chr(10),'<br>'));
      else
         htp.prn(replace(l_line,chr(13)||chr(10),'<br>'));
      end if;
       l_offset := l_offset + l_amount;
    end loop;
end flush_clob;


procedure send_notify (to_addr varchar2, to_msg varchar2, to_subject varchar2, prob_id number)is

http_host       varchar2(300);
script_name     varchar2(300);
editurl         varchar2(999) := 'https://' || http_host || script_name || '/f?p=' ||
                 nvl(v('APP_ID'),'194') || ':4:::NO:4:P4_PROB_ID,P4_RP:' || prob_id || ',3';
my_email        varchar2(100) := lower(nvl(v('APP_USER'),user)) || '@slac.stanford.edu';

to_address      varchar2(500);

begin

    begin
        select owa_util.get_cgi_env('HTTP_HOST') into http_host
        from dual;
        exception when others then null;
    end;

    begin
        select owa_util.get_cgi_env('SCRIPT_NAME') into script_name
        from dual;
        exception when others then null;
    end;


    editurl := 'https://' || http_host || script_name || '/f?p=' ||
                 nvl(v('APP_ID'),'194') || ':4:::NO:4:P4_PROB_ID,P4_RP:' || prob_id || ',3';

    to_address := trim(both ';' from replace(to_addr,' ',''));

    to_address := 'jlgordon@slac.stanford.edu';

    begin
      plsql_mail.contact_smtpsrv('oracle.slac.stanford.edu',to_address);
      plsql_mail.send_header('From', my_email);
      plsql_mail.send_header('To', to_address);
      plsql_mail.send_header('Subject',to_subject);
      plsql_mail.send_header('Content-type', 'text/html');
      plsql_mail.send_body(to_msg || break ||
      'Note: The above information is for CATER problem notification.' || break || break ||
      'See: ' || editurl);
      plsql_mail.signoff_smtpsrv;
      exception when others then
         plsql_mail.contact_smtpsrv('oracle.slac.stanford.edu','jlgordon@slac.stanford.edu');
         plsql_mail.send_header('From', 'jlgordon@slac.stanford.edu');
         plsql_mail.send_header('To', 'jlgordon@slac.stanford.edu');
         plsql_mail.send_header('Subject','Error in PKG.send_notify');
         plsql_mail.send_header('Content-type', 'text/html');
         plsql_mail.send_body('Error in PKG.send_notify' || break ||
           'to_addr=' || to_address || break ||
           'to_msg= ' || to_msg     || break ||
           'subject=' || to_subject || break ||
           'prob_id=' || prob_id    || break ||
           sqlerrm);
         plsql_mail.signoff_smtpsrv;
     end;
end;


procedure notifyx(
     p_div_code_id number,
     p_prob_id number,
     p_prob_type_chk varchar2,
     p_shop_id number,
     p_subsystem_id number,
     p_msg varchar2 default null,
     p_descr varchar2 default null)
as
begin

  declare

  msg         varchar2(4000);
  msg2        varchar2(4000);
  cc          number := 0;
  div_code    varchar2(100);
  shop        varchar2(100);
  subsystem   varchar2(100);
  userinfo    varchar2(100) := lower(nvl(v('APP_USER'),user)) || ' (' ||
     to_char(sysdate,'mm/dd/yyyy hh24:mi') || ')';
  subject     varchar2(500);
  --notify_list varchar2(1000) := 'colocho@slac.stanford.edu;ballen@slac.stanford.edu;jlgordon@slac.stanford.edu';
  notify_list varchar2(1000) := 'colocho@slac.stanford.edu;ballen@slac.stanford.edu';
  notify      varchar2(1000) := null;



  cursor getinfo is
  select
     b.notif_id,
     b.shop_id,
     b.notification_method,
     replace(b.email_to,' ','') email_to,
     b.printer1_id,
     b.printer2_id,
     b.email_template,
     b.printtemplate,
     p1.printer p1_printer,
     p2.printer p2_printer
  from
     art_notifications b, art_printers p1, art_printers p2
  where
     ((b.prob_type_chk = p_prob_type_chk
     and b.shop_id = p_shop_id
     and b.shop_id is not null
     and b.subsystem_id is null
     and b.status_ai_chk = 'A'
     and b.div_code_id = p_div_code_id)
     or
     (b.prob_type_chk = p_prob_type_chk
     and b.shop_id = p_shop_id
     and b.shop_id is not null
     and b.subsystem_id = p_subsystem_id
     and b.subsystem_id is not null
     and b.status_ai_chk = 'A'
     and b.div_code_id = p_div_code_id)
     or
     (b.prob_type_chk = p_prob_type_chk
     and b.shop_id is null
     and b.subsystem_id is null
     and b.status_ai_chk = 'A'
     and b.div_code_id = p_div_code_id))
     and b.printer1_id = p1.printer_id(+)
     and b.printer2_id = p2.printer_id(+);

  begin

     --RETURN;   ---- Remove after initial load

     begin
     select div_code into div_code
     from art_division_codes
     where div_code_id = p_div_code_id;
     exception when others then
        div_code := 1;
     end;

     begin
     select shop into shop
     from art_shops
     where shop_id = p_shop_id;
     exception when others then
        shop := '<null>';
     end;

     begin
     select subsystem into subsystem
     from art_subsystems
     where subsystem_id = p_subsystem_id;
     exception when others then
        subsystem := '<null>';
     end;


     if p_msg is not null then
        msg := p_msg || break || break;
     end if;
     msg2 :=  break||
         'User:        ' || userinfo || break ||
         'Prob id:     ' || p_prob_id || break ||
         'Div Code:    ' || div_code || ' (' || p_div_code_id || ')' ||break ||
         'Prob Type:   ' || p_prob_type_chk || break ||
         'Shop:        ' || shop || ' (' || p_shop_id || ')' || break ||
         'Subsystem:   ' || subsystem || ' (' || p_subsystem_id || ')' || break ||
         'Description: ' || p_descr || chr(10) || break;

     subject := 'Cater problem notification';

     for i in getinfo loop

        cc := cc + 1;

        if i.notification_method in (1,2) then
           msg := p_msg || msg2 ||
           'Notif_id:    ' || i.notif_id || break ||
           'Sending to:  ' || i.email_to || break ||
           'Template:    ' || i.email_template || break || break;
           subject := 'Cater problem notification';
           if i.email_to is not null then
              notify := ';' || i.email_to;
           end if;
           send_notify(notify_list || notify, msg, subject, p_prob_id);
        end if;

        if i.notification_method in (0,2) then
           msg := p_msg || msg2 ||
           'Notif_id:    ' || i.notif_id || break ||
           'Printing to: ' || i.p1_printer;
           if i.printer2_id is not null then
              msg := msg ||
              'Printing to: ' || i.p2_printer;
           end if;
           msg := msg || chr(10) ||
           'Template:    ' || i.printtemplate || break|| break;
           subject := 'PRINTER: ' || i.p1_printer || ' ' || i.printtemplate;
           notify := 'remmail@slac.stanford.edu';
           send_notify(notify_list || ';' || notify, msg, subject, p_prob_id);
           if i.printer2_id is not null then
              subject := 'PRINTER: ' || i.p2_printer || ' ' || i.printtemplate;
              send_notify(notify, msg, subject, p_prob_id);
           end if;

        end if;

     end loop;

     if cc = 0 then
        msg := p_msg || msg2 || 'No notification matches found.';
        send_notify(notify_list, msg, subject, p_prob_id);
     end if;



  end;

end notifyx;

procedure printl(
   p_label varchar2,
   p_old varchar2,
   p_new varchar2,
   p_operation varchar2 default 'UPD') is

begin

   if p_operation = 'INS' and p_new is not null then
      htp.p('<tr><td nowrap valign=top>' || p_label || '<td>' || p_new || '</td>');
   elsif p_operation = 'UPD' and nvl(p_old,'(no value)') != nvl(p_new,'(no value)') then
      htp.p('<tr><td nowrap valign=top>' || p_label || '</td><td>' || nvl(p_new,'(no value)') || '</td>');
   else
      null;
   end if;

end;

-- Poonam Jan 2016 - new procedure for Solution/Task history.
procedure view_sol_jn(p_prob_id number, p_sol_id number) is

    c_proc             constant varchar2(100) := 'pkg.view_sol_jn ';

    type solset is table of art_solutions_jn%rowtype;
    solutions solset;

    new number := 1;
    old number := 1;
    sol_no number := 0;
 -- Added by Poonam for label distinction based on PROB_TYPE_CHK for History Page.
   v_prob_type_chk   art_problems.prob_type_chk%type;
   v_problem_label    varchar2(20);
   v_solution_label     varchar2(20);
   v_solver_label        varchar2(20);
   v_solve_hrs_label   varchar2(20);
    i number;

begin
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin ' );
  -- Added by Poonam for label distinction based on PROB_TYPE_CHK for History Page.
  select prob_type_chk into v_prob_type_chk from art_problems
       where prob_id = p_prob_id;

-- Poonam - 7/13/2012 - changing SOFTWARE REQUEST to REQUEST only, as it can mean Hardware or Software type of requests
   if v_prob_type_chk = 'REQUEST' then
       v_problem_label  :=  'Responsible Person' ;
       v_solution_label   := 'Task';
       v_solver_label      := 'Assigned To';
       v_solve_hrs_label := 'Effort (Person Hrs)' ;
   else
       v_problem_label  :=  'Assigned To' ;
       v_solution_label   := 'Solution';
       v_solver_label      := 'Solver';
       v_solve_hrs_label := 'Solve Hrs' ;
  end if;
  --
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '1' );
   select * bulk collect into solutions from art_solutions_jn
     where sol_id = p_sol_id
     order by jn_datetime;

apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '2' );
   htp.p('<title>Cater #' || p_prob_id || ', '|| v_solution_label||' #'|| solutions(new).solution_number || ' history</title>');
   htp.p('<h3>History for Cater #' || p_prob_id || ', '|| v_solution_label||' #'|| solutions(new).solution_number ||'</h3>');
   htp.p('<table>');
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '3' );

--   if solutions.count > 0 then
   for i in solutions.first .. solutions.last
   loop
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '4' );

      htp.p('<tr><td colspan=2>&nbsp;</td>');
      new := i;
      if solutions(i).jn_operation != 'INS' then
         old := i-1;
      else
         old := new;
         sol_no := sol_no + 1;
         htp.p('<tr><td><strong>'||v_solution_label||'  ' || solutions(new).solution_number || ' Created</strong></td><td>(' ||  solutions(i).sol_id || ') ' ||
          to_char(solutions(new).created_date,'mm/dd/yyyy hh24:mi') || ' By ' || lower(solutions(new).created_by)
          || '</td>');
      end if;

      if solutions(new).jn_operation = 'UPD' then
      htp.p('<tr><td><strong>'||v_solution_label||'  ' || solutions(new).solution_number || ' Modified</strong></td><td>(' || solutions(i).sol_id || ') ' ||
          to_char(solutions(new).modified_date,'mm/dd/yyyy hh24:mi') || ' By ' || lower(solutions(new).modified_by)
          || '</td>');
      end if;

      if solutions(new).jn_operation = 'DEL' then
      htp.p('<tr><td><strong>'||v_solution_label||'  ' || solutions(new).solution_number || ' Deleted</strong></td><td>(' || solutions(i).sol_id || ') ' ||
          to_char(sysdate,'mm/dd/yyyy hh24:mi') || ' By ' ||  nvl(v('APP_USER'),user)
          || ',</td>');
      end if;

      printl('Review To Close',getval('YESNO',solutions(old).review_to_close_chk), getval('YESNO',solutions(new).review_to_close_chk),solutions(i).jn_operation);
      printl('Task Title',solutions(old).task_title,solutions(new).task_title,solutions(i).jn_operation);

      printl(v_solver_label,getval('NAME',solutions(old).solvedby_id),getval('NAME',solutions(new).solvedby_id),solutions(i).jn_operation);
      printl(v_solve_hrs_label,solutions(old).solve_hours,solutions(new).solve_hours,solutions(i).jn_operation);
      printl('Task Priority',solutions(old).task_priority_chk,solutions(new).task_priority_chk,solutions(i).jn_operation);
      printl('Task Skill Set',solutions(old).task_skill,solutions(new).task_skill,solutions(i).jn_operation);
      printl('Start Date',to_char(solutions(old).task_start_date,'mm/dd/yyyy'),to_char(solutions(new).task_start_date,'mm/dd/yyyy'),solutions(new).jn_operation);
      printl('End Date',to_char(solutions(old).task_end_date,'mm/dd/yyyy'),to_char(solutions(new).task_end_date,'mm/dd/yyyy'),solutions(new).jn_operation);
      printl('Solution Type',getval('SOL_TYPE',solutions(old).sol_type_id),getval('SOL_TYPE',solutions(new).sol_type_id),solutions(i).jn_operation);
      printl('Module',solutions(old).module,solutions(new).module,solutions(i).jn_operation);
      printl('Old Serial',solutions(old).old_serial_number,solutions(new).old_serial_number,solutions(i).jn_operation);
      printl('New Serial',solutions(old).new_serial_number,solutions(new).new_serial_number,solutions(i).jn_operation);
      printl('Drawing',solutions(old).draw_id,solutions(new).draw_id,solutions(i).jn_operation);
      printl('Doc(Solution)',solutions(old).DOCUMENTATION_SOLUTION,solutions(new).DOCUMENTATION_SOLUTION,solutions(i).jn_operation);
      printl('Subsytem',getval('SUBSYSTEM',solutions(old).subsystem_id),getval('SUBSYSTEM',solutions(new).subsystem_id),solutions(i).jn_operation);
      printl('Shop Main',getval('SHOP',solutions(old).shop_main_id),getval('SHOP',solutions(new).shop_main_id),solutions(i).jn_operation);
      printl('Percent Complete',solutions(old).TASK_PERCENT_COMPLETE,solutions(new).TASK_PERCENT_COMPLETE,solutions(i).jn_operation);
      printl('Description',solutions(old).description, solutions(new).description,solutions(i).jn_operation);
      printl('Feedback Comments',solutions(old).FEEDBACK_COMMENTS, solutions(new).FEEDBACK_COMMENTS,solutions(i).jn_operation);
      printl('Feedback Priority',solutions(old).FEEDBACK_PRIORITY_CHK, solutions(new).FEEDBACK_PRIORITY_CHK,solutions(i).jn_operation);

      end loop;
--      end if;
solutions.delete;
      i := 0;
      htp.p('<tr><td colspan=2>&nbsp;</td>');
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '5' );

   htp.p('</table>');

end;


-- Poonam Jan 2016 - new procedure for Job history.
procedure view_job_jn(p_prob_id number, p_job_id number) is

    c_proc             constant varchar2(100) := 'pkg.view_job_jn ';

    type jobset is table of art_jobs_jn%rowtype;
    jobs jobset;

    cursor get_facilities_famis is
      select *
      from  art_facilities_famis_vw
      where tracking1 = to_char(p_prob_id)
      order by req_id;

    new number := 1;
    old number := 1;
    job_no number := 0;
 -- Added by Poonam for label distinction based on PROB_TYPE_CHK for History Page.
   v_prob_type_chk   art_problems.prob_type_chk%type;
   v_problem_label    varchar2(20);
    i number;

begin
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin' );
   select * bulk collect into jobs from art_jobs_jn
     where job_id = p_job_id
     order by jn_datetime;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '1' );

   htp.p('<title>Cater #' || p_prob_id || ', '||jobs(new).job_type_chk ||' Job #' || jobs(new).job_number|| ' history</title>');
   htp.p('<h3>History for Cater #' || p_prob_id || ', '||jobs(new).job_type_chk ||' Job #'|| jobs(new).job_number|| '</h3>');
   htp.p('<table>');
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '2' );

--   if jobs.count > 0 then
   for i in jobs.first .. jobs.last
   loop
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '3' );

      htp.p('<tr><td colspan=2>&nbsp;</td>');
      new := i;
      if jobs(i).jn_operation != 'INS' then
         old := i-1;
      else
         old := new;
         job_no := job_no + 1;
         htp.p('<tr><td><strong>Job ' || jobs(new).job_number || ' Created</strong></td><td>(' ||  jobs(i).job_id || ') ' ||
          to_char(jobs(new).created_date,'mm/dd/yyyy hh24:mi') || ' By ' || lower(jobs(new).created_by)
          || '</td>');
      end if;

      if jobs(new).jn_operation = 'UPD' then
      htp.p('<tr><td><strong>Job ' || jobs(new).job_number || ' Modified</strong></td><td>(' || jobs(i).job_id || ') ' ||
          to_char(jobs(new).modified_date,'mm/dd/yyyy hh24:mi') || ' By ' || lower(jobs(new).modified_by)
          || '</td>');
      end if;

      if jobs(new).jn_operation = 'DEL' then
      htp.p('<tr><td><strong>Job ' || jobs(new).job_number || ' Deleted</strong></td><td>(' || jobs(i).job_id || ') ' ||
          to_char(sysdate,'mm/dd/yyyy hh24:mi') || ' By ' ||  nvl(v('APP_USER'),user)
          || ',</td>');
      end if;

-- Poonam - 3/8/2012 - Added the new JOB_TYPE_CHK field
      printl('Job Type',jobs(old).job_type_chk,jobs(new).job_type_chk,jobs(new).jn_operation);
      printl ('Status',getval('JOB_STATUS',jobs(old).status_chk),getval('JOB_STATUS',jobs(new).status_chk),jobs(new).jn_operation);
      printl ('Scheduling Priority',getval('PRIORITY',jobs(old).priority_id),getval('PRIORITY',jobs(new).priority_id),jobs(new).jn_operation);
      printl('Job Title',jobs(old).name, jobs(new).name,jobs(new).jn_operation);
      printl('Description',jobs(old).description, jobs(new).description,jobs(new).jn_operation);
      printl('Work Type',getval('WORK_TYPE',jobs(old).work_type_id),getval('WORK_TYPE',jobs(new).work_type_id),jobs(new).jn_operation);
      printl('Area',getval('AREA',jobs(old).area_id), getval('AREA',jobs(new).area_id),jobs(new).jn_operation);
      printl('Subsytem',getval('SUBSYSTEM',jobs(old).subsystem_id),getval('SUBSYSTEM',jobs(new).subsystem_id),jobs(new).jn_operation);
      printl('Shop Main',getval('SHOP',jobs(old).shop_main_id),getval('SHOP',jobs(new).shop_main_id),jobs(new).jn_operation);
      printl('Shop Alt',getval('SHOP',jobs(old).shop_alt_id),getval('SHOP',jobs(new).shop_alt_id),jobs(new).jn_operation);
      printl('Area Manager',getval('AREAMGR',jobs(old).area_id), getval('AREAMGR',jobs(new).area_id),jobs(new).jn_operation);
      printl('HOP',getval('YESNO',jobs(old).hop_chk),getval('YESNO',jobs(new).hop_chk),jobs(new).jn_operation);
      printl('Assigned To',getval('NAME',jobs(old).task_person_id),getval('NAME',jobs(new).task_person_id),jobs(new).jn_operation);
      printl('Planned Start DateTime',to_char(jobs(old).start_time,'mm/dd/yyyy hh24:mi'),to_char(jobs(new).start_time,'mm/dd/yyyy hh24:mi'),jobs(new).jn_operation);
      printl('Planned Stop DateTime',to_char(jobs(old).LATEST_DATE,'mm/dd/yyyy hh24:mi'),to_char(jobs(new).LATEST_DATE,'mm/dd/yyyy hh24:mi'),jobs(new).jn_operation);
      printl('Time Needed',jobs(old).total_time,jobs(new).total_time,jobs(new).jn_operation);
      printl('Time Comment',jobs(old).test_time_needed,jobs(new).test_time_needed,jobs(new).jn_operation);
      printl('Access Req',getval('ACCESS_REQ',jobs(old).access_req_id),getval('ACCESS_REQ',jobs(new).access_req_id),jobs(new).jn_operation);
      printl('PPS Zone',getval('PPSZONE',jobs(old).ppszone_id),getval('PPSZONE',jobs(new).ppszone_id),jobs(new).jn_operation);
      printl('RPFO Survey',getval('YESNO',jobs(old).rpfo_survey_chk),getval('YESNO',jobs(new).rpfo_survey_chk),jobs(new).jn_operation);
      printl('Rad Rem Survey',getval('YESNO',jobs(old).radiation_removal_survey_chk),
              getval('YESNO',jobs(new).radiation_removal_survey_chk),jobs(new).jn_operation);
      printl('Rad Work Permit',getval('YESNO',jobs(old).radiation_work_permit_chk),
              getval('YESNO',jobs(new).radiation_work_permit_chk),jobs(new).jn_operation);
      printl('Elec Sys Work Frm',getval('YESNO',jobs(old).elec_sys_work_ctl_form_chk),
              getval('YESNO',jobs(new).elec_sys_work_ctl_form_chk),jobs(new).jn_operation);
      printl('PPS Int Hazard Checkout',getval('YESNO',jobs(old).PPS_INT_HAZ_CHK),
              getval('YESNO',jobs(new).PPS_INT_HAZ_CHK),jobs(new).jn_operation);
      printl('Lock and Tag',getval('YESNO',jobs(old).lock_and_tag_chk),
              getval('YESNO',jobs(new).lock_and_tag_chk),jobs(new).jn_operation);
      printl('Rad Safety Form',getval('YESNO',jobs(old).radiation_safety_wcf_chk),
              getval('YESNO',jobs(new).radiation_safety_wcf_chk),jobs(new).jn_operation);
      printl('Additional Safety Info',jobs(old).SAFETY_FORM_DESCR,jobs(new).SAFETY_FORM_DESCR,jobs(new).jn_operation);
      printl('Building',getval('BUILDING',jobs(old).building_id),getval('BUILDING',jobs(new).building_id),jobs(new).jn_operation);
      printl('Bldg Mgr',getval('NAME',jobs(old).bldgmgr_id),getval('NAME',jobs(new).bldgmgr_id),jobs(new).jn_operation);
      printl('Asst Bldg Mgr',getval('NAME',jobs(old).asst_bldgmgr_id),getval('NAME',jobs(new).asst_bldgmgr_id),jobs(new).jn_operation);
      printl('Visual Number',jobs(old).VISUAL_NUMBER,jobs(new).VISUAL_NUMBER,jobs(new).jn_operation);
      printl('Task Manager',getval('NAME',jobs(old).TASK_MANAGER),getval('NAME',jobs(new).TASK_MANAGER),jobs(new).jn_operation);
      printl('Review Date',to_char(jobs(old).review_date,'mm/dd/yyyy'),to_char(jobs(new).review_date,'mm/dd/yyyy'),jobs(new).jn_operation);
      printl('Release Conditions Defined',getval('AM_APPROVAL',jobs(old).am_approval_chk),
              getval('AM_APPROVAL',jobs(new).am_approval_chk),jobs(new).jn_operation);
      printl('CD/AM Review Date',to_char(jobs(old).area_mgr_review_date,'mm/dd/yyyy'),to_char(jobs(new).area_mgr_review_date,'mm/dd/yyyy'),jobs(new).jn_operation);
      printl('CD/AM Comments',jobs(old).area_mgr_review_comments,jobs(new).area_mgr_review_comments,jobs(new).jn_operation);
      printl('Date Completed',to_char(jobs(old).date_completed,'mm/dd/yyyy'),to_char(jobs(new).date_completed,'mm/dd/yyyy'),jobs(new).jn_operation);
      printl('Issues',jobs(old).issues,jobs(new).issues,jobs(new).jn_operation);
   IF jobs(new).job_type_chk = 'HARDWARE' then
      printl('Comments',jobs(old).comments,jobs(new).comments,jobs(new).jn_operation);
   END IF;
      printl('Min Hours',jobs(old).minimum_hours,jobs(new).minimum_hours,jobs(new).jn_operation);
      printl('# Persons',jobs(old).number_of_persons,jobs(new).number_of_persons,jobs(new).jn_operation);
      printl('Safety Issues',getval('YESNO',jobs(old).safety_issue_chk),getval('YESNO',jobs(new).safety_issue_chk),jobs(new).jn_operation);
      printl('Person Hours',jobs(old).person_hours,jobs(new).person_hours,jobs(new).jn_operation);
      printl('Toco Time',jobs(old).toco_time,jobs(new).toco_time,jobs(new).jn_operation);
      printl('Ongoing Chk',getval('YESNO',jobs(old).ongoing_chk),getval('YESNO',jobs(new).ongoing_chk),jobs(new).jn_operation);
      printl('Atmos Safety',getval('YESNO',jobs(old).atmospheric_safety_wcf_chk),
              getval('YESNO',jobs(new).atmospheric_safety_wcf_chk),jobs(new).jn_operation);
      printl('Micro',jobs(old).micro,jobs(new).micro,jobs(new).jn_operation);
      printl('Primary',jobs(old).primary,jobs(new).primary,jobs(new).jn_operation);
      printl('Unit',jobs(old).unit,jobs(new).unit,jobs(new).jn_operation);
      printl('Micro Other',jobs(old).micro_other,jobs(new).micro_other,jobs(new).jn_operation);

      printl('Group',getval('GROUP',jobs(old).group_id),getval('GROUP',jobs(new).group_id),jobs(new).jn_operation);
      printl('Beam Requirements',getval('BEAM',jobs(old).requires_beam_chk),getval('BEAM',jobs(new).requires_beam_chk),jobs(new).jn_operation);
      printl('Beam Comment',jobs(old).beam_comment,jobs(new).beam_comment,jobs(new).jn_operation);
      printl('Invasive',getval('YESNO',jobs(old).invasive_chk),getval('YESNO',jobs(new).invasive_chk),jobs(new).jn_operation);
      printl('Invasive Comment',jobs(old).invasive_comment,jobs(new).invasive_comment,jobs(new).jn_operation);
      printl('Systems Affected',jobs(old).systems_affected,jobs(new).systems_affected,jobs(new).jn_operation);
      printl('Dependencies',jobs(old).dependencies,jobs(new).dependencies,jobs(new).jn_operation);
      printl('Risk/Benefit',jobs(old).risk_benefit_descr,jobs(new).risk_benefit_descr,jobs(new).jn_operation);
      printl('Systems Required',jobs(old).systems_required,jobs(new).systems_required,jobs(new).jn_operation);
      printl('Test Plan',jobs(old).test_plan,jobs(new).test_plan,jobs(new).jn_operation);
      printl('Backout Plan',jobs(old).backout_plan,jobs(new).backout_plan,jobs(new).jn_operation);
   IF jobs(new).job_type_chk != 'HARDWARE' then
      printl('Followup Comments',jobs(old).comments,jobs(new).comments,jobs(new).jn_operation);
   END IF;
      printl('Feedback Comments',jobs(old).FEEDBACK_COMMENTS, jobs(new).FEEDBACK_COMMENTS,jobs(new).jn_operation);
      printl('Feedback Priority',jobs(old).FEEDBACK_PRIORITY_CHK, jobs(new).FEEDBACK_PRIORITY_CHK,jobs(new).jn_operation);
      printl('Division',getval('DIV_CODE',jobs(old).div_code_id),getval('DIV_CODE',jobs(new).div_code_id),jobs(new).jn_operation);


   end loop;
--   end if;
jobs.delete;
      i := 0;
      htp.p('<tr><td colspan=2>&nbsp;</td>');
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '4' );

   htp.p('</table>');

end;


procedure view_jn(p_prob_id number) is


    type probset is table of art_problems_jn%rowtype;
    problems probset;

    type jobset is table of art_jobs_jn%rowtype;
    jobs jobset;

    type solset is table of art_solutions_jn%rowtype;
    solutions solset;

    cursor get_facilities_famis is
      select *
      from  art_facilities_famis_vw
      where tracking1 = to_char(p_prob_id)
      order by req_id;

    new number := 1;
    old number := 1;
    job_no number := 0;
    sol_no number := 0;
 -- Added by Poonam for label distinction based on PROB_TYPE_CHK for History Page.
   v_prob_type_chk   art_problems.prob_type_chk%type;
   v_problem_label    varchar2(20);
   v_solution_label     varchar2(20);
   v_solver_label        varchar2(20);
   v_solve_hrs_label   varchar2(20);
    i number;

begin
  -- Added by Poonam for label distinction based on PROB_TYPE_CHK for History Page.
  select prob_type_chk into v_prob_type_chk from art_problems
       where prob_id = p_prob_id;

-- Poonam - 7/13/2012 - changing SOFTWARE REQUEST to REQUEST only, as it can mean Hardware or Software type of requests
   if v_prob_type_chk = 'REQUEST' then
       v_problem_label  :=  'Responsible Person' ;
       v_solution_label   := 'Task';
       v_solver_label      := 'Assigned To';
       v_solve_hrs_label := 'Effort (Person Hrs)' ;
   else
       v_problem_label  :=  'Assigned To' ;
       v_solution_label   := 'Solution';
       v_solver_label      := 'Solver';
       v_solve_hrs_label := 'Solve Hrs' ;
  end if;
  --
   select * bulk collect into problems from art_problems_jn
     where prob_id = p_prob_id
     order by jn_datetime;

   htp.p('<title>Cater #' || problems(new).prob_id || ' history</title>');
--   htp.p('<h3>History for '||v_problem_label||' #' || problems(new).prob_id || '</h3>'); -- Poonam 3/8/12
   htp.p('<h3>History for Cater #' || problems(new).prob_id || '</h3>');
   htp.p('<table>');

   for i in problems.first .. problems.last
   loop
      new := i;
      if problems(i).jn_operation != 'INS' then
         old := i-1;
         htp.p('<tr><td colspan=2>&nbsp;</td>');
      else
         htp.p('<tr><td><strong>Created</strong></td><td>' ||
          to_char(problems(new).created_date,'mm/dd/yyyy hh24:mi') || ' By ' || lower(problems(new).created_by)
          || '</td>');
      end if;

      if problems(new).jn_operation = 'UPD' then
      htp.p('<tr><td><strong>Modified</strong></td><td>' ||
          to_char(problems(new).modified_date,'mm/dd/yyyy hh24:mi') || ' By ' || lower(problems(new).modified_by)
          || '</td>');
      end if;

      if problems(new).jn_operation = 'DEL' then
      htp.p('<tr><td><strong>Deleted</strong></td><td>' ||
          to_char(sysdate,'mm/dd/yyyy hh24:mi') || ' By ' ||  nvl(v('APP_USER'),user)
          || ',</td>');
      end if;

      printl('CATER ID',initcap(problems(old).prob_id),initcap(problems(new).prob_id),problems(new).jn_operation);
      printl('Cater Type',initcap(problems(old).prob_type_chk),initcap(problems(new).prob_type_chk),problems(new).jn_operation);
      printl('Status',getval('PROB_STATUS',problems(old).status_chk),
          getval('PROB_STATUS',problems(new).status_chk),problems(new).jn_operation);
      printl('Description',problems(old).description, problems(new).description,problems(new).jn_operation);
      printl('Area',getval('AREA',problems(old).area_id), getval('AREA',problems(new).area_id),problems(new).jn_operation);
      printl('Area Mgr',getval('NAME',problems(old).areamgr_id),getval('NAME',problems(new).areamgr_id),problems(new).jn_operation);
      printl('Subsytem',getval('SUBSYSTEM',problems(old).subsystem_id),getval('SUBSYSTEM',problems(new).subsystem_id),problems(new).jn_operation);
      printl(v_problem_label,getval('NAME',problems(old).assignedto_id),getval('NAME',problems(new).assignedto_id),problems(new).jn_operation);
      printl('WBS Description',getval('PROJECT',problems(old).project_id),getval('PROJECT',problems(new).project_id),problems(new).jn_operation);
      printl('Group',getval('GROUP',problems(old).group_id),getval('GROUP',problems(new).group_id),problems(new).jn_operation);
      printl('Request Type',getval('REQUEST_TYPE',problems(old).sw_request_type),getval('REQUEST_TYPE',problems(new).sw_request_type),problems(new).jn_operation);
      printl('Customer Priority',problems(old).priority_chk,problems(new).priority_chk,problems(new).jn_operation);
      printl('Customer Need Date',to_char(problems(old).due_date,'mm/dd/yyyy'), to_char(problems(new).due_date,'mm/dd/yyyy'),problems(new).jn_operation);
-- Poonam - 6/24/2021 - Added the new fields into the History.
      printl('Related Cater ID',problems(old).related_prob_id,problems(new).related_prob_id,problems(new).jn_operation);
      printl('PA Number',problems(old).pa_number,problems(new).pa_number,problems(new).jn_operation);

      -- Hardware
-- Poonam - 3/8/2012 - This check is not needed as the display is only where there are values or changed values.
--      if NVL(problems(new).PROB_TYPE_CHK,problems(old).PROB_TYPE_CHK) = 'HARDWARE' Then
      printl('Shop Main',getval('SHOP',problems(old).shop_main_id),getval('SHOP',problems(new).shop_main_id),problems(new).jn_operation);
      printl('Shop Alt',getval('SHOP',problems(old).shop_alt_id),getval('SHOP',problems(new).shop_alt_id),problems(new).jn_operation);
      printl('Micro',problems(old).micro,problems(new).micro,problems(new).jn_operation);
      printl('Primary',problems(old).primary,problems(new).primary,problems(new).jn_operation);
      printl('Unit',problems(old).unit,problems(new).unit,problems(new).jn_operation);
      printl('PV Name',problems(old).pv_name,problems(new).pv_name,problems(new).jn_operation);
      printl('Urgency',problems(old).urgency,problems(new).urgency,problems(new).jn_operation);
      printl('Review Date',to_char(problems(old).review_date,'mm/dd/yyyy'),to_char(problems(new).review_date,'mm/dd/yyyy'),problems(new).jn_operation);
      printl('HOP',getval('YESNO',problems(old).hop_chk),getval('YESNO',problems(new).hop_chk),problems(new).jn_operation);
      printl('Watch&Wait Date',to_char(problems(old).watch_and_wait_date,'mm/dd/yyyy'),
         to_char(problems(new).watch_and_wait_date,'mm/dd/yyyy'),problems(new).jn_operation);
      printl('Watch&Wait Comm',problems(old).watch_and_wait_comment,problems(new).watch_and_wait_comment,problems(new).jn_operation);
      printl('Due Next',to_char(problems(old).date_due_next,'mm/dd/yyyy'), to_char(problems(new).date_due_next,'mm/dd/yyyy'),problems(new).jn_operation);
      printl('CEF Req Submit',getval('YESNO',problems(old).cef_request_submitted_chk),
          getval('YESNO',problems(new).cef_request_submitted_chk),problems(new).jn_operation);
      printl('CEF Track#',problems(old).cef_tracking_no,problems(new).cef_tracking_no,problems(new).jn_operation);
      printl('Building',getval('BUILDING',problems(old).building_id),getval('BUILDING',problems(new).building_id),problems(new).jn_operation);
      printl('Bldg Mgr',getval('NAME',problems(old).bldgmgr_id),getval('NAME',problems(new).bldgmgr_id),problems(new).jn_operation);
      printl('Asst B Mgr',getval('NAME',problems(old).asst_bldgmgr_id),getval('NAME',problems(new).asst_bldgmgr_id),problems(new).jn_operation);
--      else
      -- Software
      printl('Display',problems(old).display,problems(new).display,problems(new).jn_operation);
      printl('Facility',getval('FACILITY',problems(old).facility_id),getval('FACILITY',problems(new).facility_id),problems(new).jn_operation);
      printl('Term Type',problems(old).terminal_type,problems(new).terminal_type,problems(new).jn_operation);
      printl('Reproducible',getval('YESNO',problems(old).reproducible_chk),getval('YESNO',problems(new).reproducible_chk),problems(new).jn_operation);
      printl('Error Msg',problems(old).error_message,problems(new).error_message,problems(new).jn_operation);
--      end if;

      printl('Date Closed',to_char(problems(old).date_closed,'mm/dd/yyyy hh24:mi'),
              to_char(problems(new).date_closed,'mm/dd/yyyy hh24:mi'),problems(new).jn_operation);
      printl('Closer',getval('NAME',problems(old).closer_id),getval('NAME',problems(new).closer_id),problems(new).jn_operation);


   end loop;

problems.delete;

   select * bulk collect into jobs from art_jobs_jn
     where prob_id = p_prob_id
     order by job_id, jn_datetime;

   if jobs.count > 0 then
   for i in jobs.first .. jobs.last
   loop

      htp.p('<tr><td colspan=2>&nbsp;</td>');
      new := i;
      if jobs(i).jn_operation != 'INS' then
         old := i-1;
      else
         old := new;
         job_no := job_no + 1;
         htp.p('<tr><td><strong>Job ' || job_no || ' Created</strong></td><td>(' ||  jobs(i).job_id || ') ' ||
          to_char(jobs(new).created_date,'mm/dd/yyyy hh24:mi') || ' By ' || lower(jobs(new).created_by)
          || '</td>');
      end if;

      if jobs(new).jn_operation = 'UPD' then
      htp.p('<tr><td><strong>Job ' || job_no || ' Modified</strong></td><td>(' || jobs(i).job_id || ') ' ||
          to_char(jobs(new).modified_date,'mm/dd/yyyy hh24:mi') || ' By ' || lower(jobs(new).modified_by)
          || '</td>');
      end if;

      if jobs(new).jn_operation = 'DEL' then
      htp.p('<tr><td><strong>Job ' || job_no || ' Deleted</strong></td><td>(' || jobs(i).job_id || ') ' ||
          to_char(sysdate,'mm/dd/yyyy hh24:mi') || ' By ' ||  nvl(v('APP_USER'),user)
          || ',</td>');
      end if;

-- Poonam - 3/8/2012 - Added the new JOB_TYPE_CHK field
      printl('Job Type',jobs(old).job_type_chk,jobs(new).job_type_chk,jobs(new).jn_operation);
      printl ('Status',getval('JOB_STATUS',jobs(old).status_chk),getval('JOB_STATUS',jobs(new).status_chk),jobs(new).jn_operation);
      printl ('Scheduling Priority',getval('PRIORITY',jobs(old).priority_id),getval('PRIORITY',jobs(new).priority_id),jobs(new).jn_operation);
      printl('Job Title',jobs(old).name, jobs(new).name,jobs(new).jn_operation);
      printl('Description',jobs(old).description, jobs(new).description,jobs(new).jn_operation);
      printl('Work Type',getval('WORK_TYPE',jobs(old).work_type_id),getval('WORK_TYPE',jobs(new).work_type_id),jobs(new).jn_operation);
      printl('Area',getval('AREA',jobs(old).area_id), getval('AREA',jobs(new).area_id),jobs(new).jn_operation);
      printl('Subsytem',getval('SUBSYSTEM',jobs(old).subsystem_id),getval('SUBSYSTEM',jobs(new).subsystem_id),jobs(new).jn_operation);
      printl('Shop Main',getval('SHOP',jobs(old).shop_main_id),getval('SHOP',jobs(new).shop_main_id),jobs(new).jn_operation);
      printl('Shop Alt',getval('SHOP',jobs(old).shop_alt_id),getval('SHOP',jobs(new).shop_alt_id),jobs(new).jn_operation);
      printl('Area Manager',getval('AREAMGR',jobs(old).area_id), getval('AREAMGR',jobs(new).area_id),jobs(new).jn_operation);
      printl('HOP',getval('YESNO',jobs(old).hop_chk),getval('YESNO',jobs(new).hop_chk),jobs(new).jn_operation);
      printl('Task Person',getval('NAME',jobs(old).task_person_id),getval('NAME',jobs(new).task_person_id),jobs(new).jn_operation);
      printl('Start DateTime',to_char(jobs(old).start_time,'mm/dd/yyyy hh24:mi'),to_char(jobs(new).start_time,'mm/dd/yyyy hh24:mi'),jobs(new).jn_operation);
      printl('Total Time',jobs(old).total_time,jobs(new).total_time,jobs(new).jn_operation);
      printl('Time Comment',jobs(old).test_time_needed,jobs(new).test_time_needed,jobs(new).jn_operation);
      printl('Access Req',getval('ACCESS_REQ',jobs(old).access_req_id),getval('ACCESS_REQ',jobs(new).access_req_id),jobs(new).jn_operation);
      printl('PPS Zone',getval('PPSZONE',jobs(old).ppszone_id),getval('PPSZONE',jobs(new).ppszone_id),jobs(new).jn_operation);
      printl('RPFO Survey',getval('YESNO',jobs(old).rpfo_survey_chk),getval('YESNO',jobs(new).rpfo_survey_chk),jobs(new).jn_operation);
      printl('Rad Rem Survey',getval('YESNO',jobs(old).radiation_removal_survey_chk),
              getval('YESNO',jobs(new).radiation_removal_survey_chk),jobs(new).jn_operation);
      printl('Rad Work Permit',getval('YESNO',jobs(old).radiation_work_permit_chk),
              getval('YESNO',jobs(new).radiation_work_permit_chk),jobs(new).jn_operation);
      printl('Elec Sys Work Frm',getval('YESNO',jobs(old).elec_sys_work_ctl_form_chk),
              getval('YESNO',jobs(new).elec_sys_work_ctl_form_chk),jobs(new).jn_operation);
      printl('Lock and Tag',getval('YESNO',jobs(old).lock_and_tag_chk),
              getval('YESNO',jobs(new).lock_and_tag_chk),jobs(new).jn_operation);
      printl('Rad Safety Form',getval('YESNO',jobs(old).radiation_safety_wcf_chk),
              getval('YESNO',jobs(new).radiation_safety_wcf_chk),jobs(new).jn_operation);
      printl('Building',getval('BUILDING',jobs(old).building_id),getval('BUILDING',jobs(new).building_id),jobs(new).jn_operation);
      printl('Bldg Mgr',getval('NAME',jobs(old).bldgmgr_id),getval('NAME',jobs(new).bldgmgr_id),jobs(new).jn_operation);
      printl('Asst Bldg Mgr',getval('NAME',jobs(old).asst_bldgmgr_id),getval('NAME',jobs(new).asst_bldgmgr_id),jobs(new).jn_operation);
      printl('Review Date',to_char(jobs(old).review_date,'mm/dd/yyyy'),to_char(jobs(new).review_date,'mm/dd/yyyy'),jobs(new).jn_operation);
      printl('Release Conditions Defined',getval('AM_APPROVAL',jobs(old).am_approval_chk),
              getval('AM_APPROVAL',jobs(new).am_approval_chk),jobs(new).jn_operation);
      printl('CD/AM Review Date',to_char(jobs(old).area_mgr_review_date,'mm/dd/yyyy'),to_char(jobs(new).area_mgr_review_date,'mm/dd/yyyy'),jobs(new).jn_operation);
      printl('CD/AM Comments',jobs(old).area_mgr_review_comments,jobs(new).area_mgr_review_comments,jobs(new).jn_operation);
      printl('Date Completed',to_char(jobs(old).date_completed,'mm/dd/yyyy'),to_char(jobs(new).date_completed,'mm/dd/yyyy'),jobs(new).jn_operation);
      printl('Issues',jobs(old).issues,jobs(new).issues,jobs(new).jn_operation);
   if v_prob_type_chk = 'HARDWARE' then
      printl('Comments',jobs(old).comments,jobs(new).comments,jobs(new).jn_operation);
   end if;
      printl('Min Hours',jobs(old).minimum_hours,jobs(new).minimum_hours,jobs(new).jn_operation);
      printl('# Persons',jobs(old).number_of_persons,jobs(new).number_of_persons,jobs(new).jn_operation);
      printl('Safety Issues',getval('YESNO',jobs(old).safety_issue_chk),getval('YESNO',jobs(new).safety_issue_chk),jobs(new).jn_operation);
      printl('Person Hours',jobs(old).person_hours,jobs(new).person_hours,jobs(new).jn_operation);
      printl('Toco Time',jobs(old).toco_time,jobs(new).toco_time,jobs(new).jn_operation);
      printl('Ongoing Chk',getval('YESNO',jobs(old).ongoing_chk),getval('YESNO',jobs(new).ongoing_chk),jobs(new).jn_operation);
      printl('Atmos Safety',getval('YESNO',jobs(old).atmospheric_safety_wcf_chk),
              getval('YESNO',jobs(new).atmospheric_safety_wcf_chk),jobs(new).jn_operation);
      printl('Micro',jobs(old).micro,jobs(new).micro,jobs(new).jn_operation);
      printl('Primary',jobs(old).primary,jobs(new).primary,jobs(new).jn_operation);
      printl('Unit',jobs(old).unit,jobs(new).unit,jobs(new).jn_operation);
      printl('Micro Other',jobs(old).micro_other,jobs(new).micro_other,jobs(new).jn_operation);

      printl('Group',getval('GROUP',jobs(old).group_id),getval('GROUP',jobs(new).group_id),jobs(new).jn_operation);
      printl('Beam Requirements',getval('BEAM',jobs(old).requires_beam_chk),getval('BEAM',jobs(new).requires_beam_chk),jobs(new).jn_operation);
      printl('Beam Comment',jobs(old).beam_comment,jobs(new).beam_comment,jobs(new).jn_operation);
      printl('Invasive',getval('YESNO',jobs(old).invasive_chk),getval('YESNO',jobs(new).invasive_chk),jobs(new).jn_operation);
      printl('Invasive Comment',jobs(old).invasive_comment,jobs(new).invasive_comment,jobs(new).jn_operation);
      printl('Systems Affected',jobs(old).systems_affected,jobs(new).systems_affected,jobs(new).jn_operation);
      printl('Dependencies',jobs(old).dependencies,jobs(new).dependencies,jobs(new).jn_operation);
      printl('Risk/Benefit',jobs(old).risk_benefit_descr,jobs(new).risk_benefit_descr,jobs(new).jn_operation);
      printl('Systems Required',jobs(old).systems_required,jobs(new).systems_required,jobs(new).jn_operation);
      printl('Test Plan',jobs(old).test_plan,jobs(new).test_plan,jobs(new).jn_operation);
      printl('Backout Plan',jobs(old).backout_plan,jobs(new).backout_plan,jobs(new).jn_operation);
   if v_prob_type_chk != 'HARDWARE' then
      printl('Followup Comments',jobs(old).comments,jobs(new).comments,jobs(new).jn_operation);
   end if;
      printl('Division',getval('DIV_CODE',jobs(old).div_code_id),getval('DIV_CODE',jobs(new).div_code_id),jobs(new).jn_operation);


   end loop;
   end if;
jobs.delete;

   select * bulk collect into solutions from art_solutions_jn
     where prob_id = p_prob_id
     order by sol_id, jn_datetime;

   if solutions.count > 0 then
   for i in solutions.first .. solutions.last
   loop

      htp.p('<tr><td colspan=2>&nbsp;</td>');
      new := i;
      if solutions(i).jn_operation != 'INS' then
         old := i-1;
      else
         old := new;
         sol_no := sol_no + 1;
         htp.p('<tr><td><strong>'||v_solution_label||'  ' || sol_no || ' Created</strong></td><td>(' ||  solutions(i).sol_id || ') ' ||
          to_char(solutions(new).created_date,'mm/dd/yyyy hh24:mi') || ' By ' || lower(solutions(new).created_by)
          || '</td>');
      end if;

      if solutions(new).jn_operation = 'UPD' then
      htp.p('<tr><td><strong>'||v_solution_label||'  ' || sol_no || ' Modified</strong></td><td>(' || solutions(i).sol_id || ') ' ||
          to_char(solutions(new).modified_date,'mm/dd/yyyy hh24:mi') || ' By ' || lower(solutions(new).modified_by)
          || '</td>');
      end if;

      if solutions(new).jn_operation = 'DEL' then
      htp.p('<tr><td><strong>'||v_solution_label||'  ' || sol_no || ' Deleted</strong></td><td>(' || solutions(i).sol_id || ') ' ||
          to_char(sysdate,'mm/dd/yyyy hh24:mi') || ' By ' ||  nvl(v('APP_USER'),user)
          || ',</td>');
      end if;

      printl('Review To Close',getval('YESNO',solutions(old).review_to_close_chk), getval('YESNO',solutions(new).review_to_close_chk),solutions(i).jn_operation);
      printl('Task Title',solutions(old).task_title,solutions(new).task_title,solutions(i).jn_operation);

      printl(v_solver_label,getval('NAME',solutions(old).solvedby_id),getval('NAME',solutions(new).solvedby_id),solutions(i).jn_operation);
--      printl('Solver',GETVAL('NAME',solutions(old).SOLVEDBY_ID),GETVAL('NAME',solutions(new).SOLVEDBY_ID),solutions(i).jn_operation);
       printl(v_solve_hrs_label,solutions(old).solve_hours,solutions(new).solve_hours,solutions(i).jn_operation);
--     printl('Solve Hrs',solutions(old).SOLVE_HOURS,solutions(new).SOLVE_HOURS,solutions(i).jn_operation);
      printl('Task Priority',solutions(old).task_priority_chk,solutions(new).task_priority_chk,solutions(i).jn_operation);
      printl('Task Skill Set',solutions(old).task_skill,solutions(new).task_skill,solutions(i).jn_operation);
      printl('Start Date',to_char(solutions(old).task_start_date,'mm/dd/yyyy'),to_char(solutions(new).task_start_date,'mm/dd/yyyy'),solutions(new).jn_operation);
      printl('End Date',to_char(solutions(old).task_end_date,'mm/dd/yyyy'),to_char(solutions(new).task_end_date,'mm/dd/yyyy'),solutions(new).jn_operation);
      printl('Solution Type',getval('SOL_TYPE',solutions(old).sol_type_id),getval('SOL_TYPE',solutions(new).sol_type_id),solutions(i).jn_operation);
      printl('Module',solutions(old).module,solutions(new).module,solutions(i).jn_operation);
      printl('Old Serial',solutions(old).old_serial_number,solutions(new).old_serial_number,solutions(i).jn_operation);
      printl('New Serial',solutions(old).new_serial_number,solutions(new).new_serial_number,solutions(i).jn_operation);
      printl('Description',solutions(old).description, solutions(new).description,solutions(i).jn_operation);

      end loop;
      end if;
solutions.delete;

      i := 0;
      htp.p('<tr><td colspan=2>&nbsp;</td>');
      for c2 in get_facilities_famis loop

         i := i + 1;
         htp.p('<tr><td><strong>Facilities FAMIS Information ' || i || ' (Current)' || '</td>');

         printl('Description',null, c2.description);
         printl('SR Number', null, c2.sr_number);
         printl('Status',null,c2.wo_status);
         printl('Requestor',null,c2.requestor);
         printl('Telephone',null,c2.telephone);
         printl('Req Date',null,c2.req_date);
         printl('Req Type',null,c2.req_type);
         printl('Priority',null,c2.priority);
         printl('Crew',null,c2.crew);
         printl('Building',null,c2.building);
         printl('tracking1',null,c2.tracking1);
         printl('Start Time',null,c2.start_date);
         printl('Due Date',null,c2.due_date);
         printl('Complete Date',null,c2.complete_date);
         printl('Created',null,to_char(c2.enter_date,'mm/dd/yyyy') || ' By ' ||
            lower(c2.enter_user));

      end loop;

   htp.p('</table>');

end;


procedure print (
    p_prob_id number,
    email varchar2 default 'NO')
as

begin

declare

    c_start_page    constant number := 104;
    c_return_page   constant number := 1;

    http_host       varchar2(300) := owa_util.get_cgi_env('HTTP_HOST');
    script_name     varchar2(300) := owa_util.get_cgi_env('SCRIPT_NAME');
    editurl         varchar2(999) := 'https://' || http_host || script_name || '/f?p=' ||
                    nvl(v('APP_ID'),'194') || ':4:::NO:4:P4_PROB_ID,P4_RP:' || 'xx' || ',3';
    my_email        varchar2(100) := lower(nvl(v('APP_USER'),user)) || '@slac.stanford.edu';
    instance        varchar2(10);

    l_editurl       varchar2(1000) := 'https://' || http_host || script_name ||'/f?p=194:101:::::P101_FIRST_PAGE,P101_PROB_ID,P101_RP:'||c_start_page||','||p_prob_id||','||c_return_page;
    l_read_only_url varchar2(1000) := 'https://' || http_host || script_name ||'/f?p=249:104:::::P104_PROB_ID,P104_RP:'||p_prob_id||','||c_return_page;

   i number;

   cursor get_problems is
   select * from art_problems_vw
   where
      prob_id = p_prob_id;

   cursor get_solutions is
      select
         *
      from
         art_solutions_vw
      where
         prob_id = p_prob_id
      order by sol_id;


   cursor get_jobs is
      select
         *
      from
         art_jobs_vw
      where
         prob_id = p_prob_id
      order by job_id;

   cursor get_facilities_famis is
      select
         *
      from
         art_facilities_famis_vw
      where
         tracking1 = to_char(p_prob_id)
      order by req_id;

   procedure writeline(line varchar2) is
   begin
      if email = 'YES' then
         plsql_mail.send_body(line);
      else
         htp.p(line);
      end if;
   end;

   procedure show(label varchar2, value varchar2, top varchar2 default null) is
   begin
      if top is not null then
         if v('APP_USER') is not null then
            writeline('<tr><td colspan=2>&' || 'nbsp;</td></tr>' ||
            '<tr><td colspan=2 valign="bottom" class="t3RegionHeader">' || top || '</td></tr>');
         else
            writeline('<tr><td colspan=2>&' || 'nbsp;</td></tr>' ||
            '<tr><td colspan=2 valign="bottom"><b>' || top || '</b></td></tr>');
         end if;
      end if;
      if label is not null then
         writeline('<tr><td colspan=2><b>' || label || '</b></td></tr>');
      end if;
      if value is not null then
         writeline('<tr><td colspan=2><table border=1 cellspacing=0 cellpadding=4><tr><td>');
         writeline(value);
         writeline('</td></tr>');
         writeline('</table>');
      end if;

   end;

   procedure writeclob(description clob, label varchar2 default 'Description') is
   begin
      --writeline('<tr><td><b>' || label || '</b></td></tr>');
      writeline('<tr><td colspan=2><table border=1 cellspacing=0 cellpadding=4><tr><td>');
      flush_clob(description,email);
      writeline('</td></tr></table>');
      writeline('</td></tr>');
   end;

   procedure write2(label1 varchar2, val1 varchar2) is
   begin
       if val1 is not null then
       writeline('<tr><td width="20%"><b>' || label1 || ':</b></td><td>' || val1 ||'&' || 'nbsp;</td></tr>');
       end if;
   end;

begin

   begin
        select owa_util.get_cgi_env('HTTP_HOST') into http_host
        from dual;
        exception when others then null;
    end;

    begin
        select owa_util.get_cgi_env('SCRIPT_NAME') into script_name
        from dual;
        exception when others then null;
    end;

   printvar := null;

   for c0 in get_problems loop
--   Also, no need for the IF condition, as APP_USER ="nobody" and not NULL when run in Read-only mode.
          writeline('<title>Cater #' || p_prob_id || '</title>');
          --editurl := 'https://' || http_host || script_name || '/f?p=' ||
                    --nvl(v('APP_ID'),'194') || ':101:::NO:4:P4_PROB_ID,P4_RP:' || p_prob_id || ',3';
          editurl := '<a href="' || l_editurl || '"><br>Go to CATER</a>';
          writeline('<title>CATER ' || p_prob_id || '</title>');
          writeline(editurl);

/* Poonam - 12/12/2011 - Removed old code as no need for hard-coding.
                         Below logic does not take care of any other DB like SLACSTG.
      if v('APP_USER') is null then
          writeline('<title>Cater #' || p_prob_id || '</title>');
          instance := 'slacprod';
          if instr(upper(script_name),'SLACDEV')>0 then
             instance := 'slacdev';
          end if;
          editURL := 'https://' || http_host || '/apex/' || instance || '/f?p=' ||
                    NVL(V('APP_ID'),'194') || ':4:::NO:4:P4_PROB_ID,P4_RP:' || p_prob_id || ',3';

          editURL := '<a href="' || editURL || '">Go to Cater</a>';
          writeline('<title>Cater ' || p_prob_id || '</title>');
          writeline(editURL);
      end if;
*/
--
      writeline('<table border=0 width="75%" align=left>');

-- Poonam - 12/12/2011 - Added different title for Software Requests
-- Poonam - 7/13/2012 - changing SOFTWARE REQUEST to REQUEST only, as it can mean Hardware or Software type of requests
      if upper(c0.prob_type) = 'REQUEST' then
         show(null,null,'Hardware/Software Request '||p_prob_id);
      else
         show(null,null,'Problem '||p_prob_id || ' (' || c0.prob_type || ')  [' ||
          to_char(c0.created_date,'mm/dd/yyyy hh24:mi') || ']');
      end if;
      --
      writeclob(c0.description);

-- Poonam - 12/12/2011 - New fields for Software Requests
-- Poonam - 7/13/2012 - changing SOFTWARE REQUEST to REQUEST only, as it can mean Hardware or Software type of requests
  if upper(c0.prob_type) = 'REQUEST' then
     write2('Request Title',c0.problem_title);
     write2('WBS Description',c0.project_name);
     write2('Group Name',c0.group_name);
  end if;
--
     write2('Problem Type',c0.prob_type);
         write2('Status',c0.status);
         write2('Area',c0.area);
         write2('Area Manager',c0.areamgr);
         write2('Subsystem',c0.subsystem);
         write2('Assigned To',c0.assignedto);

-- Poonam - 7/20/2012 - Write all fields that have a value.
--      if c0.prob_type = 'HARDWARE' Then
         write2('Shop Main',c0.shop_main);
         write2('Shop Alt',c0.shop_alt);
         write2('Micro',c0.micro);
         write2('Primary',c0.primary);
         write2('Unit',c0.unit);
         write2('PV name',c0.pv_name);
         write2('Urgency',c0.urgency);
         write2('Review Date',c0.review_date);
         write2('HOP',c0.hop);
         write2('Watch&Wait Date',to_char(c0.watch_and_wait_date,'mm/dd/yyyy'));
         write2('Watch&Wait Comm',c0.watch_and_wait_comment);
         write2('Due Next',to_char(c0.date_due_next,'mm/dd/yyyy'));
         write2('CEF Track#',c0.cef_tracking_no);
         write2('Building',c0.building_no);
         write2('Bldg_mgr',c0.bldgmgr);
         write2('Asst B Mgr',c0.asst_bldgmgr);
--      Else
         write2('Display',c0.display);
         write2('Facility',c0.facility);
         write2('Terminal Type',c0.terminal_type);
         write2('Reproducible',c0.reproducible);
         write2('Error Message',c0.error_message);
--      End if;

         write2('Created',to_char(c0.created_date,'mm/dd/yyyy hh24:mi') || ' By ' ||
            lower(c0.created_by));
         if c0.modified_date is not null then
         write2('Modified',to_char(c0.modified_date,'mm/dd/yyyy hh24:mi') || ' By ' ||
            lower(c0.modified_by));
         end if;


      i := 0;
      for c1 in get_solutions loop
        i := i + 1;
-- Poonam - 12/12/2011 - Added new logic for SOFTWARE REQUEST
-- Poonam - 7/13/2012 - changing SOFTWARE REQUEST to REQUEST only, as it can mean Hardware or Software type of requests
      if upper(c0.prob_type) = 'REQUEST' then
         show(null,null,'Task ' || i );

         write2('Task Title',c1.task_title);
         writeclob(c1.description);
--         write2('Review to Close',c1.review_to_close);
         write2('Assigned To',c1.solvedby);
         write2('Effort Hrs',c1.solve_hours);
         write2('Subsystem',c1.task_subsystem);
         write2('Shop Main',c1.task_shop_main);
     else
         show(null,null,'Solution ' || i || '  [' ||
            to_char(c1.created_date,'mm/dd/yyyy hh24:mi') || ']');
         writeclob(c1.description);
--         write2('Review to Close',c1.review_to_close);
         write2('Solver',c1.solvedby);
         write2('Solution Type',c1.sol_type);
         write2('Solve Hrs',c1.solve_hours);
         write2('Module',c1.module);
         write2('Old Serial',c1.old_serial_number);
         write2('New Serial',c1.new_serial_number);
      end if;
     write2('Task Priority',c1.task_priority_chk);
     write2('Task Skill Set',c1.task_skill);
     write2('Start Date',c1.task_start_date);
     write2('End Date',c1.task_end_date);
     write2('Percent Complete',c1.task_percent_complete);
     write2('Review to Close',c1.review_to_close);
         write2('Created',to_char(c1.created_date,'mm/dd/yyyy hh24:mi') || ' By ' ||
            lower(c1.created_by));
         if c1.modified_date is not null then
            write2('Modified',to_char(c1.modified_date,'mm/dd/yyyy hh24:mi') || ' By ' ||
                   lower(c1.modified_by));
         end if;

      end loop;
      if i = 0 then
-- Poonam - 12/12/2011 - Added new logic for SOFTWARE REQUEST
-- Poonam - 7/13/2012 - changing SOFTWARE REQUEST to REQUEST only, as it can mean Hardware or Software type of requests
        if upper(c0.prob_type) = 'REQUEST' then
           show(null,null,'No Tasks');
    else
           show(null,null,'No Solutions');
    end if;
      end if;

      i := 0;
      for c1 in get_jobs loop
         i := i + 1;
         show(null,null,'Job ' || i || '  [Created On: ' ||
            to_char(c1.created_date,'mm/dd/yyyy hh24:mi') || ']');
         writeclob(c1.description);
         write2('Status',c1.status);
         write2('Priority',c1.priority);
         write2('Work Type',c1.work_type);
         write2('Area',c1.area);
         write2('Subsystem',c1.subsystem);
         write2('Shop main',c1.shop_main);
         write2('Shop alt',c1.shop_alt);
         write2('Area Mgr',c1.area_manager);
         write2('HOP',c1.hop_chk);
         write2('Task Person',c1.task_person);
         write2('Total Time',c1.total_time);
         write2('Access Req',c1.access_req);
         write2('PPS Zone',c1.ppszone);
         write2('RFPO Survey',c1.radiation_removal_survey_chk);
         write2('Rad Rem Survey',c1.radiation_removal_survey_chk);
         write2('Elec sys Work Frm',c1.radiation_work_permit_chk);
         write2('Lock and Tag',c1.lock_and_tag_chk);
         write2('Rad Safety Form',c1.rad_safety_work_ctl_form_chk);
         write2('Building',c1.building_no);
         write2('Bldg Mgr',c1.bldgmgr);
         write2('Asst B Mgr',c1.asst_bldgmgr);
         write2('Release Conditions Defined',c1.am_approval_chk);
         write2('Review Date',to_char(c1.review_date,'mm/dd/yyyy'));
         write2('Issues',c1.issues);
         write2('Comments',c1.comments);
         write2('Min Hours',c1.minimum_hours);
         write2('# Persons',c1.number_of_persons);
         write2('Safety Issues',c1.safety_issue_chk);
         write2('Person Hours',c1.person_hours);
         write2('Toco Time',c1.toco_time);
         write2('Ongoing Chk',c1.ongoing_chk);
         write2('Start Time',c1.start_time);
         write2('Atmos Safety',c1.atmospheric_safety_wcf_chk);
         write2('Created',to_char(c1.created_date,'mm/dd/yyyy hh24:mi') || ' By ' ||
            lower(c1.created_by));
         if c1.modified_date is not null then
            write2('Modified',to_char(c1.modified_date,'mm/dd/yyyy hh24:mi') || ' By ' ||
            lower(c1.modified_by));
         end if;

      end loop;
      if i = 0 then
         show(null,null,'No Jobs');
      end if;

      i := 0;

      for c2 in get_facilities_famis loop

         i := i + 1;
         show(null,null,'Facilities FAMIS ' || i || '  [' ||
            to_char(c2.enter_date,'mm/dd/yyyy') || ']');
         writeclob(c2.description);
         write2('SR Number',c2.sr_number);
         write2('Status',c2.wo_status);
         write2('Requestor',c2.requestor);
         write2('Telephone',c2.telephone);
         write2('Req Date',c2.req_date);
         write2('Req Type',c2.req_type);
         write2('Priority',c2.priority);
         write2('Crew',c2.crew);
         write2('Building',c2.building);
         write2('tracking1',c2.tracking1);
         write2('Start Time',c2.start_date);
         write2('Due Date',c2.due_date);
         write2('Complete Date',c2.complete_date);
         write2('Created',to_char(c2.enter_date,'mm/dd/yyyy') || ' By ' ||
            lower(c2.enter_user));

         if c2.modify_date is not null then
            write2('Modified',to_char(c2.modify_date,'mm/dd/yyyy') || ' By ' ||
            lower(c2.modify_user));
         end if;

      end loop;

      if i = 0 then
         show(null,null,'No Facilities FAMIS Information');
      end if;

      writeline('</table>');
   end loop;

end;


end print;

---------------

function format_msg (p_msg in varchar2, p_html_flag in varchar2) return varchar2
is
  v_proc      varchar2(100);
  v_errmsg    varchar2(300);
  v_flag      varchar2(1);
  v_ret       varchar2(32767);
begin

  v_proc := 'PKG.FORMAT_MSG';

  v_flag := substr(upper(trim(p_html_flag)),1,1);

  if ( (v_flag is null) or (v_flag not in ('N','Y')) ) then
    v_flag := 'N';
  end if;

  if ( v_flag = 'N' ) then
    v_ret := substr(p_msg,1,32767);
  elsif ( v_flag = 'Y' ) then
    v_ret := substr('<table bgcolor=black cellpadding=1>'
                    || '<tr><td><font color=yellow>'
                    || p_msg
                    || '</font></td></tr></table>', 1, 32767);
  end if;

  return v_ret;

exception
  when others then
    v_errmsg := substr('ERROR: '||v_proc||': '||sqlerrm,1,300);
    raise_application_error(-20200, v_errmsg);
end format_msg;

---------------

procedure test_status
is

new_prob_id number := 100001;
new_sol_id number := 100001;
new_job_id number := 100001;
new_job_id2 number := 100002;
status varchar2(100);
step_num number := 0;

procedure show_status(step number, msg varchar2, id varchar2, status1 varchar2)
is

ss varchar2(100);

begin

   begin
   select status_chk into ss from art_problems
   where prob_id = new_prob_id;
   exception when others then
      ss := null;
   end;

   step_num := step_num + 1;

   insert into art_status_check values(step_num,
      msg,
      id,
      status1,
      ss);

end;


procedure clear_records
is

begin

   begin
      delete from art_jobs where prob_id = new_prob_id;
      exception when others then
         null;
   end;

   begin
      delete from art_solutions where prob_id = new_prob_id;
      exception when others then
         null;
   end;

   begin
      delete from art_problems where prob_id = new_prob_id;
      exception when others then
         null;
   end;

end clear_records;


begin


   clear_records;

   commit;

   delete from art_status_check;
   show_status(0, 'Starting ' || to_char(sysdate,'mm/dd/yy hh24:mi') || ' user=' || nvl(v('APP_USER'),user),null, null);

--------- Case 1

   -- Create Hardware Problem
   insert into art_problems (prob_id, prob_type_chk, created_by, created_date)
     values(new_prob_id, 'HARDWARE', 'STATUS_CHECK', sysdate);
   show_status(1, '<b>1A - Create Hardware Problem</b>',new_prob_id,'0');
   commit;

   -- Add solution 1 RTC=Yes
   insert into art_solutions (sol_id, prob_id, review_to_close_chk, created_by, created_date)
     values(new_sol_id, new_prob_id, 'Y', 'STATUS_CHECK',sysdate);
   show_status(2, '1B - Add solution 1 RTC=Yes',new_sol_id,'3');

   -- Close problem
   update art_problems set status_chk = 4, closer_id = 17604
     where prob_id = new_prob_id;
   show_status(3, '1C - Close problem',new_prob_id,'4');

   clear_records;

--------- Case 2

   -- Create Hardware Problem
   insert into art_problems (prob_id, prob_type_chk, created_by, created_date)
     values(new_prob_id, 'HARDWARE', 'STATUS_CHECK', sysdate);
   show_status(21, '<b>2A - Create Hardware Problem</b>',new_prob_id,'0');
   commit;

   -- Add solution 1 RTC=No
   insert into art_solutions (sol_id, prob_id, review_to_close_chk, created_by, created_date)
     values(new_sol_id, new_prob_id, 'N', 'STATUS_CHECK',sysdate);
   show_status(22, '2B - Add solution 1 RTC=No',new_sol_id,'1');

   -- Modify solution 1 RTC=YEs
   update art_solutions set review_to_close_chk = 'Y'
      where sol_id = new_sol_id;
 --  show_status(23, '2C - Modify solution 1 RTC=Yes',new_sol_id,'3');

   -- Close problem
   update art_problems set status_chk = 4, closer_id = 17604
     where prob_id = new_prob_id;
   show_status(24, '2D - Close problem',new_prob_id,'4');


   clear_records;

/*  ??????????????? Check with Jim if he commented out this code ?????????????????????
--------- Case 3

   -- Create Hardware Problem
   insert into art_problems (prob_id, prob_type_chk, created_by, created_date)
     values(new_prob_id, 'HARDWARE', 'STATUS_CHECK', sysdate);
   show_status(31, '<b>3A - Create Hardware Problem</b>',new_prob_id,'0');
   commit;

   -- Modify problem description
   update art_problems set description = 'test'
      where prob_id = new_prob_id;
   show_status(33, '3B - Modify problem description',new_prob_id,'0');

   -- Enter Watch & Wait Date and Comment
   update art_problems set watch_and_wait_date = sysdate,
      watch_and_wait_comment = 'test comment'
      where prob_id = new_prob_id;
   show_status(34, '3C - Enter Watch & Wait Date and Comment',new_prob_id,'1');

   -- Remove Watch & Wait Date and Comment
   update art_problems set watch_and_wait_date = null,
      watch_and_wait_comment = null
      where prob_id = new_prob_id;
   show_status(35, '3D - Remove Watch & Wait Date and Comment',new_prob_id,'0');

   -- Add assignee
   update art_problems set assignedto_id = 17604
      where prob_id = new_prob_id;
   show_status(36, '3E - Modify problem, add assignee',new_prob_id,'1');

   -- Remove assignee
   update art_problems set assignedto_id = null
      where prob_id = new_prob_id;
   show_status(37, '3F - Modify probem, remove assignee',new_prob_id,'0');

   -- Enter Watch & Wait Date and Comment
   update art_problems set watch_and_wait_date = sysdate,
      watch_and_wait_comment = 'test comment'
      where prob_id = new_prob_id;
   show_status(38, '3G - Enter Watch & Wait Date and Comment',new_prob_id,'1');

   -- Add assignee
   update art_problems set assignedto_id = 17604
      where prob_id = new_prob_id;
   show_status(39, '3H - Modify problem, add assignee',new_prob_id,'1');

   -- Remove Watch & Wait Date and Comment
   update art_problems set watch_and_wait_date = null,
      watch_and_wait_comment = null
      where prob_id = new_prob_id;
   show_status(40, '3I - Remove Watch & Wait Date and Comment',new_prob_id,'1');

   -- Remove assignee
   update art_problems set assignedto_id = null
      where prob_id = new_prob_id;
   show_status(41, '3J - Modify probem, remove assignee',new_prob_id,'0');

   -- Remove assignee
   update art_problems set assignedto_id = 17604
      where prob_id = new_prob_id;
   show_status(37, '3K - Modify probem, add assignee',new_prob_id,'1');

   -- Enter Watch & Wait Date and Comment
   update art_problems set watch_and_wait_date = sysdate,
      watch_and_wait_comment = 'test comment'
      where prob_id = new_prob_id;
   show_status(38, '3L - Enter Watch & Wait Date and Comment',new_prob_id,'1');

   -- Remove assignee
   update art_problems set assignedto_id = null
      where prob_id = new_prob_id;
   show_status(37, '3M - Modify probem, remove assignee',new_prob_id,'1');

  -- Remove Watch & Wait Date and Comment
   update art_problems set watch_and_wait_date = null,
      watch_and_wait_comment = null
      where prob_id = new_prob_id;
   show_status(40, '3N - Remove Watch & Wait Date and Comment',new_prob_id,'0');

   -- Add solution 1 RTC=No
   insert into art_solutions (sol_id, prob_id, review_to_close_chk, created_by, created_date)
     values(new_sol_id, new_prob_id, 'N', 'STATUS_CHECK',sysdate);
   show_status(22, '3O - Add solution 1 RTC=No',new_sol_id,'1');

   -- Modify solution 1 RTC=YEs
   update art_solutions set review_to_close_chk = 'Y'
      where sol_id = new_sol_id;
   show_status(23, '3P - Modify solution 1 RTC=Yes',new_sol_id,'3');

   -- Enter Watch & Wait Date and Comment
   update art_problems set watch_and_wait_date = sysdate,
      watch_and_wait_comment = 'test comment'
      where prob_id = new_prob_id;
   show_status(38, '3Q - Enter Watch & Wait Date and Comment',new_prob_id,'3');

    -- Remove Watch & Wait Date and Comment
   update art_problems set watch_and_wait_date = null,
      watch_and_wait_comment = null
      where prob_id = new_prob_id;
   show_status(40, '3R - Remove Watch & Wait Date and Comment',new_prob_id,'3');

   -- Close problem
   update art_problems set status_chk = 4, closer_id = 17604
     where prob_id = new_prob_id;
   show_status(24, '3S - Close problem',new_prob_id,'4');


   CLEAR_RECORDS;

--------- Case 4

   -- Create Hardware Problem
   insert into art_problems (prob_id, prob_type_chk, created_by, created_date)
     values(new_prob_id, 'HARDWARE', 'STATUS_CHECK', sysdate);
   show_status(31, '<b>4A - Create Hardware Problem</b>',new_prob_id,'0');
   commit;

   insert into art_jobs (job_id, prob_id, created_by, created_date)
     values(new_job_id, new_prob_id, 'STATUS_CHECK',sysdate);
   show_status(220, '4B - Add job 1',new_prob_id,'2');

  update art_jobs set status_chk = 1
     where job_id = new_job_id;
   show_status(120, '4C - Complete Job 1',new_prob_id,'3');

   -- Close problem
   update art_problems set status_chk = 4, closer_id = 17604
     where prob_id = new_prob_id;
   show_status(24, '4D - Close problem',new_prob_id,'4');


   CLEAR_RECORDS;


--------- Case 5

   -- Create Hardware Problem
   insert into art_problems (prob_id, prob_type_chk, created_by, created_date)
     values(new_prob_id, 'HARDWARE', 'STATUS_CHECK', sysdate);
   show_status(31, '<b>5A - Create Hardware Problem</b>',new_prob_id,'0');
   commit;

   insert into art_jobs (job_id, prob_id, created_by, created_date)
     values(new_job_id, new_prob_id, 'STATUS_CHECK',sysdate);
   show_status(220, '5B - Add job 1',new_job_id,'2');

  update art_jobs set status_chk = 2
     where job_id = new_job_id;
   show_status(120, '5C - Drop Job 1',new_job_id,'3');

   -- Close problem
   update art_problems set status_chk = 4, closer_id = 17604
     where prob_id = new_prob_id;
   show_status(24, '5D - Close problem',new_prob_id,'4');


   CLEAR_RECORDS;

--------- Case 6

   -- Create Hardware Problem
   insert into art_problems (prob_id, prob_type_chk, created_by, created_date)
     values(new_prob_id, 'HARDWARE', 'STATUS_CHECK', sysdate);
   show_status(31, '<b>6A - Create Hardware Problem</b>',new_prob_id,'0');
   commit;

   insert into art_jobs (job_id, prob_id, created_by, created_date)
     values(new_job_id, new_prob_id, 'STATUS_CHECK',sysdate);
   show_status(220, '6B - Add job 1',new_prob_id,'2');

  update art_jobs set status_chk = 1
     where job_id = new_job_id;
   show_status(120, '6C - Complete Job 1',new_prob_id,'3');

   -- Add solution 1 RTC=No
   insert into art_solutions (sol_id, prob_id, review_to_close_chk, created_by, created_date)
     values(new_sol_id, new_prob_id, 'N', 'STATUS_CHECK',sysdate);
   show_status(22, '6D - Add solution 1 RTC=No',new_sol_id,'1');

   -- Modify solution 1 add description
   update art_solutions set description = 'test'
      where sol_id = new_sol_id;
   show_status(23, '6E - Modify solution 1 modify description',new_sol_id,'1');

   -- Enter Watch & Wait Date and Comment
   update art_problems set watch_and_wait_date = sysdate,
      watch_and_wait_comment = 'test comment'
      where prob_id = new_prob_id;
   show_status(38, '6F - Enter Watch & Wait Date and Comment',new_prob_id,'1');

   -- Add job 2
   insert into art_jobs (job_id, prob_id, created_by, created_date)
     values(new_job_id+1, new_prob_id, 'STATUS_CHECK',sysdate);
   show_status(220, '6G - Add job 2',new_job_id+1,'2');

   -- Modify solution 1 RTC=YEs
   update art_solutions set review_to_close_chk = 'Y'
      where sol_id = new_sol_id;
   show_status(23, '6H - Modify solution 1 RTC=Yes',new_sol_id,'2');

   -- Enter Watch & Wait Date and Comment
   update art_problems set watch_and_wait_date = sysdate,
      watch_and_wait_comment = 'test comment'
      where prob_id = new_prob_id;
   show_status(38, '6I - Enter Watch & Wait Date and Comment',new_prob_id,'2');

   -- Complete job 2
   update art_jobs set status_chk = 1
     where job_id = new_job_id+1;
   show_status(120, '6J - Complete Job 2',new_job_id+1,'3');

   -- Close problem
   update art_problems set status_chk = 4, closer_id = 17604
     where prob_id = new_prob_id;
   show_status(24, '6K - Close problem',new_prob_id,'4');


   CLEAR_RECORDS;

--------- Case 7

   -- Create Hardware Problem
   insert into art_problems (prob_id, prob_type_chk, created_by, created_date)
     values(new_prob_id, 'HARDWARE', 'STATUS_CHECK', sysdate);
   show_status(31, '<b>7A - Create Hardware Problem</b>',new_prob_id,'0');
   commit;

   insert into art_jobs (job_id, prob_id, created_by, created_date)
     values(new_job_id, new_prob_id, 'STATUS_CHECK',sysdate);
   show_status(220, '7B - Add job 1',new_prob_id,'2');

   -- Add solution 1 RTC=No
   insert into art_solutions (sol_id, prob_id, review_to_close_chk, created_by, created_date)
     values(new_sol_id, new_prob_id, 'N', 'STATUS_CHECK',sysdate);
   show_status(22, '7C - Add solution 1 RTC=No',new_sol_id,'2');

   -- Modify solution 1 add description
   update art_solutions set description = 'test'
      where sol_id = new_sol_id;
   show_status(23, '7D - Modify solution 1 modify description',new_sol_id,'2');

  -- Modify solution 1 RTC=YEs
   update art_solutions set review_to_close_chk = 'Y'
      where sol_id = new_sol_id;
   show_status(23, '7E - Modify solution 1 RTC=Yes',new_sol_id,'2');

   -- Add solution 2 RTC=No
   insert into art_solutions (sol_id, prob_id, review_to_close_chk, created_by, created_date)
     values(new_sol_id+1, new_prob_id, 'N', 'STATUS_CHECK',sysdate);
   show_status(22, '7F - Add solution 2 RTC=No',new_sol_id+1,'2');

   -- Add job 2
   insert into art_jobs (job_id, prob_id, created_by, created_date)
     values(new_job_id+1, new_prob_id, 'STATUS_CHECK',sysdate);
   show_status(220, '7G - Add job 2',new_job_id+1,'2');

   -- Modify job 2 problem description
   update art_jobs set description = 'test'
     where job_id = new_job_id+1;
   show_status(120, '7H - Modify Job 2 description',new_job_id+1,'2');

  -- Complete job 2
   update art_jobs set status_chk = 1
     where job_id = new_job_id+1;
   show_status(120, '7I - Complete Job 2',new_job_id+1,'2');

   -- Add job 3
   insert into art_jobs (job_id, prob_id, created_by, created_date)
     values(new_job_id+2, new_prob_id, 'STATUS_CHECK',sysdate);
   show_status(220, '7J - Add job 3',new_job_id+2,'2');

   -- Modify job 3 problem description
   update art_jobs set description = 'test'
     where job_id = new_job_id+2;
   show_status(120, '7K - Modify Job 3 description',new_job_id+2,'2');

  -- Complete job 3
   update art_jobs set status_chk = 2
     where job_id = new_job_id+2;
   show_status(120, '7L - Complete Job 2',new_job_id+2,'2');

  -- Complete job 1
   update art_jobs set status_chk = 1
     where job_id = new_job_id;
   show_status(120, '7M - Complete Job 1',new_job_id,'1');

  -- Modify solution 2 RTC=YEs
   update art_solutions set review_to_close_chk = 'Y'
      where sol_id = new_sol_id+1;
   show_status(23, '7N - Modify solution 2 RTC=Yes',new_sol_id+1,'3');

   -- Add job 4
   insert into art_jobs (job_id, prob_id, created_by, created_date)
     values(new_job_id+3, new_prob_id, 'STATUS_CHECK',sysdate);
   show_status(220, '7O - Add job 2',new_job_id+3,'2');

  -- Complete job 4
   update art_jobs set status_chk = 1
     where job_id = new_job_id+3;
   show_status(120, '7P - Complete Job 4',new_job_id+3,'3');

   -- Close problem
   update art_problems set status_chk = 4, closer_id = 17604
     where prob_id = new_prob_id;
   show_status(24, '7Q - Close problem',new_prob_id,'4');

   CLEAR_RECORDS;
*/

end test_status;


procedure email_problem
(p_prob_id in number
,p_to      in varchar2
,p_from    in varchar2
,p_subject in varchar2
,p_comment in varchar2
) is

begin

   begin
     plsql_mail.contact_smtpsrv('oracle.slac.stanford.edu',p_to);
     plsql_mail.send_header('From', p_from);
     plsql_mail.send_header('To', p_to);
     plsql_mail.send_header('Subject',p_subject);
     plsql_mail.send_header('Content-type', 'text/html');

     plsql_mail.send_body(replace(p_comment,chr(13)||chr(10),'<br>'));
-- Poonam - 12/12/2011 - Replaced below code with above line to put a line feed.
--     plsql_mail.send_body(p_comment || chr(10) || chr(10));
--
     print(p_prob_id, 'YES');
     plsql_mail.signoff_smtpsrv;
     /*
     EXCEPTION WHEN OTHERS THEN
        plsql_mail.contact_smtpsrv('oracle.slac.stanford.edu','jlgordon@slac.stanford.edu');
        plsql_mail.send_header('From', 'crane@slac.stanford.edu');
        plsql_mail.send_header('To', 'crane@slac.stanford.edu');
        plsql_mail.send_header('Subject','Error in PKG.send_notify');
        plsql_mail.send_body('Error in PKG.send_notify' || chr(10) ||
           'to_addr=' || p_to || chr(10) ||
           'to_msg=' || p_comment || chr(10) ||
           'subject=' || p_subject || chr(10) ||
           'prob_id=' || p_prob_id || chr(10) ||
           SQLERRM);
        plsql_mail.signoff_smtpsrv;
     */
   end;

end email_problem;


procedure email_job(
   p_job_id in number,
   p_sol_id in number,
   p_prob_id in number,
   p_prob_type_chk in varchar2,
   p_to in varchar2,
   p_from in varchar2,
   p_subject in varchar2,
   p_comment in varchar2)
is

http_host       varchar2(300);
script_name     varchar2(300);
readurl         varchar2(999) := 'https://' || http_host || script_name || '/f?p= 249:4:::NO:4:P4_PROB_ID,P4_RP:' || p_prob_id || ',3';
editurl         varchar2(999) := 'https://' || http_host || script_name || '/f?p=' ||
                 nvl(v('APP_ID'),'194') || ':4:::NO:4:P4_PROB_ID,P4_RP:' || p_prob_id || ',3';
my_email        varchar2(100) := lower(nvl(v('APP_USER'),user)) || '@slac.stanford.edu';
instance        varchar2(10);

begin
-- Poonam - 12/12/2011 - New procedure for Emailing from Job and Solution pages of Cater App.
--    This was done, because "email_problem" proc  is very specific to a PROB_ID and modifying it
--    could break something else that might be using it outside of CATER.

    begin
        select owa_util.get_cgi_env('HTTP_HOST') into http_host
        from dual;
        exception when others then null;
    end;

    begin
        select owa_util.get_cgi_env('SCRIPT_NAME') into script_name
        from dual;
        exception when others then null;
    end;

   begin
     plsql_mail.contact_smtpsrv('oracle.slac.stanford.edu',p_to);
     plsql_mail.send_header('From', p_from);
     plsql_mail.send_header('To', p_to);
     plsql_mail.send_header('Subject',p_subject);
     plsql_mail.send_header('Content-type', 'text/html');

     plsql_mail.send_body(replace(p_comment,chr(13)||chr(10),'<br>'));

--     plsql_mail.send_body('<title>Cater #' || p_prob_id || '</title>');

     if p_job_id is not null then
       if nvl(p_prob_type_chk,'HARDWARE') = 'HARDWARE' then
      readurl := 'https://' || http_host || script_name || '/f?p= 249:18:::NO:18:P18_JOB_ID,P18_PROB_TYPE_CHK,P18_RP:' || p_job_id ||','||p_prob_type_chk|| ',3';
          readurl := '<a href="' || readurl || '">Read-Only Cater Job</br></a>';
          plsql_mail.send_body(readurl);
          plsql_mail.send_body('<table border=0 width="75%" align=left>');
      --
      editurl := 'https://' || http_host || script_name || '/f?p=' ||
                    nvl(v('APP_ID'),'194') || ':18:::NO:18:P18_JOB_ID,P18_PROB_TYPE_CHK,P18_RP:' || p_job_id ||','||p_prob_type_chk|| ',3';
          editurl := '<a href="' || editurl || '">Go to Cater Job</a>';
          plsql_mail.send_body(editurl);
    else
      readurl := 'https://' || http_host || script_name || '/f?p= 249:200:::NO:200:P200_JOB_ID,P200_PROB_TYPE_CHK,P200_RP:' || p_job_id ||','||p_prob_type_chk|| ',3';
          readurl := '<a href="' || readurl || '">Read-Only Cater Job</br></a>';
          plsql_mail.send_body(readurl);
          plsql_mail.send_body('<table border=0 width="75%" align=left>');
      --
      editurl := 'https://' || http_host || script_name || '/f?p=' ||
                    nvl(v('APP_ID'),'194') || ':200:::NO:200:P200_JOB_ID,P200_PROB_TYPE_CHK,P200_RP:' || p_job_id ||','||p_prob_type_chk|| ',3';
          editurl := '<a href="' || editurl || '">Go to Cater Job</a>';
          plsql_mail.send_body(editurl);
    end if;
     elsif p_sol_id is not null then
-- Poonam 6/6/2012 - Added the value to be passed to P5_PROB_TYPE_CHK, as ART_SOLUTIONS does not have PROB_TYPE_CHK column.
--           Without it, Page 5 was always opening with only some restricted fields and could not go on the basis of Prob Type.
--
      readurl := 'https://' || http_host || script_name || '/f?p= 249:5:::NO:5:P5_SOL_ID,P5_PROB_TYPE_CHK,P5_RP:' || p_sol_id ||','||p_prob_type_chk|| ',3';
          readurl := '<a href="' || readurl || '">Read-Only Cater Task/Solution</br></a>';
          plsql_mail.send_body(readurl);
          plsql_mail.send_body('<table border=0 width="75%" align=left>');
          --
      editurl := 'https://' || http_host || script_name || '/f?p=' ||
                    nvl(v('APP_ID'),'194') || ':5:::NO:5:P5_SOL_ID,P5_PROB_TYPE_CHK,P5_RP:' || p_sol_id ||','||p_prob_type_chk|| ',3';
          editurl := '<a href="' || editurl || '">Go to Cater Task/Solution</a>';
          plsql_mail.send_body(editurl);
     else
      readurl := 'https://' || http_host || script_name || '/f?p= 249:4:::NO:4:P4_PROB_ID,P4_RP:' || p_prob_id || ',3';
          readurl := '<a href="' || readurl || '">Read-Only Cater</br></a>';
          plsql_mail.send_body(readurl);
          plsql_mail.send_body('<table border=0 width="75%" align=left>');
          --
      editurl := 'https://' || http_host || script_name || '/f?p=' ||
                    nvl(v('APP_ID'),'194') || ':4:::NO:4:P4_PROB_ID,P4_RP:' || p_prob_id || ',3';
          editurl := '<a href="' || editurl || '">Go to Cater</a>';
          plsql_mail.send_body(editurl);
     end if;
     --
     plsql_mail.signoff_smtpsrv;

     exception when others then
        plsql_mail.contact_smtpsrv('oracle.slac.stanford.edu','poonam@slac.stanford.edu');
        plsql_mail.send_header('From', 'poonam@slac.stanford.edu');
        plsql_mail.send_header('To', 'poonam@slac.stanford.edu');
        plsql_mail.send_header('Subject','Error in PKG.email_job');
        plsql_mail.send_body('Error in PKG.email_job' || chr(10) ||
           'to_addr=' || p_to || chr(10) ||
           'to_msg=' || p_comment || chr(10) ||
           'subject=' || p_subject || chr(10) ||
           'prob_id=' || p_prob_id || chr(10) ||
           sqlerrm);
        plsql_mail.signoff_smtpsrv;

   end;

end email_job;


procedure send_email
(pi_email_from  in  varchar2 := 'jlgordon@slac.stanford.edu'
,pi_email_to    in  varchar2
,pi_email_cc    in  varchar2
,pi_subject     in  varchar2
,pi_body        in  varchar2
,pi_is_html     in  char default 'N'
,pi_is_active   in  char default 'N' -- change this to 'Y' for prod
,pi_email_id    out number
) as

    l_email_id number;

begin

    apps_util.qm_email_pkg.send_email
    (p_app_name    => 'CATER'
    ,p_page_name   => null
    ,p_email_from  => pi_email_from
    ,p_email_to    => pi_email_to
    ,p_email_cc    => pi_email_cc
    ,p_email_bcc   => null
    ,p_subject     => pi_subject
    ,p_body        => pi_body
    ,p_is_html     => pi_is_html
    ,p_is_active   => pi_is_active
    ,p_email_id    => l_email_id
    );

end send_email;


function email_addresses (p_role varchar2) return varchar2
is

  cursor email_cur is
    select sid_email
    from art_junc_div_userrole_user ur
        ,art_user_roles             r
        ,person                     p
    where ur.user_role_id = r.user_role_id
    and p.key = ur.user_id
    and r.user_role = p_role;

  l_emails varchar2(500);
  l_first_loop boolean := true;

begin

  for email_rec in email_cur loop

    if l_first_loop
    then
      l_first_loop := false;
    else
      l_emails := l_emails || ',';
    end if;

    l_emails := l_emails || email_rec.sid_email;

  end loop;

  return l_emails;

end;


function area_mgr_pref_set
(p_area_id      number
,p_area_mgr_id  number
,p_pref         varchar
) return boolean is

  l_result pls_integer := 0;

begin

  select 1 into l_result
  from art_junc_area_mgr_am_pref amap
      ,art_area_mgr_prefs        amp
  where amap.area_mgr_pref_id = amp.area_mgr_pref_id
  and   amap.area_id          = p_area_id
  and   amap.area_mgr_id      = p_area_mgr_id
  and   amp.name              = p_pref;

  if l_result = 1
  then
    return true;
  else
    return false;
  end if;

exception
  when no_data_found
    then return false;
end;


function prob_on_watchlist
(p_prob_id  art_junc_prob_watchlist.prob_id%type
) return boolean is

  l_result pls_integer := 0;

begin

  select count(*) into l_result
  from art_junc_prob_watchlist
  where prob_id   = p_prob_id;

    if l_result > 0
  then
    return true;
  else
    return false;
  end if;

exception
  when no_data_found
    then return false;
end;


procedure send_alert
(p_prob_id             in art_problems.prob_id%type
,p_assignedto_id       in art_problems.assignedto_id%type
,p_area_id             in art_problems.area_id%type
,p_instance            in varchar2
,p_change_msg          in varchar2
,p_alert_type          in varchar2 -- a or c
,p_host_sid_url        in varchar2
) is

  c_application_name       constant varchar2(20)  := 'CATER';
  c_created_msg            constant varchar2(20)  := 'created';
  c_changed_msg            constant varchar2(20)  := 'modified';
  c_cater_msg_label        constant varchar2(100) := c_application_name ||' #';
  c_am_alert_pref          constant varchar2(100) := 'Email alert for changes to problems';

  l_subject                         varchar2(1000);
  l_body                            varchar2(1000);
  l_alert_type_msg                  varchar2(20);
  l_cater_problem_edit_url          varchar2(1000);
  l_cater_problem_print_url         varchar2(1000);
  l_instance_msg                    varchar2(50) := null;
  l_email_address_to                varchar2(4000);
  l_area                            varchar2(100);
  l_area_mgr_id                     number;
  l_area_mgr_sid_email              varchar2(100);
  l_assignedto_sid_email            varchar2(100);

  l_user                            varchar2(100) := nvl(v('APP_USER'),user);
  l_my_email                        varchar2(100) := lower(nvl(v('APP_USER'),user)) || '@slac.stanford.edu';

  cursor watchlist_user_cur is
    select pers.sid_email
    from art_junc_prob_watchlist pw
        ,person                  pers
    where pw.prob_id = p_prob_id
    and   pw.user_id = pers.key;

begin

  if p_alert_type = 'a'
  then
    l_alert_type_msg := c_created_msg;
  else
    l_alert_type_msg := c_changed_msg;
  end if;

  -- format instance message if not prod
  if p_instance != 'slacprod'
  then
    l_instance_msg := ', instance: ' || p_instance;
  end if;

  -- construct url for cater link
  l_cater_problem_edit_url := p_host_sid_url || '/f?p=' || nvl(v('APP_ID'),'194') || ':4:::NO:4:P4_PROB_ID,P4_RP:' || p_prob_id || ',3';

  -- construct url for print output
  l_cater_problem_print_url := p_host_sid_url || '/mcc_maint.pkg.print?p_prob_id=' || p_prob_id || util.g_lf || util.g_lf;

  -- get assignedto email address
  begin
    select sid_email
    into l_assignedto_sid_email
    from person
    where key = p_assignedto_id;
  exception
    when no_data_found then null;
  end;

  -- get area information
  begin
    select a.area
          ,p.key
          ,p.sid_email
    into l_area
        ,l_area_mgr_id
        ,l_area_mgr_sid_email
    from art_junc_area_person ap
        ,person               p
        ,art_areas            a
    where ap.person_id = p.key
    and   ap.area_id   = a.area_id
    and   a.area_id    = p_area_id
    and   rownum < 2;
  exception
    when no_data_found then null;
  end;

  -- l_test_msg := 'area='||to_char(p_area_id)||' areamgr='||to_char(l_area_mgr_id);

  -- add assigned to email address
  l_email_address_to := l_email_address_to || l_assignedto_sid_email;

  -- add area mgr email address
  if pkg.area_mgr_pref_set(p_area_id,l_area_mgr_id,c_am_alert_pref)
  -- if pkg.area_mgr_pref_set(3,355291,'Email notification for changes to problems')
  then
    l_email_address_to := l_email_address_to || ',' || 'gordonsrus@gmail.com'; -- l_area_mgr_sid_email;
  end if;

  if pkg.prob_on_watchlist(p_prob_id)
  then
    for watchlist_user_rec in watchlist_user_cur
    loop
      l_email_address_to := l_email_address_to || ',' || 'gordonsrus@gmail.com'; -- l_area_mgr_sid_email;
    end loop;
  end if;

  -- construct subject
  l_subject := c_cater_msg_label || p_prob_id || '/' || l_area || ' ' || l_alert_type_msg || l_instance_msg;

  -- construct body
  l_body := c_cater_msg_label || p_prob_id || '/' || l_area || ' was '|| l_alert_type_msg || '.' || util.g_lf || util.g_lf
            || p_change_msg
            || '- ' || l_alert_type_msg || ': ' || to_char(sysdate,util.g_datetime_format) || ' by '
            || v('APP_USER') || ' ' || l_my_email || util.g_lf || util.g_lf
            || 'See quick view: ' || util.g_lf
            || l_cater_problem_print_url
            || 'Go to ' || c_application_name || ':' || util.g_lf
            || l_cater_problem_edit_url
            ;

  util.send_email
  (p_addr_to       => l_email_address_to
  ,p_addr_from     => l_my_email
  ,p_subject       => l_subject
  ,p_body          => l_body
  ,p_content_type  => util.c_content_type_plain
  );

end;


function get_sched_off_grand_total
(p_start_date  date
,p_end_date    date
) return number as

  l_shifts          number;
  l_shifts_summary  number;

begin

  select count(*) into l_shifts
  from mcco_shifts_view m
      ,art_programs     p
      ,art_programs     parent
  where p.program   = m.program_type
  and   p.parent_id = parent.prog_id(+)
  and   m.shift_date between p_start_date and p_end_date;

  select count(*) into l_shifts_summary
  from
  (
  select count(m.shift_date)
  from mcco_shifts_view m
      ,art_programs     p
      ,art_programs     parent
  where p.program   = m.program_type
  and   p.parent_id = parent.prog_id(+)
  and   m.shift_date between p_start_date and p_end_date
  group by m.shift_date
          ,m.shift_type
  );

  -- dbms_output.put_line((l_shifts-l_shifts_summary)*8);

  return (l_shifts-l_shifts_summary) * 8;

end;


function get_name_for_sid
(p_sid  number
) return varchar2 is

  l_name  person.name%type;

begin

  select name into l_name
  from person
  where key = p_sid;

  return l_name;

exception
  when no_data_found then null;
end;


function add_ins_msg
(p_new_value  varchar2
,p_label      varchar2
,p_html_flag  pls_integer
) return varchar2 is

  l_msg_out   varchar2(1000);

begin

  if  p_new_value is not null
  then

    l_msg_out := util.add_notification_line(l_msg_out
                                           ,p_label
                                           ,p_new_value
                                           ,p_html_flag
                                           );
    return l_msg_out;

  else

    return null;

  end if;

end;


function add_chg_msg
(p_old_value  varchar2
,p_new_value  varchar2
,p_label      varchar2
,p_html_flag  pls_integer
) return varchar2 is

  l_msg_out   varchar2(1000);
  l_no_value  varchar2(50) := 'No Value';

begin

  if p_old_value != p_new_value
  then
    l_msg_out :=  '- ' || p_label || ' has changed from '
                  || '"' || nvl(p_old_value,l_no_value) || '"'
                  || ' to '
                  || '"' || nvl(p_new_value,l_no_value) || '"'
                  || util.g_lf;
    return l_msg_out;
  else
    return null;
  end if;

end;


function user_pref_set
(p_user_pref_id  number
,p_person_id     number
) return boolean is

  l_result pls_integer := 0;

begin

  select count(*) into l_result
  from art_junc_user_user_prefs
  where user_pref_id = p_user_pref_id
  and   user_id      = p_person_id;

  if l_result > 0
  then
    return true;
  else
    return false;
  end if;

exception
  when others then return false;
end;


function admin_user_pref_set
(p_user_pref_id  number
) return boolean is

  l_result pls_integer := 0;

begin

  select count(*) into l_result
  from art_junc_user_pref_roles
  where user_pref_id = p_user_pref_id
  and user_role_id = 7;

  if l_result > 0
  then
    return true;
  else
    return false;
  end if;

exception
  when others then return false;
end;


function priority_access_warning
(pi_priority     varchar2
,pi_access_type  varchar2
) return varchar2
as
begin

  if (pi_priority = 'PAMM' and pi_access_type  = 'No Access')
  or (pi_priority = 'POMM' and pi_access_type != 'No Access')
  then
      return 'Y';
  else
      return null;
  end if;

end;


begin
  pkg_allow_set_status := 'Y';
  trg_jobs_request_id_arr.delete;
  trg_sols_request_id_arr.delete;
end pkg;

/
