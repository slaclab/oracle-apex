--------------------------------------------------------
--  File created - Thursday-September-29-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table SSRL_RSW_FORM
--------------------------------------------------------

  CREATE TABLE "MCC_MAINT"."SSRL_RSW_FORM" 
   (	"SSRL_FORM_ID" NUMBER, 
	"S1_PRELIM_1" CHAR(1 BYTE), 
	"S1_PRELIM_2" CHAR(1 BYTE), 
	"FORM_STATUS_ID" NUMBER(2,0), 
	"EMAIL_CHK" VARCHAR2(1 BYTE), 
	"EMAIL_RULE" NUMBER(4,0), 
	"DROP_FORM_CHK" VARCHAR2(1 BYTE), 
	"SSRL_FORM_ID_TRANSFER_FROM" NUMBER, 
	"SSRL_FORM_ID_TRANSFER_TO" NUMBER, 
	"S1_TASK_PERSON_ID" NUMBER, 
	"S1_AREA_ID" NUMBER, 
	"S1_START_TIME" DATE, 
	"S1_DESCR" VARCHAR2(4000 BYTE), 
	"S2_DESCR_BEFORE" VARCHAR2(4000 BYTE), 
	"S2_DESCR_AFTER" VARCHAR2(4000 BYTE), 
	"S3_RAD_ID" NUMBER, 
	"S3_RAD_DATE" DATE, 
	"S3_RAD_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S3_SSO_ID" NUMBER, 
	"S3_SSO_DATE" DATE, 
	"S3_SSO_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S3_AREA_MGR_ID" NUMBER, 
	"S3_AREA_MGR_DATE" DATE, 
	"S3_AREA_MGR_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S3_TASK_PERSON_ACK_ID" NUMBER, 
	"S3_TASK_PERSON_ACK_DATE" DATE, 
	"S3_TASK_PERSON_ACK_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S4_OPERATOR_ID" NUMBER, 
	"S4_OPERATOR_DATE" DATE, 
	"S4_OPERATOR_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S4_ASSIGN_WRKR_ID" NUMBER, 
	"S4_ASSIGN_WRKR_DATE" DATE, 
	"S4_ASSIGN_WRKR_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S4_WRKR_ID" NUMBER, 
	"S4_WRKR_DATE" DATE, 
	"S4_WRKR_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S5_TASK_PERSON_CHK" VARCHAR2(1 BYTE), 
	"S5_TASK_PERSON_COMMENTS" VARCHAR2(500 BYTE), 
	"S5_TASK_PERSON_ACK_ID" NUMBER, 
	"S5_TASK_PERSON_ACK_DATE" DATE, 
	"S5_TASK_PERSON_ACK_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S5_PPS_CHK" VARCHAR2(1 BYTE), 
	"S5_PPS_COMMENTS" VARCHAR2(500 BYTE), 
	"S5_PPS_ID" NUMBER, 
	"S5_PPS_DATE" DATE, 
	"S5_PPS_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S5_RAD_CHK" VARCHAR2(1 BYTE), 
	"S5_RAD_COMMENTS" VARCHAR2(500 BYTE), 
	"S5_RAD_ID" NUMBER, 
	"S5_RAD_DATE" DATE, 
	"S5_RAD_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S5_OPERATOR_CHK" VARCHAR2(1 BYTE), 
	"S5_OPERATOR_COMMENTS" VARCHAR2(500 BYTE), 
	"S5_OPERATOR_ID" NUMBER, 
	"S5_OPERATOR_DATE" DATE, 
	"S5_OPERATOR_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S5_RPFO_CHK" VARCHAR2(1 BYTE), 
	"S5_RPFO_COMMENTS" VARCHAR2(500 BYTE), 
	"S5_RPFO_ID" NUMBER, 
	"S5_RPFO_DATE" DATE, 
	"S5_RPFO_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S5_OTHER1_CHK" VARCHAR2(1 BYTE), 
	"S5_OTHER1_ID" NUMBER, 
	"S5_OTHER1_COMMENTS" VARCHAR2(500 BYTE), 
	"S5_OTHER1_ACK_ID" NUMBER, 
	"S5_OTHER1_ACK_DATE" DATE, 
	"S5_OTHER1_ACK_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S5_OTHER2_CHK" VARCHAR2(1 BYTE), 
	"S5_OTHER2_ID" NUMBER, 
	"S5_OTHER2_COMMENTS" VARCHAR2(500 BYTE), 
	"S5_OTHER2_ACK_ID" NUMBER, 
	"S5_OTHER2_ACK_DATE" DATE, 
	"S5_OTHER2_ACK_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S5_OTHER3_CHK" VARCHAR2(1 BYTE), 
	"S5_OTHER3_ID" NUMBER, 
	"S5_OTHER3_COMMENTS" VARCHAR2(500 BYTE), 
	"S5_OTHER3_ACK_ID" NUMBER, 
	"S5_OTHER3_ACK_DATE" DATE, 
	"S5_OTHER3_ACK_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S6_SSO_ID" NUMBER, 
	"S6_SSO_DATE" DATE, 
	"S6_SSO_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"S6_OPERATOR_ID" NUMBER, 
	"S6_OPERATOR_DATE" DATE, 
	"S6_OPERATOR_MODIFIED_BY" VARCHAR2(30 BYTE), 
	"FOLLOWUP_COMMENTS" VARCHAR2(4000 BYTE), 
	"POST_CLOSURE_COMMENTS" VARCHAR2(4000 BYTE), 
	"CREATED_BY" VARCHAR2(30 BYTE), 
	"CREATED_DATE" DATE, 
	"MODIFIED_BY" VARCHAR2(30 BYTE), 
	"MODIFIED_DATE" DATE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "MCC_MAINT_DATA" ;
--------------------------------------------------------
--  DDL for Index SSRL_RSW_FORM_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "MCC_MAINT"."SSRL_RSW_FORM_PK" ON "MCC_MAINT"."SSRL_RSW_FORM" ("SSRL_FORM_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "MCC_MAINT_DATA" ;
--------------------------------------------------------
--  DDL for Trigger SSRL_RSW_FORM_AIUDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "MCC_MAINT"."SSRL_RSW_FORM_AIUDR" 
    AFTER INSERT OR UPDATE OR DELETE ON SSRL_RSW_FORM
    FOR EACH ROW
DECLARE
    JN_OPERATION VARCHAR2(3);
BEGIN
    IF INSERTING THEN
        JN_OPERATION := 'INS';
    ELSIF UPDATING THEN
        JN_OPERATION := 'UPD';
    ELSIF DELETING THEN
        JN_OPERATION := 'DEL';
    END IF;
    IF INSERTING OR UPDATING THEN
        INSERT INTO SSRL_RSW_FORM_JN
        ( JN_OPERATION, JN_ORACLE_USER, JN_DATETIME, JN_NOTES, JN_APPLN, JN_SESSION
         , SSRL_FORM_ID, S1_PRELIM_1, S1_PRELIM_2
         , FORM_STATUS_ID, EMAIL_CHK, EMAIL_RULE, SSRL_FORM_ID_TRANSFER_FROM
         , SSRL_FORM_ID_TRANSFER_TO, S1_TASK_PERSON_ID, S1_AREA_ID, S1_START_TIME
         , S1_DESCR, S2_DESCR_BEFORE, S2_DESCR_AFTER, S3_RAD_ID
         , S3_RAD_DATE, S3_RAD_MODIFIED_BY, S3_SSO_ID, S3_SSO_DATE
         , S3_SSO_MODIFIED_BY, S3_AREA_MGR_ID, S3_AREA_MGR_DATE, S3_AREA_MGR_MODIFIED_BY
         , S3_TASK_PERSON_ACK_ID, S3_TASK_PERSON_ACK_DATE, S3_TASK_PERSON_ACK_MODIFIED_BY, S4_OPERATOR_ID
         , S4_OPERATOR_DATE, S4_OPERATOR_MODIFIED_BY, S4_WRKR_ID, S4_WRKR_DATE
         , S4_WRKR_MODIFIED_BY, S5_TASK_PERSON_CHK, S5_TASK_PERSON_COMMENTS, S5_TASK_PERSON_ACK_ID
         , S5_TASK_PERSON_ACK_DATE, S5_TASK_PERSON_ACK_MODIFIED_BY, S5_PPS_CHK, S5_PPS_COMMENTS
         , S5_PPS_ID, S5_PPS_DATE, S5_PPS_MODIFIED_BY, S5_RAD_CHK
         , S5_RAD_COMMENTS, S5_RAD_ID, S5_RAD_DATE, S5_RAD_MODIFIED_BY
         , S5_OPERATOR_CHK, S5_OPERATOR_COMMENTS, S5_OPERATOR_ID, S5_OPERATOR_DATE
         , S5_OPERATOR_MODIFIED_BY, S5_RPFO_CHK, S5_RPFO_COMMENTS, S5_RPFO_ID
         , S5_RPFO_DATE, S5_RPFO_MODIFIED_BY
         , S5_OTHER1_CHK, S5_OTHER1_ID, S5_OTHER1_COMMENTS, S5_OTHER1_ACK_ID
         , S5_OTHER1_ACK_DATE, S5_OTHER1_ACK_MODIFIED_BY, S5_OTHER2_CHK, S5_OTHER2_ID
         , S5_OTHER2_COMMENTS, S5_OTHER2_ACK_ID, S5_OTHER2_ACK_DATE, S5_OTHER2_ACK_MODIFIED_BY
         , S5_OTHER3_CHK, S5_OTHER3_ID, S5_OTHER3_COMMENTS, S5_OTHER3_ACK_ID
         , S5_OTHER3_ACK_DATE, S5_OTHER3_ACK_MODIFIED_BY, S6_SSO_ID, S6_SSO_DATE
         , S6_SSO_MODIFIED_BY, S6_OPERATOR_ID, S6_OPERATOR_DATE, S6_OPERATOR_MODIFIED_BY
         , FOLLOWUP_COMMENTS, POST_CLOSURE_COMMENTS, CREATED_BY, CREATED_DATE
         , MODIFIED_BY, MODIFIED_DATE
	 , S4_ASSIGN_WRKR_ID, S4_ASSIGN_WRKR_DATE, S4_ASSIGN_WRKR_MODIFIED_BY, DROP_FORM_CHK
	) VALUES (jn_operation, NVL(V('APP_USER'),USER), SYSDATE, NULL, NULL, userenv('sessionid')
         , :NEW.SSRL_FORM_ID, :NEW.S1_PRELIM_1, :NEW.S1_PRELIM_2
         , :NEW.FORM_STATUS_ID, :NEW.EMAIL_CHK, :NEW.EMAIL_RULE, :NEW.SSRL_FORM_ID_TRANSFER_FROM
         , :NEW.SSRL_FORM_ID_TRANSFER_TO, :NEW.S1_TASK_PERSON_ID, :NEW.S1_AREA_ID, :NEW.S1_START_TIME
         , :NEW.S1_DESCR, :NEW.S2_DESCR_BEFORE, :NEW.S2_DESCR_AFTER, :NEW.S3_RAD_ID
         , :NEW.S3_RAD_DATE, :NEW.S3_RAD_MODIFIED_BY, :NEW.S3_SSO_ID, :NEW.S3_SSO_DATE
         , :NEW.S3_SSO_MODIFIED_BY, :NEW.S3_AREA_MGR_ID, :NEW.S3_AREA_MGR_DATE, :NEW.S3_AREA_MGR_MODIFIED_BY
         , :NEW.S3_TASK_PERSON_ACK_ID, :NEW.S3_TASK_PERSON_ACK_DATE, :NEW.S3_TASK_PERSON_ACK_MODIFIED_BY, :NEW.S4_OPERATOR_ID
         , :NEW.S4_OPERATOR_DATE, :NEW.S4_OPERATOR_MODIFIED_BY, :NEW.S4_WRKR_ID, :NEW.S4_WRKR_DATE
         , :NEW.S4_WRKR_MODIFIED_BY, :NEW.S5_TASK_PERSON_CHK, :NEW.S5_TASK_PERSON_COMMENTS, :NEW.S5_TASK_PERSON_ACK_ID
         , :NEW.S5_TASK_PERSON_ACK_DATE, :NEW.S5_TASK_PERSON_ACK_MODIFIED_BY, :NEW.S5_PPS_CHK, :NEW.S5_PPS_COMMENTS
         , :NEW.S5_PPS_ID, :NEW.S5_PPS_DATE, :NEW.S5_PPS_MODIFIED_BY, :NEW.S5_RAD_CHK
         , :NEW.S5_RAD_COMMENTS, :NEW.S5_RAD_ID, :NEW.S5_RAD_DATE, :NEW.S5_RAD_MODIFIED_BY
         , :NEW.S5_OPERATOR_CHK, :NEW.S5_OPERATOR_COMMENTS, :NEW.S5_OPERATOR_ID, :NEW.S5_OPERATOR_DATE
         , :NEW.S5_OPERATOR_MODIFIED_BY, :NEW.S5_RPFO_CHK, :NEW.S5_RPFO_COMMENTS, :NEW.S5_RPFO_ID
         , :NEW.S5_RPFO_DATE, :NEW.S5_RPFO_MODIFIED_BY
         , :NEW.S5_OTHER1_CHK, :NEW.S5_OTHER1_ID, :NEW.S5_OTHER1_COMMENTS, :NEW.S5_OTHER1_ACK_ID
         , :NEW.S5_OTHER1_ACK_DATE, :NEW.S5_OTHER1_ACK_MODIFIED_BY, :NEW.S5_OTHER2_CHK, :NEW.S5_OTHER2_ID
         , :NEW.S5_OTHER2_COMMENTS, :NEW.S5_OTHER2_ACK_ID, :NEW.S5_OTHER2_ACK_DATE, :NEW.S5_OTHER2_ACK_MODIFIED_BY
         , :NEW.S5_OTHER3_CHK, :NEW.S5_OTHER3_ID, :NEW.S5_OTHER3_COMMENTS, :NEW.S5_OTHER3_ACK_ID
         , :NEW.S5_OTHER3_ACK_DATE, :NEW.S5_OTHER3_ACK_MODIFIED_BY, :NEW.S6_SSO_ID, :NEW.S6_SSO_DATE
         , :NEW.S6_SSO_MODIFIED_BY, :NEW.S6_OPERATOR_ID, :NEW.S6_OPERATOR_DATE, :NEW.S6_OPERATOR_MODIFIED_BY
         , :NEW.FOLLOWUP_COMMENTS, :NEW.POST_CLOSURE_COMMENTS, :NEW.CREATED_BY, :NEW.CREATED_DATE
         , :NEW.MODIFIED_BY, :NEW.MODIFIED_DATE
	 , :NEW.S4_ASSIGN_WRKR_ID, :NEW.S4_ASSIGN_WRKR_DATE, :NEW.S4_ASSIGN_WRKR_MODIFIED_BY, :NEW.DROP_FORM_CHK
         );
     END IF;
     IF DELETING THEN
         INSERT INTO SSRL_RSW_FORM_JN
         ( JN_OPERATION, JN_ORACLE_USER, JN_DATETIME, JN_NOTES, JN_APPLN, JN_SESSION
         , SSRL_FORM_ID, S1_PRELIM_1, S1_PRELIM_2
         , FORM_STATUS_ID, EMAIL_CHK, EMAIL_RULE, SSRL_FORM_ID_TRANSFER_FROM
         , SSRL_FORM_ID_TRANSFER_TO, S1_TASK_PERSON_ID, S1_AREA_ID, S1_START_TIME
         , S1_DESCR, S2_DESCR_BEFORE, S2_DESCR_AFTER, S3_RAD_ID
         , S3_RAD_DATE, S3_RAD_MODIFIED_BY, S3_SSO_ID, S3_SSO_DATE
         , S3_SSO_MODIFIED_BY, S3_AREA_MGR_ID, S3_AREA_MGR_DATE, S3_AREA_MGR_MODIFIED_BY
         , S3_TASK_PERSON_ACK_ID, S3_TASK_PERSON_ACK_DATE, S3_TASK_PERSON_ACK_MODIFIED_BY, S4_OPERATOR_ID
         , S4_OPERATOR_DATE, S4_OPERATOR_MODIFIED_BY, S4_WRKR_ID, S4_WRKR_DATE
         , S4_WRKR_MODIFIED_BY, S5_TASK_PERSON_CHK, S5_TASK_PERSON_COMMENTS, S5_TASK_PERSON_ACK_ID
         , S5_TASK_PERSON_ACK_DATE, S5_TASK_PERSON_ACK_MODIFIED_BY, S5_PPS_CHK, S5_PPS_COMMENTS
         , S5_PPS_ID, S5_PPS_DATE, S5_PPS_MODIFIED_BY, S5_RAD_CHK
         , S5_RAD_COMMENTS, S5_RAD_ID, S5_RAD_DATE, S5_RAD_MODIFIED_BY
         , S5_OPERATOR_CHK, S5_OPERATOR_COMMENTS, S5_OPERATOR_ID, S5_OPERATOR_DATE
         , S5_OPERATOR_MODIFIED_BY, S5_RPFO_CHK, S5_RPFO_COMMENTS, S5_RPFO_ID
         , S5_RPFO_DATE, S5_RPFO_MODIFIED_BY
         , S5_OTHER1_CHK, S5_OTHER1_ID, S5_OTHER1_COMMENTS, S5_OTHER1_ACK_ID
         , S5_OTHER1_ACK_DATE, S5_OTHER1_ACK_MODIFIED_BY, S5_OTHER2_CHK, S5_OTHER2_ID
         , S5_OTHER2_COMMENTS, S5_OTHER2_ACK_ID, S5_OTHER2_ACK_DATE, S5_OTHER2_ACK_MODIFIED_BY
         , S5_OTHER3_CHK, S5_OTHER3_ID, S5_OTHER3_COMMENTS, S5_OTHER3_ACK_ID
         , S5_OTHER3_ACK_DATE, S5_OTHER3_ACK_MODIFIED_BY, S6_SSO_ID, S6_SSO_DATE
         , S6_SSO_MODIFIED_BY, S6_OPERATOR_ID, S6_OPERATOR_DATE, S6_OPERATOR_MODIFIED_BY
         , FOLLOWUP_COMMENTS, POST_CLOSURE_COMMENTS, CREATED_BY, CREATED_DATE
         , MODIFIED_BY, MODIFIED_DATE
	 , S4_ASSIGN_WRKR_ID, S4_ASSIGN_WRKR_DATE, S4_ASSIGN_WRKR_MODIFIED_BY, DROP_FORM_CHK
         ) VALUES (jn_operation, NVL(V('APP_USER'),USER), SYSDATE, NULL, NULL,userenv('sessionid')
         , :OLD.SSRL_FORM_ID, :OLD.S1_PRELIM_1, :OLD.S1_PRELIM_2
         , :OLD.FORM_STATUS_ID, :OLD.EMAIL_CHK, :OLD.EMAIL_RULE, :OLD.SSRL_FORM_ID_TRANSFER_FROM
         , :OLD.SSRL_FORM_ID_TRANSFER_TO, :OLD.S1_TASK_PERSON_ID, :OLD.S1_AREA_ID, :OLD.S1_START_TIME
         , :OLD.S1_DESCR, :OLD.S2_DESCR_BEFORE, :OLD.S2_DESCR_AFTER, :OLD.S3_RAD_ID
         , :OLD.S3_RAD_DATE, :OLD.S3_RAD_MODIFIED_BY, :OLD.S3_SSO_ID, :OLD.S3_SSO_DATE
         , :OLD.S3_SSO_MODIFIED_BY, :OLD.S3_AREA_MGR_ID, :OLD.S3_AREA_MGR_DATE, :OLD.S3_AREA_MGR_MODIFIED_BY
         , :OLD.S3_TASK_PERSON_ACK_ID, :OLD.S3_TASK_PERSON_ACK_DATE, :OLD.S3_TASK_PERSON_ACK_MODIFIED_BY, :OLD.S4_OPERATOR_ID
         , :OLD.S4_OPERATOR_DATE, :OLD.S4_OPERATOR_MODIFIED_BY, :OLD.S4_WRKR_ID, :OLD.S4_WRKR_DATE
         , :OLD.S4_WRKR_MODIFIED_BY, :OLD.S5_TASK_PERSON_CHK, :OLD.S5_TASK_PERSON_COMMENTS, :OLD.S5_TASK_PERSON_ACK_ID
         , :OLD.S5_TASK_PERSON_ACK_DATE, :OLD.S5_TASK_PERSON_ACK_MODIFIED_BY, :OLD.S5_PPS_CHK, :OLD.S5_PPS_COMMENTS
         , :OLD.S5_PPS_ID, :OLD.S5_PPS_DATE, :OLD.S5_PPS_MODIFIED_BY, :OLD.S5_RAD_CHK
         , :OLD.S5_RAD_COMMENTS, :OLD.S5_RAD_ID, :OLD.S5_RAD_DATE, :OLD.S5_RAD_MODIFIED_BY
         , :OLD.S5_OPERATOR_CHK, :OLD.S5_OPERATOR_COMMENTS, :OLD.S5_OPERATOR_ID, :OLD.S5_OPERATOR_DATE
         , :OLD.S5_OPERATOR_MODIFIED_BY, :OLD.S5_RPFO_CHK, :OLD.S5_RPFO_COMMENTS, :OLD.S5_RPFO_ID
         , :OLD.S5_RPFO_DATE, :OLD.S5_RPFO_MODIFIED_BY
         , :OLD.S5_OTHER1_CHK, :OLD.S5_OTHER1_ID, :OLD.S5_OTHER1_COMMENTS, :OLD.S5_OTHER1_ACK_ID
         , :OLD.S5_OTHER1_ACK_DATE, :OLD.S5_OTHER1_ACK_MODIFIED_BY, :OLD.S5_OTHER2_CHK, :OLD.S5_OTHER2_ID
         , :OLD.S5_OTHER2_COMMENTS, :OLD.S5_OTHER2_ACK_ID, :OLD.S5_OTHER2_ACK_DATE, :OLD.S5_OTHER2_ACK_MODIFIED_BY
         , :OLD.S5_OTHER3_CHK, :OLD.S5_OTHER3_ID, :OLD.S5_OTHER3_COMMENTS, :OLD.S5_OTHER3_ACK_ID
         , :OLD.S5_OTHER3_ACK_DATE, :OLD.S5_OTHER3_ACK_MODIFIED_BY, :OLD.S6_SSO_ID, :OLD.S6_SSO_DATE
         , :OLD.S6_SSO_MODIFIED_BY, :OLD.S6_OPERATOR_ID, :OLD.S6_OPERATOR_DATE, :OLD.S6_OPERATOR_MODIFIED_BY
         , :OLD.FOLLOWUP_COMMENTS, :OLD.POST_CLOSURE_COMMENTS, :OLD.CREATED_BY, :OLD.CREATED_DATE
         , :OLD.MODIFIED_BY, :OLD.MODIFIED_DATE
	 , :OLD.S4_ASSIGN_WRKR_ID, :OLD.S4_ASSIGN_WRKR_DATE, :OLD.S4_ASSIGN_WRKR_MODIFIED_BY, :OLD.DROP_FORM_CHK
	);
         END IF;
END;
/
ALTER TRIGGER "MCC_MAINT"."SSRL_RSW_FORM_AIUDR" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SSRL_RSW_FORM_MESSAGES_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "MCC_MAINT"."SSRL_RSW_FORM_MESSAGES_TRG" 
AFTER INSERT OR UPDATE ON SSRL_RSW_FORM FOR EACH ROW
declare
    c_proc          constant varchar2(100) := 'SSRL_RSW_FORM_MESSAGES_TRG ';

    l_apex_url_prefix            varchar2(100);
    l_instance                   varchar2(100) := 'slacprod';

    l_form_url   varchar2(1000);-- := 'https://oraweb.slac.stanford.edu/apex/' || pi_instance || '/f?p=273:3:::NO:2:P3_SSRL_FORM_ID:' || l_form_rec_new.ssrl_form_id;

--	l_instance		varchar2(100);
	l_url_prefix		varchar2(200);
	l_edit_url              varchar2(1000);
	l_edit_link             varchar2(1000);

	l_form_rec_new           SSRL_RSW_FORM%rowtype;
	l_form_rec_old           SSRL_RSW_FORM%rowtype;
	l_operation              varchar2(1);
	l_changer_email          varchar2(100);
	l_message_type           varchar2(10);
	l_form_id	number;
	l_page_name	varchar2(500);
	l_descr		varchar2(200);
	l_subject	varchar2(500);
	l_body		varchar2(1000);
	l_email_to	varchar2(1000);
	l_email_other	varchar2(1000);
	l_email_to_final	varchar2(1000);

	l_email_to_s1_old_task_person	varchar2(50);
	l_email_to_s1_new_task_person	varchar2(50);
	l_email_to_s3_sso	varchar2(50);
	l_email_to_s3_am	varchar2(50);
	l_email_to_s3_rp	varchar2(50);
	l_email_to_s4_do	varchar2(50);
	l_s4_new_assign_wrkr	varchar2(50);
	l_email_to_s4_new_assign_wrkr	varchar2(50);
	l_email_to_s4_old_assign_wrkr	varchar2(50);
	l_email_to_s4_wrkr	varchar2(50);
	l_email_to_s5_rp	varchar2(50);
	l_email_to_s5_rpfo	varchar2(50);
	l_email_to_s5_pps	varchar2(50);
	l_email_to_s5_do	varchar2(50);
	l_email_to_s6_do	varchar2(50);
	l_email_to_s6_sso	varchar2(50);
	l_email_to_other1	varchar2(50);
	l_email_to_other2	varchar2(50);
	l_email_to_other3	varchar2(50);
	l_email_to_other1_ack	varchar2(50);
	l_email_to_other2_ack	varchar2(50);
	l_email_to_other3_ack	varchar2(50);

	l_email_to_bldo		varchar2(50);
	l_email_to_ops		varchar2(50);
	l_email_to_s3		varchar2(500);
	l_email_to_s4		varchar2(500);
	l_email_to_s5		varchar2(500);
	l_email_to_s6		varchar2(500);
	l_email_to_sso_grp	varchar2(500);
	l_email_to_am_grp	varchar2(500);
	l_email_to_rp_grp	varchar2(500);
	l_email_to_rpfo_grp	varchar2(500);
	l_email_to_pps_grp	varchar2(500);
	l_email_id		number;
	l_email_flag		number(2) := 0;
	l_created_by		PERSONS.PERSON.NAME%TYPE;
	l_created_by_email	varchar2(50) := NULL;
	l_modified_by		PERSONS.PERSON.NAME%TYPE;
	l_modified_by_email	varchar2(50) := NULL;
	l_old_form_status	SSRL_RSW_FORM_STATUS.STATUS%TYPE;
	l_new_form_status	SSRL_RSW_FORM_STATUS.STATUS%TYPE;

begin

    apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'begin');

	l_form_rec_new.SSRL_FORM_ID	:=	:new.SSRL_FORM_ID;
	l_form_rec_new.S1_PRELIM_1	:=	:new.S1_PRELIM_1;
	l_form_rec_new.S1_PRELIM_2	:=	:new.S1_PRELIM_2;
	l_form_rec_new.FORM_STATUS_ID	:=	:new.FORM_STATUS_ID;
	l_form_rec_new.EMAIL_CHK	:=	:new.EMAIL_CHK;
	l_form_rec_new.S1_TASK_PERSON_ID	:=	:new.S1_TASK_PERSON_ID;
	l_form_rec_new.S1_AREA_ID	:=	:new.S1_AREA_ID;
	l_form_rec_new.S1_START_TIME	:=	:new.S1_START_TIME;
	l_form_rec_new.S1_DESCR	:=	:new.S1_DESCR;
	l_form_rec_new.S2_DESCR_BEFORE	:=	:new.S2_DESCR_BEFORE;
	l_form_rec_new.S2_DESCR_AFTER	:=	:new.S2_DESCR_AFTER;
	l_form_rec_new.S3_TASK_PERSON_ACK_ID	:=	:new.S3_TASK_PERSON_ACK_ID;
	l_form_rec_new.S3_TASK_PERSON_ACK_DATE	:=	:new.S3_TASK_PERSON_ACK_DATE;
	l_form_rec_new.S3_TASK_PERSON_ACK_MODIFIED_BY	:=	:new.S3_TASK_PERSON_ACK_MODIFIED_BY;
	l_form_rec_new.S3_AREA_MGR_ID	:=	:new.S3_AREA_MGR_ID;
	l_form_rec_new.S3_AREA_MGR_DATE	:=	:new.S3_AREA_MGR_DATE;
	l_form_rec_new.S3_AREA_MGR_MODIFIED_BY	:=	:new.S3_AREA_MGR_MODIFIED_BY;
	l_form_rec_new.S3_RAD_ID	:=	:new.S3_RAD_ID;
	l_form_rec_new.S3_RAD_DATE	:=	:new.S3_RAD_DATE;
	l_form_rec_new.S3_RAD_MODIFIED_BY	:=	:new.S3_RAD_MODIFIED_BY;
	l_form_rec_new.S3_SSO_ID	:=	:new.S3_SSO_ID;
	l_form_rec_new.S3_SSO_DATE	:=	:new.S3_SSO_DATE;
	l_form_rec_new.S3_SSO_MODIFIED_BY	:=	:new.S3_SSO_MODIFIED_BY;
	l_form_rec_new.S4_OPERATOR_ID	:=	:new.S4_OPERATOR_ID;
	l_form_rec_new.S4_OPERATOR_DATE	:=	:new.S4_OPERATOR_DATE;
	l_form_rec_new.S4_OPERATOR_MODIFIED_BY	:=	:new.S4_OPERATOR_MODIFIED_BY;
	l_form_rec_new.S4_ASSIGN_WRKR_ID	:=	:new.S4_ASSIGN_WRKR_ID;
	l_form_rec_new.S4_ASSIGN_WRKR_DATE	:=	:new.S4_ASSIGN_WRKR_DATE;
	l_form_rec_new.S4_ASSIGN_WRKR_MODIFIED_BY	:=	:new.S4_ASSIGN_WRKR_MODIFIED_BY;
	l_form_rec_new.S4_WRKR_ID	:=	:new.S4_WRKR_ID;
	l_form_rec_new.S4_WRKR_DATE	:=	:new.S4_WRKR_DATE;
	l_form_rec_new.S4_WRKR_MODIFIED_BY	:=	:new.S4_WRKR_MODIFIED_BY;
	l_form_rec_new.S5_PPS_ID	:=	:new.S5_PPS_ID;
	l_form_rec_new.S5_PPS_DATE	:=	:new.S5_PPS_DATE;
	l_form_rec_new.S5_PPS_MODIFIED_BY	:=	:new.S5_PPS_MODIFIED_BY;
	l_form_rec_new.S5_RAD_ID	:=	:new.S5_RAD_ID;
	l_form_rec_new.S5_RAD_DATE	:=	:new.S5_RAD_DATE;
	l_form_rec_new.S5_RAD_MODIFIED_BY	:=	:new.S5_RAD_MODIFIED_BY;
	l_form_rec_new.S5_OPERATOR_ID	:=	:new.S5_OPERATOR_ID;
	l_form_rec_new.S5_OPERATOR_DATE	:=	:new.S5_OPERATOR_DATE;
	l_form_rec_new.S5_OPERATOR_MODIFIED_BY	:=	:new.S5_OPERATOR_MODIFIED_BY;
	l_form_rec_new.S5_OTHER1_ACK_ID	:=	:new.S5_OTHER1_ACK_ID;
	l_form_rec_new.S5_OTHER1_ACK_DATE	:=	:new.S5_OTHER1_ACK_DATE;
	l_form_rec_new.S5_OTHER1_ACK_MODIFIED_BY	:=	:new.S5_OTHER1_ACK_MODIFIED_BY;
	l_form_rec_new.S6_SSO_ID	:=	:new.S6_SSO_ID;
	l_form_rec_new.S6_SSO_DATE	:=	:new.S6_SSO_DATE;
	l_form_rec_new.S6_SSO_MODIFIED_BY	:=	:new.S6_SSO_MODIFIED_BY;
	l_form_rec_new.S6_OPERATOR_ID	:=	:new.S6_OPERATOR_ID;
	l_form_rec_new.S6_OPERATOR_DATE	:=	:new.S6_OPERATOR_DATE;
	l_form_rec_new.S6_OPERATOR_MODIFIED_BY	:=	:new.S6_OPERATOR_MODIFIED_BY;
	l_form_rec_new.CREATED_BY	:=	:new.CREATED_BY;
	l_form_rec_new.CREATED_DATE	:=	:new.CREATED_DATE;
	l_form_rec_new.MODIFIED_BY	:=	:new.MODIFIED_BY;
	l_form_rec_new.MODIFIED_DATE	:=	:new.MODIFIED_DATE;
	l_form_rec_new.S5_TASK_PERSON_CHK	:=	:new.S5_TASK_PERSON_CHK;
	l_form_rec_new.S5_PPS_CHK	:=	:new.S5_PPS_CHK;
	l_form_rec_new.S5_RAD_CHK	:=	:new.S5_RAD_CHK;
	l_form_rec_new.S5_OPERATOR_CHK	:=	:new.S5_OPERATOR_CHK;
	l_form_rec_new.S5_OTHER1_CHK	:=	:new.S5_OTHER1_CHK;
	l_form_rec_new.S5_TASK_PERSON_ACK_ID	:=	:new.S5_TASK_PERSON_ACK_ID;
	l_form_rec_new.S5_TASK_PERSON_ACK_DATE	:=	:new.S5_TASK_PERSON_ACK_DATE;
	l_form_rec_new.S5_TASK_PERSON_ACK_MODIFIED_BY	:=	:new.S5_TASK_PERSON_ACK_MODIFIED_BY;
	l_form_rec_new.FOLLOWUP_COMMENTS	:=	:new.FOLLOWUP_COMMENTS;
	l_form_rec_new.S5_OTHER1_COMMENTS	:=	:new.S5_OTHER1_COMMENTS;
	l_form_rec_new.S5_OTHER1_ID	:=	:new.S5_OTHER1_ID;
	l_form_rec_new.S5_RPFO_CHK	:=	:new.S5_RPFO_CHK;
	l_form_rec_new.S5_RPFO_ID	:=	:new.S5_RPFO_ID;
	l_form_rec_new.S5_RPFO_DATE	:=	:new.S5_RPFO_DATE;
	l_form_rec_new.S5_RPFO_MODIFIED_BY	:=	:new.S5_RPFO_MODIFIED_BY;
	l_form_rec_new.EMAIL_RULE	:= 	:new.EMAIL_RULE;
	l_form_rec_new.S5_TASK_PERSON_COMMENTS	:= 	:new.S5_TASK_PERSON_COMMENTS;
	l_form_rec_new.S5_PPS_COMMENTS	:= 	:new.S5_PPS_COMMENTS;
	l_form_rec_new.S5_RAD_COMMENTS	:= 	:new.S5_RAD_COMMENTS;
	l_form_rec_new.S5_OPERATOR_COMMENTS	:= 	:new.S5_OPERATOR_COMMENTS;
	l_form_rec_new.S5_RPFO_COMMENTS	:= 	:new.S5_RPFO_COMMENTS;
	l_form_rec_new.POST_CLOSURE_COMMENTS	:= 	:new.POST_CLOSURE_COMMENTS;
	l_form_rec_new.SSRL_FORM_ID_TRANSFER_FROM	:= 	:new.SSRL_FORM_ID_TRANSFER_FROM;
	l_form_rec_new.SSRL_FORM_ID_TRANSFER_TO	:= 	:new.SSRL_FORM_ID_TRANSFER_TO;
	l_form_rec_new.S5_OTHER2_CHK :=  :new.S5_OTHER2_CHK;
	l_form_rec_new.S5_OTHER2_ID :=  :new.S5_OTHER2_ID;
	l_form_rec_new.S5_OTHER2_COMMENTS :=  :new.S5_OTHER2_COMMENTS;
	l_form_rec_new.S5_OTHER2_ACK_ID :=  :new.S5_OTHER2_ACK_ID;
	l_form_rec_new.S5_OTHER2_ACK_DATE :=  :new.S5_OTHER2_ACK_DATE;
	l_form_rec_new.S5_OTHER2_ACK_MODIFIED_BY :=  :new.S5_OTHER2_ACK_MODIFIED_BY;
	l_form_rec_new.S5_OTHER3_CHK :=  :new.S5_OTHER3_CHK;
	l_form_rec_new.S5_OTHER3_ID :=  :new.S5_OTHER3_ID;
	l_form_rec_new.S5_OTHER3_COMMENTS :=  :new.S5_OTHER3_COMMENTS;
	l_form_rec_new.S5_OTHER3_ACK_ID :=  :new.S5_OTHER3_ACK_ID;
	l_form_rec_new.S5_OTHER3_ACK_DATE :=  :new.S5_OTHER3_ACK_DATE;
	l_form_rec_new.S5_OTHER3_ACK_MODIFIED_BY :=  :new.S5_OTHER3_ACK_MODIFIED_BY;

	if inserting
	then
		l_operation := 'I';
		l_changer_email := lower(:new.created_by) || '@' || 'slac.stanford.edu';
	elsif updating
	then
		l_operation := 'U';
		l_changer_email := lower(:new.modified_by) || '@' || 'slac.stanford.edu';
		l_form_rec_old.SSRL_FORM_ID	:=	:old.SSRL_FORM_ID;
		l_form_rec_old.S1_PRELIM_1	:=	:old.S1_PRELIM_1;
		l_form_rec_old.S1_PRELIM_2	:=	:old.S1_PRELIM_2;
		l_form_rec_old.FORM_STATUS_ID	:=	:old.FORM_STATUS_ID;
		l_form_rec_old.EMAIL_CHK	:=	:old.EMAIL_CHK;
		l_form_rec_old.S1_TASK_PERSON_ID	:=	:old.S1_TASK_PERSON_ID;
		l_form_rec_old.S1_AREA_ID	:=	:old.S1_AREA_ID;
		l_form_rec_old.S1_START_TIME	:=	:old.S1_START_TIME;
		l_form_rec_old.S1_DESCR	:=	:old.S1_DESCR;
		l_form_rec_old.S2_DESCR_BEFORE	:=	:old.S2_DESCR_BEFORE;
		l_form_rec_old.S2_DESCR_AFTER	:=	:old.S2_DESCR_AFTER;
		l_form_rec_old.S3_TASK_PERSON_ACK_ID	:=	:old.S3_TASK_PERSON_ACK_ID;
		l_form_rec_old.S3_TASK_PERSON_ACK_DATE	:=	:old.S3_TASK_PERSON_ACK_DATE;
		l_form_rec_old.S3_TASK_PERSON_ACK_MODIFIED_BY	:=	:old.S3_TASK_PERSON_ACK_MODIFIED_BY;
		l_form_rec_old.S3_AREA_MGR_ID	:=	:old.S3_AREA_MGR_ID;
		l_form_rec_old.S3_AREA_MGR_DATE	:=	:old.S3_AREA_MGR_DATE;
		l_form_rec_old.S3_AREA_MGR_MODIFIED_BY	:=	:old.S3_AREA_MGR_MODIFIED_BY;
		l_form_rec_old.S3_RAD_ID	:=	:old.S3_RAD_ID;
		l_form_rec_old.S3_RAD_DATE	:=	:old.S3_RAD_DATE;
		l_form_rec_old.S3_RAD_MODIFIED_BY	:=	:old.S3_RAD_MODIFIED_BY;
		l_form_rec_old.S3_SSO_ID	:=	:old.S3_SSO_ID;
		l_form_rec_old.S3_SSO_DATE	:=	:old.S3_SSO_DATE;
		l_form_rec_old.S3_SSO_MODIFIED_BY	:=	:old.S3_SSO_MODIFIED_BY;
		l_form_rec_old.S4_OPERATOR_ID	:=	:old.S4_OPERATOR_ID;
		l_form_rec_old.S4_OPERATOR_DATE	:=	:old.S4_OPERATOR_DATE;
		l_form_rec_old.S4_OPERATOR_MODIFIED_BY	:=	:old.S4_OPERATOR_MODIFIED_BY;
		l_form_rec_old.S4_ASSIGN_WRKR_ID	:=	:old.S4_ASSIGN_WRKR_ID;
		l_form_rec_old.S4_ASSIGN_WRKR_DATE	:=	:old.S4_ASSIGN_WRKR_DATE;
		l_form_rec_old.S4_ASSIGN_WRKR_MODIFIED_BY	:=	:old.S4_ASSIGN_WRKR_MODIFIED_BY;
		l_form_rec_old.S4_WRKR_ID	:=	:old.S4_WRKR_ID;
		l_form_rec_old.S4_WRKR_DATE	:=	:old.S4_WRKR_DATE;
		l_form_rec_old.S4_WRKR_MODIFIED_BY	:=	:old.S4_WRKR_MODIFIED_BY;
		l_form_rec_old.S5_PPS_ID	:=	:old.S5_PPS_ID;
		l_form_rec_old.S5_PPS_DATE	:=	:old.S5_PPS_DATE;
		l_form_rec_old.S5_PPS_MODIFIED_BY	:=	:old.S5_PPS_MODIFIED_BY;
		l_form_rec_old.S5_RAD_ID	:=	:old.S5_RAD_ID;
		l_form_rec_old.S5_RAD_DATE	:=	:old.S5_RAD_DATE;
		l_form_rec_old.S5_RAD_MODIFIED_BY	:=	:old.S5_RAD_MODIFIED_BY;
		l_form_rec_old.S5_OPERATOR_ID	:=	:old.S5_OPERATOR_ID;
		l_form_rec_old.S5_OPERATOR_DATE	:=	:old.S5_OPERATOR_DATE;
		l_form_rec_old.S5_OPERATOR_MODIFIED_BY	:=	:old.S5_OPERATOR_MODIFIED_BY;
		l_form_rec_old.S5_OTHER1_ACK_ID	:=	:old.S5_OTHER1_ACK_ID;
		l_form_rec_old.S5_OTHER1_ACK_DATE	:=	:old.S5_OTHER1_ACK_DATE;
		l_form_rec_old.S5_OTHER1_ACK_MODIFIED_BY	:=	:old.S5_OTHER1_ACK_MODIFIED_BY;
		l_form_rec_old.S6_SSO_ID	:=	:old.S6_SSO_ID;
		l_form_rec_old.S6_SSO_DATE	:=	:old.S6_SSO_DATE;
		l_form_rec_old.S6_SSO_MODIFIED_BY	:=	:old.S6_SSO_MODIFIED_BY;
		l_form_rec_old.S6_OPERATOR_ID	:=	:old.S6_OPERATOR_ID;
		l_form_rec_old.S6_OPERATOR_DATE	:=	:old.S6_OPERATOR_DATE;
		l_form_rec_old.S6_OPERATOR_MODIFIED_BY	:=	:old.S6_OPERATOR_MODIFIED_BY;
		l_form_rec_old.CREATED_BY	:=	:old.CREATED_BY;
		l_form_rec_old.CREATED_DATE	:=	:old.CREATED_DATE;
		l_form_rec_old.MODIFIED_BY	:=	:old.MODIFIED_BY;
		l_form_rec_old.MODIFIED_DATE	:=	:old.MODIFIED_DATE;
		l_form_rec_old.S5_TASK_PERSON_CHK	:=	:old.S5_TASK_PERSON_CHK;
		l_form_rec_old.S5_PPS_CHK	:=	:old.S5_PPS_CHK;
		l_form_rec_old.S5_RAD_CHK	:=	:old.S5_RAD_CHK;
		l_form_rec_old.S5_OPERATOR_CHK	:=	:old.S5_OPERATOR_CHK;
		l_form_rec_old.S5_OTHER1_CHK	:=	:old.S5_OTHER1_CHK;
		l_form_rec_old.S5_TASK_PERSON_ACK_ID	:=	:old.S5_TASK_PERSON_ACK_ID;
		l_form_rec_old.S5_TASK_PERSON_ACK_DATE	:=	:old.S5_TASK_PERSON_ACK_DATE;
		l_form_rec_old.S5_TASK_PERSON_ACK_MODIFIED_BY	:=	:old.S5_TASK_PERSON_ACK_MODIFIED_BY;
		l_form_rec_old.FOLLOWUP_COMMENTS	:=	:old.FOLLOWUP_COMMENTS;
		l_form_rec_old.S5_OTHER1_COMMENTS	:=	:old.S5_OTHER1_COMMENTS;
		l_form_rec_old.S5_OTHER1_ID	:=	:old.S5_OTHER1_ID;
		l_form_rec_old.S5_RPFO_CHK	:=	:old.S5_RPFO_CHK;
		l_form_rec_old.S5_RPFO_ID	:=	:old.S5_RPFO_ID;
		l_form_rec_old.S5_RPFO_DATE	:=	:old.S5_RPFO_DATE;
		l_form_rec_old.S5_RPFO_MODIFIED_BY	:=	:old.S5_RPFO_MODIFIED_BY;
		l_form_rec_old.EMAIL_RULE	:= 	:old.EMAIL_RULE;
		l_form_rec_old.S5_TASK_PERSON_COMMENTS	:= 	:old.S5_TASK_PERSON_COMMENTS;
		l_form_rec_old.S5_PPS_COMMENTS	:= 	:old.S5_PPS_COMMENTS;
		l_form_rec_old.S5_RAD_COMMENTS	:= 	:old.S5_RAD_COMMENTS;
		l_form_rec_old.S5_OPERATOR_COMMENTS	:= 	:old.S5_OPERATOR_COMMENTS;
		l_form_rec_old.S5_RPFO_COMMENTS	:= 	:old.S5_RPFO_COMMENTS;
		l_form_rec_old.POST_CLOSURE_COMMENTS	:= 	:old.POST_CLOSURE_COMMENTS;
		l_form_rec_old.SSRL_FORM_ID_TRANSFER_FROM	:= 	:old.SSRL_FORM_ID_TRANSFER_FROM;
		l_form_rec_old.SSRL_FORM_ID_TRANSFER_TO	:= 	:old.SSRL_FORM_ID_TRANSFER_TO;
		l_form_rec_old.S5_OTHER2_CHK :=  :old.S5_OTHER2_CHK;
		l_form_rec_old.S5_OTHER2_ID :=  :old.S5_OTHER2_ID;
		l_form_rec_old.S5_OTHER2_COMMENTS :=  :old.S5_OTHER2_COMMENTS;
		l_form_rec_old.S5_OTHER2_ACK_ID :=  :old.S5_OTHER2_ACK_ID;
		l_form_rec_old.S5_OTHER2_ACK_DATE :=  :old.S5_OTHER2_ACK_DATE;
		l_form_rec_old.S5_OTHER2_ACK_MODIFIED_BY :=  :old.S5_OTHER2_ACK_MODIFIED_BY;
		l_form_rec_old.S5_OTHER3_CHK :=  :old.S5_OTHER3_CHK;
		l_form_rec_old.S5_OTHER3_ID :=  :old.S5_OTHER3_ID;
		l_form_rec_old.S5_OTHER3_COMMENTS :=  :old.S5_OTHER3_COMMENTS;
		l_form_rec_old.S5_OTHER3_ACK_ID :=  :old.S5_OTHER3_ACK_ID;
		l_form_rec_old.S5_OTHER3_ACK_DATE :=  :old.S5_OTHER3_ACK_DATE;
		l_form_rec_old.S5_OTHER3_ACK_MODIFIED_BY :=  :old.S5_OTHER3_ACK_MODIFIED_BY;


	end if;
    --
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ',l_operation= '||l_operation||', EMAIL_RULE= '||:new.EMAIL_RULE||', EMAIL_CHK= '||:new.EMAIL_CHK);
     begin
        select name, maildisp
          into l_created_by, l_created_by_email
          from persons.person
         where key in (select max(but_sid) from but 
                        where upper(but_kid) = :new.CREATED_BY);
     exception
       when no_data_found then 
         l_created_by := 'UnAssigned';
         l_created_by_email := NULL;
       when others then raise;
     end;
    --
     begin
        select name, maildisp
          into l_modified_by, l_modified_by_email
          from persons.person
         where key in (select max(but_sid) from but 
                        where upper(but_kid) = :new.MODIFIED_BY);
     exception
       when no_data_found then 
         l_modified_by := Null;
         l_modified_by_email := NULL;
       when others then raise;
     end;
    --
	l_form_id := l_form_rec_new.SSRL_FORM_ID;
	l_email_to_sso_grp := ssrl_rsw_pkg.email_addresses('SSO');
	l_email_to_am_grp := ssrl_rsw_pkg.email_addresses('AREA MANAGER');
	l_email_to_rp_grp := ssrl_rsw_pkg.email_addresses('RP');
	l_email_to_rpfo_grp := ssrl_rsw_pkg.email_addresses('RPFO');
	l_email_to_pps_grp := ssrl_rsw_pkg.email_addresses('PPS');

	l_email_to_bldo := 'ssrl-bldo@slac.stanford.edu';
	l_email_to_ops := 'spearops@slac.stanford.edu';

	l_email_to_s3_rp := getval('EMAIL_ID',l_form_rec_new.S3_RAD_ID);
	l_email_to_s3_sso := getval('EMAIL_ID',l_form_rec_new.S3_SSO_ID);
	l_email_to_s3_am := getval('EMAIL_ID',l_form_rec_new.S3_AREA_MGR_ID);

	l_email_to_s4_do  := getval('EMAIL_ID',l_form_rec_new.S4_OPERATOR_ID);
	l_email_to_s4_wrkr := getval('EMAIL_ID', l_form_rec_new.S4_WRKR_ID);

	l_email_to_s5_rp := getval('EMAIL_ID',l_form_rec_new.S5_RAD_ID);
	l_email_to_s5_rpfo := getval('EMAIL_ID',l_form_rec_new.S5_RPFO_ID);
	l_email_to_s5_pps := getval('EMAIL_ID',l_form_rec_new.S5_PPS_ID);
	l_email_to_s5_do := getval('EMAIL_ID',l_form_rec_new.S5_OPERATOR_ID);
	l_email_to_s6_do := getval('EMAIL_ID',l_form_rec_new.S6_OPERATOR_ID);
	l_email_to_s6_sso := getval('EMAIL_ID',l_form_rec_new.S6_SSO_ID);

	l_email_to_s1_old_task_person := getval('EMAIL_ID', l_form_rec_old.S1_TASK_PERSON_ID);
	l_email_to_s1_new_task_person := getval('EMAIL_ID', l_form_rec_new.S1_TASK_PERSON_ID);

	l_email_to_other1 := getval('EMAIL_ID', l_form_rec_new.S5_OTHER1_ID);
	l_email_to_other2 := getval('EMAIL_ID', l_form_rec_new.S5_OTHER2_ID);
	l_email_to_other3 := getval('EMAIL_ID', l_form_rec_new.S5_OTHER3_ID);
	l_email_to_other1_ack := getval('EMAIL_ID', l_form_rec_new.S5_OTHER1_ACK_ID);
	l_email_to_other2_ack := getval('EMAIL_ID', l_form_rec_new.S5_OTHER2_ACK_ID);
	l_email_to_other3_ack := getval('EMAIL_ID', l_form_rec_new.S5_OTHER3_ACK_ID);

	l_email_to_s3 := l_email_to_s3_rp ||';'|| l_email_to_s3_sso ||';'|| l_email_to_s3_am ||';'|| l_email_to_s1_new_task_person;
	l_email_to_s4 := l_email_to_s4_do ||';'|| l_email_to_s4_wrkr;
	l_email_to_s5 := l_email_to_s5_do ||';'|| l_email_to_s5_rp ||';'|| l_email_to_s5_rpfo ||';'|| l_email_to_s5_pps;
	l_email_to_s6 := l_email_to_s6_do ||';'|| l_email_to_s6_sso;

	l_email_other := l_email_to_other1 ||';'|| l_email_to_other2 ||';'|| l_email_to_other3 ||';'|| l_email_to_other1_ack ||';'|| l_email_to_other2_ack ||';'|| l_email_to_other3_ack;
	--
	l_email_to := l_email_to_s3 ||';'|| l_email_to_s4 ||';'|| l_email_to_s5 ||';'|| l_email_to_s6 ||';'|| l_email_other;
	l_email_to := l_email_to ||';'|| l_created_by_email;

	l_email_to_final := trim(';' FROM l_email_to);
	--
	l_descr := substr(l_form_rec_new.S1_DESCR,1,200);
	l_old_form_status := getval('SSRL_FORM_STATUS', l_form_rec_old.FORM_STATUS_ID);
	l_new_form_status := getval('SSRL_FORM_STATUS', l_form_rec_new.FORM_STATUS_ID);

    cater_ui.get_apex_url_prefix(po_apex_url_prefix => l_apex_url_prefix, po_instance => l_instance);
