--------------------------------------------------------
--  File created - Monday-January-10-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body CATER_UI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MCC_MAINT"."CATER_UI" as

-- Poonam 9/6/2017 - New function "get_replyall_url" for Reply-All url to work across all platforms.
-- Poonam 4/21/2017 - Added sched_start_time in the Order By in pdf_access_schedule
-- Poonam Mar 2017 - New code for emails being sent by Scheduler job and not triggers anymore.
--         Includes new function "called_from_web".
-- Poonam Nov 2016 - Fixes for ORDS Platform.
--        Adding .pdf as IE does not add pdf extension, but other browsers do and fixing Chrome issues too.
-- Poonam Sep 2016 - Changes for Webauth
-- Poonam Jan 2016 - Date format in the View Access Schedule PDF. 13:07 showed as 13:7.

function get_prob_edit_url
(p_apex_url_prefix varchar2
,p_start_page      number
,p_prob_id         number
,p_return_page     number
) return varchar2 is
    l_editurl varchar2(1000);
begin
-- Poonam - 9/21/16 - for Webauth
    l_editurl := p_apex_url_prefix || 'f?p=194:104:::NO:' || p_start_page || ':P104_FIRST_PAGE,P104_PROB_ID,P104_RP:' || p_start_page || ',' || p_prob_id || ',' || p_return_page;
--    l_editurl := p_apex_url_prefix || 'f?p=194:101:::NO:' || p_start_page || ':P101_FIRST_PAGE,P101_PROB_ID,P101_RP:' || p_start_page || ',' || p_prob_id || ',' || p_return_page;
    return l_editurl;
end get_prob_edit_url;


function get_prob_read_only_url
(p_apex_url_prefix varchar2
,p_start_page      number
,p_prob_id         number
,p_return_page     number
) return varchar2 is
    l_read_only_url varchar2(1000);
begin
    l_read_only_url := p_apex_url_prefix || 'f?p=249:104:::NO:' || p_start_page || ':P104_PROB_ID,P104_RP:' || p_prob_id || ',' || p_return_page;
    return l_read_only_url;
end get_prob_read_only_url;

function get_replyall_url
(p_apex_url_prefix varchar2
,p_start_page      number
,p_email_id         number
,p_prob_id         number
,p_parent_email_id         number
) return varchar2 is
    l_editurl varchar2(1000);
begin
-- Poonam - 9/21/16 - for Webauth
    l_editurl := p_apex_url_prefix || 'f?p=194:104:::NO:' || p_start_page || ':P104_FIRST_PAGE,P104_EMAIL_ID,P104_PROB_ID,P104_PARENT_EMAIL_ID:' || p_start_page || ',' || p_email_id ||','|| p_prob_id || ',' || p_parent_email_id;
    return l_editurl;
end get_replyall_url;

function get_job_edit_url
(p_apex_url_prefix varchar2
,p_start_page      number
,p_prob_id         number
,p_job_id          number
,p_job_type_chk    varchar2
,p_return_page     number
) return varchar2 is
    l_edit_url varchar2(1000);
begin
-- Poonam - 9/21/16 - for Webauth
    l_edit_url := p_apex_url_prefix || 'f?p=194:104:::NO:' || p_start_page || ':P104_FIRST_PAGE,P104_PROB_ID,P104_JOB_ID,P104_JOB_TYPE_CHK:' || p_start_page || ',' || p_prob_id || ',' || p_job_id || ',' || p_job_type_chk || ',' || p_return_page;
--    l_edit_url := p_apex_url_prefix || 'f?p=194:101:::NO:' || p_start_page || ':P101_FIRST_PAGE,P101_PROB_ID,P101_JOB_ID,P101_JOB_TYPE_CHK:' || p_start_page || ',' || p_prob_id || ',' || p_job_id || ',' || p_job_type_chk || ',' || p_return_page;
    return l_edit_url;
end get_job_edit_url;


function get_job_read_only_url
(p_apex_url_prefix varchar2
,p_start_page      number
,p_prob_id         number
,p_job_id          number
,p_job_type_chk    varchar2
,p_return_page     number
) return varchar2 is
    l_read_only_url varchar2(1000);
begin
    l_read_only_url := p_apex_url_prefix || 'f?p=249:104:::NO:' || p_start_page || ':P104_PROB_ID,P104_JOB_ID,P104_JOB_TYPE_CHK,P104_RP:' || p_prob_id || ',' || p_job_id || ',' || p_job_type_chk || ',' || p_return_page;
    return l_read_only_url;
end get_job_read_only_url;


function get_sol_edit_url
(p_apex_url_prefix varchar2
,p_start_page      number
,p_prob_id         number
,p_sol_id          number
,p_prob_type_chk   varchar2
,p_return_page     number
) return varchar2 is
    l_edit_url varchar2(1000);
begin
-- Poonam - 9/21/16 - for Webauth
    l_edit_url := p_apex_url_prefix || 'f?p=194:104:::NO:' || p_start_page || ':P104_FIRST_PAGE,P104_PROB_ID,P104_SOL_ID,P104_PROB_TYPE_CHK,P104_RP:' || p_start_page || ',' || p_prob_id || ',' || p_sol_id || ',' || p_prob_type_chk || ',' || p_return_page;
--    l_edit_url := p_apex_url_prefix || 'f?p=194:101:::NO:' || p_start_page || ':P101_FIRST_PAGE,P101_PROB_ID,P101_SOL_ID,P101_PROB_TYPE_CHK,P101_RP:' || p_start_page || ',' || p_prob_id || ',' || p_sol_id || ',' || p_prob_type_chk || ',' || p_return_page;
    return l_edit_url;
end get_sol_edit_url;


function get_sol_read_only_url
(p_apex_url_prefix varchar2
,p_start_page      number
,p_prob_id         number
,p_sol_id          number
,p_prob_type_chk   varchar2
,p_return_page     number
) return varchar2 is
    l_read_only_url varchar2(1000);
begin
    l_read_only_url := p_apex_url_prefix || 'f?p=249:104:::NO:' || p_start_page || ':P104_PROB_ID,P104_SOL_ID,P104_PROB_TYPE_CHK,P104_RP:' || p_prob_id || ',' || p_sol_id || ',' || p_prob_type_chk || ',' || p_return_page;
    return l_read_only_url;
end get_sol_read_only_url;


function get_rsw_edit_url
(p_apex_url_prefix varchar2
,p_form_id         number
) return varchar2 is
    l_edit_url varchar2(1000);
begin
    l_edit_url := p_apex_url_prefix || 'f?p=252:2:::NO:2:P2_FORM_ID:' || p_form_id;
    return l_edit_url;
end get_rsw_edit_url;

function get_rsw_read_only_url
(p_apex_url_prefix varchar2
,p_form_id         number
) return varchar2 is
    l_read_only_url varchar2(1000);
begin
    l_read_only_url := p_apex_url_prefix || 'f?p=251:2:::NO:P2_FORM_ID:' || p_form_id;
    return l_read_only_url;
end get_rsw_read_only_url;

-- Poonam - 3/15/2017 - New function for cater emails happening from Scheduler job
FUNCTION called_from_web
 RETURN BOOLEAN IS
  lv   VARCHAR2 (100);
