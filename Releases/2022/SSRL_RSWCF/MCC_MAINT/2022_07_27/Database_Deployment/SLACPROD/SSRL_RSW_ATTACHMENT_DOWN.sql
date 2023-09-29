create or replace PROCEDURE SSRL_RSW_ATTACHMENT_DOWN (p_file_id in number) AS
        v_mime  SSRL_RSW_ATTACHMENT.MIME_TYPE%TYPE;
        v_length  NUMBER;
        v_file_name VARCHAR2(2000);
        Lob_loc  BLOB;
BEGIN
        SELECT MIME_TYPE, BLOB_CONTENT, name, DBMS_LOB.GETLENGTH(blob_content)
                INTO v_mime,lob_loc,v_file_name,v_length
                FROM SSRL_RSW_ATTACHMENT
                WHERE file_id = p_file_id;
              --
              -- set up HTTP header
              --
                    -- use an NVL around the mime type and
                    -- if it is a null set it to application/octect
                    -- application/octect may launch a download window from windows
                    owa_util.mime_header( nvl(v_mime,'application/octet'), FALSE );

                -- set the size so the browser knows how much to download
                htp.p('Content-length: ' || v_length);
                -- the filename will be used by the browser if the users does a save as
                htp.p('Content-Disposition:  attachment;  filename=' || v_file_name || '');
                -- close the headers
                owa_util.http_header_close;
                -- download the BLOB
                wpg_docload.download_file( Lob_loc );
end ssrl_rsw_attachment_down;
/
GRANT EXECUTE on SSRL_RSW_ATTACHMENT_DOWN to PUBLIC;
/