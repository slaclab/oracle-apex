create or replace PACKAGE BODY          "CAPTARIN" 
IS
-----------------------------------------------------------------------------
-- Name          : CAPTAR.CAPTARIN (Spreadsheet Upload Program)
--
-- Purpose       : Reads Cable information from a table, validates and
--                 Post the information into respective CAPTAR table.
--
-- Options       : VALIDATE : Validate the data of a specified file.
--                 PROCESS  : Validate and Process the data of a specified file.
--
-- Author        : Venkat Samineni
--
-- Date                  Comments
-- ~~~~                  ~~~~~~~~
-- June 12, 2002         Initial Code by Venkat
-- Dec  08, 2006         Modified to accomidate the Overwrite option by Venkat
-- Jan 14, 2008          Modified to read the CSV file and load into temp table through APEX by Elie
-- Jan  15, 2008         Modified to read from a table instead of a excel file
-- June 12, 2008         Modified to include some additional delete statements for overwrite option
--                                add to rollback the deletes if it is a validation.
-- June 13, 2017         Modified to accomodate the ROUTING field length change from 50 to 1000 by Venkat
-- June 12, 2018         Modified to accomodate folowing field length changes by Venkat  - DEV-8189
--                                Formal Device Name: 14 to 50
--                                Cable Function: 33 to 120
--                                Origin/Destination Termination Point:
--                                  Loc: 6 to 20
--                                  Rack: 6 to 40
--                                  Connector number: 8 to 30
--                                Drawing #: 18 to 200
-- Feb 26, 2019         Modified to accomodate folowing field length changes by Venkat  - DEV-8189
--                                Cable_type/cabletype: 8 to 15
-- Mar 03, 2019		Added the insert into DRAWING # and DRAWING_TITLE fields in CABLEINV,
--			as they were not getting updated into the target table through the Upload program.
-- Apr 28, 2022         Modified to accomodate folowing field length changes by Poonam
--                                Area_Code: 7 to 10
--                                Jobnum : 6 to 10
----------------------------------------------------------------------------------------------------------

  TYPE varchar2_t IS TABLE OF VARCHAR2(32767) INDEX BY binary_integer;
  process_upload_id number;

  PROCEDURE csv_to_array (
            p_csv_string IN  VARCHAR2,
            p_array      OUT wwv_flow_global.vc_arr2,
            p_separator  IN  VARCHAR2        := ','
                         )
  IS
    -- Utility to take a CSV string, parse it into a PL/SQL table
    -- Note that it takes care of some elements optionally enclosed
    -- by double-quotes.
    l_start_separator PLS_INTEGER     := 0;
    l_stop_separator  PLS_INTEGER     := 0;
    l_length          PLS_INTEGER     := 0;
    l_idx             BINARY_INTEGER  := 0;
    l_quote_enclosed  BOOLEAN         := FALSE;
    l_offset          PLS_INTEGER     := 1;

    V_ERRMSG   VARCHAR2(1000) := NULL;  -- ELIE ADDED 30-JAN-2013

    C_PROC  CONSTANT  VARCHAR2(100) := 'CAPTARIN.CSV_TO_ARRAY';  -- ELIE ADDED 30-JAN-2013

  BEGIN
    l_length := NVL(LENGTH(p_csv_string),0);
    IF (l_length <= 0) THEN
       RETURN;
    END IF;
    LOOP
      l_idx := l_idx + 1;
      l_quote_enclosed := FALSE;
      IF SUBSTR(p_csv_string, l_start_separator + 1, 1) = '"' THEN
         l_quote_enclosed := TRUE;
         l_offset := 2;
         l_stop_separator := INSTR(p_csv_string, '"', l_start_separator + l_offset, 1);
      ELSE
         l_offset := 1;
         l_stop_separator := INSTR(p_csv_string, p_separator, l_start_separator + l_offset, 1);
      END IF;
      IF l_stop_separator = 0 THEN
         l_stop_separator := l_length + 1;
      END IF;
      p_array(l_idx) := (SUBSTR(p_csv_string, l_start_separator + l_offset,(l_stop_separator - l_start_separator - l_offset)));
      EXIT WHEN l_stop_separator >= l_length;
      IF l_quote_enclosed THEN
         l_stop_separator := l_stop_separator + 1;
      END IF;
      l_start_separator := l_stop_separator;
    END LOOP;

    RETURN;  -- ELIE ADDED 30-JAN-2013

    -- ELIE ADDED EXCEPTION BLOCK 30-JAN-2013
  EXCEPTION
    WHEN OTHERS THEN
      V_ERRMSG := SUBSTR('OTHERS ERROR ('||C_PROC||')=>'||SQLERRM,1,1000);
      RAISE_APPLICATION_ERROR(-20100, V_ERRMSG);

  END csv_to_array;

  --------------------------

  PROCEDURE get_records(
            p_blob IN blob,
            p_records OUT varchar2_t)
  IS
    l_record_separator VARCHAR2(2) := chr(13)||chr(10);
    l_last             INTEGER;
    l_current          INTEGER;

    V_ERRMSG  VARCHAR2(1000) := NULL;

    C_PROC    CONSTANT  VARCHAR2(100) := 'CAPTARIN.GET_RECORDS';

  BEGIN
    -- Sigh, stupid DOS/Unix newline stuff. If HTMLDB has generated the file,
    -- it will be a Unix text file. If user has manually created the file, it
    -- will have DOS newlines.
    -- If the file has a DOS newline (cr+lf), use that
    -- If the file does not have a DOS newline, use a Unix newline (lf)
    IF (NVL(dbms_lob.instr(p_blob,utl_raw.cast_to_raw(l_record_separator),1,1),0)=0) THEN
       l_record_separator := chr(10);
    END IF;
    l_last := 1;
    LOOP
      l_current := dbms_lob.instr( p_blob, utl_raw.cast_to_raw(l_record_separator), l_last, 1 );
      EXIT WHEN (nvl(l_current,0) = 0);
      p_records(p_records.count+1) := utl_raw.cast_to_varchar2(dbms_lob.substr(p_blob,l_current-l_last,l_last));
      l_last := l_current+length(l_record_separator);
    END LOOP;

    RETURN;


    -- ELIE ADDED EXCEPTION BLOCK 30-JAN-2013
  EXCEPTION
    WHEN OTHERS THEN
      V_ERRMSG := SUBSTR('OTHERS ERROR ('||C_PROC||')=>'||SQLERRM,1,1000);
      RAISE_APPLICATION_ERROR(-20200, V_ERRMSG);

  END get_records;

  PROCEDURE parse_file(
        p_val_or_proc     IN VARCHAR2,
        p_new_or_over     IN VARCHAR2,
        p_file_name       IN VARCHAR2,
        p_comments        IN VARCHAR2,
        p_IgnoreErrors    IN VARCHAR2,
        p_upload_id       IN OUT NUMBER,
        p_discrepancy_cnt IN OUT NUMBER,
        p_errmsg          IN OUT VARCHAR2
        )
  IS
    l_blob        blob;
    l_records     varchar2_t;
    l_record      wwv_flow_global.vc_arr2;
    l_seq_id      number;
    test          number;
    dis_cnt       number;
    temp          varchar2(4000);
    v_user        varchar2(100) := upper(nvl(v('APP_USER'),user));
    v_dt          date;
    v_msg         varchar2(4000);
    crlf          varchar2(2) := chr(10)||chr(13);
    num_cols_init number;
    p_num_cols    number := 36;
    l_debug       boolean := FALSE;
    nnn number := 5;
    temp1   varchar2(1000) := null;
    col_val varchar2(1000) := null;

    C_PROC    CONSTANT   VARCHAR2(100) := 'CAPTARIN.PARSE_FILE';

    PROC_ERROR    EXCEPTION;

  BEGIN
    p_upload_id       := null;
    p_discrepancy_cnt := null;
    p_errmsg          := null;
    v_msg := null;
    FileName := p_file_name;

    BEGIN
      select blob_content into l_blob
      from   wwv_flow_files
      where  name = p_file_name;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           P_ERRMSG := SUBSTR('ERROR ('||C_PROC||'): FILE "'||P_FILE_NAME||'" NOT FOUND.',1,1000);
           raise_application_error(-20001, P_ERRMSG);
    END;

                      if ( l_debug ) then
                        htp.p('<table bgcolor=black cellpadding=1>');
                        htp.p('<tr><td><font color=yellow>Before Get Records</font></td></tr>');
                        htp.p('</table>');
                      end if;

    get_records(l_blob,l_records);

                      if ( l_debug ) then
                        htp.p('<table bgcolor=black cellpadding=1>');
                        htp.p('<tr><td><font color=yellow>After Get Records</font></td></tr>');
                        htp.p('</table>');
                      end if;

   --fetch a new batch id for this upload
    begin
      select CAPTARIN_UPLOAD_LOG_SEQ.nextval into p_upload_id from dual;
      -- htmldb_util.set_session_state('P1_UPLOAD_ID',upload_id);

      process_upload_id := p_upload_id;

      select sysdate into v_dt from dual;

      temp := p_file_name;
      test := instr(p_file_name,'/');
      if test > 0 then
         temp := substr(temp,test+1);
      end if;

      insert into captarin_upload_log
            (upload_id, date_uploaded, uploaded_by, comments, filename, version_date,
              val_or_proc, new_or_over, IgnoreErrors)
      values (p_upload_id, v_dt, v_user, p_comments, temp, v_dt,
              p_val_or_proc,p_new_or_over,p_IgnoreErrors);

    EXCEPTION
      WHEN others THEN
           P_ERRMSG := SUBSTR('OTHERS ERROR ('||C_PROC||'): INSERT INTO CAPTARIN_UPLOAD_LOG FOR UPLOAD_ID='||TO_CHAR(P_UPLOAD_ID)||'=>'||SQLERRM,1,1000);
           raise_application_error(-20002, P_ERRMSG);
    end;

     -- Initialize extra columns for this row if there are less than the number of needed columns for the underlying table MPS_UPLOAD.
     BEGIN
                  if ( l_record.count < p_num_cols ) then
                    num_cols_init := 0;
                    for q in l_record.count+1 .. p_num_cols loop
                      num_cols_init := num_cols_init + 1;
                      l_record(q) := null;
                      if ( l_debug ) then
                        htp.p('<table bgcolor=black cellpadding=1>');
                        htp.p('<tr><td><font color=yellow>PARSE_FILE: ADDING EXTRA COLUMNS: l_record('||to_char(q)||')</font></td></tr>');
                        htp.p('</table>');
                      end if;
                    end loop;

                    if ( l_debug ) then
                      htp.p('<table bgcolor=black cellpadding=1>');
                      htp.p('<tr><td><font color=yellow>==== PARSE_FILE: AFTER INITIALIZING ALL EXTRA COLUMNS ====</font></td></tr>');
                      htp.p('<tr><td><font color=yellow>NUM COLUMNS INITIALIZED='||to_char(num_cols_init)||'</font></td></tr>');
                      htp.p('</table>');
                    end if;
                  end if;

     EXCEPTION
      WHEN others THEN
           P_ERRMSG := SUBSTR('OTHERS ERROR ('||C_PROC||'): INITIALIZE COLUMNS SECTION FOR P_NUM_COLS='||TO_CHAR(P_NUM_COLS)||'=>'||SQLERRM,1,1000);
           raise_application_error(-20003, P_ERRMSG);
     END;

     ------------------

    FOR i IN 6..l_records.count
        LOOP
          csv_to_array(l_records(i),l_record);
          begin
            if l_record(3) is not null then
               insert into captarin_upload (id,
                                            upload_id,
                                            cablenum,
                                            formal_device_name,
                                            cable_function,
                                            cable_type,
                                            origin_loc,
                                            origin_rack,
                                            origin_side,
                                            origin_ele,
                                            origin_slot,
                                            origin_conn,
                                            origin_pin_list,
                                            origin_conn_type,
                                            origin_station,
                                            origin_ins,
                                            dest_loc,
                                            dest_rack,
                                            dest_side,
                                            dest_ele,
                                            dest_slot,
                                            dest_conn,
                                            dest_pin_list,
                                            dest_conn_type,
                                            dest_station,
                                            dest_ins,
                                            length,
                                            routing,
                                            revision,
                                            job,
                                            drawing,
                                            drawing_title,
                                            user_id,
                                            list_title,
                                            area_code,
                                            username,
                                            date_created,
                                            created_by,
                                            date_updated,
                                            updated_by)
                                    values (captarin_upload_seq.nextval,
                                            p_upload_id,
                                            l_record(3),
                                            l_record(4),
                                            l_record(5),
                                            l_record(6),
                                            l_record(7),
                                            l_record(8),
                                            l_record(9),
                                            l_record(10),
                                            l_record(11),
                                            l_record(12),
                                            l_record(13),
                                            l_record(14),
                                            l_record(15),
                                            l_record(16),
                                            l_record(17),
                                            l_record(18),
                                            l_record(19),
                                            l_record(20),
                                            l_record(21),
                                            l_record(22),
                                            l_record(23),
                                            l_record(24),
                                            l_record(25),
                                            l_record(26),
                                            l_record(27),
                                            l_record(28),
                                            l_record(29),
                                            l_record(30),
                                            l_record(31),
                                            l_record(32),
                                            l_record(33),
                                            l_record(34),
                                            l_record(35),
                                            v_user,
                                            v_dt,
                                            v_user,
                                            null,
                                            null);
            end if;
          exception
              when others then
                   -- raise_application_error(-20004,SQLERRM||' Error in line: '||i||', List Title:'||l_record(34)||', Column Count: '||l_record.count);
                   v_msg := substr(c_proc||'=>'||sqlerrm||crlf||' Error in line: '||to_char(i)||': Column Count: '||to_char(l_record.count)||crlf||
                                               --'l_record(1)='||l_record(1)||crlf||
                                               --'l_record(2)='||l_record(2)||crlf||
                                               'l_record(3)='||l_record(3)||crlf||
                                               --'l_record(4)='||l_record(4)||crlf||
                                               --'l_record(5)='||l_record(5)||crlf||
                                               --'l_record(6)='||l_record(6)||crlf||
                                               --'l_record(7)='||l_record(7)||crlf||
                                               'l_record(8)='||l_record(8)||crlf||
                                               --'l_record(9)='||l_record(9)||crlf||
                                               'l_record(10)='||l_record(10)||crlf||
                                               --'l_record(11)='||l_record(11)||crlf||
                                               --'l_record(12)='||l_record(12)||crlf||
                                               --'l_record(13)='||l_record(13)||crlf||
                                               --'l_record(14)='||l_record(14)||crlf||
                                               --'l_record(15)='||l_record(15)||crlf||
                                               --'l_record(16)='||l_record(16)||crlf||
                                               --'l_record(17)='||l_record(17)||crlf||
                                               'l_record(18)='||l_record(18)||crlf||
                                               --'l_record(19)='||l_record(19)||crlf||
                                               'l_record(20)='||l_record(20)||crlf||
                                               --'l_record(21)='||l_record(21)||crlf||
                                               --'l_record(22)='||l_record(22)||crlf||
                                               --'l_record(23)='||l_record(23)||crlf||
                                               --'l_record(24)='||l_record(24)||crlf||
                                               --'l_record(25)='||l_record(25)||crlf||
                                               --'l_record(26)='||l_record(26)||crlf||
                                               'l_record(27)='||l_record(27)||crlf||
                                               --'l_record(28)='||l_record(28)||crlf||
                                               --'l_record(29)='||l_record(29)||crlf||
                                               --'l_record(30)='||l_record(30)||crlf||
                                               --'l_record(31)='||l_record(31)||crlf||
                                               --'l_record(32)='||l_record(32)||crlf||
                                               --'l_record(33)='||l_record(33)||crlf||
                                               'l_record(34)='||l_record(34)||crlf||
                                               'l_record(35)='||l_record(35),1,4000);

                   raise_application_error(-20005,v_msg);
          end;
        END LOOP;

        ----------------------------

        LoadData (OperatorName => v_user,
                  RunOption    => p_val_or_proc,
                  DataStatus   => p_new_or_over,
                  IgnoreErrors => p_IgnoreErrors,
                  p_uploadid   => p_upload_id,
                  p_errmsg     => p_errmsg);

       -------------------------

        IF ( P_ERRMSG IS NULL ) THEN

          select count(*) into p_discrepancy_cnt from captarin_discrepancies;

          delete from wwv_flow_files      where name = p_file_name;

          COMMIT;  -- ELIE ADDED 31-JAN-2013 JUST FOR TEST PURPOSES

        /*  ELIE COMMENTED OUT 30-JAN-2013
          if ( (p_val_or_proc = 'VALIDATE') or (p_discrepancy_cnt > 0) or (p_errmsg is not null) ) then
            -- delete from captarin_upload_log where upload_id = p_upload_id;
            null;
          end if;

          commit;
          */

         -- ELIE ADDED THIS IF-ENDIF BLOCK 30-JAN-2013
          if ( (p_val_or_proc = 'VALIDATE') or (p_discrepancy_cnt > 0) ) then
            ROLLBACK;
          ELSE
            COMMIT;
          end if;

      ELSE

        RAISE PROC_ERROR;

      END IF;

      RETURN;

   EXCEPTION
     WHEN PROC_ERROR THEN
       ROLLBACK;
       RETURN;
     WHEN OTHERS THEN
       P_ERRMSG := SUBSTR('OTHERS ERROR ('||C_PROC||')=>'||SQLERRM,1,1000);
       ROLLBACK;
       RETURN;

   END PARSE_FILE;

   ------------------------------------------------------------

  function setit (RunOption VARCHAR2,
                req      in varchar2,
                adjust   in varchar2,
                len      in number,
                name     in varchar2,
                defa     in varchar2, -- default value
                value    in varchar2,
                squash   in number,
                mID      in number,
                p_errmsg in out varchar2)
  return varchar2
  is
    newvalue varchar2(1000);
    SetitDataValidationIssue EXCEPTION;
  begin
    p_errmsg := null;
    newvalue := value;
     If squash = 1 then
        newvalue := replace(newvalue,'  ',' ');
     else
        newvalue := trim(newvalue);
      end if;

     if newvalue = '' or newvalue is null then
        newvalue := defa;
     end if;

     if substr(newvalue,1,1) = '"' then
        newvalue := substr(value,2,length(newvalue)-2);
     end if;

     if length(newvalue) > len Then
        IF RunOption = 'VALIDATE' THEN
           INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type, discrp_status,
              description, file_name, discrp_source, line_no, id)
           VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
              'Line: ' || TO_CHAR(LineNumber) || 'Value length error ' ||
              name || ' val=' || value || ' expected len=' ||
              len || ', real=' || length(newvalue) || '.', NULL, 'CAPTARIN', LineNumber, mID);
        ELSE
           p_errmsg := '(1): Data is invalid in SETIT procedure for '||name||'. Process terminated.';
           RAISE SetitDataValidationIssue;
        END IF;
     end if;
     if length(newvalue) = 0 then
        if req = 'R' then
           IF RunOption = 'VALIDATE' THEN
              INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type, discrp_status,
                 description, file_name, discrp_source, line_no, id)
              VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                 'Line: ' || TO_CHAR(LineNumber) || ', Required field found blank for:' ||
                 name || '- ' || newvalue, NULL, 'CAPTARIN', LineNumber, mID);
           ELSE
              p_errmsg := '(2): Data is invalid in SETIT procedure for '||name||'. Process terminated.';
              RAISE SetitDataValidationIssue;
           END IF;
        end if;
     End if;
    --if adjust = 'N' then
    --   if datatype(newvalue) = 'CHAR' Then
    --      etemp := name || ' value not numeric.. val=' || value;
    --      --Call DoSay 'Error  : cable 'left(cablenum,9)' line 'right(j,3) etemp
    --      error := error + 1;
    --   endif;
    --endif;
    return trim(newvalue);
  EXCEPTION
    WHEN SetitDataValidationIssue THEN
         return trim(newvalue);
         -- RAISE_APPLICATION_ERROR(-20006, 'Data is invalid in SETIT procedure. Process terminated.');
    WHEN OTHERS THEN
         p_errmsg := substr('Problem occurred in SetIt function for '||name||': '||sqlerrm,1,300);
         return trim(newvalue);
  end setit;

  PROCEDURE LoadData (OperatorName in VARCHAR2,
                      RunOption    in VARCHAR2,
                      DataStatus   in VARCHAR2,
                      IgnoreErrors in VARCHAR2,
                      p_uploadid   in NUMBER,
                      p_errmsg     in out VARCHAR2)
  IS
  -----------------------------------------------------------------------------
  -- Name          : CAPTAR.CAPTARIN (Spreadsheet Upload Program)
  --
  -- Purpose       : Reads Cable information from a table, validates and
  --                 Post the information into respective CAPTAR table.
  --
  -- Options       : VALIDATE : Validate the data of a specified file.
  --                 PROCESS  : Validate and Process the data of a specified file.
  --
  -- Author        : Venkat Samineni
  --
  -- Date                  Comments
  -- ~~~~                  ~~~~~~~~
  -- June 12, 2002         Initial Code
  -- Dec  08, 2006         Modified to accomidate hte Overwrite option
  --                       and to read from a table instead of a excel file
  -----------------------------------------------------------------------------
  --
  -- Local Data Validation Variables.
  --
  PrevTitle captar.cable_listing.list_title%type;
  PrevArea captar.cable_listing.area_code%type;
  PrevJobnum captar.cableinv.jobnum%type;
  RecCheck NUMBER := 0;
  --FileName VARCHAR2(1) :=  '';
  --
  -- Local Variables.
  --
  CheckPin_Status captar.pin.status%type;
  CheckPin_Cablenum captar.conductor.cablenum%type;
  ListNo captar.cable_listing.list_no%type;
  Condnum captar.condnum.condnum%type;

  CODEPOINT   INTEGER;

  C_PROC     CONSTANT   VARCHAR2(100) := 'CAPTARIN.LOADDATA';

  TYPE cd_record IS TABLE OF captarin_discrepancies%ROWTYPE;
  l_table cd_record;

  --
  -- Cursor to get the data
  --
  cursor c1 is SELECT * FROM captarin_upload WHERE upload_id = p_uploadid;
  --cursor c1 is SELECT * FROM captarin_upload WHERE username = OperatorName;

  cursor c2 is select *
               from   captarin_discrepancies
               where  upper(discrp_source) = 'CAPTARIN'
                      and created_by = OperatorName
                      and upload_id = p_uploadid
               order  by discrepancy_id;

  Invalid_RunOption    EXCEPTION;
  Invalid_DataStatus   EXCEPTION;
  Invalid_OperatorName EXCEPTION;
  DataValidationIssue  EXCEPTION;
  Setit_Error          EXCEPTION;

  BEGIN
    LineNumber := 0;
    p_errmsg := null;

    CODEPOINT := 0;
    --
    -- Check parameter values are valid.
    --
    IF RunOption NOT IN ('VALIDATE', 'PROCESS') THEN
       RAISE Invalid_RunOption;
    END IF;

    IF DataStatus NOT IN ('NEW', 'OVERWRITE') THEN
       RAISE Invalid_DataStatus;
    END IF;

    IF OperatorName IS NULL THEN
       RAISE Invalid_OperatorName;
    END IF;
    --
    -- Delete all captarin_discrepancies associated with this Process and the Opertator.
    --

    --DELETE FROM captarin_discrepancies WHERE UPPER(discrp_source) = 'CAPTARIN' AND created_by = OperatorName;

    -- Save point to rollback the changes if the option is VALIDATE and OVERWRITE,
    -- initial delete statements should be rolledback and the discrepancy table inserts should be commited.

    CODEPOINT := 1;
    savepoint del_rows;
    CODEPOINT := 2;
    open c1;
    loop
      CODEPOINT := 3;
      fetch c1 into mID,mUPLOAD_ID,mCABLENUM,mFORMAL_DEVICE_NAME,mCABLE_FUNCTION,mCABLE_TYPE,mORIGIN_LOC,
        mORIGIN_RACK,mORIGIN_SIDE,mORIGIN_ELE,mORIGIN_SLOT,mORIGIN_CONN,mORIGIN_PIN_LIST,
        mORIGIN_CONN_TYPE,mORIGIN_STATION,mORIGIN_INS,mDEST_LOC,mDEST_RACK,mDEST_SIDE,
        mDEST_ELE,mDEST_SLOT,mDEST_CONN,mDEST_PIN_LIST,mDEST_CONN_TYPE,mDEST_STATION,
        mDEST_INS,mLENGTH,mROUTING,mREVISION,mJOB,mDRAWING,mDRAWING_TITLE,mUSER_ID,
        mLIST_TITLE,mAREA_CODE,mUSERNAME,mDATE_CREATED,mCREATED_BY,mDATE_UPDATED,mUPDATED_BY;
      if c1%notfound then
         close c1;
         exit;
      end if;

      LineNumber := LineNumber + 1;

      CODEPOINT := 4;

      mCABLENUM           := setit(RunOption,'R','L',9,'CABLENUM','',mCABLENUM,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mCABLE_TYPE         := setit(RunOption,'O','L',15,'CABLETYPE','',mCABLE_TYPE,0,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mFORMAL_DEVICE_NAME := setit(RunOption,'O','L',50,'FORMAL DEVICE NAME','',mFORMAL_DEVICE_NAME,0,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mCABLE_FUNCTION     := setit(RunOption,'O','L',120,'FUNC','',mCABLE_FUNCTION,0,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mORIGIN_LOC         := setit(RunOption,'R','L',20,'LOC','',mORIGIN_LOC,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mORIGIN_RACK        := setit(RunOption,'R','L',40,'RACK','',mORIGIN_RACK,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mORIGIN_SIDE        := setit(RunOption,'R','L',1,'SIDE','F',mORIGIN_SIDE,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mORIGIN_ELE         := setit(RunOption,'O','N',2,'ELE',0,mORIGIN_ELE,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mORIGIN_SLOT        := setit(RunOption,'O','L',6,'SLOT','-',mORIGIN_SLOT,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mORIGIN_CONN        := setit(RunOption,'O','L',30,'CONNNUM','X',mORIGIN_CONN,0,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mORIGIN_PIN_LIST    := setit(RunOption,'O','L',16,'PINLIST','',mORIGIN_PIN_LIST,0,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mORIGIN_CONN_TYPE   := setit(RunOption,'O','L',9,'CONNTYPE','?',mORIGIN_CONN_TYPE,0,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mORIGIN_STATION     := setit(RunOption,'O','L',6,'STATION','',mORIGIN_STATION,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mORIGIN_INS         := setit(RunOption,'O','L',3,'INSTR','',mORIGIN_INS,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mDEST_LOC           := setit(RunOption,'R','L',20,'LOC2','',mDEST_LOC,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mDEST_RACK          := setit(RunOption,'R','L',40,'RACK2','',mDEST_RACK,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mDEST_SIDE          := setit(RunOption,'R','L',1,'SIDE2','F',mDEST_SIDE,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mDEST_ELE           := setit(RunOption,'O','N',2,'ELE2',0,mDEST_ELE,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mDEST_SLOT          := setit(RunOption,'O','L',6,'SLOT2','-',mDEST_SLOT,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mDEST_CONN          := setit(RunOption,'O','L',30,'CONNNUM2','X',mDEST_CONN,0,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mDEST_PIN_LIST      := setit(RunOption,'O','L',16,'PINLIST2','',mDEST_PIN_LIST,0,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mDEST_CONN_TYPE     := setit(RunOption,'O','L',9,'CONNTYPE2','?',mDEST_CONN_TYPE,0,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mDEST_STATION       := setit(RunOption,'O','L',6,'STATION2','',mDEST_STATION,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mDEST_INS           := setit(RunOption,'O','L',3,'INSTR2','',mDEST_INS,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mLENGTH             := setit(RunOption,'O','N',4,'LENGTH','',mLENGTH,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mROUTING            := setit(RunOption,'O','L',1000,'ROUTING','',mROUTING,0,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mJOB                := setit(RunOption,'O','L',10,'JOBNUM','',mJOB,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mREVISION           := setit(RunOption,'O','N',2,'REV',0,mREVISION,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mDRAWING            := setit(RunOption,'O','L',200,'DWGNUM','',mDRAWING,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mUSER_ID            := setit(RunOption,'O','L',12,'USER','LOAD',mUSER_ID,0,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mDRAWING_TITLE      := setit(RunOption,'R','L',80,'TITLE','',mDRAWING_TITLE,0,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mAREA_CODE          := setit(RunOption,'R','C',10,'AREACODE','',mAREA_CODE,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mLIST_TITLE         := setit(RunOption,'R','C',80,'LISTTITLE','',mLIST_TITLE,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      mUSERNAME           := setit(RunOption,'R','C',25,'USERNAME','',mUSERNAME,1,mID,p_errmsg);
      if (p_errmsg is not null) then
         raise Setit_Error;
      end if;

      CODEPOINT := 5;

      --
      -- Validation part.
      --

      -- added by venkat on 06/11/2008
      IF DataStatus = 'OVERWRITE' THEN
         DELETE FROM CAPTAR.CONNINV WHERE CABLENUM = mCablenum;
         delete from captar.conductor where conductor.cablenum = mCablenum;
         delete from captar.cableinv where cableinv.cablenum = mCablenum;
      END IF;

      --
      -- Check that the List Title is same accross the file.
      --
      IF PrevTitle IS NULL THEN
         PrevTitle := mList_Title;
      END IF;
      IF mList_Title != PrevTitle THEN
         IF RunOption = 'VALIDATE' THEN
            CODEPOINT := 6;
            INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
               discrp_status, description, file_name, discrp_source, line_no, id)
            VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
               'Line: ' || TO_CHAR(LineNumber) || ', List Title is not the same as previous one.',
               FileName, 'CAPTARIN', LineNumber, mID);
         ELSE
            RAISE DataValidationIssue;
         END IF;
      END IF;

      --
      -- Check that the Area Code is same accross the file.
      --
      IF PrevArea IS NULL THEN
         PrevArea := mArea_Code;
      END IF;
      IF mArea_Code != PrevArea THEN
         IF RunOption = 'VALIDATE' THEN
            CODEPOINT := 7;
            INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
               discrp_status, description, file_name, discrp_source, line_no, id)
            VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
               'Line: ' || TO_CHAR(LineNumber) || ', Area Code is not the same as previous one.',
               FileName, 'CAPTARIN', LineNumber, mID);
         ELSE
            RAISE DataValidationIssue;
         END IF;
      END IF;

      --
      -- Check that the Job Number is same accross the file.
      --
      --???? Not quite suere whether this check is required or not.
      IF PrevJobnum IS NULL THEN
         PrevJobnum := mJob;
      END IF;
      IF mJob != PrevJobnum THEN
         IF RunOption = 'VALIDATE' THEN
            CODEPOINT := 8;
            INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
               discrp_status, description, file_name, discrp_source, line_no, id)
            VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
               'Line: ' || TO_CHAR(LineNumber) || ', Job Number is not the same as previous one.',
               FileName, 'CAPTARIN', LineNumber, mID);
         ELSE
            RAISE DataValidationIssue;
         END IF;
      END IF;

      --
      -- If Rack dataype is number and is a single digit pad '0' to it.
      --
      IF LENGTH(morigin_rack) = 1 and morigin_rack IN ('0','1','2','3','4','5','6','7','8','9') THEN
         morigin_rack := '0' || morigin_rack;
      END IF;
      IF LENGTH(mdest_rack) = 1 and mdest_rack IN ('0','1','2','3','4','5','6','7','8','9') THEN
         mdest_rack := '0' || mdest_rack;
      END IF;

      --
      -- Make sure that Cable Number is unique.
      --
      CODEPOINT := 9;
      SELECT COUNT(cablenum) INTO RecCheck FROM captar.cableinv WHERE cablenum = mCablenum;
      IF RecCheck > 0 THEN
         IF RunOption = 'VALIDATE' THEN
            IF DataStatus = 'NEW' THEN
               CODEPOINT := 10;
               INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                  discrp_status, description, file_name, discrp_source, line_no, id)
               VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                  'Line: ' || TO_CHAR(LineNumber) || ', Cable Number: ' ||
                  mCablenum || ' already in CABLEINV table.',
                  FileName, 'CAPTARIN', LineNumber, mID);
            ELSIF DataStatus = 'OVERWRITE' THEN
               NULL; -- Eventually the record will be deleted.
            END IF;
         ELSIF RunOption = 'PROCESS' THEN
            IF DataStatus = 'NEW' THEN
               RAISE DataValidationIssue;
            ELSIF DataStatus = 'OVERWRITE' THEN
               NULL; -- Eventually the record will be deleted.
            END IF;
         END IF;
      END IF;

      --
      -- Make Cable Type is valid.
      --
      CODEPOINT := 11;
      SELECT COUNT(cabletype) INTO RecCheck FROM captar.condnum WHERE cabletype = mCable_Type;
       IF RecCheck = 0 THEN
          IF RunOption = 'VALIDATE' THEN
             CODEPOINT := 12;
             INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                discrp_status, description, file_name, discrp_source, line_no, id)
             VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                'Line: ' || TO_CHAR(LineNumber) || ', Cable Type: ' ||
                mCable_Type || ' not found in CONDNUM table.',
                FileName, 'CAPTARIN', LineNumber, mID);
          ELSE
             RAISE DataValidationIssue;
          END IF;
       END IF;

       --
       -- Make sure First set of loc/rack/side/ele/slot/connum/cablenum not in CONNINV table.
       --
       CODEPOINT := 13;
       SELECT COUNT(*) INTO RecCheck FROM captar.conninv
       WHERE loc = morigin_Loc AND rack = morigin_Rack AND side = morigin_Side AND ele = morigin_Ele
             AND slot = morigin_Slot AND connnum = morigin_Conn AND cablenum = mCablenum;
       IF RecCheck > 0 THEN
          IF RunOption = 'VALIDATE' THEN
             CODEPOINT := 14;
             INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                discrp_status, description, file_name, discrp_source, line_no, id)
             VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                'Line: ' || TO_CHAR(LineNumber) ||
                ', 1st set of loc/rack/side/ele/slot/connnum/cablenum combination exists in table CONNINV.',
                FileName, 'CAPTARIN', LineNumber, mID);
          ELSE
             RAISE DataValidationIssue;
          END IF;
       END IF;

       --
       -- Make sure Second set of loc/rack/side/ele/slot/connum/cablenum not in CONNINV table.
       --
       CODEPOINT := 15;
       SELECT COUNT(*) INTO RecCheck FROM captar.conninv
       WHERE loc = mdest_Loc AND rack = mdest_Rack AND side = mdest_Side AND ele = mdest_Ele
             AND slot = mdest_Slot AND connnum = mdest_Conn AND cablenum = mCablenum;
       IF RecCheck > 0 THEN
          IF RunOption = 'VALIDATE' THEN
             CODEPOINT := 16;
             INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                discrp_status, description, file_name, discrp_source, line_no, id)
             VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                'Line: ' || TO_CHAR(LineNumber) ||
                ', 2nd set of loc/rack/side/ele/slot/connnum/cablenum combination exists in table CONNINV.',
                FileName, 'CAPTARIN', LineNumber, mID);
          ELSE
             RAISE DataValidationIssue;
          END IF;
       END IF;

       --
       -- Make sure First set of loc/rack/side/ele/slot/connum/pinlist not in CONNINV table.
       --
       CODEPOINT := 17;
       SELECT COUNT(*) INTO RecCheck FROM captar.conninv
       WHERE loc = morigin_Loc AND rack = morigin_Rack AND side = morigin_Side AND ele = morigin_Ele
             AND slot = morigin_Slot AND connnum = morigin_Conn AND pinlist = morigin_Pin_List;
       IF RecCheck > 0 THEN
          IF RunOption = 'VALIDATE' THEN
             CODEPOINT := 18;
             INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                discrp_status, description, file_name, discrp_source, line_no, id)
             VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                'Line: ' || TO_CHAR(LineNumber) ||
                ', 1st set of loc/rack/side/ele/slot/connnum/pinlist combination exists in table CONNINV.',
                FileName, 'CAPTARIN', LineNumber, mID);
          ELSE
             if IgnoreErrors = 'Y' then
                null;
             else
                RAISE DataValidationIssue;
             end if;
          END IF;
       END IF;

       --
       -- Make sure Second set of loc/rack/side/ele/slot/connum/pinlist not in CONNINV table.
       --
       CODEPOINT := 19;
       SELECT COUNT(*) INTO RecCheck FROM captar.conninv
       WHERE loc = mdest_Loc AND rack = mdest_Rack AND side = mdest_Side AND ele = mdest_Ele
             AND slot = mdest_Slot AND connnum = mdest_Conn AND pinlist = mdest_Pin_List;

       IF RecCheck > 0 THEN
          IF RunOption = 'VALIDATE' THEN
             CODEPOINT := 20;
             INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                discrp_status, description, file_name, discrp_source, line_no, id)
             VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                'Line: ' || TO_CHAR(LineNumber) ||
                ', 2nd set of loc/rack/side/ele/slot/connnum/pinlist combination exists in table CONNINV.',
                FileName, 'CAPTARIN', LineNumber, mID);
          ELSE
             if IgnoreErrors = 'Y' then
                null;
             else
                RAISE DataValidationIssue;
             end if;
          END IF;
       END IF;

       --
       -- Make sure Fist set of loc/rack/side/ele/slot not in SLOT table.
       --
       CODEPOINT := 21;
       SELECT COUNT(*) INTO RecCheck FROM captar.slot
       WHERE loc = morigin_Loc AND rack = morigin_Rack AND side = morigin_Side AND ele = morigin_Ele AND slot = morigin_Slot;
       --IF RecCheck = 0 THEN
          --IF RunOption = 'VALIDATE' THEN
          --   INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type, discrp_status, description, file_name, discrp_source)
          --   VALUES (TRUNC(SYSDATE), 'WARNING', 'OPEN', 'Line: ' || TO_CHAR(LineNumber) || ', 1st set of loc/rack/side/ele/slot combination not found in SLOT table.', FileName, 'CAPTARIN');
          --ELSE
          --   NULL; --RAISE DataValidationIssue;
          --END IF;
       --ELS
       IF RecCheck > 1 THEN
          IF RunOption = 'VALIDATE' THEN
             CODEPOINT := 22;
             INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                discrp_status, description, file_name, discrp_source, line_no, id)
             VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                'Line: ' || TO_CHAR(LineNumber) ||
                ', 1st set of loc/rack/side/ele/slot combination listed morethan once in SLOT table.',
                FileName, 'CAPTARIN', LineNumber, mID);
          ELSE
             RAISE DataValidationIssue;
          END IF;
       END IF;

       --
       -- Make sure Second set of loc/rack/side/ele/slot not in SLOT table.
       --
       CODEPOINT := 23;
       SELECT COUNT(*) INTO RecCheck FROM captar.slot
       WHERE loc = mdest_Loc AND rack = mdest_Rack AND side = mdest_Side AND ele = mdest_Ele AND slot = mdest_Slot;
       --IF RecCheck = 0 THEN
       --   IF RunOption = 'VALIDATE' THEN
       --      INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type, discrp_status, description, file_name, discrp_source)
       --      VALUES (TRUNC(SYSDATE), 'WARNING', 'OPEN', 'Line: ' || TO_CHAR(LineNumber) || ', 2nd set of loc/rack/side/ele/slot combination not found in SLOT table.', FileName, 'CAPTARIN');
       --   ELSE
       --      NULL; --RAISE DataValidationIssue;
       --   END IF;
       --ELS
       IF RecCheck > 1 THEN
          IF RunOption = 'VALIDATE' THEN
             CODEPOINT := 24;
             INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                discrp_status, description, file_name, discrp_source, line_no, id)
             VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                'Line: ' || TO_CHAR(LineNumber) ||
                ', 2nd set of loc/rack/side/ele/slot combination listed morethan once in SLOT table.',
                FileName, 'CAPTARIN', LineNumber, mID);
          ELSE
             RAISE DataValidationIssue;
          END IF;
       END IF;

       --
       -- Make sure Area Code is in AREA table.
       --
       CODEPOINT := 25;
       SELECT COUNT(area_code) INTO RecCheck FROM captar.area WHERE area_code = mArea_Code;
       IF RecCheck = 0 THEN
          IF RunOption = 'VALIDATE' THEN
             CODEPOINT := 26;
             INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                discrp_status, description, file_name, discrp_source, line_no, id)
             VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                'Line: ' || TO_CHAR(LineNumber) ||
                ', Area Code: ' || mArea_Code || ' not found in AREA table.',
                FileName, 'CAPTARIN', LineNumber, mID);
          ELSE
             RAISE DataValidationIssue;
          END IF;
       END IF;

       --
       -- Make sure destination location and origin location are not the same.
       --
       IF morigin_Loc = mdest_Loc AND morigin_Rack = mdest_Rack
               AND morigin_Side = mdest_Side AND morigin_Ele = mdest_Ele
               AND morigin_Slot = mdest_Slot AND morigin_Conn = mdest_Conn
               AND mCablenum = mCablenum THEN
          IF RunOption = 'VALIDATE' THEN
             CODEPOINT := 27;
             INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                discrp_status, description, file_name, discrp_source, line_no, id)
             VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                'Line: ' || TO_CHAR(LineNumber) || ', Destination location and Origin location is same.',
                FileName, 'CAPTARIN', LineNumber, mID);
          ELSE
             RAISE DataValidationIssue;
          END IF;
       END IF;

       --
       -- Make sure first Connector is not linked to another cable.
       --
       IF INSTR(morigin_conn,'TB',1,1) > 0 THEN
          --
          -- Check that the CONNECTOR is not already in PIN table.
          --
          CODEPOINT := 28;
          SELECT COUNT(*) INTO RecCheck
          FROM captar.pin p, captar.conductor c
          WHERE p.loc = morigin_Loc AND p.rack = morigin_Rack AND p.side = morigin_Side AND p.ele = morigin_Ele AND p.slot = morigin_Slot AND p.connnum = morigin_Conn AND p.refnum = c.refnum;
          IF RecCheck = 0 THEN
             NULL;         -- First Connector is not linked to any cable, which is good.
          ELSE             -- First Connector is liked to something, let check further on this.
             CODEPOINT := 29;

             -- ELIE ADDED CLAUSE "AND ROWNUM < 2" (30-JAN-2013)
             SELECT status,
                          cablenum
                 INTO CheckPin_Status,
                          CheckPin_Cablenum
             FROM captar.pin p, captar.conductor c
             WHERE p.loc = morigin_Loc
                 AND p.rack = morigin_Rack
                 AND p.side = morigin_Side
                 AND p.ele = morigin_Ele
                 AND p.slot = morigin_Slot
                 AND p.connnum = morigin_Conn
                 AND p.refnum = c.refnum
                 AND ROWNUM < 2;

             IF mcablenum <> CheckPin_Cablenum AND CheckPin_Status = 'F' THEN
                IF RunOption = 'VALIDATE' THEN
                   IF DataStatus = 'NEW' THEN
                      CODEPOINT := 30;
                      INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                         discrp_status, description, file_name, discrp_source, line_no, id)
                      VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                         'Line: ' || TO_CHAR(LineNumber) ||
                         ', Connector linked to another cable: ' || CheckPin_Cablenum || ' with status: ' ||
                         CheckPin_Status || ' (First Set).',
                         FileName, 'CAPTARIN', LineNumber, mID);
                   ELSIF DataStatus = 'OVERWRITE' THEN
                      CODEPOINT := 31;
                      INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                         discrp_status, description, file_name, discrp_source, line_no, id)
                      VALUES (process_upload_id,TRUNC(SYSDATE), 'DELETE', 'OPEN',
                         'Line: ' || TO_CHAR(LineNumber) ||
                         ', UPDATE/DELETE PIN.STATUS and PIN.REFNUM to NULL that are linked to another cable: ' ||
                         CheckPin_Cablenum || ' with status: ' || CheckPin_Status || ' (First Set).',
                         FileName, 'CAPTARIN', LineNumber, mID);
                   END IF;
                ELSIF RunOption = 'PROCESS' THEN
                  IF DataStatus = 'OVERWRITE' THEN
                     CODEPOINT := 32;
                     update captar.pin
                            set pin.refnum = NULL, pin.status = NULL
                     where  pin.refnum in (select pin.refnum
                                           from   captar.pin, captar.conductor
                                           where  pin.refnum = conductor.refnum
                                                  and conductor.cablenum = mCablenum);
                  ELSIF DataStatus = 'NEW' THEN
                     RAISE DataValidationIssue;
                  END IF;
                END IF;
             END IF;
          END IF;
          --
          -- Check that the CONNECTOR is not already in  Connector Inventory table.
          --
          CODEPOINT := 33;
          SELECT COUNT(*) INTO RecCheck FROM captar.conninv
          WHERE loc = morigin_Loc AND rack = morigin_Rack AND side = morigin_Side AND ele = morigin_Ele AND slot = morigin_Slot AND connnum = morigin_conn;
          IF RecCheck <> 0 THEN
             IF RunOption = 'VALIDATE' THEN
                IF DataStatus = 'NEW' THEN
                   CODEPOINT := 34;
                   INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date,
                      discrp_type, discrp_status, description, file_name, discrp_source, line_no, id)
                   VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                      'Line: ' || TO_CHAR(LineNumber) ||
                      ', Connector is already in Connector Inventory (First Set).',
                      FileName, 'CAPTARIN', LineNumber, mID);
                ELSIF DataStatus = 'OVERWRITE' THEN
                   CODEPOINT := 35;
                   INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date,
                   discrp_type, discrp_status, description, file_name, discrp_source, line_no, id)
                   SELECT process_upload_id, TRUNC(SYSDATE), 'DELETE', 'OPEN',
                      'Line: ' || TO_CHAR(LineNumber) ||
                          'LOC:' || loc || ', RACK:' || rack || ', SIDE:' || side || ', ELE:' || ele || ', SLOT:' || slot || ', CONNNUM:' || connnum ||
                          ', PINLIST:' || pinlist || ', CABLENUM:' || cablenum || ', CONNTYPE:' || conntype || ', STATION:' || station || ', INSTR:' || instr,
                          '', 'CAPTARIN', LineNumber, mID
                   FROM   captar.conninv where  conninv.cablenum = mCablenum;
                   --VALUES (TRUNC(SYSDATE), 'DELETE', 'OPEN', 'Line: ' || TO_CHAR(LineNumber) || ', DELETE Connector Inventory (First Set).', FileName, 'CAPTARIN');
                END IF;
             ELSIF RunOption = 'PROCESS' THEN
                IF DataStatus = 'OVERWRITE' THEN
                   CODEPOINT := 36;
                   delete from captar.conninv where  conninv.cablenum = mCablenum;
                ELSIF DataStatus = 'NEW' THEN
                   RAISE DataValidationIssue;
                END IF;
             END IF;
          END IF;
       END IF;
       --
       -- Make sure second Connector is not linked to another cable.
       --
       CODEPOINT := 37;
       IF INSTR(mdest_conn,'TB',1,1) > 0 THEN
