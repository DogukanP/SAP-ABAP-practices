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

    CREATE OBJECT go_spli
      EXPORTING
        parent  = go_cont                   " Parent Container
        rows    = 2                   " Number of Rows to be displayed
        columns = 1.                  " Number of Columns to be Displayed

    CALL METHOD go_spli->get_container
      EXPORTING
        row       = 1              " Row
        column    = 1              " Column
      RECEIVING
        container = go_sub1.            " Container

    CALL METHOD go_spli->get_container
      EXPORTING
        row       = 2              " Row
        column    = 1             " Column
      RECEIVING
        container = go_sub2.            " Container


    CALL METHOD go_spli->set_row_height
      EXPORTING
        id     = 1             " Row ID
        height = 15.            " Height

    CREATE OBJECT go_docu
      EXPORTING
        style = 'ALV_GIRD'.             " Adjusting to the Style of a Particular GUI Environment


    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_sub2.


    CREATE OBJECT go_event_receiver.

    SET HANDLER go_event_receiver->handle_top_of_page FOR go_alv.
    SET HANDLER go_event_receiver->handle_hotspot_click FOR go_alv.
    SET HANDLER go_event_receiver->handle_double_click FOR go_alv.
    SET HANDLER go_event_receiver->handle_data_changed FOR go_alv.
    SET HANDLER go_event_receiver->handle_onf4_changed FOR go_alv.


    PERFORM set_dropdown.

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

    CALL METHOD go_alv->list_processing_events
      EXPORTING
        i_event_name = 'TOP_OF_PAGE'                " Event Name List Processing
        i_dyndoc_id  = go_docu.

    CALL METHOD go_alv->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


  PERFORM register_f4.
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
  DATA : lv_numc   TYPE n LENGTH 8,
         lv_numc_c TYPE char8.
*         lv_tabix type i.

  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.

  LOOP AT gt_scarr ASSIGNING <gfs_scarr>.

*    lv_tabix = lv_tabix + 1.

    lv_numc = lv_numc + 1.
    lv_numc_c = lv_numc.


    CASE <gfs_scarr>-currcode.
      WHEN 'USD'.
        <gfs_scarr>-dd_handle = 3.
      WHEN 'JPY'.
        <gfs_scarr>-dd_handle = 4.
      WHEN OTHERS.
        <gfs_scarr>-dd_handle = 5.
    ENDCASE.

*    IF <gfs_scarr>-currcode NE 'USD'.
*      CLEAR : gs_cellstyle.
*      gs_cellstyle-fieldname = 'URL'.
*      gs_cellstyle-style = cl_gui_alv_grid=>mc_style_disabled.
*      APPEND gs_cellstyle TO <gfs_scarr>-cellstyle.
*    ENDIF.

