*&---------------------------------------------------------------------*
*& Report ZDOP_OO_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdop_oo_alv.

INCLUDE zdop_oo_alv_top.
INCLUDE zdop_oo_alv_c01.
INCLUDE zdop_oo_alv_f01.
INCLUDE zdop_oo_alv_i01.
INCLUDE zdop_oo_alv_o01.

INITIALIZATION.
  PERFORM variant.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM variant_searc_help.

START-OF-SELECTION.
  PERFORM get_data.
  CALL SCREEN 0100.
