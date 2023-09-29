set pages 9999
set echo on
set feedback on
spool fix_cater_id_rsw_form_form.lst

create table rsw_form_01312022
as select * from rsw_form;

create table rsw_form_jn_01312022
as select * from rsw_form_jn;

select a.form_id as rsw_form_id, a.prob_id as original_cater_id, a.job_id as original_job_id,a.jn_datetime as form_created_on, 
b.prob_id as latest_cater_id, b.job_id as latest_job_id, getval('RAD_FORM_STATUS',b.form_status_id) as form_status
from rsw_form_jn a, rsw_form b
where a.jn_operation = 'INS'
and a.form_id = b.form_id
and a.prob_id != b.prob_id
order by a.form_id desc;

update rsw_form set prob_id =  99533 ,
		 job_id =  68644 
where form_id =  5340  
and prob_id =  99488
;
update rsw_form set prob_id =  110681 ,
		 job_id =  76100 
where form_id =  5905  
and prob_id =  109801
;
update rsw_form set prob_id =  110681 ,
		 job_id =  76100 
where form_id =  5906  
and prob_id =  109801
;
update rsw_form set prob_id =  109746 ,
		 job_id =  76719 
where form_id =  5975  
and prob_id =  109775
;
update rsw_form set prob_id =  110781 ,
		 job_id =  76479 
where form_id =  5978  
and prob_id =  111058
;
update rsw_form set prob_id =  109746 ,
		 job_id =  76719 
where form_id =  5991  
and prob_id =  112293
;
update rsw_form set prob_id =  112810 ,
		 job_id =  77431 
where form_id =  6009  
and prob_id =  112824
;
update rsw_form set prob_id =  115881 ,
		 job_id =  79465 
where form_id =  6116  
and prob_id =  115878
;
update rsw_form set prob_id =  126483
where form_id =  6570  
and prob_id =  117516
;
update rsw_form set prob_id =  129049
where form_id =  6773  
and prob_id =  130081
;
update rsw_form set prob_id =  136094 ,
		 job_id =  95523 
where form_id =  7237  
and prob_id =  135990
;
update rsw_form set prob_id =  139487 ,
		 job_id =  98540 
where form_id =  7475  
and prob_id =  138942
;
update rsw_form set prob_id =  142461 ,
		 job_id =  101704 
where form_id =  8008  
and prob_id =  146052
;
update rsw_form set prob_id =  142461 ,
		 job_id =  101704 
where form_id =  8055  
and prob_id =  146406
;
update rsw_form set prob_id =  149301 ,
		 job_id =  106157 
where form_id =  8285  
and prob_id =  150188
;
update rsw_form set prob_id =  150975 ,
		 job_id =  106955 
where form_id =  8352  
and prob_id =  146461
;
update rsw_form set prob_id =  149656 ,
		 job_id =  107842 
where form_id =  8423  
and prob_id =  152261
;

select a.form_id as rsw_form_id, a.prob_id as original_cater_id, a.job_id as original_job_id,a.jn_datetime as form_created_on, 
b.prob_id as latest_cater_id, b.job_id as latest_job_id, getval('RAD_FORM_STATUS',b.form_status_id) as form_status
from rsw_form_jn a, rsw_form b
where a.jn_operation = 'INS'
and a.form_id = b.form_id
and a.form_id in (8423,
8352,
8285,
8055,
8008,
7475,
7237,
6773,
6570,
6116,
6009,
5991,
5978,
5975,
5906,
5905,
5340
)
order by a.form_id desc;

spool off;