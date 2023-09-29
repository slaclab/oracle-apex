create or replace procedure update_safety_system
as
  C_PROC	CONSTANT   VARCHAR2(30) := 'update_safety_system';
  ERRMSG	VARCHAR2(1000);
BEGIN
  EXECUTE IMMEDIATE 'ALTER TRIGGER MAGNET_STRING_BIUDR DISABLE'; 
  update_magnet_string_safety;
  EXECUTE IMMEDIATE 'ALTER TRIGGER MAGNET_STRING_BIUDR ENABLE';
EXCEPTION
   WHEN OTHERS THEN
--    apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||' Error for PSC_ID= '|| c1_rec.PSC_ID||', Barcode = '|| c1_rec.barcode||', Element = '|| c1_rec.element);
    apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||' Error');
    ERRMSG := SUBSTR(SQLERRM,1,1000);
    RAISE_APPLICATION_ERROR(-20120, ERRMSG);
END;