BEGIN
  lv := owa_util.get_cgi_env ('server_name');
  RETURN TRUE;
EXCEPTION
  WHEN VALUE_ERROR THEN
  RETURN FALSE;
END called_from_web;

procedure get_apex_url_prefix
(po_apex_url_prefix out varchar2
,po_instance        out varchar2
) is
    l_http_host   varchar2(100);
    l_url_prefix  varchar2(100);
    l_script_name varchar2(100);
    l_instance    varchar2(100);
    c_proc              constant varchar2(100) := 'CATER_UI.GET_APEX_URL_PREFIX ';

begin
  l_instance := sys_context('USERENV','INSTANCE_NAME');
-- Poonam 3/15/2017 - When emails are sent from Scheduler job and NOT trigger anymore.
  IF called_from_web THEN

    l_http_host   := owa_util.get_cgi_env('HTTP_HOST');
    l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');

    l_url_prefix  := 'https://' || l_http_host || l_script_name || '/';

    po_apex_url_prefix := l_url_prefix;
-- Poonam - changed it to lower(instance), as earlier it was hardcoded lower.
    po_instance        := lower(l_instance);
  ELSE
    po_instance        := lower(l_instance);
    po_apex_url_prefix := 'https://oraweb.slac.stanford.edu/apex/'||po_instance||'/';
-- Poonam - changed it to lower(instance), as earlier it was hardcoded lower.
  END IF;

end get_apex_url_prefix;


function get_link
(p_url   varchar2
,p_label varchar2
) return varchar2
is
    l_link varchar2(1000);
begin
    l_link := '<a href="' || p_url || '" target="_blank">' || p_label || '</a>';
    return l_link;
end get_link;


function plpdf_session_id_valid(p_session_id varchar2) return boolean is
begin
    return true;
end plpdf_session_id_valid;


/*
procedure store_document
(pi_blob in blob
) is
begin
    insert into utl_store_blob (blob_file, created_date)
    values (pi_blob, sysdate);
end store_document;
*/

procedure set_text_color_for_status
(pi_status varchar2
) is
begin
    case pi_status
    when 'Closed'      then apps_util.utl_plpdf.dark_green_text;
    when 'RevToClose'  then apps_util.utl_plpdf.dark_grey_text;
    when 'New'         then apps_util.utl_plpdf.dark_grey_text;
    when 'Scheduled'   then apps_util.utl_plpdf.dark_grey_text;
    when 'In Progress' then apps_util.utl_plpdf.dark_grey_text;
    else                    apps_util.utl_plpdf.dark_grey_text;
    end case;
end set_text_color_for_status;


procedure set_text_color_for_subsystem
(pi_subsystem varchar2
) is
begin
    case pi_subsystem
    when 'PPS'    then apps_util.utl_plpdf.orange_text;
    when 'BCS'    then apps_util.utl_plpdf.orange_text;
    when 'Safety' then apps_util.utl_plpdf.orange_text;
    else               null;
    end case;
end set_text_color_for_subsystem;


--procedure page_heading2 is
--    l_row_height  constant number := 10;
--begin
--    plpdf.newpage;
--    apps_util.utl_plpdf.set_print_font_heading;
--    apps_util.utl_plpdf.dark_grey_text;
--    apps_util.utl_plpdf.light_blue_fill;

    /* Print headers */

    /* Draws a rectangle cell with text inside. */
--    plpdf.printcell
--    (p_w      => 300    -- Rectangle width
--    ,p_h      => l_row_height   -- Rectangle heigth
--    ,p_txt    => to_char(sysdate, 'fmddth')||' of '||to_char (sysdate, 'fmMonth')||', '||to_char(sysdate, 'YYYY')||':  CATER Problems Since Last Meeting                                                                                     Page '||plpdf.CurrentPagenumber -- Text in rectangle
--    ,p_border => '0'            -- With frame
--    ,p_ln     => '1'            -- Cursor position after the cell is printed
--    ,p_align  => 'L'            -- Text alignment: Center
--    ,p_fill   => 0              -- Fill with current fill color
--    );
--end page_heading2;


procedure page_heading
(l_widths      plpdf_type.t_row_widths
) is
    l_row_height  constant number := 10;
begin

    plpdf.newpage;
    apps_util.utl_plpdf.set_print_font_heading;
    apps_util.utl_plpdf.dark_grey_text;
    apps_util.utl_plpdf.light_blue_fill;

    /* Print headers */

    /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => 300    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => to_char(sysdate,'Day Mon DD, YYYY')||':  CATER Problems Since Last Meeting                                                                            Page '||plpdf.CurrentPagenumber -- Text in rectangle
    ,p_border => '0'            -- With frame
    ,p_ln     => '1'            -- Cursor position after the cell is printed
    ,p_align  => 'L'            -- Text alignment: Center
    ,p_fill   => 0              -- Fill with current fill color
    );

    /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => l_widths(1)    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'ID'           -- Text in rectangle
    ,p_border => '1'            -- With frame
    ,p_ln     => '0'            -- Cursor position after the cell is printed
    ,p_align  => 'L'            -- Text alignment: Center
    ,p_fill   => 1              -- Fill with current fill color
    );

    /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => l_widths(2)    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'Area'         -- Text in rectangle
    ,p_border => '1'            -- With frame
    ,p_ln     => '0'            -- Cursor position after the cell is printed
    ,p_align  => 'L'            -- Text alignment: Center
    ,p_fill   => 1              -- Fill with current fill color
    );

    /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => l_widths(3)    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'Subsystem'    -- Text in rectangle
    ,p_border => '1'            -- With frame
    ,p_ln     => '0'            -- Cursor position after the cell is printed
    ,p_align  => 'L'            -- Text alignment: Center
    ,p_fill   => 1              -- Fill with current fill color
    );

    /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => l_widths(4)    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'Shop'         -- Text in rectangle
    ,p_border => '1'            -- With frame
    ,p_ln     => '0'            -- Cursor position after the cell is printed
    ,p_align  => 'L'            -- Text alignment: Center
    ,p_fill   => 1              -- Fill with current fill color
    );

    /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => l_widths(5)    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'Status'       -- Text in rectangle
    ,p_border => '1'            -- With frame
    ,p_ln     => '0'            -- Cursor position after the cell is printed
    ,p_align  => 'L'            -- Text alignment: Center
    ,p_fill   => 1              -- Fill with current fill color
    );

    /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => l_widths(6)    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'Description'  -- Text in rectangle
    ,p_border => '1'            -- With frame
    ,p_ln     => '1'            -- Cursor position after the cell is printed
    ,p_align  => 'L'            -- Text alignment: Center
    ,p_fill   => 1              -- Fill with current fill color
    );

    apps_util.utl_plpdf.set_print_font_body;
    apps_util.utl_plpdf.white_fill;

end page_heading;

procedure access_schedule_pdf_heading
(l_widths    in  plpdf_type.t_row_widths
,repair_id  in  number
,po_filename out varchar2
) is
    l_row_height  constant number := 10;
    start_date date;
    end_date date;
    rep_program art_programs.program%TYPE;
    maint_type art_maint_access_types.description%TYPE;
    maint_name art_maint_access_types.name%TYPE;
    last_acc_mod_date date;
    last_not_mod_date date;
--    last_mod_date date;

