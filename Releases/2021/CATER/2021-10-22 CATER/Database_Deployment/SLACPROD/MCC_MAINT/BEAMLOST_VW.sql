CREATE OR REPLACE FORCE VIEW "BEAMLOST_VW" ("PROB_ID", "STATUS", "PROB_TYPE", "CREATED_DATE", "CREATED_BY", "MODIFIED_BY", "MODIFIED_DATE", "SHORT_DESCR", "DESCRIPTION", "AREA", "NUM_SOLS", "NUM_JOBS", "SHOP_MAIN", "SHOP_ALT", "SUBSYSTEM", "CLOSER", "AREAMGR", "BLDGMGR", "ASST_BLDGMGR", "ASSIGNEDTO", "MODIFIER", "BUILDING_NO", "PRIORITY", "FACILITY", "COMPLEVEL", "SUMTIME", "LOST_DATE", "PROGRAM", "PARENT_PROGRAM", "BTIME_ID", "SHIFT", "SHIFT_ORDERING", "CODE_NAME", "ID", "MICRO", "PRIMARY", "UNIT", "URGENCY", "DIV_CODE_ID", "DIV_CODE", "YEAR", "SEPARATE_EVENT_VALUE", "SECONDARY_PROGRAM_VALUE", "AREA_MGR_REVIEW_DATE", "AREA_MGR_REVIEW_COMMENTS") AS 
  select a.prob_id
      ,decode (a.status_chk,
                0, 'New',
                1, 'In Progress',
                2, 'Scheduled',
                3, 'RevToClose',
                4, 'Closed',
                'Unknown'
               ) status
      ,initcap (a.prob_type_chk) prob_type
      ,a.created_date
      ,a.created_by
      ,a.modified_by
      ,a.modified_date
      ,substr (a.description, 1, 80) short_descr
      ,a.description
      ,b.area
      ,i.cc num_sols
      ,j.cc num_jobs
      ,e.shop shop_main
      ,c.shop shop_alt
      ,d.subsystem
      ,f.name closer
      ,g.name areamgr
      ,h.name bldgmgr
      ,k.name asst_bldgmgr
      ,l.name assignedto
      ,m.name modifier
      ,n.building_no
      ,p.priority
      ,o.facility
      ,component_level (q.id) complevel
      ,q.timelost sumtime
      ,q.lost_date
      ,s.program
      ,v.program parent_program
      ,q.btime_id
      ,decode(q.lost_shift_chk,1,'Owl',2,'Day',3,'Swing',null,'Unknown') shift
      ,decode(q.lost_shift_chk,1,3,2,2,3,1,null,4) shift_ordering
      ,t.code_name
      ,t.id
      ,a.micro
      ,a.primary
      ,a.unit
      ,a.urgency
      ,u.div_code_id
      ,u.div_code
      ,to_char(a.created_date,'yyyy') year
      ,decode(q.separate_chk,'Y',1,0) separate_event_value
      ,decode(q.secondary_program_chk,'Y',1,0) secondary_program_value
      ,a.area_mgr_review_date
      ,a.area_mgr_review_comments
from art_problems   a
    ,art_areas      b
    ,art_shops      c
    ,art_subsystems d
    ,art_shops      e
    ,persons.person f
    ,persons.person g
    ,persons.person h
    ,(select   prob_id, count (*) cc
             from art_solutions
            where review_to_close_chk != 'Y'
         group by prob_id) i,
        (select   prob_id, count (*) cc
             from art_jobs
            where status_chk = 0
         group by prob_id) j
    ,persons.person     k
    ,persons.person     l
    ,persons.person     m
    ,sid.buildings      n
    ,art_facilities     o
    ,art_priorities     p
    ,art_beamlost_time  q
    ,(select prob_id
            ,id
            ,prog_id
            ,sum (timelost) cc
      from art_beamlost_time
      group by prob_id, id, prog_id) r
    ,art_programs       s
    ,art_beamlost_tree  t
    ,art_division_codes u
    ,art_programs       v
where a.area_id         = b.area_id     (+)
and   a.shop_alt_id     = c.shop_id     (+)
and   a.subsystem_id    = d.subsystem_id(+)
and   a.shop_main_id    = e.shop_id     (+)
and   a.closer_id       = f.key         (+)
and   a.areamgr_id      = g.key         (+)
and   a.bldgmgr_id      = h.key         (+)
and   a.prob_id         = i.prob_id     (+)
and   a.prob_id         = j.prob_id     (+)
and   a.asst_bldgmgr_id = k.key         (+)
and   a.assignedto_id   = l.key         (+)
and   a.modifier_id     = m.key         (+)
and   a.building_id     = n.building_id (+)
and   a.facility_id     = o.facility_id (+)
and   a.priority_chk    = p.priority_id (+)
and   a.prob_id         = q.prob_id
and   q.prob_id         = r.prob_id     (+)
and   q.id              = r.id          (+)
and   q.prog_id         = r.prog_id     (+)
and   q.prog_id         = s.prog_id     (+)
and   r.id              = t.id          (+)
and   a.div_code_id     = u.div_code_id
and   s.parent_id       = v.prog_id     (+);