--    l_edit_url := l_apex_url_prefix || 'f?p=273:3:::NO:1:P3_SSRL_FORM_ID:' || l_form_rec_new.ssrl_form_id;
    l_form_url := APEX_UTIL.PREPARE_URL(p_url => 'f?p=273:3:::NO:3:P3_SSRL_FORM_ID:' || l_form_rec_new.ssrl_form_id);
    l_edit_url := l_apex_url_prefix || l_form_url;
--    l_form_url := cater_ui.get_rsw_edit_url(p_apex_url_prefix=>l_apex_url_prefix,p_form_id=>l_form_id);
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_form_url = '|| l_form_url );
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_edit_url = '|| l_edit_url );
  l_edit_link := '<a href="' || l_edit_url || '" target="_blank">' || 'Edit Form' || '</a>';
/*
  IF  (l_operation = 'I')
  THEN
	l_email_flag := 1;
	l_email_to_final := l_created_by_email;
        l_page_name := 'New form';
	l_subject := 'SSRL electronic RSWCF: please approve if required. SSRL RSWCF #'||l_form_id||' is assigned to you';
 apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'l_edit_url = '|| l_edit_url );

    l_body := 'SSRL electronic RSWCF: please approve if required. '|| chr(10)|| '<br>' ||
          'Please note that SSRL RSWCF #'||l_form_id||' is assigned to you.' || chr(10)|| '<br>' ||
          ' Work Description: '||l_descr||chr(10)|| '<br>' ||
          ' This RSWCF was originally generated by: '||l_created_by||chr(10)|| '<br><br>' ||
         ' Click on the link below to review the form' || chr(10) || '<br><br>' || l_edit_link;

	begin
		apps_util.qm_email_pkg.send_email
		(p_app_name   => 'SSRL_RSWCF'
		,p_page_name  => l_page_name
		,p_email_from => 'SSRL_RSWCF@slac.stanford.edu'
		,p_email_to   => l_email_to_final
		,p_email_cc   => null
		,p_email_bcc  => null
		,p_subject    => l_subject 
		,p_body       => l_body 
		,p_is_html    => 'Y'
		,p_is_active  => 'Y'-- change this to 'Y' for prod
		,p_email_id   => l_email_id
		);
	exception
	  WHEN OTHERS THEN
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'Error in send_email for Form #'||l_form_rec_new.SSRL_FORM_ID||', Form_status_id = '||l_form_rec_new.FORM_STATUS_ID);
	end;

    END IF; -- l_operation = 'I'
*/
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 1) l_email_flag = '||l_email_flag);
  IF  (l_operation = 'U')
  THEN
   l_instance := sys_context('USERENV','INSTANCE_NAME');
   l_url_prefix := 'https://oraweb.slac.stanford.edu/apex/'||lower(l_instance)||'/';