-- Poonam Jan 2016 - made it varchar to format the date field properly.
    last_mod_date VARCHAR2(20);

    l_filename VARCHAR2(100);
begin

    plpdf.newpage;
    apps_util.utl_plpdf.set_print_font_heading;
    apps_util.utl_plpdf.dark_grey_text;
--    apps_util.utl_plpdf.light_blue_fill;

    select sched_start_date, sched_end_date
           ,p.program
           ,mat.description, mat.name
    into start_date, end_date
         ,rep_program
         ,maint_type, maint_name
    from art_sched_repairs sr
         ,art_programs p
         ,art_maint_access_types mat
    where sr.sched_repair_id = repair_id
    and sr.maint_access_type_id = mat.maint_access_type_id
    and sr.prog_id = p.prog_id;

-- Poonam 11/9/2016 - Adding .pdf as IE does not add pdf extension, but other browsers do
-- Also, Google Chrome creates a weird name combo for the dates on the ORDS platform, but this fixes it.
po_filename := trim(substr(rep_program,1,30))||'_'||trim(substr(maint_name,1,20))||'_'||to_char(start_date,'mm/dd/yyyy')||'.pdf';

    select max(jn_datetime)
    into last_acc_mod_date
    from art_access_schedule_jn
    where sched_repair_id = repair_id;

    select max(jn_datetime)
    into last_not_mod_date
    from art_notes_jn
    where sched_repair_id = repair_id;

-- Poonam Jan 2016 - to get the right format: 13:07 displayed as 13:7.
--         Leading 0 was getting truncated.

    select to_char(greatest(nvl(last_not_mod_date, to_date('07-04-1776','MM-DD-YYYY')),
                    nvl(last_acc_mod_date,to_date('07-04-1776','MM-DD-YYYY'))),'FMDy Mon ddth') ||', '||
           to_char(greatest(nvl(last_not_mod_date, to_date('07-04-1776','MM-DD-YYYY')),
                    nvl(last_acc_mod_date,to_date('07-04-1776','MM-DD-YYYY'))),'FXHH24:MI')
    into last_mod_date
    from dual;
-- Poonam - just changed from Times to Arial.
    plpdf.setprintfont
    (p_family => 'Arial'        -- Font family: Arial
    ,p_style  => 'BU'            -- Font style: Bold
    ,p_size   => 22             -- Font size: 12 pt
    );

     apps_util.utl_plpdf.dark_grey_text;

    /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => 250    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => rep_program||' '||maint_type
    ,p_border => '0'            -- With frame
    ,p_ln     => '1'            -- Cursor position after the cell is printed
    ,p_align  => 'C'            -- Text alignment: Center
    ,p_fill   => 0              -- Fill with current fill color
    );

    plpdf.linebreak(5);
     plpdf.setcolor4text(1,1,255);  -- Blue Color

    plpdf.setprintfont
    (p_family => 'Arial'        -- Font family: Arial
    ,p_style  => 'BI'            -- Font style: Bold
    ,p_size   => 20             -- Font size: 12 pt
    );

    plpdf.printcell
    (p_w      => 120    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => to_char(start_date,'FMDy Mon ddth, YYYY')
    ,p_border => '0'            -- With frame
    ,p_ln     => '0'            -- Cursor position after the cell is printed
    ,p_align  => 'L'            -- Text alignment: Center
    ,p_fill   => 0              -- Fill with current fill color
    );

     plpdf.setcolor4text(1,1,255);  -- Blue Color

    /* Sets the font and its properties */
     plpdf.SetPrintFont(
          p_family => 'Arial', -- Font family: Arial
          p_style  => 'I', -- Font style: Italic
          p_size   => 12 -- Font size: 8 pt
     );

-- Poonam Jan 2016 - pre-formatted date field used now.

    plpdf.printcell
    (p_w      => 120    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'Last Updated: '||last_mod_date
--    ,p_txt    => 'Last Updated: '||to_char(last_mod_date,'FMDy Mon ddth, HH24:MI')
    ,p_border => '0'            -- With frame
    ,p_ln     => '1'            -- Cursor position after the cell is printed
    ,p_align  => 'R'            -- Text alignment: Center
    ,p_fill   => 0              -- Fill with current fill color
    );

end access_schedule_pdf_heading;

procedure access_schedule_heading
(l_widths      plpdf_type.t_row_widths
) is
    l_row_height  constant number := 10;

begin
    plpdf.newpage;
    apps_util.utl_plpdf.white_fill;

     plpdf.SetPrintFont(
          p_family => 'Arial', -- Font family: Arial
          p_style  => 'B', -- Font style: Italic
          p_size   => 15 -- Font size: 8 pt
     );
    plpdf.setcolor4text(1,1,255);  -- Blue Color
    /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => 40  -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'PPS Zone'     -- Text in rectangle
    ,p_border => '1'            -- With frame
    ,p_ln     => '0'            -- Cursor position after the cell is printed
    ,p_align  => 'L'            -- Text alignment: Center
    ,p_fill   => 1              -- Fill with current fill color
    );

    /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => 38    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'RPFO Survey'  -- Text in rectangle
    ,p_border => '1'            -- With frame
    ,p_ln     => '0'            -- Cursor position after the cell is printed
    ,p_align  => 'C'            -- Text alignment: Center
    ,p_fill   => 1              -- Fill with current fill color
    );


    /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => 52    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'Access State'         -- Text in rectangle
    ,p_border => '1'            -- With frame
    ,p_ln     => '0'            -- Cursor position after the cell is printed
    ,p_align  => 'C'            -- Text alignment: Center
    ,p_fill   => 1              -- Fill with current fill color
    );

    /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => 38    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'Access Start'       -- Text in rectangle
    ,p_border => '1'            -- With frame
    ,p_ln     => '0'            -- Cursor position after the cell is printed
    ,p_align  => 'C'            -- Text alignment: Center
    ,p_fill   => 1              -- Fill with current fill color
    );

    /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => 38    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'Search Time'  -- Text in rectangle
    ,p_border => '1'            -- With frame
    ,p_ln     => '0'            -- Cursor position after the cell is printed
    ,p_align  => 'C'            -- Text alignment: Center
    ,p_fill   => 1              -- Fill with current fill color
    );

     /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => 38    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'No Access'  -- Text in rectangle
    ,p_border => '1'            -- With frame
    ,p_ln     => '1'            -- Cursor position after the cell is printed
    ,p_align  => 'C'            -- Text alignment: Center
    ,p_fill   => 1              -- Fill with current fill color
    );

    apps_util.utl_plpdf.dark_grey_text;
--    apps_util.utl_plpdf.set_print_font_body;
    apps_util.utl_plpdf.white_fill;

end access_schedule_heading;

procedure access_schedule_notes
(l_widths      plpdf_type.t_row_widths
 ,repair_id number
 ,l_print_day number
) is
    l_row_height  constant number := 10;
    l_count number(2) := 0;
    l_note_time varchar2(15);

    cursor note_cur is
        select n.note_desc CatNote
	      ,n.note_time
--               ,to_char(n.note_time,'HH24:MI') NoteTime
        from art_notes n
        where n.sched_repair_id = repair_id
        and note_type_id = 1
        order by n.note_time nulls first, n.note_id;

