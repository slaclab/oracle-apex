--------------------------------------------------------
--  File created - Tuesday-June-22-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body CATER_MESSAGE_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MCC_MAINT"."CATER_MESSAGE_NEW" as

-- Poonam - 3/24/2021 - Modified procedure "email_problem_by_replyall" to increase the length of 
--                      l_html_older_comment from 4K to 6K due to errors.
-- Poonam - 9/6/2017 - Modified procedure "email_problem_by_replyall" so it can work from ACR too.
--                   - Added New procedure "chk_cater_notif_watchlist" for Watchlist Email preferences.
-- Poonam - Mar 2016 - Adding the HTML <pre> tags to the email body to preserve the line breaks.
--                   - SHortened the Subject Line for all Cater Emails.
-- Poonam - Jan 2016 - Replacing newline and carriage returns with a space in the 
--       Email Subject line to take care of HTML code spewing out into the email.
--   Email only 5 latest Jobs, 5 latest Open Solution/Tasks and Open RSWCF forms.
-- Poonam  8/31/2015 - Don't send the name "slacprod" in every Prod email subject.
-- Poonam 10/21/2014 - Minor changes for Cater Title display
-- Poonam 10/14/2014 - Changes for New CATER UI.
-- Poonam 7/1/2014 - send HTML email to the Task person even if NO Shop Notification exists
--                  Modified the procedure "send_message_to_group"
-- Poonam - Apr 2014 Release - Fixed the TO Address for Email from Solution/Task page
--                 in "email_sol_by_id" procedure.
-- Poonam - Feb2014 Release - Retain the User Subject line from the EMail button.
--                            Changed color definitions for statuses based on Johnny's feedback.
-- Poonam - 1/13/2014 - Reverted to original code for Old and New Created date, as problem was in the App.
-- Poonam - Modified to not display old and new Created_Date on each table, as they are somehow different.
-- The seconds are resetting to 00 in the CREATED_DATE for all of the tables during the 1st update after an Insert.
-- This could be due to the multiple triggers for Change Log and other things on each table.
-- Needs to be looked at some stage.

c_html              constant varchar2(10)  := 'HTML';
c_plain             constant varchar2(10)  := 'PLAIN';
c_html_break        constant varchar2(10)  := '<br>';
c_plain_break       constant varchar2(10)  := util.g_lf;

--
-- styles
--

c_css_styles   constant varchar2(32767) :=
'
<style>

body
{
font-family:'||c_font_family||';
font-size:1.0em;
background-color:#FFFFFF;
color:#30261D;
text-align:left;
}

b.light {font-weight:lighter;}
b.thick {font-weight:bold;}
b.thicker {font-weight:900;}

