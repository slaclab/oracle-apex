alter table art_problems add pa_number varchar2(50);
alter table art_problems_jn add pa_number varchar2(50);

alter table art_problems_email add pa_number varchar2(50);
alter table art_problems_email_jn add pa_number varchar2(50);

comment on column art_problems.pa_number is '"Project Activity Number".  Often, we call these charge codes.';

