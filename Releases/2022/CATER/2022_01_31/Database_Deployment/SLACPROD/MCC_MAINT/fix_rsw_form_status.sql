-- Forms 5991/6009/6116. The status is changing from Closed to Work Not Approved.
-- This is because they do not have the person responsible signature in section which was not implemented until 2015.
-- and the logic is forcing status=Work not approved for this case.
-- So need to disable the triggers for updating them.

set pages 9999
set echo on
set feedback on
set define off

spool fix_rsw_form_status.lst

create table rsw_form_02022022
as select * from rsw_form;

create table rsw_form_jn_02022022
as select * from rsw_form_jn;

alter trigger RSW_FORM_CHG_TRG disable;
alter trigger RSW_FORM_MESSAGES_TRG disable;
alter trigger RSW_FORM_TRG disable;

-- This trigger will only write the journal record into RSW_FORM_JN with no other trigger checks
@RSW_FORM_TRG_TEMP.sql

update rsw_form
set form_status_id = 6
where form_id in (6116,6009,5991);

select form_id, form_status_id
from rsw_form
where form_id in (6116,6009,5991);

select form_id, form_status_id, jn_datetime
from rsw_form_jn
where form_id in (6116,6009,5991)
order by form_id, 3 desc;

select table_name, trigger_name,trigger_type, triggering_event from user_triggers 
where status='DISABLED'
order by 1,2;

select * from user_objects where status='INVALID' order by object_type, object_name;

alter trigger RSW_FORM_TRG enable;
alter trigger RSW_FORM_CHG_TRG enable;
alter trigger RSW_FORM_MESSAGES_TRG enable;
drop trigger RSW_FORM_TRG_TEMP;

spool off;