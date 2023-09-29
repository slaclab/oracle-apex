create or replace procedure update_magnet_string_safety
as
  C_PROC	CONSTANT   VARCHAR2(30) := 'update_magnet_string_safety';
  ERRMSG	VARCHAR2(1000);
  v_safety_system magnet_string.safety_system%TYPE := 99;

  cursor c1 is
    select PSC_ID, BARCODE, ELEMENT, SAFETY_SYSTEM, SAFETY_BCS, SAFETY_MPS, SAFETY_PPS
    from magnet_string;

BEGIN
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' Begin');
  FOR c1_rec in c1 LOOP

    IF (c1_rec.SAFETY_BCS = 0 and c1_rec.SAFETY_MPS = 0 and c1_rec.SAFETY_PPS = 0) THEN
      IF (c1_rec.SAFETY_SYSTEM != 0 or c1_rec.SAFETY_SYSTEM is null) THEN
 apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 1');
 apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||' PSC_ID= '|| c1_rec.PSC_ID||', Barcode = '|| c1_rec.barcode||', Element = '|| c1_rec.element);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_SYSTEM= '||c1_rec.SAFETY_SYSTEM);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_BCS= '||c1_rec.SAFETY_BCS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_MPS= '||c1_rec.SAFETY_MPS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_PPS= '||c1_rec.SAFETY_PPS);
      v_safety_system := 0;
      END IF;
    END IF;
    --
    IF (c1_rec.SAFETY_BCS = 1 and c1_rec.SAFETY_MPS = 0 and c1_rec.SAFETY_PPS = 0) THEN
      IF (nvl(c1_rec.SAFETY_SYSTEM,0) != 1) THEN
 apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 2');
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||' PSC_ID= '|| c1_rec.PSC_ID||', Barcode = '|| c1_rec.barcode||', Element = '|| c1_rec.element);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_SYSTEM= '||c1_rec.SAFETY_SYSTEM);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_BCS= '||c1_rec.SAFETY_BCS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_MPS= '||c1_rec.SAFETY_MPS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_PPS= '||c1_rec.SAFETY_PPS);
        v_safety_system := 1;
      END IF;
    END IF;
    --
    IF (c1_rec.SAFETY_BCS = 0 and c1_rec.SAFETY_MPS = 0 and c1_rec.SAFETY_PPS = 1) THEN
      IF (nvl(c1_rec.SAFETY_SYSTEM,0) != 2) THEN
 apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 3');
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||' PSC_ID= '|| c1_rec.PSC_ID||', Barcode = '|| c1_rec.barcode||', Element = '|| c1_rec.element);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_SYSTEM= '||c1_rec.SAFETY_SYSTEM);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_BCS= '||c1_rec.SAFETY_BCS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_MPS= '||c1_rec.SAFETY_MPS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_PPS= '||c1_rec.SAFETY_PPS);
        v_safety_system := 2;
      END IF;
    END IF;
    --
    IF (c1_rec.SAFETY_BCS = 1 and c1_rec.SAFETY_MPS = 0 and c1_rec.SAFETY_PPS = 1) THEN
      IF (nvl(c1_rec.SAFETY_SYSTEM,0) != 3) THEN
 apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 4');
 apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||' PSC_ID= '|| c1_rec.PSC_ID||', Barcode = '|| c1_rec.barcode||', Element = '|| c1_rec.element);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_SYSTEM= '||c1_rec.SAFETY_SYSTEM);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_BCS= '||c1_rec.SAFETY_BCS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_MPS= '||c1_rec.SAFETY_MPS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_PPS= '||c1_rec.SAFETY_PPS);
       v_safety_system := 3;
      END IF;
    END IF;
    --
    IF (c1_rec.SAFETY_BCS = 0 and c1_rec.SAFETY_MPS = 1 and c1_rec.SAFETY_PPS = 0) THEN
      IF (nvl(c1_rec.SAFETY_SYSTEM,0) != 4) THEN
  apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 5');
  apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||' PSC_ID= '|| c1_rec.PSC_ID||', Barcode = '|| c1_rec.barcode||', Element = '|| c1_rec.element);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_SYSTEM= '||c1_rec.SAFETY_SYSTEM);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_BCS= '||c1_rec.SAFETY_BCS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_MPS= '||c1_rec.SAFETY_MPS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_PPS= '||c1_rec.SAFETY_PPS);
     v_safety_system := 4;
      END IF;
    END IF;
    --
    IF (c1_rec.SAFETY_BCS = 1 and c1_rec.SAFETY_MPS = 1 and c1_rec.SAFETY_PPS = 0) THEN
      IF (nvl(c1_rec.SAFETY_SYSTEM,0) != 5) THEN
 apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 6');
 apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||' PSC_ID= '|| c1_rec.PSC_ID||', Barcode = '|| c1_rec.barcode||', Element = '|| c1_rec.element);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_SYSTEM= '||c1_rec.SAFETY_SYSTEM);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_BCS= '||c1_rec.SAFETY_BCS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_MPS= '||c1_rec.SAFETY_MPS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_PPS= '||c1_rec.SAFETY_PPS);
       v_safety_system := 5;
      END IF;
    END IF;
    --
    IF (c1_rec.SAFETY_BCS = 0 and c1_rec.SAFETY_MPS = 1 and c1_rec.SAFETY_PPS = 1) THEN
      IF (nvl(c1_rec.SAFETY_SYSTEM,0) != 6) THEN
  apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 7');
 apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||' PSC_ID= '|| c1_rec.PSC_ID||', Barcode = '|| c1_rec.barcode||', Element = '|| c1_rec.element);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_SYSTEM= '||c1_rec.SAFETY_SYSTEM);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_BCS= '||c1_rec.SAFETY_BCS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_MPS= '||c1_rec.SAFETY_MPS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_PPS= '||c1_rec.SAFETY_PPS);
      v_safety_system := 6;
      END IF;
    END IF;
    --
    IF (c1_rec.SAFETY_BCS = 1 and c1_rec.SAFETY_MPS = 1 and c1_rec.SAFETY_PPS = 1) THEN
      IF (nvl(c1_rec.SAFETY_SYSTEM,0) != 7) THEN
 apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 8');
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||' PSC_ID= '|| c1_rec.PSC_ID||', Barcode = '|| c1_rec.barcode||', Element = '|| c1_rec.element);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_SYSTEM= '||c1_rec.SAFETY_SYSTEM);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_BCS= '||c1_rec.SAFETY_BCS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_MPS= '||c1_rec.SAFETY_MPS);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' SAFETY_PPS= '||c1_rec.SAFETY_PPS);
        v_safety_system := 7;
      END IF;
    END IF;
    --
  IF (v_safety_system != 99) THEN
  apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' updated for PSC_ID = '||c1_rec.PSC_ID);
 apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' v_safety_system= '||v_safety_system);
   update magnet_string
    set SAFETY_SYSTEM = v_safety_system
    where psc_id = c1_rec.PSC_ID;
  END IF;
  v_safety_system := 99;
  END LOOP;
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' End');

EXCEPTION
   WHEN OTHERS THEN
--    apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||' Error for PSC_ID= '|| c1_rec.PSC_ID||', Barcode = '|| c1_rec.barcode||', Element = '|| c1_rec.element);
    apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc ||' Error');
    ERRMSG := SUBSTR(SQLERRM,1,1000);
    RAISE_APPLICATION_ERROR(-20120, ERRMSG);
END;
/