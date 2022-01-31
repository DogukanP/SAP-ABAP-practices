*&---------------------------------------------------------------------*
*& Include          ZDOP_OO_ALV_C01
*&---------------------------------------------------------------------*
CLASS cl_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS handle_top_of_page
      FOR EVENT top_of_page OF cl_gui_alv_grid
      IMPORTING
        e_dyndoc_id
        table_index.
    METHODS handle_hotspot_click
      FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING
        e_row_id
        e_column_id.
    METHODS handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING
        e_row
        e_column
        es_row_no.
    METHODS handle_data_changed
      FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING
        er_data_changed
        e_onf4
        e_onf4_before
        e_onf4_after
        e_ucomm.
    METHODS handle_onf4_changed
      FOR EVENT onf4 OF cl_gui_alv_grid
      IMPORTING
        e_fieldname
        e_fieldvalue
        es_row_no
        er_event_data
        et_bad_cells
        e_display.
    METHODS handle_button_click
      FOR EVENT button_click OF cl_gui_alv_grid
      IMPORTING
        es_col_id
        es_row_no.
ENDCLASS.

CLASS cl_event_receiver IMPLEMENTATION.
  METHOD handle_top_of_page.
    DATA : lv_text TYPE sdydo_text_element.
    lv_text = 'FLIGHT DETAILS'.

    CALL METHOD go_docu->add_text
      EXPORTING
        text      = lv_text             " Single Text, Up To 255 Characters Long
        sap_style = cl_dd_document=>heading.           " Recommended Styles

    CALL METHOD go_docu->new_line.

    CLEAR lv_text.

    CONCATENATE 'USER : ' sy-uname INTO lv_text SEPARATED BY space.

    CALL METHOD go_docu->add_text
      EXPORTING
        text         = lv_text              " Single Text, Up To 255 Characters Long
        sap_color    = cl_dd_document=>list_positive
        sap_fontsize = cl_dd_document=>medium.

    CALL METHOD go_docu->display_document
      EXPORTING
        parent = go_sub1.               " Contain Object Already Exists


  ENDMETHOD.
  METHOD handle_hotspot_click.
    DATA : lv_mess TYPE char200.
    READ TABLE gt_scarr INTO gs_scarr INDEX e_row_id-index.
    IF sy-subrc EQ 0.
      CASE e_column_id.
        WHEN 'CARRID'.
          CONCATENATE 'TIKLANAN KOLON' e_column_id 'DEĞERİ' gs_scarr-carrid INTO lv_mess SEPARATED BY space.
          MESSAGE lv_mess TYPE 'I'.
      ENDCASE.
    ENDIF.
  ENDMETHOD.
  METHOD handle_double_click.
    DATA : lv_mess TYPE char200.
    READ TABLE gt_scarr INTO gs_scarr INDEX e_row-index.
    IF sy-subrc EQ 0.
      CONCATENATE 'DOUBLE CLICK ÇALIŞTI -> TIKLANAN KOLON :'
      e_column-fieldname
       INTO lv_mess
       SEPARATED BY space.
      MESSAGE lv_mess TYPE 'I'.
    ENDIF.
  ENDMETHOD.
  METHOD handle_data_changed.
    DATA : ls_modi TYPE lvc_s_modi,
           lv_mess TYPE char200.

    LOOP AT er_data_changed->mt_good_cells INTO ls_modi.
      READ TABLE gt_scarr INTO gs_scarr INDEX ls_modi-row_id.
      IF sy-subrc EQ 0.
        CONCATENATE ls_modi-fieldname '-> ESKİ DEĞER' gs_scarr-url ',YENİ DEĞER' ls_modi-value INTO lv_mess SEPARATED BY space.
        MESSAGE lv_mess TYPE 'I'.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
  METHOD handle_onf4_changed.
    TYPES : BEGIN OF lty_value_tab,
              carrname TYPE s_carrname,
            END OF lty_value_tab.

    DATA : lt_return_tab TYPE TABLE OF ddshretval,
           ls_return_tab TYPE ddshretval,
           lt_value_tab  TYPE TABLE OF lty_value_tab,
           ls_value_tab  TYPE  lty_value_tab.

    CLEAR : ls_value_tab.
    ls_value_tab-carrname = 'UÇUŞ 1'.
    APPEND ls_value_tab TO lt_value_tab.

    CLEAR : ls_value_tab.
    ls_value_tab-carrname = 'UÇUŞ 2'.
    APPEND ls_value_tab TO lt_value_tab.

    CLEAR : ls_value_tab.
    ls_value_tab-carrname = 'UÇUŞ 3'.
    APPEND ls_value_tab TO lt_value_tab.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'CARRNAME'
        window_title    = 'CARRNAME F4'
        value_org       = 'S'
      TABLES
        value_tab       = lt_value_tab
        return_tab      = lt_return_tab
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE lt_return_tab INTO ls_return_tab WITH KEY fieldname = 'F0001'.
    IF sy-subrc EQ 0.
      READ TABLE gt_scarr ASSIGNING <gfs_scarr> INDEX es_row_no-row_id.
      IF sy-subrc EQ 0.
        <gfs_scarr>-carrname = ls_return_tab-fieldval.
        go_alv->refresh_table_display( ).
      ENDIF.
    ENDIF.
    er_event_data->m_event_handled = 'X'.
  ENDMETHOD.
  METHOD handle_button_click.
    DATA : lv_mess TYPE char200.
    READ TABLE gt_scarr INTO gs_scarr INDEX es_row_no-row_id.
    IF sy-subrc EQ 0.
      CASE es_col_id-fieldname.
        WHEN 'DELETE'.
          CONCATENATE es_col_id-fieldname ',' gs_scarr-carrid gs_scarr-carrname INTO lv_mess SEPARATED BY space.
          MESSAGE lv_mess TYPE 'I'.
      ENDCASE.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