begin

    plpdf.setprintfont
    (p_family => 'Arial'        -- Font family: Arial
    ,p_style  => 'BI'            -- Font style: Bold
    ,p_size   => 14             -- Font size: 12 pt
    );

    plpdf.setcolor4text(255,1,1); -- Red color

    /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => 250    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'Work is not released until all release conditions are satisfied'
    ,p_border => '0'            -- With frame
    ,p_ln     => '1'            -- Cursor position after the cell is printed
    ,p_align  => 'L'            -- Text alignment: Center
    ,p_fill   => 0              -- Fill with current fill color
    );

    apps_util.utl_plpdf.set_print_font_heading;
    apps_util.utl_plpdf.dark_grey_text;

    for note_rec in note_cur
    loop
    l_count := l_count+1;
-- Poonam - 5/3/2016 - Show day+time when PMM > 1 day
     IF l_print_day = 1 THEN
       l_note_time := to_char(note_rec.note_time,'Dy HH24:MI');
     ELSE
       l_note_time := to_char(note_rec.note_time,'HH24:MI');
     END IF;

	  /* Draws a rectangle cell with text inside. */
        plpdf.printcell
        (p_w      => 10    -- Rectangle width
        ,p_h      => l_row_height   -- Rectangle heigth
        ,p_txt    => l_count||') '
        ,p_border => '0'            -- With frame
        ,p_ln     => '0'            -- Cursor position after the cell is printed
        ,p_align  => 'R'            -- Text alignment: Center
        ,p_fill   => 0              -- Fill with current fill color
        );

        plpdf.printcell
        (p_w      => 30    -- Rectangle width
        ,p_h      => l_row_height   -- Rectangle heigth
        ,p_txt    => l_note_time
--        ,p_txt    => note_rec.noteTime
        ,p_border => '0'            -- With frame
        ,p_ln     => '0'            -- Cursor position after the cell is printed
        ,p_align  => 'L'            -- Text alignment: Center
        ,p_fill   => 0              -- Fill with current fill color
        );

        plpdf.PrintMultiLineCell
        (p_w      => 0    -- Rectangle width
        ,p_h      => l_row_height   -- Rectangle heigth
        ,p_txt    => note_rec.catNote
        ,p_border => '0'            -- With frame
        ,p_ln     => '1'            -- Cursor position after the cell is printed
        ,p_align  => 'L'            -- Text alignment: Center
        ,p_fill   => 0              -- Fill with current fill color
	,p_maxline => 0
	,p_clipping => 0
        );

    end loop;

    apps_util.utl_plpdf.white_fill;

end access_schedule_notes;

procedure access_schedule_recovery_notes
(l_widths      plpdf_type.t_row_widths
 ,repair_id number
 ,l_print_day number
) is
    l_row_height  constant number := 10;
    l_line_count number := 0;
    l_note_time varchar2(15);

    cursor note_cur is
        select n.note_desc CatNote
	      ,n.note_time
--               ,to_char(n.note_time,'HH24:MI') NoteTime
               ,s.shop NoteShop
        from art_notes n
             ,art_shops s
        where n.sched_repair_id = repair_id
        and note_type_id = 2
        and s.shop_id = n.shop_id (+)
        order by n.note_time nulls first, s.shop, n.note_id;

begin

    plpdf.newpage;

    plpdf.setprintfont
    (p_family => 'Arial'        -- Font family: Arial
    ,p_style  => 'BI'            -- Font style: Bold
    ,p_size   => 16             -- Font size: 12 pt
    );

    apps_util.utl_plpdf.dark_grey_text;

    /* Draws a rectangle cell with text inside. */
    plpdf.printcell
    (p_w      => 250    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'RECOVERY NOTES'
    ,p_border => '0'            -- With frame
    ,p_ln     => '1'            -- Cursor position after the cell is printed
    ,p_align  => 'L'            -- Text alignment: Center
    ,p_fill   => 0              -- Fill with current fill color
    );

    plpdf.setcolor4text(1,1,255);  -- Blue Color
     plpdf.SetPrintFont(
          p_family => 'Arial', -- Font family: Arial
          p_style  => 'B', -- Font style: Italic
          p_size   => 15 -- Font size: 8 pt
     );
    --
    plpdf.printcell
    (p_w      => 25    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'SHOP'
    ,p_border => '0'            -- With frame
    ,p_ln     => '0'            -- Cursor position after the cell is printed
    ,p_align  => 'L'            -- Text alignment: Center
    ,p_fill   => 0              -- Fill with current fill color
    );
    plpdf.printcell
    (p_w      => 30    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'TIME '
    ,p_border => '0'            -- With frame
    ,p_ln     => '0'            -- Cursor position after the cell is printed
    ,p_align  => 'L'            -- Text alignment: Center
    ,p_fill   => 0              -- Fill with current fill color
    );
    plpdf.printcell
    (p_w      => 220    -- Rectangle width
    ,p_h      => l_row_height   -- Rectangle heigth
    ,p_txt    => 'TASK'
    ,p_border => '0'            -- With frame
    ,p_ln     => '1'            -- Cursor position after the cell is printed
    ,p_align  => 'L'            -- Text alignment: Center
    ,p_fill   => 0              -- Fill with current fill color
    );
    apps_util.utl_plpdf.set_print_font_heading;
    apps_util.utl_plpdf.dark_grey_text;

    Plpdf.DrawLine(1,Plpdf.GetCurrentY,350,Plpdf.GetCurrentY);
    plpdf.linebreak(5);

    for note_rec in note_cur
    loop
      l_line_count := l_line_count + 1;
      --
-- Poonam - 5/3/2016 - Show day+time when PMM > 1 day
     IF l_print_day = 1 THEN
       l_note_time := to_char(note_rec.note_time,'Dy HH24:MI');
     ELSE
       l_note_time := to_char(note_rec.note_time,'HH24:MI');
     END IF;
     --
      if mod(l_line_count,2) = 1 then
        apps_util.utl_plpdf.light_blue_fill;
      else
        apps_util.utl_plpdf.white_fill;
      end if;

        plpdf.printcell
        (p_w      => 25    -- Rectangle width
        ,p_h      => l_row_height   -- Rectangle heigth
        ,p_txt    => note_rec.noteShop
        ,p_border => '0'            -- With frame
        ,p_ln     => '0'            -- Cursor position after the cell is printed
        ,p_align  => 'L'            -- Text alignment: Center
        ,p_fill   => 1              -- Fill with current fill color
        );

          /* Draws a rectangle cell with text inside. */
        plpdf.printcell
        (p_w      => 30    -- Rectangle width
        ,p_h      => l_row_height   -- Rectangle heigth
        ,p_txt    => l_note_time
--        ,p_txt    => note_rec.noteTime
        ,p_border => '0'            -- With frame
        ,p_ln     => '0'            -- Cursor position after the cell is printed
        ,p_align  => 'L'            -- Text alignment: Center
        ,p_fill   => 1              -- Fill with current fill color
        );

        plpdf.PrintMultiLineCell
        (p_w      => 0    -- Rectangle width
        ,p_h      => l_row_height   -- Rectangle heigth
        ,p_txt    => note_rec.catNote
        ,p_border => '0'            -- With frame
        ,p_ln     => '1'            -- Cursor position after the cell is printed
        ,p_align  => 'L'            -- Text alignment: Center
        ,p_fill   => 1              -- Fill with current fill color
	,p_maxline => 0
	,p_clipping => 0
        );
    end loop;

    apps_util.utl_plpdf.white_fill;

