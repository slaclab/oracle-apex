select *
from
(
select p.name d
      ,p.key
from art_user_roles             ur
    ,art_users                  u
    ,art_junc_div_userrole_user uru
    ,person                     p
where uru.user_id      = u.person_id
and   uru.user_role_id = ur.user_role_id
and   uru.div_code_id  = :P2_DIV_CODE_ID
and   p.key            = u.person_id
and   ((user_role      = 'PERSON RESPONSIBLE')
       or (user_role   = 'ADSO')
       or (user_role   = 'EOIC')
       or (user_role   = 'AREA MANAGER')
       or (user_role   = 'RDSO'))
union
select p.name
      ,p.key
from person p
where p.key = :P2_S1_TASK_PERSON_ID
) order by 1