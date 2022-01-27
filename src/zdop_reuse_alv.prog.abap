*&---------------------------------------------------------------------*
*& Report ZDOP_REUSE_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdop_reuse_alv.

TYPE-POOLS : slis.

DATA : BEGIN OF gt_data OCCURS 0,
        vbeln LIKE vbak-vbeln,
        posnr LIKE vbap-posnr,
        matnr LIKE vbap-matnr,
        line_color(4),
       END OF gt_data.

DATA : gt_fcat TYPE slis_t_fieldcat_alv WITH HEADER LINE.
DATA : gs_layout TYPE slis_layout_alv.

SELECT vbak~vbeln
       vbap~posnr
       vbap~matnr
       INTO TABLE gt_data
       FROM vbak
       INNER JOIN vbap ON vbap~vbeln EQ vbak~vbeln.

LOOP AT gt_data.
  gt_data-line_color = 'C701'.
  MODIFY gt_data.
ENDLOOP.

gs_layout-info_fieldname = 'LINE_COLOR'.

*FIELDCATALOG İÇİN MAKRO
DEFINE fill_field_catalog.
CLEAR gt_fcat.
gt_fcat-fieldname = &1.
gt_fcat-ref_tabname = &2.
gt_fcat-ref_fieldname = &3.
gt_fcat-ddictxt = &4. "DEFAULT KOLON GENİŞLİĞİ
gt_fcat-seltext_s = "KISA KOLON ADI
gt_fcat-seltext_m = "ORTA KOLON ADI
gt_fcat-seltext_l = "UZUN KOLON ADI
gt_fcat-reptext_ddic = &5. "VARYANT KISMINDA GÖRÜLEN METİN
APPEND gt_fcat.
END-OF-DEFINITION.


*FCAT DOLDURMA
fill_field_catalog 'VBELN' 'VBAK' 'VBELN' 'L' 'SİPARİŞ NO'.
fill_field_catalog 'POSNR' 'VBAP' 'POSNR' 'L' 'KALEM NO'.
fill_field_catalog 'MATNR' 'VBAP' 'MATNR' 'L' 'MALZEME NO'.


*BU YÖNTEM ÖNCEKİ YÖNTEME GÖRE DAHA ÇOK TERCİH EDİLİR.
*KULLANILAN FONKSİYON INTERNAL TABLONUN VEYA STRUCTURE IN TÜM ALANLARINI OKUYUP FCAT'A DOLDURUR.

*CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
* EXPORTING
*   i_program_name               = sy-repid
*   i_internal_tabname           = 'GT_DATA'
*   i_inclname                   = sy-repid
* CHANGING
*   ct_fieldcat                  = gt_fcat[]
* EXCEPTIONS
*   inconsistent_interface       = 1
*   program_error                = 2
*   OTHERS                       = 3
*          .
*IF sy-subrc <> 0.
* Implement suitable error handling here
*ENDIF.

LOOP AT gt_fcat.
  CASE gt_fcat-fieldname.
    WHEN 'LINE_COLOR'.
      gt_fcat-tech = 'X'. "SÜTUN GİZLENSİN.
    WHEN 'VBELN'.
      gt_fcat-emphasize = 'C410'.
      gt_fcat-key = ''. "ANAHTAR ALAN İSE RENK EZİLEBİLİR.
    WHEN 'POSNR'.
      gt_fcat-emphasize = 'C510'.
      gt_fcat-key = ''.
    WHEN 'MATNR'.
      gt_fcat-emphasize = 'C710'.
      gt_fcat-key = ''.
    ENDCASE.
    MODIFY GT_FCAT.
ENDLOOP.


CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
   it_fieldcat                       = gt_fcat[]
*   is_layout                         = gs_layout
 TABLES
    t_outtab                         = gt_data
 EXCEPTIONS
   program_error                     = 1
   OTHERS                            = 2
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.
