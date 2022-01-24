*&---------------------------------------------------------------------*
*& Report ZDOP_FOR_ALL_ENTRIES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdop_for_all_entries.

TABLES : ekko, "SATIN ALMA SİPARİŞİ BAŞLIK
         ekpo, "SATIN ALMA SİPARİŞİ KALEM
         ekbe, "SATIN ALMA BELGESİ TARİHÇESİ
         rBkp, "GİREM FATURA BELGE BAŞLIĞI
         rseg, "GİREN FATURA BELGE KALEMİ
         mkpf, "MALZEME BELGESİ BELGE BAŞLIĞI
         mseg, "MALZEME BELGESİ BELGE KALEMİ
         mara, "MALZEME ANA VEİRLERİ
         makt, "MALZEME KISA METİNLERİ
         t134t. "MALZEME TÜRÜ TANIMLARI


*RAPOR İÇİN LİSTE TANIMLAMASI

DATA : BEGIN OF gt_data OCCURS 0,
        ebeln LIKE ekko-ebeln, "SATIN ALMA BELGESİ
        ebelp LIKE ekPo-ebelp, "SATIN ALMA BELGESİ KALEMİ
        bedat LIKE ekko-bedat, "SATIN ALMA  BELGESİ TARİHİ
        cpudt LIKE ekbe-cpudt, "MUHASEBE BELGESİ GİRİŞ TARİHİ
        menge LIKE ekpo-menge, "SATIN ALMA SİPARİŞİ MİKTAR
        meins LIKE ekpo-meins, "Satın alma siparişi ölçü birimi
        matnr LIKE ekpo-matnr, "Malzeme Numarası
        maktx LIKE makt-maktx, "Malzeme Tanımı
        mtart LIKE mara-mtart, "Malzeme Türü
        mtbez LIKE t134t-mtbez,"Malzeme Türü Tanımı
        vgabe LIKE ekbe-vgabe, "İşlem Türü
        gjahr LIKE rbkp-gjahr, "Fatura Belgesi Mali Yılı
        belnr LIKE rbkp-belnr, "Fatura Belgesi
        buzei LIKE rseg-buzei, "Fatura Belgesi Kalemi
        wrbtr LIKE rseg-wrbtr, "Fatura Tutarı
        waers LIKE rbkp-waers, "Fatura Tutar Birimi
        mjahr LIKE mkpf-mjahr, "Mal Giriş Belgesi Yılı
        mblnr LIKE mkpf-mblnr, "Mal Giriş Belgesi
        zeile LIKE mseg-zeile, "Mal Giriş Belgesi Kalemi
        mengex LIKE mseg-menge,"Mal Giriş Miktarı
       END OF gt_data.


* Faturalar için internal tablo
DATA : BEGIN OF gt_invoice OCCURS 0,
        gjahr LIKE rbkp-gjahr, "Fatura Belgesi Mali Yılı
        belnr LIKE rbkp-belnr, "Fatura Belgesi
        buzei LIKE rseg-buzei, "Fatura Belgesi Kalemi
        wrbtr LIKE rseg-wrbtr, "Fatura Tutarı
        waers LIKE rbkp-waers, "Fatura Tutar Birimi
       END OF gt_invoice.

*Mal girişleri için internal tablo

DATA : BEGIN OF gt_goodsmov OCCURS 0,
        mjahr LIKE mkpf-mjahr, "Mal Giriş Belgesi Yılı
        mblnr LIKE mkpf-mblnr, "Mal Giriş Belgesi
        zeile LIKE mseg-zeile, "Mal Giriş Belgesi Kalemi
        menge LIKE mseg-menge, "Mal Giriş Miktarı
        sjahr LIKE mseg-sjahr, "Ters kayıt belgesi yılı
        smbln LIKE mseg-smbln, "Ters kayıt belgesi
        smblp LIKE mseg-smblp, "Ters kayıt belgesi kalemi
       END OF gt_goodsmov.

*Çalışma Süresi Analizi için
DATA : gv_t1 TYPE p DECIMALS 3,
       gv_t2 TYPE p DECIMALS 3,
       gv_t3 TYPE p DECIMALS 3.

