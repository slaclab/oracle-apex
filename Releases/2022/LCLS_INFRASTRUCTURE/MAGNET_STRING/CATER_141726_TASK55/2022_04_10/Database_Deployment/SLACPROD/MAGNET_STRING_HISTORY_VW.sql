
  CREATE OR REPLACE VIEW LCLS_INFRASTRUCTURE.MAGNET_STRING_HISTORY_VW (ROWNUM_OLD, ROWNUM_NEW, PSC_ID, BARCODE, JN_OPERATION, JN_ORACLE_USER, JN_DATETIME, JN_NOTES, JN_APPLN, JN_SESSION, OLD_ELEMENT, NEW_ELEMENT, OLD_POLY_ID, NEW_POLY_ID, OLD_PSC_TYPE, NEW_PSC_TYPE, OLD_PSC_DEVICE, NEW_PSC_DEVICE, OLD_PSC_NODE, NEW_PSC_NODE, OLD_PSC_LOCN, NEW_PSC_LOCN, OLD_ACSW_NODE, NEW_ACSW_NODE, OLD_TS_NODE, NEW_TS_NODE, OLD_MCOR_CRATE_NUM, NEW_MCOR_CRATE_NUM, OLD_MCOR_CRATE_CHAN, NEW_MCOR_CRATE_CHAN, OLD_BULK_PS, NEW_BULK_PS, OLD_IOC, NEW_IOC, OLD_ACSW_NAME, NEW_ACSW_NAME, OLD_ACSW_HOST, NEW_ACSW_HOST, OLD_ACSW_PLUG, NEW_ACSW_PLUG, OLD_HW_DISPLAY, NEW_HW_DISPLAY, OLD_UNIT_DISPLAY, NEW_UNIT_DISPLAY, OLD_LIMIT_DISPLAY, NEW_LIMIT_DISPLAY, OLD_HW_AREA, NEW_HW_AREA, OLD_COOLING_TYPE, NEW_COOLING_TYPE, OLD_SAFETY_SYSTEM, NEW_SAFETY_SYSTEM, OLD_SAFETY_BCS, NEW_SAFETY_BCS, OLD_SAFETY_PPS, NEW_SAFETY_PPS, OLD_SAFETY_MPS, NEW_SAFETY_MPS, OLD_STDZ_FUNC, NEW_STDZ_FUNC, OLD_DEGAUSS_FUNC, NEW_DEGAUSS_FUNC, OLD_CALIB_FUNC, NEW_CALIB_FUNC, OLD_DEGAUSS_SETL, NEW_DEGAUSS_SETL, OLD_DEGAUSS_RAMP_RATE, NEW_DEGAUSS_RAMP_RATE, OLD_DEGAUSS_WF_UOM, NEW_DEGAUSS_WF_UOM, OLD_DEGAUSS_RAMP_RATE_UOM, NEW_DEGAUSS_RAMP_RATE_UOM, OLD_DEGAUSS_SETL_UOM, NEW_DEGAUSS_SETL_UOM, OLD_DEGAUSS_STEP_SIZE, NEW_DEGAUSS_STEP_SIZE, OLD_DEGAUSS_STEP_SIZE_UOM, NEW_DEGAUSS_STEP_SIZE_UOM, OLD_DEGAUSS_WF_ELEM_CNT, NEW_DEGAUSS_WF_ELEM_CNT, OLD_DEGAUSS_WF, NEW_DEGAUSS_WF, OLD_UNIT_DISPLAY_OVERRIDE, NEW_UNIT_DISPLAY_OVERRIDE, OLD_HW_DISPLAY_OVERRIDE, NEW_HW_DISPLAY_OVERRIDE, OLD_SW_PS_STRING, NEW_SW_PS_STRING, CREATED_BY, DATE_CREATED, OLD_UPDATED_BY, NEW_UPDATED_BY, OLD_DATE_UPDATED, NEW_DATE_UPDATED) AS 
  SELECT
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE rownum_old
END  as rownum_old,
rownum_new,
f_cur.psc_id as psc_id,
f_cur.barcode as barcode,
f_cur.jn_operation  as jn_operation,
f_cur.jn_oracle_user  as jn_oracle_user,
f_cur.jn_datetime  as jn_datetime,
f_cur.jn_notes  as jn_notes,
f_cur.jn_appln  as jn_appln,
f_cur.jn_session  as jn_session,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.element
END  as old_element,
f_cur.element  as new_element,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.poly_id
END  as old_poly_id,
f_cur.poly_id  as new_poly_id,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.psc_type
END  as old_psc_type,
f_cur.psc_type  as new_psc_type,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.psc_device
END  as old_psc_device,
f_cur.psc_device  as new_psc_device,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.psc_node
END  as old_psc_node,
f_cur.psc_node  as new_psc_node,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.psc_locn
END  as old_psc_locn,
f_cur.psc_locn  as new_psc_locn,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.acsw_node
END  as old_acsw_node,
f_cur.acsw_node  as new_acsw_node,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.ts_node
END  as old_ts_node,
f_cur.ts_node  as new_ts_node,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.mcor_crate_num
END  as old_mcor_crate_num,
f_cur.mcor_crate_num  as new_mcor_crate_num,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.mcor_crate_chan
END  as old_mcor_crate_chan,
f_cur.mcor_crate_chan  as new_mcor_crate_chan,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.bulk_ps
END  as old_bulk_ps,
f_cur.bulk_ps  as new_bulk_ps,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.ioc
END  as old_ioc,
f_cur.ioc  as new_ioc,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.acsw_name
END  as old_acsw_name,
f_cur.acsw_name  as new_acsw_name,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.acsw_host
END  as old_acsw_host,
f_cur.acsw_host  as new_acsw_host,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.acsw_plug
END  as old_acsw_plug,
f_cur.acsw_plug  as new_acsw_plug,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.hw_display
END  as old_hw_display,
f_cur.hw_display  as new_hw_display,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.unit_display
END  as old_unit_display,
f_cur.unit_display  as new_unit_display,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.limit_display
END  as old_limit_display,
f_cur.limit_display  as new_limit_display,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.hw_area
END  as old_hw_area,
f_cur.hw_area  as new_hw_area,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.cooling_type
END  as old_cooling_type,
f_cur.cooling_type  as new_cooling_type,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.safety_system
END  as old_safety_system,
f_cur.safety_system  as new_safety_system,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.safety_bcs
END  as old_safety_bcs,
f_cur.safety_bcs  as new_safety_bcs,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.safety_pps
END  as old_safety_pps,
f_cur.safety_pps  as new_safety_pps,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.safety_mps
END  as old_safety_mps,
f_cur.safety_mps  as new_safety_mps,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.stdz_func
END  as old_stdz_func,
f_cur.stdz_func  as new_stdz_func,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.degauss_func
END  as old_degauss_func,
f_cur.degauss_func  as new_degauss_func,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.calib_func
END  as old_calib_func,
f_cur.calib_func  as new_calib_func,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.degauss_setl
END  as old_degauss_setl,
f_cur.degauss_setl  as new_degauss_setl,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.degauss_ramp_rate
END  as old_degauss_ramp_rate,
f_cur.degauss_ramp_rate  as new_degauss_ramp_rate,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.degauss_wf_uom
END  as old_degauss_wf_uom,
f_cur.degauss_wf_uom  as new_degauss_wf_uom,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.degauss_ramp_rate_uom
END  as old_degauss_ramp_rate_uom,
f_cur.degauss_ramp_rate_uom  as new_degauss_ramp_rate_uom,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.degauss_setl_uom
END  as old_degauss_setl_uom,
f_cur.degauss_setl_uom  as new_degauss_setl_uom,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.degauss_step_size
END  as old_degauss_step_size,
f_cur.degauss_step_size  as new_degauss_step_size,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.degauss_step_size_uom
END  as old_degauss_step_size_uom,
f_cur.degauss_step_size_uom  as new_degauss_step_size_uom,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.degauss_wf_elem_cnt
END  as old_degauss_wf_elem_cnt,
f_cur.degauss_wf_elem_cnt  as new_degauss_wf_elem_cnt,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.degauss_wf
END  as old_degauss_wf,
f_cur.degauss_wf  as new_degauss_wf,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.UNIT_DISPLAY_OVERRIDE
END  as old_unit_display_override,
f_cur.UNIT_DISPLAY_OVERRIDE  as new_unit_display_override,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.HW_DISPLAY_OVERRIDE
END  as old_hw_display_override,
f_cur.HW_DISPLAY_OVERRIDE  as new_hw_display_override,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.SW_PS_STRING
END  as old_sw_ps_string,
f_cur.SW_PS_STRING  as new_sw_ps_string,
f_cur.created_by as created_by,
f_cur.date_created as date_created,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.updated_by
END  as old_updated_by,
f_cur.updated_by  as new_updated_by,
CASE f_cur.jn_operation
   WHEN 'INS' THEN NULL
   ELSE f_pre.date_updated