--   l_edit_url := l_url_prefix ||'f?p=273:1';
--   l_edit_url := l_url_prefix ||'f?p='||pi_app_id||':3:::NO::P3_SSRL_FORM_ID:' || pi_ssrl_form_id ;
-- *******************  Form Status in Work Released/Closed/Dropped **************
    IF (l_form_rec_new.EMAIL_CHK = 'Y' and l_form_rec_new.email_rule in (19,21))
    THEN
        l_email_flag := 1;
	l_email_to_final := l_email_to_final ||';'|| l_email_to_ops||';'||l_email_to_bldo;
        l_page_name := 'ALL - Close form';
	l_subject := 'SSRL RSWCF #'||l_form_id||' is now '|| l_new_form_status;
   l_body := 'SSRL electronic RSWCF: please approve if required. '|| chr(10)|| '<br>' ||
          ' Please note that SSRL RSWCF #'||l_form_id||' is now ' || l_new_form_status ||chr(10)|| '<br>' ||
          ' Work Description: '||l_descr||chr(10)|| '<br>' ||
          ' This RSWCF was originally generated by: '||l_created_by||chr(10)|| '<br>' ||
          ' This RSWCF was last signed by: '|| l_modified_by ||chr(10)|| '<br><br>' ||
          ' Click on the link below to review the form' || chr(10) || '<br><br>' || l_edit_link;
	--
    END IF; -- email_rule in (19,21) (Form Status in Released/Closed/Dropped)
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 2) l_email_flag = '||l_email_flag);
    --