* Okunan kayıt sayısı
DATA : gv_line_count TYPE i.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_ebeln FOR ekko-ebeln,"Satın alma belgesi
                   s_bedat FOR ekko-bedat,"Satınalma belgesinin tarihi
                   s_matnr FOR ekpo-matnr,"Malzeme Numarası
                   s_mtart FOR mara-mtart,"Malzeme Türü
                   s_cpudt FOR ekbe-cpudt,"Giriş tarihi
                   s_belnr FOR rbkp-belnr,"Fatura Belgesi
                   s_mblnr FOR mkpf-mblnr."Mal Giriş Belgesi
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

* Aşağıdaki SELECT ‘e görüldüğü üzere JOIN’imizde
* olabildiğince tabloyu birleştiriyoruz.

GET RUN TIME FIELD gv_t1.

SELECT ekko~ebeln "Satın alma belgesi
       ekpo~ebelp  "Satın alma belgesi kalemi
       ekbe~cpudt  "Muhasebe belgesinin giriş tarihi
       ekko~bedat  "Satın alma belgesinin tarihi
       ekpo~menge  "Satın alma siparişi miktarı
       ekpo~meins  "Satın alma siparişi ölçü birimi
       ekpo~matnr  "Malzeme Numarası
       makt~maktx  "Malzeme Tanımı
       mara~mtart  "Malzeme Türü
       ekbe~vgabe  "işlem Türü
       ekbe~belnr  "Belge Numarası
       ekbe~gjahr  "Belge Yılı
       ekbe~buzei  "Belge Kalemi
       t134t~mtbez "Malzeme Türü Tanımı
  INTO CORRESPONDING FIELDS OF TABLE gt_data FROM ekko
  INNER JOIN ekpo ON ekpo~ebeln EQ ekko~ebeln
  INNER JOIN mara ON mara~matnr EQ ekpo~matnr
  INNER JOIN makt ON makt~matnr EQ mara~matnr
    AND makt~spras EQ sy-langu " login dilinde tanımı alıyoruz
  INNER JOIN t134t ON t134t~mtart EQ mara~mtart
    AND t134t~spras EQ sy-langu " login dilinde tanımı alıyoruz
  LEFT OUTER JOIN ekbe ON ekbe~ebeln EQ ekpo~ebeln
    AND ekbe~ebelp EQ ekpo~ebelp
  WHERE ekko~ebeln IN s_ebeln
    AND ekko~bedat IN s_bedat
    AND ekpo~matnr IN s_matnr
    AND mara~mtart IN s_mtart.

* EKBE tablosu INNER JOIN ile eklenseydi
* ‘EKBE~CPUDT IN S_CPUDT’ ifadesini WHERE koşulumuza ekleyebilirdik.
* Ancak LEFT OUTER JOIN ile eklendiğinden koşula bu tablo ile ilgili bir koşul eklenemez,
* LEFT OUTER JOIN ‘de bu tür durumlarda çoğu zaman EKBE tablosu JOIN’den çıkarılır
* Ancak bu kesinlikle yanlıştır, EKBE tablosunu JOIN’den çıkarmak performansı düşürür.
* Bu nedenle EKBE için filtrelenen alanları aşağıdaki gibi filtrelemek daha mantıklıdır

DELETE gt_data WHERE cpudt NOT IN s_cpudt.

* Şimdi Faturaları ve Mal girişlerini tek SELECT komutu ve for all entries ile alalım
* Önce KEY tablolarımızı oluşturalım...

DATA : lt_inv_key LIKE TABLE OF gt_invoice WITH HEADER LINE,
      lt_goods_key LIKE TABLE OF gt_goodsmov WITH HEADER LINE.

REFRESH : lt_inv_key,lt_goods_key.

LOOP AT gt_data.
  CLEAR lt_inv_key.
  IF gt_data-vgabe EQ '1'.
* Mal girişleri için KEY tablosu
    lt_goods_key-mjahr = gt_data-gjahr.
    lt_goods_key-mblnr = gt_data-belnr.
    lt_goods_key-zeile = gt_data-buzei.
    COLLECT lt_goods_key.
  ELSEIF gt_data-vgabe EQ '2'.
*Faturalar için key tablosu
    lt_inv_key-gjahr = gt_data-gjahr.
    lt_inv_key-belnr = gt_data-belnr.
    lt_inv_key-buzei = gt_data-buzei.
    COLLECT lt_inv_key.
  ENDIF.
ENDLOOP.

