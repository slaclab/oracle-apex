BEGIN
  SYS.DBMS_SCHEDULER.DROP_JOB
    (job_name  => 'LCLS_INFRASTRUCTURE.UPDATE_SAFETY_SYSTEM_JOB');
END;
/
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'LCLS_INFRASTRUCTURE.UPDATE_SAFETY_SYSTEM_JOB',
            job_type => 'STORED_PROCEDURE',
            job_action => 'LCLS_INFRASTRUCTURE.UPDATE_SAFETY_SYSTEM',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2022-09-14 17:13:22.000000000 AMERICA/LOS_ANGELES','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=DAILY;BYTIME=040000',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => FALSE,
            comments => 'Updates the SAFETY_SYSTEM values based on BCS, PPS and MPS Safety System values in MAGNET_STRING');

    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'LCLS_INFRASTRUCTURE.UPDATE_SAFETY_SYSTEM_JOB', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'LCLS_INFRASTRUCTURE.UPDATE_SAFETY_SYSTEM_JOB', 
             attribute => 'raise_events', value => '492');
 END;
/ 
BEGIN
 DBMS_SCHEDULER.ADD_JOB_EMAIL_NOTIFICATION (
  job_name   =>  'UPDATE_SAFETY_SYSTEM_JOB',
  recipients =>  'poonam@slac.stanford.edu',
  sender     =>  'update_safety_system_job@slac.stanford.edu',
  subject    =>  'Scheduler Job Notification-%job_owner%.%job_name%-%event_type%',
  body       =>   '%event_type% occurred at %event_timestamp%. %error_message%',
  events     =>  'JOB_FAILED, JOB_STOPPED, JOB_BROKEN, JOB_DISABLED, JOB_SCH_LIM_REACHED');
END;
/

BEGIN

    DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'LCLS_INFRASTRUCTURE.UPDATE_SAFETY_SYSTEM_JOB'
     ,attribute => 'RAISE_EVENTS'
     ,value     => SYS.DBMS_SCHEDULER.JOB_FAILED + SYS.DBMS_SCHEDULER.JOB_BROKEN + SYS.DBMS_SCHEDULER.JOB_STOPPED + SYS.DBMS_SCHEDULER.JOB_SCH_LIM_REACHED + SYS.DBMS_SCHEDULER.JOB_DISABLED + SYS.DBMS_SCHEDULER.JOB_CHAIN_STALLED);

    DBMS_SCHEDULER.enable(
             name => 'LCLS_INFRASTRUCTURE.UPDATE_SAFETY_SYSTEM_JOB');
END;
/