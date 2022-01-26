*&---------------------------------------------------------------------*
*& Include          ZDOP_BATCH_EXCEL_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form OPEN_FILE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM open_file .
  DATA : lt_filename TYPE filetable,
         ls_filename TYPE file_table,
         lv_rc       TYPE i.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      default_extension       = 'XLS'
    CHANGING
      file_table              = lt_filename     " Table Holding Selected Files
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1                " "Open File" dialog failed
      cntl_error              = 2                " Control error
      error_no_gui            = 3                " No GUI available
      not_supported_by_gui    = 4                " GUI does not support this
      OTHERS                  = 5.
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  READ TABLE lt_filename INTO ls_filename INDEX 1.
  IF sy-subrc = 0.
    p_file = ls_filename-filename.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SHOW_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_data.
  CALL SCREEN 0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SHOW_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_alv .

  IF go_custom_container IS INITIAL.
    CREATE OBJECT go_custom_container
      EXPORTING
        container_name = go_container.

    CREATE OBJECT go_grid
      EXPORTING
        i_parent = go_custom_container.

    PERFORM build_layout.

    PERFORM build_fcat .

    PERFORM exclude_button CHANGING gt_exclude .

    PERFORM event_handler.

    CALL METHOD go_grid->set_table_for_first_display ""alv basılır.
      EXPORTING
        is_layout            = gs_layout
        it_toolbar_excluding = gt_exclude
        is_variant           = gs_variant
        i_save               = 'A'
      CHANGING
        it_outtab            = gt_out
        it_fieldcatalog      = gt_fcat[].

    PERFORM register_event.
  ELSE .
    PERFORM check_changed_data    USING go_grid .
    PERFORM refresh_table_display USING go_grid .
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

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_file
      i_begin_col             = '1'
      i_begin_row             = '2'
      i_end_col               = '9'
      i_end_row               = '256'
    TABLES
      intern                  = gt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  IF sy-subrc = 0.

    LOOP AT gt_excel INTO gs_excel.

      CASE gs_excel-col.

        WHEN '0001'.
          CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
            EXPORTING
              date_external            = gs_excel-value
            IMPORTING
              date_internal            = gs_out-belge_tarihi
            EXCEPTIONS
              date_external_is_invalid = 1
              OTHERS                   = 2.
        WHEN '0002'.
          MOVE gs_excel-value TO gs_out-belge_turu.
        WHEN '0003'.
          MOVE gs_excel-value TO gs_out-sirket_kodu.
        WHEN '0004'.
          MOVE gs_excel-value TO gs_out-para_birimi.
        WHEN '0005'.
          MOVE gs_excel-value TO gs_out-kayit_anahtari.
        WHEN '0006'.
          MOVE gs_excel-value TO gs_out-hesap.

        WHEN '0007'.
          CALL FUNCTION 'HRCM_STRING_TO_AMOUNT_CONVERT'
            EXPORTING
              string            = gs_excel-value
              decimal_separator = '.' "virgülden sonra kuruş.
            IMPORTING
              betrg             = gs_out-tutar
            EXCEPTIONS
              convert_error     = 1
              OTHERS            = 2.

        WHEN '0008'.
          MOVE gs_excel-value TO gs_out-kayit_anahtari2.

        WHEN '0009'.

          MOVE gs_excel-value TO gs_out-hesap2.

      ENDCASE.
      AT END OF row.
        SELECT SINGLE bukrs FROM bkpf INTO gs_bukrs WHERE bukrs EQ gs_out-sirket_kodu.
        IF sy-subrc NE 0.
          gs_out-line_color = 'C610'.
        ENDIF.
        APPEND gs_out TO gt_out.
        CLEAR gs_out.
      ENDAT.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_layout .
  CLEAR gs_layout.
  gs_layout-zebra      = 'X'."ilk satır koyu ikinci satır açık
  gs_layout-cwidth_opt = 'X'."kolonların uzunluklarını optimize et
  gs_layout-info_fname = 'LINE_COLOR'.
  gs_layout-sel_mode   = 'A'."hücrelerin seçilebilme kriteri
  gs_layout-stylefname = 'FIELD_STYLE'.
  gs_layout-info_fname = 'LINE_COLOR'.
  gs_variant-report     = sy-repid .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_fcat .
  DATA: lt_kkblo_fieldcat TYPE kkblo_t_fieldcat,
        lv_repid          TYPE sy-repid.
  FIELD-SYMBOLS: <fs_fcat> LIKE gs_fcat.

  lv_repid = sy-repid.

  CALL FUNCTION 'K_KKB_FIELDCAT_MERGE'
    EXPORTING
      i_callback_program     = lv_repid
      i_tabname              = 'GS_OUT'
      i_inclname             = lv_repid
    CHANGING
      ct_fieldcat            = lt_kkblo_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      OTHERS                 = 2.
  IF lt_kkblo_fieldcat IS INITIAL.
    MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CLEAR gt_fcat[].
  CALL FUNCTION 'LVC_TRANSFER_FROM_KKBLO'
    EXPORTING
      it_fieldcat_kkblo = lt_kkblo_fieldcat
    IMPORTING
      et_fieldcat_lvc   = gt_fcat[]
    EXCEPTIONS
      it_data_missing   = 1
      OTHERS            = 2.
  IF gt_fcat IS INITIAL.
    MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT gt_fcat INTO gs_fcat.
    gs_fcat-key = ' '.
    CASE gs_fcat-fieldname.
      WHEN 'KAYIT_ANAHTARI2'.
        gs_fcat-scrtext_s  = 'KAYIT ANAHTARI 2'.
        gs_fcat-scrtext_m  = 'KAYIT ANAHTARI 2'.
        gs_fcat-scrtext_l  = 'KAYIT ANAHTARI 2'.
        gs_fcat-coltext    = 'KAYIT ANAHTARI 2'.
      WHEN 'HESAP2'.
        gs_fcat-scrtext_s  = 'HESAP 2'.
        gs_fcat-scrtext_m  = 'HESAP 2'.
        gs_fcat-scrtext_l  = 'HESAP 2'.
        gs_fcat-coltext    = 'HESAP 2'.
      WHEN 'BELGE_NO'.
        gs_fcat-scrtext_s  = 'BELGE NO'.
        gs_fcat-scrtext_m  = 'BELGE NO'.
        gs_fcat-scrtext_l  = 'BELGE NO'.
        gs_fcat-coltext    = 'BELGE NO'.
    ENDCASE.
    MODIFY gt_fcat FROM gs_fcat.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_button
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_EXCLUDE
*&---------------------------------------------------------------------*
FORM exclude_button  CHANGING p_gt_exclude.
  DATA: ls_exclude LIKE LINE OF gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_print.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_check.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_views.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_maintain_variant.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_find.
  APPEND ls_exclude TO gt_exclude.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form register_event
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM register_event .
  CALL METHOD go_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM event_handler .
  DATA: lcl_alv_event TYPE REF TO lcl_event_receiver .
  CREATE OBJECT lcl_alv_event.

  SET HANDLER lcl_alv_event->handle_toolbar      FOR go_grid.
  SET HANDLER lcl_alv_event->handle_user_command FOR go_grid.
  SET HANDLER lcl_alv_event->double_click        FOR go_grid.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_changed_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID
