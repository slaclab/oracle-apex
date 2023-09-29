create or replace view V_LINACZ_ENGG_NAME_CHANGE as
select b.description as beamline, new_BEAMLINE as new_beamline_id, old_beamline as old_beamline_id, new_UPLOAD_ID,old_upload_id, 
   new_DATE_UPLOADED,old_DATE_UPLOADED,new_ELEMENT,new_linacz_m,old_linacz_m,
   new_ENGINEERING_NAME, old_ENGINEERING_NAME,
   (new_linacz_m - old_linacz_m)*1000 linacz_diff_mm
from beamlines b, 
(
with max_upload as (
select sl.BEAMLINE as new_BEAMLINE ,
sl.UPLOAD_ID as new_UPLOAD_ID ,
sl.DATE_UPLOADED as new_DATE_UPLOADED ,
su.ELEMENT_ID as new_ELEMENT_ID ,
su.ELEMENT as new_ELEMENT ,
su.SOLID_EDGE_X_COOR as new_linacz_m,
su.ENGINEERING_NAME as new_ENGINEERING_NAME
from   SYMBOLS_UPLOAD_LOG sl, symbols_upload su
where sl.upload_id = su.upload_id
 and  sl.upload_id = 
      (select max(x.upload_id) from SYMBOLS_UPLOAD_LOG x
       where x.beamline = sl.beamline))
, next_max_upload as (
select sl.BEAMLINE as old_BEAMLINE ,
sl.UPLOAD_ID as old_UPLOAD_ID ,
sl.DATE_UPLOADED as old_DATE_UPLOADED ,
su.ELEMENT_ID as old_ELEMENT_ID ,
su.ELEMENT as old_ELEMENT ,
su.SOLID_EDGE_X_COOR as old_linacz_m,
su.ENGINEERING_NAME as old_ENGINEERING_NAME
from   SYMBOLS_UPLOAD_LOG sl, symbols_upload su
where sl.upload_id = su.upload_id
 and  1 = (select count(distinct(upload_id))
      from SYMBOLS_UPLOAD_LOG b
      where b.beamline = sl.beamline
       and  b.upload_id > sl.upload_id))
 select a.new_BEAMLINE, b.old_beamline, new_UPLOAD_ID,old_upload_id, new_DATE_UPLOADED,old_DATE_UPLOADED, new_ELEMENT,old_element,
 new_linacz_m,old_linacz_m, new_ENGINEERING_NAME, old_ENGINEERING_NAME
 from max_upload a, next_max_upload b
 where a.new_beamline = b.old_beamline
 and a.new_element = b.old_element
 ) a
 where b.id = a.new_beamline;