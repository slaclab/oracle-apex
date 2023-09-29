--------------------------------------------------------
--  File created - Friday-September-30-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table SSRL_RELEASES_JN
--------------------------------------------------------

  CREATE TABLE MCC_MAINT.SSRL_RELEASES_JN 
   (	JN_OPERATION VARCHAR2(3), 
	JN_ORACLE_USER VARCHAR2(30), 
	JN_DATETIME DATE, 
	JN_NOTES VARCHAR2(240), 
	JN_APPLN VARCHAR2(30), 
	JN_SESSION NUMBER, 
	RELEASE_ID NUMBER, 
	PROD_INSTALL_DATE DATE, 
	VERSION VARCHAR2(30), 
	DESCRIPTION VARCHAR2(4000), 
	CREATED_BY VARCHAR2(30), 
	CREATED_DATE DATE, 
	MODIFIED_BY VARCHAR2(30), 
	MODIFIED_DATE DATE
   )  TABLESPACE MCC_MAINT_DATA ;
--------------------------------------------------------
--  Constraints for Table SSRL_RELEASES_JN
--------------------------------------------------------

  ALTER TABLE MCC_MAINT.SSRL_RELEASES_JN MODIFY (JN_OPERATION NOT NULL ENABLE);
  ALTER TABLE MCC_MAINT.SSRL_RELEASES_JN MODIFY (JN_ORACLE_USER NOT NULL ENABLE);
  ALTER TABLE MCC_MAINT.SSRL_RELEASES_JN MODIFY (JN_DATETIME NOT NULL ENABLE);