end access_schedule_recovery_notes;


procedure problems_since_last_mtg
(pi_div_code_id number
) is

    l_blob      blob;
    l_border    char(1);                    -- Actual border
    l_fill      number;                     -- Filling
    l_datas     plpdf_type.t_row_datas;     -- Array of datas
    l_borders   plpdf_type.t_row_borders;   -- Array of borders
    l_widths    plpdf_type.t_row_widths;    -- Array of widths
    l_aligns    plpdf_type.t_row_aligns;    -- Array of aligns
    l_styles    plpdf_type.t_row_styles;    -- Array of styles
    l_maxlines  plpdf_type.t_row_maxlines;  -- Array of max lines

    l_line_count  number := 1;
    l_page_count  number := 1;
    l_page_length constant number := 16;

    l_filename varchar2(30);

    cursor cater_cur is
        select p.prob_id
              ,p.area
              ,subsystem
              ,p.shop_main
              ,p.status
              ,replace(replace(p.short_descr,'<b>',''),'</b>','') short_descr
              --,shop_main
        from art_problems_vw p
            ,art_areas       a
        where p.div_code_id = pi_div_code_id
        and   prob_id > (select last_meeting_prob_id
                         from art_division_codes
                         where div_code_id = pi_div_code_id)
                         and p.area = a.area
                         order by a.display_order;

 begin

    /* Initialize, without parameters means:
     - page orientation: portrait
     - unit: mm
     - default page format: A4 */
    plpdf.init
    (p_orientation => 'L'
    );
    /*
    plpdf.setheaderprocname
    (p_proc_name=>'page_heading3'
    ,p_height=>10
    );
    */

    /* Begin a new page, without parameters means:
     - page orientation: default (portrait) */

    /* Set columns widths */
    l_widths(1) := 18;
    l_widths(2) := 30;
    l_widths(3) := 24;
    l_widths(4) := 15;
    l_widths(5) := 15;
    l_widths(6) := 172;

    /* Set columns aligns */
    l_aligns(1) := 'L';
    l_aligns(2) := 'L';
    l_aligns(3) := 'L';
    l_aligns(4) := 'L';
    l_aligns(5) := 'L';
    l_aligns(6) := 'L';

    --plpdf.setheaderprocname('art_prbs_snc_lst_mtg_pg_hdg',10);
    page_heading(l_widths);
    --page_heading2;

    for cater_rec in cater_cur
    loop

        if l_line_count > l_page_length
        then
            --page_heading2;
            page_heading(l_widths);
            l_line_count := 1;
            l_page_count := l_page_count + 1;
        end if;

        set_text_color_for_status(cater_rec.status);

        /*
        case cater_rec.urgency
        when 'Immediate' then apps_util.utl_plpdf.light_yellow_fill;
        when 'Later'     then apps_util.utl_plpdf.light_grey_fill;
        else                  apps_util.utl_plpdf.white_fill;
        end case;
        */

        /* Draws a rectangle cell with text inside. */
        plpdf.printcell
        (p_w      => l_widths(1)            -- Rectangle width
        ,p_h      => apps_util.utl_plpdf.g_row_height -- Rectangle heigth
        ,p_txt    => cater_rec.prob_id      -- Text in rectangle
        ,p_border => '1'                    -- With frame
        ,p_ln     => '0'                    -- Cursor position after the cell is printed
        ,p_align  => 'L'                    -- Text alignment: Left
        ,p_fill   => 1                      -- Fill with current fill color
        );

        /* Draws a rectangle cell with text inside. */
        plpdf.printcell
        (p_w      => l_widths(2)            -- Rectangle width
        ,p_h      => apps_util.utl_plpdf.g_row_height -- Rectangle heigth
        ,p_txt    => cater_rec.area         -- Text in rectangle
        ,p_border => '1'                    -- With frame
        ,p_ln     => '0'                    -- Cursor position after the cell is printed
        ,p_align  => 'L'                    -- Text alignment: Left
        ,p_fill   => 1                      -- Fill with current fill color
        );

        set_text_color_for_subsystem(cater_rec.subsystem);

        /* Draws a rectangle cell with text inside. */
        plpdf.printcell
        (p_w      => l_widths(3)            -- Rectangle width
        ,p_h      => apps_util.utl_plpdf.g_row_height -- Rectangle heigth
        ,p_txt    => cater_rec.subsystem    -- Text in rectangle
        ,p_border => '1'                    -- With frame
        ,p_ln     => '0'                    -- Cursor position after the cell is printed
        ,p_align  => 'L'                    -- Text alignment: Left
        ,p_fill   => 1                      -- Fill with current fill color
        );

        set_text_color_for_status(cater_rec.status);

        /* Draws a rectangle cell with text inside. */
        plpdf.printcell
        (p_w      => l_widths(4)            -- Rectangle width
        ,p_h      => apps_util.utl_plpdf.g_row_height -- Rectangle heigth
        ,p_txt    => cater_rec.shop_main    -- Text in rectangle
        ,p_border => '1'                    -- With frame
        ,p_ln     => '0'                    -- Cursor position after the cell is printed
        ,p_align  => 'L'                    -- Text alignment: Left
        ,p_fill   => 1                      -- Fill with current fill color
        );

        /* Draws a rectangle cell with text inside. */
        plpdf.printcell
        (p_w      => l_widths(5)            -- Rectangle width
        ,p_h      => apps_util.utl_plpdf.g_row_height -- Rectangle heigth
        ,p_txt    => cater_rec.status       -- Text in rectangle
        ,p_border => '1'                    -- With frame
        ,p_ln     => '0'                    -- Cursor position after the cell is printed
        ,p_align  => 'L'                    -- Text alignment: Left
        ,p_fill   => 1                      -- Fill with current fill color
        );

        /* Draws a rectangle cell with text inside. */
        plpdf.printcell
        (p_w      => l_widths(6)            -- Rectangle width
        ,p_h      => apps_util.utl_plpdf.g_row_height -- Rectangle heigth
        ,p_txt    => cater_rec.short_descr  -- Text in rectangle
        ,p_border => '1'                    -- With frame
        ,p_ln     => '1'                    -- Cursor position after the cell is printed
        ,p_align  => 'L'                    -- Text alignment: Left
        ,p_fill   => 1                      -- Fill with current fill color
        );

        l_line_count := l_line_count + 1;

    end loop;

    apps_util.utl_plpdf.line_break;
    apps_util.utl_plpdf.print_document(l_blob);
    --store_document(l_blob);

    commit;

end problems_since_last_mtg;

