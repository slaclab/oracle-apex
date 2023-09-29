  create or replace view SSRL_RSW_USER_ROLE_VW
  as
  SELECT p.fname, p.lname, p.name username,
  	 p.gonet,
	 p.sid_email alternate_email,
	 p.maildisp primary_email,
            uru.user_id sid,
	    uru.role_id,
            ur.role role,
	    ur.role_desc
       FROM ssrl_rsw_roles ur,
            ssrl_rsw_user_roles uru,
            person p
      WHERE nvl(uru.status_ai_chk,'A') = 'A'
        AND uru.user_id = p.key
        AND uru.role_id = ur.role_id
   ORDER BY 1;
/