td.blueCell { background-color:#7AA3CC; padding:5px;}
td.ltBlueCell { background-color:#C4D6E8;}

td.yellowCell { background-color:#E6B800; }
td.ltYellowCell { background-color:#F4E194; }

td.orangeCell { background-color:#FFB280; }
td.ltOrangeCell { background-color:#FFE0CC; }

td.redCell { background-color:#E86262; }
td.ltRedCell { background-color:#FF9999; }

td.activeStatusCell { color:#FF3300; }
td.completeStatusCell { color:#009900; }

td.whiteCell { background-color:#FFFFFF; padding:5px;}

tr.blueRow { background-color:#99CCFF; }
tr.ltBlueRow { background-color:#D6EBFF; }

</style>
';

--l_html_message_body  clob;
--l_text_message_body  clob;


function text_overflow (p_text varchar2,p_size_limit pls_integer) return varchar is
c_proc              constant varchar2(100) := 'CATER_MESSAGE_NEW.text_overflow ';
    l_result varchar2(4000);
begin


    if length(p_text) > p_size_limit
    then
        l_result := substr(p_text,0,p_size_limit);
        l_result := l_result || '...';
    else
        l_result := p_text;
    end if;

    return l_result;

end text_overflow;


function get_shop_mgr_email_addr (p_shop_id number) return varchar2 is

    l_email_address varchar2(100);
c_proc              constant varchar2(100) := 'CATER_MESSAGE_NEW.get_shop_mgr_email_addr ';

begin

    select p.maildisp
    into l_email_address
    from art_shops s
        ,person    p
    where s.shop_mgr_id = p.key
    and   s.shop_mgr_id = p_shop_id
    and rownum < 2;

    return l_email_address;

end get_shop_mgr_email_addr;


procedure message_begin
(pi_operation         in  varchar2
,pi_message_type         in  varchar2
,pi_from                 in  varchar2
,pi_to                   in  varchar2
,pi_subject		 in  varchar2
,pi_app_user             in  varchar2
,pi_prob_type_chk        in  varchar2
,pi_job_type_chk         in  varchar2
,pi_status_chk           in  number
,pi_status		 in  varchar2
,pi_schema_user          in  varchar2
,pi_assigned_to          in  number
,pi_prob_id              in  number
,pi_problem_title        in  varchar2
,pi_job_id               in  number
,pi_job_number           in  number
,pi_sol_id               in  number
,pi_task_person_id       in  number
,pi_created_date         in  date
,pi_created_by           in  varchar2
,pi_modified_date        in  date
,pi_modified_by          in  varchar2
,pi_comment              in  varchar2
,po_message_to           out varchar2
,po_html_message_subject out varchar2
,po_text_message_subject out varchar2
,po_html_message_body    out clob
,po_text_message_body    out clob
,po_apex_url_prefix      out varchar2
,po_instance             out varchar2
) is

    c_proc              constant varchar2(100) := 'CATER_MESSAGE_NEW.message_begin ';
    c_job_status_label  constant varchar2(100) := 'Job status: ';
    c_prob_status_label constant varchar2(100) := 'Problem status: ';

    to_address                   varchar2(1024);
    l_maildisp                   PERSONS.PERSON.MAILDISP%TYPE; -- Poonam - changed to DB type
    l_name                       PERSONS.PERSON.NAME%TYPE;     -- Poonam - changed to DB type
    l_problem_title              art_problems.problem_title%type;
    l_message_subject            varchar2(500);
    l_script_name                varchar2(100);
    l_instance                   varchar2(100);
    l_task_person                varchar2(100);
    l_prob_type_chk              art_problems.prob_type_chk%type;
    l_http_host                  varchar2(100);
    l_url_prefix                 varchar2(100);

    l_status_label               varchar2(100);
-- Poonam - getting PROBLEM STATUS
    l_prob_subject_part         varchar2(30);
    l_job_subject_part         varchar2(30);
    l_sol_subject_part         varchar2(30);
    l_prob_descr         varchar2(100);
    l_supervisor_email         PERSONS.PERSON.MAILDISP%TYPE;
--
--    l_prob_job_label             varchar2(500);  -- Poonam 10/14/14 - Not being used
    l_edit_url                   varchar2(1000);
    l_read_only_url              varchar2(1000);

    l_html_message_body          clob;
    l_text_message_body          clob;

    l_errmsg                     varchar2(1000);

-- Poonam 10/14/14 - For Cater Watchlist
cursor prob_watchlist_cur is
  select a.user_id, b.maildisp, b.name
  from art_junc_prob_watchlist a, person b
  where a.prob_id = pi_prob_id
  and   a.user_id = b.key;

begin


-- Poonam 10/14/2014 - Getting Problem Title for all types except when Null.
  if pi_job_id is not null or
     pi_sol_id is not null then
--    select prob_type_chk, decode(prob_type_chk,'REQUEST',problem_title,substr(description,1,50),substr(description,1,50))
    select prob_type_chk, substr(nvl(problem_title,description),1,50)
    into l_prob_type_chk, l_problem_title
    from art_problems
    where prob_id = pi_prob_id;
  else
    l_prob_type_chk := pi_prob_type_chk;
    l_problem_title := pi_problem_title;
  end if;
--
-- Gets INSTANCE from the Database (for Scheduler job) and the APEX URL too.
    cater_ui.get_apex_url_prefix(po_apex_url_prefix => l_url_prefix, po_instance => l_instance);

    po_message_to := lower(pi_to);

-- Poonam - Feb2014 Release - To retain the User Subject line from the EMail button.
IF pi_subject is NOT NULL THEN
   l_message_subject := pi_subject;
ELSE
-- Poonam - Mar 2016 - Shortening the Subject line
   l_prob_subject_part := 'CATER #';
    if l_prob_type_chk = 'REQUEST' then
       l_sol_subject_part := ' Task #';
    else
       l_sol_subject_part := ' Solution #';
    end if;

    l_job_subject_part := initcap(pi_job_type_chk)||' Job #';
--
    --
    -- set subject line
    --
-- Poonam 8/31/2015 - Don't send the name "slacprod" in every Prod email subject.
-- Poonam - Mar 2016 - Shortening the Subject line for all Cater Emails
  IF l_instance = 'slacprod' then
    if pi_prob_id is not null and pi_job_id is null and pi_sol_id is null  -- problem change
    then
      l_message_subject := substr(l_problem_title,1,50)||': '||l_prob_subject_part || pi_prob_id;
--        l_message_subject := l_instance || pi_status ||l_prob_subject_part || pi_prob_id||': '||substr(l_problem_title,1,50)||'; '||l_name;
    end if;
    --
    if pi_sol_id is not null   -- solution change
    then
      l_message_subject := substr(l_problem_title,1,50)||': '||l_prob_subject_part||pi_prob_id||l_sol_subject_part||pi_job_number;
--          l_message_subject := l_instance|| l_sol_subject_part||pi_job_number||' '||pi_status||';'||l_prob_subject_part||pi_prob_id||': '||substr(l_problem_title,1,50)||'; '||l_name;
    end if;
    --
    IF pi_job_id is not null   -- job change
    THEN
      l_message_subject := substr(l_problem_title,1,50)||': '||l_prob_subject_part||pi_prob_id||l_job_subject_part||pi_job_number;
--           l_message_subject := l_instance||l_job_subject_part||pi_job_number||' '||pi_status||';'||l_prob_subject_part||pi_prob_id||': '||substr(l_problem_title,1,50)||'; '||l_name;
    END IF;
  ELSE
    if pi_prob_id is not null and pi_job_id is null and pi_sol_id is null  -- problem change
    then
     l_message_subject := l_instance ||' '||substr(l_problem_title,1,50)||': '||l_prob_subject_part || pi_prob_id;
--        l_message_subject := l_instance || pi_status ||l_prob_subject_part || pi_prob_id||': '||substr(l_problem_title,1,50)||'; '||l_name;
    end if;
    --
    if pi_sol_id is not null   -- solution change
    then
     l_message_subject := l_instance||' '||substr(l_problem_title,1,50)||': '|| l_prob_subject_part||pi_prob_id||l_sol_subject_part||pi_job_number;
--          l_message_subject := l_instance|| l_sol_subject_part||pi_job_number||' '||pi_status||';'||l_prob_subject_part||pi_prob_id||': '||substr(l_problem_title,1,50)||'; '||l_name;
    end if;
    --
    if pi_job_id is not null   -- job change
    then
      l_message_subject := l_instance||' '||substr(l_problem_title,1,50)||': '||l_prob_subject_part||pi_prob_id||l_job_subject_part||pi_job_number;
--           l_message_subject := l_instance||l_job_subject_part||pi_job_number||' '||pi_status||';'||l_prob_subject_part||pi_prob_id||': '||substr(l_problem_title,1,50)||'; '||l_name;
    end if;
  END IF;
END IF; -- pi_subject NOT NULL
--
    to_address := fix_biud_toaddr(to_address);

    l_html_message_body := l_html_message_body || '<!DOCTYPE html><html lang="en-us" >' || c_plain_break;
    l_html_message_body := l_html_message_body || '<title>CATER Report</title>'         || c_plain_break;
    l_html_message_body := l_html_message_body || c_css_styles || c_plain_break;
    l_html_message_body := l_html_message_body || '<body>' || c_plain_break;

-- Poonam - Mar 2016 - Added HTML ,<pre> tags to preserve line breaks in the email text
-- Poonam - Removing the COMMENT add here. Doing it in message_end instead.
--    l_html_message_body := l_html_message_body || '<p><pre>' || pi_comment || '</pre></p><br>' || c_plain_break;
    l_html_message_body := l_html_message_body || '<table border="0">' || c_plain_break;

    po_html_message_subject := l_message_subject;
    po_text_message_subject := l_message_subject;


    po_html_message_body    := l_html_message_body;
    po_text_message_body    := l_text_message_body;

    po_apex_url_prefix      := l_url_prefix;
    po_instance             := l_instance;

exception
    when others
    then

        l_errmsg := errmsg(c_proc);

        apps_util.utl.log_add
        (p_appl_id         => 1
        ,p_trans_id        => null
        ,p_message_type_id => 1
        ,p_text            => l_errmsg
        );

end message_begin;


function errmsg(p_proc varchar2) return varchar2
is
    c_proc constant varchar2(100) := 'CATER_MESSAGE_NEW.errmsg ';
begin
    apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin');
    return p_proc || sqlerrm || ' ' || dbms_utility.format_error_backtrace();
end errmsg;

procedure send_email
(pi_page_name      in  varchar2
,pi_email_from     in  varchar2
,pi_email_to       in  varchar2
,pi_email_cc       in  varchar2
,pi_subject        in  varchar2
,pi_body           in  clob
,pi_is_html        in  char
,pi_is_active      in  char
,po_email_id       out number
) is

    c_proc          constant varchar2(100) := 'CATER_MESSAGE_NEW.send_email ';
    l_email_to    VARCHAR2(1024); -- APPS_UTIL.QM_EMAILS
begin
-- Comment out later ***********************************************
/*
    apps_util.utl.log_add
    (p_appl_id => 1
    ,p_trans_id => null
    ,p_message_type_id => 1
    ,p_text =>
    c_proc          ||
    '7 c_app_name: '  || c_app_name   ||
    ' pi_page_name: '|| pi_page_name ||
    ' c_from_email: '|| pi_email_from   ||
    ' pi_email_to: ' || pi_email_to  ||
    ' pi_email_cc: ' || pi_email_cc  ||
    ' pi_subject: '  || pi_subject   ||
    ' pi_body: '     || substr(pi_body,1,100) ||
    ' pi_is_html: '  || pi_is_html ||
    ' pi_is_active: '|| pi_is_active
    );
*/
    l_email_to := trim(';' FROM pi_email_to);

    qm_email_pkg.send_email
    (p_app_name   => c_app_name
    ,p_page_name  => pi_page_name
    ,p_email_from => pi_email_from
    ,p_email_to   => l_email_to
    ,p_email_cc   => pi_email_cc
    ,p_email_bcc  => null
    ,p_subject    => pi_subject
    ,p_body       => pi_body
    ,p_is_html    => pi_is_html
    ,p_is_active  => pi_is_active
    ,p_email_id   => po_email_id
    );

EXCEPTION
   WHEN OTHERS THEN
	plsql_mail.contact_smtpsrv('oracle.slac.stanford.edu','poonam@slac.stanford.edu');
        plsql_mail.send_header('From', 'poonam@slac.stanford.edu');
        plsql_mail.send_header('To', 'poonam@slac.stanford.edu');
        plsql_mail.send_header('Subject','Error in '|| c_proc);
        plsql_mail.send_body('Error in ' || c_proc || chr(10) ||
           'from_addr=' || pi_email_from || chr(10) ||
           'to_addr=' || pi_email_to || chr(10) ||
           'subject=' || pi_subject || chr(10) ||
           sqlerrm);
        plsql_mail.signoff_smtpsrv;

end send_email;

procedure message_body_line
(pi_prob_id         in     number
,pi_job_id          in     number := null
,pi_sol_id          in     number := null
,pi_form_id         in     number := null
,pi_prob_type_chk   in     varchar2 := null
,pi_job_type_chk    in     varchar2 := null
,pi_label           in     varchar2
,pi_old             in     varchar2
,pi_new             in     varchar2
,pi_message_type    in     varchar2 := null
,pi_apex_url_prefix in     varchar2
,pio_html_body      in out clob
,pio_text_body      in out clob
,pio_line_number    in out pls_integer
) is

    c_proc             constant varchar2(100) := 'CATER_MESSAGE_NEW.message_body_line ';
    --c_html_line_end   constant varchar2(100) := c_html_break  || c_html_break;
    c_plain_line_end   constant varchar2(100) := c_plain_break || c_plain_break;

    l_label_cell_bg_color       varchar2(100) := 'blueCell';
    l_value_cell_bg_color       varchar2(100) := 'whiteCell';

    l_errmsg                    varchar2(1000) := null;

    l_edit_url                  varchar2(1000);
    l_read_only_url             varchar2(1000);
    l_edit_link                 varchar2(1000);
    l_read_only_link            varchar2(1000);
    l_new_value_out             varchar2(1000) := pi_new;

begin

if pi_label like 'Rad Safety Form%' then
    apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || pi_label || ' pi_form_id: '|| pi_form_id ||', pi_old: '|| pi_old || ', pi_new: ' ||  pi_new );
end if;
    --
    -- special handling for lines
    --
    -- Link creation --comment out by Kalsi

-- Poonam 3/15/2017 - All Caters are referred to as CATER Id now. No more special labels.
    case
--        when pi_label in ('HW CATER Id','SW CATER Id','Request Id')
        when pi_label = 'CATER Id'
        then
            begin
                l_edit_url       := cater_ui.get_prob_edit_url(p_apex_url_prefix=>pi_apex_url_prefix, p_start_page=>c_start_page, p_prob_id=>pi_new, p_return_page=>c_return_page) || c_plain_break;
                l_edit_link      := cater_ui.get_link(l_edit_url,'edit');
                l_read_only_url  := cater_ui.get_prob_read_only_url(p_apex_url_prefix=>pi_apex_url_prefix, p_start_page=>c_start_page, p_prob_id=>pi_new, p_return_page=>c_return_page) || c_plain_break;
                l_read_only_link := cater_ui.get_link(l_read_only_url,'read only');
                l_new_value_out  := pi_new || ' ' || l_edit_link || ' ' || l_read_only_link;
            end;
        when pi_label in ('HW Job Number','SW Job Number')
        then
            begin
                l_new_value_out := pi_new;
                if l_new_value_out is null or l_new_value_out = 0
                then
                    l_new_value_out := 'null';
                end if;
                l_edit_url       := cater_ui.get_job_edit_url(p_apex_url_prefix=>pi_apex_url_prefix, p_start_page=>c_start_page, p_prob_id=>pi_prob_id, p_job_id=>pi_job_id, p_job_type_chk=>pi_job_type_chk, p_return_page=>c_return_page) || c_plain_break;
                l_edit_link      := cater_ui.get_link(l_edit_url,'edit');
                l_read_only_url  := cater_ui.get_job_read_only_url(p_apex_url_prefix=>pi_apex_url_prefix, p_start_page=>c_start_page, p_prob_id=>pi_prob_id, p_job_id=>pi_job_id, p_job_type_chk=>pi_job_type_chk, p_return_page=>c_return_page) || c_plain_break;
                l_read_only_link := cater_ui.get_link(l_read_only_url,'read only');
                l_new_value_out  := l_new_value_out || ' ' || l_edit_link || ' ' || l_read_only_link;
            end;
        when pi_label in ('Solution Number','Task Number')
        then
            begin
                l_new_value_out := pi_new;
                if l_new_value_out is null or l_new_value_out = 0
                then
                    l_new_value_out := 'null';
                end if;
                l_edit_url       := cater_ui.get_sol_edit_url(p_apex_url_prefix=>pi_apex_url_prefix, p_start_page=>c_start_page, p_prob_id=>pi_prob_id, p_sol_id=>pi_sol_id, p_prob_type_chk=>pi_prob_type_chk, p_return_page=>c_return_page) || c_plain_break;
                l_edit_link      := cater_ui.get_link(l_edit_url,'edit');
                l_read_only_url  := cater_ui.get_sol_read_only_url(p_apex_url_prefix=>pi_apex_url_prefix, p_start_page=>c_start_page, p_prob_id=>pi_prob_id, p_sol_id=>pi_sol_id, p_prob_type_chk=>pi_prob_type_chk, p_return_page=>c_return_page) || c_plain_break;
                l_read_only_link := cater_ui.get_link(l_read_only_url,'read only');
                l_new_value_out  := l_new_value_out || ' ' || l_edit_link || ' ' || l_read_only_link;
            end;
/* Poonam - new Email - Removing the below logic, as it's only a Dummy Link
	when pi_label = 'Rad Safety Form'
        then
            begin
                if pi_new = 'Yes'
                then
                  l_edit_url       := cater_ui.get_rsw_edit_url(p_apex_url_prefix=>pi_apex_url_prefix,p_form_id=>pi_form_id) || c_plain_break;
                  l_edit_link      := cater_ui.get_link(l_edit_url,'edit');
                  l_read_only_url  := cater_ui.get_rsw_read_only_url(p_apex_url_prefix=>pi_apex_url_prefix,p_form_id=>pi_form_id) || c_plain_break;
                  l_read_only_link := cater_ui.get_link(l_read_only_url,'read only');
                  l_new_value_out  := l_new_value_out || ' ' || l_edit_link || ' ' || l_read_only_link;
                end if;
            end;
*/
	else l_new_value_out := pi_new;
    end case;


    if pi_old is not null or pi_new is not null
    then
        --
        -- set color
        --
        if pi_prob_id is not null and pi_job_id is null and pi_sol_id is null and pi_form_id is null -- prob
        then
            l_label_cell_bg_color := 'blueCell';
        elsif pi_prob_id is not null and pi_job_id is not null and pi_sol_id is null and pi_form_id is null -- job
        then
            l_label_cell_bg_color := 'orangeCell';
        elsif pi_sol_id is not null -- solution
        then
            l_label_cell_bg_color := 'ltYellowCell';
        elsif pi_prob_id is null and pi_job_id is null and pi_sol_id is null and pi_form_id is not null -- rad safety form
        then
            l_label_cell_bg_color := 'redCell';
        else
            l_label_cell_bg_color := 'redCell';
        end if;

-- Poonam Feb 2014 - Changed color definitions for statuses based on Johnny's feedback.
        case
            when l_new_value_out = 'Drop'
              or l_new_value_out = 'Work Not Approved'
            then l_value_cell_bg_color := 'activeStatusCell';
            when l_new_value_out = 'New'
	      or l_new_value_out = 'Active'
              or l_new_value_out = 'Work Approved'
              or l_new_value_out = 'Work Complete'
              or l_new_value_out = 'Ready For Beam'
              or l_new_value_out = 'Review To Close'
            then l_value_cell_bg_color := 'completeStatusCell';
            else l_value_cell_bg_color := 'whiteCell';
        end case;

-- Poonam - Mar 2016 - Added HTML <pre> tags to preserve line breaks in the email text.
 if pi_message_type in ('R','RP')
 then
   pio_html_body := pio_html_body || '<tr><td class="' || l_label_cell_bg_color || '">' || pi_label || '</td><td class="' || l_value_cell_bg_color || '"><pre>' || l_new_value_out || '</pre></td></tr>' || c_plain_break;
   pio_text_body := pio_text_body ||                                                       pi_label ||                                                ': ' || pi_new                 || c_plain_break;

 else -- (pi_message_type not in ('R','RP')
   if pi_old is null  -- New Row Inserted
   then
     if l_new_value_out is not null
     then
        pio_html_body   := pio_html_body || '<tr><td class="' || l_label_cell_bg_color || '"><b>' || pi_label || '</b></td><td class="' || l_value_cell_bg_color || '">' || c_html_break||'<pre>' || l_new_value_out || '</pre></td></tr>' || c_plain_break;
        pio_text_body   := pio_text_body ||                                                          pi_label || c_plain_break || l_new_value_out || c_plain_line_end;
     end if; -- l_new_value_out is not null
   else -- (pi_old is NOT null)
      if pi_old = l_new_value_out --??? Why check for NVL, as pi_old is NOT NULL. So, if they are different, they are different. Old and New values are same
      then
        pio_html_body   := pio_html_body || '<tr><td class="' || l_label_cell_bg_color || '"><b>' || pi_label || '</b></td><td class="' || l_value_cell_bg_color || '">' || c_html_break||'<pre>'|| pi_old  || '</pre></td></tr>' || c_plain_break;
        pio_text_body   := pio_text_body ||                                                          pi_label || c_plain_break || pi_old  || c_plain_line_end;
      else -- New and Old are NOT the same
--        if pi_label in ('SW CATER Id','HW CATER Id','Request Id','HW Job Number','SW Job Number','Solution Number','Task Number','Rad Safety Form Id')  -- No new and old values for the ID fields
        if pi_label in ('CATER Id','HW Job Number','SW Job Number','Solution Number','Task Number','Rad Safety Form Id')  -- No new and old values for the ID fields
        then
           pio_html_body   := pio_html_body || '<tr><td class="' || l_label_cell_bg_color || '"><b>' || pi_label || '</b></td><td class="' || l_value_cell_bg_color || '">' || c_html_break ||'<pre>'|| l_new_value_out || '</pre></td></tr>' || c_plain_break;
           pio_text_body   := pio_text_body ||                                                          pi_label || c_plain_break || l_new_value_out || c_plain_line_end;
        else -- Print OLD and NEW values for all NON PK fields
           pio_html_body   := pio_html_body || '<tr><td class="' || l_label_cell_bg_color || '"><b>' || pi_label || '</b></td><td class="' || l_value_cell_bg_color || '">' || c_html_break  || '<b>[NEW]:</b>' || c_html_break ||'<pre>'|| l_new_value_out ||'</pre>'|| c_html_break  || '<b>[OLD]:</b>' || c_html_break||'<pre>'|| pi_old || '</pre></td></tr>' || c_plain_break;
           pio_text_body   := pio_text_body ||                                                          pi_label || c_plain_break || '[NEW]:' || c_plain_break || pi_new || c_plain_break || '[OLD]:'        || c_plain_break || pi_old || c_plain_line_end;
        end if; -- pi_label for OTHER PK Fields
       end if; -- (nvl(pi_old,0) = nvl(l_new_value_out,0) )
   end if; -- (pi_old is null )
  end if; -- (pi_message_type in ('R','RP') )
  --
  if pi_label like 'Rad Safety Form%' -- add an extra line for rad safety form (RSWCF) change lines
  then
    pio_html_body   := pio_html_body || '<tr><td class="' || l_label_cell_bg_color || '"><b>' || pi_label || '</b></td><td class="' || l_value_cell_bg_color || '">' || c_html_break ||'<pre>'|| pi_new  || '</pre></td></tr><tr><td></td><td class="' || l_value_cell_bg_color || 
		    '">If Radiation Safety Work Control Form Required</td></tr>' || c_plain_break || '<tr><td></td><td class="' || l_value_cell_bg_color || 
		    '">RSWCF''s must be in the Work Approved state before the job can begin</td></tr>' || c_plain_break;
    pio_text_body   := pio_text_body ||                                                          pi_label || c_plain_break || pi_new  || c_plain_line_end;
  end if; -- pi_label like 'Rad Safety Form%' 

end if;

exception
    when others
    then

        l_errmsg := substr('ERROR: '||c_proc||': '||sqlerrm,1,1000);

        apps_util.utl.log_add
        (p_appl_id         => 1
        ,p_trans_id        => null
        ,p_message_type_id => 1
        ,p_text            => l_errmsg
        );

end message_body_line;

-- ****************** Add the url_prefix as an input parameter ***********************
-- Poonam - Adding COMMENT here.
-- ******************************************************************************
procedure message_end
(pi_app_id              in varchar2
,pi_script_name         in varchar2
,pi_instance            in varchar2
,pi_div_code_id         in number
,pi_prob_id             in number
,pi_sol_id              in number
,pi_job_id              in number
,pi_shop_id             in number
,pi_subsystem_id        in number
,pi_prob_type_chk       in varchar2
,pi_job_type_chk        in varchar2
,pi_page_name           in varchar2
,pi_from                in varchar2
,pi_to                  in varchar2
,pi_subject             in varchar2
,pi_comment             in varchar2
,pi_html_body           in clob
,pi_text_body           in clob
,pi_html_subject        in varchar2
,pi_text_subject        in varchar2
,pi_web                 in boolean
,pi_is_active           in char
,pi_message_type        in varchar2
,pi_size_limit_reached  in varchar2
) is

    c_proc                      constant varchar2(100) := 'CATER_MESSAGE_NEW.message_end ';
    c_email_size_limit_message  constant varchar2(500) := 'Warning: Email body size limit reached. This message has been truncated. There may be more jobs and/or solutions for this CATER.';

    l_is_html                char;
    l_html_body              clob := pi_html_body;
    l_text_body              clob := pi_text_body;

    l_html_comment           varchar2(4000);
    l_http_host              varchar2(300);
    l_script_name            varchar2(300) := pi_script_name;
    l_editurl                varchar2(1000);
    l_read_only_url          varchar2(1000);
    l_quickview              varchar2(500);
    l_url_prefix             varchar2(1000);
    l_prob_type_chk          varchar2(100);

    l_prob_job_label         varchar2(100);  -- ??????????????? Is this being used ?????????
    l_email_id               number := null;

-- Poonam - Jan 2016 - Added to take care of HTML code spewing out into the email.
    l_html_subject	     varchar2(1000);
    l_text_subject           varchar2(1000);
    l_reply_link                 varchar2(1000);
    l_reply_url                 varchar2(1000);
    l_instance                   varchar2(100);
    l_email_comment           varchar2(4000) := NULL;
-- Poonam May 2019 - Added to truncate the '@slac.stanford.edu' part of the email
--   when inserting into the table ART_JUNC_CATER_EMAILS.CREATED_BY
    l_created_by		varchar2(30);

begin
    l_html_body     := l_html_body || '</table>' || c_plain_break;

    if pi_size_limit_reached = 'Y'
    then
        l_html_body := l_html_body || '<p>' || c_email_size_limit_message || '</p>';
    end if;

-- Poonam - Jan 2016 - Added to take care of HTML code spewing out into the email.
--       Replacing newline and carriage returns with a space.
   l_html_subject := replace(replace(pi_html_subject,chr(10),' '),chr(13),' ');
   l_text_subject := replace(replace(pi_text_subject,chr(10),' '),chr(13),' ');

-- Poonam -- ??????????????? Is this being used ?????????
    if pi_job_id is null
    then -- problem change
        l_prob_job_label := 'problem' || c_plain_break;
    else -- job change
        l_prob_job_label := 'job' || c_plain_break;
    end if;

    l_html_body := l_html_body || '</body></html>' || c_plain_break;
    l_prob_type_chk := pi_prob_type_chk;

IF pi_comment is NOT NULL THEN
  l_email_comment := sysdate||' ['|| pi_from||']'||c_plain_break|| pi_comment;
END IF;
-- Poonam - moved the comment to the bottom of the message.
    l_html_body := l_html_body || '<p>View this email in HTML format to improve legibility.</p>' || c_plain_break;
--    l_html_comment := '<p><pre>' || pi_comment || '</pre></p><br>' || c_plain_break;

-- For the moment, removing from and date for the most recent comment.
    l_html_comment := '<p><pre>' || l_email_comment || '</pre></p><br>' || c_plain_break;

    /*
    prob_type_chk can be:
    HARDWARE
    SOFTWARE
    REQUEST
    HARDWARE JOB
    SOFTWARE JOB
    */
    if pi_job_id is null
    then -- prob
        l_prob_type_chk := pi_prob_type_chk;
    else -- job
        l_prob_type_chk := pi_job_type_chk || ' JOB';
    end if;

-- Poonam - Adding this condition for NO notifications being found
IF pi_to IS NOT NULL THEN
    if pi_message_type in ('SE','R','RP') -- report
    then

        l_is_html := 'Y';

-- Poonam - Jan 2016 - Using l_html_subject in place of pi_html_subject to 
--                     take care of HTML code spewing out into the email.

-- Poonam - Changed pi_is_active ='N', so we can get the EMAIL_ID back for Reply-All
        send_email
        (pi_page_name  => pi_page_name
        ,pi_email_from => pi_from
        ,pi_email_to   => pi_to
        ,pi_email_cc   => null
        ,pi_subject    => l_html_subject
	,pi_body       => l_html_body
        ,pi_is_html    => l_is_html
        ,pi_is_active  => 'N' 
        ,po_email_id   => l_email_id
        );
    end if;
--
-- Poonam May 2019 - Added to truncate the '@slac.stanford.edu' part of the email
--   when inserting into the table ART_JUNC_CATER_EMAILS.CREATED_BY. 
 l_created_by := UPPER(substr(pi_from,1, instr(pi_from,'@')-1));
--
-- Update Junction table with Cater Id, Job/Sol Id and Email Id for the email sent.
  IF l_email_id is not null THEN
    IF pi_sol_id is NULL AND pi_job_id is NULL 
    THEN
     insert into ART_JUNC_CATER_EMAILS (prob_id, email_id, parent_email_id, email_comment, created_by, created_date)
     values (pi_prob_id, l_email_id, l_email_id,pi_comment, l_created_by, sysdate);
    ELSIF pi_sol_id is NOT NULL
    THEN
     insert into ART_JUNC_CATER_EMAILS (prob_id, email_id, job_or_sol, job_sol_id, parent_email_id, email_comment, created_by, created_date)
     values (pi_prob_id, l_email_id, 'S', pi_sol_id,l_email_id,pi_comment, l_created_by, sysdate);
    ELSIF pi_job_id is NOT NULL
    THEN
     insert into ART_JUNC_CATER_EMAILS (prob_id, email_id, job_or_sol, job_sol_id, parent_email_id, email_comment, created_by, created_date)
     values (pi_prob_id, l_email_id, 'J', pi_job_id,l_email_id,pi_comment, l_created_by, sysdate);
    END IF;
    --
    commit;

-- Poonam - New code for Reply-All Link.
-- IF l_email_id is not null THEN   -- Moved it above 3/16/2017
-- Get INSTANCE from the Database and the APEX URL too.

  cater_ui.get_apex_url_prefix(po_apex_url_prefix => l_url_prefix, po_instance => l_instance);
--  l_reply_url := l_url_prefix || 'f?p=194:400:::NO:400:' || 'P400_EMAIL_ID,P400_PROB_ID,P400_PARENT_EMAIL_ID:' || l_email_id || ',' || pi_prob_id ||','|| l_email_id;
l_reply_url       := cater_ui.get_replyall_url(p_apex_url_prefix=>l_url_prefix, p_start_page=>c_start_page, p_email_id=>l_email_id, p_prob_id=>pi_prob_id, p_parent_email_id=>l_email_id) || c_plain_break;
  l_reply_link      := cater_ui.get_link(l_reply_url,'Reply-All');

-- ***************** Comment below code for testing without sending actual email ************
        qm_email_pkg.connect_smtp
        (l_email_id
        ,qm_email_pkg.fix_email_addresses(pi_from)
        ,qm_email_pkg.fix_email_addresses(pi_to)
        ,NULL
        ,NULL
        ,l_html_subject
        ,l_reply_link||c_html_break||c_html_break||l_html_comment ||l_html_body
        ,'Y'
        );
  ELSE
    apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' l_email_id is NULL: '||l_email_id);
  END IF; -- l_email_id is not null
ELSE
  apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' pi_to is NULL: '|| pi_to);
END IF; -- pi_to IS NOT NULL
--
end message_end;


procedure email_problem_by_id
(pi_prob_id       number
,pi_from          varchar2
,pi_to            varchar2
,pi_subject       varchar2
,pi_comment       varchar2
,pi_message_type  varchar2
) is

    c_proc                      constant varchar2(100) := 'CATER_MESSAGE_NEW.email_problem_by_id ';
    c_user                       constant varchar2(100) := nvl(v('APP_USER'),user);
    c_now                        constant date := sysdate;
    c_trans_id                   varchar2(100) := dbms_transaction.local_transaction_id;

    l_problem_rec_new   SYS_REFCURSOR;
    l_problem_rec_old   rc;
    l_to                varchar2(500);
    l_prob_email_id	ART_PROBLEMS_EMAIL.prob_email_id%TYPE;

begin
    l_prob_email_id := art_problems_email_seq.nextval;

    l_to := pi_from||';'|| translate(pi_to,':',';');

insert into art_problems_email
        (prob_email_id
        ,prob_chg_email_chk
	,prob_operation
	,prob_rec_type
        ,prob_user
        ,prob_email_datetime
        ,prob_email_trans_id
        ,prob_email_SESSION
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
        )
select   l_prob_email_id
	,2
	,'I'
	,'NEW'
        ,c_user
        ,c_now
        ,c_trans_id
        ,userenv('sessionid')
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
from art_problems
where prob_id = pi_prob_id;

commit;

  OPEN l_problem_rec_new FOR
    select *
    from art_problems_email
    where prob_email_id = l_prob_email_id
    and prob_chg_email_chk = 2
    and rownum = 1;

  OPEN l_problem_rec_old FOR
    select *
    from art_problems_email
    where 1 = 0;
--
    CATER_MESSAGE_NEW.email_cater_problem
    (pi_prob_rec_new  => l_problem_rec_new
    ,pi_prob_rec_old  => l_problem_rec_old
    ,pi_operation     => 'I'
    ,pi_from          => pi_from
    ,pi_to            => l_to
    ,pi_subject       => pi_subject
    ,pi_comment       => pi_comment
    ,pi_message_type  => pi_message_type
    ,pi_call_from     => 'email_problem_by_id'
    );

end  email_problem_by_id;

procedure email_job_by_id
(pi_job_id        number
,pi_from          varchar2
,pi_to            varchar2
,pi_subject       varchar2
,pi_comment       varchar2
,pi_message_type  varchar2
) is

    c_proc    constant varchar2(100) := 'CATER_MESSAGE_NEW.email_job_by_id: ';
    c_user                       constant varchar2(100) := nvl(v('APP_USER'),user);
    c_now                        constant date := sysdate;
    c_trans_id                   varchar2(100) := dbms_transaction.local_transaction_id;

    l_to               varchar2(1000);
--    l_job_rec          art_jobs%rowtype;
    l_job_rec_new          SYS_REFCURSOR;
    l_job_rec_old          jrc;

    l_job_email_id	art_jobs_email.job_email_id%TYPE;

begin

    l_job_email_id := art_jobs_email_seq.nextval;

    l_to := pi_from||';'|| translate(pi_to,':',';');

insert into art_jobs_email
( job_email_id, job_chg_email_chk, job_operation, job_rec_type
, job_user, job_email_datetime, job_email_trans_id, job_email_SESSION
, JOB_ID, AREA_ID, SUBSYSTEM_ID
, PRIORITY_ID, ACCESS_REQ_ID, PPSZONE_ID, WORK_TYPE_ID
, PROB_ID, SHOP_ALT_ID, DIV_CODE_ID, SHOP_MAIN_ID
, BLDGMGR_ID, ASST_BLDGMGR_ID, BUILDING_ID, UPDATEDBY_ID
, CREATED_BY, CREATED_DATE, MODIFIED_BY, MODIFIED_DATE
, STATUS_CHK, DESCRIPTION, CATER_NUMBER
, MICRO, PRIMARY, AGE, REVIEW_COUNT
, LATEST_DATE, REVIEW_DATE, EOIC_PAGE
, SAFETY_FORM_DESCR, DISPLAY_ORDER
, ONGOING_CHK, LOCK_AND_TAG_CHK, ATMOSPHERIC_SAFETY_WCF_CHK, ELEC_SYS_WORK_CTL_FORM_CHK
, RADIATION_WORK_PERMIT_CHK, RADIATION_SAFETY_WCF_CHK, RADIATION_REMOVAL_SURVEY_CHK, UNIT
, SAFETY_ISSUE_CHK, AM_APPROVAL_CHK, START_TIME, ADSO
, MINIMUM_HOURS, TOCO_TIME, TOTAL_TIME, ISSUES
, NUMBER_OF_PERSONS, PERSON_HOURS, MICRO_OTHER, RPFO_SURVEY_CHK
, JOB_STATUS_CHK, JOB_NUMBER, JOB_UPDATED_DATE, JOB_COUNT
, JOB_PRIORITY_FLAGS, EVENT_NUMBER, CHANNEL, NAME
, DEVICE_COMMON_NAME, COMMENTS, SEARCH_CRITERIA, CHECKBOX_DATE_FLAGGED
, FEEDBACK_COMMENTS, FEEDBACK_PRIORITY_CHK
, DATE_COMPLETED, HOP_CHK, OLD_CREATED_BY, OLD_MODIFIED_BY
, ACCESS_REQUIREMENTS_CHK, TASK_PERSON_ID, AREA_MGR_ID, area_mgr_review_date, area_mgr_review_comments
, SEQUENCE, TODAY_CHK, today_modified_date, REQUIRES_BEAM_CHK, INVASIVE_CHK
, TEST_TIME_NEEDED, INVASIVE_COMMENT, BEAM_COMMENT, TEST_PLAN
, BACKOUT_PLAN, SYSTEMS_AFFECTED, DEPENDENCIES, GROUP_ID
, SYSTEMS_REQUIRED, EMAIL_CHK, RISK_BENEFIT_DESCR, JOB_TYPE_CHK, PPS_INT_HAZ_CHK
) 
select
  l_job_email_id, 2, 'I', 'NEW', c_user, c_now, c_trans_id, userenv('sessionid')
, JOB_ID, AREA_ID, SUBSYSTEM_ID
, PRIORITY_ID, ACCESS_REQ_ID, PPSZONE_ID, WORK_TYPE_ID
, PROB_ID, SHOP_ALT_ID, DIV_CODE_ID, SHOP_MAIN_ID
, BLDGMGR_ID, ASST_BLDGMGR_ID, BUILDING_ID, UPDATEDBY_ID
, CREATED_BY, CREATED_DATE, MODIFIED_BY, MODIFIED_DATE
, STATUS_CHK, DESCRIPTION, CATER_NUMBER
, MICRO, PRIMARY, AGE, REVIEW_COUNT
, LATEST_DATE, REVIEW_DATE, EOIC_PAGE
, SAFETY_FORM_DESCR, DISPLAY_ORDER
, ONGOING_CHK, LOCK_AND_TAG_CHK, ATMOSPHERIC_SAFETY_WCF_CHK, ELEC_SYS_WORK_CTL_FORM_CHK
, RADIATION_WORK_PERMIT_CHK, RADIATION_SAFETY_WCF_CHK, RADIATION_REMOVAL_SURVEY_CHK, UNIT
, SAFETY_ISSUE_CHK, AM_APPROVAL_CHK, START_TIME, ADSO
, MINIMUM_HOURS, TOCO_TIME, TOTAL_TIME, ISSUES
, NUMBER_OF_PERSONS, PERSON_HOURS, MICRO_OTHER, RPFO_SURVEY_CHK
, JOB_STATUS_CHK, JOB_NUMBER, JOB_UPDATED_DATE, JOB_COUNT
, JOB_PRIORITY_FLAGS, EVENT_NUMBER, CHANNEL, NAME
, DEVICE_COMMON_NAME, COMMENTS, SEARCH_CRITERIA, CHECKBOX_DATE_FLAGGED
, FEEDBACK_COMMENTS, FEEDBACK_PRIORITY_CHK
, DATE_COMPLETED, HOP_CHK, OLD_CREATED_BY, OLD_MODIFIED_BY
, ACCESS_REQUIREMENTS_CHK, TASK_PERSON_ID, AREA_MGR_ID, area_mgr_review_date, area_mgr_review_comments
, SEQUENCE, TODAY_CHK, today_modified_date, REQUIRES_BEAM_CHK, INVASIVE_CHK
, TEST_TIME_NEEDED, INVASIVE_COMMENT, BEAM_COMMENT, TEST_PLAN
, BACKOUT_PLAN, SYSTEMS_AFFECTED, DEPENDENCIES, GROUP_ID
, SYSTEMS_REQUIRED, EMAIL_CHK, RISK_BENEFIT_DESCR, JOB_TYPE_CHK, PPS_INT_HAZ_CHK
from art_jobs
where job_id = pi_job_id;

commit;

  OPEN l_job_rec_new FOR
    select *
    from art_jobs_email
    where job_email_id = l_job_email_id
    and job_chg_email_chk = 2
    and rownum = 1;

  OPEN l_job_rec_old FOR
    select *
    from art_jobs_email
    where 1 = 0;
--
  CATER_MESSAGE_NEW.email_cater_job_dtl
    (pi_job_rec_new  => l_job_rec_new
    ,pi_job_rec_old  => l_job_rec_old
    ,pi_operation    => 'I'
    ,pi_from         => pi_from
    ,pi_to           => l_to
    ,pi_subject      => pi_subject
    ,pi_comment      => pi_comment
    ,pi_message_type => pi_message_type
    ,pi_call_from    => 'email_job_by_id'
    );

end email_job_by_id;


procedure email_sol_by_id
(pi_sol_id        number
,pi_from          varchar2
,pi_to            varchar2
,pi_subject       varchar2
,pi_comment       varchar2
,pi_message_type  varchar2
,pi_prob_type_chk varchar2
) is

    c_proc            constant varchar2(100) := 'CATER_MESSAGE_NEW.email_sol_by_id ';
    c_user                       constant varchar2(100) := nvl(v('APP_USER'),user);
    c_now                        constant date := sysdate;
    c_trans_id                   varchar2(100) := dbms_transaction.local_transaction_id;

--    l_sol_rec art_solutions%rowtype;
    l_sol_rec_new    SYS_REFCURSOR;
    l_sol_rec_old    src;
    l_to          varchar2(500);
    l_sol_email_id	art_solutions_email.sol_email_id%TYPE;

begin
    l_sol_email_id := art_solutions_email_seq.nextval;

    l_to := pi_from||';'|| translate(pi_to,':',';');


insert into art_solutions_email
( sol_email_id, sol_chg_email_chk, sol_operation, sol_rec_type
, sol_user, sol_email_datetime, sol_email_trans_id, sol_email_SESSION
, sol_id, div_code_id, sol_type_id
, prob_id, solvedby_id, updatedby_id, draw_id
, created_by, created_date, modified_by, modified_date
, module_changed, facility_changed, solution_count, solution_number
, module, old_serial_number, new_serial_number, description
, display_changed, documentation_solution, solve_hours, review_to_close_chk
, date_rtc_checked, attachment_history, feedback_comments, feedback_priority_chk
, old_solverby_id, old_modifiedby_id
, task_title, task_priority_chk, task_skill
, task_start_date, task_end_date, task_percent_complete
, subsystem_id, shop_main_id, email_chk, sol_type_chk
)
select
 l_sol_email_id, 2, 'I', 'NEW', c_user, c_now, c_trans_id, userenv('sessionid')
, sol_id, div_code_id, sol_type_id
, prob_id, solvedby_id, updatedby_id, draw_id
, created_by, created_date, modified_by, modified_date
, module_changed, facility_changed, solution_count, solution_number
, module, old_serial_number, new_serial_number, description
, display_changed, documentation_solution, solve_hours, review_to_close_chk
, date_rtc_checked, attachment_history, feedback_comments, feedback_priority_chk
, old_solverby_id, old_modifiedby_id
, task_title, task_priority_chk, task_skill
, task_start_date, task_end_date, task_percent_complete
, subsystem_id, shop_main_id, email_chk, sol_type_chk
from art_solutions
where sol_id = pi_sol_id;

commit;

  OPEN l_sol_rec_new FOR
    select *
    from art_solutions_email
    where sol_email_id = l_sol_email_id
    and sol_chg_email_chk = 2
    and rownum = 1;

  OPEN l_sol_rec_old FOR
    select *
    from art_solutions_email
    where 1 = 0;
--
    CATER_MESSAGE_NEW.email_cater_sol_dtl
    (pi_sol_rec_new   => l_sol_rec_new
    ,pi_sol_rec_old   => l_sol_rec_old
    ,pi_operation     => 'I'
    ,pi_from          => pi_from
    ,pi_to            => l_to
    ,pi_subject       => pi_subject
    ,pi_comment       => pi_comment
    ,pi_message_type  => pi_message_type
    ,pi_prob_type_chk => pi_prob_type_chk
    ,pi_call_from     => 'email_sol_by_id'
    );

end  email_sol_by_id;

--
-- message body content
--

procedure sw_prob_message_body_content
(pi_prob_rec_new      in  art_problems_email%rowtype
,pi_prob_rec_old      in  art_problems_email%rowtype
,pi_message_type      in  varchar2
,pi_apex_url_prefix   in  varchar2
,pi_html_message_body in  clob
,pi_text_message_body in  clob
,po_html_message_body out clob
,po_text_message_body out clob
) is

    c_proc               constant varchar2(100) := 'CATER_MESSAGE_NEW.sw_prob_message_body_content ';

    l_html_message_body            clob := pi_html_message_body;
    l_text_message_body            clob := pi_text_message_body;
    l_line_number                  pls_integer := 0;
    l_description_old              varchar2(500);
    l_description_new              varchar2(500);
    l_watch_and_wait_comment_old   varchar2(500);
    l_watch_and_wait_comment_new   varchar2(500);
    l_area_mgr_review_comments_old varchar2(500);
    l_area_mgr_review_comments_new varchar2(500);
    l_error_message_old            varchar2(500);
    l_error_message_new            varchar2(500);

  l_prob_rec_new  art_problems_email%rowtype;
  l_prob_rec_old  art_problems_email%rowtype;

begin

  l_prob_rec_new := pi_prob_rec_new;
  l_prob_rec_old := pi_prob_rec_old;

    l_description_old := text_overflow(l_prob_rec_old.description,c_max_textarea_length);
    l_description_new := text_overflow(l_prob_rec_new.description,c_max_textarea_length);

    l_description_old              := text_overflow(l_prob_rec_old.description,c_max_textarea_length);
    l_description_new              := text_overflow(l_prob_rec_new.description,c_max_textarea_length);

    l_watch_and_wait_comment_old   := text_overflow(l_prob_rec_old.watch_and_wait_comment,c_max_textarea_length);
    l_watch_and_wait_comment_new   := text_overflow(l_prob_rec_new.watch_and_wait_comment,c_max_textarea_length);

    l_area_mgr_review_comments_old := text_overflow(l_prob_rec_old.area_mgr_review_comments,c_max_textarea_length);
    l_area_mgr_review_comments_new := text_overflow(l_prob_rec_new.area_mgr_review_comments,c_max_textarea_length);

    l_error_message_old := text_overflow(l_prob_rec_old.error_message,c_max_textarea_length);
    l_error_message_new := text_overflow(l_prob_rec_new.error_message,c_max_textarea_length);

--    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'SW CATER Id',                 pi_old=>l_prob_rec_old.prob_id,                                     pi_new=>l_prob_rec_new.prob_id,                                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'CATER Id',                 pi_old=>l_prob_rec_old.prob_id,                                     pi_new=>l_prob_rec_new.prob_id,                                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
-- Poonam 10/14/14 - Added the Cater Title
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Title',                       pi_old=>l_prob_rec_old.problem_title,                               pi_new=>l_prob_rec_new.problem_title,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Status',                      pi_old=>getval('PROB_STATUS',l_prob_rec_old.status_chk),            pi_new=>getval('PROB_STATUS',l_prob_rec_new.status_chk),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
-- Poonam 10/14/14 - Added the new Cater SubType
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'CATER SubType',               pi_old=>getval('CATER_SUBTYPE',l_prob_rec_old.prob_type_dtl_id),    pi_new=>getval('CATER_SUBTYPE',l_prob_rec_new.prob_type_dtl_id),    pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Division',                    pi_old=>getval('DIV_CODE',l_prob_rec_old.div_code_id),              pi_new=>getval('DIV_CODE',l_prob_rec_new.div_code_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Description',                 pi_old=>l_description_old,                                           pi_new=>l_description_new,                                           pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Assigned To',                 pi_old=>getval('NAME',l_prob_rec_old.assignedto_id),                pi_new=>getval('NAME',l_prob_rec_new.assignedto_id),                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Area',                        pi_old=>getval('AREA',l_prob_rec_old.area_id),                      pi_new=>getval('AREA',l_prob_rec_new.area_id),                      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Area Mgr',                    pi_old=>getval('NAME',l_prob_rec_old.areamgr_id),                   pi_new=>getval('NAME',l_prob_rec_new.areamgr_id),                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Subsystem',                   pi_old=>getval('SUBSYSTEM',l_prob_rec_old.subsystem_id),            pi_new=>getval('SUBSYSTEM',l_prob_rec_new.subsystem_id),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Main Shop',                   pi_old=>getval('SHOP',l_prob_rec_old.shop_main_id),                 pi_new=>getval('SHOP',l_prob_rec_new.shop_main_id),                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Alt Shop',                    pi_old=>getval('SHOP',l_prob_rec_old.shop_alt_id),                  pi_new=>getval('SHOP',l_prob_rec_new.shop_alt_id),                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Urgency',                     pi_old=>l_prob_rec_old.urgency,                                     pi_new=>l_prob_rec_new.urgency,                                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'HOP',                         pi_old=>getval('YESNO',l_prob_rec_old.hop_chk),                     pi_new=>getval('YESNO',l_prob_rec_new.hop_chk),                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Watch and Wait Date',         pi_old=>to_char(l_prob_rec_old.watch_and_wait_date,c_date_format),  pi_new=>to_char(l_prob_rec_new.watch_and_wait_date,c_date_format),  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Watch and Wait Comment',      pi_old=>l_watch_and_wait_comment_old,                                pi_new=>l_watch_and_wait_comment_new,                                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Display',                     pi_old=>l_prob_rec_old.display,                                     pi_new=>l_prob_rec_new.display,                                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Facility',                    pi_old=>getval('FACILITY',l_prob_rec_old.facility_id),              pi_new=>getval('FACILITY',l_prob_rec_new.facility_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Terminal Type',               pi_old=>l_prob_rec_old.terminal_type,                               pi_new=>l_prob_rec_new.terminal_type,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Reproducible',                pi_old=>getval('YESNO',l_prob_rec_old.reproducible_chk),            pi_new=>getval('YESNO',l_prob_rec_new.reproducible_chk),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Estimated Hrs',               pi_old=>l_prob_rec_old.estimated_hrs,                               pi_new=>l_prob_rec_new.estimated_hrs,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Area Mgr Rev Date',           pi_old=>to_char(l_prob_rec_old.area_mgr_review_date,c_date_format), pi_new=>to_char(l_prob_rec_new.area_mgr_review_date,c_date_format), pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Area Mgr Rev Comments',       pi_old=>l_area_mgr_review_comments_old,                              pi_new=>l_area_mgr_review_comments_new,                              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Error Message',               pi_old=>l_error_message_old,                                         pi_new=>l_error_message_new,                                         pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Closer',                      pi_old=>getval('NAME',l_prob_rec_old.closer_id),                    pi_new=>getval('NAME',l_prob_rec_new.closer_id),                    pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Created By',                  pi_old=>l_prob_rec_old.created_by,                                  pi_new=>l_prob_rec_new.created_by,                                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
-- Poonam - Modified to not display old and new Created_Date, as they are somehow different. Displays only the NEW Created date.
-- Poonam - 1/13/2014 - Reverted to original code, as problem was in the App.
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Created Date',                pi_old=>l_prob_rec_old.created_date,                                pi_new=>l_prob_rec_new.created_date,                                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Modified By',                 pi_old=>l_prob_rec_old.modified_by,                                 pi_new=>l_prob_rec_new.modified_by,                                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Modified Date',               pi_old=>l_prob_rec_old.modified_date,                               pi_new=>l_prob_rec_new.modified_date,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);

    po_html_message_body := l_html_message_body;
    po_text_message_body := l_text_message_body;

end sw_prob_message_body_content;


procedure hw_prob_message_body_content
(pi_prob_rec_new      in  art_problems_email%rowtype
,pi_prob_rec_old      in  art_problems_email%rowtype
,pi_message_type      in  varchar2
,pi_apex_url_prefix   in  varchar2
,pi_html_message_body in  clob
,pi_text_message_body in  clob
,po_html_message_body out clob
,po_text_message_body out clob
) is

    c_proc               constant varchar2(100)   := 'CATER_MESSAGE_NEW.hw_prob_message_body_content ';

    l_html_message_body            clob        := pi_html_message_body;
    l_text_message_body            clob        := pi_text_message_body;
    l_line_number                  pls_integer := 0;
    l_description_old              varchar2(500);
    l_description_new              varchar2(500);
    l_watch_and_wait_comment_old   varchar2(500);
    l_watch_and_wait_comment_new   varchar2(500);
    l_area_mgr_review_comments_old varchar2(500);
    l_area_mgr_review_comments_new varchar2(500);

  l_prob_rec_new  art_problems_email%rowtype;
  l_prob_rec_old  art_problems_email%rowtype;

begin

  l_prob_rec_new := pi_prob_rec_new;
  l_prob_rec_old := pi_prob_rec_old;

    l_description_old              := text_overflow(l_prob_rec_old.description,c_max_textarea_length);
    l_description_new              := text_overflow(l_prob_rec_new.description,c_max_textarea_length);

    l_watch_and_wait_comment_old   := text_overflow(l_prob_rec_old.watch_and_wait_comment,c_max_textarea_length);
    l_watch_and_wait_comment_new   := text_overflow(l_prob_rec_new.watch_and_wait_comment,c_max_textarea_length);

    l_area_mgr_review_comments_old := text_overflow(l_prob_rec_old.area_mgr_review_comments,c_max_textarea_length);
    l_area_mgr_review_comments_new := text_overflow(l_prob_rec_new.area_mgr_review_comments,c_max_textarea_length);

-- Meking it generic CATER Id
--    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'HW CATER Id',              pi_old=>l_prob_rec_old.prob_id,                                     pi_new=>l_prob_rec_new.prob_id,                                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'CATER Id',                 pi_old=>l_prob_rec_old.prob_id,                                     pi_new=>l_prob_rec_new.prob_id,                                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
-- Poonam 10/14/14 - Added the Cater Title
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Title',                       pi_old=>l_prob_rec_old.problem_title,                               pi_new=>l_prob_rec_new.problem_title,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Description',                 pi_old=>l_description_old,                                           pi_new=>l_description_new,                                           pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Status',                      pi_old=>getval('PROB_STATUS',l_prob_rec_old.status_chk),            pi_new=>getval('PROB_STATUS',l_prob_rec_new.status_chk),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
-- Poonam 10/14/14 - Added the new Cater SubType
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'CATER SubType',               pi_old=>getval('CATER_SUBTYPE',l_prob_rec_old.prob_type_dtl_id),    pi_new=>getval('CATER_SUBTYPE',l_prob_rec_new.prob_type_dtl_id),    pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    --message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'CATER Type',                  pi_old=>l_prob_rec_old.prob_type_chk,                               pi_new=>l_prob_rec_new.prob_type_chk,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Division',                    pi_old=>getval('DIV_CODE',l_prob_rec_old.div_code_id),              pi_new=>getval('DIV_CODE',l_prob_rec_new.div_code_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Assigned To',                 pi_old=>getval('NAME',l_prob_rec_old.assignedto_id),                pi_new=>getval('NAME',l_prob_rec_new.assignedto_id),                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Area',                        pi_old=>getval('AREA',l_prob_rec_old.area_id),                      pi_new=>getval('AREA',l_prob_rec_new.area_id),                      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Area Mgr',                    pi_old=>getval('NAME',l_prob_rec_old.areamgr_id),                   pi_new=>getval('NAME',l_prob_rec_new.areamgr_id),                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Subsystem',                   pi_old=>getval('SUBSYSTEM',l_prob_rec_old.subsystem_id),            pi_new=>getval('SUBSYSTEM',l_prob_rec_new.subsystem_id),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Main Shop',                   pi_old=>getval('SHOP',l_prob_rec_old.shop_main_id),                 pi_new=>getval('SHOP',l_prob_rec_new.shop_main_id),                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Alt Shop',                    pi_old=>getval('SHOP',l_prob_rec_old.shop_alt_id),                  pi_new=>getval('SHOP',l_prob_rec_new.shop_alt_id),                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Micro',                       pi_old=>l_prob_rec_old.micro,                                       pi_new=>l_prob_rec_new.micro,                                       pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Primary',                     pi_old=>l_prob_rec_old.primary,                                     pi_new=>l_prob_rec_new.primary,                                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Unit',                        pi_old=>l_prob_rec_old.unit,                                        pi_new=>l_prob_rec_new.unit,                                        pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'PV Name',                     pi_old=>l_prob_rec_old.pv_name,                                     pi_new=>l_prob_rec_new.pv_name,                                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Urgency',                     pi_old=>l_prob_rec_old.urgency,                                     pi_new=>l_prob_rec_new.urgency,                                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Action Item Review Date',     pi_old=>to_char(l_prob_rec_old.review_date,c_date_format),          pi_new=>to_char(l_prob_rec_new.review_date,c_date_format),          pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'HOP',                         pi_old=>getval('YESNO',l_prob_rec_old.hop_chk),                     pi_new=>getval('YESNO',l_prob_rec_new.hop_chk),                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Watch and Wait Comment',      pi_old=>l_watch_and_wait_comment_old,                                pi_new=>l_watch_and_wait_comment_new,                                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Date Due Next',               pi_old=>to_char(l_prob_rec_old.date_due_next,c_date_format),        pi_new=>to_char(l_prob_rec_new.date_due_next,c_date_format),        pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Watch and Wait Date',         pi_old=>to_char(l_prob_rec_old.watch_and_wait_date,c_date_format),  pi_new=>to_char(l_prob_rec_new.watch_and_wait_date,c_date_format),  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'CEF Request Submitted',       pi_old=>getval('YESNO',l_prob_rec_old.cef_request_submitted_chk),   pi_new=>getval('YESNO',l_prob_rec_new.cef_request_submitted_chk),   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    --message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'CEF Tracking Number',         pi_old=>getval('YESNO',l_prob_rec_old.cef_tracking_no),             pi_new=>getval('YESNO',l_prob_rec_new.cef_tracking_no),             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'CEF Tracking Number',         pi_old=>l_prob_rec_old.cef_tracking_no,                             pi_new=>l_prob_rec_new.cef_tracking_no,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Building',                    pi_old=>getval('BUILDING',l_prob_rec_old.building_id),              pi_new=>getval('BUILDING',l_prob_rec_new.building_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Bldg Mgr',                    pi_old=>getval('NAME',l_prob_rec_old.bldgmgr_id),                   pi_new=>getval('NAME',l_prob_rec_new.bldgmgr_id),                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Asst Bldg Mgr',               pi_old=>getval('NAME',l_prob_rec_old.asst_bldgmgr_id),              pi_new=>getval('NAME',l_prob_rec_new.asst_bldgmgr_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Facility',                    pi_old=>getval('FACILITY',l_prob_rec_old.facility_id),              pi_new=>getval('FACILITY',l_prob_rec_new.facility_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Estimated Hrs',               pi_old=>l_prob_rec_old.estimated_hrs,                               pi_new=>l_prob_rec_new.estimated_hrs,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Area Mgr Rev Date',           pi_old=>to_char(l_prob_rec_old.area_mgr_review_date,c_date_format), pi_new=>to_char(l_prob_rec_new.area_mgr_review_date,c_date_format), pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Area Mgr Rev Comments',       pi_old=>l_area_mgr_review_comments_old,                              pi_new=>l_area_mgr_review_comments_new,                              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Created By',                  pi_old=>l_prob_rec_old.created_by,                                  pi_new=>l_prob_rec_new.created_by,                                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Created Date',                pi_old=>l_prob_rec_old.created_date,                                pi_new=>l_prob_rec_new.created_date,                                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Modified By',                 pi_old=>l_prob_rec_old.modified_by,                                 pi_new=>l_prob_rec_new.modified_by,                                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Modified Date',               pi_old=>l_prob_rec_old.modified_date,                               pi_new=>l_prob_rec_new.modified_date,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);

    po_html_message_body := l_html_message_body;
    po_text_message_body := l_text_message_body;

end hw_prob_message_body_content;


procedure request_message_body_content
(pi_prob_rec_new      in  art_problems_email%rowtype
,pi_prob_rec_old      in  art_problems_email%rowtype
,pi_message_type      in  varchar2
,pi_apex_url_prefix   in  varchar2
,pi_html_message_body in  clob
,pi_text_message_body in  clob
,po_html_message_body out clob
,po_text_message_body out clob
) is

    c_proc               constant varchar2(100)   := 'CATER_MESSAGE_NEW.request_message_body_content ';

    l_html_message_body           clob        := pi_html_message_body;
    l_text_message_body           clob        := pi_text_message_body;
    l_line_number                 pls_integer := 0;
    l_description_old             varchar2(500);
    l_description_new             varchar2(500);

  l_prob_rec_new  art_problems_email%rowtype;
  l_prob_rec_old  art_problems_email%rowtype;

begin

  l_prob_rec_new := pi_prob_rec_new;
  l_prob_rec_old := pi_prob_rec_old;

    l_description_old := text_overflow(l_prob_rec_old.description,c_max_textarea_length);
    l_description_new := text_overflow(l_prob_rec_new.description,c_max_textarea_length);

-- Meking it generic CATER Id
--    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Request Id',                  pi_old=>l_prob_rec_old.prob_id,                                     pi_new=>l_prob_rec_new.prob_id,                                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'CATER Id',                  pi_old=>l_prob_rec_old.prob_id,                                     pi_new=>l_prob_rec_new.prob_id,                                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Title',                       pi_old=>l_prob_rec_old.problem_title,                               pi_new=>l_prob_rec_new.problem_title,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Status',                      pi_old=>getval('PROB_STATUS',l_prob_rec_old.status_chk),            pi_new=>getval('PROB_STATUS',l_prob_rec_new.status_chk),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
-- Poonam 10/14/14 - Added the new Cater SubType
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'CATER SubType',               pi_old=>getval('CATER_SUBTYPE',l_prob_rec_old.prob_type_dtl_id),    pi_new=>getval('CATER_SUBTYPE',l_prob_rec_new.prob_type_dtl_id),    pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    --message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'CATER Type',                  pi_old=>l_prob_rec_old.prob_type_chk,                               pi_new=>l_prob_rec_new.prob_type_chk,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Assigned To',                 pi_old=>getval('NAME',l_prob_rec_old.assignedto_id),                pi_new=>getval('NAME',l_prob_rec_new.assignedto_id),                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Division',                    pi_old=>getval('DIV_CODE',l_prob_rec_old.div_code_id),              pi_new=>getval('DIV_CODE',l_prob_rec_new.div_code_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Area',                        pi_old=>getval('AREA',l_prob_rec_old.area_id),                      pi_new=>getval('AREA',l_prob_rec_new.area_id),                      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Area Mgr',                    pi_old=>getval('NAME',l_prob_rec_old.areamgr_id),                   pi_new=>getval('NAME',l_prob_rec_new.areamgr_id),                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Subsystem',                   pi_old=>getval('SUBSYSTEM',l_prob_rec_old.subsystem_id),            pi_new=>getval('SUBSYSTEM',l_prob_rec_new.subsystem_id),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Main Shop',                   pi_old=>getval('SHOP',l_prob_rec_old.shop_main_id),                 pi_new=>getval('SHOP',l_prob_rec_new.shop_main_id),                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Assigned To Person',          pi_old=>getval('NAME',l_prob_rec_old.assignedto_id),                pi_new=>getval('NAME',l_prob_rec_new.assignedto_id),                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Priority',                    pi_old=>getval('PRIORITY',l_prob_rec_old.priority_chk),             pi_new=>getval('PRIORITY',l_prob_rec_new.priority_chk),             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Description',                 pi_old=>l_description_old,                                           pi_new=>l_description_new,                                           pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Estimated Hrs',               pi_old=>l_prob_rec_old.estimated_hrs,                               pi_new=>l_prob_rec_new.estimated_hrs,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Created By',                  pi_old=>l_prob_rec_old.created_by,                                  pi_new=>l_prob_rec_new.created_by,                                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Created Date',                pi_old=>l_prob_rec_old.created_date,                                pi_new=>l_prob_rec_new.created_date,                                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Modified By',                 pi_old=>l_prob_rec_old.modified_by,                                 pi_new=>l_prob_rec_new.modified_by,                                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_prob_rec_new.prob_id,pi_prob_type_chk=>l_prob_rec_new.prob_type_chk,pi_label=>'Modified Date',               pi_old=>l_prob_rec_old.modified_date,                               pi_new=>l_prob_rec_new.modified_date,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);

    po_html_message_body := l_html_message_body;
    po_text_message_body := l_text_message_body;

end request_message_body_content;


procedure rsw_message_body_content
(pi_rsw_rec_new       in  rsw_form%rowtype
,pi_rsw_rec_old       in  rsw_form%rowtype
,pi_message_type      in  varchar2
,pi_apex_url_prefix   in  varchar2
,pi_html_message_body in  clob
,pi_text_message_body in  clob
,po_html_message_body out clob
,po_text_message_body out clob
) is

    c_proc               constant varchar2(100) := 'CATER_MESSAGE_NEW.rsw_message_body_content ';

    l_html_message_body           clob := pi_html_message_body;
    l_text_message_body           clob := pi_text_message_body;
    l_line_number                 pls_integer := 0;
    l_description_old             varchar2(500);
    l_description_new             varchar2(500);

begin

    l_description_old := text_overflow(pi_rsw_rec_old.s1_descr,c_max_textarea_length);
    l_description_new := text_overflow(pi_rsw_rec_new.s1_descr,c_max_textarea_length);

    message_body_line(pi_prob_id=>pi_rsw_rec_new.prob_id,pi_form_id=>pi_rsw_rec_new.form_id,pi_label=>'Rad Safety Form Id',pi_old=>pi_rsw_rec_old.form_id,                                 pi_new=>pi_rsw_rec_new.form_id,                                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>pi_rsw_rec_new.prob_id,pi_form_id=>pi_rsw_rec_new.form_id,pi_label=>'Status',         pi_old=>getval('RAD_FORM_STATUS',pi_rsw_rec_old.form_status_id),pi_new=>getval('RAD_FORM_STATUS',pi_rsw_rec_new.form_status_id),pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>pi_rsw_rec_new.prob_id,pi_form_id=>pi_rsw_rec_new.form_id,pi_label=>'Description',    pi_old=>l_description_old,                                      pi_new=>l_description_new,                                      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>pi_rsw_rec_new.prob_id,pi_form_id=>pi_rsw_rec_new.form_id,pi_label=>'Task Person',    pi_old=>getval('NAME',pi_rsw_rec_old.s1_task_person_id),        pi_new=>getval('NAME',pi_rsw_rec_new.s1_task_person_id),        pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);

    po_html_message_body := l_html_message_body;
    po_text_message_body := l_text_message_body;

end rsw_message_body_content;


procedure sw_job_message_body_content
(pi_job_rec_new       in  art_jobs_email%rowtype
,pi_job_rec_old       in  art_jobs_email%rowtype
,pi_message_type      in  varchar2
,pi_apex_url_prefix   in  varchar2
,pi_html_message_body in  clob
,pi_text_message_body in  clob
,po_html_message_body out clob
,po_text_message_body out clob
) is

    c_proc               constant varchar2(100) := 'CATER_MESSAGE_NEW.sw_job_message_body_content ';

    l_html_message_body           clob        := pi_html_message_body;
    l_text_message_body           clob        := pi_text_message_body;
    l_line_number                 pls_integer := 0;

    l_description_old             varchar2(500);
    l_description_new             varchar2(500);

    l_issues_old                  varchar2(500);
    l_issues_new                  varchar2(500);

    l_comments_old                varchar2(500);
    l_comments_new                varchar2(500);

    l_test_plan_old               varchar2(500);
    l_test_plan_new               varchar2(500);

    l_backout_plan_old            varchar2(500);
    l_backout_plan_new            varchar2(500);

    l_system_required_old         varchar2(500);
    l_system_required_new         varchar2(500);

    l_systems_affected_old        varchar2(500);
    l_systems_affected_new        varchar2(500);

    l_risk_benefit_old            varchar2(500);
    l_risk_benefit_new            varchar2(500);

    l_dependencies_old            varchar2(500);
    l_dependencies_new            varchar2(500);

    l_follow_up_comments_old      varchar2(500);
    l_follow_up_comments_new      varchar2(500);

  l_job_rec_new  art_jobs_email%rowtype;
  l_job_rec_old  art_jobs_email%rowtype;

begin
  l_job_rec_new := pi_job_rec_new;
  l_job_rec_old := pi_job_rec_old;

    l_description_old := text_overflow(l_job_rec_old.description,c_max_textarea_length);
    l_description_new := text_overflow(l_job_rec_new.description,c_max_textarea_length);

    l_issues_old := text_overflow(l_job_rec_old.issues,c_max_textarea_length);
    l_issues_new := text_overflow(l_job_rec_new.issues,c_max_textarea_length);

    l_test_plan_old := text_overflow(l_job_rec_old.test_plan,c_max_textarea_length);
    l_test_plan_new := text_overflow(l_job_rec_new.test_plan,c_max_textarea_length);

    l_backout_plan_old := text_overflow(l_job_rec_old.backout_plan,c_max_textarea_length);
    l_backout_plan_new := text_overflow(l_job_rec_new.backout_plan,c_max_textarea_length);

    l_system_required_old := text_overflow(l_job_rec_old.systems_required,c_max_textarea_length);
    l_system_required_new := text_overflow(l_job_rec_new.systems_required,c_max_textarea_length);

-- Poonam - Fixed the System Affected to be NOT Description
    l_systems_affected_old := text_overflow(l_job_rec_old.systems_affected,c_max_textarea_length);
    l_systems_affected_new := text_overflow(l_job_rec_new.systems_affected,c_max_textarea_length);

    l_risk_benefit_old := text_overflow(l_job_rec_old.risk_benefit_descr,c_max_textarea_length);
    l_risk_benefit_new := text_overflow(l_job_rec_new.risk_benefit_descr,c_max_textarea_length);

    l_dependencies_old := text_overflow(l_job_rec_old.dependencies,c_max_textarea_length);
    l_dependencies_new := text_overflow(l_job_rec_new.dependencies,c_max_textarea_length);

    l_follow_up_comments_old := text_overflow(l_job_rec_old.comments,c_max_textarea_length);
    l_follow_up_comments_new := text_overflow(l_job_rec_new.comments,c_max_textarea_length);

    message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'CATER Id',       pi_old=>l_job_rec_old.prob_id,                                  pi_new=>l_job_rec_new.prob_id,                                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'SW Job Number',       pi_old=>l_job_rec_old.job_number,                                  pi_new=>l_job_rec_new.job_number,                                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Description',         pi_old=>l_description_old,                                          pi_new=>l_description_new,                                          pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Planned Start Time',  pi_old=>to_char(l_job_rec_old.start_time,c_date_time_format),      pi_new=>to_char(l_job_rec_new.start_time,c_date_time_format),      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Status',              pi_old=>getval('JOB_STATUS',l_job_rec_old.status_chk),             pi_new=>getval('JOB_STATUS',l_job_rec_new.status_chk),             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Task Person',         pi_old=>getval('NAME',l_job_rec_old.task_person_id),               pi_new=>getval('NAME',l_job_rec_new.task_person_id),               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    --message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Job Type',            pi_old=>l_job_rec_old.job_type_chk,                                pi_new=>l_job_rec_new.job_type_chk,                                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);

-- Poonam - Changed the Backout Plan to be NOT test Plan
    if pi_message_type != 'RP'
    then
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Division',            pi_old=>getval('DIV_CODE',l_job_rec_old.div_code_id),              pi_new=>getval('DIV_CODE',l_job_rec_new.div_code_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Area',                pi_old=>getval('AREA',l_job_rec_old.area_id),                      pi_new=>getval('AREA',l_job_rec_new.area_id),                      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Job Title',           pi_old=>l_job_rec_old.name,                                        pi_new=>l_job_rec_new.name,                                        pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Shop Main',           pi_old=>getval('SHOP',l_job_rec_old.shop_main_id),                 pi_new=>getval('SHOP',l_job_rec_new.shop_main_id),                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Approved by CD',      pi_old=>getval('YESNO',l_job_rec_old.am_approval_chk),             pi_new=>getval('YESNO',l_job_rec_new.am_approval_chk),             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Time Needed (hrs)',   pi_old=>to_char(l_job_rec_old.total_time),                         pi_new=>to_char(l_job_rec_new.total_time),                         pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Time Comments',       pi_old=>l_job_rec_old.test_time_needed,                            pi_new=>l_job_rec_new.test_time_needed,                            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Beam Requirements',   pi_old=>getval('BEAM',l_job_rec_old.requires_beam_chk),            pi_new=>getval('BEAM',l_job_rec_new.requires_beam_chk),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Beam Comment',        pi_old=>l_job_rec_old.beam_comment,                                pi_new=>l_job_rec_new.beam_comment,                                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Invasive',            pi_old=>getval('YESNO',l_job_rec_old.invasive_chk),                pi_new=>getval('YESNO',l_job_rec_new.invasive_chk),                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Invasive Comment',    pi_old=>l_job_rec_old.invasive_comment,                            pi_new=>l_job_rec_new.invasive_comment,                            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Scheduling Priority', pi_old=>getval('PRIORITY',l_job_rec_old.priority_id),              pi_new=>getval('PRIORITY',l_job_rec_new.priority_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Area Manager',        pi_old=>getval('NAME',l_job_rec_old.area_mgr_id),                  pi_new=>getval('NAME',l_job_rec_new.area_mgr_id),                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Subsytem',            pi_old=>getval('SUBSYSTEM',l_job_rec_old.subsystem_id),            pi_new=>getval('SUBSYSTEM',l_job_rec_new.subsystem_id),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Work Type',           pi_old=>getval('WORK_TYPE',l_job_rec_new.work_type_id),            pi_new=>getval('WORK_TYPE',l_job_rec_new.work_type_id),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Test Plan',           pi_old=>l_test_plan_old,                                            pi_new=>l_test_plan_new,                                            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Backout Plan',        pi_old=>l_backout_plan_old,                                         pi_new=>l_backout_plan_new,                                         pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Systems Affected',    pi_old=>l_systems_affected_old,                                     pi_new=>l_systems_affected_new,                                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Systems Required',    pi_old=>l_system_required_old,                                      pi_new=>l_system_required_new,                                      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Risk/Benefit',        pi_old=>l_risk_benefit_old,                                         pi_new=>l_risk_benefit_new,                                         pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Dependencies',        pi_old=>l_dependencies_old,                                         pi_new=>l_dependencies_new,                                         pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Issues',              pi_old=>l_issues_old,                                               pi_new=>l_issues_new,                                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Followup Comments',   pi_old=>l_follow_up_comments_old,                                   pi_new=>l_follow_up_comments_new,                                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Date Completed',      pi_old=>getval('YESNO',l_job_rec_old.date_completed),              pi_new=>getval('YESNO',l_job_rec_new.date_completed),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Created By',          pi_old=>l_job_rec_old.created_by,                                  pi_new=>l_job_rec_new.created_by,                                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Created Date',        pi_old=>l_job_rec_old.created_date,                                pi_new=>l_job_rec_new.created_date,                                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Modified By',         pi_old=>l_job_rec_old.modified_by,                                 pi_new=>l_job_rec_new.modified_by,                                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Modified Date',       pi_old=>l_job_rec_old.modified_date,                               pi_new=>l_job_rec_new.modified_date,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    end if;

    po_html_message_body := l_html_message_body;
    po_text_message_body := l_text_message_body;

end sw_job_message_body_content;


procedure hw_job_message_body_content
(pi_job_rec_new       in  art_jobs_email%rowtype
,pi_job_rec_old       in  art_jobs_email%rowtype
,pi_message_type      in  varchar2
,pi_apex_url_prefix   in  varchar2
,pi_html_message_body in  clob
,pi_text_message_body in  clob
,po_html_message_body out clob
,po_text_message_body out clob
) is

    c_proc               constant varchar2(100) := 'CATER_MESSAGE_NEW.hw_job_message_body_content ';

    l_html_message_body           clob        := pi_html_message_body;
    l_text_message_body           clob        := pi_text_message_body;
    l_line_number                 pls_integer := 0;

    l_description_old             varchar2(500);
    l_description_new             varchar2(500);

    l_issues_old                  varchar2(500);
    l_issues_new                  varchar2(500);

    l_comments_old                varchar2(500);
    l_comments_new                varchar2(500);

    l_feedback_comments_old       varchar2(500);
    l_feedback_comments_new       varchar2(500);

  l_job_rec_new  art_jobs_email%rowtype;
  l_job_rec_old  art_jobs_email%rowtype;

begin
  l_job_rec_new := pi_job_rec_new;
  l_job_rec_old := pi_job_rec_old;


    l_description_old       := text_overflow(l_job_rec_old.description,c_max_textarea_length);
    l_description_new       := text_overflow(l_job_rec_new.description,c_max_textarea_length);

    l_issues_old            := text_overflow(l_job_rec_old.issues,c_max_textarea_length);
    l_issues_new            := text_overflow(l_job_rec_new.issues,c_max_textarea_length);

    l_comments_old          := text_overflow(l_job_rec_old.comments,c_max_textarea_length);
    l_comments_new          := text_overflow(l_job_rec_new.comments,c_max_textarea_length);

    l_feedback_comments_old := text_overflow(l_job_rec_old.feedback_comments,c_max_textarea_length);
    l_feedback_comments_new := text_overflow(l_job_rec_new.feedback_comments,c_max_textarea_length);

    message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'CATER Id',       pi_old=>l_job_rec_old.prob_id,                                       pi_new=>l_job_rec_new.prob_id,                                       pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'HW Job Number',       pi_old=>l_job_rec_old.job_number,                                       pi_new=>l_job_rec_new.job_number,                                       pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Description',         pi_old=>l_description_old,                                               pi_new=>l_description_new,                                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Planned Start Time',  pi_old=>to_char(l_job_rec_old.start_time,c_date_time_format),           pi_new=>to_char(l_job_rec_new.start_time,c_date_time_format),           pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Status',              pi_old=>getval('JOB_STATUS',l_job_rec_old.status_chk),                  pi_new=>getval('JOB_STATUS',l_job_rec_new.status_chk),                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Task Person',         pi_old=>getval('NAME',l_job_rec_old.task_person_id),                    pi_new=>getval('NAME',l_job_rec_new.task_person_id),                    pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Rad Safety Form Status',     pi_old=>getval('YESNO',nvl(l_job_rec_old.radiation_safety_wcf_chk,'Y')),pi_new=>getval('YESNO',nvl(l_job_rec_new.radiation_safety_wcf_chk,'Y')),pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    --message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Rad Safety Form',     pi_old=>getval('YESNO',l_job_rec_old.radiation_safety_wcf_chk),pi_new=>getval('YESNO',l_job_rec_new.radiation_safety_wcf_chk),pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);

    if pi_message_type != 'RP' -- abbreviate if this is a problem level email
    then
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Division',            pi_old=>getval('DIV_CODE',l_job_rec_old.div_code_id),              pi_new=>getval('DIV_CODE',l_job_rec_new.div_code_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Priority',            pi_old=>getval('PRIORITY',l_job_rec_old.priority_id),              pi_new=>getval('PRIORITY',l_job_rec_new.priority_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Area',                pi_old=>getval('AREA',l_job_rec_old.area_id),                      pi_new=>getval('AREA',l_job_rec_new.area_id),                      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Area Manager',        pi_old=>getval('NAME',l_job_rec_old.area_mgr_id),                  pi_new=>getval('NAME',l_job_rec_new.area_mgr_id),                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Release Conditions Defined',         pi_old=>getval('AM_APPROVAL',l_job_rec_old.am_approval_chk),             pi_new=>getval('AM_APPROVAL',l_job_rec_new.am_approval_chk),             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
--        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'AM Approval',         pi_old=>getval('AM_APPROVAL',l_job_rec_old.am_approval_chk),             pi_new=>getval('AM_APPROVAL',l_job_rec_new.am_approval_chk),             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Subsytem',            pi_old=>getval('SUBSYSTEM',l_job_rec_old.subsystem_id),            pi_new=>getval('SUBSYSTEM',l_job_rec_new.subsystem_id),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Shop Main',           pi_old=>getval('SHOP',l_job_rec_old.shop_main_id),                 pi_new=>getval('SHOP',l_job_rec_new.shop_main_id),                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Shop Alt',            pi_old=>getval('SHOP',l_job_rec_old.shop_alt_id),                  pi_new=>getval('SHOP',l_job_rec_new.shop_alt_id),                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Total Time',          pi_old=>l_job_rec_old.total_time,                                  pi_new=>l_job_rec_new.total_time,                                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Person Hours',        pi_old=>l_job_rec_old.person_hours,                                pi_new=>l_job_rec_new.person_hours,                                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Access Req',          pi_old=>getval('ACCESS_REQ',l_job_rec_old.access_req_id),          pi_new=>getval('ACCESS_REQ',l_job_rec_new.access_req_id),          pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'RPFO Survey',         pi_old=>getval('YESNO',l_job_rec_old.rpfo_survey_chk),             pi_new=>getval('YESNO',l_job_rec_new.rpfo_survey_chk),             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Rad Work Permit',     pi_old=>getval('YESNO',l_job_rec_old.radiation_work_permit_chk),   pi_new=>getval('YESNO',l_job_rec_new.radiation_work_permit_chk),   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Lock and Tag',        pi_old=>getval('YESNO',l_job_rec_old.lock_and_tag_chk),            pi_new=>getval('YESNO',l_job_rec_new.lock_and_tag_chk),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Building',            pi_old=>getval('BUILDING',l_job_rec_old.building_id),              pi_new=>getval('BUILDING',l_job_rec_new.building_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Bldg Mgr',            pi_old=>getval('NAME',l_job_rec_old.bldgmgr_id),                   pi_new=>getval('NAME',l_job_rec_new.bldgmgr_id),                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Review Date',         pi_old=>to_char(l_job_rec_old.review_date,c_date_format),          pi_new=>to_char(l_job_rec_new.review_date,c_date_format),          pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Work Type',           pi_old=>getval('WORK_TYPE',l_job_rec_old.work_type_id),            pi_new=>getval('WORK_TYPE',l_job_rec_new.work_type_id),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'PPS Zone',            pi_old=>getval('PPSZONE',l_job_rec_old.ppszone_id),                pi_new=>getval('PPSZONE',l_job_rec_new.ppszone_id),                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Rad Rem Survey',      pi_old=>getval('YESNO',l_job_rec_old.radiation_removal_survey_chk),pi_new=>getval('YESNO',l_job_rec_new.radiation_removal_survey_chk),pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
-- Poonam 10/21/2014 : Added the new column PPS_INT_HAZ_CHK
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'PPS Interlocked Hazard Checkout',      pi_old=>getval('YESNO',l_job_rec_old.PPS_INT_HAZ_CHK),pi_new=>getval('YESNO',l_job_rec_new.PPS_INT_HAZ_CHK),pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
	message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Elec Sys Work Frm',   pi_old=>getval('YESNO',l_job_rec_old.elec_sys_work_ctl_form_chk),  pi_new=>getval('YESNO',l_job_rec_new.elec_sys_work_ctl_form_chk),  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Asst Bldg Mgr',       pi_old=>getval('NAME',l_job_rec_old.asst_bldgmgr_id),              pi_new=>getval('NAME',l_job_rec_new.asst_bldgmgr_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Issues',              pi_old=>l_issues_old,                                               pi_new=>l_issues_new,                                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Comments',            pi_old=>l_comments_old,                                             pi_new=>l_comments_new,                                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Min Hours',           pi_old=>l_job_rec_old.minimum_hours,                               pi_new=>l_job_rec_new.minimum_hours,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'# Persons',           pi_old=>l_job_rec_old.number_of_persons,                           pi_new=>l_job_rec_new.number_of_persons,                           pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Safety Issues',       pi_old=>getval('YESNO',l_job_rec_old.safety_issue_chk),            pi_new=>getval('YESNO',l_job_rec_new.safety_issue_chk),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Toco Time',           pi_old=>l_job_rec_old.toco_time,                                   pi_new=>l_job_rec_new.toco_time,                                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Atmos Safety',        pi_old=>getval('YESNO',l_job_rec_old.atmospheric_safety_wcf_chk),  pi_new=>getval('YESNO',l_job_rec_new.atmospheric_safety_wcf_chk),  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Micro',               pi_old=>l_job_rec_old.micro,                                       pi_new=>l_job_rec_new.micro,                                       pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Primary',             pi_old=>l_job_rec_old.primary,                                     pi_new=>l_job_rec_new.primary,                                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Unit',                pi_old=>l_job_rec_old.unit,                                        pi_new=>l_job_rec_new.unit,                                        pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Ongoing',             pi_old=>getval('YESNO',l_job_rec_old.ongoing_chk),                 pi_new=>getval('YESNO',l_job_rec_new.ongoing_chk),                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
-- Poonam - Why do we need this since we already have a Yes/No above ????
--        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'RSWCF',               pi_old=>l_job_rec_old.radiation_safety_wcf_chk,                    pi_new=>l_job_rec_new.radiation_safety_wcf_chk,                    pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Created By',          pi_old=>l_job_rec_old.created_by,                                  pi_new=>l_job_rec_new.created_by,                                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Created Date',        pi_old=>l_job_rec_old.created_date,                                pi_new=>l_job_rec_new.created_date,                                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Modified By',         pi_old=>l_job_rec_old.modified_by,                                 pi_new=>l_job_rec_new.modified_by,                                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_job_rec_new.prob_id,pi_job_id=>l_job_rec_new.job_id,pi_job_type_chk=>l_job_rec_new.job_type_chk,pi_label=>'Modified Date',       pi_old=>l_job_rec_old.modified_date,                               pi_new=>l_job_rec_new.modified_date,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    end if;

    po_html_message_body := l_html_message_body;
    po_text_message_body := l_text_message_body;

end hw_job_message_body_content;


procedure solution_message_body_content
(pi_sol_rec_new       in  art_solutions_email%rowtype
,pi_sol_rec_old       in  art_solutions_email%rowtype
,pi_message_type      in  varchar2
,pi_apex_url_prefix   in  varchar2
,pi_prob_type_chk     in  varchar2
,pi_html_message_body in  clob
,pi_text_message_body in  clob
,po_html_message_body out clob
,po_text_message_body out clob
) is

    c_proc                   constant varchar2(100)   := 'CATER_MESSAGE_NEW.solution_message_body_content ';

    l_html_message_body               clob        := pi_html_message_body;
    l_text_message_body               clob        := pi_text_message_body;
    l_line_number                     pls_integer := 0;
    l_description_old                 varchar2(500);
    l_description_new                 varchar2(500);

  l_sol_rec_new  art_solutions_email%rowtype;
  l_sol_rec_old  art_solutions_email%rowtype;

begin

  l_sol_rec_new := pi_sol_rec_new;
  l_sol_rec_old := pi_sol_rec_old;

  message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'CATER Id',       pi_old=>l_sol_rec_old.prob_id,                     pi_new=>l_sol_rec_new.prob_id,                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    if pi_prob_type_chk = 'REQUEST'
    then
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Task Number',       pi_old=>l_sol_rec_old.solution_number,                     pi_new=>l_sol_rec_new.solution_number,                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    else
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Solution Number',   pi_old=>l_sol_rec_old.solution_number,                     pi_new=>l_sol_rec_new.solution_number,                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    end if;

    l_description_old := text_overflow(l_sol_rec_old.description,c_max_textarea_length);
    l_description_new := text_overflow(l_sol_rec_new.description,c_max_textarea_length);

    if pi_prob_type_chk = 'REQUEST'
    then

        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Task Title',        pi_old=>l_sol_rec_old.task_title,                          pi_new=>l_sol_rec_new.task_title,                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Assigned To',            pi_old=>getval('NAME',l_sol_rec_old.solvedby_id),          pi_new=>getval('NAME',l_sol_rec_new.solvedby_id),         pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Description',       pi_old=>l_description_old,                                  pi_new=>l_description_new,                                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Effort(Person Hours)',       pi_old=>l_sol_rec_old.SOLVE_HOURS,                      pi_new=>l_sol_rec_new.SOLVE_HOURS,                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Subsystem',         pi_old=>getval('SUBSYSTEM',l_sol_rec_old.subsystem_id),    pi_new=>getval('SUBSYSTEM',l_sol_rec_new.subsystem_id),                       pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Shop',              pi_old=>getval('SHOP',l_sol_rec_old.shop_main_id),         pi_new=>getval('SHOP',l_sol_rec_new.shop_main_id),                              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Task Priority',        pi_old=>l_sol_rec_old.TASK_PRIORITY_CHK,                   pi_new=>l_sol_rec_new.TASK_PRIORITY_CHK,                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Task Skill Set',        pi_old=>l_sol_rec_old.TASK_SKILL,                   pi_new=>l_sol_rec_new.TASK_SKILL,                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Task Start Date',   pi_old=>l_sol_rec_old.task_start_date,                     pi_new=>l_sol_rec_new.task_start_date,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Task End Date',     pi_old=>l_sol_rec_old.task_end_date,                       pi_new=>l_sol_rec_new.task_end_date,              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Percent Complete',     pi_old=>l_sol_rec_old.TASK_PERCENT_COMPLETE,                       pi_new=>l_sol_rec_new.TASK_PERCENT_COMPLETE,              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Complete',          pi_old=>getval('YESNO',nvl(l_sol_rec_old.review_to_close_chk,'N')), pi_new=>getval('YESNO',nvl(l_sol_rec_new.review_to_close_chk,'N')), pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Created By',      pi_old=>l_sol_rec_old.created_by,                     pi_new=>l_sol_rec_new.created_by,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Created Date',      pi_old=>l_sol_rec_old.created_date,                     pi_new=>l_sol_rec_new.created_date,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Modified By',      pi_old=>l_sol_rec_old.modified_by,                     pi_new=>l_sol_rec_new.modified_by,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Modified Date',      pi_old=>l_sol_rec_old.modified_date,                     pi_new=>l_sol_rec_new.modified_date,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    else
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Description',       pi_old=>l_description_old,                                  pi_new=>l_description_new,                                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Solver',            pi_old=>l_sol_rec_old.old_solverby_id,                     pi_new=>l_sol_rec_new.old_solverby_id,                         pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Solve Hours',       pi_old=>l_sol_rec_old.solution_count,                      pi_new=>l_sol_rec_new.solution_count,                      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Solution Type',     pi_old=>getval('SOL_TYPE',l_sol_rec_old.sol_type_id),      pi_new=>getval('SOL_TYPE',l_sol_rec_new.sol_type_id),      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Module',            pi_old=>l_sol_rec_old.module,                              pi_new=>l_sol_rec_new.module,                              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Old Serial Number', pi_old=>l_sol_rec_old.old_serial_number,                   pi_new=>l_sol_rec_new.old_serial_number,                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'New Serial Number', pi_old=>l_sol_rec_old.new_serial_number,                   pi_new=>l_sol_rec_new.new_serial_number,                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Drawing',           pi_old=>l_sol_rec_old.draw_id,                             pi_new=>l_sol_rec_new.draw_id,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Doc',               pi_old=>l_sol_rec_old.documentation_solution,              pi_new=>l_sol_rec_new.documentation_solution,              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Complete',          pi_old=>getval('YESNO',nvl(l_sol_rec_old.review_to_close_chk,'N')), pi_new=>getval('YESNO',nvl(l_sol_rec_new.review_to_close_chk,'N')), pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Created By',      pi_old=>l_sol_rec_old.created_by,                     pi_new=>l_sol_rec_new.created_by,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Created Date',      pi_old=>l_sol_rec_old.created_date,                     pi_new=>l_sol_rec_new.created_date,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Modified By',      pi_old=>l_sol_rec_old.modified_by,                     pi_new=>l_sol_rec_new.modified_by,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>l_sol_rec_new.prob_id,pi_sol_id=>l_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Modified Date',      pi_old=>l_sol_rec_old.modified_date,                     pi_new=>l_sol_rec_new.modified_date,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    end if;

    po_html_message_body := l_html_message_body;
    po_text_message_body := l_text_message_body;

end solution_message_body_content;

procedure check_cater_preferences
(pi_prob_rec_new	in art_problems_email%rowtype
,pi_prob_rec_old	in art_problems_email%rowtype
,pi_table_name		in varchar2
,pi_from         	in varchar2
,pi_operation		in varchar2
,po_user_email		out varchar2
) is 

 c_proc		constant varchar2(100) := 'check_cater_preferences ';

l_email_to      varchar2(2000); --ART_USER_NOTIFICATIONS.EMAIL_TO%TYPE;
l_new_email_to  varchar2(2000); --ART_USER_NOTIFICATIONS.EMAIL_TO%TYPE;

V_ERRMSG	VARCHAR2(1000);
l_prob_rec_new  art_problems_email%rowtype;
l_prob_rec_old  art_problems_email%rowtype;

user_notif_cur  SYS_REFCURSOR;

BEGIN
  l_prob_rec_new := pi_prob_rec_new;
  l_prob_rec_old := pi_prob_rec_old;

IF pi_operation = 'I' THEN
 BEGIN
  OPEN user_notif_cur FOR
   select * from ART_USER_NOTIFICATIONS
   where notif_object = 'CATER' --pi_appl
   and   table_name   = pi_table_name    --'ART_PROBLEMS'
   and   STATUS_AI_CHK = 'A'
   and   NEW_CATER = 'Y'
   union
   select * from ART_USER_NOTIFICATIONS
   where notif_object = 'CATER' --pi_appl
   and   table_name   = pi_table_name    --'ART_PROBLEMS'
   and   STATUS_AI_CHK = 'A'
   and   NEW_CATER is null
   and   DESCRIPTION_CHG is null
   and   EMAIL_WATCHLIST is null
   order by 1;
--
	CATER_MESSAGE_NEW.chk_cater_notif_on_insert
	(pi_prob_rec_new => pi_prob_rec_new
	,pi_prob_rec_old => pi_prob_rec_old
        ,pi_user_notif_rec    => user_notif_cur
	,pi_chg_type     => 'NEW_CATER'
	,po_notif_email   => l_email_to      
        );
--
       IF l_email_to IS NOT NULL THEN
         l_new_email_to := l_email_to ||';'||l_new_email_to;
       END IF;
--
  CLOSE user_notif_cur;
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);
 END;
ELSE 
 IF pi_prob_rec_new.description != pi_prob_rec_old.description THEN
 BEGIN
  OPEN user_notif_cur FOR
   select * from ART_USER_NOTIFICATIONS
   where notif_object = 'CATER' --pi_appl
   and   table_name   = pi_table_name    --'ART_PROBLEMS'
   and   STATUS_AI_CHK = 'A'
   and   DESCRIPTION_CHG = 'Y'
   order by 1;
   --
	CATER_MESSAGE_NEW.chk_cater_notif_on_insert
	(pi_prob_rec_new => pi_prob_rec_new
	,pi_prob_rec_old => pi_prob_rec_old
        ,pi_user_notif_rec    => user_notif_cur
	,pi_chg_type     => 'DESCR_CHG'
	,po_notif_email   => l_email_to      
        );
     IF l_email_to IS NOT NULL THEN
       l_new_email_to := l_email_to ||';'||l_new_email_to;
     END IF;
--
   CLOSE user_notif_cur;
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);
  END;
  END IF;
  --
  BEGIN
  OPEN user_notif_cur FOR
   select * from ART_USER_NOTIFICATIONS
   where notif_object = 'CATER' --pi_appl
   and   table_name   = pi_table_name    --'ART_PROBLEMS'
   and   STATUS_AI_CHK = 'A'
   and   EMAIL_WATCHLIST = 'Y'
   order by 1;

    CATER_MESSAGE_NEW.chk_cater_notif_watchlist
	(pi_prob_rec_new => pi_prob_rec_new
	,pi_prob_rec_old => pi_prob_rec_old
        ,pi_user_notif_rec    => user_notif_cur
	,pi_chg_type     => 'WATCHLIST'
	,po_notif_email   => l_email_to      
        );
     IF l_email_to IS NOT NULL THEN
       l_new_email_to := l_email_to ||';'||l_new_email_to;
     END IF;
   --
   CLOSE user_notif_cur;
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);
  END;
--
  BEGIN
  OPEN user_notif_cur FOR
   select * from ART_USER_NOTIFICATIONS
   where notif_object = 'CATER' --pi_appl
   and   table_name   = pi_table_name    --'ART_PROBLEMS'
   and   STATUS_AI_CHK = 'A'
   and   NEW_CATER is null
   and   DESCRIPTION_CHG is null
   and   EMAIL_WATCHLIST is null
   order by 1;
	CATER_MESSAGE_NEW.chk_cater_notif_on_update
	(pi_prob_rec_new => pi_prob_rec_new
	,pi_prob_rec_old => pi_prob_rec_old
        ,pi_user_notif_rec    => user_notif_cur
	,pi_chg_type     => 'NO_COND'
	,po_notif_email   => l_email_to      
        );
      IF l_email_to IS NOT NULL THEN
        l_new_email_to := l_email_to ||';'||l_new_email_to;
      END IF;
--
   CLOSE user_notif_cur;
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);
  END;
--
END IF;
--
IF substr(trim(l_new_email_to),1,1) = ';' THEN
  l_new_email_to := substr(trim(l_new_email_to),2);
END IF;
--
po_user_email := l_new_email_to;
--
exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);

end check_cater_preferences;

-- Poonam 9/6/2017 - New procedure for Watchlist email preferences
procedure chk_cater_notif_watchlist
(pi_prob_rec_new	in art_problems_email%rowtype
,pi_prob_rec_old	in art_problems_email%rowtype
,pi_user_notif_rec      in notif_rc
,pi_chg_type            in varchar2
,po_notif_email         out varchar2) 
is
--
c_proc   constant	varchar2(100) := 'chk_cater_notif_watchlist ';
C_SQ     CONSTANT	VARCHAR2(1) := CHR(39);
V_ERRMSG		VARCHAR2(1000);

l_email_flag		VARCHAR2(1) := 'N';
l_notif_col_name	ART_USER_NOTIF_COLUMNS.notif_column_alias%TYPE;
l_table_col_name	ART_USER_NOTIF_COLUMNS.notif_column%TYPE;
l_column_yes_no_val	ART_USER_NOTIF_COLUMNS.column_yes_no_val%TYPE;
l_column_datatype	ART_USER_NOTIF_COLUMNS.column_datatype%TYPE;
l_accept		VARCHAR2(1) := '';
l_where_clause		varchar2(4000) := '';
l_sqlstring		varchar2(4000) := '';
-- Increase length in package code before increasing here *************
l_user_email		VARCHAR2(2000);

l_notif_block		varchar2(4000);
l_notif_col_val		VARCHAR2(100);
l_email_block		varchar2(4000);
l_col_val		VARCHAR2(100);

l_user_notif_id		ART_USER_NOTIFICATIONS.USER_NOTIF_ID%TYPE;
l_user_id		ART_USER_NOTIFICATIONS.USER_ID%TYPE;
l_email_to		ART_USER_NOTIFICATIONS.EMAIL_TO%TYPE;

l_watchlist_user_found  NUMBER(1) := 0;

BEGIN
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1,p_text => c_proc || ', pi_chg_type= '|| pi_chg_type);
CATER_MESSAGE_NEW.prob_email_rec_new := pi_prob_rec_new;
CATER_MESSAGE_NEW.prob_email_rec_old := pi_prob_rec_old;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1,p_text => c_proc || ', prob_id= '|| CATER_MESSAGE_NEW.prob_email_rec_new.prob_id);

 <<notif_loop>>
  LOOP
   fetch pi_user_notif_rec into notif_rec;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1,p_text => c_proc || ', notif_rec.user_notif_id= '|| notif_rec.user_notif_id);
   exit when pi_user_notif_rec%NOTFOUND;

   l_where_clause := '';
   l_accept := '';

<<notif_col_loop>>
  FOR  c1_rec in (select notif_column, notif_column_alias,
                         column_yes_no_val, column_datatype
		from ART_USER_NOTIF_COLUMNS
		where notif_table = 'ART_PROBLEMS')
  LOOP
    l_notif_col_name  := c1_rec.notif_column_alias;
    l_table_col_name := c1_rec.notif_column;
    l_column_yes_no_val := c1_rec.column_yes_no_val;
    l_column_datatype := c1_rec.column_datatype;

    l_notif_block := 'begin :1 := CATER_MESSAGE_NEW.notif_rec.'||c1_rec.notif_column_alias||'; end;';

    EXECUTE IMMEDIATE l_notif_block using OUT l_notif_col_val;

    IF l_notif_col_val IS NOT NULL 
    THEN
     IF (l_notif_col_name= 'PROB_STATUS_CHK' and l_notif_col_val= 99) THEN
         l_accept := 'Y';
	 l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '|| l_notif_col_val;
     ELSE
      l_email_block := 'begin :1 := CATER_MESSAGE_NEW.prob_email_rec_new.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block using OUT l_col_val;

      IF l_col_val is null then
        l_accept := 'N';
        exit notif_col_loop; -- Read next row from ART_USER_NOTIFICATIONS
      ELSE
        IF l_col_val = l_notif_col_val THEN
          l_accept := 'Y';
	  --
	  IF l_column_datatype = 'VARCHAR' THEN
           l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '||C_SQ|| l_col_val ||C_SQ;
          ELSIF l_column_datatype = 'NUMBER' THEN
	   l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '|| l_col_val;
          END IF;
	  --
        ELSE
          l_accept := 'N';
	  exit notif_col_loop; -- Read next row from ART_USER_NOTIFICATIONS
	END IF; -- l_col_val = l_notif_col_val
      END IF; -- l_col_val is null 
     END IF; -- l_notif_col_name= 'PROB_STATUS_CHK' and l_notif_col_val= 99
    END IF; -- l_notif_col_val IS NOT NULL 
  END LOOP notif_col_loop; -- c1_rec

IF (l_accept = 'Y' OR l_accept is NULL) THEN
l_sqlstring := 'select user_notif_id, user_id, email_to from art_user_notifications where table_name= ''ART_PROBLEMS'' and STATUS_AI_CHK = ''A'' and EMAIL_WATCHLIST = ''Y''';

 IF l_where_clause IS NOT NULL THEN
  l_where_clause := l_where_clause || ' and user_notif_id = '|| notif_rec.user_notif_id;

  l_sqlstring := l_sqlstring || l_where_clause;
 ELSE
  l_sqlstring := l_sqlstring || ' and user_notif_id = '|| notif_rec.user_notif_id;
 END IF; -- l_where_clause IS NOT NULL
EXECUTE IMMEDIATE l_sqlstring INTO l_user_notif_id, l_user_id, l_email_to;

  BEGIN
      select 1
      into l_watchlist_user_found
      from art_junc_prob_watchlist a
      where a.prob_id = pi_prob_rec_new.prob_id
      and   a.user_id = l_user_id;

      IF l_watchlist_user_found = 1 THEN
        l_user_email := l_user_email ||';'|| GETVAL('EMAIL_ID', l_user_id)||';'||l_email_to;
        l_user_email := trim(';' FROM l_user_email);
        l_watchlist_user_found := 0; 
 insert into temp_notif values (l_user_notif_id, l_user_id,l_user_email, sysdate );
 commit;
      END IF;
  EXCEPTION
   when NO_DATA_FOUND then NULL;
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);
  END;
END IF; -- l_accept = 'Y' OR l_accept is NULL
END LOOP notif_loop;
--
po_notif_email := l_user_email;
--
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1,p_text => c_proc || ', po_notif_email = '|| po_notif_email );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'end');
--
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);

end chk_cater_notif_watchlist;


procedure chk_cater_notif_on_insert
(pi_prob_rec_new	in art_problems_email%rowtype
,pi_prob_rec_old	in art_problems_email%rowtype
,pi_user_notif_rec      in notif_rc
,pi_chg_type            in varchar2
,po_notif_email         out varchar2) 
is
--
c_proc   constant	varchar2(100) := 'chk_cater_notif_on_insert ';
C_SQ     CONSTANT	VARCHAR2(1) := CHR(39);
V_ERRMSG		VARCHAR2(1000);

l_email_flag		VARCHAR2(1) := 'N';
l_notif_col_name	ART_USER_NOTIF_COLUMNS.notif_column_alias%TYPE;
l_table_col_name	ART_USER_NOTIF_COLUMNS.notif_column%TYPE;
l_column_yes_no_val	ART_USER_NOTIF_COLUMNS.column_yes_no_val%TYPE;
l_column_datatype	ART_USER_NOTIF_COLUMNS.column_datatype%TYPE;
l_accept		VARCHAR2(1) := '';
l_where_clause		varchar2(4000) := '';
l_sqlstring		varchar2(4000) := '';
-- Increase length in package code before increasing here *************
l_user_email		VARCHAR2(2000);

l_notif_block		varchar2(4000);
l_notif_col_val		VARCHAR2(100);
l_email_block		varchar2(4000);
l_col_val		VARCHAR2(100);

l_user_notif_id		ART_USER_NOTIFICATIONS.USER_NOTIF_ID%TYPE;
l_user_id		ART_USER_NOTIFICATIONS.USER_ID%TYPE;
l_email_to		ART_USER_NOTIFICATIONS.EMAIL_TO%TYPE;

BEGIN
CATER_MESSAGE_NEW.prob_email_rec_new := pi_prob_rec_new;
CATER_MESSAGE_NEW.prob_email_rec_old := pi_prob_rec_old;
 <<notif_loop>>
  LOOP
   fetch pi_user_notif_rec into notif_rec;
   exit when pi_user_notif_rec%NOTFOUND;

   l_where_clause := '';
   l_accept := '';

<<notif_col_loop>>
  FOR  c1_rec in (select notif_column, notif_column_alias,
                         column_yes_no_val, column_datatype
		from ART_USER_NOTIF_COLUMNS
		where notif_table = 'ART_PROBLEMS')
  LOOP
    l_notif_col_name  := c1_rec.notif_column_alias;
    l_table_col_name := c1_rec.notif_column;
    l_column_yes_no_val := c1_rec.column_yes_no_val;
    l_column_datatype := c1_rec.column_datatype;
/*
      l_email_block := 'begin :1 := CATER_MESSAGE_NEW.prob_email_rec_new.'||c1_rec.notif_column||'; end;';
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1,p_text => c_proc || ', l_email_block= '|| l_email_block);

      EXECUTE IMMEDIATE l_email_block using OUT l_col_val;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1,p_text => c_proc || ', l_col_val= '|| l_col_val );
*/
      l_notif_block := 'begin :1 := CATER_MESSAGE_NEW.notif_rec.'||c1_rec.notif_column_alias||'; end;';

    EXECUTE IMMEDIATE l_notif_block using OUT l_notif_col_val;

    IF l_notif_col_val IS NOT NULL 
    THEN
     IF (l_notif_col_name= 'PROB_STATUS_CHK' and l_notif_col_val= 99) THEN
         l_accept := 'Y';
	 l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '|| l_notif_col_val;
     ELSE
      l_email_block := 'begin :1 := CATER_MESSAGE_NEW.prob_email_rec_new.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block using OUT l_col_val;

      IF l_col_val is null then
        l_accept := 'N';
        exit notif_col_loop; -- Read next row from ART_USER_NOTIFICATIONS
      ELSE
        IF l_col_val = l_notif_col_val THEN
          l_accept := 'Y';
	  --
	  IF l_column_datatype = 'VARCHAR' THEN
           l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '||C_SQ|| l_col_val ||C_SQ;
          ELSIF l_column_datatype = 'NUMBER' THEN
	   l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '|| l_col_val;
          END IF;
	  --
--          l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '|| l_col_val;
        ELSE
          l_accept := 'N';
	  exit notif_col_loop; -- Read next row from ART_USER_NOTIFICATIONS
	END IF; -- l_col_val = l_notif_col_val
      END IF; -- l_col_val is null 
     END IF; -- l_notif_col_name= 'PROB_STATUS_CHK' and l_notif_col_val= 99
    END IF; -- l_notif_col_val IS NOT NULL 
  END LOOP notif_col_loop; -- c1_rec

IF l_accept = 'Y' THEN
 IF l_where_clause IS NOT NULL THEN
  l_where_clause := l_where_clause || ' and user_notif_id = '|| notif_rec.user_notif_id;
  l_sqlstring := 'select user_notif_id, user_id, email_to from art_user_notifications where table_name= ''ART_PROBLEMS'' and STATUS_AI_CHK = ''A''';

l_sqlstring := l_sqlstring || l_where_clause;

  EXECUTE IMMEDIATE l_sqlstring INTO l_user_notif_id, l_user_id , l_email_to;
l_user_email := l_user_email ||';'|| GETVAL('EMAIL_ID', l_user_id)||';'|| l_email_to ;
l_user_email := trim(';' FROM l_user_email);
 END IF;
END IF;
END LOOP notif_loop;
--
po_notif_email := l_user_email;
--
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);

end chk_cater_notif_on_insert;

procedure chk_cater_notif_on_update
(pi_prob_rec_new	in art_problems_email%rowtype
,pi_prob_rec_old	in art_problems_email%rowtype
,pi_user_notif_rec      in notif_rc
,pi_chg_type            in varchar2
,po_notif_email         out varchar2) 
is

c_proc  constant	varchar2(100) := 'chk_cater_notif_on_update ';
C_SQ    CONSTANT	VARCHAR2(1) := CHR(39);
V_ERRMSG		VARCHAR2(1000);

-- Increase length in package code before increasing here *************
l_user_email		VARCHAR2(2000);

l_email_flag		VARCHAR2(1) := 'N';
l_accept		VARCHAR2(1) := '';
l_notif_col_name	ART_USER_NOTIF_COLUMNS.notif_column_alias%TYPE;
l_table_col_name	ART_USER_NOTIF_COLUMNS.notif_column%TYPE;
l_column_yes_no_val	ART_USER_NOTIF_COLUMNS.column_yes_no_val%TYPE;
l_column_datatype	ART_USER_NOTIF_COLUMNS.column_datatype%TYPE;
l_sqlstring		varchar2(4000) := '';
l_where_clause		varchar2(4000) := '';

l_user_notif_id		ART_USER_NOTIFICATIONS.USER_NOTIF_ID%TYPE;
l_user_id		ART_USER_NOTIFICATIONS.USER_ID%TYPE;
l_email_to		ART_USER_NOTIFICATIONS.EMAIL_TO%TYPE;

l_notif_col_val		VARCHAR2(100);
l_col_val_new		VARCHAR2(100);
l_col_val_old		VARCHAR2(100);
l_notif_block		varchar2(4000);
l_email_block_new	varchar2(4000);
l_email_block_old	varchar2(4000);

BEGIN
CATER_MESSAGE_NEW.prob_email_rec_new := pi_prob_rec_new;
CATER_MESSAGE_NEW.prob_email_rec_old := pi_prob_rec_old;

 <<notif_loop>>
  LOOP
-- Read ART_USER_NOTIFICATIONS rows in a loop
   fetch pi_user_notif_rec into notif_rec;
   exit when pi_user_notif_rec%NOTFOUND;

   l_where_clause := '';
   l_accept := '';

<<notif_col_loop>>
  FOR  c1_rec in (select notif_column, notif_column_alias,
                         column_yes_no_val, column_datatype
		from ART_USER_NOTIF_COLUMNS
		where notif_table = 'ART_PROBLEMS')
  LOOP
-- Matching with ART_USER_NOTIF_COLUMNS column values for notif_table = 'ART_PROBLEMS'.
-- Ex - l_notif_col_name = SHOP_ID, l_table_col_name = SHOP_MAIN_ID (column name in the actual table) 
--      l_column_yes_no_val = N, l_column_datatype = NUMBER
    l_notif_col_name  := c1_rec.notif_column_alias;
    l_table_col_name := c1_rec.notif_column;
    l_column_yes_no_val := c1_rec.column_yes_no_val;
    l_column_datatype := c1_rec.column_datatype;

-- Ex - l_notif_block= begin :1 := CATER_MESSAGE_NEW.notif_rec.SHOP_ID; end;
      l_notif_block := 'begin :1 := CATER_MESSAGE_NEW.notif_rec.'||c1_rec.notif_column_alias||'; end;';

-- This would give the actual column value of the row from ART_USER_NOTIFICATIONS
    EXECUTE IMMEDIATE l_notif_block using OUT l_notif_col_val;

-- IF value from ART_USER_NOTIFICATIONS is NOT NULL, then we proceed to check the new value of the same column name in ART_PROBLEMS.
-- IF they match, we then check the old value of the column (before the update). If they don't match, read the next row of ART_USER_NOTIF_COLUMNS.
-- IF the old value has changed to the value defined in ART_USER_NOTIFICATIONS, we add it to the where clause of the SQL statement

   IF l_notif_col_val IS NOT NULL 
   THEN
-- We now read the NEW column value of the above column name from the Problem record. Ex - :new.SHOP_MAIN_ID
-- Ex - l_email_block_new= begin :1 := CATER_MESSAGE_NEW.prob_email_rec_new.SHOP_MAIN_ID; end;
      l_email_block_new := 'begin :1 := CATER_MESSAGE_NEW.prob_email_rec_new.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block_new using OUT l_col_val_new;

-- IF ART_USER_NOTIFICATIONS column has a value, but the same column in the Problem record is NULL, then skip to the next row
    IF l_col_val_new IS NULL THEN
        l_accept := 'N';
        exit notif_col_loop; -- Read next row from ART_USER_NOTIFICATIONS
    ELSE
-- Special processing for ANY STATUS change. Check Old and New for Status change.
     IF (l_notif_col_name= 'PROB_STATUS_CHK' and l_notif_col_val= 99) THEN
      l_email_block_old := 'begin :1 := CATER_MESSAGE_NEW.prob_email_rec_old.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block_old using OUT l_col_val_old;
      IF (l_col_val_new != l_col_val_old) OR
         (l_col_val_old is NULL and l_col_val_new is NOT NULL) THEN
          l_accept := 'Y';
	  --
          l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '|| l_notif_col_val;
       END IF; -- l_col_val_new != l_col_val_old for 99
     ELSE
-- Ex - IF :new.SHOP_MAIN_ID != ART_USER_NOTIFICATIONS.SHOP_ID, then read next row
      IF l_col_val_new != l_notif_col_val THEN
        l_accept := 'N';
        exit notif_col_loop; -- Read next row from ART_USER_NOTIFICATIONS
      ELSE     
-- Ex - IF :new.SHOP_MAIN_ID = ART_USER_NOTIFICATIONS.SHOP_ID, then check the :old.SHOP_MAIN_ID value.
       l_email_block_old := 'begin :1 := CATER_MESSAGE_NEW.prob_email_rec_old.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block_old using OUT l_col_val_old;

-- Ex - IF Old and New are different, use it in the where clause
      IF (l_col_val_new != l_col_val_old) OR
         (l_col_val_old is NULL and l_col_val_new is NOT NULL) THEN
          l_accept := 'Y';
	  --
-- Checking Varchar or Number to appropriately create the where clause statement for the values.
	  IF l_column_datatype = 'VARCHAR' THEN
           l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '||C_SQ|| l_col_val_new||C_SQ;
          ELSIF l_column_datatype = 'NUMBER' THEN
	   l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '||l_col_val_new;
          END IF; -- l_column_datatype
	  --
--          l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '|| l_col_val_new;
       END IF; -- l_col_val_new != l_col_val_old
      END IF; -- l_col_val_new != l_notif_col_val
    END IF; -- l_notif_col_name= 'PROB_STATUS_CHK' and l_notif_col_val= 99
    END IF; -- l_col_val_new IS NULL
   END IF; -- l_notif_col_val IS NOT NULL 
  END LOOP notif_col_loop; -- c1_rec

IF l_accept = 'Y' THEN
 IF l_where_clause IS NOT NULL THEN
  l_where_clause := l_where_clause || ' and user_notif_id = '|| notif_rec.user_notif_id;
  l_sqlstring := 'select user_notif_id, user_id, email_to from art_user_notifications where table_name= ''ART_PROBLEMS'' and STATUS_AI_CHK = ''A''';

l_sqlstring := l_sqlstring || l_where_clause;

  EXECUTE IMMEDIATE l_sqlstring INTO l_user_notif_id, l_user_id , l_email_to;
l_user_email := l_user_email || ';'|| GETVAL('EMAIL_ID', l_user_id)||';'|| l_email_to ;
l_user_email := trim(';' FROM l_user_email);

 END IF;
END IF;
END LOOP notif_loop;
--
po_notif_email := trim(';' FROM l_user_email);
--
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);

end chk_cater_notif_on_update;

procedure check_job_preferences
(pi_job_rec_new	        in art_jobs_email%rowtype
,pi_job_rec_old         in art_jobs_email%rowtype
,pi_table_name		in varchar2
,pi_from         	in varchar2
,pi_operation		in varchar2
,po_user_email		out varchar2
) is 
--
c_proc   constant	varchar2(100) := 'check_job_preferences ';
C_SQ     CONSTANT	VARCHAR2(1) := CHR(39);
V_ERRMSG		VARCHAR2(1000);

l_email_to		varchar2(2000); --ART_USER_NOTIFICATIONS.EMAIL_TO%TYPE;
l_new_email_to		varchar2(2000); --ART_USER_NOTIFICATIONS.EMAIL_TO%TYPE;

l_job_rec_new		art_jobs_email%rowtype;
l_job_rec_old		art_jobs_email%rowtype;
user_notif_cur		SYS_REFCURSOR;
--
BEGIN

  l_job_rec_new := pi_job_rec_new;
  l_job_rec_old := pi_job_rec_old;

IF pi_operation = 'I' THEN
 BEGIN
  OPEN user_notif_cur FOR
   select * from ART_USER_NOTIFICATIONS
   where notif_object = 'JOB' --pi_appl
   and   table_name   = pi_table_name  -- 'ART_JOBS' 
   and   STATUS_AI_CHK = 'A'
   order by 1;
--
	CATER_MESSAGE_NEW.chk_job_notif_on_insert
	(pi_job_rec_new => pi_job_rec_new
	,pi_job_rec_old => pi_job_rec_old
        ,pi_user_notif_rec    => user_notif_cur
	,pi_chg_type     => 'NEW_JOB'
	,po_notif_email   => l_email_to      
        );
IF l_email_to IS NOT NULL THEN
   l_new_email_to := l_email_to ||';'||l_new_email_to;
END IF;
--
  CLOSE user_notif_cur;
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);
 END;
