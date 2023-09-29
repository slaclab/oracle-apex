create or replace procedure SET_LIMIT_DISPLAY (
    pi_ms_barcode	IN VARCHAR2,
    po_parent_psc_type	OUT VARCHAR2)
AS
	l_ps_string	  magnet_polynomial.ps_string%TYPE;
	l_parent_barcode  magnet_polynomial.barcode%TYPE;
--	po_parent_psc_type	magnet_string.psc_type%TYPE;
	ERRMSG	  VARCHAR2(500);
	C_PROC    CONSTANT   VARCHAR2(30) := 'SET_LIMIT_DISPLAY';
begin
 apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' Begin');
      select p.barcode,p.ps_string, s.psc_type
       into l_parent_barcode, l_ps_string, po_parent_psc_type
       from magnet_polynomial p, magnet_string s
       where p.barcode = s.barcode
       and p.ps_config='STRING MAIN'
       and p.ps_string in (select ps_string
			  from magnet_polynomial
			  where barcode = pi_ms_barcode 
			  and ps_config='STRING');

--			and element != ps_string);

dbms_output.put_line('String Barcode= '|| pi_ms_barcode);
dbms_output.put_line('Parent Barcode= '|| l_parent_barcode);
dbms_output.put_line('l_ps_string= '|| l_ps_string);
dbms_output.put_line('po_parent_psc_type= '|| po_parent_psc_type);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' po_parent_psc_type= '|| po_parent_psc_type);
apps_util.utl.log_add(p_appl_id => 2, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' End');

exception
      WHEN NO_DATA_FOUND THEN
        po_parent_psc_type := '';
      WHEN OTHERS THEN
	 ERRMSG := SUBSTR(SQLERRM,1,500);
	 RAISE_APPLICATION_ERROR(-20120, ERRMSG);

end SET_LIMIT_DISPLAY;   
/
