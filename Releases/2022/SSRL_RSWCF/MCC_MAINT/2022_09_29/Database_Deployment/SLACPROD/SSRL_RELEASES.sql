--------------------------------------------------------
--  File created - Friday-September-30-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table SSRL_RELEASES
--------------------------------------------------------

  CREATE TABLE MCC_MAINT.SSRL_RELEASES 
   (	RELEASE_ID		NUMBER, 
	PROD_INSTALL_DATE	DATE, 
	VERSION			VARCHAR2(30), 
	DESCRIPTION		VARCHAR2(4000), 
	CREATED_BY		VARCHAR2(30), 
	CREATED_DATE		DATE, 
	MODIFIED_BY		VARCHAR2(30), 
	MODIFIED_DATE		DATE
   )   TABLESPACE MCC_MAINT_DATA ;
--------------------------------------------------------
--  DDL for Index SSRL_RELEASES_PK
--------------------------------------------------------
ALTER TABLE SSRL_RELEASES
ADD CONSTRAINT SSRL_RELEASES_PK PRIMARY KEY (RELEASE_ID)
using index;

drop sequence SSRL_RELEASES_SEQ;
CREATE SEQUENCE SSRL_RELEASES_SEQ
MINVALUE 1 
MAXVALUE 999999999999999999999999999 
INCREMENT BY 1 
START WITH 1 
NOCACHE  
NOORDER  
NOCYCLE;

