create or replace package SSRL_RSW_PKG
as

l_min_textarea_length   constant pls_integer  := 20;
l_warning_color         constant varchar2(10) := '#FF00FF';
c_email_domain          constant varchar2(100) := 'slac.stanford.edu';
c_from_email            constant varchar2(100) := 'slac-app-cater-admin' || '@' || c_email_domain;
rswcf_email_rec_new	SSRL_RSW_FORM%ROWTYPE;
rswcf_email_rec_old	SSRL_RSW_FORM%ROWTYPE;
/*
procedure view_jn
(p_form_id                   in  number
,p_debug                     in  number := 0
);

function format_msg
(p_msg                       in  varchar2
,p_html_flag                 in  varchar2
) return varchar2;

function read_only
(p_role                      in  number
,p_item                      in  varchar2 := null
) return                     boolean;
*/
procedure SSRL_RSW_GET_STATUS 
(p_form_id			in  number
,p_s3_task_person_ack_id	in  number
,p_s3_area_mgr_id		in  number
,p_s3_sso_id			in  number
,p_s3_rad_id			in  number
,p_s4_operator_id		in  number
,p_s4_wrkr_id			in  number
,p_s5_task_person_ack_id	in  number
,p_s5_pps_id			in  number
,p_s5_rad_id			in  number
,p_s5_operator_id		in  number
,p_s5_other_id			in  number
,p_s6_sso_id			in  number
,p_s6_operator_id		in  number
,p_s4_operator_ack		in  varchar2
,p_s5_pps_chk			in  varchar2
,p_s5_rad_chk			in  varchar2
,p_s5_operator_chk		in  varchar2
,p_s5_other_chk			in  varchar2
,p_s6_operator_ack		in  varchar2
,p_form_status_id		in out number
--,p_status_id_out		out number
);

function form_status_color
(p_form_status_id                number
) return varchar2;

function get_form_status
(p_status_id                     number
) return varchar2;

procedure get_user_role
(pi_person_id      in  number
,po_role_id   out number
,po_role      out varchar2
);

procedure get_user_information
(pi_person_id      in  number
,po_name           out varchar2
,po_email_address  out varchar2
,po_phone_ext      out varchar2
,po_bldg           out varchar2
,po_role_id	   out number
,po_role	   out varchar2
);

function email_addresses (p_role varchar2) return varchar2;

function get_ssrl_rsw_edit_url
(p_apex_url_prefix varchar2
,p_form_id         number
) return varchar2;

/*
begin
    rsw_pkg.email_form
    (pi_form_id    => 5296
    ,pi_email_to   => 'poonam@slac.stanford.edu'
    ,pi_email_cc   => 'poonam@slac.stanford.edu'
    ,pi_email_from => 'poonam@slac.stanford.edu'
    ,pi_subject    => 'test'
    ,pi_comment    => 'test'
    ,pi_instance   => 'slacdev2'
    ,pi_active     => 'Y'
    ,pi_html       => 'Y'
    );
end;
*/
/*
procedure email_rsw_form
(pi_form_rec_new	SSRL_RSW_FORM%rowtype
,pi_form_rec_old	SSRL_RSW_FORM%rowtype
,pi_from		varchar2 := c_from_email
,pi_operation		varchar2
,pi_message_type	varchar2 := null
);
*/
/*
procedure email_form
(pi_form_id     number
,pi_email_to    varchar2
,pi_email_cc    varchar2
,pi_email_from  varchar2
,pi_subject     varchar2
,pi_comment     varchar2 := null
,pi_instance    varchar2
,pi_active      varchar2 := 'Y'
,pi_html        varchar2 := 'Y'
);
*/
end SSRL_RSW_PKG;
/