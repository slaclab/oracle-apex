create or replace PROCEDURE COMPARE_MAGNET_POLY_CHANGES
AS

/*
NAME:            COMPARE_MAGNET_POLY_CHANGES

PURPOSE:         DETECTS ANY CHANGES MADE IN THE PREVIOUS 24 HOURS TO BMIN/BMAX & IMIN/IMAX and to Polynomial Coeffs 
                 IN TABLE LCLS_INFRASTRUCTURE.MAGNET_POLYNOMIALS ON SLACPROD.
                 A REPORT OF THESE CHANGES, IF ANY, ARE EMAILED TO SPECIFIC PEOPLE.
                 THE INTENT IS TO DBMS_SCHEDULE THIS PROCEDURE TO BE RUN AT 5 PM DAILY.
		 CATER #152417

MODS:            Poonam  01/26/2022       
*/

  V_ERRMSG                                                 VARCHAR2(1000);
  V_HEADER                                                  VARCHAR2(10000);
  V_FORMAT                                                 VARCHAR2(1);
  V_DEBUG                                                    VARCHAR2(1);
  V_MSG                                                       CLOB;
  V_CNT1                                                        PLS_INTEGER;
  V_CNT2                                                        PLS_INTEGER;

  GC_INSTANCE   CONSTANT      VARCHAR2(30) := UPPER(SYS_CONTEXT('USERENV', 'DB_NAME'));

  C_PROC                          CONSTANT         VARCHAR2(100) := 'COMPARE_MAGNET_POLY_CHANGES';
  C_PIPE                            CONSTANT          VARCHAR2(1)  := '|';
  C_CRLF                          CONSTANT          VARCHAR2(2)   := CHR(10);
  C_TAB                          CONSTANT          VARCHAR2(2)   := CHR(9);
  C_COMMA                      CONSTANT          VARCHAR2(2)   := ',';

  C_SEND_ADDR               CONSTANT          VARCHAR2(500) := 'poonam@slac.stanford.edu;magnets-l@slac.stanford.edu';
  C_FROM_ADDR              CONSTANT          VARCHAR2(500) := 'Notify_Process';
  C_SUBJECT                CONSTANT          VARCHAR2(100) := 'Notify Magnet Polynomial Changes in ';

  PROC_ERROR                EXCEPTION;
  l_instance		varchar2(100);
  l_session_user	varchar2(100);
  l_subject		varchar2(200);
BEGIN
  l_instance := sys_context('USERENV','INSTANCE_NAME');
  l_session_user := sys_context('USERENV','SESSION_USER');

  V_ERRMSG := NULL;
  V_MSG := NULL;
  V_CNT1 := 0;
  V_CNT2 := 0;

  ---------------------------------

    V_HEADER := 'Bmin/Bmax Imin/Imax Changes'||C_CRLF;
    V_HEADER := V_HEADER||'# '||C_TAB||'EVENT_DATE'||C_TAB||C_TAB||C_TAB||
                         'POLYNOMIAL'||C_TAB||
                         'BARCODE'||C_TAB||
                         'ELEMENT'||C_TAB||
                         'BMIN_VAL'||C_TAB||
                         'BMAX_VAL'||C_TAB||
                         'IMIN_VAL'||C_TAB||
                         'IMAX_VAL'||C_CRLF;
    V_HEADER := V_HEADER ||
    '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'||C_CRLF;

      V_MSG := '*' || USER || '@' || GC_INSTANCE || '*' || C_CRLF || V_HEADER || C_CRLF;
--dbms_output.put_line('loop start');

FOR J IN
(
select event_date, barcode, polynomial, element,
       bmin_val,bmax_val,imin_val,imax_val
from MAGNET_POLYNOMIALS_CHANGES_VW
where (bmin_val like '%->%'
or bmax_val like '%->%'
or imin_val like '%->%'
or imax_val like '%->%'
)
and event_date >= sysdate-1
order by 1 desc
)
LOOP

  V_CNT1 := V_CNT1 + 1;
--dbms_output.put_line('V_CNT1= '||V_CNT1||', element= '||j.element);

    V_MSG := V_MSG||V_CNT1||')'||C_TAB||TO_CHAR(J.EVENT_DATE, 'DD-MON-YYYY HH:MI:SS PM')||C_COMMA||C_TAB||
		    j.polynomial ||C_COMMA||C_TAB||
                    J.barcode ||C_COMMA||C_TAB||
                    J.element ||C_COMMA||C_TAB||
                    J.bmin_val ||C_COMMA||C_TAB||
                    J.bmax_val ||C_COMMA||C_TAB||
                    J.imin_val ||C_COMMA||C_TAB||
                    J.imax_val ||C_CRLF;

END LOOP;
--dbms_output.put_line('V_CNT1= '||V_CNT1||', loop end');