procedure pdf_access_schedule
(pi_repair_id number
) is

    l_blob      blob;
    l_border    char(1);                    -- Actual border
    l_fill      number;                     -- Filling
    l_datas     plpdf_type.t_row_datas;     -- Array of datas
    l_borders   plpdf_type.t_row_borders;   -- Array of borders
    l_widths    plpdf_type.t_row_widths;    -- Array of widths
    l_aligns    plpdf_type.t_row_aligns;    -- Array of aligns
    l_styles    plpdf_type.t_row_styles;    -- Array of styles
    l_maxlines  plpdf_type.t_row_maxlines;  -- Array of max lines


    l_line_count  number := 0;
    l_page_count  number := 1;
    l_page_length constant number := 17;
    l_print_day   number := 0;

    l_survey_time varchar2(15);
    l_sched_start_time varchar2(15);
    l_search_time varchar2(15);
    l_sched_end_time varchar2(15);

l_filename varchar2(100);
po_filename varchar2(100);

-- Poonam 4/21/2017 - Added sched_start_time in the Order By
    cursor cater_cur is
        select z.ppszone
	       ,z.program_type
	       ,a.survey_time
               ,r.access_req
	       ,a.sched_start_time
	       ,a.search_time
	       ,a.sched_end_time
,ROW_NUMBER( ) OVER (PARTITION BY z.program_type ORDER BY z.display_order NULLS LAST) SRL_NO
        from art_access_schedule a
          ,art_ppszones z
          ,art_access_reqs r
        where a.RECOVERY_ZONE_TYPE = 'ART_PPSZONES'
	and a.RECOVERY_ZONE_ID = z.ppszone_id
        and a.sched_repair_id = pi_repair_id
        and a.access_req_id = r.access_req_id
        order by z.program_type, SRL_NO, a.sched_start_time;

 begin
   begin
    select 1
    into l_print_day
    from art_sched_repairs
    where sched_repair_id = pi_repair_id
      and trunc(sched_end_date) > trunc(sched_start_date);
   exception
     when others then NULL;
      l_print_day := 0;
   end;

    /* Initialize, without parameters means:
     - page orientation: portrait
     - unit: mm
     - default page format: A4 */
    plpdf.init
    (p_orientation => 'L'
    );

/* Sets the page footer procedure name. The program name passed
as a parameter executes when the page footer is created. */

-- Since we are not yet on v3.0, the below proc SetFooterProcName5 will NOT work.
--   So, we we will use just a regular footer for page no.
    plpdf.SetFooterProcName(
     p_proc_name => 'mcc_maint.CATER_UI.access_schedule_footer',
     p_height => 10 --Height of footer section
     );
     CATER_UI.access_schedule_footer;

    access_schedule_pdf_heading(l_widths,pi_repair_id,po_filename);
    access_schedule_notes(l_widths,pi_repair_id,l_print_day);

    for cater_rec in cater_cur
    loop
       if cater_rec.SRL_NO = 1 then
	    l_line_count := 0;
    apps_util.utl_plpdf.set_print_font_heading;
    apps_util.utl_plpdf.dark_grey_text;
            access_schedule_heading(l_widths);
	    apps_util.utl_plpdf.set_print_font_heading;
        end if;

         l_line_count := l_line_count + 1;

        if l_line_count >= l_page_length
        then
    apps_util.utl_plpdf.set_print_font_heading;
    apps_util.utl_plpdf.dark_grey_text;
            access_schedule_heading(l_widths);
            l_line_count := 1;
            l_page_count := l_page_count + 1;
	    apps_util.utl_plpdf.set_print_font_heading;
        end if;
-- Changing 0 to 1
     if mod(l_line_count,2) = 1 then
       apps_util.utl_plpdf.light_blue_fill;
     else
       apps_util.utl_plpdf.white_fill;
     end if;

     IF l_print_day = 1 THEN
       l_survey_time := to_char(cater_rec.survey_time,'Dy HH24:MI');
       l_sched_start_time := to_char(cater_rec.sched_start_time,'Dy HH24:MI');
       l_search_time := to_char(cater_rec.search_time,'Dy HH24:MI');
       l_sched_end_time := to_char(cater_rec.sched_end_time,'Dy HH24:MI');
     ELSE
       l_survey_time := to_char(cater_rec.survey_time,'HH24:MI');
       l_sched_start_time := to_char(cater_rec.sched_start_time,'HH24:MI');
       l_search_time := to_char(cater_rec.search_time,'HH24:MI');
       l_sched_end_time := to_char(cater_rec.sched_end_time,'HH24:MI');
     END IF;

        --set_text_color_for_status(cater_rec.status);

        /*
        case cater_rec.urgency
        when 'Immediate' then apps_util.utl_plpdf.light_yellow_fill;
        when 'Later'     then apps_util.utl_plpdf.light_grey_fill;
        else                  apps_util.utl_plpdf.white_fill;
        end case;
        */
    plpdf.setprintfont
    (p_family => 'Arial'        -- Font family: Arial
    ,p_style  => 'B'           -- Font style: Bold
    ,p_size   => 14             -- Font size: 12 pt
    );
        /* Draws a rectangle cell with text inside. */
        plpdf.printcell
        (p_w      => 40            -- Rectangle width
        ,p_h      => apps_util.utl_plpdf.g_row_height -- Rectangle heigth
        ,p_txt    => cater_rec.ppszone      -- Text in rectangle
        ,p_border => '1'                    -- With frame
        ,p_ln     => '0'                    -- Cursor position after the cell is printed
        ,p_align  => 'L'                    -- Text alignment: Left
        ,p_fill   => 1                      -- Fill with current fill color
        );

           /* Draws a rectangle cell with text inside. */
        plpdf.printcell
        (p_w      => 38            -- Rectangle width
        ,p_h      => apps_util.utl_plpdf.g_row_height -- Rectangle heigth
        ,p_txt    => l_survey_time      -- Text in rectangle
        ,p_border => '1'                    -- With frame
        ,p_ln     => '0'                    -- Cursor position after the cell is printed
        ,p_align  => 'C'                    -- Text alignment: Left
        ,p_fill   => 1                      -- Fill with current fill color
        );

           /* Draws a rectangle cell with text inside. */
        plpdf.printcell
        (p_w      => 52            -- Rectangle width
        ,p_h      => apps_util.utl_plpdf.g_row_height -- Rectangle heigth
        ,p_txt    => cater_rec.access_req      -- Text in rectangle
        ,p_border => '1'                    -- With frame
        ,p_ln     => '0'                    -- Cursor position after the cell is printed
        ,p_align  => 'C'                    -- Text alignment: Left
        ,p_fill   => 1                      -- Fill with current fill color
        );

           /* Draws a rectangle cell with text inside. */
        plpdf.printcell
        (p_w      => 38            -- Rectangle width
        ,p_h      => apps_util.utl_plpdf.g_row_height -- Rectangle heigth
        ,p_txt    => l_sched_start_time      -- Text in rectangle
        ,p_border => '1'                    -- With frame
        ,p_ln     => '0'                    -- Cursor position after the cell is printed
        ,p_align  => 'C'                    -- Text alignment: Left
        ,p_fill   => 1                      -- Fill with current fill color
        );

           /* Draws a rectangle cell with text inside. */
        plpdf.printcell
        (p_w      => 38            -- Rectangle width
        ,p_h      => apps_util.utl_plpdf.g_row_height -- Rectangle heigth
        ,p_txt    => l_search_time      -- Text in rectangle
        ,p_border => '1'                    -- With frame
        ,p_ln     => '0'                    -- Cursor position after the cell is printed
        ,p_align  => 'C'                    -- Text alignment: Left
        ,p_fill   => 1                      -- Fill with current fill color
        );

         /* Draws a rectangle cell with text inside. */
        plpdf.printcell
        (p_w      => 38           -- Rectangle width
        ,p_h      => apps_util.utl_plpdf.g_row_height -- Rectangle heigth
        ,p_txt    => l_sched_end_time      -- Text in rectangle
        ,p_border => '1'                    -- With frame
        ,p_ln     => '1'                    -- Cursor position after the cell is printed
        ,p_align  => 'C'                    -- Text alignment: Left
        ,p_fill   => 1                      -- Fill with current fill color
        );


    end loop;

    access_schedule_recovery_notes(l_widths,pi_repair_id,l_print_day);

    apps_util.utl_plpdf.line_break;
    -- apps_util.utl_plpdf.print_document(l_blob);
    -- store_document(l_blob);

     plpdf.SendDoc(l_blob);
     owa_util.mime_header('application/pdf',false);
     htp.p('Content-Disposition: attachment; filename="' || po_filename || '"');
     htp.p('Content-Length: ' || dbms_lob.getlength(l_blob));
     owa_util.http_header_close;
     wpg_docload.download_file(l_blob);


    --commit;

