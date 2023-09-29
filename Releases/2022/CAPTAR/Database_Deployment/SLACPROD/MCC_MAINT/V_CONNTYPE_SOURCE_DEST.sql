
  CREATE OR REPLACE VIEW "CAPTAR"."V_CONNTYPE_SOURCE_DEST" ("CABLENUM", "CONNINV_ID", "CONNTYPE", "CONN_SOURCE_DEST_TYPE") AS 
  select b.cablenum cablenum, 
    b.conninv_id conninv_id, 
    b.conntype conntype,
    decode(origin,'Y','SOURCE','N','DEST') as conn_source_dest_type
--    decode(ROW_NUMBER() OVER (PARTITION BY cablenum ORDER BY conninv_id),1,'SOURCE',2,'DEST') as conn_source_dest_type
from conninv b
where  cablenum is not null;