-- *******************  Form Status = Transferred **************
    IF (l_form_rec_new.EMAIL_CHK = 'Y' and l_form_rec_new.email_rule = 18)
    THEN
        l_email_flag := 1;
        l_page_name := 'Transfer form';
	l_subject := 'SSRL RSWCF #'||l_form_id||' is now '||l_new_form_status||' to #'||l_form_rec_new.SSRL_FORM_ID_TRANSFER_TO;
   l_body := ' SSRL electronic RSWCF: please approve if required. '|| chr(10)|| '<br>' ||
          ' Please note that SSRL RSWCF #'||l_form_id||' is now '||l_new_form_status||' to #'||
	  l_form_rec_new.SSRL_FORM_ID_TRANSFER_TO||' and cannot be modified anymore' || chr(10)|| '<br>' ||
          ' Work Description: '||l_descr||chr(10)|| '<br>' ||
          ' This RSWCF was originally generated by: '||l_created_by||chr(10)|| '<br>' ||
          ' This RSWCF was last signed by: '|| l_modified_by ||chr(10)|| '<br><br>' ||
          ' Click on the link below to review the form' || chr(10) || '<br><br>' || l_edit_link;
    END IF; -- email_rule = 18 (Form Status = Transferred)
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 3) l_email_flag = '||l_email_flag);
    --