end pdf_access_schedule;


function get_region_label
(pi_page_type varchar2
,pi_prob_type varchar2
) return varchar2 as
  l_result varchar2(100);
begin

  l_result :=
  case pi_prob_type
    when 'HARDWARE' then 'Accelerator Hardware '||pi_page_type||' Information'
    when 'SOFTWARE' then 'Accelerator Software '||pi_page_type||' Information'
    when 'REQUEST'  then 'Hardware/Software Request'
    else pi_page_type||' Information'
  end;

  return l_result;

end;


procedure cater_search_query
(pi_person_id                   in number
,pi_slac_div_code_id            in number
,pi_allowed_codes               in varchar2
,pi_show_all_slac_divisions     in varchar2 := null
,pi_status                      in varchar2 := null
,pi_type                        in varchar2 := null
,pi_area_id                     in varchar2 := null
,pi_area_manager                in varchar2 := null
,pi_hop                         in varchar2 := null
,pi_assigned_to                 in varchar2 := null
,pi_shop                        in varchar2 := null
,pi_shop_alt                    in varchar2 := null
,pi_ww_after                    in varchar2 := null
,pi_ww_before                   in varchar2 := null
,pi_subsystem                   in varchar2 := null
,pi_description                 in varchar2 := null
,pi_created_before              in varchar2 := null
,pi_created_after               in varchar2 := null
,pi_area_manager_review_date    in varchar2 := null
,pi_before_or_after_am_rev_date in varchar2 := null
,pi_area_manager_rev_comments   in varchar2 := null
,pi_group_id                    in varchar2 := null
,pi_watch                       in out varchar2
,po_sql                         out varchar2
) as

  lf            constant char := chr(10);

  temp                   varchar2(4000);
  allowed_codes          varchar2(100);

begin

  -- convert from colon delimitted to comma delimitted string
  allowed_codes := replace(pi_allowed_codes,':',',');

  temp := 'select p.prob_id'||lf||
          '      ,initcap(replace(s.subsystem,''/'','' '')) subsystem'||lf||
          '      ,pers1.name assignedto_name'||lf||
--          '      ,to_char(p.created_date,''mm/dd/yyyy hh24:mi'') created_date '||lf||
          '      ,p.created_date'||lf||
          '      ,(select div_code from art_division_codes where div_code_id = p.div_code_id) div_code'||lf||
          '      ,case p.status_chk'||lf||
          '       when 0 then ''New'''||lf||
          '       when 1 then ''In Progress'''||lf||
          '       when 2 then ''Scheduled Jobs'''||lf||
          '       when 3 then ''Review to Close'''||lf||
          '       when 4 then ''Closed'''||lf||
          '       end as status'||lf||
          '      ,decode(p.prob_type_chk,''REQUEST'',substr(p.problem_title,1,80),p.pv_name||decode(p.pv_name,null,null,'' - - - '')||to_char(substr(p.description,1,80))) problem_short_description'||lf||
--          '     ,p.pv_name || decode(p.pv_name,null,null,'' - - - '')'||lf||
--          '     || to_char(substr(p.description,1,80)) '||lf||
--          '     problem_short_description'||lf||
          '      ,s.cc solutions' ||lf||
          '      ,j.cc jobs'||lf||
          '      ,pa.area' ||lf||
          '      ,g.name'||lf||
          '      ,to_char(p.area_mgr_review_date,''mm/dd/yyyy hh24:mi'') area_mgr_review_date'||lf||
          '      ,p.area_mgr_review_comments'||lf||
          'from art_problems           p'||lf||
          '    ,art_areas              pa'||lf||
          '    ,art_subsystems         s'||lf||
--          '    ,art_junc_group_problem gp'||lf||
          '    ,art_group              g'||lf||
          '    ,person                 pers1'||lf||
          '    ,(select prob_id, count(*) cc'||lf||
          '      from art_solutions'||lf||
          '      where nvl(review_to_close_chk,''N'') != ''Y'''||lf||
          '      group by prob_id) s'||lf||
          '    ,(select prob_id, count(*) cc'||lf||
          '      from art_jobs'||lf||
          '      where status_chk = 0'||lf||
          '      group by prob_id) j'||lf||
          'where p.prob_id       = s.prob_id      (+)'||lf||
          'and   p.prob_id       = j.prob_id      (+)'||lf||
          'and   p.area_id       = pa.area_id     (+)'||lf||
          'and   p.subsystem_id  = s.subsystem_id (+)'||lf||
