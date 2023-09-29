INSERT INTO art_junc_div_userrole_user (div_code_id
                                        ,user_id
                                        ,status_ai_chk
                                        ,user_role_id)
SELECT div_code_id
       ,person_id
       ,status_ai_chk
       ,8
FROM art_users
WHERE art_users.person_id IN (SELECT student_num FROM art_pr_training
                              WHERE art_pr_training.status_ai_chk = 'A')
AND art_users.status_ai_chk = 'A'
AND NOT EXISTS(
    SELECT 1
    FROM art_junc_div_userrole_user
    WHERE art_junc_div_userrole_user.user_id = art_users.person_id
);