ELSE 
--
  BEGIN
  OPEN user_notif_cur FOR
   select * from ART_USER_NOTIFICATIONS
   where notif_object = 'JOB' --pi_appl
   and   table_name   = pi_table_name  -- 'ART_JOBS' 
   and   STATUS_AI_CHK = 'A'
   and   NEW_JOB is null
   order by 1;
	CATER_MESSAGE_NEW.chk_job_notif_on_update
	(pi_job_rec_new => pi_job_rec_new
	,pi_job_rec_old => pi_job_rec_old
        ,pi_user_notif_rec    => user_notif_cur
	,pi_chg_type     => 'NO_COND'
	,po_notif_email   => l_email_to      
        );
IF l_email_to IS NOT NULL THEN
   l_new_email_to := l_email_to ||';'||l_new_email_to;
END IF;
--
   CLOSE user_notif_cur;
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);
  END;
--
END IF;
--
IF substr(trim(l_new_email_to),1,1) = ';' THEN
  l_new_email_to := substr(trim(l_new_email_to),2);
END IF;
--
po_user_email := l_new_email_to;

 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);
--
END check_job_preferences;

procedure chk_job_notif_on_insert
(pi_job_rec_new		in art_jobs_email%rowtype
,pi_job_rec_old		in art_jobs_email%rowtype
,pi_user_notif_rec      in notif_rc
,pi_chg_type            in varchar2
,po_notif_email         out varchar2) 
is

