--------------------------------------------------------
--  File created - Thursday-June-24-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View ART_PROBLEMS_VW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE VIEW "MCC_MAINT"."ART_PROBLEMS_VW" ("PROB_ID", "STATUS", "PROB_TYPE", "PROB_SUBTYPE", "CREATED_DATE", "CREATED_BY", "MODIFIED_BY", "MODIFIED_DATE", "SHORT_DESCR", "DESCRIPTION", "AREA", "NUM_SOLS", "NUM_JOBS", "NUM_ACTIVE_SOLS", "NUM_INACTIVE_SOLS", "NUM_ACTIVE_JOBS", "NUM_INACTIVE_JOBS", "SHOP_MAIN", "SHOP_ALT", "SUBSYSTEM", "CLOSER", "AREAMGR", "BLDGMGR", "ASST_BLDGMGR", "ASSIGNEDTO", "MODIFIER", "BUILDING_NO", "FACILITY", "COMMENTS", "DISPLAY", "MICRO", "MICRO_OTHER", "PRIMARY", "UNIT", "OSMO_REVIEW", "OSMO_REVIEW_DATE", "OSMO_REVIEW_COMMENT", "OSMO_CLOSE_DATE", "OLD_CATER_PRIM_UNIT", "GROUP_RESP", "DATE_CLOSED", "AGE", "ERROR_MESSAGE", "TERMINAL_TYPE", "ESTIMATED_FIX_TIME", "INSPECTION_DATE", "INSTALLATION_DATE", "DATE_END", "DATE_START", "DATE_DUE_NEXT", "REPEAT_INTERVAL", "BOOKEEPING", "URGENCY", "REPRODUCIBLE", "REVIEW_DATE", "DISPLAY_ORDER", "WATCH_AND_WAIT_DATE", "WATCH_AND_WAIT_COMMENT", "REPORT_CLASSIFICATION_GROUP", "SEARCH_CRITERIA", "CHECKBOX_DATE_FLAGGED", "PRIORITY", "CEF_TRACKING_NO", "DUE_DATE", "CEF_REQUEST_SUBMITTED_CHK", "HOP", "MICRO_OR_IOC", "PV_NAME", "LOST_BEAMTIME", "MINLOST_DATE", "MAXLOST_DATE", "DIV_CODE_ID", "DIV_CODE", "GROUP_NAME", "PROBLEM_TITLE", "PROJECT_NAME", "ESTIMATED_HRS", "RELATED_PROB_ID") AS 
  SELECT a.prob_id,
          DECODE (a.status_chk,
                  0, 'New',
                  1, 'In Progress',
                  2, 'Scheduled',
                  3, 'RevToClose',
                  4, 'Closed',
                  'Unknown')
             status,
          INITCAP (a.prob_type_chk) prob_type,
	  (select prob_type_detail from art_problem_types
	   where prob_type_dtl_id = a.prob_type_dtl_id) prob_subtype,
          a.created_date,
          a.created_by,
          a.modified_by,
          a.modified_date,
          SUBSTR (a.description, 1, 80) short_descr,
          a.description,
          b.area,
          i.cc num_sols,
          j.cc num_jobs,
          (SELECT COUNT (sol_id) number_of_active_solutions
             FROM art_solutions
            WHERE prob_id = a.prob_id
                  AND NVL (review_to_close_chk, 'N') != 'Y')
             num_active_sols,
          (SELECT COUNT (sol_id) number_of_active_solutions
             FROM art_solutions
            WHERE prob_id = a.prob_id
                  AND NVL (review_to_close_chk, 'N') = 'Y')
             num_inactive_sols,
          (SELECT COUNT (job_id) number_of_active_jobs
             FROM art_jobs
            WHERE prob_id = a.prob_id AND status_chk = 0)
             num_active_jobs,
          (SELECT COUNT (job_id) number_of_active_jobs
             FROM art_jobs
            WHERE prob_id = a.prob_id AND status_chk != 0)
             num_inactive_jobs,
          e.shop shop_main,
          c.shop shop_alt,
          d.subsystem,
          f.name closer,
          g.name areamgr,
          h.name bldgmgr,
          k.name asst_bldgmgr,
          l.name assignedto,
          m.name modifier,
          n.building_no,
          o.facility,
          a.comments,
          a.display,
          a.micro,
          a.micro_other,
          a.primary,
          a.unit,
          DECODE (a.osmo_review_chk,  'Y', 'Yes',  'N', 'No',  NULL)
             osmo_review,
          a.osmo_review_date,
          a.osmo_review_comment,
          a.osmo_close_date,
          a.old_cater_prim_unit,
          a.group_resp,
          a.date_closed,
          ROUND (NVL (a.date_closed, SYSDATE) - a.created_date) age,
          a.error_message,
          a.terminal_type,
          a.estimated_fix_time,
          a.inspection_date,
          a.installation_date,
          a.date_end,
          a.date_start,
          a.date_due_next,
          a.repeat_interval,
          a.bookeeping,
          a.urgency,
          DECODE (a.reproducible_chk,  'Y', 'Yes',  'N', 'No',  NULL)
             reproducible,
          a.review_date,
          b.display_order,
          a.watch_and_wait_date,
          a.watch_and_wait_comment,
          a.report_classification_group,
          a.search_criteria,
          a.checkbox_date_flagged,
          a.priority_chk,
          a.cef_tracking_no,
          a.due_date,
          a.cef_request_submitted_chk,
          DECODE (a.hop_chk,  'Y', 'Yes',  'N', 'No',  NULL) hop,
          a.micro_or_ioc_chk micro_or_ioc,
          a.pv_name,
          q.cc lost_beamtime,
          q.minlost_date,
          q.maxlost_date,
          a.div_code_id,
          r.div_code,
          s.name group_name,
          a.problem_title,
          t.project_name,
          a.estimated_hrs,
	  a.related_prob_id
     FROM art_problems a,
          art_areas b,
          art_shops c,
          art_subsystems d,
          art_shops e,
          persons.person f,
          persons.person g,
          persons.person h,
          (  SELECT prob_id, COUNT (*) cc
               FROM art_solutions
           GROUP BY prob_id) i,
          (  SELECT prob_id, COUNT (*) cc
               FROM art_jobs
           GROUP BY prob_id) j,
          persons.person k,
          persons.person l,
          persons.person m,
          sid.buildings n,
          art_facilities o,
          (  SELECT prob_id,
                    SUM (timelost) cc,
                    MIN (lost_date) minlost_date,
                    MAX (lost_date) maxlost_date
               FROM art_beamlost_time
           GROUP BY prob_id) q,
          art_division_codes r,
          art_group s,
          art_projects t
    WHERE     a.area_id = b.area_id(+)
          AND a.shop_alt_id = c.shop_id(+)
          AND a.subsystem_id = d.subsystem_id(+)
          AND a.shop_main_id = e.shop_id(+)
          AND a.closer_id = f.key(+)
          AND a.areamgr_id = g.key(+)
          AND a.bldgmgr_id = h.key(+)
          AND a.prob_id = i.prob_id(+)
          AND a.prob_id = j.prob_id(+)
          AND a.asst_bldgmgr_id = k.key(+)
          AND a.assignedto_id = l.key(+)
          AND a.modifier_id = m.key(+)
          AND a.building_id = n.building_id(+)
          AND a.facility_id = o.facility_id(+)
          AND a.prob_id = q.prob_id(+)
          AND a.div_code_id = r.div_code_id(+)
          AND a.GROUP_ID = s.GROUP_ID(+)
          AND a.project_id = t.project_id(+)
;
