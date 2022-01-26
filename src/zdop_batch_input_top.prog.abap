*&---------------------------------------------------------------------*
*& Include          ZDOP_BATCH_INPUT_TOP
*&---------------------------------------------------------------------*
PARAMETERS : p_file TYPE rlgrap-filename OBLIGATORY.

DATA : BEGIN OF gs_out,
         belge_tarihi    LIKE bkpf-bldat,
         belge_turu      LIKE bkpf-blart,
         sirket_kodu     LIKE bkpf-bukrs,
         para_birimi     LIKE bkpf-waers,
         kayit_anahtari  LIKE rf05a-newbs,
         hesap           LIKE rf05a-newko,
         tutar           TYPE string,"bseg-wrbtr,  "string,
         kayit_anahtari2 LIKE rf05a-newbs,
         hesap2          LIKE rf05a-newko,
         belge_no        LIKE ekko-ebeln,
         line_color      TYPE char4, "lvc_t_scol,
       END OF gs_out.

DATA : gt_out   LIKE TABLE OF gs_out,
*       gs_doc like gs_out,
*       gt_doc like TABLE OF gs_out,
       gs_cont  LIKE TABLE OF gs_out,
       gs_bukrs LIKE bkpf-bukrs.

DATA : gt_excel LIKE TABLE OF alsmex_tabline,
       gs_excel LIKE alsmex_tabline.

DATA : ok_code TYPE sy-ucomm.

DATA: go_container        TYPE scrfname VALUE 'GO_CONTAINER',
      go_grid             TYPE REF TO cl_gui_alv_grid,
      go_custom_container TYPE REF TO cl_gui_custom_container,
      gs_layout           TYPE lvc_s_layo,   "layout
      gt_fcat             TYPE lvc_t_fcat,   "fieldcatalog
      gs_fcat             TYPE lvc_s_fcat,   "fieldcatalog
      gt_exclude          TYPE ui_functions, "alv toolbardaki butonlar için
      gs_exclude          TYPE ui_func,      "alv toolbardaki butonlar için
      gs_variant          TYPE disvariant.   "alv datasının varyantlı gelmesi için

*       Batchinputdata of single transaction
DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
*       error session opened (' ' or 'X')
DATA:   e_group_opened.
*       message texts
TABLES: t100.

DATA: gt_return TYPE bapiret2_t,
      ls_nast   TYPE nast.
