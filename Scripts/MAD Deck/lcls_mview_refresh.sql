set pages 9999
spool lcls_mview_refresh_mcco.lst

drop table BKUP_LCLS_ELEMENTS;
drop table BKUP_V_SHOW_ELEMENT_DATA;
drop table BKUP_V_LCLS_ELEMENTS_REPORT;
drop table BKUP_V_LCLS_ELEMENTS_REP_PUB;
drop table BKUP_V_LCLS_BSA;
drop table BKUP_V_LCLS_BSA_BY_ELEMENT;

create table BKUP_LCLS_ELEMENTS as select * from LCLS_ELEMENTS;
create table BKUP_V_SHOW_ELEMENT_DATA as select * from V_SHOW_ELEMENT_DATA;
create table BKUP_V_LCLS_ELEMENTS_REPORT as select * from V_LCLS_ELEMENTS_REPORT;
create table BKUP_V_LCLS_ELEMENTS_REP_PUB as select * from V_LCLS_ELEMENTS_REPORT_PUBLIC;
create table BKUP_V_LCLS_BSA as select * from V_LCLS_BSA;
create table BKUP_V_LCLS_BSA_BY_ELEMENT as select * from V_LCLS_BSA_BY_ELEMENT;


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'LCLS_INFRASTRUCTURE.LCLS_ELEMENTS'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => FALSE
   ,NESTED               => FALSE);
END;
/

BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'LCLS_INFRASTRUCTURE.V_LCLS_BSA'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => FALSE
   ,NESTED               => FALSE);
END;
/

BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'LCLS_INFRASTRUCTURE.V_LCLS_BSA_BY_ELEMENT'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => FALSE
   ,NESTED               => FALSE);
END;
/

BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'LCLS_INFRASTRUCTURE.V_LCLS_ELEMENTS_REPORT'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => FALSE
   ,NESTED               => FALSE);
END;
/

BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'LCLS_INFRASTRUCTURE.V_LCLS_ELEMENTS_REPORT_PUBLIC'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => FALSE
   ,NESTED               => FALSE);
END;
/

BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'LCLS_INFRASTRUCTURE.V_SHOW_ELEMENT_DATA'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => FALSE
   ,NESTED               => FALSE);
END;
/

spool off;