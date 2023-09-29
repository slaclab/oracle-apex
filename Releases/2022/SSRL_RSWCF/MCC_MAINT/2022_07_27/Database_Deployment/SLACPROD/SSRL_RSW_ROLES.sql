drop table ssrl_rsw_roles;
create table SSRL_RSW_ROLES (
	ROLE_ID		NUMBER not null,
	ROLE		VARCHAR2(100),
	ROLE_DESC	VARCHAR2(100),
	STATUS_AI_CHK	VARCHAR2(1) default 'A',
	DISPLAY_ORDER	NUMBER,
	CREATED_BY	VARCHAR2(30),
	CREATED_DATE	DATE,
	MODIFIED_BY	VARCHAR2(30),
	MODIFIED_DATE	DATE,
CONSTRAINT SSRL_RSW_ROLES_PK PRIMARY KEY (ROLE_ID)
USING INDEX
);

create unique index SSRL_RSW_ROLES_UDX1 
on SSRL_RSW_ROLES (ROLE);

insert into ssrl_rsw_roles (ROLE_ID,ROLE, ROLE_DESC) values (1, 'SSO', 'SSRL Safety Officer');
insert into ssrl_rsw_roles (ROLE_ID,ROLE, ROLE_DESC) values (2, 'DO', 'SSRL Duty Operator');
insert into ssrl_rsw_roles (ROLE_ID,ROLE, ROLE_DESC) values (3, 'RP', 'Radiation Physicist');
insert into ssrl_rsw_roles (ROLE_ID,ROLE, ROLE_DESC) values (4, 'RPFO', 'RPFO');
insert into ssrl_rsw_roles (ROLE_ID,ROLE, ROLE_DESC) values (5, 'AREA MANAGER', 'SSRL Area Manager');
insert into ssrl_rsw_roles (ROLE_ID,ROLE, ROLE_DESC) values (6, 'PPS', 'BCS/HCS/PPS Signoff');
insert into ssrl_rsw_roles (ROLE_ID,ROLE, ROLE_DESC) values (7, 'ADMIN', 'Admin');
insert into ssrl_rsw_roles (ROLE_ID,ROLE, ROLE_DESC) values (8, 'SUPER ADMIN','Super Admin');
insert into ssrl_rsw_roles (ROLE_ID,ROLE, ROLE_DESC) values (9, 'USER', 'User');

drop table ssrl_rsw_user_roles;
create table ssrl_rsw_user_roles (
	USER_ROLE_ID	NUMBER not null,
	ROLE_ID		NUMBER,
	USER_ID		NUMBER,
	STATUS_AI_CHK	VARCHAR2(1) default 'A',
	CREATED_BY	VARCHAR2(30),
	CREATED_DATE	DATE,
	MODIFIED_BY	VARCHAR2(30),
	MODIFIED_DATE	DATE,
CONSTRAINT SSRL_RSW_USER_ROLES_PK PRIMARY KEY (USER_ROLE_ID)
USING INDEX
);

create unique index SSRL_RSW_USER_ROLES_UDX1 
on SSRL_RSW_USER_ROLES (USER_ID, ROLE_ID);

drop SEQUENCE SSRL_RSW_ROLES_SEQ;
CREATE SEQUENCE SSRL_RSW_ROLES_SEQ
MINVALUE 1 
MAXVALUE 999999999999999999999999999 
INCREMENT BY 1 
START WITH 10 
NOCACHE  
NOORDER  
NOCYCLE;


-- Create Database Trigger --
SET DEFINE OFF;
CREATE OR REPLACE TRIGGER MCC_MAINT.SSRL_RSW_ROLES_BIUR
BEFORE INSERT OR UPDATE ON MCC_MAINT.SSRL_RSW_ROLES FOR EACH ROW
begin
 
  if inserting and :new.ROLE_ID is null
  then
    select SSRL_RSW_ROLES_SEQ.nextval into :new.ROLE_ID from dual;
  end if;
  
  if inserting and :new.created_by is null
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