---------------------------------
    V_HEADER := 'Magnet Poly Coeff Changes'||C_CRLF;
    V_HEADER := V_HEADER||'# '||C_TAB||'EVENT_DATE'||C_TAB||C_TAB||C_TAB||
                         'POLYNOMIAL'||C_TAB||
                         'BARCODE'||C_TAB||
                         'ELEMENT'||C_TAB||
                         'COEFF_0_VAL'||C_TAB||
                         'COEFF_1_VAL'||C_TAB||
                         'COEFF_2_VAL'||C_TAB||
                         'COEFF_3_VAL'||C_TAB||
                         'COEFF_4_VAL'||C_TAB||
                         'COEFF_5_VAL'||C_TAB||
                         'COEFF_6_VAL'||C_TAB||
                         'COEFF_7_VAL'||C_TAB||
                         'COEFF_8_VAL'||C_TAB||
                         'COEFF_9_VAL'||C_TAB||
                         'COEFF_10_VAL'||C_TAB||
                         'COEFF_11_VAL'||C_TAB||
                         'COEFF_12_VAL'||C_CRLF;
    V_HEADER := V_HEADER ||
    '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'||C_CRLF;
DBMS_LOB.CreateTemporary( V_MSG, true );
      V_MSG := V_MSG || C_CRLF || V_HEADER || C_CRLF;
--dbms_output.put_line('loop2 start');

FOR i IN
(
select event_date, barcode, polynomial, element,
COEFF_0_VAL,
COEFF_1_VAL,
COEFF_2_VAL,
COEFF_3_VAL,
COEFF_4_VAL,
COEFF_5_VAL,
COEFF_6_VAL,
COEFF_7_VAL,
COEFF_8_VAL,
COEFF_9_VAL,
COEFF_10_VAL,
COEFF_11_VAL,
COEFF_12_VAL
from MAGNET_POLYNOMIALS_CHANGES_VW
where (COEFF_0_VAL like '%->%'
	or COEFF_1_VAL like '%->%'
	or COEFF_2_VAL like '%->%'
	or COEFF_3_VAL like '%->%'
	or COEFF_4_VAL like '%->%'
	or COEFF_5_VAL like '%->%'
	or COEFF_6_VAL like '%->%'
	or COEFF_7_VAL like '%->%'
	or COEFF_8_VAL like '%->%'
	or COEFF_9_VAL like '%->%'
	or COEFF_10_VAL like '%->%'
	or COEFF_11_VAL like '%->%'
	or COEFF_12_VAL like '%->%'
)
and event_date >= sysdate-1
order by 1 desc
)
LOOP

  V_CNT2 := V_CNT2 + 1;
--dbms_output.put_line('V_CNT2= '||V_CNT2||', element= '||i.element);

    V_MSG := V_MSG||V_CNT2||')'||C_TAB||TO_CHAR(i.EVENT_DATE, 'DD-MON-YYYY HH:MI:SS PM')||C_COMMA||C_TAB||
		i.POLYNOMIAL||C_COMMA||C_TAB||
		i.BARCODE||C_COMMA||C_TAB||
		i.ELEMENT||C_COMMA||C_TAB||
		i.COEFF_0_VAL||C_COMMA||C_TAB||
		i.COEFF_1_VAL||C_COMMA||C_TAB||
		i.COEFF_2_VAL||C_COMMA||C_TAB||
		i.COEFF_3_VAL||C_COMMA||C_TAB||
		i.COEFF_4_VAL||C_COMMA||C_TAB||
		i.COEFF_5_VAL||C_COMMA||C_TAB||
		i.COEFF_6_VAL||C_COMMA||C_TAB||
		i.COEFF_7_VAL||C_COMMA||C_TAB||
		i.COEFF_8_VAL||C_COMMA||C_TAB||
		i.COEFF_9_VAL||C_COMMA||C_TAB||
		i.COEFF_10_VAL||C_COMMA||C_TAB||
		i.COEFF_11_VAL||C_COMMA||C_TAB||
		i.COEFF_12_VAL||C_CRLF;

END LOOP;
--dbms_output.put_line('V_CNT2= '||V_CNT2||', loop end');

---------------------------------
  IF ( V_CNT1 > 0 ) OR ( V_CNT2 > 0 ) THEN

    l_subject := C_SUBJECT || l_session_user ||' on '|| l_instance;

    NOTIFY_PKG.ORA_SENDMAIL(P_SEND_ADDR => C_SEND_ADDR,
                            P_FROM_ADDR => C_FROM_ADDR,
                            P_MSG       => V_MSG,
                            P_SUBJECT   => l_subject,
                            P_ERRMSG    => V_ERRMSG);

    IF ( V_ERRMSG IS NOT NULL ) THEN
        RAISE PROC_ERROR;
    END IF;

  END IF;

  RETURN;


EXCEPTION
  WHEN PROC_ERROR THEN
    RAISE_APPLICATION_ERROR (-20010, V_ERRMSG);
  WHEN OTHERS THEN
    V_ERRMSG := SUBSTR('ERROR ('||C_PROC||'): OTHERS ERROR =>'||SQLERRM, 1, 1000);
    RAISE_APPLICATION_ERROR (-20020, V_ERRMSG);

END COMPARE_MAGNET_POLY_CHANGES;
/