c_proc    CONSTANT	VARCHAR2(100) := 'chk_job_notif_on_insert ';
C_SQ      CONSTANT	VARCHAR2(1) := CHR(39);
V_ERRMSG		VARCHAR2(1000);

l_email_flag		VARCHAR2(1) := 'N';
-- Increase length in package code before increasing here *************
l_user_email		VARCHAR2(2000);

l_accept		VARCHAR2(1) := '';
l_notif_col_name	ART_USER_NOTIF_COLUMNS.notif_column_alias%TYPE;
l_table_col_name	ART_USER_NOTIF_COLUMNS.notif_column%TYPE;
l_column_yes_no_val	ART_USER_NOTIF_COLUMNS.column_yes_no_val%TYPE;
l_column_datatype	ART_USER_NOTIF_COLUMNS.column_datatype%TYPE;
l_notif_col_val		VARCHAR2(100);
l_col_val		VARCHAR2(100);
l_notif_block		VARCHAR2(4000);
l_email_block		VARCHAR2(4000);
l_sqlstring		VARCHAR2(4000) := '';
l_where_clause		VARCHAR2(4000) := '';

l_user_notif_id		ART_USER_NOTIFICATIONS.USER_NOTIF_ID%TYPE;
l_user_id		ART_USER_NOTIFICATIONS.USER_ID%TYPE;
l_email_to		ART_USER_NOTIFICATIONS.EMAIL_TO%TYPE;
--
BEGIN
cater_message_new.job_email_rec_new := pi_job_rec_new;
cater_message_new.job_email_rec_old := pi_job_rec_old;
 <<notif_loop>>
  LOOP
   fetch pi_user_notif_rec into notif_rec;
   exit when pi_user_notif_rec%NOTFOUND;

   l_where_clause := '';
   l_accept := '';

