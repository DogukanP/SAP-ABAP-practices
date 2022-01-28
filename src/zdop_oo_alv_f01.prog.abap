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

  IF go_alv IS INITIAL.
    CREATE OBJECT go_cont
      EXPORTING
        container_name = 'CC_ALV'.

    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_cont.

    CALL METHOD go_alv->set_table_for_first_display
      EXPORTING
*       i_structure_name              = 'SCARR'            " Internal Output Table Structure Name
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

    CALL METHOD go_alv->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL METHOD go_alv->refresh_table_display.
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
  CLEAR : gs_fcat.
  gs_fcat-fieldname = 'CARRID'.
  gs_fcat-scrtext_m = 'HAVAYOLU ŞİRKETİ'.
  gs_fcat-key = abap_true.
  APPEND gs_fcat TO gt_fcat.

  CLEAR : gs_fcat.
  gs_fcat-fieldname = 'CARRNAME'.
  gs_fcat-scrtext_m = 'HAVAYOLU ADI'.
  gs_fcat-ref_table = 'SCARR'.
  gs_fcat-ref_table = 'CARRNAME'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR : gs_fcat.
  gs_fcat-fieldname = 'CURRCODE'.
  gs_fcat-scrtext_m = 'HAVAYOLU PB'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR : gs_fcat.
  gs_fcat-fieldname = 'URL'.
  gs_fcat-scrtext_m = 'HAVAYOLU URL'.
  gs_fcat-col_opt = abap_true.
  APPEND gs_fcat TO gt_fcat.

  CLEAR : gs_fcat.
  gs_fcat-fieldname = 'COST'.
  gs_fcat-scrtext_m = 'FIYAT'.
  gs_fcat-col_opt = abap_true.
  gs_fcat-edit = 'X'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR : gs_fcat.
  gs_fcat-fieldname = 'DURUM'.
  gs_fcat-scrtext_m = 'DURUM'.
  APPEND gs_fcat TO gt_fcat.
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
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TOTAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_total .
  DATA : lv_total TYPE int4,
         lv_lines TYPE int4,
         lv_avr   TYPE int4.

  LOOP AT gt_scarr INTO gs_scarr.
    lv_total = lv_total + gs_scarr-cost.
  ENDLOOP.

  DESCRIBE TABLE gt_scarr LINES lv_lines.

  lv_avr = lv_total / lv_lines.

  LOOP AT gt_scarr ASSIGNING <gfs_scarr>.
    IF <gfs_scarr>-cost GT lv_avr .
      <gfs_scarr>-durum = '@0A@'.
    ELSEIF <gfs_scarr>-cost LT lv_avr.
      <gfs_scarr>-durum = '@08@'.
    ELSE.
      <gfs_scarr>-durum = '@09@'.
    ENDIF.
  ENDLOOP.


ENDFORM.