--  *******************  Form Status = Complete **************
    IF (l_form_rec_new.EMAIL_CHK = 'Y' and l_form_rec_new.email_rule = 17)
    THEN
        l_email_flag := 1;
	l_email_to_final := ssrl_rsw_pkg.email_addresses('SSO');
	l_email_to_final := l_email_to_final ||';'||l_created_by_email;
	l_page_name := 'SSO - Complete form';
	l_subject := 'SSRL electronic RSWCF: please approve if required. Please signoff to close SSRL RSWCF #'||l_form_id;
   l_body := 'SSRL electronic RSWCF: please approve if required. '|| chr(10)|| '<br>' ||
          'As SSRL Safety Officer, Please review the work done and signoff to close SSRL RSWCF #'||l_form_id||chr(10)|| '<br>' ||
		  ' Section 6: SSO review' || chr(10)|| '<br>' ||
          ' Work Description: '||l_descr||chr(10)|| '<br>' ||
          ' This RSWCF was originally generated by: '||l_created_by||chr(10)|| '<br>' ||
          ' This RSWCF was last signed by: '|| l_modified_by ||chr(10)|| '<br><br>' ||
          ' Click on the link below to review the form' || chr(10) || '<br><br>' || l_edit_link;
    END IF; -- email_rule = 17 (Form Status = Complete)
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 4) l_email_flag = '||l_email_flag);
    --
