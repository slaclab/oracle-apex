
  CREATE OR REPLACE  VIEW CAPTAR.V_CONNINV (ORIGIN_CABLENUM, ORIGIN_LOC, ORIGIN_RACK, ORIGIN_ELE, ORIGIN_SIDE, ORIGIN_SLOT, ORIGIN_CONNNUM, ORIGIN_STATION, ORIGIN_CONNTYPE, ORIGIN_INSTR, origin_type, DESTINATION_CABLENUM, DESTINATION_LOC, DESTINATION_RACK, DESTINATION_ELE, DESTINATION_SIDE, DESTINATION_SLOT, DESTINATION_CONNNUM, DESTINATION_STATION, DESTINATION_CONNTE, DESTINATION_INSTR, destination_type) AS 
  with w as (
select b.cablenum origin_cablenum, 
    b.conninv_id origin_conninv_id, 
    b.loc as origin_loc,
    b.rack as origin_rack,
    b.ele as origin_ele,
    b.side as origin_side,
    b.slot as origin_slot,
    b.connnum as origin_connnum,
    b.station origin_station,
    b.conntype origin_conntype,
    b.instr origin_instr,
    decode(b.origin,'Y','SOURCE','N','DESTINATION') as origin_type
from conninv b
where  cablenum is not null
and   origin = 'Y'),
y as (
select b.cablenum destination_cablenum, 
    b.conninv_id destination_conninv_id, 
    b.loc as destination_loc,
    b.rack as destination_rack,
    b.ele as destination_ele,
    b.side as destination_side,
    b.slot as destination_slot,
    b.connnum as destination_connnum,
    b.station destination_station,
    b.conntype destination_conntype,
    b.instr destination_instr,
    decode(b.origin,'Y','SOURCE','N','DESTINATION') as destination_type
from conninv b
where  cablenum is not null
and   origin = 'N')
select w.origin_cablenum,
w.origin_loc,
w.origin_rack,
w.origin_ele,
w.origin_side,
w.origin_slot,
w.origin_connnum,
w.origin_station,
w.origin_conntype,
w.origin_instr,
w.origin_type,
y.destination_cablenum,
y.destination_loc,
y.destination_rack,
y.destination_ele,
y.destination_side,
y.destination_slot,
y.destination_connnum,
y.destination_station,
y.destination_conntype,
y.destination_instr,
y.destination_type
from w, y
where w.origin_cablenum is not null
and y.destination_cablenum is not null
and w.origin_cablenum = y.destination_cablenum;
