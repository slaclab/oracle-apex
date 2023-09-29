UPDATE art_pr_training
SET status_ai_chk = 'A'
WHERE student_num IN (
    SELECT key
    FROM person
    WHERE gonet = 'ACTIVE'
);

UPDATE art_pr_training
SET status_ai_chk = 'I'
WHERE student_num IN (
    SELECT key
    FROM person
    WHERE gonet != 'ACTIVE'
);

commit;
