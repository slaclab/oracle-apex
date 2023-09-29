create or replace PROCEDURE COMPARE_SYMBOLS_COLS_CHANGE
AS

/*
NAME:            COMPARE_SYMBOLS_COLS_CHANGE

PURPOSE:         DETECTS ANY CHANGES MADE IN THE PREVIOUS 24 HOURS TO COLUMNS LINACZ_M and Engineering name 
                 IN TABLE LCLS_INFRASTRUCTURE.SYMBOLS_UPLOAD ON SLACPROD.
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

  C_PROC                          CONSTANT         VARCHAR2(100) := 'COMPARE_SYMBOLS_COLS_CHANGE';
  C_PIPE                            CONSTANT          VARCHAR2(1)  := '|';
  C_CRLF                          CONSTANT          VARCHAR2(2)   := CHR(10);
  C_TAB                          CONSTANT          VARCHAR2(2)   := CHR(9);
  C_COMMA                      CONSTANT          VARCHAR2(2)   := ',';

  C_SEND_ADDR               CONSTANT          VARCHAR2(500) := 'poonam@slac.stanford.edu;magnets-l@slac.stanford.edu';
  C_FROM_ADDR              CONSTANT          VARCHAR2(500) := 'Notify_Process';
  C_SUBJECT                CONSTANT          VARCHAR2(100) := 'Notify Symbols Column Changes in ';

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

    V_HEADER := 'LINACZ_M Changes'||C_CRLF;
    V_HEADER := V_HEADER||'# '||C_TAB||'EVENT_DATE'||C_TAB||C_TAB||C_TAB||
                         'UPLOAD_ID'||C_TAB||
                         'BEAMLINE'||C_TAB||
                         'ELEMENT'||C_TAB||
                         'OLD_LINACZ_M'||C_TAB||
                         'NEW_LINACZ_M'||C_TAB||
                         'LINACZ_DIFF_MM'||C_CRLF;
    V_HEADER := V_HEADER ||
    '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'||C_CRLF;

      V_MSG := '*' || USER || '@' || GC_INSTANCE || '*' || C_CRLF || V_HEADER || C_CRLF;
--dbms_output.put_line('loop start');

FOR J IN
(
select BEAMLINE, new_UPLOAD_ID,new_DATE_UPLOADED as event_date,
    new_ELEMENT,new_linacz_m,old_linacz_m,linacz_diff_mm
from V_LINACZ_ENGG_NAME_CHANGE
where new_linacz_m !=  old_linacz_m
and new_DATE_UPLOADED >= SYSDATE - 1
)
LOOP

  V_CNT1 := V_CNT1 + 1;
--dbms_output.put_line('V_CNT1= '||V_CNT1||', element= '||j.new_element);

    V_MSG := V_MSG||V_CNT1||')'||C_TAB||TO_CHAR(J.EVENT_DATE, 'DD-MON-YYYY HH:MI:SS PM')||C_COMMA||C_TAB||
		    j.new_upload_id||C_COMMA||C_TAB||
                    J.BEAMLINE||C_COMMA||C_TAB||
                    J.new_ELEMENT||C_COMMA||C_TAB||
                    J.old_linacz_m||C_COMMA||C_TAB||
                    J.new_linacz_m||C_COMMA||C_TAB||
                    J.linacz_diff_mm||C_CRLF;

END LOOP;
--dbms_output.put_line('V_CNT1= '||V_CNT1||', loop end');

---------------------------------
    V_HEADER := 'Engineering Name Changes'||C_CRLF;
    V_HEADER := V_HEADER||'# '||C_TAB||'EVENT_DATE'||C_TAB||C_TAB||C_TAB||
                         'UPLOAD_ID'||C_TAB||
                         'BEAMLINE'||C_TAB||
                         'ELEMENT'||C_TAB||
                         'OLD_ENGINEERING_NAME'||C_TAB||
                         'NEW_ENGINEERING_NAME'||C_CRLF;
    V_HEADER := V_HEADER ||
    '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'||C_CRLF;

      V_MSG := V_MSG || C_CRLF || V_HEADER || C_CRLF;
--dbms_output.put_line('loop2 start');

FOR i IN
(
select BEAMLINE, new_UPLOAD_ID,new_DATE_UPLOADED as event_date,
    new_ELEMENT,NEW_ENGINEERING_NAME,OLD_ENGINEERING_NAME
from V_LINACZ_ENGG_NAME_CHANGE
where NEW_ENGINEERING_NAME !=  OLD_ENGINEERING_NAME
and new_DATE_UPLOADED >= SYSDATE - 1
)
LOOP

  V_CNT2 := V_CNT2 + 1;
--dbms_output.put_line('V_CNT2= '||V_CNT2||', element= '||i.new_element);

    V_MSG := V_MSG||V_CNT2||')'||C_TAB||TO_CHAR(i.EVENT_DATE, 'DD-MON-YYYY HH:MI:SS PM')||C_COMMA||C_TAB||
		    i.new_upload_id||C_COMMA||C_TAB||
                    i.BEAMLINE||C_COMMA||C_TAB||
                    i.new_ELEMENT||C_COMMA||C_TAB||
                    i.OLD_ENGINEERING_NAME||C_COMMA||C_TAB||C_TAB||
                    i.NEW_ENGINEERING_NAME||C_CRLF;

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

END COMPARE_SYMBOLS_COLS_CHANGE;
/