*&---------------------------------------------------------------------*
FORM check_changed_data  USING    p_go_grid.
  DATA: lv_valid TYPE c.

  CALL METHOD go_grid->check_changed_data
    IMPORTING
      e_valid = lv_valid.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_table_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID
*&---------------------------------------------------------------------*
FORM refresh_table_display  USING    p_go_grid.
  DATA : ls_stable TYPE lvc_s_stbl .

  ls_stable-row = 'X'.
  ls_stable-col = 'X'.
  CALL METHOD go_grid->refresh_table_display
    EXPORTING
      is_stable      = ls_stable
      i_soft_refresh = 'X'
    EXCEPTIONS
      finished       = 1
      OTHERS         = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_doc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_doc .
  DATA : lt_rows TYPE lvc_t_row,
         ls_rows TYPE lvc_s_row,
         ls_out  LIKE gs_out.

  CALL METHOD go_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_rows.
  IF lt_rows IS INITIAL.
    MESSAGE 'EN AZ BİR SATIR SEÇİNİZ' TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    LOOP AT lt_rows INTO ls_rows.
      CLEAR : gs_out.
      READ TABLE gt_out INTO gs_out INDEX ls_rows-index.
      SELECT SINGLE bukrs FROM bkpf INTO gs_bukrs WHERE bukrs EQ gs_out-sirket_kodu.
      IF sy-subrc EQ 0.
        PERFORM bdc_fb01 USING gs_out.
        LOOP AT gt_return INTO DATA(ls_return) .
          ls_out-belge_no = ls_return-message_v1.
          MODIFY gt_out FROM ls_out INDEX ls_rows-index TRANSPORTING belge_no.
        ENDLOOP.
        PERFORM refresh_table_display USING go_grid .
      ELSE.
        MESSAGE 'ŞİRKET KODU MEVCUT DEĞİL' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    ENDLOOP .
  ENDIF.