-- Poonam 5/28/2021 - Bypassing this check
/*          --
          -- Check that the CONNECTOR is not already in PIN table.
          --
          CODEPOINT := 38;
          SELECT COUNT(*) INTO RecCheck
          FROM captar.pin p, captar.conductor c
          WHERE p.loc = mdest_Loc AND p.rack = mdest_Rack AND p.side = mdest_Side AND p.ele = mdest_Ele AND p.slot = mdest_Slot AND p.connnum = mdest_Conn AND p.refnum = c.refnum;
          IF RecCheck = 0 THEN
             NULL;         -- Second Connector is not linked to any cable, which is good.
          ELSE             -- Second Connector is liked to something, let check further on this.
             CODEPOINT := 39;
             SELECT status, cablenum INTO CheckPin_Status, CheckPin_Cablenum
             FROM captar.pin p, captar.conductor c
             WHERE p.loc = mdest_Loc AND p.rack = mdest_Rack AND p.side = mdest_Side AND p.ele = mdest_Ele AND p.slot = mdest_Slot AND p.connnum = mdest_Conn AND p.refnum = c.refnum;
             IF mcablenum <> CheckPin_Cablenum AND CheckPin_Status = 'F' THEN
                IF RunOption = 'VALIDATE' THEN
                   IF DataStatus = 'NEW' THEN
                      CODEPOINT := 40;
                      INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                         discrp_status, description, file_name, discrp_source, line_no, id)
                      VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                         'Line: ' || TO_CHAR(LineNumber) ||
                         ', Connector linked to another cable: ' || CheckPin_Cablenum || ' with status: ' ||
                         CheckPin_Status || ' (Second Set).',
                         FileName, 'CAPTARIN', LineNumber, mID);
                   ELSIF DataStatus = 'OVERWRITE' THEN
                      CODEPOINT := 41;
                      INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                      discrp_status, description, file_name, discrp_source, line_no, id)
                      VALUES (process_upload_id,TRUNC(SYSDATE), 'DELETE', 'OPEN',
                        'Line: ' || TO_CHAR(LineNumber) ||
                        ', UPDATE/DELETE PIN.STATUS and PIN.REFNUM to NULL that are linked to another cable: ' ||
                        CheckPin_Cablenum || ' with status: ' || CheckPin_Status || ' (Second Set).',
                        FileName, 'CAPTARIN', LineNumber, mID);
                   END IF;
                ELSIF RunOption = 'PROCESS' THEN
                   IF DataStatus = 'OVERWRITE' THEN
                      CODEPOINT := 42;
                      update captar.pin
                             set pin.refnum = NULL, pin.status = NULL
                      where  pin.refnum in (select pin.refnum
                                            from   captar.pin, captar.conductor
                                            where  pin.refnum = conductor.refnum
                                                   and conductor.cablenum = mCablenum);
                   ELSIF DataStatus = 'NEW' THEN
                      RAISE DataValidationIssue;
                   END IF;
                END IF; -- RunOption = 'VALIDATE'
             END IF; -- mcablenum <> CheckPin_Cablenum AND CheckPin_Status = 'F'
          END IF; -- RecCheck = 0
 -- Poonam 5/28/2021 - Bypassed this much code
 */
	  --
          -- Check that the CONNECTOR is not already in  Connector Inventory table.
          --
          CODEPOINT := 43;
          SELECT COUNT(*) INTO RecCheck FROM captar.conninv
          WHERE loc = mdest_Loc AND rack = mdest_Rack AND side = mdest_Side AND ele = mdest_Ele AND slot = mdest_Slot AND connnum = mdest_conn;
          IF RecCheck <> 0 THEN
             IF RunOption = 'VALIDATE' THEN
                IF DataStatus = 'NEW' THEN
                   CODEPOINT := 44;
                   INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date,
                      discrp_type, discrp_status, description, file_name, discrp_source, line_no, id)
                   VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                      'Line: ' || TO_CHAR(LineNumber) ||
                      ', Connector is already in Connector Inventory (Second Set).',
                      FileName, 'CAPTARIN', LineNumber, mID);
                ELSIF DataStatus = 'OVERWRITE' THEN
                   CODEPOINT := 45;
                   INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                      discrp_status, description, file_name, discrp_source, line_no, id)
                   VALUES (process_upload_id,TRUNC(SYSDATE), 'DELETE', 'OPEN',
                      'Line: ' || TO_CHAR(LineNumber) || ', DELETE Connector Inventory (Second Set).',
                      FileName, 'CAPTARIN', LineNumber, mID);
                END IF;
             ELSIF RunOption = 'PROCESS' THEN
                IF DataStatus = 'OVERWRITE' THEN
                   CODEPOINT := 46;
                   delete from captar.conninv where  conninv.cablenum = mCablenum;
                ELSIF DataStatus = 'NEW' THEN
                   RAISE DataValidationIssue;
                END IF;
             END IF;
          END IF;
       END IF;
       --
       -- Delete the entries if they are already there for OVERWRITE option
       --
       IF DataStatus = 'OVERWRITE' THEN
          IF RunOption = 'VALIDATE' THEN
             CODEPOINT := 47;
             INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                discrp_status, description, file_name, discrp_source, line_no, id)
             VALUES (process_upload_id,TRUNC(SYSDATE), 'DELETE', 'OPEN',
                'Line: ' || TO_CHAR(LineNumber) || ', DELETE CONDUCTOR records for cable: ' || mCablenum ,
                FileName, 'CAPTARIN', LineNumber, mID);
             CODEPOINT := 48;
             INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                discrp_status, description, file_name, discrp_source, line_no, id)
             VALUES (process_upload_id,TRUNC(SYSDATE), 'DELETE', 'OPEN',
                'Line: ' || TO_CHAR(LineNumber) ||
                ', DELETE CABLEINV records for cable: ' || mCablenum ,
                FileName, 'CAPTARIN', LineNumber, mID);
          ELSIF RunOption = 'PROCESS' THEN
             CODEPOINT := 49;
             delete from captar.conductor where conductor.cablenum = mCablenum;
             CODEPOINT := 50;
             delete from captar.cableinv where cableinv.cablenum = mCablenum;

          END IF;
       END IF;

       --
       -- Grab a new list no if not already exists in cable list table for that area code.
       --
       CODEPOINT := 51;
       SELECT COUNT(*) INTO RecCheck FROM captar.cable_listing WHERE list_title = mList_Title AND area_code = mArea_Code;
       IF RecCheck = 0 THEN
          IF RunOption = 'PROCESS' THEN
             CODEPOINT := 52;
             SELECT captar.list_no.nextval INTO ListNo FROM dual;
             INSERT INTO captar.cable_listing (list_no, list_title, area_code)
             VALUES (ListNo, mList_Title, mArea_Code);
          END IF;
       ELSIF RecCheck = 1 THEN
          CODEPOINT := 53;
          SELECT list_no INTO ListNo FROM captar.cable_listing WHERE list_title = mList_Title AND area_code = mArea_Code;
       ELSIF RecCheck > 1 THEN
             IF RunOption = 'VALIDATE' THEN
                CODEPOINT := 54;
                INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                discrp_status, description, file_name, discrp_source, line_no, id)
                VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                   'Line: ' || TO_CHAR(LineNumber) ||
                   ' more than one List No found for the List Title and Area Code combination in CABLE_LISTING table.',
                   FileName, 'CAPTARIN', LineNumber, mID);
             ELSE
                RAISE DataValidationIssue;
             END IF;
       END IF;

       --
       -- Insert data into respective tables
       --
       IF RunOption = 'PROCESS' THEN
          CODEPOINT := 55;
          INSERT INTO captar.cableinv
	  (cablenum, cabletype, jobnum, enteredby, dateent, func, system, length, routing, rev, list_no, dwgnum, drawing_title)
          VALUES
	  (mCablenum, mCable_Type, mJob, mUser_ID, SYSDATE, mCable_Function, mFormal_Device_Name, mLength, mRouting, mRevision, ListNo, mDRAWING,mDRAWING_TITLE);