<<notif_col_loop>>
  FOR  c1_rec in (select notif_column, notif_column_alias,
                         column_yes_no_val, column_datatype
		  from ART_USER_NOTIF_COLUMNS
		  where notif_table = 'ART_JOBS')
  LOOP
    l_notif_col_name  := c1_rec.notif_column_alias;
    l_table_col_name := c1_rec.notif_column;
    l_column_yes_no_val := c1_rec.column_yes_no_val;
    l_column_datatype := c1_rec.column_datatype;
/*
      l_email_block := 'begin :1 := cater_message_new.job_email_rec_new.'||c1_rec.notif_column||'; end;';
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1,p_text => c_proc || ', l_email_block= '|| l_email_block);

      EXECUTE IMMEDIATE l_email_block using OUT l_col_val;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1,p_text => c_proc || ', l_col_val= '|| l_col_val );
*/
      l_notif_block := 'begin :1 := cater_message_new.notif_rec.'||c1_rec.notif_column_alias||'; end;';

    EXECUTE IMMEDIATE l_notif_block using OUT l_notif_col_val;

    IF l_notif_col_val IS NOT NULL
    THEN
     IF (l_notif_col_name= 'JOB_STATUS_CHK' and l_notif_col_val= 99) THEN
         l_accept := 'Y';
	 l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '|| l_notif_col_val;
     ELSIF (l_notif_col_name= 'AM_APPROVAL_CHK' and l_notif_col_val= 'U') THEN
         l_accept := 'Y';
	 l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '||C_SQ|| l_notif_col_val||C_SQ;
     ELSE
      l_email_block := 'begin :1 := cater_message_new.job_email_rec_new.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block using OUT l_col_val;

      IF l_col_val is null then
        l_accept := 'N';
        exit notif_col_loop; -- Read next row from ART_USER_NOTIFICATIONS
      ELSE
        IF l_col_val = l_notif_col_val THEN
          l_accept := 'Y';
	  --
	  IF l_column_datatype = 'VARCHAR' THEN
           l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '||C_SQ|| l_col_val ||C_SQ;
          ELSIF l_column_datatype = 'NUMBER' THEN
	   l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '|| l_col_val;
          END IF;
	  --
        ELSE
          l_accept := 'N';
	  exit notif_col_loop; -- Read next row from ART_USER_NOTIFICATIONS
	END IF; -- l_col_val = l_notif_col_val
      END IF; -- l_col_val is null
     END IF; -- l_notif_col_name= 'JOB_STATUS_CHK' and l_notif_col_val= 99
    END IF; -- l_notif_col_val IS NOT NULL
  END LOOP notif_col_loop; -- c1_rec

IF l_accept = 'Y' THEN
 IF l_where_clause IS NOT NULL THEN
  l_where_clause := l_where_clause || ' and user_notif_id = '|| notif_rec.user_notif_id;
  l_sqlstring := 'select user_notif_id, user_id, email_to from art_user_notifications where table_name= ''ART_JOBS'' and STATUS_AI_CHK = ''A''';

l_sqlstring := l_sqlstring || l_where_clause;

  EXECUTE IMMEDIATE l_sqlstring INTO l_user_notif_id, l_user_id , l_email_to;
l_user_email := l_user_email ||';'|| GETVAL('EMAIL_ID', l_user_id)||';'||l_email_to;
l_user_email := trim(';' FROM l_user_email);
 END IF;
END IF;
END LOOP notif_loop;
--
po_notif_email := l_user_email;
--
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);

end chk_job_notif_on_insert;

procedure chk_job_notif_on_update
(pi_job_rec_new		in art_jobs_email%rowtype
,pi_job_rec_old		in art_jobs_email%rowtype
,pi_user_notif_rec      in notif_rc
,pi_chg_type            in varchar2
,po_notif_email         out varchar2) 
is
c_proc    CONSTANT	VARCHAR2(100) := 'chk_job_notif_on_update ';
C_SQ      CONSTANT	VARCHAR2(1) := CHR(39);
V_ERRMSG		VARCHAR2(1000);

l_email_flag  VARCHAR2(1) := 'N';
l_accept   VARCHAR2(1) := '';
-- Increase length in package code before increasing here *************
l_user_email  VARCHAR2(2000);

l_notif_col_name	ART_USER_NOTIF_COLUMNS.notif_column_alias%TYPE;
l_table_col_name	ART_USER_NOTIF_COLUMNS.notif_column%TYPE;
l_column_yes_no_val	ART_USER_NOTIF_COLUMNS.column_yes_no_val%TYPE;
l_column_datatype	ART_USER_NOTIF_COLUMNS.column_datatype%TYPE;

l_sqlstring		VARCHAR2(4000) := '';
l_where_clause		VARCHAR2(4000) := '';
l_notif_block		VARCHAR2(4000);
l_email_block_new	VARCHAR2(4000);
l_email_block_old	VARCHAR2(4000);
l_col_val_new		VARCHAR2(100);
l_col_val_old		VARCHAR2(100);
l_notif_col_val		VARCHAR2(100);

l_user_notif_id		ART_USER_NOTIFICATIONS.USER_NOTIF_ID%TYPE;
l_user_id		ART_USER_NOTIFICATIONS.USER_ID%TYPE;
l_email_to		ART_USER_NOTIFICATIONS.EMAIL_TO%TYPE;
--
BEGIN
cater_message_new.job_email_rec_new := pi_job_rec_new;
cater_message_new.job_email_rec_old := pi_job_rec_old;

 <<notif_loop>>
  LOOP
   fetch pi_user_notif_rec into notif_rec;
   exit when pi_user_notif_rec%NOTFOUND;

   l_where_clause := '';
   l_accept := '';

<<notif_col_loop>>
  FOR  c1_rec in (select notif_column, notif_column_alias,
                         column_yes_no_val, column_datatype
		  from ART_USER_NOTIF_COLUMNS
		  where notif_table = 'ART_JOBS')
  LOOP
    l_notif_col_name  := c1_rec.notif_column_alias;
    l_table_col_name := c1_rec.notif_column;
    l_column_yes_no_val := c1_rec.column_yes_no_val;
    l_column_datatype := c1_rec.column_datatype;

    l_notif_block := 'begin :1 := cater_message_new.notif_rec.'||c1_rec.notif_column_alias||'; end;';

    EXECUTE IMMEDIATE l_notif_block using OUT l_notif_col_val;

-- Poonam - New code for AM_APPROVAL_CHK with Null value too
   IF (l_notif_col_name= 'AM_APPROVAL_CHK' and l_notif_col_val= 'U') THEN
      l_email_block_new := 'begin :1 := cater_message_new.job_email_rec_new.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block_new using OUT l_col_val_new;

      l_email_block_old := 'begin :1 := CATER_MESSAGE_NEW.job_email_rec_old.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block_old using OUT l_col_val_old;

       IF (nvl(l_col_val_new,'U') != nvl(l_col_val_old,'U')) THEN
          l_accept := 'Y';
	  --
          l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '||C_SQ|| l_notif_col_val||C_SQ;
       END IF; -- l_col_val_new != l_col_val_old for AM_APPROVAL_CHK for 'U'
   ELSE   -- Any other condition but AM_APPROVAL_CHK and 'U'
   IF l_notif_col_val IS NOT NULL 
   THEN
      l_email_block_new := 'begin :1 := cater_message_new.job_email_rec_new.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block_new using OUT l_col_val_new;

   IF l_col_val_new IS NULL THEN
        l_accept := 'N';
        exit notif_col_loop; -- Read next row from ART_USER_NOTIFICATIONS
   ELSE
    IF (l_notif_col_name= 'JOB_STATUS_CHK' and l_notif_col_val= 99) THEN
      l_email_block_old := 'begin :1 := CATER_MESSAGE_NEW.job_email_rec_old.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block_old using OUT l_col_val_old;
       IF (l_col_val_new != l_col_val_old) OR
         (l_col_val_old is NULL and l_col_val_new is NOT NULL) THEN
          l_accept := 'Y';
	  --
          l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '|| l_notif_col_val;
       END IF; -- l_col_val_new != l_col_val_old for 99
    ELSE
     IF l_col_val_new != l_notif_col_val THEN
       l_accept := 'N';
       exit notif_col_loop; -- Read next row from ART_USER_NOTIFICATIONS
     ELSE     
      l_email_block_old := 'begin :1 := cater_message_new.job_email_rec_old.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block_old using OUT l_col_val_old;

       IF (l_col_val_new != l_col_val_old) OR
         (l_col_val_old is NULL and l_col_val_new is NOT NULL) THEN
          l_accept := 'Y';
	  --
	  IF l_column_datatype = 'VARCHAR' THEN
           l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '||C_SQ|| l_col_val_new||C_SQ;
          ELSIF l_column_datatype = 'NUMBER' THEN
	   l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '||l_col_val_new;
          END IF; -- l_column_datatype
	  --
	END IF; -- l_col_val_new != l_col_val_old
      END IF; -- l_col_val_new != l_notif_col_val
     END IF; -- l_notif_col_name= 'JOB_STATUS_CHK' and l_notif_col_val= 99
    END IF; -- l_col_val_new IS NULL
   END IF; -- l_notif_col_val IS NOT NULL 
  END IF; -- AM_APPROVAL_CHK with 'U' value
  END LOOP notif_col_loop; -- c1_rec

IF l_accept = 'Y' THEN
 IF l_where_clause IS NOT NULL THEN
  l_where_clause := l_where_clause || ' and user_notif_id = '|| notif_rec.user_notif_id;
  l_sqlstring := 'select user_notif_id, user_id, email_to from art_user_notifications where table_name= ''ART_JOBS'' and STATUS_AI_CHK = ''A''';

l_sqlstring := l_sqlstring || l_where_clause;

  EXECUTE IMMEDIATE l_sqlstring INTO l_user_notif_id, l_user_id , l_email_to;
l_user_email := l_user_email ||';'|| GETVAL('EMAIL_ID', l_user_id)||';'||l_email_to;
l_user_email := trim(';' FROM l_user_email);
 END IF;
END IF;
END LOOP notif_loop;
--
po_notif_email := l_user_email;
--
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);

end chk_job_notif_on_update;

procedure check_sol_preferences
(pi_sol_rec_new		in art_solutions_email%rowtype
,pi_sol_rec_old		in art_solutions_email%rowtype
,pi_table_name		in varchar2
,pi_from         	in varchar2
,pi_operation		in varchar2
,po_user_email		out varchar2
) is 

 c_proc         constant varchar2(100) := 'check_sol_preferences ';
l_email_to      ART_USER_NOTIFICATIONS.EMAIL_TO%TYPE;
l_new_email_to  ART_USER_NOTIFICATIONS.EMAIL_TO%TYPE;

V_ERRMSG	VARCHAR2(1000);
l_sol_rec_new	ART_SOLUTIONS_EMAIL%rowtype;
l_sol_rec_old	ART_SOLUTIONS_EMAIL%rowtype;

user_notif_cur  SYS_REFCURSOR;

BEGIN

  l_sol_rec_new := pi_sol_rec_new;
  l_sol_rec_old := pi_sol_rec_old;

IF pi_operation = 'I' THEN
 BEGIN
  OPEN user_notif_cur FOR
   select * from ART_USER_NOTIFICATIONS
   where notif_object = 'SOLUTION' --pi_appl
   and   table_name   = 'ART_SOLUTIONS' --pi_table_name
   and   STATUS_AI_CHK = 'A'
   order by 1;
--
	cater_message_new.chk_sol_notif_on_insert
	(pi_sol_rec_new => pi_sol_rec_new
	,pi_sol_rec_old => pi_sol_rec_old
        ,pi_user_notif_rec    => user_notif_cur
	,pi_chg_type     => 'NEW_SOL'
	,po_notif_email   => l_email_to      
        );
     IF l_email_to IS NOT NULL THEN
       l_new_email_to := l_email_to ||';'||l_new_email_to;
     END IF;
--
  CLOSE user_notif_cur;
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);
 END;
