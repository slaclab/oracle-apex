CREATE OR REPLACE FUNCTION "MCC_MAINT"."GETVAL" (P_ITEM VARCHAR2, P_VAL VARCHAR2) RETURN VARCHAR2 IS
TEMP VARCHAR2(4000);
BEGIN
   IF P_ITEM = 'AREA' THEN
      BEGIN
      SELECT AREA INTO TEMP FROM ART_AREAS WHERE AREA_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'SUBSYSTEM' THEN
      BEGIN
      SELECT SUBSYSTEM INTO TEMP FROM ART_SUBSYSTEMS WHERE SUBSYSTEM_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL;  END;
   END IF;

   IF P_ITEM = 'SHOP' THEN
      BEGIN
      SELECT SHOP INTO TEMP FROM ART_SHOPS WHERE SHOP_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'PRIORITY' THEN
      BEGIN
      SELECT PRIORITY INTO TEMP FROM ART_PRIORITIES WHERE PRIORITY_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'ACCESS_REQ' THEN
      BEGIN
      SELECT ACCESS_REQ INTO TEMP FROM ART_ACCESS_REQS WHERE ACCESS_REQ_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'WORK_TYPE' THEN
      BEGIN
      SELECT WORK_TYPE INTO TEMP FROM ART_WORK_TYPES WHERE WORK_TYPE_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'PPSZONE' THEN
      BEGIN
      SELECT PPSZONE INTO TEMP FROM ART_PPSZONES WHERE PPSZONE_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'DIV_CODE' THEN
      BEGIN
      SELECT DIV_CODE INTO TEMP FROM ART_DIVISION_CODES WHERE DIV_CODE_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'NAME' THEN
      BEGIN
      SELECT NAME INTO TEMP FROM PERSONS.PERSON WHERE KEY = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'BUILDING' THEN
      BEGIN
      SELECT BUILDING_NO INTO TEMP FROM SID.BUILDINGS WHERE BUILDING_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'FACILITY' THEN
      BEGIN
      SELECT FACILITY INTO TEMP FROM ART_FACILITIES WHERE FACILITY_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'SOL_TYPE' THEN
      BEGIN
      SELECT SOL_TYPE INTO TEMP FROM ART_SOLUTION_TYPES WHERE SOL_TYPE_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

-- Poonam - 6/25/2014 - Added the rownum=1, as there are multiple Area managers for an Area sometimes.
   IF P_ITEM = 'AREAMGR' THEN
      BEGIN
      SELECT P.NAME INTO TEMP FROM PERSONS.PERSON P,
         ART_JUNC_AREA_PERSON A WHERE A.AREA_ID = P_VAL
         AND A.PERSON_ID = P.KEY
	 and rownum = 1;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'JOB_STATUS' THEN
      BEGIN
      SELECT NAME INTO TEMP FROM ART_JOB_STATUS WHERE JOB_STATUS_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'PROB_STATUS' THEN
      BEGIN
      SELECT NAME INTO TEMP FROM ART_PROBLEM_STATUS WHERE PROBLEM_STATUS_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'PROB_STATUS_DISP' THEN
      BEGIN
      SELECT DISPLAY_NAME INTO TEMP FROM ART_PROBLEM_STATUS WHERE PROBLEM_STATUS_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'AM_APPROVAL' THEN
      BEGIN
      SELECT
         DECODE(P_VAL,'Y','Yes','N','No','AMR') INTO TEMP FROM DUAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'YESNO' THEN
      BEGIN
      SELECT
         DECODE(P_VAL,'Y','Yes','N','No',NULL) INTO TEMP FROM DUAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'BEAM' THEN
     BEGIN
      SELECT decode(P_VAL,'BEAM','Beam','NOBEAM','No Beam','VVSON','VVSs On','ACCTRIG','ACC Trig','STBYTRIG','STBY Trig','NORQMTS','No Requirements',P_VAL)
      INTO TEMP FROM DUAL;
     EXCEPTION WHEN OTHERS THEN TEMP := P_VAL;
     END;
   END IF;

   IF P_ITEM = 'REQUEST_TYPE' THEN
     BEGIN
      SELECT decode(P_VAL,1,'Customer',2,'Project',3,'Maintenance',4,'Internal',P_VAL)
      INTO TEMP FROM DUAL;
     EXCEPTION WHEN OTHERS THEN TEMP := P_VAL;
     END;
   END IF;

   IF P_ITEM = 'GROUP' THEN
      BEGIN
      SELECT NAME INTO TEMP FROM ART_GROUP WHERE GROUP_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;
