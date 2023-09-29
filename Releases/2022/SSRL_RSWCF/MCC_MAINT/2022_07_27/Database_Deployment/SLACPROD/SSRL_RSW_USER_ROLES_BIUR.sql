-- Create Database Trigger --
SET DEFINE OFF;
create or replace TRIGGER SSRL_RSW_USER_ROLES_BIUR
BEFORE INSERT OR UPDATE ON SSRL_RSW_USER_ROLES FOR EACH ROW
declare
    jn_operation varchar2(3);
begin

  if inserting -- and :new.USER_ROLE_ID is null
  then
    select SSRL_RSW_USER_ROLES_SEQ.nextval into :new.USER_ROLE_ID from dual;
  end if;

  if inserting -- and :new.created_by is null
  then
    :new.created_by := nvl(v('APP_USER'),user);
    :new.created_date := sysdate;
  end if;

  if updating
  then
    :new.modified_by := nvl(v('APP_USER'),user);
    :new.modified_date := sysdate;
  end if;
end;
/