-- Sec 1/2a/2b/3 any changes
    IF (l_form_rec_new.EMAIL_CHK = 'Y' and l_form_rec_new.email_rule = 6)
    THEN
	l_email_to_s3_rp := getval('EMAIL_ID',l_form_rec_old.S3_RAD_ID);
	l_email_to_s3_sso := getval('EMAIL_ID',l_form_rec_old.S3_SSO_ID);
	l_email_to_s3_am := getval('EMAIL_ID',l_form_rec_old.S3_AREA_MGR_ID);
--	l_email_to := l_email_to_s3_rp ||';'|| l_email_to_s3_sso ||';'|| l_email_to_s3_am ||';'|| 
--	              l_email_to_s1_new_task_person ||';'|| l_email_to_s1_old_task_person||';'||l_created_by_email;

	l_email_to_s4_do := getval('EMAIL_ID',l_form_rec_old.S4_OPERATOR_ID);
	l_email_to_s4_wrkr := getval('EMAIL_ID',l_form_rec_old.S4_WRKR_ID);

	l_email_to_s5_do := getval('EMAIL_ID',l_form_rec_old.S5_OPERATOR_ID);
	l_email_to_s5_rp := getval('EMAIL_ID',l_form_rec_old.S5_RAD_ID);
	l_email_to_s5_rpfo := getval('EMAIL_ID',l_form_rec_old.S5_RPFO_ID);
	l_email_to_s5_pps := getval('EMAIL_ID',l_form_rec_old.S5_PPS_ID);

	l_email_to_other1_ack := getval('EMAIL_ID', l_form_rec_old.S5_OTHER1_ACK_ID);
	l_email_to_other2_ack := getval('EMAIL_ID', l_form_rec_old.S5_OTHER2_ACK_ID);
	l_email_to_other3_ack := getval('EMAIL_ID', l_form_rec_old.S5_OTHER3_ACK_ID);

	l_email_to_s3 := l_email_to_s3_rp ||';'|| l_email_to_s3_sso ||';'|| l_email_to_s3_am 
	                 ||';'|| l_email_to_s1_new_task_person||';'|| l_email_to_s1_old_task_person;
	l_email_to_s4 := l_email_to_s4_do ||';'|| l_email_to_s4_wrkr;
	l_email_to_s5 := l_email_to_s5_do ||';'|| l_email_to_s5_rp ||';'|| l_email_to_s5_rpfo ||';'|| l_email_to_s5_pps;

	l_email_other := l_email_to_other1_ack ||';'|| l_email_to_other2_ack ||';'|| l_email_to_other3_ack;
	--
	l_email_to := l_email_to_s3 ||';'|| l_email_to_s4 ||';'|| l_email_to_s5 ||';'|| l_email_other;
        l_email_to := l_email_to ||';'|| l_created_by_email;


	l_email_to_final := trim(';' FROM l_email_to);

        l_email_flag := 1;
	l_page_name := 'PreWork Approvals Nullified';
	l_subject := 'SSRL electronic RSWCF: please approve if required. Please review SSRL RSWCF #'||l_form_id||' as PreWork Approvals have been Nullified';
	l_body := 'SSRL electronic RSWCF: please approve if required. '|| chr(10)|| '<br>' ||
          ' PreWork Approvals were Nullified for SSRL RSWCF #'||l_form_id||'. Please review the details again.'|| chr(10)|| '<br>' ||
          ' Work Description: '||l_descr||chr(10)|| '<br>' ||
          ' This RSWCF was originally generated by: '||l_created_by||chr(10)|| '<br>' ||
          ' This RSWCF was last signed by: '|| l_modified_by ||chr(10)|| '<br><br>' ||
          ' Click on the link below to review the form' || chr(10) || '<br><br>' || l_edit_link;
    END IF; -- email_rule = 6 (Sec 1/2a/2b/3 any changes)
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 5) l_email_flag = '||l_email_flag);
    --
-- Sec 4 Assigned Worker changes
    IF (l_form_rec_new.EMAIL_CHK = 'Y' and l_form_rec_new.email_rule = 20)
    THEN
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 6) l_form_rec_new.S4_ASSIGN_WRKR_ID = '|| l_form_rec_new.S4_ASSIGN_WRKR_ID);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 7) l_form_rec_old.S4_ASSIGN_WRKR_ID = '|| l_form_rec_old.S4_ASSIGN_WRKR_ID);
	l_s4_new_assign_wrkr := getval('NAME',l_form_rec_new.S4_ASSIGN_WRKR_ID);
	l_email_to_s4_new_assign_wrkr := getval('EMAIL_ID',l_form_rec_new.S4_ASSIGN_WRKR_ID);
	l_email_to_s4_old_assign_wrkr := getval('EMAIL_ID',l_form_rec_old.S4_ASSIGN_WRKR_ID);
        l_email_to := l_email_to_s4_new_assign_wrkr ||';'||l_email_to_s4_old_assign_wrkr||';'|| l_created_by_email;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 8) l_email_to_s4_new_assign_wrkr = '|| l_email_to_s4_new_assign_wrkr);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 9) l_email_to_s4_old_assign_wrkr = '|| l_email_to_s4_old_assign_wrkr);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 10) l_email_to = '|| l_email_to);

	l_email_to_final := trim(';' FROM l_email_to);
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 11) l_email_to_final = '|| l_email_to_final);

        l_email_flag := 1;
	l_page_name := 'Worker Assigned';
	l_subject := 'SSRL electronic RSWCF: please approve if required. Please review and perform the work for SSRL RSWCF #'||l_form_id;
	l_body := 'SSRL electronic RSWCF: please approve if required. '|| chr(10)|| '<br>' ||
	  ' This work is now assigned to '|| l_s4_new_assign_wrkr || chr(10)|| '<br>' ||
          ' Please review and perform the work for SSRL RSWCF #'||l_form_id|| chr(10)|| '<br>' ||
	  ' Section 4: Worker Assigned.' ||chr(10)|| '<br>' ||
          ' Work Description: '||l_descr||chr(10)|| '<br>' ||
          ' This RSWCF was originally generated by: '||l_created_by||chr(10)|| '<br>' ||
          ' This RSWCF was last signed by: '|| l_modified_by ||chr(10)|| '<br><br>' ||
          ' Click on the link below to review the form' || chr(10) || '<br><br>' || l_edit_link;
    END IF; -- email_rule = 20 (Sec 4 Assigned Worker changes)
    --