-- Poonam 10/28/2022 - Added extra column for Origin/Destination to be updated while doing the insert here. origin = Y - Origin record. origin =  N - Destination record
          CODEPOINT := 56;
          INSERT INTO captar.conninv (loc, rack, side, ele, slot, connnum, pinlist, conntype, station, instr, cablenum, origin)
          VALUES (morigin_Loc, morigin_Rack, morigin_Side, morigin_Ele, morigin_Slot, morigin_Conn, morigin_Pin_list, morigin_Conn_Type, morigin_Station, morigin_Ins, mCablenum, 'Y');

          CODEPOINT := 57;
          INSERT INTO captar.conninv (loc, rack, side, ele, slot, connnum, pinlist, conntype, station, instr, cablenum, origin)
          VALUES (mdest_Loc, mdest_Rack, mdest_Side, mdest_Ele, mdest_Slot, mdest_Conn, mdest_Pin_list, mdest_Conn_type, mdest_Station, mdest_Ins, mCablenum, 'N');
       END IF;

       CODEPOINT := 58;
       SELECT COUNT(*) INTO RecCheck FROM captar.condnum WHERE cabletype = mCable_Type;

       IF RecCheck = 0 THEN
          IF RunOption = 'VALIDATE' THEN
             CODEPOINT := 59;
             INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type,
                discrp_status, description, file_name, discrp_source, line_no, id)
             VALUES (process_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN',
                'Line: ' || TO_CHAR(LineNumber) ||
                ', Condnum not found in CONDNUM table for cabletype: ' || mCable_Type || '.',
                FileName, 'CAPTARIN', LineNumber, mID);
          ELSE
             RAISE DataValidationIssue;
          END IF;
       ELSIF RecCheck = 1 THEN
          CODEPOINT := 60;
          SELECT condnum INTO condnum FROM captar.condnum WHERE cabletype = mCable_Type;
          IF RunOption = 'PROCESS' THEN
             CODEPOINT := 61;
             INSERT INTO captar.conductor (refnum, cablenum, condnum, siglname, hooked)
             VALUES (captar.refnum.nextval, mCablenum, Condnum, NULL, 0);
          END IF;
       --ELSIF RecCheck > 1 THEN
       --   IF RunOption = 'VALIDATE' THEN
       --      INSERT INTO captar.captarin_discrepancies (upload_id,discrp_date, discrp_type, discrp_status, description, file_name, discrp_source)
       --      VALUES (p_upload_id,TRUNC(SYSDATE), 'ERROR', 'OPEN', 'Line: ' || TO_CHAR(LineNumber) || ', More than one Condnum found in CONDNUM table for cabletype: ' || mCable_Type || '.', FileName, 'CAPTARIN');
       --   ELSE
       --      RAISE DataValidationIssue;
       --   END IF;
       END IF;
    END LOOP;

    CODEPOINT := 62;
    --
    -- If the program is ran with option of VALIDATE and OVERWRITE,
    -- initial delete statements should be rolledback and the discrepancy table inserts
    -- should be commited.
    IF RunOption = 'VALIDATE' AND DataStatus = 'OVERWRITE' THEN
       open c2;
       CODEPOINT := 63;
       loop
         fetch c2 bulk collect into l_table;
         exit when c2%notfound;
       end loop;
       close c2;
       rollback to del_rows;
       CODEPOINT := 64;
       for i in 1..l_table.count loop
           insert into captarin_discrepancies values l_table(i);
       end loop;
    end if;

    CODEPOINT := 65;

    -- COMMIT;  -- ELIE COMMENTED OUT 30-JAN-2013 NOTE: FINAL (AND ONLY) COMMIT IS DONE IN PROCEDURE PARSE_FILE.

  EXCEPTION
    WHEN VALUE_ERROR THEN
         P_ERRMSG := SUBSTR('ERROR ('||C_PROC||'): Input line too large for the buffer while reading line: ' || TO_CHAR(LineNumber),1,1000);
         RETURN;
         -- RAISE_APPLICATION_ERROR(-20006, 'Input line too large for the buffer while reading line: ' || TO_CHAR(LineNumber));
    WHEN Invalid_RunOption THEN
         P_ERRMSG := SUBSTR('ERROR ('||C_PROC||'): Invalid Run Option: ' || RunOption || ' to Process the file, Process terminated.',1,1000);
         RETURN;
         -- RAISE_APPLICATION_ERROR(-20007, 'Invalid Run Option: ' || RunOption || ' to Process the file, Process terminated.');
    WHEN Invalid_DataStatus THEN
         P_ERRMSG := SUBSTR('ERROR ('||C_PROC||'): Invalid Data Status: ' || DataStatus || ' to Process the file, Process terminated.',1,1000);
         RETURN;
         -- RAISE_APPLICATION_ERROR(-20008, 'Invalid Data Status: ' || DataStatus || ' to Process the file, Process terminated.');
    WHEN Invalid_OperatorName THEN
         P_ERRMSG := SUBSTR('ERROR ('||C_PROC||'): Invalid Operator Name: ' || OperatorName || ' to Process the file, Process terminated.',1,1000);
         RETURN;
         -- RAISE_APPLICATION_ERROR(-20009, 'Invalid Operator Name: ' || OperatorName || ' to Process the file, Process terminated.');
    WHEN DataValidationIssue THEN
         P_ERRMSG := SUBSTR('ERROR ('||C_PROC||'): LineNumber='||to_char(LineNumber) ||' AND CODEPOINT='||TO_CHAR(CODEPOINT)||': Data is invalid. Please run with VALIDATE option to see the errors. Process terminated.',1,1000);
         RETURN;
         -- RAISE_APPLICATION_ERROR(-20010, 'Data is invalid. Please run with VALIDATE option to see the errors. Process terminated.');
    WHEN Setit_Error THEN
         P_ERRMSG := SUBSTR('ERROR ('||C_PROC||'): SETIT ERROR',1,1000);
         RETURN;
    WHEN OTHERS THEN
         P_ERRMSG := SUBSTR('OTHERS ERROR ('||C_PROC||'): AT CODEPOINT='||TO_CHAR(CODEPOINT)||' =>'||SQLERRM,1,1000);
         RETURN;

  END LOADDATA;

END CAPTARIN;
/