--          'and   p.prob_id     = gp.problem_id  (+)'||lf||
--          'and   gp.group_id   = g.group_id     (+)'||lf||
          'and   p.group_id      = g.group_id     (+)'||lf||
          'and   p.assignedto_id = pers1.key      (+)'||lf;

  if nvl(pi_show_all_slac_divisions,'N') = 'Y'
  then
    temp := temp || 'and   p.div_code_id in (' || allowed_codes || ')' || lf;
  else
    temp := temp || 'and   p.div_code_id   = ' || pi_slac_div_code_id || lf;
  end if;

  if  pi_status is not null
  and pi_status != 'ANY'
  then
     if pi_status  = 'OPEN'
     then
       temp := temp || 'and   p.status_chk    < 4 '|| lf;
     elsif pi_status = 'LAST3'
     then
       temp := temp || 'and   p.status_chk    > 3' || lf;
       temp := temp || 'and   p.created_date  >= sysdate-90' || lf;
     else
       temp := temp || 'and   p.status_chk = ' || pi_status || lf;
     end if;
  end if;

  if  pi_type is not null
  and pi_type != 'ANY'
  then
     temp := temp ||'and   p.prob_type_chk = upper(' || pi_type || ') '|| lf;
  end if;

  if  pi_area_id is not null
  and pi_area_id != 'ANY'
  then
     if pi_show_all_slac_divisions = 'Y'
     then
       temp := temp || 'and   p.area_id = ''' || pi_area_id || lf;
     elsif pi_area_id is not null and pi_area_id = 'ALL'
     then
       temp := temp || 'and   p.area_id in (select q.area_id from art_areas q where q.div_code_id = ' || pi_slac_div_code_id || ') '|| lf;
     else
       temp := temp || 'and   p.area_id in (select q.area_id from art_areas q where q.area = ' || pi_area_id || ' and q.div_code_id = ' || pi_slac_div_code_id || ') '|| lf;
     end if;
  end if;

  if  pi_area_manager is not null
  and pi_area_manager != 'ANY'
  then
    if pi_show_all_slac_divisions = 'Y'
    then
        temp := temp || 'and   p.areamgr_id = ' || pi_area_manager || ' ' || lf;
    else
        temp := temp || 'and   p.areamgr_id = ' || pi_area_manager || ' and q.div_code_id = ' || pi_slac_div_code_id || lf;
    end if;
  end if;


  if  pi_hop is not null
  and pi_hop != 'ANY'
  then
    if pi_hop = 'NULL'
    then
      temp := temp || 'and (p.hop_chk is null or p.hop_chk = ''N'')' || lf;
    else
      temp := temp || 'and   p.hop_chk = ''Y''' || lf;
    end if;
  end if;

  if  pi_assigned_to is not null
  and pi_assigned_to != 'ANY'
  then
    temp := temp || 'and   p.assignedto_id = '||pi_assigned_to||' ' || lf;
  end if;


  if  pi_shop is not null
  and pi_shop != 'ANY'
  then
    if pi_show_all_slac_divisions = 'Y'
    then
      temp := temp || 'and   p.shop_main_id = ' || pi_shop || lf;
    else
      temp := temp || 'and   p.shop_main_id = ' || pi_shop ||' and q.div_code_id = '||pi_slac_div_code_id||')' || lf;
    end if;
  end if;

  if pi_shop_alt is not null and pi_shop_alt != 'ANY'
  then
    if pi_show_all_slac_divisions = 'Y'
    then
      temp := temp || 'and   p.shop_alt_id = ' || pi_shop_alt || lf;
    else
      temp := temp || 'and   p.shop_alt_id = ' || pi_shop_alt || ' and q.div_code_id = '||pi_slac_div_code_id || lf;
    end if;
  end if;

  if pi_ww_after is not null
  then
    temp := temp || 'and   p.watch_and_wait_date > to_date(''' || pi_ww_after || ''',''mm/dd/yyyy hh24:mi'')' || lf;
    pi_watch := 'ANY';
  end if;

  if pi_watch = 'ANY'
  then
    if pi_ww_before is not null
    then
      temp := temp || 'and   p.watch_and_wait_date < to_date(''' || pi_ww_before || ''',''mm/dd/yyyy hh24:mi'') and p.watch_and_wait_date is not null' || lf;
      pi_watch := 'ANY';
    end if;
  end if;

  if  pi_watch is not null
  and pi_watch != 'ANY'
  then

    if pi_watch = 'TODAY'
    then
      temp := temp || 'and   trunc(p.watch_and_wait_date) = trunc(sysdate)' || lf;
    elsif pi_watch = 'LATER'
    then
      temp := temp || 'and   p.watch_and_wait_date > sysdate' || lf;
    elsif pi_watch = 'EARLIER'
    then
      temp := temp || 'and   p.watch_and_wait_date < sysdate' || lf;
    elsif pi_watch = 'TOMORROW'
    then
      temp := temp || 'and   trunc(p.watch_and_wait_date) = trunc(sysdate+1)' || lf;
    else
      null;
    end if;
  end if;

  if  pi_subsystem is not null
  and pi_subsystem != 'ANY'
  then
    if pi_show_all_slac_divisions = 'Y'
    then
      temp := temp || 'and   p.subsystem_id =  ' || pi_subsystem || lf;
    else
      temp := temp || 'and   p.subsystem_id =  ' || pi_subsystem ||' and q.div_code_id = '||pi_slac_div_code_id || lf;
    end if;
  end if;

  if  pi_description is not null
  then
    temp := temp || 'and   upper(p.description) like ''%' || upper(pi_description) || '%''' || lf;
  end if;

  if pi_created_after is not null
  then
    temp := temp || 'and   p.created_date > to_date(''' || pi_created_after||''',''mm/dd/yyyy hh24:mi'')' || lf;
  end if;

  if pi_created_before is not null
  then
    temp := temp || 'and   p.created_date < to_date(''' || pi_created_before||''',''mm/dd/yyyy hh24:mi'')' || lf;
  end if;

  if pi_area_manager_review_date is not null
  then
    if pi_before_or_after_am_rev_date = 'B'
    then
      temp := temp || ' and   p.area_mgr_review_date <= to_date(''' || pi_area_manager_review_date || ''',''mm/dd/yyyy hh24:mi'')' || lf;
    else
      temp := temp || ' and   p.area_mgr_review_date >= to_date(''' || pi_area_manager_review_date || ''',''mm/dd/yyyy hh24:mi'')' || lf;
    end if;
  end if;

  if pi_area_manager_rev_comments is not null
  then
    temp := temp || ' and   p.area_mgr_review_comments like ''%' || pi_area_manager_rev_comments || '%''' || lf;
  end if;

  if  pi_group_id is not null
  then
    temp := temp || ' and   p.group_id = '||pi_group_id || lf;
  end if;

  po_sql := temp;

end cater_search_query;


function get_area_managers_for_area (p_area_id number) return varchar2 as

    l_names       varchar2(500);
    l_area_person varchar2(500);

    cursor area_person_cur(cp_area_id number) is
        select p.name
        from art_junc_area_person ap
            ,person p
        where ap.area_id   = cp_area_id
        and   ap.person_id = p.key;

begin

    open area_person_cur(p_area_id);
    loop

        fetch area_person_cur into l_area_person;

        if area_person_cur%notfound
        then
            exit;
        elsif area_person_cur%rowcount > 1
        then
            l_names := l_names || '/';
        end if;

        l_names := l_names || l_area_person;

    end loop;
    close area_person_cur;

    return l_names;

end get_area_managers_for_area;

procedure access_schedule_footer is

begin
/* Sets the font and its properties */
plpdf.SetPrintFont(
p_family => 'Arial', -- Font family: Arial
p_style => 'I', -- Font style: Italic
p_size => 12 -- Font size: 8 pt
);

apps_util.utl_plpdf.dark_grey_text;

/* Print number of page */
/* Draws a rectangle cell with text inside. */
plpdf.PrintCell(
p_w => 250, -- Rectangle width
p_h => 10, -- Rectangle heigth
p_txt => 'Page: '||to_char(plpdf.CurrentPageNumber), -- Text in rectangle
p_border => '0', -- Without frame
p_ln => '0', -- Cursor position after the cell is printed: Beside
p_align => 'R' -- Text alignment: Center
);
/*
    plpdf.printcell
    (p_w      => 0    -- Rectangle width
    ,p_h      => 10   -- Rectangle heigth
    ,p_txt    => 'Last Updated: '||to_char(last_mod_date,'FMDy Mon ddth, HH24:MI')
    ,p_border => '0'            -- With frame
    ,p_ln     => '0'            -- Cursor position after the cell is printed
    ,p_align  => 'R'            -- Text alignment: Center
    ,p_fill   => 0              -- Fill with current fill color
    );
*/
end access_schedule_footer;

END CATER_UI;

/
