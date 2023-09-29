-- Start with this Template script always, add the commands and save as
-- MAIN_SCRIPT.sql in the New Deployment folder

set define off
set pages 9999
set time on
set timing on

spool MAIN_SCRIPT.lst;

select * from user_objects where status='INVALID' 
order by object_type, object_name;

select table_name, trigger_name,trigger_type, triggering_event from user_triggers 
where status='DISABLED'
order by 1,2;

select * from user_objects where status='INVALID' order by object_type, object_name;

-- This is where you put your SQL/PLSQL scripts to be run
@fix_cater_id_rswcf_form.sql

spool off;

set pagesize 0
set heading off;
set feedback off;
set time off
set timing off
set echo off
set termout off
set verify off
set trimspool on
spool compile_invalid_objects.sql
select 'alter '||object_type||' '||object_name||' compile;' 
from user_objects 
where status='INVALID' 
and object_type in ('TRIGGER','PACKAGE','FUNCTION','PROCEDURE','VIEW', 'MATERIALIZED VIEW')
order by object_type, object_name;

spool off;
@compile_invalid_objects.sql

spool compile_invalid_package_body.sql
select 'alter package '||object_name||' compile body;' 
from user_objects 
where status='INVALID' 
and object_type in ('PACKAGE BODY')
order by object_type, object_name;

spool off;

@compile_invalid_package_body.sql

set heading on;
set feedback on;
set pagesize 9999
set time on
set timing on
set echo on
set termout on
set verify on
set trimspool off
spool MAIN_SCRIPT_db_health_check.lst;

select * from user_objects where status='INVALID' order by object_type, object_name;

select table_name, trigger_name,trigger_type, triggering_event from user_triggers 
where status='DISABLED'
order by 1,2;

spool off;