/* Poonam 10-26-2018 - This field is NOT being used anymore in a CATER.
   IF P_ITEM = 'PROJECT' THEN
      BEGIN
      SELECT PROJECT_NAME INTO TEMP FROM ART_PROJECTS WHERE PROJECT_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;
*/
   IF P_ITEM = 'WORK_TYPE' THEN
      BEGIN
      SELECT WORK_TYPE INTO TEMP FROM ART_WORK_TYPES WHERE WORK_TYPE_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'RAD_FORM_STATUS' THEN
      begin
      SELECT STATUS INTO TEMP FROM RSW_FORM_STATUS WHERE FORM_STATUS_ID = P_VAL;
      exception when others then temp := p_val; end;
   END IF;
-- Poonam - Added New for New CATER UI
   IF P_ITEM = 'CATER_SUBTYPE' THEN
      BEGIN
      SELECT PROB_TYPE_DETAIL INTO TEMP FROM ART_PROBLEM_TYPES WHERE PROB_TYPE_DTL_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

-- Poonam - Retrieving Individual's email id
   IF P_ITEM = 'EMAIL_ID' THEN
      BEGIN
      SELECT MAILDISP INTO TEMP FROM PERSONS.PERSON WHERE KEY = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

-- Poonam - 9/21/2016 - Retrieving Job Number from Job Id
   IF P_ITEM = 'JOB_NUM' THEN
      BEGIN
      SELECT job_number INTO TEMP FROM art_jobs WHERE job_id = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

-- Poonam - 9/21/2016 - Retrieving Solution/Task Number from Sol Id
   IF P_ITEM = 'SOL_NUM' THEN
      BEGIN
      SELECT solution_number INTO TEMP FROM art_solutions WHERE sol_id = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

-- Below GETVAL values for Software Project application
   IF P_ITEM = 'PROJECT' THEN
      BEGIN
      SELECT PROJ_NAME INTO TEMP FROM SWE_PROJECT WHERE ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'PROJ_STATUS' THEN
      BEGIN
      SELECT PROJ_STAT_NAME INTO TEMP FROM SWE_PROJECT_STATUS WHERE ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'DEPT' THEN
      BEGIN
      SELECT DESCRIPTION INTO TEMP FROM SID.ORGANIZATIONS WHERE ORG_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'ROLE' THEN
      BEGIN
      SELECT ROLE_NAME INTO TEMP FROM SWE_ROLE WHERE ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'PROGRAM' THEN
      BEGIN
      SELECT PROGRAM_NAME INTO TEMP FROM SWE_PROGRAM WHERE PROGRAM_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'SSRL_AREA' THEN
      BEGIN
      SELECT AREA INTO TEMP FROM SSRL_RSW_AREA WHERE AREA_ID = P_VAL;
      EXCEPTION WHEN OTHERS THEN TEMP := P_VAL; END;
   END IF;

   IF P_ITEM = 'SSRL_FORM_STATUS' THEN
      begin
      SELECT STATUS INTO TEMP FROM SSRL_RSW_FORM_STATUS WHERE FORM_STATUS_ID = P_VAL;
      exception when others then temp := p_val; end;
   END IF;

RETURN TEMP;

END;
/
