
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "LCLS_INFRASTRUCTURE"."V_LCLS_ELEMENTS_REPORT" ("ELEMENT_ID", "ELEMENT", "FIRST_SOURCED_FROM", "ELEMENT_TYPE", "ACTIVE_FLAG", "ELEMENT_COMMENT", "AREA", "KEYWORD", "ENGINEERING_NAME", "SYMBOLS_UPLOAD_ID", "LTU_UPLOAD_ID", "SUML_M", "SUML_FT", "LINACZ_M", "LINACZ_FT", "LTU_SUML_M", "LTU_SUML_FT", "LTU_LINACZ_M", "LTU_LINACZ_FT", "MAD_SUML_M", "MAD_SOLID_EDGE_XCOOR_M", "MAD_SUML_FT", "MAD_SOLID_EDGE_XCOOR_FT", "NONMAD_SUML_M", "NONMAD_SOLID_EDGE_XCOOR_M", "NONMAD_SUML_FT", "NONMAD_SOLID_EDGE_XCOOR_FT", "PRIMARY", "SLC_MICRO_NAME", "IOC_LOC", "UNIT", "EPICS_DEVICE_NAME", "SLC_NAME", "EPICS_CHANNEL_ACCESS_NAME", "IOC_CAPTAR_SEARCH", "SLC_CAPTAR_SEARCH", "BEAMLINE_ID", "BEAMLINE", "SECTION_ID", "SECTIONS", "BEGIN_DBMARK", "BEGIN_SUML", "END_DBMARK", "END_SUML", "DRAW_ID", "DRAWING_NO", "INSTALLED_FLAG", "BARCODE", "EFFECTIVE_LENGTH", "BSA_FLAG", "BSA_FLAG_EPICS", "BSA_FLAG_SLC", "OBSTRUCTION", "OPS_STATUS", "OPS_STATUS_DATE", "SECTOR", "SECTOR_LOCATION", "UNDULATOR_CELL", "IRMIS_IOC_NAMES", "RF_FREQUENCY", "RF_AMPLITUDE", "RF_PHASE", "RF_GRADIENT", "RF_POWER_FRACTION", "Z_LENGTH", "FRINGE_FIELD_INTEGRAL", "INTEGRATED_FIELD_BL", "FIELD_B", "INTEGRATED_FIELD_GRAD_GL", "FIELD_GRADIENT_G", "XAL_SCALE_NAME", "XAL_SCALE_VALUE", "XAL_POLARITY", "MAGNET_X_COOR", "MAGNET_Y_COOR", "MAGNET_Z_COOR", "MAGNET_X_ANGLE", "MAGNET_Y_ANGLE", "MAGNET_Z_ANGLE", "SOLENOID_STRENGTH_KS", "UNDULATOR_PERIOD_LENGTH", "UNDULATOR_STRENGTH_K", "X_SIZE", "Y_SIZE", "SECTION", "DIST_FROM_SECTION_START", "XAL_KEYWORD", "S_DISPLAY", "SOLID_EDGE_ID", "APERTURE", "ANGLE", "K1", "K2", "TILT", "E1", "E2", "H1", "H2", "ENERGY", "SOLID_EDGE_YCOOR_M", "SOLID_EDGE_ZCOOR_M", "SOLID_EDGE_YCOOR_FT", "SOLID_EDGE_ZCOOR_FT", "SOLID_EDGE_X_ANGLE", "SOLID_EDGE_Y_ANGLE", "SOLID_EDGE_Z_ANGLE", "REVISION", "REVISION_DATE", "LTU_RF_FREQUENCY", "LTU_RF_AMPLITUDE", "LTU_RF_PHASE", "LTU_RF_GRADIENT", "LTU_RF_POWER_FRACTION", "LTU_Z_LENGTH", "LTU_FRINGE_FIELD_INTEGRAL", "LTU_INTEGRATED_FIELD_BL", "LTU_FIELD_B", "LTU_INTEGRATED_FIELD_GRAD_GL", "LTU_FIELD_GRADIENT_G", "LTU_XAL_SCALE_NAME", "LTU_XAL_SCALE_VALUE", "LTU_XAL_POLARITY", "LTU_MAGNET_X_COOR", "LTU_MAGNET_Y_COOR", "LTU_MAGNET_Z_COOR", "LTU_MAGNET_X_ANGLE", "LTU_MAGNET_Y_ANGLE", "LTU_MAGNET_Z_ANGLE", "LTU_SOLENOID_STRENGTH_KS", "LTU_UNDULATOR_PERIOD_LENGTH", "LTU_UNDULATOR_STRENGTH_K", "LTU_X_SIZE", "LTU_Y_SIZE", "LTU_SECTION", "LTU_DIST_FROM_SECTION_START", "LTU_XAL_KEYWORD", "LTU_S_DISPLAY", "LTU_SOLID_EDGE_ID", "LTU_APERTURE", "LTU_ANGLE", "LTU_K1", "LTU_K2", "LTU_TILT", "LTU_E1", "LTU_E2", "LTU_H1", "LTU_H2", "LTU_ENERGY", "LTU_SOLID_EDGE_YCOOR_M", "LTU_SOLID_EDGE_ZCOOR_M", "LTU_SOLID_EDGE_YCOOR_FT", "LTU_SOLID_EDGE_ZCOOR_FT", "LTU_SOLID_EDGE_X_ANGLE", "LTU_SOLID_EDGE_Y_ANGLE", "LTU_SOLID_EDGE_Z_ANGLE", "LTU_REVISION", "LTU_REVISION_DATE", "COMPONENT_NAME", "COMPONENT_COMMENTS") AS 
  SELECT t.element_id,
          t.element,
          t.first_sourced_from,
          t.element_type,
          t.active_flag,
          t.element_comment,
          t.area,
          t.keyword,
          t.engineering_name,
          ------
          t.symbols_upload_id,
          t.ltu_upload_id,
          ------
          t.suml_m,
          t.suml_ft,
          t.linacz_m,
          t.linacz_ft,
          ------
          t.ltu_suml_m,
          t.ltu_suml_ft,
          t.ltu_linacz_m,
          t.ltu_linacz_ft,
          ------
          t.mad_suml_m,
          t.mad_solid_edge_xcoor_m,
          t.mad_suml_ft,
          t.mad_solid_edge_xcoor_ft,
          ------
          t.nonmad_suml_m,
          t.nonmad_solid_edge_xcoor_m,
          t.nonmad_suml_ft,
          t.nonmad_solid_edge_xcoor_ft,
          t.primary,
          t.slc_micro_name,
          t.ioc_loc,
          t.unit,
          ------
          t.epics_device_name,
          t.slc_name,
          ------
          t.epics_channel_access_name,
          ------
          t.ioc_captar_search,
          t.slc_captar_search,
          ------
          t.beamline_id,
          t.beamline,
          t.section_id,
          t.sections,
          t.begin_dbmark,
          t.begin_suml,
          t.end_dbmark,
          t.end_suml,
          -- (T.SUML_M - T.BEGIN_SUML) AS DISTANCE_FROM_START,
          t.draw_id,
          t.drawing_no,
          t.installed_flag,
          t.barcode,
          ------
          t.effective_length,
          ------
          CASE
             WHEN (t.epics_channel_access_name IN
                      (SELECT SUBSTR (root_name,
                                      1,
                                        INSTR (root_name,
                                               ':',
                                               1,
                                               3)
                                      - 1)
                         FROM irmisdb.bsa_root_names@TOMCCO_IRMISDB.SLACPROD.SLAC.STANFORD.EDU))
             THEN
                'Y'
             ELSE
                'N'
          END
             AS bsa_flag,
          ------
          CASE
             WHEN ( (SELECT COUNT (*)
                       FROM IRMISDB.BSA_ROOT_NAMES@TOMCCO_IRMISDB.SLACPROD.SLAC.STANFORD.EDU
                      WHERE     SUBSTR (ROOT_NAME,
                                        1,
                                          INSTR (ROOT_NAME,
                                                 ':',
                                                 1,
                                                 3)
                                        - 1) = T.EPICS_CHANNEL_ACCESS_NAME
                            AND SOURCE = 'EPICS') > 0)
             THEN
                'Y'
             ELSE
                'N'
          END
             AS bsa_flag_epics,
          ------
          CASE
             WHEN ( (SELECT COUNT (*)
                       FROM IRMISDB.BSA_ROOT_NAMES@TOMCCO_IRMISDB.SLACPROD.SLAC.STANFORD.EDU
                      WHERE     SUBSTR (ROOT_NAME,
                                        1,
                                          INSTR (ROOT_NAME,
                                                 ':',
                                                 1,
                                                 3)
                                        - 1) = T.EPICS_CHANNEL_ACCESS_NAME
                            AND SOURCE = 'SLC') > 0)
             THEN
                'Y'
             ELSE
                'N'
          END
             AS bsa_flag_slc,
          ------
          t.obstruction,
	  t.ops_status,
	  t.ops_status_date,
          t.sector,
          t.sector_location,
	  t.undulator_cell,
          ------
          t.irmis_ioc_names,
          ---- BEGIN NEW FIELDS (FROM SYMBOLS_UPLOAD) ----
          t.rf_frequency,
          t.rf_amplitude,
          t.rf_phase,
          t.rf_gradient,
          t.rf_power_fraction,
          t.z_length,
          t.fringe_field_integral,
          t.integrated_field_bl,
          t.field_b,
          t.integrated_field_grad_gl,
          t.field_gradient_g,
          t.xal_scale_name,
          t.xal_scale_value,
          t.xal_polarity,
          t.magnet_x_coor,
          t.magnet_y_coor,
          t.magnet_z_coor,
          t.magnet_x_angle,
          t.magnet_y_angle,
          t.magnet_z_angle,
          t.solenoid_strength_ks,
          t.undulator_period_length,
          t.undulator_strength_k,
          t.x_size,
          t.y_size,
          t.section,
          t.dist_from_section_start,
          t.xal_keyword,
          t.s_display,
          -- ELIE: BEGIN ADDED COLUMNS (7-NOV-2010)
          T.SOLID_EDGE_ID,
          T.APERTURE,
          T.ANGLE,
          T.K1,
          T.K2,
          T.TILT,
          T.E1,
          T.E2,
          T.H1,
          T.H2,
          T.ENERGY,
          T.SOLID_EDGE_YCOOR_M,
          T.SOLID_EDGE_ZCOOR_M,
          T.SOLID_EDGE_YCOOR_FT,
          T.SOLID_EDGE_ZCOOR_FT,
          T.SOLID_EDGE_X_ANGLE,
          T.SOLID_EDGE_Y_ANGLE,
          T.SOLID_EDGE_Z_ANGLE,
          T.REVISION,
          T.REVISION_DATE,
          -- ELIE: END ADDED COLUMNS (7-NOV-2010)
          ---- END NEW FIELDS (FROM SYMBOLS_UPLOAD) ----
          --------
          ---- BEGIN NEW FIELDS (FROM LTU_UPLOAD) ----
          t.ltu_rf_frequency,
          t.ltu_rf_amplitude,
          t.ltu_rf_phase,
          t.ltu_rf_gradient,
          t.ltu_rf_power_fraction,
          t.ltu_z_length,
          t.ltu_fringe_field_integral,
          t.ltu_integrated_field_bl,
          t.ltu_field_b,
          t.ltu_integrated_field_grad_gl,
          t.ltu_field_gradient_g,
          t.ltu_xal_scale_name,
          t.ltu_xal_scale_value,
          t.ltu_xal_polarity,
          t.ltu_magnet_x_coor,
          t.ltu_magnet_y_coor,
          t.ltu_magnet_z_coor,
          t.ltu_magnet_x_angle,
          t.ltu_magnet_y_angle,
          t.ltu_magnet_z_angle,
          t.ltu_solenoid_strength_ks,
          t.ltu_undulator_period_length,
          t.ltu_undulator_strength_k,
          t.ltu_x_size,
          t.ltu_y_size,
          t.ltu_section,
          t.ltu_dist_from_section_start,
          t.ltu_xal_keyword,
          t.ltu_s_display,
          -- ELIE: BEGIN ADDED COLUMNS (7-NOV-2010)
          T.LTU_SOLID_EDGE_ID,
          T.LTU_APERTURE,
          T.LTU_ANGLE,
          T.LTU_K1,
          T.LTU_K2,
          T.LTU_TILT,
          T.LTU_E1,
          T.LTU_E2,
          T.LTU_H1,
          T.LTU_H2,
          T.LTU_ENERGY,
          T.LTU_SOLID_EDGE_YCOOR_M,
          T.LTU_SOLID_EDGE_ZCOOR_M,
          T.LTU_SOLID_EDGE_YCOOR_FT,
          T.LTU_SOLID_EDGE_ZCOOR_FT,
          T.LTU_SOLID_EDGE_X_ANGLE,
          T.LTU_SOLID_EDGE_Y_ANGLE,
          T.LTU_SOLID_EDGE_Z_ANGLE,
          T.LTU_REVISION,
          T.LTU_REVISION_DATE,
          -- ELIE: END ADDED COLUMNS (7-NOV-2010)
          ---- END NEW FIELDS (FROM LTU_UPLOAD) ----
          --------
          t.component_name,
          t.component_comments
     FROM (SELECT l.element_id,
                  l.element,
                  l.first_sourced_from,
                  l.element_type,
                  l.active_flag,
                  l.element_comment,
                  DECODE (l.area, NULL, '- NO AREA -', l.area) AS area,
                  l.keyword,
                  ---------- Poonam - 1/25/2019
		  COALESCE(l.engineering_name, sx.symbols_engineering_name) as engineering_name,
                  --l.engineering_name,
                  -- BEGIN SYMBOLS COORDINATES
                  CASE WHEN ( 'MARK' IN (SX.XAL_KEYWORD, TX.LTU_XAL_KEYWORD) ) THEN  COALESCE (L.NONMAD_SUML_M, SX.SUML)
                            ELSE COALESCE (SX.SUML, L.NONMAD_SUML_M)
                  END AS SUML_M,
                  ----------
                  CASE WHEN ( 'MARK' IN (SX.XAL_KEYWORD, TX.LTU_XAL_KEYWORD) ) THEN ROUND (COALESCE (L.NONMAD_SUML_M, SX.SUML) * 3.28083989501, 6)
                            ELSE ROUND (COALESCE (SX.SUML, L.NONMAD_SUML_M) * 3.28083989501, 6)
                   END AS SUML_FT,
                   ----------
                  CASE WHEN ( 'MARK' IN (SX.XAL_KEYWORD, TX.LTU_XAL_KEYWORD) ) THEN COALESCE (L.NONMAD_SOLID_EDGE_XCOOR_M, SX.SOLID_EDGE_X_COOR)
                           ELSE COALESCE (SX.SOLID_EDGE_X_COOR, L.NONMAD_SOLID_EDGE_XCOOR_M)
                  END AS LINACZ_M,
                  ----------
                  CASE WHEN ( 'MARK' IN (SX.XAL_KEYWORD, TX.LTU_XAL_KEYWORD) ) THEN ROUND (COALESCE (L.NONMAD_SOLID_EDGE_XCOOR_M, SX.SOLID_EDGE_X_COOR) * 3.28083989501, 6)
                           ELSE ROUND (COALESCE (SX.SOLID_EDGE_X_COOR, L.NONMAD_SOLID_EDGE_XCOOR_M) * 3.28083989501, 6)
                  END AS LINACZ_FT,
                  -- END SYMBOLS COORDINATES
                  -- BEGIN LTU COORDINATES
                  CASE WHEN ( 'MARK' IN (SX.XAL_KEYWORD, TX.LTU_XAL_KEYWORD) ) THEN COALESCE (L.NONMAD_LTU_SUML_M, TX.LTU_SUML)
                           ELSE COALESCE (TX.LTU_SUML, L.NONMAD_LTU_SUML_M)
                  END AS LTU_SUML_M,
                  ---------
                  CASE WHEN ( 'MARK' IN (SX.XAL_KEYWORD, TX.LTU_XAL_KEYWORD) ) THEN ROUND (COALESCE (L.NONMAD_LTU_SUML_M, TX.LTU_SUML) * 3.28083989501, 6)
                            ELSE ROUND (COALESCE (TX.LTU_SUML, L.NONMAD_LTU_SUML_M) * 3.28083989501, 6)
                  END AS LTU_SUML_FT,
                  ---------
                  CASE WHEN ( 'MARK' IN (SX.XAL_KEYWORD, TX.LTU_XAL_KEYWORD) ) THEN COALESCE (L.NONMAD_LTU_SOLID_EDGE_XCOOR_M, TX.LTU_SOLID_EDGE_X_COOR)
                           ELSE COALESCE (TX.LTU_SOLID_EDGE_X_COOR, L.NONMAD_LTU_SOLID_EDGE_XCOOR_M)
                  END AS LTU_LINACZ_M,
                  ---------
                  CASE WHEN ( 'MARK' IN (SX.XAL_KEYWORD, TX.LTU_XAL_KEYWORD) ) THEN ROUND (COALESCE (L.NONMAD_LTU_SOLID_EDGE_XCOOR_M, TX.LTU_SOLID_EDGE_X_COOR) * 3.28083989501, 6)
                            ELSE ROUND (COALESCE (TX.LTU_SOLID_EDGE_X_COOR, L.NONMAD_LTU_SOLID_EDGE_XCOOR_M) * 3.28083989501, 6)
                  END AS LTU_LINACZ_FT,
                  -- END LTU COORDINATES
                  ------
                  sx.symbols_upload_id,
                  tx.ltu_upload_id,
                  ------
                  sx.suml AS mad_suml_m,
                  sx.solid_edge_x_coor AS mad_solid_edge_xcoor_m,
                  ROUND (sx.suml * 3.28083989501, 6) AS mad_suml_ft,
                  ROUND (sx.solid_edge_x_coor * 3.28083989501, 6)
                     AS mad_solid_edge_xcoor_ft,
                  ------
                  -- ELIE: BEGIN ADDED COLUMNS (7-NOV-2010)
                  SX.SOLID_EDGE_Y_COOR AS SOLID_EDGE_YCOOR_M,
                  SX.SOLID_EDGE_Z_COOR AS SOLID_EDGE_ZCOOR_M,
                  ROUND (SX.SOLID_EDGE_Y_COOR * 3.28083989501, 6)
                     AS SOLID_EDGE_YCOOR_FT,
                  ROUND (SX.SOLID_EDGE_Z_COOR * 3.28083989501, 6)
                     AS SOLID_EDGE_ZCOOR_FT,
                  ------
                  TX.LTU_SOLID_EDGE_Y_COOR AS LTU_SOLID_EDGE_YCOOR_M,
                  TX.LTU_SOLID_EDGE_Z_COOR AS LTU_SOLID_EDGE_ZCOOR_M,
                  ROUND (TX.LTU_SOLID_EDGE_Y_COOR * 3.28083989501, 6)
                     AS LTU_SOLID_EDGE_YCOOR_FT,
                  ROUND (TX.LTU_SOLID_EDGE_Z_COOR * 3.28083989501, 6)
                     AS LTU_SOLID_EDGE_ZCOOR_FT,
                  -- ELIE: END ADDED COLUMNS (7-NOV-2010)
                  ------
                  l.nonmad_suml_m,
                  l.nonmad_solid_edge_xcoor_m,
                  ROUND (l.nonmad_suml_m * 3.28083989501, 6)
                     AS nonmad_suml_ft,
                  ROUND (l.nonmad_solid_edge_xcoor_m * 3.28083989501, 6)
                     AS nonmad_solid_edge_xcoor_ft,
                  ------
                  sx.effective_length,
                  ------
                  l.primary,
                  l.slc_micro_name,
                  l.ioc_loc,
                  l.unit,
                  ------
                  CASE
                     WHEN (    l.primary IS NULL
                           AND l.ioc_loc IS NULL
                           AND l.unit IS NULL)
                     THEN
                        '- NO EPICS NAME -'
                     ELSE
                        l.primary || ':' || l.ioc_loc || ':' || l.unit
                  END
                     AS epics_device_name,
                  ------
                  CASE
                     WHEN (l.slc_micro_name IS NULL)
                     THEN
                        NULL
                     ELSE
                        l.primary || ':' || l.slc_micro_name || ':' || l.unit
                  END
                     AS slc_name,
                  ------
                  CASE
                     WHEN (l.primary IS NOT NULL AND l.unit IS NOT NULL)
                     THEN
                        CASE
                           WHEN (    (l.ioc_loc IS NOT NULL)
                                 AND (l.ioc_loc =
                                         NVL (l.slc_micro_name, 'NULL')))
                           THEN
                                 l.slc_micro_name
                              || ':'
                              || l.primary
                              || ':'
                              || l.unit
                           WHEN (    (l.ioc_loc IS NOT NULL)
                                 AND (l.ioc_loc !=
                                         NVL (l.slc_micro_name, 'NULL')))
                           THEN
                              l.primary || ':' || l.ioc_loc || ':' || l.unit
                           WHEN (l.slc_micro_name IS NOT NULL)
                           THEN
                                 l.slc_micro_name
                              || ':'
                              || l.primary
                              || ':'
                              || l.unit
                           ELSE
                              NULL
                        END
                     ELSE
                        NULL
                  END
                     AS epics_channel_access_name,
                  ------
                  DECODE (l.primary || ':' || l.ioc_loc,
                          ':', '%25',
                          l.primary || ':' || l.ioc_loc || '%25')
                     AS ioc_captar_search,
                  ------
                  DECODE (l.primary || ':' || l.slc_micro_name,
                          ':', '%25',
                          l.primary || ':' || l.slc_micro_name || '%25')
                     AS slc_captar_search,
                  ------
                  l.beamline_id,
                  (SELECT b.description
                     FROM lcls_infrastructure.beamlines b
                    WHERE b.id = l.beamline_id)
                     AS beamline,
                  ------
                  -- L.SECTION_ID,
                  -- DECODE(S.SECTION, NULL, '- NO SECTION -', S.SECTION) AS SECTIONS,
                  rb.section_id,
                  DECODE (rb.section, NULL, '- NO SECTION -', rb.section)
                     AS sections,
                  rb.begin_dbmark,
                  rb.begin_suml,
                  re.end_dbmark,
                  re.end_suml,
                  ------
                  l.draw_id,
                  ------
                  (SELECT (   d.prefix
                           || '-'
                           || TO_CHAR (d.series)
                           || '-'
                           || TO_CHAR (d.base)
                           || '-'
                           || TO_CHAR (d.suffix))
                     FROM draw.md_draw d
                    WHERE d.draw_id(+) = l.draw_id)
                     AS drawing_no,
                  ------
                  /*
                  (CASE WHEN (Y.RES_CNT = 0)
                  THEN '<style type=text/css> .this_link {white-space: nowrap; color: green;}</style><a class=this_link href=http://mdweb.slac.stanford.edu/Doc%20Control.ODA.By%20Drawing%20Number.php?drawnum=' ||
                       (SELECT (D.PREFIX||'-'||TO_CHAR(D.SERIES)||'-'||TO_CHAR(D.BASE)||'-'||TO_CHAR(D.SUFFIX))
                          FROM DRAW.MD_DRAW D
                         WHERE D.DRAW_ID = L.DRAW_ID
                       ) ||
                       '>' ||
                       (SELECT (D.PREFIX||'-'||TO_CHAR(D.SERIES)||'-'||TO_CHAR(D.BASE)||'-'||TO_CHAR(D.SUFFIX))
                          FROM DRAW.MD_DRAW D
                         WHERE D.DRAW_ID = L.DRAW_ID
                       ) ||
                       '   <img src=/i/diamonds.gif border=0></a>'
                  ELSE '<style type=text/css> .this_link {white-space: nowrap; color: green;}</style><a class=this_link href=http://mdweb.slac.stanford.edu/Doc%20Control.ODA.By%20Drawing%20Number.php?drawnum=' ||
                       (SELECT (D.PREFIX||'-'||TO_CHAR(D.SERIES)||'-'||TO_CHAR(D.BASE)||'-'||TO_CHAR(D.SUFFIX))
                          FROM DRAW.MD_DRAW D
                         WHERE D.DRAW_ID = L.DRAW_ID
                       ) ||
                       '>' ||
                       (SELECT (D.PREFIX||'-'||TO_CHAR(D.SERIES)||'-'||TO_CHAR(D.BASE)||'-'||TO_CHAR(D.SUFFIX))
                          FROM DRAW.MD_DRAW D
                         WHERE D.DRAW_ID = L.DRAW_ID
                       ) ||
                       '</a>'
                  END) AS DRAWING_NO,
                  */
                  ------
                  l.installed_flag,
                  ------
                  COALESCE(px.barcode, yx.barcode) barcode,
                  ------
                  l.obstruction_chk AS obstruction,
	         (select initcap(a.ops_status) from LCLS_ELEMENTS_OPS_STATUS a 
	          where a.ops_status_id = l.ops_status_id) as ops_status,
		  l.ops_status_date,
--	          to_date(l.ops_status_date,'MM/DD/YYYY') as ops_status_date,
                  l.sector,
                  l.sector_location,
		  l.undulator_cell,
                  ------
                  mv.irmis_ioc_names,
                  ---- BEGIN NEW FIELDS (FROM SYMBOLS_UPLOAD)----
                  sx.rf_frequency,
                  sx.rf_amplitude,
                  sx.rf_phase,
                  sx.rf_gradient,
                  sx.rf_power_fraction,
                  sx.z_length,
                  sx.fringe_field_integral,
                  sx.integrated_field_bl,
                  sx.field_b,
                  sx.integrated_field_grad_gl,
                  sx.field_gradient_g,
                  sx.xal_scale_name,
                  sx.xal_scale_value,
                  sx.xal_polarity,
                  sx.magnet_x_coor,
                  sx.magnet_y_coor,
                  sx.magnet_z_coor,
                  sx.magnet_x_angle,
                  sx.magnet_y_angle,
                  sx.magnet_z_angle,
                  sx.solenoid_strength_ks,
                  sx.undulator_period_length,
                  sx.undulator_strength_k,
                  sx.x_size,
                  sx.y_size,
                  sx.section,
                  sx.dist_from_section_start,
                  sx.xal_keyword,
                  sx.s_display,
                  ----------
                  SX.SOLID_EDGE_ID,
                  SX.APERTURE,
                  SX.ANGLE,
                  SX.K1,
                  SX.K2,
                  SX.TILT,
                  SX.E1,
                  SX.E2,
                  SX.H1,
                  SX.H2,
                  SX.ENERGY,
                  SX.SOLID_EDGE_Y_COOR,
                  SX.SOLID_EDGE_Z_COOR,
                  SX.SOLID_EDGE_X_ANGLE,
                  SX.SOLID_EDGE_Y_ANGLE,
                  SX.SOLID_EDGE_Z_ANGLE,
                  SX.REVISION,
                  SX.REVISION_DATE,
                  ---- END NEW FIELDS (FROM SYMBOLS_UPLOAD) ----
                  ---- BEGIN NEW FIELDS (FROM LTU_UPLOAD) ----
                  tx.ltu_rf_frequency,
                  tx.ltu_rf_amplitude,
                  tx.ltu_rf_phase,
                  tx.ltu_rf_gradient,
                  tx.ltu_rf_power_fraction,
                  tx.ltu_z_length,
                  tx.ltu_fringe_field_integral,
                  tx.ltu_integrated_field_bl,
                  tx.ltu_field_b,
                  tx.ltu_integrated_field_grad_gl,
                  tx.ltu_field_gradient_g,
                  tx.ltu_xal_scale_name,
                  tx.ltu_xal_scale_value,
                  tx.ltu_xal_polarity,
                  tx.ltu_magnet_x_coor,
                  tx.ltu_magnet_y_coor,
                  tx.ltu_magnet_z_coor,
                  tx.ltu_magnet_x_angle,
                  tx.ltu_magnet_y_angle,
                  tx.ltu_magnet_z_angle,
                  tx.ltu_solenoid_strength_ks,
                  tx.ltu_undulator_period_length,
                  tx.ltu_undulator_strength_k,
                  tx.ltu_x_size,
                  tx.ltu_y_size,
                  tx.ltu_section,
                  tx.ltu_dist_from_section_start,
                  tx.ltu_xal_keyword,
                  tx.ltu_s_display,
                  ----------
                  TX.LTU_SOLID_EDGE_ID,
                  TX.LTU_APERTURE,
                  TX.LTU_ANGLE,
                  TX.LTU_K1,
                  TX.LTU_K2,
                  TX.LTU_TILT,
                  TX.LTU_E1,
                  TX.LTU_E2,
                  TX.LTU_H1,
                  TX.LTU_H2,
                  TX.LTU_ENERGY,
                  TX.LTU_SOLID_EDGE_Y_COOR,
                  TX.LTU_SOLID_EDGE_Z_COOR,
                  TX.LTU_SOLID_EDGE_X_ANGLE,
                  TX.LTU_SOLID_EDGE_Y_ANGLE,
                  TX.LTU_SOLID_EDGE_Z_ANGLE,
                  TX.LTU_REVISION,
                  TX.LTU_REVISION_DATE,
                  ---- END NEW FIELDS (FROM LTU_UPLOAD) ----
                  cx.component_name,
                  cx.component_comments
             FROM lcls_infrastructure.lcls_elements l,
                  ------
                  -- LCLS_INFRASTRUCTURE.SECTIONS S,
                  ------
                  (SELECT p.section_id,
                          p.section,
                          x1.element AS begin_dbmark,
                          x1.suml AS begin_suml
                     FROM (SELECT ul.beamline,
                                  ul.upload_id,
                                  u.element,
                                  u.suml
                             FROM lcls_infrastructure.symbols_upload u,
                                  lcls_infrastructure.symbols_upload_log ul
                            WHERE     u.upload_id = ul.upload_id
                                  AND u.element LIKE 'DBMARK%') x1,
                          lcls_infrastructure.sections p
                    WHERE     x1.upload_id =
                                 (SELECT MAX (y1.upload_id)
                                    FROM lcls_infrastructure.symbols_upload_log y1
                                   WHERE y1.beamline = x1.beamline)
                          AND x1.element = p.begin_dbmark) rb,
                  ------
                  (SELECT p.section_id,
                          p.section,
                          x1.element AS end_dbmark,
                          x1.suml AS end_suml
                     FROM (SELECT ul.beamline,
                                  ul.upload_id,
                                  u.element,
                                  u.suml
                             FROM lcls_infrastructure.symbols_upload u,
                                  lcls_infrastructure.symbols_upload_log ul
                            WHERE     u.upload_id = ul.upload_id
                                  AND u.element LIKE 'DBMARK%') x1,
                          lcls_infrastructure.sections p
                    WHERE     x1.upload_id =
                                 (SELECT MAX (y1.upload_id)
                                    FROM lcls_infrastructure.symbols_upload_log y1
                                   WHERE y1.beamline = x1.beamline)
                          AND x1.element = p.end_dbmark) re,
                  ------
                  (SELECT i.barcode, i.element
                     FROM lcls_infrastructure.lcls_inventory i
                    WHERE i.barcode IS NOT NULL) yx,
                  ------
                  lcls_infrastructure.mv_irmis_ioc_names_per_element mv,
                  ------
                  (SELECT w.src,
                          w.element,
                          w.upload_id AS symbols_upload_id,
			  w.engineering_name as symbols_engineering_name,
                          w.suml,
                          w.solid_edge_x_coor,
                          w.effective_length,
                          w.rf_frequency,
                          w.rf_amplitude,
                          w.rf_phase,
                          w.rf_gradient,
                          w.rf_power_fraction,
                          w.z_length,
                          w.fringe_field_integral,
                          w.integrated_field_bl,
                          w.field_b,
                          w.integrated_field_grad_gl,
                          w.field_gradient_g,
                          w.xal_scale_name,
                          w.xal_scale_value,
                          w.xal_polarity,
                          w.magnet_x_coor,
                          w.magnet_y_coor,
                          w.magnet_z_coor,
                          w.magnet_x_angle,
                          w.magnet_y_angle,
                          w.magnet_z_angle,
                          w.solenoid_strength_ks,
                          w.undulator_period_length,
                          w.undulator_strength_k,
                          w.x_size,
                          w.y_size,
                          w.section,
                          w.dist_from_section_start,
                          w.xal_keyword,
                          w.s_display,
                          -- ##BEGIN ADDED COLUMNS
                          W.SOLID_EDGE_ID,
                          W.APERTURE,
                          W.ANGLE,
                          W.K1,
                          W.K2,
                          W.TILT,
                          W.E1,
                          W.E2,
                          W.H1,
                          W.H2,
                          W.ENERGY,
                          W.SOLID_EDGE_Y_COOR,
                          W.SOLID_EDGE_Z_COOR,
                          W.SOLID_EDGE_X_ANGLE,
                          W.SOLID_EDGE_Y_ANGLE,
                          W.SOLID_EDGE_Z_ANGLE,
                          W.REVISION,
                          W.REVISION_DATE
                     FROM (SELECT 'SYMBOLS' AS src,
                                  ul.beamline,
                                  ul.upload_id,
				  u.engineering_name,
                                  u.element,
                                  u.suml,
                                  u.solid_edge_x_coor,
                                  u.effective_length,
                                  u.rf_frequency,
                                  u.rf_amplitude,
                                  u.rf_phase,
                                  u.rf_gradient,
                                  u.rf_power_fraction,
                                  u.z_length,
                                  u.fringe_field_integral,
                                  u.integrated_field_bl,
                                  u.field_b,
                                  u.integrated_field_grad_gl,
                                  u.field_gradient_g,
                                  u.xal_scale_name,
                                  u.xal_scale_value,
                                  u.xal_polarity,
                                  u.magnet_x_coor,
                                  u.magnet_y_coor,
                                  u.magnet_z_coor,
                                  u.magnet_x_angle,
                                  u.magnet_y_angle,
                                  u.magnet_z_angle,
                                  u.solenoid_strength_ks,
                                  u.undulator_period_length,
                                  u.undulator_strength_k,
                                  u.x_size,
                                  u.y_size,
                                  u.section,
                                  u.dist_from_section_start,
                                  u.xal_keyword,
                                  u.s_display,
                                  -- ##BEGIN ADDED COLUMNS
                                  U.SOLID_EDGE_ID,
                                  U.APERTURE,
                                  U.ANGLE,
                                  U.K1,
                                  U.K2,
                                  U.TILT,
                                  U.E1,
                                  U.E2,
                                  U.H1,
                                  U.H2,
                                  U.ENERGY,
                                  U.SOLID_EDGE_Y_COOR,
                                  U.SOLID_EDGE_Z_COOR,
                                  U.SOLID_EDGE_X_ANGLE,
                                  U.SOLID_EDGE_Y_ANGLE,
                                  U.SOLID_EDGE_Z_ANGLE,
                                  U.REVISION,
                                  U.REVISION_DATE
                             FROM lcls_infrastructure.symbols_upload u,
                                  lcls_infrastructure.symbols_upload_log ul
                            WHERE u.upload_id = ul.upload_id) w
                    WHERE w.upload_id = (SELECT MAX (upload_id)
                                           FROM lcls_infrastructure.symbols_upload_log
                                          WHERE beamline = w.beamline)) sx,
                  ------
                  (SELECT w.src,
                          w.element,
                          w.upload_id AS ltu_upload_id,
                          w.suml AS ltu_suml,
                          w.solid_edge_x_coor AS ltu_solid_edge_x_coor,
                          w.effective_length AS ltu_effective_length,
                          w.rf_frequency AS ltu_rf_frequency,
                          w.rf_amplitude AS ltu_rf_amplitude,
                          w.rf_phase AS ltu_rf_phase,
                          w.rf_gradient AS ltu_rf_gradient,
                          w.rf_power_fraction AS ltu_rf_power_fraction,
                          w.z_length AS ltu_z_length,
                          w.fringe_field_integral
                             AS ltu_fringe_field_integral,
                          w.integrated_field_bl AS ltu_integrated_field_bl,
                          w.field_b AS ltu_field_b,
                          w.integrated_field_grad_gl
                             AS ltu_integrated_field_grad_gl,
                          w.field_gradient_g AS ltu_field_gradient_g,
                          w.xal_scale_name AS ltu_xal_scale_name,
                          w.xal_scale_value AS ltu_xal_scale_value,
                          w.xal_polarity AS ltu_xal_polarity,
                          w.magnet_x_coor AS ltu_magnet_x_coor,
                          w.magnet_y_coor AS ltu_magnet_y_coor,
                          w.magnet_z_coor AS ltu_magnet_z_coor,
                          w.magnet_x_angle AS ltu_magnet_x_angle,
                          w.magnet_y_angle AS ltu_magnet_y_angle,
                          w.magnet_z_angle AS ltu_magnet_z_angle,
                          w.solenoid_strength_ks AS ltu_solenoid_strength_ks,
                          w.undulator_period_length
                             AS ltu_undulator_period_length,
                          w.undulator_strength_k AS ltu_undulator_strength_k,
                          w.x_size AS ltu_x_size,
                          w.y_size AS ltu_y_size,
                          w.section AS ltu_section,
                          w.dist_from_section_start
                             AS ltu_dist_from_section_start,
                          w.xal_keyword AS ltu_xal_keyword,
                          w.s_display AS ltu_s_display,
                          -- ##BEGIN ADDED COLUMNS
                          W.SOLID_EDGE_ID AS LTU_SOLID_EDGE_ID,
                          W.APERTURE AS LTU_APERTURE,
                          W.ANGLE AS LTU_ANGLE,
                          W.K1 AS LTU_K1,
                          W.K2 AS LTU_K2,
                          W.TILT AS LTU_TILT,
                          W.E1 AS LTU_E1,
                          W.E2 AS LTU_E2,
                          W.H1 AS LTU_H1,
                          W.H2 AS LTU_H2,
                          W.ENERGY AS LTU_ENERGY,
                          W.SOLID_EDGE_Y_COOR AS LTU_SOLID_EDGE_Y_COOR,
                          W.SOLID_EDGE_Z_COOR AS LTU_SOLID_EDGE_Z_COOR,
                          W.SOLID_EDGE_X_ANGLE AS LTU_SOLID_EDGE_X_ANGLE,
                          W.SOLID_EDGE_Y_ANGLE AS LTU_SOLID_EDGE_Y_ANGLE,
                          W.SOLID_EDGE_Z_ANGLE AS LTU_SOLID_EDGE_Z_ANGLE,
                          W.REVISION AS LTU_REVISION,
                          W.REVISION_DATE AS LTU_REVISION_DATE
                     FROM (SELECT 'LTU' AS src,
                                  ul.beamline,
                                  ul.upload_id,
                                  u.element,
                                  u.suml,
                                  u.solid_edge_x_coor,
                                  u.effective_length,
                                  u.rf_frequency,
                                  u.rf_amplitude,
                                  u.rf_phase,
                                  u.rf_gradient,
                                  u.rf_power_fraction,
                                  u.z_length,
                                  u.fringe_field_integral,
                                  u.integrated_field_bl,
                                  u.field_b,
                                  u.integrated_field_grad_gl,
                                  u.field_gradient_g,
                                  u.xal_scale_name,
                                  u.xal_scale_value,
                                  u.xal_polarity,
                                  u.magnet_x_coor,
                                  u.magnet_y_coor,
                                  u.magnet_z_coor,
                                  u.magnet_x_angle,
                                  u.magnet_y_angle,
                                  u.magnet_z_angle,
                                  u.solenoid_strength_ks,
                                  u.undulator_period_length,
                                  u.undulator_strength_k,
                                  u.x_size,
                                  u.y_size,
                                  u.section,
                                  u.dist_from_section_start,
                                  u.xal_keyword,
                                  u.s_display,
                                  -- ##BEGIN ADDED COLUMNS
                                  U.SOLID_EDGE_ID,
                                  U.APERTURE,
                                  U.ANGLE,
                                  U.K1,
                                  U.K2,
                                  U.TILT,
                                  U.E1,
                                  U.E2,
                                  U.H1,
                                  U.H2,
                                  U.ENERGY,
                                  U.SOLID_EDGE_Y_COOR,
                                  U.SOLID_EDGE_Z_COOR,
                                  U.SOLID_EDGE_X_ANGLE,
                                  U.SOLID_EDGE_Y_ANGLE,
                                  U.SOLID_EDGE_Z_ANGLE,
                                  U.REVISION,
                                  U.REVISION_DATE
                             FROM lcls_infrastructure.ltu_upload u,
                                  lcls_infrastructure.ltu_upload_log ul
                            WHERE u.upload_id = ul.upload_id) w
                    WHERE w.upload_id = (SELECT MAX (U3.upload_id)
                                           FROM lcls_infrastructure.ltu_upload U2,
                                                lcls_infrastructure.ltu_upload_log U3
                                          WHERE U2.upload_id = u3.upload_id
                                          AND U2.ELEMENT = W.ELEMENT)) tx,
                  ------
                  (SELECT lc.comp_name AS component_name,
                          ecj.element_id,
                          lc.comments AS component_comments
                     FROM lcls_infrastructure.lcls_comp lc,
                          lcls_infrastructure.lcls_junc_elem_comp ecj
                    WHERE lc.comp_id = ecj.comp_id) cx,
		    (select element, barcode from magnet_polynomial
		      where barcode is not null) px
            WHERE (    UPPER (TRIM (l.element)) =
                          UPPER (TRIM (sx.element(+)))
                   AND UPPER (TRIM (l.element)) =
                          UPPER (TRIM (tx.element(+)))
                   AND UPPER (TRIM (l.element)) =
                          UPPER (TRIM (yx.element(+)))
                   AND UPPER (TRIM (l.element)) =
                          UPPER (TRIM (px.element(+)))
                   AND l.section_id = rb.section_id(+)
                   AND l.section_id = re.section_id(+)
                   AND l.element_id = mv.element_id(+)
                   AND l.element_id = cx.element_id(+))) t;