ENDFORM.

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  IF fval <> space.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    APPEND bdcdata.
  ENDIF.
ENDFORM.
*----------------------------------------------------------------------*
*        Start new transaction according to parameters                 *
*----------------------------------------------------------------------*
FORM bdc_transaction USING tcode.
  DATA: l_mstring(480).
  DATA: l_subrc LIKE sy-subrc.

  REFRESH messtab.
  CALL TRANSACTION tcode USING bdcdata
                   MODE   'N'
                   UPDATE 'A'
                   MESSAGES INTO messtab.
  l_subrc = sy-subrc.

  LOOP AT messtab.
    MESSAGE ID     messtab-msgid
            TYPE   messtab-msgtyp
            NUMBER messtab-msgnr
            INTO l_mstring
            WITH messtab-msgv1
                 messtab-msgv2
                 messtab-msgv3
                 messtab-msgv4.
    WRITE: / messtab-msgtyp, l_mstring(250).
  ENDLOOP.
  SKIP.

  CALL FUNCTION 'CONVERT_BDCMSGCOLL_TO_BAPIRET2'
    TABLES
      imt_bdcmsgcoll = messtab
      ext_return     = gt_return.

  REFRESH bdcdata.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BDC_FB01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_OUT  text
*----------------------------------------------------------------------*
FORM bdc_fb01  USING ls_out LIKE LINE OF gt_out.

  REFRESH : messtab , bdcdata.
  CLEAR bdcdata.
  DATA : ls_date(10) TYPE c.

  CALL FUNCTION 'BKK_CONVERT_FORMAT_DATE'
    EXPORTING
      p_date           = ls_out-belge_tarihi
    CHANGING
      p_formatted_date = ls_date.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0100'.
  "belge_turu
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BKPF-BLDAT'
                                ls_date.
  PERFORM bdc_field       USING 'BKPF-BLART'
                                ls_out-belge_turu.
  PERFORM bdc_field       USING 'BKPF-BUKRS'
                                ls_out-sirket_kodu.

  PERFORM bdc_field       USING 'BKPF-WAERS'
                                ls_out-para_birimi.
  PERFORM bdc_field       USING 'FS006-DOCID'
                                '*'.
  PERFORM bdc_field       USING 'RF05A-NEWBS'
                                ls_out-kayit_anahtari.
  PERFORM bdc_field       USING 'RF05A-NEWKO'
                                ls_out-hesap.
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BU'.
  PERFORM bdc_field       USING 'BSEG-WRBTR'
                                 ls_out-tutar .
*                                 '800,00'.

  PERFORM bdc_field       USING 'RF05A-NEWBS'
                                ls_out-kayit_anahtari2.
  PERFORM bdc_field       USING 'RF05A-NEWKO'
                                ls_out-hesap2.
  PERFORM bdc_field       USING 'DKACB-FMORE'
                                'X'.
  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'COBL-GSBER'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTE'.
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BSEG-WRBTR'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BU'.
  PERFORM bdc_field       USING 'BSEG-WRBTR'
                                ls_out-tutar.
*                                '800,00'.

  PERFORM bdc_field       USING 'DKACB-FMORE'
                                'X'.
  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'COBL-GSBER'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTE'.

  PERFORM bdc_transaction USING 'FB01'.


  CLEAR : ls_out.
  REFRESH bdcdata.
  REFRESH bdcdata.
  REFRESH messtab.
  CLEAR : messtab.

  cl_rmsl_message=>display( gt_return ).

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SHOW_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM show_doc .
*  READ TABLE gt_out INTO gs_out INDEX e_row-index.
*  IF sy-subrc EQ 0.
*    SET PARAMETER ID 'BLN'  FIELD gs_out-belge_numarasi.
*    CALL TRANSACTION 'FB03' .
*  ENDIF.
*ENDFORM.