*    CASE lv_tabix.
*      WHEN 1.
*        gs_cellstyle-fieldname = 'URL'.
*        gs_cellstyle-style = '00000000'.
*        APPEND gs_cellstyle TO <gfs_scarr>-cellstyle.
*      WHEN 2.
*        gs_cellstyle-fieldname = 'URL'.
*        gs_cellstyle-style = '00000001'.
*        APPEND gs_cellstyle TO <gfs_scarr>-cellstyle.
*      WHEN 3.
*        gs_cellstyle-fieldname = 'URL'.
*        gs_cellstyle-style = '00000002'.
*        APPEND gs_cellstyle TO <gfs_scarr>-cellstyle.
*    ENDCASE.

    gs_cellstyle-fieldname = 'URL'.
    gs_cellstyle-style = lv_numc_c.
    APPEND gs_cellstyle TO <gfs_scarr>-cellstyle.
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
  gs_fcat-edit = 'X'.
  gs_fcat-f4availabl = 'X'.
  "GS_FCAT-style = cl_gui_alv_grid=>mc_style_f4 . AYNI İŞE YARIYOR
  APPEND gs_fcat TO gt_fcat.

  CLEAR : gs_fcat.
  gs_fcat-fieldname = 'CURRCODE'.
  gs_fcat-scrtext_m = 'HAVAYOLU PB'.
  APPEND gs_fcat TO gt_fcat.

  CLEAR : gs_fcat.
  gs_fcat-fieldname = 'URL'.
  gs_fcat-scrtext_m = 'HAVAYOLU URL'.
  gs_fcat-col_opt = abap_true.
  gs_fcat-edit = 'X'.
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

  CLEAR : gs_fcat.
  gs_fcat-fieldname = 'LOCATION'.
  gs_fcat-scrtext_m = 'LOCATION'.
  gs_fcat-edit = abap_true.
  gs_fcat-drdn_hndl = 1.
  APPEND gs_fcat TO gt_fcat.

  CLEAR : gs_fcat.
  gs_fcat-fieldname = 'SEATT'.
  gs_fcat-scrtext_m = 'BÖLÜM'.
  gs_fcat-edit = abap_true.
  gs_fcat-drdn_hndl = 2.
  APPEND gs_fcat TO gt_fcat.

  CLEAR : gs_fcat.
  gs_fcat-fieldname = 'SEATP'.
  gs_fcat-scrtext_m = 'KOLTUK POZİSYONU'.
  gs_fcat-edit = abap_true.
  gs_fcat-drdn_field = 'DD_HANDLE'.
  APPEND gs_fcat TO gt_fcat.

  LOOP AT gt_fcat ASSIGNING <gfs_fcat>.
    IF <gfs_fcat>-fieldname EQ 'CARRID'.
      <gfs_fcat>-hotspot = abap_true.
    ENDIF.
  ENDLOOP.
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
  gs_layout-stylefname = 'CELLSTYLE'.
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
*&---------------------------------------------------------------------*
*& Form SET_DROPDOWN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_dropdown .
  DATA : lt_dropdown TYPE lvc_t_drop,
         ls_dropdown TYPE lvc_s_drop.

  CLEAR : ls_dropdown.
  ls_dropdown-handle = 1.
  ls_dropdown-value = 'YURTİÇİ'.
  APPEND ls_dropdown TO lt_dropdown.

  CLEAR : ls_dropdown.
  ls_dropdown-handle = 1.
  ls_dropdown-value = 'YURTDIŞI'.
  APPEND ls_dropdown TO lt_dropdown.

  CLEAR : ls_dropdown.
  ls_dropdown-handle = 2.
  ls_dropdown-value = 'ECONOMY'.
  APPEND ls_dropdown TO lt_dropdown.

  CLEAR : ls_dropdown.
  ls_dropdown-handle = 2.
  ls_dropdown-value = 'BUSINESS'.
  APPEND ls_dropdown TO lt_dropdown.

  CLEAR : ls_dropdown.
  ls_dropdown-handle = 2.
  ls_dropdown-value = 'FIRST CLASS'.
  APPEND ls_dropdown TO lt_dropdown.

  CLEAR : ls_dropdown.
  ls_dropdown-handle = 3.
  ls_dropdown-value = 'ÖN'.
  APPEND ls_dropdown TO lt_dropdown.

  CLEAR : ls_dropdown.
  ls_dropdown-handle = 3.
  ls_dropdown-value = 'KANAT'.
  APPEND ls_dropdown TO lt_dropdown.

  CLEAR : ls_dropdown.
  ls_dropdown-handle = 3.
  ls_dropdown-value = 'ARKA'.
  APPEND ls_dropdown TO lt_dropdown.

  CLEAR : ls_dropdown.
  ls_dropdown-handle = 4.
  ls_dropdown-value = 'ÖN'.
  APPEND ls_dropdown TO lt_dropdown.

  CLEAR : ls_dropdown.
  ls_dropdown-handle = 4.
  ls_dropdown-value = 'ARKA'.
  APPEND ls_dropdown TO lt_dropdown.

  CLEAR : ls_dropdown.
  ls_dropdown-handle = 5.
  ls_dropdown-value = 'KANAT'.
  APPEND ls_dropdown TO lt_dropdown.

  go_alv->set_drop_down_table(
    EXPORTING
      it_drop_down       =  lt_dropdown                " Dropdown Table
*      it_drop_down_alias =                  " ALV Control: Dropdown List Boxes
  ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form register_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM register_f4 .
  DATA : lt_f4 TYPE lvc_t_f4,
         ls_f4 TYPE lvc_s_f4.

  CLEAR : LS_F4.
  LS_F4-fieldname = 'CARRNAME'.
  LS_F4-register = 'X'.
  APPEND LS_F4 TO LT_F4.

  CALL METHOD go_alv->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4.                  " F4 Fields
ENDFORM.
