*&---------------------------------------------------------------------*
*& Include          ZDOP_OO_ALV_TOP
*&---------------------------------------------------------------------*
TABLES : scarr.

*DATA :BEGIN OF gt_scarr OCCURS 0,
*        carrid   TYPE SCARR-carrid   ,
*        carrname TYPE SCARR-carrname ,
*        currcode TYPE SCARR-currcode ,
*        url      TYPE SCARR-url      ,
*      END OF gt_scarr.

TYPES : BEGIN OF gty_scarr,
          carrid     TYPE s_carr_id,
          carrname   TYPE s_carrname,
          currcode   TYPE s_curRcode,
          url        TYPE s_carrurl,
          mess       TYPE char200,
          line_color TYPE char4,
          cell_color TYPE lvc_t_scol,
        END OF gty_scarr.

DATA : gs_cell_color TYPE lvc_s_scol.

DATA : go_alv  TYPE REF TO cl_gui_alv_grid,
       go_cont TYPE REF TO cl_gui_custom_container.

DATA : gt_scarr TYPE TABLE OF gty_scarr.

DATA : gt_fcat TYPE lvc_t_fcat,
       gs_fcat TYPE lvc_s_fcat.

DATA : gs_layout TYPE lvc_s_layo.

FIELD-SYMBOLS : <gfs_fcat>  TYPE lvc_s_fcat,
                <gfs_scarr> TYPE gty_scarr.