/*
-- Any change of the Section 5 Checkboxes to Null
    IF (l_form_rec_new.EMAIL_CHK = 'Y' and l_form_rec_new.email_rule = 20)
    THEN
	l_email_to_s3_rp := getval('EMAIL_ID',l_form_rec_old.S3_RAD_ID);
	l_email_to_s3_sso := getval('EMAIL_ID',l_form_rec_old.S3_SSO_ID);
	l_email_to_s3_am := getval('EMAIL_ID',l_form_rec_old.S3_AREA_MGR_ID);
	l_email_to_s4_do := getval('EMAIL_ID',l_form_rec_old.S4_OPERATOR_ID);
	l_email_to_s4_wrkr := getval('EMAIL_ID',l_form_rec_old.S4_WRKR_ID);

	l_email_to_s5_do := getval('EMAIL_ID',l_form_rec_old.S5_OPERATOR_ID);
	l_email_to_s5_rp := getval('EMAIL_ID',l_form_rec_old.S5_RAD_ID);
	l_email_to_s5_rpfo := getval('EMAIL_ID',l_form_rec_old.S5_RPFO_ID);
	l_email_to_s5_pps := getval('EMAIL_ID',l_form_rec_old.S5_PPS_ID);

	l_email_to_other1_ack := getval('EMAIL_ID', l_form_rec_old.S5_OTHER1_ACK_ID);
	l_email_to_other2_ack := getval('EMAIL_ID', l_form_rec_old.S5_OTHER2_ACK_ID);
	l_email_to_other3_ack := getval('EMAIL_ID', l_form_rec_old.S5_OTHER3_ACK_ID);

	l_email_to_s3 := l_email_to_s3_rp ||';'|| l_email_to_s3_sso ||';'|| l_email_to_s3_am ||';'|| l_email_to_s1_new_task_person;
	l_email_to_s4 := l_email_to_s4_do ||';'|| l_email_to_s4_wrkr;
	l_email_to_s5 := l_email_to_s5_do ||';'|| l_email_to_s5_rp ||';'|| l_email_to_s5_rpfo ||';'|| l_email_to_s5_pps;

	l_email_other := l_email_to_other1_ack ||';'|| l_email_to_other2_ack ||';'|| l_email_to_other3_ack;
	--
	l_email_to := l_email_to_s3 ||';'|| l_email_to_s4 ||';'|| l_email_to_s5 ||';'|| l_email_other;
        l_email_to := l_email_to ||';'|| l_created_by_email;

	l_email_to_final := trim(';' FROM l_email_to);

        l_email_flag := 1;
	l_page_name := 'PreWork Approvals Nullified';
	l_subject := 'SSRL electronic RSWCF: please approve if required. Please review SSRL RSWCF #'||l_form_id||' as PreWork Approvals have been Nullified';
	l_body := 'SSRL electronic RSWCF: please approve if required. '|| chr(10)|| '<br>' ||
          ' PreWork Approvals were Nullified for SSRL RSWCF #'||l_form_id||'. Please review the details again.'|| chr(10)|| '<br>' ||
          ' Work Description: '||l_descr||chr(10)|| '<br>' ||
          ' This RSWCF was originally generated by: '||l_created_by||chr(10)|| '<br>' ||
          ' This RSWCF was last signed by: '|| l_modified_by ||chr(10)|| '<br><br>' ||
          ' Click on the link below to review the form' || chr(10) || '<br><br>' || l_edit_link;
    END IF; -- email_rule = 20 (Section 5 Checkboxes Null)
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ' 5) l_email_flag = '||l_email_flag);
*/
    --
    IF  (l_email_flag = 1)
    THEN
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ', going to send email');
	begin
		l_email_to_final := trim(';' FROM l_email_to_final);

		apps_util.qm_email_pkg.send_email
		(p_app_name   => 'SSRL_RSWCF'
		,p_page_name  => l_page_name
		,p_email_from => 'SSRL_RSWCF@slac.stanford.edu'
		,p_email_to   => l_email_to_final ||';'|| 'poonam@slac.stanford.edu' 
		,p_email_cc   => null
		,p_email_bcc  => null
		,p_subject    => l_subject 
		,p_body       => l_body 
		,p_is_html    => 'Y'
		,p_is_active  => 'Y'-- change this to 'Y' for prod
		,p_email_id   => l_email_id
		);
	exception
	  WHEN OTHERS THEN
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || 'Error in send_email for Form #'||l_form_rec_new.SSRL_FORM_ID||', Form_status_id = '||l_form_rec_new.FORM_STATUS_ID);
	end;
    END IF; -- email_flag = 1
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || ', end');
  END IF; -- l_operation = 'U'

end  SSRL_RSW_FORM_MESSAGES_TRG;


/
ALTER TRIGGER "MCC_MAINT"."SSRL_RSW_FORM_MESSAGES_TRG" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SSRL_RSW_FORM_BIUDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "MCC_MAINT"."SSRL_RSW_FORM_BIUDR" 
 BEFORE INSERT OR UPDATE OR DELETE
 ON SSRL_RSW_FORM  FOR EACH ROW
DECLARE
	jn_operation	VARCHAR2(3);
	l_current_user	varchar2(30) := lower(nvl(v('APP_USER'),user));
	c_proc		constant varchar2(100) := 'SSRL_RSW_FORM_BIUDR ';
BEGIN

if inserting and :new.SSRL_FORM_ID is null then
    select SSRL_RSW_FORM_seq.nextval into :new.SSRL_FORM_ID
    from dual;
end if;
--
if inserting and :new.created_by is null  then
    :new.created_by := NVL(V('APP_USER'),USER);
    :new.created_date := sysdate;
end if;
--
if updating then
    :new.modified_by := NVL(V('APP_USER'),USER);
    :new.modified_date := sysdate;
    :new.EMAIL_CHK := 'N';
    :new.email_rule := 0;
    --
    if (nvl(:new.s3_rad_id,0) != nvl(:old.s3_rad_id,0))
    then
         :new.s3_rad_date        := sysdate;
         :new.s3_rad_modified_by := l_current_user;
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 1;
    end if;
    --
    if (nvl(:new.s3_sso_id,0) != nvl(:old.s3_sso_id,0))
    then
         :new.s3_sso_date        := sysdate;
         :new.s3_sso_modified_by := l_current_user;
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 2;
    end if;
    --
    if (nvl(:new.s3_area_mgr_id,0) != nvl(:old.s3_area_mgr_id,0))
    then
         :new.s3_area_mgr_date        := sysdate;
         :new.s3_area_mgr_modified_by := l_current_user;
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 3;
    end if;
    --
    IF :new.S3_TASK_PERSON_ACK_ID is not null then
	IF :new.S3_TASK_PERSON_ACK_ID != :new.S1_TASK_PERSON_ID THEN
	   :new.S3_TASK_PERSON_ACK_ID := NULL;
           :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 4;
	END IF;
    END IF;
    --
    if (nvl(:new.S3_TASK_PERSON_ACK_ID,0) != nvl(:old.S3_TASK_PERSON_ACK_ID,0))
    then
         :new.S3_TASK_PERSON_ACK_DATE        := sysdate;
         :new.S3_TASK_PERSON_ACK_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';
 	 :new.email_rule := 5;
    end if;
    --
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '1 value of :new.s3_rad_id = '|| :new.s3_rad_id );
    -- we make all the 3 RP, SSO & AM ids also NULL
    -- Any change of Sec 1/2a/2b
    IF	(:new.S1_TASK_PERSON_ID	!=	:old.S1_TASK_PERSON_ID	OR
	:new.S1_AREA_ID		!=	:old.S1_AREA_ID		OR
	:new.S1_START_TIME	!=	:old.S1_START_TIME	OR
	:new.S1_DESCR		!=	:old.S1_DESCR		OR
	:new.S2_DESCR_BEFORE	!=	:old.S2_DESCR_BEFORE	OR
	:new.S2_DESCR_AFTER	!=	:old.S2_DESCR_AFTER)
    THEN
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 6;
	 --
	:new.S3_RAD_ID := NULL;
--	:new.S3_RAD_DATE        := NULL;
--	:new.S3_RAD_MODIFIED_BY := NULL;
	:new.S3_SSO_ID := NULL;
--	:new.S3_SSO_DATE        := NULL;
--	:new.S3_SSO_MODIFIED_BY := NULL;
	:new.S3_AREA_MGR_ID := NULL;
--	:new.S3_AREA_MGR_DATE        := NULL;
--	:new.S3_AREA_MGR_MODIFIED_BY := NULL;
	:new.S3_TASK_PERSON_ACK_ID        := NULL;
--	:new.S3_TASK_PERSON_ACK_DATE        := NULL;
--	:new.S3_TASK_PERSON_ACK_MODIFIED_BY := NULL;
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '2 value of :new.s3_rad_id = '|| :new.s3_rad_id );
    END IF; -- Any change of Sec 1/2a/2b

apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '3 value of :new.s3_rad_id = '|| :new.s3_rad_id );
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '4 value of :old.s3_rad_id = '|| :old.s3_rad_id );
      IF (:new.s3_rad_id is null and :old.s3_rad_id is not null) OR
	 (:new.s3_sso_id is null and :old.s3_sso_id is not null) OR
	 (:new.s3_area_mgr_id is null and :old.s3_area_mgr_id is not null)
      THEN
apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '4 value of :new.s3_rad_id = '|| :new.s3_rad_id );
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 6;
	 --
    END IF; -- Any change of Sec 3 signoffs
    --
    if (nvl(:new.S4_OPERATOR_ID,0) != nvl(:old.S4_OPERATOR_ID,0))
    then
         :new.S4_OPERATOR_DATE        := sysdate;
         :new.S4_OPERATOR_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';
 	 :new.email_rule := 7;
    end if;
    --
    if (nvl(:new.S4_ASSIGN_WRKR_ID,0) != nvl(:old.S4_ASSIGN_WRKR_ID,0))
    then
         :new.S4_ASSIGN_WRKR_DATE        := sysdate;
         :new.S4_ASSIGN_WRKR_MODIFIED_BY := l_current_user;
 	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 20; -- ??????????????????????????????????????????????????
   end if;
    --
    if (nvl(:new.S4_WRKR_ID,0) != nvl(:old.S4_WRKR_ID,0))
    then
         :new.S4_WRKR_DATE        := sysdate;
         :new.S4_WRKR_MODIFIED_BY := l_current_user;
 	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 8;
   end if;
    --
   --
   if (nvl(:new.S5_TASK_PERSON_ACK_ID,0) != nvl(:old.S5_TASK_PERSON_ACK_ID,0))
    then
         :new.S5_TASK_PERSON_ACK_DATE        := sysdate;
         :new.S5_TASK_PERSON_ACK_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 9;
    end if;
    --
    if (nvl(:new.S5_PPS_ID,0) != nvl(:old.S5_PPS_ID,0))
    then
         :new.S5_PPS_DATE        := sysdate;
         :new.S5_PPS_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 10;
    end if;
    --
    if (nvl(:new.s5_rad_id,0) != nvl(:old.s5_rad_id,0))
    then
         :new.s5_rad_date        := sysdate;
         :new.s5_rad_modified_by := l_current_user;
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 11;
    end if;
    --
    if (nvl(:new.S5_OPERATOR_ID,0) != nvl(:old.S5_OPERATOR_ID,0))
    then
         :new.S5_OPERATOR_DATE        := sysdate;
         :new.S5_OPERATOR_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 12;
    end if;
    --
    if (nvl(:new.S5_RPFO_ID,0) != nvl(:old.S5_RPFO_ID,0))
    then
         :new.S5_RPFO_DATE        := sysdate;
         :new.S5_RPFO_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 13;
    end if;
    --
    if (:new.S5_OTHER1_CHK is null and :old.S5_OTHER1_CHK = 'Y') AND
       (:new.S5_OTHER1_ID is NOT NULL) THEN
       :new.S5_OTHER1_ID := NULL;
    end if;
    --
    if (:new.S5_OTHER2_CHK is null and :old.S5_OTHER2_CHK = 'Y') AND
       (:new.S5_OTHER2_ID is NOT NULL) THEN
       :new.S5_OTHER2_ID := NULL;
    end if;
    --
    if (:new.S5_OTHER3_CHK is null and :old.S5_OTHER3_CHK = 'Y') AND
       (:new.S5_OTHER3_ID is NOT NULL) THEN
       :new.S5_OTHER3_ID := NULL;
    end if;
    --
    if (nvl(:new.S5_OTHER1_ACK_ID,0) != nvl(:old.S5_OTHER1_ACK_ID,0))
    then
         :new.S5_OTHER1_ACK_DATE        := sysdate;
         :new.S5_OTHER1_ACK_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 14;
    end if;
    --
    if (nvl(:new.S5_OTHER2_ACK_ID,0) != nvl(:old.S5_OTHER2_ACK_ID,0))
    then
         :new.S5_OTHER2_ACK_DATE        := sysdate;
         :new.S5_OTHER2_ACK_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 14;
    end if;
    --
    if (nvl(:new.S5_OTHER3_ACK_ID,0) != nvl(:old.S5_OTHER3_ACK_ID,0))
    then
         :new.S5_OTHER3_ACK_DATE        := sysdate;
         :new.S5_OTHER3_ACK_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 14;
    end if;
    --
-- Any change of the Section 5 Checkboxes to Null
    IF ( :new.S5_PPS_CHK is null and :old.S5_PPS_CHK = 'Y') OR
	(:new.S5_RPFO_CHK is null and :old.S5_RPFO_CHK = 'Y') OR
	(:new.S5_RAD_CHK is null and :old.S5_RAD_CHK = 'Y') OR
	(:new.S5_OPERATOR_CHK is null and :old.S5_OPERATOR_CHK = 'Y') OR
	(:new.S5_OTHER1_CHK is null and :old.S5_OTHER1_CHK = 'Y') OR
	(:new.S5_OTHER2_CHK is null and :old.S5_OTHER2_CHK = 'Y') OR
	(:new.S5_OTHER3_CHK is null and :old.S5_OTHER3_CHK = 'Y')
    THEN
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 6;
	 --
	:new.S3_RAD_ID := NULL;
--	:new.S3_RAD_DATE        := NULL;
--	:new.S3_RAD_MODIFIED_BY := NULL;
	:new.S3_SSO_ID := NULL;
--	:new.S3_SSO_DATE        := NULL;
--	:new.S3_SSO_MODIFIED_BY := NULL;
	:new.S3_AREA_MGR_ID := NULL;
--	:new.S3_AREA_MGR_DATE        := NULL;
--	:new.S3_AREA_MGR_MODIFIED_BY := NULL;
	:new.S3_TASK_PERSON_ACK_ID        := NULL;
--	:new.S3_TASK_PERSON_ACK_DATE        := NULL;
--	:new.S3_TASK_PERSON_ACK_MODIFIED_BY := NULL;
	--
	:new.S4_OPERATOR_ID := NULL;
--	:new.S4_OPERATOR_DATE        := NULL;
--	:new.S4_OPERATOR_MODIFIED_BY := NULL;
	:new.S4_WRKR_ID := NULL;
--	:new.S4_WRKR_DATE        := NULL;
--	:new.S4_WRKR_MODIFIED_BY := NULL;
	:new.S4_ASSIGN_WRKR_ID := NULL;
--	:new.S4_ASSIGN_WRKR_DATE        := NULL;
--	:new.S4_ASSIGN_WRKR_MODIFIED_BY := NULL;
	--
	:new.S5_TASK_PERSON_ACK_ID        := NULL;
--	:new.S5_TASK_PERSON_ACK_DATE        := NULL;
--	:new.S5_TASK_PERSON_ACK_MODIFIED_BY := NULL;
	:new.S5_PPS_ID        := NULL;
--	:new.S5_PPS_DATE        := NULL;
--	:new.S5_PPS_MODIFIED_BY := NULL;
	:new.S5_RAD_ID        := NULL;
--	:new.S5_RAD_DATE        := NULL;
--	:new.S5_RAD_MODIFIED_BY := NULL;
	:new.S5_RPFO_ID        := NULL;
--	:new.S5_RPFO_DATE        := NULL;
--	:new.S5_RPFO_MODIFIED_BY := NULL;
	:new.S5_OPERATOR_ID        := NULL;
--	:new.S5_OPERATOR_DATE        := NULL;
--	:new.S5_OPERATOR_MODIFIED_BY := NULL;
	:new.S5_OTHER1_ACK_ID        := NULL;
--	:new.S5_OTHER1_ACK_DATE        := NULL;
--	:new.S5_OTHER1_ACK_MODIFIED_BY := NULL;
	:new.S5_OTHER2_ACK_ID        := NULL;
--	:new.S5_OTHER2_ACK_DATE        := NULL;
--	:new.S5_OTHER2_ACK_MODIFIED_BY := NULL;
	:new.S5_OTHER3_ACK_ID        := NULL;
--	:new.S5_OTHER3_ACK_DATE        := NULL;
--	:new.S5_OTHER3_ACK_MODIFIED_BY := NULL;

apps_util.utl.log_add(p_appl_id => 1, p_trans_id => null, p_message_type_id => 1 ,p_text => c_proc || '2 value of :new.s3_rad_id = '|| :new.s3_rad_id );
    END IF; -- Any change of the Section 5 Checkboxes to Null
    --
    if (nvl(:new.s6_sso_id,0) != nvl(:old.s6_sso_id,0))
    then
         :new.s6_sso_date        := sysdate;
         :new.s6_sso_modified_by := l_current_user;
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 15;
    end if;
    --
    if (nvl(:new.S6_OPERATOR_ID,0) != nvl(:old.S6_OPERATOR_ID,0))
    then
         :new.S6_OPERATOR_DATE        := sysdate;
         :new.S6_OPERATOR_MODIFIED_BY := l_current_user;
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 16;
    end if;
    --
    if nvl(:new.drop_form_chk,'N') != 'Y' THEN
	SSRL_RSW_GET_STATUS
	(p_form_id		=> :new.SSRL_FORM_ID
	,p_s3_task_person_ack_id	=> :new.S3_TASK_PERSON_ACK_ID
	,p_s3_area_mgr_id	=> :new.S3_AREA_MGR_ID
	,p_s3_sso_id		=> :new.S3_SSO_ID
	,p_s3_rad_id		=> :new.S3_RAD_ID
	,p_s4_operator_id	=> :new.S4_OPERATOR_ID
	,p_s4_wrkr_id		=> :new.S4_WRKR_ID
	,p_s5_task_person_ack_id	=> :new.S5_TASK_PERSON_ACK_ID
	,p_s5_pps_id		=> :new.S5_PPS_ID
	,p_s5_rad_id		=> :new.S5_RAD_ID
	,p_s5_operator_id	=> :new.S5_OPERATOR_ID
	,p_s5_rpfo_id		=> :new.S5_RPFO_ID
	,p_s5_other1_ack_id	=> :new.S5_OTHER1_ACK_ID
	,p_s5_other2_ack_id	=> :new.S5_OTHER2_ACK_ID
	,p_s5_other3_ack_id	=> :new.S5_OTHER3_ACK_ID
	,p_s6_sso_id		=> :new.S6_SSO_ID
	,p_s6_operator_id	=> :new.S6_OPERATOR_ID
	,p_s5_pps_chk		=> :new.S5_PPS_CHK
	,p_s5_rad_chk		=> :new.S5_RAD_CHK
	,p_s5_operator_chk	=> :new.S5_OPERATOR_CHK
	,p_s5_rpfo_chk		=> :new.S5_RPFO_CHK
	,p_s5_other1_chk	=> :new.S5_OTHER1_CHK
	,p_s5_other1_id	        => :new.S5_OTHER1_ID
	,p_s5_other2_chk	=> :new.S5_OTHER2_CHK
	,p_s5_other2_id	        => :new.S5_OTHER2_ID
	,p_s5_other3_chk	=> :new.S5_OTHER3_CHK
	,p_s5_other3_id	        => :new.S5_OTHER3_ID
	,p_form_status_id	=> :new.FORM_STATUS_ID
	);
    end if;
    --
    -- Form Status = COMPLETE - Email
    if :new.form_status_id = 4 and
       :new.form_status_id != :old.form_status_id
    then
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 17;
    end if;
    --
    if :new.SSRL_FORM_ID_TRANSFER_TO is not null and
       :old.SSRL_FORM_ID_TRANSFER_TO is null
    then
         :new.form_status_id := 5; -- Transferred status
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 18;
    end if;
    --
    if :new.form_status_id in (6,7) and
       :new.form_status_id != :old.form_status_id
    then
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 19;
    end if;
    --
    -- Form Status = Work Released - Email
    if :new.form_status_id = 3 and
       :new.form_status_id != :old.form_status_id
    then
	 :new.EMAIL_CHK := 'Y';
	 :new.email_rule := 21;
    end if;
    --
end if; -- if updating

END;
/
ALTER TRIGGER "MCC_MAINT"."SSRL_RSW_FORM_BIUDR" ENABLE;
--------------------------------------------------------
--  Constraints for Table SSRL_RSW_FORM
--------------------------------------------------------

  ALTER TABLE "MCC_MAINT"."SSRL_RSW_FORM" MODIFY ("SSRL_FORM_ID" NOT NULL ENABLE);
  ALTER TABLE "MCC_MAINT"."SSRL_RSW_FORM" ADD CONSTRAINT "SSRL_RSW_FORM_PK" PRIMARY KEY ("SSRL_FORM_ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "MCC_MAINT_DATA"  ENABLE;