ELSE 
--
  BEGIN
  OPEN user_notif_cur FOR
   select * from ART_USER_NOTIFICATIONS
   where notif_object = 'SOLUTION' --pi_appl
   and   table_name   = 'ART_SOLUTIONS' --pi_table_name
   and   STATUS_AI_CHK = 'A'
   and   NEW_SOLUTION is null
   order by 1;
	cater_message_new.chk_sol_notif_on_update
	(pi_sol_rec_new => pi_sol_rec_new
	,pi_sol_rec_old => pi_sol_rec_old
        ,pi_user_notif_rec    => user_notif_cur
	,pi_chg_type     => 'NO_COND'
	,po_notif_email   => l_email_to      
        );
IF l_email_to IS NOT NULL THEN
   l_new_email_to := l_email_to ||';'||l_new_email_to;
END IF;
--
   CLOSE user_notif_cur;
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);
  END;
--
END IF;
--
IF substr(trim(l_new_email_to),1,1) = ';' THEN
  l_new_email_to := substr(trim(l_new_email_to),2);
END IF;
--
po_user_email := l_new_email_to;
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);

END check_sol_preferences;

procedure chk_sol_notif_on_insert
(pi_sol_rec_new		in ART_SOLUTIONS_EMAIL%rowtype
,pi_sol_rec_old		in ART_SOLUTIONS_EMAIL%rowtype
,pi_user_notif_rec      in notif_rc
,pi_chg_type            in varchar2
,po_notif_email         out varchar2) 
is
c_proc   constant	varchar2(100) := 'chk_sol_notif_on_insert ';
C_SQ     CONSTANT	VARCHAR2(1) := CHR(39);
V_ERRMSG		VARCHAR2(1000);

-- Increase length in package code before increasing here *************
l_user_email		VARCHAR2(500);

l_email_flag		VARCHAR2(1) := 'N';
l_accept		VARCHAR2(1) := '';
l_notif_col_name	ART_USER_NOTIF_COLUMNS.notif_column_alias%TYPE;
l_table_col_name	ART_USER_NOTIF_COLUMNS.notif_column%TYPE;
l_column_yes_no_val	ART_USER_NOTIF_COLUMNS.column_yes_no_val%TYPE;
l_column_datatype	ART_USER_NOTIF_COLUMNS.column_datatype%TYPE;
l_notif_col_val		VARCHAR2(100);
l_sqlstring		VARCHAR2(4000) := '';
l_where_clause		VARCHAR2(4000) := '';
l_notif_block		VARCHAR2(4000);
l_email_block		VARCHAR2(4000);
l_col_val		VARCHAR2(100);

l_user_notif_id		ART_USER_NOTIFICATIONS.USER_NOTIF_ID%TYPE;
l_user_id		ART_USER_NOTIFICATIONS.USER_ID%TYPE;
l_email_to		ART_USER_NOTIFICATIONS.EMAIL_TO%TYPE;

BEGIN
cater_message_new.sol_email_rec_new := pi_sol_rec_new;
cater_message_new.sol_email_rec_old := pi_sol_rec_old;
 <<notif_loop>>
  LOOP
   fetch pi_user_notif_rec into notif_rec;
   exit when pi_user_notif_rec%NOTFOUND;

   l_where_clause := '';
   l_accept := '';

<<notif_col_loop>>
  FOR  c1_rec in (select notif_column, notif_column_alias,
                         column_yes_no_val, column_datatype
		  from ART_USER_NOTIF_COLUMNS
		  where notif_table = 'ART_SOLUTIONS')
  LOOP
    l_notif_col_name  := c1_rec.notif_column_alias;
    l_table_col_name := c1_rec.notif_column;
    l_column_yes_no_val := c1_rec.column_yes_no_val;
    l_column_datatype := c1_rec.column_datatype;

      l_email_block := 'begin :1 := cater_message_new.sol_email_rec_new.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block using OUT l_col_val;

      l_notif_block := 'begin :1 := cater_message_new.notif_rec.'||c1_rec.notif_column_alias||'; end;';

    EXECUTE IMMEDIATE l_notif_block using OUT l_notif_col_val;

    IF l_notif_col_val IS NOT NULL 
    THEN
      l_email_block := 'begin :1 := cater_message_new.sol_email_rec_new.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block using OUT l_col_val;

      IF l_col_val is null then
        l_accept := 'N';
        exit notif_col_loop; -- Read next row from ART_USER_NOTIFICATIONS
      ELSE
        IF l_col_val = l_notif_col_val THEN
          l_accept := 'Y';
	  --
	  IF l_column_datatype = 'VARCHAR' THEN
           l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '||C_SQ|| l_col_val ||C_SQ;
          ELSIF l_column_datatype = 'NUMBER' THEN
	   l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '|| l_col_val;
          END IF;
	  --
--          l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '|| l_col_val;
        ELSE
          l_accept := 'N';
	  exit notif_col_loop; -- Read next row from ART_USER_NOTIFICATIONS
	END IF;
      END IF;
    END IF;
  END LOOP notif_col_loop; -- c1_rec


IF l_accept = 'Y' THEN
 IF l_where_clause IS NOT NULL THEN
  l_where_clause := l_where_clause || ' and user_notif_id = '|| notif_rec.user_notif_id;
  l_sqlstring := 'select user_notif_id, user_id, email_to from art_user_notifications where table_name= ''ART_SOLUTIONS'' and STATUS_AI_CHK = ''A''';

l_sqlstring := l_sqlstring || l_where_clause;

  EXECUTE IMMEDIATE l_sqlstring INTO l_user_notif_id, l_user_id , l_email_to;
l_user_email := l_user_email ||';'|| GETVAL('EMAIL_ID', l_user_id)||';'||l_email_to;
l_user_email := trim(';' FROM l_user_email);
 END IF;
END IF;
END LOOP notif_loop;
--
po_notif_email := l_user_email;
--
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);

end chk_sol_notif_on_insert;

procedure chk_sol_notif_on_update
(pi_sol_rec_new		in ART_SOLUTIONS_EMAIL%rowtype
,pi_sol_rec_old		in ART_SOLUTIONS_EMAIL%rowtype
,pi_user_notif_rec      in notif_rc
,pi_chg_type            in varchar2
,po_notif_email         out varchar2) 
is
c_proc   constant	varchar2(100) := 'chk_sol_notif_on_update ';
C_SQ     CONSTANT	VARCHAR2(1) := CHR(39);
V_ERRMSG		VARCHAR2(1000);

l_email_flag		VARCHAR2(1) := 'N';

-- Increase length in package code before increasing here *************
  l_user_email		VARCHAR2(500);

l_accept		VARCHAR2(1) := '';
l_col_val_new		VARCHAR2(100);
l_col_val_old		VARCHAR2(100);
l_notif_col_name	ART_USER_NOTIF_COLUMNS.notif_column_alias%TYPE;
l_table_col_name	ART_USER_NOTIF_COLUMNS.notif_column%TYPE;
l_column_yes_no_val	ART_USER_NOTIF_COLUMNS.column_yes_no_val%TYPE;
l_column_datatype	ART_USER_NOTIF_COLUMNS.column_datatype%TYPE;
l_notif_col_val		VARCHAR2(100);
l_sqlstring		VARCHAR2(4000) := '';
l_where_clause		VARCHAR2(4000) := '';
l_notif_block		VARCHAR2(4000);
l_email_block_new	VARCHAR2(4000);
l_email_block_old	VARCHAR2(4000);

l_user_notif_id		ART_USER_NOTIFICATIONS.USER_NOTIF_ID%TYPE;
l_user_id		ART_USER_NOTIFICATIONS.USER_ID%TYPE;
l_email_to		ART_USER_NOTIFICATIONS.EMAIL_TO%TYPE;


BEGIN
cater_message_new.sol_email_rec_new := pi_sol_rec_new;
cater_message_new.sol_email_rec_old := pi_sol_rec_old;

 <<notif_loop>>
  LOOP
   fetch pi_user_notif_rec into notif_rec;
   exit when pi_user_notif_rec%NOTFOUND;

   l_where_clause := '';
   l_accept := '';

<<notif_col_loop>>
  FOR  c1_rec in (select notif_column, notif_column_alias,
                         column_yes_no_val, column_datatype
		  from ART_USER_NOTIF_COLUMNS
		  where notif_table = 'ART_SOLUTIONS')
  LOOP
    l_notif_col_name  := c1_rec.notif_column_alias;
    l_table_col_name := c1_rec.notif_column;
    l_column_yes_no_val := c1_rec.column_yes_no_val;
    l_column_datatype := c1_rec.column_datatype;

      l_email_block_new := 'begin :1 := cater_message_new.sol_email_rec_new.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block_new using OUT l_col_val_new;

      l_notif_block := 'begin :1 := cater_message_new.notif_rec.'||c1_rec.notif_column_alias||'; end;';

    EXECUTE IMMEDIATE l_notif_block using OUT l_notif_col_val;

   IF l_notif_col_val IS NOT NULL 
   THEN
      l_email_block_new := 'begin :1 := cater_message_new.sol_email_rec_new.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block_new using OUT l_col_val_new;

    IF l_col_val_new IS NULL THEN
        l_accept := 'N';
        exit notif_col_loop; -- Read next row from ART_USER_NOTIFICATIONS
    ELSE
     IF l_col_val_new != l_notif_col_val THEN
       l_accept := 'N';
       exit notif_col_loop; -- Read next row from ART_USER_NOTIFICATIONS
     ELSE     
      l_email_block_old := 'begin :1 := cater_message_new.sol_email_rec_old.'||c1_rec.notif_column||'; end;';

      EXECUTE IMMEDIATE l_email_block_old using OUT l_col_val_old;

      IF (l_col_val_new != l_col_val_old) OR
         (l_col_val_old is NULL and l_col_val_new is NOT NULL) THEN
          l_accept := 'Y';
	  --
	  IF l_column_datatype = 'VARCHAR' THEN
           l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '||C_SQ|| l_col_val_new||C_SQ;
          ELSIF l_column_datatype = 'NUMBER' THEN
	   l_where_clause := l_where_clause ||' and '||l_notif_col_name||' = '||l_col_val_new;
          END IF;
	  --
	END IF;
      END IF;
    END IF;
   END IF;
  END LOOP notif_col_loop; -- c1_rec


IF l_accept = 'Y' THEN
 IF l_where_clause IS NOT NULL THEN
  l_where_clause := l_where_clause || ' and user_notif_id = '|| notif_rec.user_notif_id;
  l_sqlstring := 'select user_notif_id, user_id, email_to from art_user_notifications where table_name= ''ART_SOLUTIONS'' and STATUS_AI_CHK = ''A''';

l_sqlstring := l_sqlstring || l_where_clause;

  EXECUTE IMMEDIATE l_sqlstring INTO l_user_notif_id, l_user_id , l_email_to;
l_user_email := l_user_email ||';'|| GETVAL('EMAIL_ID', l_user_id)||';'||l_email_to;
l_user_email := trim(';' FROM l_user_email);
 END IF;
END IF;
END LOOP notif_loop;
--
po_notif_email := l_user_email;
--
 exception
   when OTHERS then 
       V_ERRMSG := SUBSTR('ERROR: '||SQLERRM,1,800);
   apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||'EXCEPTION: V_ERRMSG = '|| V_ERRMSG);

end chk_sol_notif_on_update;

procedure email_cater
is

    c_proc    constant varchar2(100) := 'CATER_MESSAGE_NEW.email_cater ';

    cursor email_grp_cur is
      select prob_email_id, count(*) as row_count 
      from art_problems_email
      where prob_chg_email_chk = 1
      and trunc(prob_email_datetime) = trunc(sysdate)
      group by prob_email_id
      order by prob_email_id;

l_prob_email_id		art_problems_email.prob_email_id%TYPE;
l_row_count		NUMBER;

problems_email_new	sys_refcursor;
problems_email_old	sys_refcursor;

begin
 OPEN email_grp_cur;
 LOOP
  FETCH email_grp_cur into l_prob_email_id, l_row_count; 
  exit when email_grp_cur%NOTFOUND;

   open problems_email_old for
      select * from art_problems_email
      where 1 = 0;

   open problems_email_new for
      select * from art_problems_email
      where prob_email_id = l_prob_email_id
      and prob_rec_type = 'NEW';
      --
    if l_row_count > 1 then
      open problems_email_old for
      select * from art_problems_email
      where prob_email_id = l_prob_email_id
      and prob_rec_type = 'OLD';
    end if;
        CATER_MESSAGE_NEW.email_cater_problem
	(pi_prob_rec_new => problems_email_new
	,pi_prob_rec_old => problems_email_old
	,pi_message_type => 'SE'
	);


END LOOP;
 close email_grp_cur;

end email_cater;

procedure printrc
(prc1 in art_problems_email%rowtype
,prc2 in art_problems_email%rowtype)
is
    c_proc     constant varchar2(100) := 'CATER_MESSAGE_NEW.printrc ';
  l_art_problems_email_new  art_problems_email%rowtype;
  l_art_problems_email_old  art_problems_email%rowtype;
begin
dbms_output.put_line('begin printrc');
  l_art_problems_email_new := prc1;
  l_art_problems_email_old := prc2;

dbms_output.put_line(l_art_problems_email_new.prob_email_id || ',' || l_art_problems_email_new.prob_rec_type);
dbms_output.put_line(l_art_problems_email_old.prob_email_id || ',' || l_art_problems_email_old.prob_rec_type);
dbms_output.put_line('end printrc');
end printrc;

procedure email_cater_problem
(pi_prob_rec_new in rc
,pi_prob_rec_old in rc := null
,pi_operation    in varchar2
,pi_from         in varchar2
,pi_to           in varchar2
,pi_subject      in varchar2
,pi_comment      in varchar2
,pi_message_type in varchar2
,pi_call_from    in varchar2
) is

    c_proc                      constant varchar2(100) := 'CATER_MESSAGE_NEW.email_cater_problem ';
    c_send_email                constant char := 'Y';  -- change this to 'Y' to hit the email server
    c_empty_table_row           constant varchar2(100):= '<tr><td>&nbsp</td><td>&nbsp</td></tr>';

    l_prob_rec_new		art_problems_email%rowtype;
    l_prob_rec_old		art_problems_email%rowtype := null;

    l_instance                  varchar2(100);
    l_user_email		VARCHAR2(500);
    l_message_to                varchar2(2000);
    l_apex_url_prefix           varchar2(500);
    l_html_message_body         clob;
    l_text_message_body         clob;
    l_html_message_subject      varchar2(1000);
    l_text_message_subject      varchar2(1000);

    l_from			varchar2(100);
    l_status			varchar2(30);
    l_errmsg                    varchar2(1000) := null;
    l_app_user                  varchar2(100);
    l_html_flag                 varchar2(1);
    l_operation			varchar2(1);
    l_message_type              varchar2(10);
    l_changer_email		varchar2(100);
    l_problem_title             art_problems_email.problem_title%type;
    l_message_title             varchar2(1000) := 'CATER Change';
    l_shop_mgr_email		PERSONS.PERSON.MAILDISP%TYPE;
    l_email_size_limit_reached  varchar2(1) := 'N';
    l_script_name               varchar2(100);

    l_assignedto_chg		varchar2(1) := 'N';
    l_email_chk			varchar2(1) := 'N';
    l_email_pref		varchar2(1) := 'N';

    l_maildisp                   PERSONS.PERSON.MAILDISP%TYPE;
    l_name                       PERSONS.PERSON.NAME%TYPE;   
    to_address                   varchar2(1024);

/* Not being used
    l_template                  varchar2(10) := 'PLAIN';
-- Check where is this getting used in the original package ???
    l_now                       date := sysdate;
    l_char_now                  varchar2(30) := to_char(l_now,c_date_time_format);
    l_job_rec                   art_jobs%rowtype;
    l_edit_url                  varchar2(1000);
    l_read_only_url             varchar2(1000);

    V_ERRMSG   VARCHAR2(1000);
*/

-- Poonam Jan 2016 - Select only 5 latest Jobs for email
    -- jobs - Only Latest 5 jobs
    cursor job_cur(p_prob_id art_problems.prob_id%type) is
       select * from (
	select *
        from art_jobs
        where prob_id = p_prob_id
--	and   status_chk NOT IN (1,2)
        order by job_number desc)
       where rownum < 6;

    job_rec art_jobs%rowtype;

-- Poonam Jan 2016 - Do not select Closed/Drop Forms
    -- rad safety forms
    cursor rsw_cur(p_prob_id rsw_form.prob_id%type) is
        select *
        from rsw_form
        where prob_id = p_prob_id
	and form_status_id < 6
        order by form_id;

    rsw_rec rsw_form%rowtype;

-- Poonam Jan 2016 - Select only 5 latest Active Solutions/Tasks
    -- solutions
    cursor sol_cur(p_prob_id art_problems.prob_id%type) is
    select * from (
        select *
        from art_solutions
        where prob_id = p_prob_id
	and nvl(review_to_close_chk,'N') = 'N'
        order by solution_number desc)
    where rownum < 6;

    sol_rec art_solutions%rowtype;

begin
    fetch pi_prob_rec_new into l_prob_rec_new;
    fetch pi_prob_rec_old into l_prob_rec_old;

IF pi_operation is NULL then
   l_operation := l_prob_rec_new.prob_operation;
ELSE
   l_operation := pi_operation;
END IF;

l_message_type := pi_message_type;

IF pi_call_from IS NULL THEN
  IF l_operation = 'I' THEN
    l_changer_email := lower(l_prob_rec_new.created_by) || '@' || 'slac.stanford.edu';
  ELSE
    l_changer_email := lower(l_prob_rec_new.modified_by) || '@' || 'slac.stanford.edu';
  END IF;
  l_from := l_changer_email;
  --
	CATER_MESSAGE_NEW.check_cater_preferences
	(pi_prob_rec_new  => l_prob_rec_new
	,pi_prob_rec_old  => l_prob_rec_old
	,pi_table_name    => 'ART_PROBLEMS'
	,pi_from          => l_from
	,pi_operation     => l_operation
	,po_user_email    => l_user_email
	);
ELSE
   l_from := pi_from;
END IF;

IF l_user_email IS NULL THEN
   l_email_pref := 'N';
ELSE
   l_email_pref := 'Y';
END IF;
--
IF (nvl(l_prob_rec_old.assignedto_id,'0') != l_prob_rec_new.assignedto_id) -- assigned to has changed
THEN
   l_assignedto_chg := 'Y';
ELSE
   l_assignedto_chg := 'N';
END IF;
--
    if pi_call_from = 'email_problem_by_id'
    then
        to_address := pi_to;
    else
      if l_assignedto_chg = 'Y' and
         l_prob_rec_new.assignedto_id is not null
        then   /* send to whoever is the task person */
            begin
                select a.maildisp, a.name
                into to_address, l_name
                from person a
                where a.key = l_prob_rec_new.assignedto_id;
            exception when others then
                to_address := null;
            end;
        end if;
    end if;
--
IF l_prob_rec_new.email_chk is null THEN
   l_email_chk := 'N';
ELSIF l_prob_rec_new.email_chk = 'Y' THEN
   l_email_chk := 'Y';
ELSE
   l_email_chk := 'N';
END IF;
--

IF l_operation = 'I' -- new problem
OR nvl(l_prob_rec_new.email_chk,'N') = 'Y' -- just use the email flag
--OR l_assignedto_chg = 'Y'
OR (nvl(l_prob_rec_old.assignedto_id,0) != nvl(l_prob_rec_new.assignedto_id,0)) -- assigned to has changed
or l_user_email IS NOT NULL -- If cater preferences is set for any user
THEN

--Poonam - added code to get the status for the Subject Line
    select GETVAL('PROB_STATUS_DISP', l_prob_rec_new.status_chk)
    into l_status
    from dual;
    --
    -- set appropriate title for message
    -- Poonam - 10/21/2014 - Put Title for all Subject lines if available.
    l_problem_title:= substr(nvl(l_prob_rec_new.problem_title,l_prob_rec_new.description),1,50);

    l_message_title := l_message_title || substr(l_problem_title,1,240);
    l_app_user := lower(nvl(v('APP_USER'),user));

    --
    -- begin message
    --
    CATER_MESSAGE_NEW.message_begin
    (pi_operation            => l_operation
    ,pi_message_type         => l_message_type
    ,pi_from                 => l_from
    ,pi_to                   => to_address
    ,pi_subject		     => pi_subject
    ,pi_app_user             => l_prob_rec_new.modified_by
    ,pi_prob_type_chk        => l_prob_rec_new.prob_type_chk
    ,pi_job_type_chk         => null
    ,pi_status_chk           => l_prob_rec_new.status_chk
    ,pi_status               => l_status
    ,pi_schema_user          => user
    ,pi_assigned_to          => null
    ,pi_prob_id              => l_prob_rec_new.prob_id
    ,pi_problem_title        => l_problem_title
    ,pi_job_id               => null
    ,pi_job_number           => null
    ,pi_sol_id               => null
    ,pi_task_person_id       => l_prob_rec_new.assignedto_id
    ,pi_created_date         => l_prob_rec_new.created_date
    ,pi_created_by           => l_prob_rec_new.created_by
    ,pi_modified_date        => l_prob_rec_new.modified_date
    ,pi_modified_by          => l_prob_rec_new.modified_by
    ,pi_comment              => pi_comment
    ,po_message_to           => l_message_to
    ,po_html_message_subject => l_html_message_subject
    ,po_text_message_subject => l_text_message_subject
    ,po_html_message_body    => l_html_message_body
    ,po_text_message_body    => l_text_message_body
    ,po_apex_url_prefix      => l_apex_url_prefix
    ,po_instance             => l_instance
    );

    --
    -- build message body
    --
-- Even Manual Email is setting pi_operation = 'I' from email_problem_by_id
	IF l_prob_rec_new.prob_type_chk = 'SOFTWARE'
        THEN
            sw_prob_message_body_content
            (pi_prob_rec_new      => l_prob_rec_new
            ,pi_prob_rec_old      => l_prob_rec_old
            ,pi_message_type      => l_message_type
            ,pi_apex_url_prefix   => l_apex_url_prefix
            ,pi_html_message_body => l_html_message_body
            ,pi_text_message_body => l_text_message_body
            ,po_html_message_body => l_html_message_body
            ,po_text_message_body => l_text_message_body
            );

        ELSIF l_prob_rec_new.prob_type_chk = 'HARDWARE'
        THEN
            hw_prob_message_body_content
            (pi_prob_rec_new      => l_prob_rec_new
            ,pi_prob_rec_old      => l_prob_rec_old
            ,pi_message_type      => l_message_type
            ,pi_apex_url_prefix   => l_apex_url_prefix
            ,pi_html_message_body => l_html_message_body
            ,pi_text_message_body => l_text_message_body
            ,po_html_message_body => l_html_message_body
            ,po_text_message_body => l_text_message_body
            );

        ELSIF l_prob_rec_new.prob_type_chk = 'REQUEST'
        THEN
            request_message_body_content
            (pi_prob_rec_new      => l_prob_rec_new
            ,pi_prob_rec_old      => l_prob_rec_old
            ,pi_message_type      => l_message_type
            ,pi_apex_url_prefix   => l_apex_url_prefix
            ,pi_html_message_body => l_html_message_body
            ,pi_text_message_body => l_text_message_body
            ,po_html_message_body => l_html_message_body
            ,po_text_message_body => l_text_message_body
            );
        ELSE
            NULL;
        END IF;
    --
    -- jobs
    --
    IF l_message_type = 'R'
    THEN
        l_message_type := l_message_type || 'P';
        OPEN job_cur(l_prob_rec_new.prob_id);
        LOOP
            FETCH job_cur into job_rec;
            EXIT when job_cur%notfound or l_email_size_limit_reached = 'Y';

            l_html_message_body := l_html_message_body || c_empty_table_row || c_plain_break;

            IF job_rec.job_type_chk = 'SOFTWARE'
            THEN
                cater_sw_job_message_body
                (pi_job_rec_new       => job_rec
                ,pi_message_type      => l_message_type
                ,pi_apex_url_prefix   => l_apex_url_prefix
                ,pi_html_message_body => l_html_message_body
                ,pi_text_message_body => l_text_message_body
                ,po_html_message_body => l_html_message_body
                ,po_text_message_body => l_text_message_body
                );

            ELSIF job_rec.job_type_chk = 'HARDWARE'
            THEN
                cater_hw_job_message_body
                (pi_job_rec_new       => job_rec
                ,pi_message_type      => l_message_type
                ,pi_apex_url_prefix   => l_apex_url_prefix
                ,pi_html_message_body => l_html_message_body
                ,pi_text_message_body => l_text_message_body
                ,po_html_message_body => l_html_message_body
                ,po_text_message_body => l_text_message_body
                );
            ELSE
                NULL;
            END IF;

            IF length(l_html_message_body) > c_email_size_limit
            THEN

                l_email_size_limit_reached := 'Y';

            END IF;
        END LOOP;
        CLOSE job_cur;

        OPEN rsw_cur(l_prob_rec_new.prob_id);
        LOOP
            FETCH rsw_cur into rsw_rec;
            EXIT when rsw_cur%notfound or l_email_size_limit_reached = 'Y';

            l_html_message_body := l_html_message_body || c_empty_table_row || c_plain_break;

            rsw_message_body_content
            (pi_rsw_rec_new       => rsw_rec
            ,pi_message_type      => l_message_type
            ,pi_apex_url_prefix   => l_apex_url_prefix
            ,pi_html_message_body => l_html_message_body
            ,pi_text_message_body => l_text_message_body
            ,po_html_message_body => l_html_message_body
            ,po_text_message_body => l_text_message_body
            );

        END LOOP;
        CLOSE rsw_cur;
        --
        -- solutions
        --
        IF l_email_size_limit_reached != 'Y'
        THEN
            FOR sol_rec in sol_cur(l_prob_rec_new.prob_id)
            LOOP
                l_html_message_body := l_html_message_body || c_empty_table_row || c_plain_break;

                cater_solution_message_body
                (pi_sol_rec_new       => sol_rec
                ,pi_message_type      => l_message_type
                ,pi_apex_url_prefix   => l_apex_url_prefix
                ,pi_prob_type_chk     => l_prob_rec_new.prob_type_chk
                ,pi_html_message_body => l_html_message_body
                ,pi_text_message_body => l_text_message_body
                ,po_html_message_body => l_html_message_body
                ,po_text_message_body => l_text_message_body
                );

            IF length(l_html_message_body) > c_email_size_limit
            THEN

                l_email_size_limit_reached := 'Y';
            END IF;

            END LOOP;
        END IF;
    END IF;
--
IF l_user_email IS NOT NULL THEN
   l_message_to := l_message_to ||';'|| l_user_email;
END IF;

-- Poonam - Adding COMMENT here
    CATER_MESSAGE_NEW.message_end
    (pi_app_id              => c_app_id
    ,pi_script_name         => l_script_name
    ,pi_instance            => l_instance
    ,pi_div_code_id         => l_prob_rec_new.div_code_id
    ,pi_prob_id             => l_prob_rec_new.prob_id
    ,pi_sol_id              => null
    ,pi_job_id              => null
    ,pi_shop_id             => l_prob_rec_new.shop_main_id
    ,pi_subsystem_id        => l_prob_rec_new.subsystem_id
    ,pi_prob_type_chk       => l_prob_rec_new.prob_type_chk
    ,pi_page_name           => null
    ,pi_from                => l_from
    ,pi_to                  => l_message_to
    ,pi_subject             => l_message_title
    ,pi_comment              => pi_comment
    ,pi_html_body           => l_html_message_body
    ,pi_text_body           => l_text_message_body
    ,pi_html_subject        => l_html_message_subject
    ,pi_text_subject        => l_text_message_subject
    ,pi_is_active           => c_send_email
    ,pi_message_type        => l_message_type
    ,pi_size_limit_reached  => l_email_size_limit_reached
    );
