*&---------------------------------------------------------------------*
*& Report ZDOP_DB_INDEX_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdop_db_index_test.

* BU PROGRAMDA VERİ TABANI TABLOSUNDA İNDEX YARATMADAN VE YARATILDIKTAN SONRAKİ PERFORMANSLAR KARŞILAŞTIRILMIŞTIR.
* INDEX YARATILDIKTAN SONRA PERFORMANSTA GÖZLE GÖZÜRÜLÜR BİR ARTIŞ YAŞANMIŞTIR.

DATA : gt_mseg LIKE TABLE OF mseg WITH HEADER LINE,
       t1 TYPE i,
       t2 TYPE i,
       t3 TYPE p DECIMALS 3,
       line_count TYPE i.

GET RUN TIME FIELD t1.

SELECT mblnr mjahr zeile FROM mseg INTO CORRESPONDING FIELDS OF TABLE gt_mseg
  WHERE matbf BETWEEN '0' AND '17'.


GET RUN TIME FIELD t2.

t3 = ( t2 - t1 ) / 1000000 .

DESCRIBE TABLE Gt_MSEG LINES line_count.

WRITE :/ 'OKUNAN KAYIT SAYISI' , 30 ':' , line_count LEFT-JUSTIFIED.
WRITE :/ 'HIZ (SANİYE)' , 30  ':' , t3 LEFT-JUSTIFIED.