END  as old_date_updated,
f_cur.date_updated  as new_date_updated
from (
	SELECT ROWNUM rownum_new,
	PSC_ID,
	BARCODE,
	JN_OPERATION,
	JN_ORACLE_USER,
	JN_DATETIME,
	JN_NOTES,
	JN_APPLN,
	JN_SESSION,
	ELEMENT,
	POLY_ID,
	PSC_TYPE,
	PSC_DEVICE,
	PSC_NODE,
	PSC_LOCN,
	ACSW_NODE,
	TS_NODE,
	MCOR_CRATE_NUM,
	MCOR_CRATE_CHAN,
	BULK_PS,
	IOC,
	ACSW_NAME,
	ACSW_HOST,
	ACSW_PLUG,
	HW_DISPLAY,
	UNIT_DISPLAY,
	LIMIT_DISPLAY,
	HW_AREA,
	COOLING_TYPE,
	SAFETY_SYSTEM,
	SAFETY_BCS,
	SAFETY_PPS,
	SAFETY_MPS,
	STDZ_FUNC,
	DEGAUSS_FUNC,
	CALIB_FUNC,
	DEGAUSS_SETL,
	DEGAUSS_RAMP_RATE,
	DEGAUSS_WF_UOM,
	DEGAUSS_RAMP_RATE_UOM,
	DEGAUSS_SETL_UOM,
	DEGAUSS_STEP_SIZE,
	DEGAUSS_STEP_SIZE_UOM,
	DEGAUSS_WF_ELEM_CNT,
	DEGAUSS_WF,
	UNIT_DISPLAY_OVERRIDE,
	HW_DISPLAY_OVERRIDE,
	SW_PS_STRING,
	CREATED_BY,
	DATE_CREATED,
	UPDATED_BY,
	DATE_UPDATED
	FROM ( select
		JN_OPERATION,
		JN_ORACLE_USER,
		JN_DATETIME,
		JN_NOTES,
		JN_APPLN,
		JN_SESSION,
		PSC_ID,
		BARCODE,
		ELEMENT,
		POLY_ID,
		PSC_TYPE,
		PSC_DEVICE,
		PSC_NODE,
		PSC_LOCN,
		ACSW_NODE,
		TS_NODE,
		to_char(MCOR_CRATE_NUM) as MCOR_CRATE_NUM,
		to_char(MCOR_CRATE_CHAN) as MCOR_CRATE_CHAN,
		BULK_PS,
		IOC,
		CREATED_BY,
		DATE_CREATED,
		UPDATED_BY,
		DATE_UPDATED,
		ACSW_NAME,
		ACSW_HOST,
		to_char(ACSW_PLUG) as ACSW_PLUG,
		HW_DISPLAY,
		UNIT_DISPLAY,
		LIMIT_DISPLAY,
		HW_AREA,
		COOLING_TYPE,
		to_char(SAFETY_SYSTEM) as SAFETY_SYSTEM,
		to_char(SAFETY_BCS) as SAFETY_BCS,
		to_char(SAFETY_PPS) as SAFETY_PPS,
		to_char(SAFETY_MPS) as SAFETY_MPS,
		STDZ_FUNC,
		DEGAUSS_FUNC,
		CALIB_FUNC,
		to_char(DEGAUSS_SETL) as DEGAUSS_SETL,
		to_char(DEGAUSS_RAMP_RATE) as DEGAUSS_RAMP_RATE,
		DEGAUSS_WF_UOM,
		DEGAUSS_RAMP_RATE_UOM,
		DEGAUSS_SETL_UOM,
		to_char(DEGAUSS_STEP_SIZE) as DEGAUSS_STEP_SIZE,
		DEGAUSS_STEP_SIZE_UOM,
		to_char(DEGAUSS_WF_ELEM_CNT) as DEGAUSS_WF_ELEM_CNT,
		DEGAUSS_WF,
		UNIT_DISPLAY_OVERRIDE,
		HW_DISPLAY_OVERRIDE,
		SW_PS_STRING
		FROM MAGNET_STRING_JN
		ORDER BY psc_id, jn_datetime DESC)) f_cur,
	(SELECT ROWNUM rownum_old,
	PSC_ID,
	BARCODE,
	JN_OPERATION,
	JN_ORACLE_USER,
	JN_DATETIME,
	JN_NOTES,
	JN_APPLN,
	JN_SESSION,
	ELEMENT,
	POLY_ID,
	PSC_TYPE,
	PSC_DEVICE,
	PSC_NODE,
	PSC_LOCN,
	ACSW_NODE,
	TS_NODE,
	MCOR_CRATE_NUM,
	MCOR_CRATE_CHAN,
	BULK_PS,
	IOC,
	ACSW_NAME,
	ACSW_HOST,
	ACSW_PLUG,
	HW_DISPLAY,
	UNIT_DISPLAY,
	LIMIT_DISPLAY,
	HW_AREA,
	COOLING_TYPE,
	SAFETY_SYSTEM,
	SAFETY_BCS,
	SAFETY_PPS,
	SAFETY_MPS,
	STDZ_FUNC,
	DEGAUSS_FUNC,
	CALIB_FUNC,
	DEGAUSS_SETL,
	DEGAUSS_RAMP_RATE,
	DEGAUSS_WF_UOM,
	DEGAUSS_RAMP_RATE_UOM,
	DEGAUSS_SETL_UOM,
	DEGAUSS_STEP_SIZE,
	DEGAUSS_STEP_SIZE_UOM,
	DEGAUSS_WF_ELEM_CNT,
	DEGAUSS_WF,
	UNIT_DISPLAY_OVERRIDE,
	HW_DISPLAY_OVERRIDE,
	SW_PS_STRING,
	CREATED_BY,
	DATE_CREATED,
	UPDATED_BY,
	DATE_UPDATED
	FROM ( select
		JN_OPERATION,
		JN_ORACLE_USER,
		JN_DATETIME,
		JN_NOTES,
		JN_APPLN,
		JN_SESSION,
		PSC_ID,
		BARCODE,
		ELEMENT,
		POLY_ID,
		PSC_TYPE,
		PSC_DEVICE,
		PSC_NODE,
		PSC_LOCN,
		ACSW_NODE,
		TS_NODE,
		to_char(MCOR_CRATE_NUM) as MCOR_CRATE_NUM,
		to_char(MCOR_CRATE_CHAN) as MCOR_CRATE_CHAN,
		BULK_PS,
		IOC,
		CREATED_BY,
		DATE_CREATED,
		UPDATED_BY,
		DATE_UPDATED,
		ACSW_NAME,
		ACSW_HOST,
		to_char(ACSW_PLUG) as ACSW_PLUG,
		HW_DISPLAY,
		UNIT_DISPLAY,
		LIMIT_DISPLAY,
		HW_AREA,
		COOLING_TYPE,
		to_char(SAFETY_SYSTEM) as SAFETY_SYSTEM,
		to_char(SAFETY_BCS) as SAFETY_BCS,
		to_char(SAFETY_PPS) as SAFETY_PPS,
		to_char(SAFETY_MPS) as SAFETY_MPS,
		STDZ_FUNC,
		DEGAUSS_FUNC,
		CALIB_FUNC,
		to_char(DEGAUSS_SETL) as DEGAUSS_SETL,
		to_char(DEGAUSS_RAMP_RATE) as DEGAUSS_RAMP_RATE,
		DEGAUSS_WF_UOM,
		DEGAUSS_RAMP_RATE_UOM,
		DEGAUSS_SETL_UOM,
		to_char(DEGAUSS_STEP_SIZE) as DEGAUSS_STEP_SIZE,
		DEGAUSS_STEP_SIZE_UOM,
		to_char(DEGAUSS_WF_ELEM_CNT) as DEGAUSS_WF_ELEM_CNT,
		DEGAUSS_WF,
		UNIT_DISPLAY_OVERRIDE,
		HW_DISPLAY_OVERRIDE,
		SW_PS_STRING
		FROM MAGNET_STRING_JN
		ORDER BY psc_id, jn_datetime DESC)) f_pre
    WHERE   f_pre.rownum_old(+) = f_cur.rownum_new + 1
    AND (
		NVL(f_pre.ELEMENT,'x') != NVL(f_cur.ELEMENT,'x')   OR
		NVL(f_pre.POLY_ID,0) != NVL(f_cur.POLY_ID,0)   OR
		NVL(f_pre.PSC_TYPE,'x') != NVL(f_cur.PSC_TYPE,'x')   OR
		NVL(f_pre.PSC_DEVICE,'x') != NVL(f_cur.PSC_DEVICE,'x')   OR
		NVL(f_pre.PSC_NODE,'x') != NVL(f_cur.PSC_NODE,'x')   OR
		NVL(f_pre.PSC_LOCN,'x') != NVL(f_cur.PSC_LOCN,'x')   OR
		NVL(f_pre.ACSW_NODE,'x') != NVL(f_cur.ACSW_NODE,'x')   OR
		NVL(f_pre.TS_NODE,'x') != NVL(f_cur.TS_NODE,'x')   OR
		NVL(TO_CHAR(f_pre.MCOR_CRATE_NUM),'Null') != NVL(TO_CHAR(f_cur.MCOR_CRATE_NUM),'Null')  OR
		NVL(TO_CHAR(f_pre.MCOR_CRATE_CHAN),'Null') != NVL(TO_CHAR(f_cur.MCOR_CRATE_CHAN),'Null')  OR
		NVL(f_pre.BULK_PS,'x') != NVL(f_cur.BULK_PS,'x')   OR
		NVL(f_pre.IOC,'x') != NVL(f_cur.IOC,'x')   OR
		NVL(f_pre.ACSW_NAME,'x') != NVL(f_cur.ACSW_NAME,'x')   OR
		NVL(f_pre.ACSW_HOST,'x') != NVL(f_cur.ACSW_HOST,'x')   OR
		NVL(TO_CHAR(f_pre.ACSW_PLUG),'Null') != NVL(TO_CHAR(f_cur.ACSW_PLUG),'Null')  OR
		NVL(f_pre.HW_DISPLAY,'x') != NVL(f_cur.HW_DISPLAY,'x')   OR
		NVL(f_pre.UNIT_DISPLAY,'x') != NVL(f_cur.UNIT_DISPLAY,'x')   OR
		NVL(f_pre.LIMIT_DISPLAY,'x') != NVL(f_cur.LIMIT_DISPLAY,'x')   OR
		NVL(f_pre.HW_AREA,'x') != NVL(f_cur.HW_AREA,'x')   OR
		NVL(f_pre.COOLING_TYPE,'x') != NVL(f_cur.COOLING_TYPE,'x')   OR
		NVL(TO_CHAR(f_pre.SAFETY_SYSTEM),'Null') != NVL(TO_CHAR(f_cur.SAFETY_SYSTEM),'Null')   OR
		NVL(TO_CHAR(f_pre.SAFETY_BCS),'Null') != NVL(TO_CHAR(f_cur.SAFETY_BCS),'Null')  OR
		NVL(TO_CHAR(f_pre.SAFETY_PPS),'Null') != NVL(TO_CHAR(f_cur.SAFETY_PPS),'Null')  OR
		NVL(TO_CHAR(f_pre.SAFETY_MPS),'Null') != NVL(TO_CHAR(f_cur.SAFETY_MPS),'Null')  OR
		NVL(f_pre.STDZ_FUNC,'x') != NVL(f_cur.STDZ_FUNC,'x')   OR
		NVL(f_pre.DEGAUSS_FUNC,'x') != NVL(f_cur.DEGAUSS_FUNC,'x')   OR
		NVL(f_pre.CALIB_FUNC,'x') != NVL(f_cur.CALIB_FUNC,'x')   OR
		NVL(TO_CHAR(f_pre.DEGAUSS_SETL),'Null') != NVL(TO_CHAR(f_cur.DEGAUSS_SETL),'Null')  OR
		NVL(TO_CHAR(f_pre.DEGAUSS_RAMP_RATE),'Null') != NVL(TO_CHAR(f_cur.DEGAUSS_RAMP_RATE),'Null')  OR
		NVL(f_pre.DEGAUSS_WF_UOM,'x') != NVL(f_cur.DEGAUSS_WF_UOM,'x')   OR
		NVL(f_pre.DEGAUSS_RAMP_RATE_UOM,'x') != NVL(f_cur.DEGAUSS_RAMP_RATE_UOM,'x')   OR
		NVL(f_pre.DEGAUSS_SETL_UOM,'x') != NVL(f_cur.DEGAUSS_SETL_UOM,'x')   OR
		NVL(TO_CHAR(f_pre.DEGAUSS_STEP_SIZE),'Null') != NVL(TO_CHAR(f_cur.DEGAUSS_STEP_SIZE),'Null')  OR
		NVL(f_pre.DEGAUSS_STEP_SIZE_UOM,'x') != NVL(f_cur.DEGAUSS_STEP_SIZE_UOM,'x')   OR
		NVL(TO_CHAR(f_pre.DEGAUSS_WF_ELEM_CNT),'Null') != NVL(TO_CHAR(f_cur.DEGAUSS_WF_ELEM_CNT),'Null')  OR
		NVL(f_pre.DEGAUSS_WF,'x') != NVL(f_cur.DEGAUSS_WF,'x')   OR
		NVL(f_pre.UNIT_DISPLAY_OVERRIDE,'x') != NVL(f_cur.UNIT_DISPLAY_OVERRIDE,'x')   OR
		NVL(f_pre.HW_DISPLAY_OVERRIDE,'x') != NVL(f_cur.HW_DISPLAY_OVERRIDE,'x')   OR
		NVL(f_pre.SW_PS_STRING,'x') != NVL(f_cur.SW_PS_STRING,'x')   OR
		f_cur.jn_operation = 'INS')
ORDER BY f_cur.psc_id, f_cur.jn_datetime DESC;