END IF; -- Checking for Email.
--
-- Setting prob_chg_email_chk = 9, so as not to be picked up in next round of processing
-- ***** Add reporting for all prob_chg_email_chk = 9, to see what errors happened.
--
UPDATE art_problems_email
set prob_chg_email_chk = 0
where prob_email_id = l_prob_rec_new.prob_email_id;
COMMIT;

EXCEPTION
    WHEN others
    THEN

        l_errmsg := 'Prob_id=' || l_prob_rec_new.prob_id || ' ' || substr('ERROR: '||c_proc||': '||sqlerrm,1,1000) || ' ' || dbms_utility.format_error_backtrace();
        l_errmsg := pkg.format_msg(l_errmsg, l_html_flag);

        apps_util.utl.log_add
        (p_appl_id         => 1
        ,p_trans_id        => null
        ,p_message_type_id => 1
        ,p_text            => l_errmsg
        );

END email_cater_problem;

procedure email_cater_sol
is
    c_proc    constant varchar2(100) := 'CATER_MESSAGE_NEW.email_cater_sol ';

    cursor email_grp_cur is
      select sol_email_id, count(*) as row_count 
      from art_solutions_email
      where sol_chg_email_chk = 1
      and trunc(sol_email_datetime) = trunc(sysdate)
      group by sol_email_id
      order by sol_email_id;

l_sol_email_id  art_solutions_email.sol_email_id%TYPE;
l_row_count	NUMBER;

sol_email_new   sys_refcursor;
sol_email_old   sys_refcursor := NULL;

begin
 OPEN email_grp_cur;
 LOOP
  FETCH email_grp_cur into l_sol_email_id, l_row_count; 
  EXIT when email_grp_cur%NOTFOUND;

   OPEN sol_email_old for
      select * from ART_SOLUTIONS_EMAIL
      where 1 = 0;

   OPEN sol_email_new for
      select * from art_solutions_email
      where sol_email_id = l_sol_email_id
      and sol_rec_type = 'NEW';
    IF l_row_count > 1 then
      open sol_email_old for
      select * from art_solutions_email
      where sol_email_id = l_sol_email_id
      and sol_rec_type = 'OLD';
    END IF;

        CATER_MESSAGE_NEW.email_cater_sol_dtl
	(pi_sol_rec_new => sol_email_new
	,pi_sol_rec_old => sol_email_old
	,pi_message_type => 'SE' 
	);

END LOOP;
CLOSE email_grp_cur;

END email_cater_sol;

procedure email_cater_sol_dtl
(pi_sol_rec_new   in src
,pi_sol_rec_old   in src := null
,pi_operation     in varchar2
,pi_from          in varchar2
,pi_to            in varchar2
,pi_subject       in varchar2
,pi_comment       in varchar2
,pi_message_type  in varchar2
,pi_prob_type_chk in varchar2
,pi_call_from     in varchar2
) is

    c_proc            constant varchar2(100) := 'CATER_MESSAGE_NEW.email_cater_sol_dtl ';
    c_send_email      constant char := 'Y';  -- change this to 'Y' to hit the email server

    l_template                 varchar2(10) := 'PLAIN';
    l_app_user                 varchar2(100);
    l_script_name              varchar2(100);
    l_html_message_body        clob;
    l_text_message_body        clob;
    l_html_message_subject     varchar2(1000);
    l_text_message_subject     varchar2(1000);
    l_message_to               varchar2(500);
    l_message_title            varchar2(1000) := 'Sol Change';
    l_errmsg                   varchar2(1000) := null;
    l_html_flag                varchar2(1);
    l_now                      date := sysdate;
    l_char_now                 varchar2(30) := to_char(l_now,c_date_time_format);
    l_line_number              pls_integer := 0;
    l_instance                 varchar2(100);

    l_apex_url_prefix          varchar2(100);
    l_edit_url                 varchar2(1000);
    l_read_only_url            varchar2(1000);
-- Poonam - Added new variable
    l_status			varchar2(30);
    l_user_email		VARCHAR2(500);
    l_shop_mgr_email		PERSONS.PERSON.MAILDISP%TYPE := NULL;

    l_sol_rec_new		art_solutions_email%rowtype;
    l_sol_rec_old		art_solutions_email%rowtype;
  --
    l_prob_type_chk		VARCHAR2(25);
    l_message_type              varchar2(10);
    l_changer_email		varchar2(100);
    l_from			varchar2(100);
    l_operation			varchar2(1);

    l_assignedto_chg		varchar2(1) := 'N';
    l_maildisp                   PERSONS.PERSON.MAILDISP%TYPE;
    l_name                       PERSONS.PERSON.NAME%TYPE;   
    to_address                   varchar2(1024);
BEGIN
    --
    -- set appropriate title for message
    --

    FETCH pi_sol_rec_new into l_sol_rec_new;
    FETCH pi_sol_rec_old into l_sol_rec_old;

IF pi_operation is NULL then
   l_operation := l_sol_rec_new.sol_operation;
ELSE
   l_operation := pi_operation;
END IF;

l_message_type := pi_message_type;
IF pi_prob_type_chk IS NULL THEN
    IF l_sol_rec_new.sol_type_chk = 'TASK' -- solution/task flag
    THEN
        l_prob_type_chk := 'REQUEST'; -- task
    ELSE
        l_prob_type_chk := 'R'; -- full breakdown report
    END IF;
ELSE
   l_prob_type_chk := pi_prob_type_chk;
END IF;

IF pi_call_from IS NULL THEN
  IF l_operation = 'I' THEN
    l_changer_email := lower(l_sol_rec_new.created_by) || '@' || 'slac.stanford.edu';
  ELSE
    l_changer_email := lower(l_sol_rec_new.modified_by) || '@' || 'slac.stanford.edu';
  END IF;

  l_from := l_changer_email;
  --
 	CATER_MESSAGE_NEW.check_sol_preferences
        (pi_sol_rec_new  => l_sol_rec_new
        ,pi_sol_rec_old  => l_sol_rec_old
	,pi_table_name    => 'ART_SOLUTIONS'
	,pi_from          => l_from
	,pi_operation     => l_operation
	,po_user_email    => l_user_email
	);
ELSE
   l_from := pi_from;
END IF;

IF (nvl(l_sol_rec_old.solvedby_id,'0') != l_sol_rec_new.solvedby_id) -- assigned to has changed
THEN
   l_assignedto_chg := 'Y';
ELSE
   l_assignedto_chg := 'N';
END IF;
--
    if pi_call_from = 'email_sol_by_id'
    then
        to_address := pi_to;
    else
      if l_assignedto_chg = 'Y' and
         l_sol_rec_new.solvedby_id is not null
        then   /* send to whoever is the task person */
            begin
                select a.maildisp, a.name
                into to_address, l_name
                from person a
                where a.key = l_sol_rec_new.solvedby_id;
            exception when others then
                to_address := null;
            end;
        end if;
    end if;
--
IF l_operation = 'I' -- new solution/task
OR (nvl(l_sol_rec_old.solvedby_id,0) <> nvl(l_sol_rec_new.solvedby_id,0)) -- assigned to has changed
OR (nvl(l_sol_rec_old.shop_main_id,0) <> nvl(l_sol_rec_new.shop_main_id,0)) -- assigned to has changed
OR l_user_email IS NOT NULL 
THEN

    l_message_title := l_message_title || substr(l_sol_rec_new.description,1,240);
    l_app_user := lower(NVL(V('APP_USER'),USER));

-- Poonam - Added Status to pass to MESSAGE_BEGIN Procedure for Solution Status in Subject line.
    select decode(NVL(l_sol_rec_new.review_to_close_chk,'N'),'N','Active','Y','Complete','Active')
    into l_status
    from dual;

    --
    -- begin message
    --
    CATER_MESSAGE_NEW.message_begin
    (pi_operation            => l_operation
    ,pi_message_type         => l_message_type
    ,pi_from                 => l_from
    ,pi_to                   => to_address
    ,pi_subject		     => pi_subject
    ,pi_app_user             => l_sol_rec_new.modified_by
    ,pi_prob_type_chk        => null
    ,pi_job_type_chk         => null
    ,pi_status_chk           => null
    ,pi_status               => l_status                       -- new - Poonam
    ,pi_schema_user          => user
    ,pi_assigned_to          => null
    ,pi_prob_id              => l_sol_rec_new.prob_id
    ,pi_problem_title        => null
    ,pi_job_id               => null
    ,pi_job_number           => l_sol_rec_new.solution_number  -- null - Modified to pass Solution number - Poonam
    ,pi_sol_id               => l_sol_rec_new.sol_id
    ,pi_task_person_id       => l_sol_rec_new.solvedby_id
    ,pi_created_date         => l_sol_rec_new.created_date
    ,pi_created_by           => l_sol_rec_new.created_by
    ,pi_modified_date        => l_sol_rec_new.modified_date
    ,pi_modified_by          => l_sol_rec_new.modified_by
    ,pi_comment              => pi_comment
    ,po_message_to           => l_message_to
    ,po_html_message_subject => l_html_message_subject
    ,po_text_message_subject => l_text_message_subject
    ,po_html_message_body    => l_html_message_body
    ,po_text_message_body    => l_text_message_body
    ,po_apex_url_prefix      => l_apex_url_prefix
    ,po_instance             => l_instance
    );
    --
    -- build message body
    --

-- Manual Email is coming in as pi_operation='I' from email_sol_by_id proc.
    solution_message_body_content
    (pi_sol_rec_new       => l_sol_rec_new
    ,pi_sol_rec_old       => l_sol_rec_old
    ,pi_message_type      => l_message_type
    ,pi_apex_url_prefix   => l_apex_url_prefix
    ,pi_prob_type_chk     => l_prob_type_chk
    ,pi_html_message_body => l_html_message_body
    ,pi_text_message_body => l_text_message_body
    ,po_html_message_body => l_html_message_body
    ,po_text_message_body => l_text_message_body
    );
--
IF l_user_email IS NOT NULL THEN
   l_message_to := l_message_to ||';'|| l_user_email;
END IF;
--
-- Poonam - Adding COMMENT here
    CATER_MESSAGE_NEW.message_end
    (pi_app_id       => c_app_id
    ,pi_script_name  => l_script_name
    ,pi_instance     => l_instance
    ,pi_div_code_id  => l_sol_rec_new.div_code_id
    ,pi_prob_id      => l_sol_rec_new.prob_id
    ,pi_sol_id       => l_sol_rec_new.sol_id
    ,pi_job_id       => null
    ,pi_shop_id      => null
    ,pi_subsystem_id => null
    ,pi_job_type_chk => null
    ,pi_page_name    => null
    ,pi_from         => l_from
    ,pi_to           => l_message_to
    ,pi_subject      => l_message_title
    ,pi_comment              => pi_comment
    ,pi_html_body    => l_html_message_body
    ,pi_text_body    => l_text_message_body
    ,pi_html_subject => l_html_message_subject
    ,pi_text_subject => l_text_message_subject
    ,pi_is_active    => c_send_email
    ,pi_message_type => l_message_type
    );
END IF;
--
UPDATE art_solutions_email
set sol_chg_email_chk = 0
where sol_email_id = l_sol_rec_new.sol_email_id;
--
COMMIT;
--
EXCEPTION
    WHEN others
    THEN
        l_errmsg := c_proc || sqlerrm;

        apps_util.utl.log_add
        (p_appl_id         => 1
        ,p_trans_id        => null
        ,p_message_type_id => 1
        ,p_text            => l_errmsg
        );

END email_cater_sol_dtl;

procedure email_cater_job
is

    c_proc    constant	varchar2(100) := 'CATER_MESSAGE_NEW.email_cater_job ';
    l_job_email_id	art_jobs_email.job_email_id%TYPE;
    l_row_count		NUMBER;

    jobs_email_new	sys_refcursor;
    jobs_email_old	sys_refcursor;

    cursor email_grp_cur is
      select job_email_id, count(*) as row_count 
      from art_jobs_email
      where job_chg_email_chk = 1
      and trunc(job_email_datetime) = trunc(sysdate)
      group by job_email_id
      order by job_email_id;

BEGIN
 OPEN email_grp_cur;
 LOOP
  FETCH email_grp_cur into l_job_email_id, l_row_count; 
  EXIT when email_grp_cur%NOTFOUND;

   OPEN jobs_email_old for
      select * from art_jobs_email
      where 1 = 0;

   OPEN jobs_email_new for
      select * from art_jobs_email
      where job_email_id = l_job_email_id
      and job_rec_type = 'NEW';
    IF l_row_count > 1 then
      open jobs_email_old for
      select * from art_jobs_email
      where job_email_id = l_job_email_id
      and job_rec_type = 'OLD';
    END IF;

        CATER_MESSAGE_NEW.email_cater_job_dtl
	(pi_job_rec_new => jobs_email_new
	,pi_job_rec_old => jobs_email_old
	,pi_message_type => 'SE'
	);

END LOOP;
CLOSE email_grp_cur;

END email_cater_job;

procedure email_cater_job_dtl
(pi_job_rec_new in jrc
,pi_job_rec_old in jrc := null
,pi_operation     in varchar2
,pi_from          in varchar2
,pi_to            in varchar2
,pi_subject       in varchar2
,pi_comment       in varchar2
,pi_message_type  in varchar2
,pi_call_from     in varchar2
) is

    c_proc            constant varchar2(100) := 'CATER_MESSAGE_NEW.email_cater_job_dtl ';
    c_send_email      constant char := 'Y';  -- change this to 'Y' to hit the email server
    c_empty_table_row constant varchar2(100):= '<tr><td>&nbsp</td><td>&nbsp</td></tr>';

    l_template                 varchar2(10) := 'PLAIN';
    l_app_user                 varchar2(100);
    l_script_name              varchar2(100);
    l_html_message_body        clob;
    l_text_message_body        clob;
    l_html_message_subject     varchar2(1000);
    l_text_message_subject     varchar2(1000);
    l_message_to               varchar2(500);
    l_message_title            varchar2(1000) := 'Job Change';
    l_errmsg                   varchar2(1000) := null;
    l_html_flag                varchar2(1);
    l_now                      date := sysdate;
    l_char_now                 varchar2(30) := to_char(l_now,c_date_time_format);
    l_line_number              pls_integer := 0;
    l_instance                 varchar2(100);

    l_apex_url_prefix          varchar2(100);
    l_edit_url                 varchar2(1000);
    l_read_only_url            varchar2(1000);

    l_email_size_limit_reached varchar2(1) := 'N';

    -- Poonam - added new variable
    l_status			varchar2(30);
    l_user_email		VARCHAR2(500);
    l_shop_mgr_email		PERSONS.PERSON.MAILDISP%TYPE := NULL;

    l_job_rec_new		art_jobs_email%rowtype;
    l_job_rec_old		art_jobs_email%rowtype := null;

    l_message_type              varchar2(10);
    l_changer_email		varchar2(100);
    l_from			varchar2(100);
    l_operation			varchar2(1);

    l_assignedto_chg		varchar2(1) := 'N';
    l_maildisp                   PERSONS.PERSON.MAILDISP%TYPE;
    l_name                       PERSONS.PERSON.NAME%TYPE;   
    to_address                   varchar2(1024);

    cursor rsw_cur(p_job_id rsw_form.job_id%type) is
        select *
        from rsw_form
        where job_id = p_job_id
        order by form_id;

    rsw_rec rsw_form%rowtype;

BEGIN
    FETCH pi_job_rec_new into l_job_rec_new;
    FETCH pi_job_rec_old into l_job_rec_old;

l_message_type := pi_message_type;

IF pi_operation is NULL THEN
   l_operation := l_job_rec_new.job_operation;
ELSE
   l_operation := pi_operation;
END IF;
    --
    -- set title for message
    --

    l_message_title := l_message_title || substr(l_job_rec_new.name,1,240);
    l_app_user := lower(NVL(V('APP_USER'),USER));

IF pi_call_from IS NULL THEN
  IF l_operation = 'I' then
    l_changer_email := lower(l_job_rec_new.created_by) || '@' || 'slac.stanford.edu';
  ELSE
    l_changer_email := lower(l_job_rec_new.modified_by) || '@' || 'slac.stanford.edu';
  END IF;
  l_from := l_changer_email;

	CATER_MESSAGE_NEW.check_job_preferences
	(pi_job_rec_new  => l_job_rec_new
	,pi_job_rec_old  => l_job_rec_old
	,pi_table_name   => 'ART_JOBS'
	,pi_from         => l_from
	,pi_operation    => l_operation
	,po_user_email   => l_user_email
	);
ELSE
   l_from := pi_from;
END IF;

IF (nvl(l_job_rec_old.TASK_PERSON_ID,'0') != l_job_rec_new.TASK_PERSON_ID) -- assigned to has changed
THEN
   l_assignedto_chg := 'Y';
ELSE
   l_assignedto_chg := 'N';
END IF;
--
    if pi_call_from = 'email_job_by_id'
    then
        to_address := pi_to;
    else
      if l_assignedto_chg = 'Y' and
         l_job_rec_new.TASK_PERSON_ID is not null
        then   /* send to whoever is the task person */
            begin
                select a.maildisp, a.name
                into to_address, l_name
                from person a
                where a.key = l_job_rec_new.TASK_PERSON_ID;
            exception when others then
                to_address := null;
            end;
        end if;
    end if;
--

IF l_operation = 'I' -- new job
OR l_job_rec_new.email_chk = 'Y'
OR (nvl(l_job_rec_old.task_person_id,1) <> nvl(l_job_rec_new.task_person_id,1)) -- task person changes
OR l_user_email IS NOT NULL
THEN

    -- Poonam - added code for getting STATUS for Subject line
    select getval('JOB_STATUS',l_job_rec_new.status_chk)
    into l_status
    from dual;

    -- begin message
    --
    CATER_MESSAGE_NEW.message_begin
    (pi_operation            => l_operation
    ,pi_message_type         => l_message_type
    ,pi_from                 => l_from
    ,pi_to                   => to_address
    ,pi_subject		     => pi_subject
    ,pi_app_user             => l_job_rec_new.modified_by
    ,pi_prob_type_chk        => null
    ,pi_job_type_chk         => l_job_rec_new.job_type_chk
    ,pi_status_chk           => l_job_rec_new.status_chk
    ,pi_status               => l_status                    -- Poonam - new
    ,pi_schema_user          => user
    ,pi_assigned_to          => null
    ,pi_prob_id              => l_job_rec_new.prob_id
    ,pi_problem_title        => null
    ,pi_job_id               => l_job_rec_new.job_id
    ,pi_job_number           => l_job_rec_new.job_number
    ,pi_sol_id               => null
    ,pi_task_person_id       => l_job_rec_new.task_person_id
    ,pi_created_date         => l_job_rec_new.created_date
    ,pi_created_by           => l_job_rec_new.created_by
    ,pi_modified_date        => l_job_rec_new.modified_date
    ,pi_modified_by          => l_job_rec_new.modified_by
    ,pi_comment              => pi_comment
    ,po_message_to           => l_message_to
    ,po_html_message_subject => l_html_message_subject
    ,po_text_message_subject => l_text_message_subject
    ,po_html_message_body    => l_html_message_body
    ,po_text_message_body    => l_text_message_body
    ,po_apex_url_prefix      => l_apex_url_prefix
    ,po_instance             => l_instance
    );
    --
    -- build message body
    --
        IF l_job_rec_new.job_type_chk = 'SOFTWARE'
        THEN

            CATER_MESSAGE_NEW.sw_job_message_body_content
            (pi_job_rec_new       => l_job_rec_new
            ,pi_job_rec_old       => l_job_rec_old
            ,pi_message_type      => l_message_type
            ,pi_apex_url_prefix   => l_apex_url_prefix
            ,pi_html_message_body => l_html_message_body
            ,pi_text_message_body => l_text_message_body
            ,po_html_message_body => l_html_message_body
            ,po_text_message_body => l_text_message_body
            );

        ELSIF l_job_rec_new.job_type_chk = 'HARDWARE'
        THEN

            CATER_MESSAGE_NEW.hw_job_message_body_content
            (pi_job_rec_new       => l_job_rec_new
            ,pi_job_rec_old       => l_job_rec_old
            ,pi_message_type      => l_message_type
            ,pi_apex_url_prefix   => l_apex_url_prefix
            ,pi_html_message_body => l_html_message_body
            ,pi_text_message_body => l_text_message_body
            ,po_html_message_body => l_html_message_body
            ,po_text_message_body => l_text_message_body
            );

        ELSE
            NULL;
        END IF;

    --
    -- rad safety forms for job
    --
    OPEN rsw_cur(l_job_rec_new.job_id);
    LOOP

        FETCH rsw_cur into rsw_rec;
        EXIT when rsw_cur%notfound or l_email_size_limit_reached = 'Y';

        l_html_message_body := l_html_message_body || c_empty_table_row || c_plain_break;

        rsw_message_body_content
        (pi_rsw_rec_new       => rsw_rec
        ,pi_message_type      => l_message_type
        ,pi_apex_url_prefix   => l_apex_url_prefix
        ,pi_html_message_body => l_html_message_body
        ,pi_text_message_body => l_text_message_body
        ,po_html_message_body => l_html_message_body
        ,po_text_message_body => l_text_message_body
        );

    END LOOP;
    CLOSE rsw_cur;

/* **************** Poonam - Discuss it further ??????????????????????????????
IF l_job_rec_new.task_person_id IS NULL THEN
  IF l_job_rec_new.shop_main_id IS NOT NULL THEN
    BEGIN
      select getval('EMAIL_ID', shop_mgr_id)
      into l_shop_mgr_email
      from art_shops
      where shop_id = l_job_rec_new.shop_main_id;

     l_message_to := l_message_to ||';'|| l_shop_mgr_email;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
  END IF;
END IF;
*/
--
IF l_user_email IS NOT NULL THEN
   l_message_to := l_message_to ||';'|| l_user_email;
END IF;
--
-- Poonam - Adding COMMENT here.
    CATER_MESSAGE_NEW.message_end
    (pi_app_id       => c_app_id
    ,pi_script_name  => l_script_name
    ,pi_instance     => l_instance
    ,pi_div_code_id  => l_job_rec_new.div_code_id
    ,pi_prob_id      => l_job_rec_new.prob_id
    ,pi_sol_id       => null
    ,pi_job_id       => l_job_rec_new.job_id
    ,pi_shop_id      => l_job_rec_new.shop_main_id
    ,pi_subsystem_id => l_job_rec_new.subsystem_id
    ,pi_job_type_chk => l_job_rec_new.job_type_chk
    ,pi_page_name    => null
    ,pi_from         => l_from
    ,pi_to           => l_message_to
    ,pi_subject      => l_message_title
    ,pi_comment              => pi_comment
    ,pi_html_body    => l_html_message_body
    ,pi_text_body    => l_text_message_body
    ,pi_html_subject => l_html_message_subject
    ,pi_text_subject => l_text_message_subject
    ,pi_is_active    => c_send_email
    ,pi_message_type => l_message_type
    );
END IF;

UPDATE art_jobs_email
set job_chg_email_chk = 0
where job_email_id = l_job_rec_new.job_email_id;
--
COMMIT;

EXCEPTION
    WHEN others
    THEN

        l_errmsg := 'Prob_id=' || l_job_rec_new.prob_id || ' ' || substr('ERROR: '|| c_proc || ': ' || sqlerrm,1,1000);
        l_errmsg := pkg.format_msg(l_errmsg, l_html_flag);

        apps_util.utl.log_add
        (p_appl_id         => 1
        ,p_trans_id        => null
        ,p_message_type_id => 1
        ,p_text            => l_errmsg
        );

END email_cater_job_dtl;

procedure cater_sw_job_message_body
(pi_job_rec_new       in  art_jobs%rowtype
,pi_job_rec_old       in  art_jobs%rowtype
,pi_message_type      in  varchar2
,pi_apex_url_prefix   in  varchar2
,pi_html_message_body in  clob
,pi_text_message_body in  clob
,po_html_message_body out clob
,po_text_message_body out clob
) is

    c_proc               constant varchar2(100) := 'CATER_MESSAGE_NEW.cater_sw_job_message_body ';

    l_html_message_body           clob        := pi_html_message_body;
    l_text_message_body           clob        := pi_text_message_body;
    l_line_number                 pls_integer := 0;

    l_description_old             varchar2(500);
    l_description_new             varchar2(500);

    l_issues_old                  varchar2(500);
    l_issues_new                  varchar2(500);

    l_comments_old                varchar2(500);
    l_comments_new                varchar2(500);

    l_test_plan_old               varchar2(500);
    l_test_plan_new               varchar2(500);

    l_backout_plan_old            varchar2(500);
    l_backout_plan_new            varchar2(500);

    l_system_required_old         varchar2(500);
    l_system_required_new         varchar2(500);

    l_systems_affected_old        varchar2(500);
    l_systems_affected_new        varchar2(500);

    l_risk_benefit_old            varchar2(500);
    l_risk_benefit_new            varchar2(500);

    l_dependencies_old            varchar2(500);
    l_dependencies_new            varchar2(500);

    l_follow_up_comments_old      varchar2(500);
    l_follow_up_comments_new      varchar2(500);

begin

    l_description_old := text_overflow(pi_job_rec_old.description,c_max_textarea_length);
    l_description_new := text_overflow(pi_job_rec_new.description,c_max_textarea_length);

    l_issues_old := text_overflow(pi_job_rec_old.issues,c_max_textarea_length);
    l_issues_new := text_overflow(pi_job_rec_new.issues,c_max_textarea_length);

    l_test_plan_old := text_overflow(pi_job_rec_old.test_plan,c_max_textarea_length);
    l_test_plan_new := text_overflow(pi_job_rec_new.test_plan,c_max_textarea_length);

    l_backout_plan_old := text_overflow(pi_job_rec_old.backout_plan,c_max_textarea_length);
    l_backout_plan_new := text_overflow(pi_job_rec_new.backout_plan,c_max_textarea_length);

    l_system_required_old := text_overflow(pi_job_rec_old.systems_required,c_max_textarea_length);
    l_system_required_new := text_overflow(pi_job_rec_new.systems_required,c_max_textarea_length);

-- Poonam - Fixed the System Affected to be NOT Description
    l_systems_affected_old := text_overflow(pi_job_rec_old.systems_affected,c_max_textarea_length);
    l_systems_affected_new := text_overflow(pi_job_rec_new.systems_affected,c_max_textarea_length);

    l_risk_benefit_old := text_overflow(pi_job_rec_old.risk_benefit_descr,c_max_textarea_length);
    l_risk_benefit_new := text_overflow(pi_job_rec_new.risk_benefit_descr,c_max_textarea_length);

    l_dependencies_old := text_overflow(pi_job_rec_old.dependencies,c_max_textarea_length);
    l_dependencies_new := text_overflow(pi_job_rec_new.dependencies,c_max_textarea_length);

    l_follow_up_comments_old := text_overflow(pi_job_rec_old.comments,c_max_textarea_length);
    l_follow_up_comments_new := text_overflow(pi_job_rec_new.comments,c_max_textarea_length);

    message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'CATER Id',       pi_old=>pi_job_rec_old.prob_id,                                  pi_new=>pi_job_rec_new.prob_id,                                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'SW Job Number',       pi_old=>pi_job_rec_old.job_number,                                  pi_new=>pi_job_rec_new.job_number,                                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Description',         pi_old=>l_description_old,                                          pi_new=>l_description_new,                                          pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Planned Start Time',  pi_old=>to_char(pi_job_rec_old.start_time,c_date_time_format),      pi_new=>to_char(pi_job_rec_new.start_time,c_date_time_format),      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Status',              pi_old=>getval('JOB_STATUS',pi_job_rec_old.status_chk),             pi_new=>getval('JOB_STATUS',pi_job_rec_new.status_chk),             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Task Person',         pi_old=>getval('NAME',pi_job_rec_old.task_person_id),               pi_new=>getval('NAME',pi_job_rec_new.task_person_id),               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    --message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Job Type',            pi_old=>pi_job_rec_old.job_type_chk,                                pi_new=>pi_job_rec_new.job_type_chk,                                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);

