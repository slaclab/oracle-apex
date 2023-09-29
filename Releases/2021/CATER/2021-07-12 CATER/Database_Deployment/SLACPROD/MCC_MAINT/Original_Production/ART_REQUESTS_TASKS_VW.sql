--------------------------------------------------------
--  File created - Thursday-June-24-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View ART_REQUESTS_TASKS_VW
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "MCC_MAINT"."ART_REQUESTS_TASKS_VW" ("PROB_ID", "GROUP_NAME", "REQUEST_STATUS", "PROB_TYPE_CHK", "RESPONSIBLE_PERSON", "REQUEST_TITLE", "REQUEST_DESCRIPTION", "WBS_DESCRIPTION", "AREA", "AREA_MANAGER", "REQUEST_SUBSYSTEM", "REQUEST_SHOP_MAIN", "REQUEST_CLOSER", "REQUEST_DATE_CLOSED", "REQUEST_COMMENTS", "REQUEST_AGE", "REQUEST_TYPE", "CUSTOMER_PRIORITY", "CUSTOMER_NEED_BY_DATE", "REQUEST_CREATED_DATE", "REQUEST_CREATED_BY", "REQUEST_MODIFIED_BY", "REQUEST_MODIFIED_DATE", "DIVISION", "TASK_NUMBER", "TASK_TITLE", "TASK_ASSIGNED_TO", "TASK_SUBSYSTEM", "TASK_SHOP_MAIN", "TASK_EFFORT_HOURS", "TASK_PRIORITY", "TASK_SKILL", "TASK_START_DATE", "TASK_END_DATE", "TASK_PERCENT_COMPLETE", "TASK_DESCRIPTION", "REVIEW_TO_CLOSE", "TASK_CREATED_DATE", "TASK_CREATED_BY", "TASK_MODIFIED_BY", "TASK_MODIFIED_DATE", "SOL_ID", "SOL_TYPE_CHK", "TASK_DIV_CODE_ID", "RELATED_PROB_ID") AS 
  SELECT P.PROB_ID,
    G.NAME GROUP_NAME,
    GETVAL ('PROB_STATUS', P.STATUS_CHK) CATER_STATUS,
    P.PROB_TYPE_CHK ,
    GETVAL ('NAME', P.ASSIGNEDTO_ID) RESPONSIBLE_PERSON,
    P.PROBLEM_TITLE,
    P.DESCRIPTION,
    GETVAL ('PROJECT', P.PROJECT_ID) WBS_DESCRIPTION,
    GETVAL ('AREA', P.AREA_ID) AREA,
    GETVAL ('NAME', P.AREAMGR_ID) AREAMGR,
    GETVAL ('SUBSYSTEM', P.SUBSYSTEM_ID) REQUEST_SUBSYSTEM,
    GETVAL ('SHOP', P.SHOP_MAIN_ID) REQUEST_SHOP_MAIN,
    GETVAL ('NAME', P.CLOSER_ID) CLOSER,
    P.DATE_CLOSED ,
    P.COMMENTS,
    ROUND (NVL (P.date_closed, SYSDATE) - P.created_date) REQUEST_AGE,
    GETVAL ('REQUEST_TYPE', P.SW_REQUEST_TYPE) REQUEST_TYPE,
    P.PRIORITY_CHK,
    P.DUE_DATE,
    P.CREATED_DATE,
    P.CREATED_BY,
    P.MODIFIED_BY,
    P.MODIFIED_DATE,
    GETVAL ('DIV_CODE', P.DIV_CODE_ID) DIV_CODE,
    S.SOLUTION_NUMBER,
    S.TASK_TITLE,
    GETVAL ('NAME', S.SOLVEDBY_ID) TASK_ASSIGNED_TO,
    GETVAL ('SUBSYSTEM', S.SUBSYSTEM_ID) TASK_SUBSYSTEM,
    GETVAL ('SHOP', S.SHOP_MAIN_ID) TASK_SHOP_MAIN,
    s.SOLVE_HOURS,
    S.TASK_PRIORITY_CHK,
    s.TASK_SKILL,
    s.TASK_START_DATE,
    s.TASK_END_DATE,
    s.TASK_PERCENT_COMPLETE,
    s.DESCRIPTION,
    GETVAL ('YESNO', S.REVIEW_TO_CLOSE_CHK) REVIEW_TO_CLOSE,
    S.CREATED_DATE,
    S.CREATED_BY,
    S.MODIFIED_BY,
    S.MODIFIED_DATE,
    S.SOL_ID,
    S.SOL_TYPE_CHK,
    S.DIV_CODE_ID,
    P.RELATED_PROB_ID
    FROM  ART_PROBLEMS P,
          ART_SOLUTIONS S,
          ART_GROUP G
    WHERE P.PROB_ID = S.PROB_ID(+)
    AND P.GROUP_ID = G.GROUP_ID(+)
;