* Faturalar okunuyor...
IF lt_inv_key[] IS NOT INITIAL.
  REFRESH : gt_invoice.
  SELECT rseg~gjahr
    rseg~belnr
    rseg~buzei
    rseg~wrbtr
    rbkp~waers INTO TABLE gt_invoice FROM rseg
    INNER JOIN rbkp ON rbkp~gjahr EQ rseg~gjahr
    AND rbkp~belnr EQ rseg~belnr
    AND rbkp~stblg EQ '' "Ters kayıt belgeleri gelmesin
    FOR ALL ENTRIES IN lt_inv_key
    WHERE rseg~belnr EQ lt_inv_key-belnr
    AND rseg~gjahr EQ lt_inv_key-gjahr
    AND rseg~buzei EQ lt_inv_key-buzei.
    ENDIF.

* Satır indexleri için
DATA : lv_tabix LIKE sy-tabix.

* Mal Girişleri okunuyor...
IF lt_goods_key[] IS NOT INITIAL.
  REFRESH : gt_goodsmov.
  SELECT mseg~mjahr
         mseg~mblnr
         mseg~zeile
         mseg~menge
         mseg~sjahr
         mseg~smbln
         mseg~smblp INTO TABLE gt_goodsmov FROM mseg
         INNER JOIN mkpf ON mkpf~mjahr EQ mseg~mjahr
         AND mkpf~mblnr EQ mseg~mblnr
         FOR ALL ENTRIES IN lt_goods_key
         WHERE mseg~mjahr EQ lt_goods_key-mjahr
         AND mseg~mblnr EQ lt_goods_key-mblnr
         AND mseg~zeile EQ lt_goods_key-zeile.
         SORT gt_goodsmov BY mjahr mblnr zeile.

  LOOP AT gt_goodsmov WHERE smbln IS NOT INITIAL.
    lv_tabix = sy-tabix.
    READ TABLE gt_goodsmov
    WITH KEY mjahr = gt_goodsmov-sjahr
    mblnr = gt_goodsmov-smbln
    zeile = gt_goodsmov-smblp
    BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      DELETE gt_goodsmov INDEX lv_tabix.
      ENDIF.
      ENDLOOP.
      DELETE gt_goodsmov WHERE smbln IS NOT INITIAL.
ENDIF.

* Toplam 3 SELECT komutunda Satın alma Belgeleri , Faturalar
* ve Mal Girişleri okunmuş oldu. Bundan sonra BINARY SEARCH
* yardımıyla GT_DATA içindeki ek alanları doldurmamız yeterli olacaktır.
* BINARY SEARCH için tabloları sıralıyoruz

SORT GT_INVOICE BY GJAHR BELNR BUZEI.
SORT GT_GOODSMOV BY MJAHR MBLNR ZEILE.

LOOP AT GT_DATA. LV_TABIX = SY-TABIX.
  IF GT_DATA-VGABE EQ '1'.
* Mal girişi
    READ TABLE GT_GOODSMOV WITH KEY MJAHR = GT_DATA-GJAHR
                                    MBLNR = GT_DATA-BELNR
                                    ZEILE = GT_DATA-BUZEI
                                    BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GT_DATA-MENGEX = GT_GOODSMOV-MENGE.
    ENDIF.
  ELSEIF GT_DATA-VGABE EQ '2'.

* Faturalar
    READ TABLE GT_INVOICE WITH KEY GJAHR = GT_DATA-GJAHR
                                   BELNR = GT_DATA-BELNR
                                   BUZEI = GT_DATA-BUZEI
                                   BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      GT_DATA-WRBTR = GT_INVOICE-WRBTR.
      GT_DATA-WAERS = GT_INVOICE-WAERS.
    ENDIF.
  ENDIF.
  MODIFY GT_DATA INDEX LV_TABIX.
ENDLOOP.

GET RUN TIME FIELD GV_T2.GV_T3 = ( GV_T2 - GV_T1 ) / 1000000.
WRITE : / 'Toplam Çalışma Süresi (saniye):' ,
          GV_T3 LEFT-JUSTIFIED .

GV_LINE_COUNT = LINES( GT_INVOICE ).
WRITE : / 'Toplam okunan Fatura Sayısı :' ,
          GV_LINE_COUNT LEFT-JUSTIFIED.

GV_LINE_COUNT = LINES( GT_GOODSMOV ).
WRITE : / 'Toplam okunan Mal Girişi Sayısı :' ,
          GV_LINE_COUNT LEFT-JUSTIFIED.

GV_LINE_COUNT = LINES( GT_DATA ).
WRITE : / 'Toplam okunan Kayıt Sayısı :' ,
          GV_LINE_COUNT LEFT-JUSTIFIED.