-- Poonam - Changed the Backout Plan to be NOT test Plan
    if pi_message_type != 'RP'
    then
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Division',            pi_old=>getval('DIV_CODE',pi_job_rec_old.div_code_id),              pi_new=>getval('DIV_CODE',pi_job_rec_new.div_code_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Area',                pi_old=>getval('AREA',pi_job_rec_old.area_id),                      pi_new=>getval('AREA',pi_job_rec_new.area_id),                      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Job Title',           pi_old=>pi_job_rec_old.name,                                        pi_new=>pi_job_rec_new.name,                                        pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Shop Main',           pi_old=>getval('SHOP',pi_job_rec_old.shop_main_id),                 pi_new=>getval('SHOP',pi_job_rec_new.shop_main_id),                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Approved by CD',      pi_old=>getval('YESNO',pi_job_rec_old.am_approval_chk),             pi_new=>getval('YESNO',pi_job_rec_new.am_approval_chk),             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Time Needed (hrs)',   pi_old=>to_char(pi_job_rec_old.total_time),                         pi_new=>to_char(pi_job_rec_new.total_time),                         pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Time Comments',       pi_old=>pi_job_rec_old.test_time_needed,                            pi_new=>pi_job_rec_new.test_time_needed,                            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Beam Requirements',   pi_old=>getval('BEAM',pi_job_rec_old.requires_beam_chk),            pi_new=>getval('BEAM',pi_job_rec_new.requires_beam_chk),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Beam Comment',        pi_old=>pi_job_rec_old.beam_comment,                                pi_new=>pi_job_rec_new.beam_comment,                                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Invasive',            pi_old=>getval('YESNO',pi_job_rec_old.invasive_chk),                pi_new=>getval('YESNO',pi_job_rec_new.invasive_chk),                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Invasive Comment',    pi_old=>pi_job_rec_old.invasive_comment,                            pi_new=>pi_job_rec_new.invasive_comment,                            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Scheduling Priority', pi_old=>getval('PRIORITY',pi_job_rec_old.priority_id),              pi_new=>getval('PRIORITY',pi_job_rec_new.priority_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Area Manager',        pi_old=>getval('NAME',pi_job_rec_old.area_mgr_id),                  pi_new=>getval('NAME',pi_job_rec_new.area_mgr_id),                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Subsytem',            pi_old=>getval('SUBSYSTEM',pi_job_rec_old.subsystem_id),            pi_new=>getval('SUBSYSTEM',pi_job_rec_new.subsystem_id),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Work Type',           pi_old=>getval('WORK_TYPE',pi_job_rec_new.work_type_id),            pi_new=>getval('WORK_TYPE',pi_job_rec_new.work_type_id),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Test Plan',           pi_old=>l_test_plan_old,                                            pi_new=>l_test_plan_new,                                            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Backout Plan',        pi_old=>l_backout_plan_old,                                         pi_new=>l_backout_plan_new,                                         pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Systems Affected',    pi_old=>l_systems_affected_old,                                     pi_new=>l_systems_affected_new,                                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Systems Required',    pi_old=>l_system_required_old,                                      pi_new=>l_system_required_new,                                      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Risk/Benefit',        pi_old=>l_risk_benefit_old,                                         pi_new=>l_risk_benefit_new,                                         pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Dependencies',        pi_old=>l_dependencies_old,                                         pi_new=>l_dependencies_new,                                         pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Issues',              pi_old=>l_issues_old,                                               pi_new=>l_issues_new,                                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Followup Comments',   pi_old=>l_follow_up_comments_old,                                   pi_new=>l_follow_up_comments_new,                                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Date Completed',      pi_old=>getval('YESNO',pi_job_rec_old.date_completed),              pi_new=>getval('YESNO',pi_job_rec_new.date_completed),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Created By',          pi_old=>pi_job_rec_old.created_by,                                  pi_new=>pi_job_rec_new.created_by,                                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Created Date',        pi_old=>pi_job_rec_old.created_date,                                pi_new=>pi_job_rec_new.created_date,                                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Modified By',         pi_old=>pi_job_rec_old.modified_by,                                 pi_new=>pi_job_rec_new.modified_by,                                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Modified Date',       pi_old=>pi_job_rec_old.modified_date,                               pi_new=>pi_job_rec_new.modified_date,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    end if;

    po_html_message_body := l_html_message_body;
    po_text_message_body := l_text_message_body;

end cater_sw_job_message_body;


procedure cater_hw_job_message_body
(pi_job_rec_new       in  art_jobs%rowtype
,pi_job_rec_old       in  art_jobs%rowtype
,pi_message_type      in  varchar2
,pi_apex_url_prefix   in  varchar2
,pi_html_message_body in  clob
,pi_text_message_body in  clob
,po_html_message_body out clob
,po_text_message_body out clob
) is

    c_proc               constant varchar2(100) := 'CATER_MESSAGE_NEW.cater_hw_job_message_body ';

    l_html_message_body           clob        := pi_html_message_body;
    l_text_message_body           clob        := pi_text_message_body;
    l_line_number                 pls_integer := 0;

    l_description_old             varchar2(500);
    l_description_new             varchar2(500);

    l_issues_old                  varchar2(500);
    l_issues_new                  varchar2(500);

    l_comments_old                varchar2(500);
    l_comments_new                varchar2(500);

    l_feedback_comments_old       varchar2(500);
    l_feedback_comments_new       varchar2(500);

begin

    l_description_old       := text_overflow(pi_job_rec_old.description,c_max_textarea_length);
    l_description_new       := text_overflow(pi_job_rec_new.description,c_max_textarea_length);

    l_issues_old            := text_overflow(pi_job_rec_old.issues,c_max_textarea_length);
    l_issues_new            := text_overflow(pi_job_rec_new.issues,c_max_textarea_length);

    l_comments_old          := text_overflow(pi_job_rec_old.comments,c_max_textarea_length);
    l_comments_new          := text_overflow(pi_job_rec_new.comments,c_max_textarea_length);

    l_feedback_comments_old := text_overflow(pi_job_rec_old.feedback_comments,c_max_textarea_length);
    l_feedback_comments_new := text_overflow(pi_job_rec_new.feedback_comments,c_max_textarea_length);

    message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'CATER Id',       pi_old=>pi_job_rec_old.prob_id,                                       pi_new=>pi_job_rec_new.prob_id,                                       pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'HW Job Number',       pi_old=>pi_job_rec_old.job_number,                                       pi_new=>pi_job_rec_new.job_number,                                       pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Description',         pi_old=>l_description_old,                                               pi_new=>l_description_new,                                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Planned Start Time',  pi_old=>to_char(pi_job_rec_old.start_time,c_date_time_format),           pi_new=>to_char(pi_job_rec_new.start_time,c_date_time_format),           pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Status',              pi_old=>getval('JOB_STATUS',pi_job_rec_old.status_chk),                  pi_new=>getval('JOB_STATUS',pi_job_rec_new.status_chk),                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Task Person',         pi_old=>getval('NAME',pi_job_rec_old.task_person_id),                    pi_new=>getval('NAME',pi_job_rec_new.task_person_id),                    pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    --message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Rad Safety Form',               pi_old=>pi_job_rec_old.radiation_safety_wcf_chk,                    pi_new=>pi_job_rec_new.radiation_safety_wcf_chk,                    pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Rad Safety Form',     pi_old=>getval('YESNO',nvl(pi_job_rec_old.radiation_safety_wcf_chk,'Y')),pi_new=>getval('YESNO',nvl(pi_job_rec_new.radiation_safety_wcf_chk,'Y')),pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    --message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Rad Safety Form',     pi_old=>getval('YESNO',pi_job_rec_old.radiation_safety_wcf_chk),pi_new=>getval('YESNO',pi_job_rec_new.radiation_safety_wcf_chk),pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);

    if pi_message_type != 'RP' -- abbreviate if this is a problem level email
    then
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Division',            pi_old=>getval('DIV_CODE',pi_job_rec_old.div_code_id),              pi_new=>getval('DIV_CODE',pi_job_rec_new.div_code_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Priority',            pi_old=>getval('PRIORITY',pi_job_rec_old.priority_id),              pi_new=>getval('PRIORITY',pi_job_rec_new.priority_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Area',                pi_old=>getval('AREA',pi_job_rec_old.area_id),                      pi_new=>getval('AREA',pi_job_rec_new.area_id),                      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Area Manager',        pi_old=>getval('NAME',pi_job_rec_old.area_mgr_id),                  pi_new=>getval('NAME',pi_job_rec_new.area_mgr_id),                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Release Conditions Defined',         pi_old=>getval('AM_APPROVAL',pi_job_rec_old.am_approval_chk),             pi_new=>getval('AM_APPROVAL',pi_job_rec_new.am_approval_chk),             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
--        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'AM Approval',         pi_old=>getval('AM_APPROVAL',pi_job_rec_old.am_approval_chk),             pi_new=>getval('AM_APPROVAL',pi_job_rec_new.am_approval_chk),             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Subsytem',            pi_old=>getval('SUBSYSTEM',pi_job_rec_old.subsystem_id),            pi_new=>getval('SUBSYSTEM',pi_job_rec_new.subsystem_id),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Shop Main',           pi_old=>getval('SHOP',pi_job_rec_old.shop_main_id),                 pi_new=>getval('SHOP',pi_job_rec_new.shop_main_id),                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Shop Alt',            pi_old=>getval('SHOP',pi_job_rec_old.shop_alt_id),                  pi_new=>getval('SHOP',pi_job_rec_new.shop_alt_id),                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Total Time',          pi_old=>pi_job_rec_old.total_time,                                  pi_new=>pi_job_rec_new.total_time,                                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Person Hours',        pi_old=>pi_job_rec_old.person_hours,                                pi_new=>pi_job_rec_new.person_hours,                                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Access Req',          pi_old=>getval('ACCESS_REQ',pi_job_rec_old.access_req_id),          pi_new=>getval('ACCESS_REQ',pi_job_rec_new.access_req_id),          pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'RPFO Survey',         pi_old=>getval('YESNO',pi_job_rec_old.rpfo_survey_chk),             pi_new=>getval('YESNO',pi_job_rec_new.rpfo_survey_chk),             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Rad Work Permit',     pi_old=>getval('YESNO',pi_job_rec_old.radiation_work_permit_chk),   pi_new=>getval('YESNO',pi_job_rec_new.radiation_work_permit_chk),   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Lock and Tag',        pi_old=>getval('YESNO',pi_job_rec_old.lock_and_tag_chk),            pi_new=>getval('YESNO',pi_job_rec_new.lock_and_tag_chk),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Building',            pi_old=>getval('BUILDING',pi_job_rec_old.building_id),              pi_new=>getval('BUILDING',pi_job_rec_new.building_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Bldg Mgr',            pi_old=>getval('NAME',pi_job_rec_old.bldgmgr_id),                   pi_new=>getval('NAME',pi_job_rec_new.bldgmgr_id),                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Review Date',         pi_old=>to_char(pi_job_rec_old.review_date,c_date_format),          pi_new=>to_char(pi_job_rec_new.review_date,c_date_format),          pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Work Type',           pi_old=>getval('WORK_TYPE',pi_job_rec_old.work_type_id),            pi_new=>getval('WORK_TYPE',pi_job_rec_new.work_type_id),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'PPS Zone',            pi_old=>getval('PPSZONE',pi_job_rec_old.ppszone_id),                pi_new=>getval('PPSZONE',pi_job_rec_new.ppszone_id),                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Rad Rem Survey',      pi_old=>getval('YESNO',pi_job_rec_old.radiation_removal_survey_chk),pi_new=>getval('YESNO',pi_job_rec_new.radiation_removal_survey_chk),pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Elec Sys Work Frm',   pi_old=>getval('YESNO',pi_job_rec_old.elec_sys_work_ctl_form_chk),  pi_new=>getval('YESNO',pi_job_rec_new.elec_sys_work_ctl_form_chk),  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Asst Bldg Mgr',       pi_old=>getval('NAME',pi_job_rec_old.asst_bldgmgr_id),              pi_new=>getval('NAME',pi_job_rec_new.asst_bldgmgr_id),              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Issues',              pi_old=>l_issues_old,                                               pi_new=>l_issues_new,                                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Comments',            pi_old=>l_comments_old,                                             pi_new=>l_comments_new,                                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Min Hours',           pi_old=>pi_job_rec_old.minimum_hours,                               pi_new=>pi_job_rec_new.minimum_hours,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'# Persons',           pi_old=>pi_job_rec_old.number_of_persons,                           pi_new=>pi_job_rec_new.number_of_persons,                           pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Safety Issues',       pi_old=>getval('YESNO',pi_job_rec_old.safety_issue_chk),            pi_new=>getval('YESNO',pi_job_rec_new.safety_issue_chk),            pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Toco Time',           pi_old=>pi_job_rec_old.toco_time,                                   pi_new=>pi_job_rec_new.toco_time,                                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Atmos Safety',        pi_old=>getval('YESNO',pi_job_rec_old.atmospheric_safety_wcf_chk),  pi_new=>getval('YESNO',pi_job_rec_new.atmospheric_safety_wcf_chk),  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Micro',               pi_old=>pi_job_rec_old.micro,                                       pi_new=>pi_job_rec_new.micro,                                       pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Primary',             pi_old=>pi_job_rec_old.primary,                                     pi_new=>pi_job_rec_new.primary,                                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Unit',                pi_old=>pi_job_rec_old.unit,                                        pi_new=>pi_job_rec_new.unit,                                        pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Ongoing',             pi_old=>getval('YESNO',pi_job_rec_old.ongoing_chk),                 pi_new=>getval('YESNO',pi_job_rec_new.ongoing_chk),                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'RSWCF',               pi_old=>pi_job_rec_old.radiation_safety_wcf_chk,                    pi_new=>pi_job_rec_new.radiation_safety_wcf_chk,                    pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Created By',          pi_old=>pi_job_rec_old.created_by,                                  pi_new=>pi_job_rec_new.created_by,                                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Created Date',        pi_old=>pi_job_rec_old.created_date,                                pi_new=>pi_job_rec_new.created_date,                                pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Modified By',         pi_old=>pi_job_rec_old.modified_by,                                 pi_new=>pi_job_rec_new.modified_by,                                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_job_rec_new.prob_id,pi_job_id=>pi_job_rec_new.job_id,pi_job_type_chk=>pi_job_rec_new.job_type_chk,pi_label=>'Modified Date',       pi_old=>pi_job_rec_old.modified_date,                               pi_new=>pi_job_rec_new.modified_date,                               pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    end if;

    po_html_message_body := l_html_message_body;
    po_text_message_body := l_text_message_body;

end cater_hw_job_message_body;


procedure cater_solution_message_body
(pi_sol_rec_new       in  art_solutions%rowtype
,pi_sol_rec_old       in  art_solutions%rowtype
,pi_message_type      in  varchar2
,pi_apex_url_prefix   in  varchar2
,pi_prob_type_chk     in  varchar2
,pi_html_message_body in  clob
,pi_text_message_body in  clob
,po_html_message_body out clob
,po_text_message_body out clob
) is

    c_proc                   constant varchar2(100)   := 'CATER_MESSAGE_NEW.cater_solution_message_body ';

    l_html_message_body               clob        := pi_html_message_body;
    l_text_message_body               clob        := pi_text_message_body;
    l_line_number                     pls_integer := 0;
    l_description_old                 varchar2(500);
    l_description_new                 varchar2(500);

begin

    message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'CATER Id',       pi_old=>pi_sol_rec_old.prob_id,                     pi_new=>pi_sol_rec_new.prob_id,                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    if pi_prob_type_chk = 'REQUEST'
    then
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Task Number',       pi_old=>pi_sol_rec_old.solution_number,                     pi_new=>pi_sol_rec_new.solution_number,                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    else
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Solution Number',   pi_old=>pi_sol_rec_old.solution_number,                     pi_new=>pi_sol_rec_new.solution_number,                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    end if;

    l_description_old := text_overflow(pi_sol_rec_old.description,c_max_textarea_length);
    l_description_new := text_overflow(pi_sol_rec_new.description,c_max_textarea_length);

    if pi_prob_type_chk = 'REQUEST'
    then

        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Task Title',        pi_old=>pi_sol_rec_old.task_title,                          pi_new=>pi_sol_rec_new.task_title,                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Assigned To',            pi_old=>getval('NAME',pi_sol_rec_old.solvedby_id),          pi_new=>getval('NAME',pi_sol_rec_new.solvedby_id),         pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Description',       pi_old=>l_description_old,                                  pi_new=>l_description_new,                                 pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Effort(Person Hours)',       pi_old=>pi_sol_rec_old.SOLVE_HOURS,                      pi_new=>pi_sol_rec_new.SOLVE_HOURS,                     pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Subsystem',         pi_old=>getval('SUBSYSTEM',pi_sol_rec_old.subsystem_id),    pi_new=>getval('SUBSYSTEM',pi_sol_rec_new.subsystem_id),                       pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Shop',              pi_old=>getval('SHOP',pi_sol_rec_old.shop_main_id),         pi_new=>getval('SHOP',pi_sol_rec_new.shop_main_id),                              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Task Priority',        pi_old=>pi_sol_rec_old.TASK_PRIORITY_CHK,                   pi_new=>pi_sol_rec_new.TASK_PRIORITY_CHK,                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Task Skill Set',        pi_old=>pi_sol_rec_old.TASK_SKILL,                   pi_new=>pi_sol_rec_new.TASK_SKILL,                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Task Start Date',   pi_old=>pi_sol_rec_old.task_start_date,                     pi_new=>pi_sol_rec_new.task_start_date,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Task End Date',     pi_old=>pi_sol_rec_old.task_end_date,                       pi_new=>pi_sol_rec_new.task_end_date,              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Percent Complete',     pi_old=>pi_sol_rec_old.TASK_PERCENT_COMPLETE,                       pi_new=>pi_sol_rec_new.TASK_PERCENT_COMPLETE,              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Complete',          pi_old=>getval('YESNO',nvl(pi_sol_rec_old.review_to_close_chk,'N')), pi_new=>getval('YESNO',nvl(pi_sol_rec_new.review_to_close_chk,'N')), pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Created By',      pi_old=>pi_sol_rec_old.created_by,                     pi_new=>pi_sol_rec_new.created_by,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Created Date',      pi_old=>pi_sol_rec_old.created_date,                     pi_new=>pi_sol_rec_new.created_date,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Modified By',      pi_old=>pi_sol_rec_old.modified_by,                     pi_new=>pi_sol_rec_new.modified_by,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Modified Date',      pi_old=>pi_sol_rec_old.modified_date,                     pi_new=>pi_sol_rec_new.modified_date,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    else
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Description',       pi_old=>l_description_old,                                  pi_new=>l_description_new,                                  pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Solver',            pi_old=>pi_sol_rec_old.old_solverby_id,                     pi_new=>pi_sol_rec_new.old_solverby_id,                         pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Solve Hours',       pi_old=>pi_sol_rec_old.solution_count,                      pi_new=>pi_sol_rec_new.solution_count,                      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Solution Type',     pi_old=>getval('SOL_TYPE',pi_sol_rec_old.sol_type_id),      pi_new=>getval('SOL_TYPE',pi_sol_rec_new.sol_type_id),      pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Module',            pi_old=>pi_sol_rec_old.module,                              pi_new=>pi_sol_rec_new.module,                              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Old Serial Number', pi_old=>pi_sol_rec_old.old_serial_number,                   pi_new=>pi_sol_rec_new.old_serial_number,                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'New Serial Number', pi_old=>pi_sol_rec_old.new_serial_number,                   pi_new=>pi_sol_rec_new.new_serial_number,                   pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Drawing',           pi_old=>pi_sol_rec_old.draw_id,                             pi_new=>pi_sol_rec_new.draw_id,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Doc',               pi_old=>pi_sol_rec_old.documentation_solution,              pi_new=>pi_sol_rec_new.documentation_solution,              pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Complete',          pi_old=>getval('YESNO',nvl(pi_sol_rec_old.review_to_close_chk,'N')), pi_new=>getval('YESNO',nvl(pi_sol_rec_new.review_to_close_chk,'N')), pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Created By',      pi_old=>pi_sol_rec_old.created_by,                     pi_new=>pi_sol_rec_new.created_by,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Created Date',      pi_old=>pi_sol_rec_old.created_date,                     pi_new=>pi_sol_rec_new.created_date,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Modified By',      pi_old=>pi_sol_rec_old.modified_by,                     pi_new=>pi_sol_rec_new.modified_by,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
        message_body_line(pi_prob_id=>pi_sol_rec_new.prob_id,pi_sol_id=>pi_sol_rec_new.sol_id,pi_prob_type_chk=>pi_prob_type_chk,pi_label=>'Modified Date',      pi_old=>pi_sol_rec_old.modified_date,                     pi_new=>pi_sol_rec_new.modified_date,                             pi_message_type=>pi_message_type,pi_apex_url_prefix=>pi_apex_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);
    end if;

    po_html_message_body := l_html_message_body;
    po_text_message_body := l_text_message_body;

end cater_solution_message_body;

procedure email_problem_by_replyall
(pi_prob_id       in number
,pi_parent_email_id	in number
,pi_from          in varchar2 := c_from_email
,pi_to            in varchar2
,pi_cc            in varchar2
,pi_subject       in varchar2
,pi_comment       in varchar2
,pi_body	  in clob
) is
    c_proc            constant varchar2(100)   := 'CATER_MESSAGE_NEW.email_problem_by_replyall ';
    l_url_prefix                 varchar2(100);
    l_instance                   varchar2(100);
    l_email_id			NUMBER;
    l_reply_link                 varchar2(1000);
    l_reply_url                 varchar2(1000);
    l_html_comment           varchar2(4000);
    l_email_comment           varchar2(4000) := NULL;
    l_older_comments           varchar2(4000);
-- Poonam 3/24/2021 - Increased the length of l_html_older_comment from 4K to 6K due to errors.
-- Might change the query overall later
    l_html_older_comment           varchar2(6000);
    l_edit_url              varchar2(1000);
    l_read_only_url              varchar2(1000);
    l_html_message_body            clob ;
    l_text_message_body            clob ;
    l_line_number                  pls_integer := 0;
    l_edit_link                 varchar2(1000);
    l_read_only_link            varchar2(1000);
    l_new_value_out             varchar2(1000) ;
    l_to		varchar2(1024); -- APPS_UTIL.QM_EMAILS
-- Poonam May 2019 - Added to truncate the '@slac.stanford.edu' part of the email
--   when inserting into the table ART_JUNC_CATER_EMAILS.CREATED_BY
    l_created_by		varchar2(30);

begin

    l_to := translate(pi_to,':',';');
    l_to := trim(';' FROM l_to);

-- Think about this ******************************************************************
    cater_ui.get_apex_url_prefix(po_apex_url_prefix => l_url_prefix, po_instance => l_instance);

    message_body_line(pi_prob_id=>pi_prob_id,pi_label=>'CATER Id',pi_old=>NULL,pi_new=>pi_prob_id,pi_message_type=>'R',pi_apex_url_prefix=>l_url_prefix,pio_html_body=>l_html_message_body,pio_text_body=>l_text_message_body,pio_line_number=>l_line_number);

    l_html_message_body     := l_html_message_body || '</table>' || c_plain_break;
    l_html_message_body := l_html_message_body || '</body></html>' || c_plain_break;

-- Insert into QM_EMAILS table with IS_ACTIVE='N', so that the email is not yet sent out. 
-- Just stored in the database.
IF pi_comment is NOT NULL THEN
  l_email_comment := sysdate||'     ['|| pi_from||']'||c_plain_break|| pi_comment;
END IF;
--    l_html_comment := '<p><pre>' || pi_comment || '</pre></p><br>' || c_plain_break;

-- For the moment, removing the From and date for most recent comment.
    l_html_comment := '<p><pre>' || l_email_comment || '</pre></p><br>' || c_plain_break;

-- Don't want to save the comment with the email body.
-- Sending only the Cater link in the body
    qm_email_pkg.send_email
    (p_app_name   => c_app_name
    ,p_page_name  => '400'
    ,p_email_from => pi_from
    ,p_email_to   => l_to
    ,p_email_cc   => pi_cc
    ,p_email_bcc  => null
    ,p_subject    => pi_subject
    ,p_body       => l_html_message_body
    ,p_is_html    => 'Y'
    ,p_is_active  => 'N'
    ,p_email_id   => l_email_id
    );

BEGIN

	select listagg(created_date||'    ['||created_by||']'||chr(10)|| email_comment,chr(13)||chr(10)||chr(13)||chr(10))
	WITHIN GROUP
	(order by email_id desc) older_comments
	into l_older_comments
	from art_junc_cater_emails
	where parent_email_id = pi_parent_email_id
	and email_comment IS NOT NULL
	group by parent_email_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN 
     l_older_comments := '';
    WHEN OTHERS THEN NULL;
END;
--
    l_html_older_comment := '<p><pre>' || l_older_comments || '</pre></p><br>' || c_plain_break;
--
-- Poonam May 2019 - Added to truncate the '@slac.stanford.edu' part of the email
--   when inserting into the table ART_JUNC_CATER_EMAILS.CREATED_BY. 
 l_created_by := UPPER(substr(pi_from,1, instr(pi_from,'@')-1));
--
insert into ART_JUNC_CATER_EMAILS (prob_id, email_id, parent_email_id, email_comment, created_by, created_date)
values (pi_prob_id, l_email_id, pi_parent_email_id, pi_comment, l_created_by, sysdate);

commit;

-- Poonam 9/6/2017 - The Reply-All link now going through the common page as any other CATER Links.
IF l_email_id is not null THEN
-- Get INSTANCE from the Database and the APEX URL too.
cater_ui.get_apex_url_prefix(po_apex_url_prefix => l_url_prefix, po_instance => l_instance);

l_reply_url       := cater_ui.get_replyall_url(p_apex_url_prefix=>l_url_prefix, p_start_page=>c_start_page, p_email_id=>l_email_id, p_prob_id=>pi_prob_id, p_parent_email_id=>pi_parent_email_id) || c_plain_break;

--  l_reply_url := l_url_prefix || 'f?p=194:400:::NO:400:' || 'P400_EMAIL_ID,P400_PROB_ID,P400_PARENT_EMAIL_ID:' || l_email_id || ',' || pi_prob_id ||','|| pi_parent_email_id;
  l_reply_link      := cater_ui.get_link(l_reply_url,'Reply-All');


-- New comment should be now part of the older comment anyways.
        qm_email_pkg.connect_smtp
        (l_email_id
        ,qm_email_pkg.fix_email_addresses(pi_from)
        ,qm_email_pkg.fix_email_addresses(l_to)
        ,qm_email_pkg.fix_email_addresses(pi_cc)
        ,NULL
        ,pi_subject
        ,l_reply_link||c_html_break||c_html_break||l_html_comment||l_html_older_comment||l_html_message_body
        ,'Y'
        );
end if;

end email_problem_by_replyall;

end CATER_MESSAGE_NEW;



/
