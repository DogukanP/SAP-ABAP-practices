*&---------------------------------------------------------------------*
*& Include          ZDOP_OO_ALV_TOP
*&---------------------------------------------------------------------*
TABLES : scarr.
TYPE-POOLS icon.
*DATA :BEGIN OF gt_scarr OCCURS 0,
*        carrid   TYPE SCARR-carrid   ,
*        carrname TYPE SCARR-carrname ,
*        currcode TYPE SCARR-currcode ,
*        url      TYPE SCARR-url      ,
*      END OF gt_scarr.

TYPES : BEGIN OF gty_scarr,
          durum     TYPE icon_d,
          carrid    TYPE s_carr_id,
          carrname  TYPE s_carrname,
          currcode  TYPE s_curRcode,
          url       TYPE s_carrurl,
          cost      TYPE int4,
          location  TYPE char20,
          seatt     TYPE char20,
          seatp     TYPE char10,
          dd_handle TYPE int4,
          cellstyle TYPE lvc_t_styl,
          delete    TYPE char20,
        END OF gty_scarr.

DATA : gs_cell_color TYPE lvc_s_scol,
       gs_cellstyle  TYPE lvc_s_styl.

DATA : go_alv  TYPE REF TO cl_gui_alv_grid,
       go_cont TYPE REF TO cl_gui_custom_container.

DATA : gt_scarr TYPE TABLE OF gty_scarr,
       gs_scarr TYPE gty_scarr.

DATA : gt_fcat TYPE lvc_t_fcat,
       gs_fcat TYPE lvc_s_fcat.

DATA : gt_excluding TYPE ui_functions,
       gv_excluding TYPE ui_func.

DATA : gt_sort TYPE lvc_t_sort,
       gs_sort TYPE lvc_s_sort.

DATA : gt_filter TYPE lvc_t_filt,
       gs_filter TYPE lvc_s_filt.

DATA : gs_layout TYPE lvc_s_layo.

FIELD-SYMBOLS : <gfs_fcat>  TYPE lvc_s_fcat,
                <gfs_scarr> TYPE gty_scarr.

*top of page için tanımlamalar

DATA : go_spli TYPE REF TO cl_gui_splitter_container,
       go_sub1 TYPE REF TO cl_gui_container,
       go_sub2 TYPE REF TO cl_gui_container.

DATA : go_docu TYPE REF TO cl_dd_document.


CLASS cl_event_receiver DEFINITION DEFERRED.
DATA : go_event_receiver TYPE REF TO cl_event_receiver.
