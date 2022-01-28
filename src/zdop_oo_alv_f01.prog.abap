*&---------------------------------------------------------------------*
*& Include          ZDOP_OO_ALV_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SHOW_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_alv .

  PERFORM set_fcat.
  PERFORM set_layout.

  CREATE OBJECT go_cont
    EXPORTING
      container_name = 'CC_ALV'.

  CREATE OBJECT go_alv
    EXPORTING
      i_parent = go_cont.

  CALL METHOD go_alv->set_table_for_first_display
    EXPORTING
*     i_structure_name              = 'SCARR'            " Internal Output Table Structure Name
      is_layout                     = gs_layout
    CHANGING
      it_outtab                     = gt_scarr
      it_fieldcatalog               = gt_fcat
    EXCEPTIONS
      invalid_parameter_combination = 1                " Wrong Parameter
      program_error                 = 2                " Program Errors
      too_many_lines                = 3                " Too many Rows in Ready for Input Grid
      OTHERS                        = 4.
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.

  LOOP AT gt_scarr ASSIGNING <gfs_scarr>.
    CASE <gfs_scarr>-currcode.
      WHEN 'USD'.
        <gfs_scarr>-line_color = 'C710'.
      WHEN 'SGD'.
        <gfs_scarr>-line_color = 'C401'.
      WHEN 'E'.
        CLEAR gs_cell_color.
        gs_cell_color-fname = 'URL'.
        gs_cell_color-color-col = '3'.
        gs_cell_color-color-int = '1'.
        gs_cell_color-color-inv = '1'.
        APPEND gs_cell_color TO <gfs_scarr>-cell_color.

        CLEAR gs_cell_color.
        gs_cell_color-fname = 'CARRID'.
        gs_cell_color-color-col = '5'.
        gs_cell_color-color-int = '1'.
        gs_cell_color-color-inv = '0'.
        APPEND gs_cell_color TO <gfs_scarr>-cell_color.
    ENDCASE.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fcat .
*  CLEAR : gs_fcat.
*  gs_fcat-fieldname = 'CARRID'.
*  gs_fcat-scrtext_m = 'HAVAYOLU ŞİRKETİ'.
*  gs_fcat-key = abap_true.
*  APPEND gs_fcat TO gt_fcat.
*
*  CLEAR : gs_fcat.
*  gs_fcat-fieldname = 'CARRNAME'.
*  gs_fcat-scrtext_m = 'HAVAYOLU ADI'.
*  gs_fcat-edit = 'X'.
*  gs_fcat-ref_table = 'SCARR'.
*  gs_fcat-ref_table = 'CARRNAME'.
*  APPEND gs_fcat TO gt_fcat.
*
*  CLEAR : gs_fcat.
*  gs_fcat-fieldname = 'CURRCODE'.
*  gs_fcat-scrtext_m = 'HAVAYOLU PB'.
*  gs_fcat-no_out = abap_true.
*  APPEND gs_fcat TO gt_fcat.
*
*  CLEAR : gs_fcat.
*  gs_fcat-fieldname = 'URL'.
*  gs_fcat-scrtext_m = 'HAVAYOLU URL'.
*  gs_fcat-col_opt = abap_true.
*  APPEND gs_fcat TO gt_fcat.

*  READ TABLE gt_fcat ASSIGNING <gfs_fcat> WITH KEY fieldname = 'MESS'.
*  IF sy-subrc EQ 0.
*    <gfs_fcat>-edit = abap_true.
*  ENDIF.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
*     I_BUFFER_ACTIVE  =
      i_structure_name = 'SCARR'
*     I_CLIENT_NEVER_DISPLAY       = 'X'
*     I_BYPASSING_BUFFER           =
*     I_INTERNAL_TABNAME           = 'GT_SCARR'
    CHANGING
      ct_fieldcat      = gt_fcat
*   EXCEPTIONS
*     INCONSISTENT_INTERFACE       = 1
*     PROGRAM_ERROR    = 2
*     OTHERS           = 3
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout .
  CLEAR : gs_layout.
  gs_layout-cwidth_opt = 'X'.
*  gs_layout-edit = 'X'.
  gs_layout-no_toolbar = 'X'.
*  gs_layout-zebra = 'X'.
  gs_layout-info_fname = 'LINE_COLOR'.
  gs_layout-ctab_fname = 'CELL_COLOR'.
ENDFORM.
