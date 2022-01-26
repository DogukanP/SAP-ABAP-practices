*&---------------------------------------------------------------------*
*& Report ZDOP_BAPI_CREATE_MAT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdop_bapi_create_mat.

*ÖNCELİKLİ OLARAK BAPI_GOODMVT_CREATE BAPISINDE ZORUNLU OLAN ALANLARI TANIMLIYORUZ.

DATA : bapi_header LIKE bapi2017_gm_head_01,
       bapi_code   LIKE bapi2017_gm_code,
       bapi_items  LIKE TABLE OF bapi2017_gm_item_create WITH HEADER LINE,
       bapi_return LIKE TABLE OF bapiret2 WITH HEADER LINE,
       bapi_document TYPE bapi2017_gm_head_ret-mat_doc,
       bapi_documentyear TYPE bapi2017_gm_head_ret-doc_year.

*BAŞLIK BİLGİLERİNİ DDOLDURUUYORUZ.

bapi_header-pstng_date = sy-datum.
bapi_header-doc_date = sy-datum.
bapi_header-header_txt = 'BAPI M11 TEST'.

*İŞLEM TÜRÜNÜ BULMAK İÇİN BAPIDEKİ ALANA TIKLIYORUZ. INPUT/HELP CHECK ALANINDA TABLOYU BULUYORUZ.
*TABLOYA GİDEREK İŞLEM TÜRÜNÜ BULUYORUZ.

bapi_code = '06'.

*KALEM BİLGİLERİNİ DOLDURUYORUZ.

CLEAR bapi_items.
bapi_items-material = 'BS12TEST'. "MALZEME
bapi_items-plant = 'K10'. "ÜRETİM YERİ
bapi_items-stge_loc = '1009'. "DEPO YERİ
bapi_items-move_type = '561'. "HAREKET TÜRÜ
bapi_items-entry_qnt = 100. "MİKTAR
bapi_items-entry_uom = 'KG'. "BİRİM
APPEND bapi_items.

*BAPI'NIN ÇAĞRILMASI

CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
  EXPORTING
    goodsmvt_header               = bapi_header
    goodsmvt_code                 = bapi_code
*   TESTRUN                       = ' '
*   GOODSMVT_REF_EWM              =
*   GOODSMVT_PRINT_CTRL           =
  IMPORTING
*   GOODSMVT_HEADRET              =
    materialdocument              = bapi_document
    matdocumentyear               = bapi_documentyear
  TABLES
    goodsmvt_item                 = bapi_items
*   GOODSMVT_SERIALNUMBER         =
    return                        = bapi_return
*   GOODSMVT_SERV_PART_DATA       =
*   EXTENSIONIN                   =
*   GOODSMVT_ITEM_CWM             =
          .

IF bapi_document IS NOT INITIAL.
*BELGE YARATILDI
* COMMIT WORK İLE KSEİN HALE GETİRİYORUZ.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
   EXPORTING
     wait          = 'X'.


  MESSAGE i000(l1) WITH bapi_document 'BELGESİ' bapi_documentyear 'YILINDA YARATILDI.'.
ELSE.
*BELGE HATALI
*BAPI NESENEYİ LOCK DURUMA GETİRMİŞ OLABİLİR BUNUN İÇİN AŞAĞIDAKİ FONKSİYONLA LOCKLAR KALDIRILIR.

  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*BAPIDEN DÖNEN MESAJLARI EKRANA BASTIRMAK.
  CALL FUNCTION 'OXT_MESSAGE_TO_POPUP'
    EXPORTING
      it_message        = bapi_return[]
*   IMPORTING
*     EV_CONTINUE       =
    EXCEPTIONS
      bal_error         = 1
      OTHERS            = 2
            .
ENDIF.
