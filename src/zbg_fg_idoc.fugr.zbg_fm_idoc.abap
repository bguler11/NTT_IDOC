FUNCTION ZBG_FM_IDOC.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_KUNNR) TYPE  KUNNR OPTIONAL
*"  EXPORTING
*"     VALUE(ES_IDOC) TYPE  ZBG_S_IDOC
*"----------------------------------------------------------------------
  DATA: lt_edidd TYPE TABLE OF edidd,
        lt_edidc TYPE TABLE OF edidc.

  IF iv_kunnr IS NOT INITIAL.

    SELECT name1,
           ort02,
           stras,
           ort01,
           regio,
           land1
       FROM kna1
      WHERE kunnr = @iv_kunnr
       INTO TABLE @DATA(lt_kunnr).

    es_idoc = VALUE #( lt_kunnr[ 1 ] OPTIONAL ).

    DATA(ls_edidc) = VALUE edidc( mestyp = 'ZBGULER_IDOC'
                                  doctyp = 'ZBGULER_TYPE'
                                  rcvprn = 'S4HCLNT500'
                                  rcvprt = 'LS' ).
    APPEND INITIAL LINE TO lt_edidd ASSIGNING FIELD-SYMBOL(<fs_edidd>).
    <fs_edidd>-segnam = 'ZBGULER_IDOC'.
    <fs_edidd>-sdata  = |{ es_idoc-name1 WIDTH = 35 ALIGN = LEFT }| &&
                        |{ es_idoc-ort02 WIDTH = 35 ALIGN = LEFT }| &&
                        |{ es_idoc-stras WIDTH = 35 ALIGN = LEFT }| &&
                        |{ es_idoc-ort01 WIDTH = 35 ALIGN = LEFT }| &&
                        |{ es_idoc-regio WIDTH = 3 ALIGN = LEFT }{ es_idoc-land1 WIDTH = 3 ALIGN = LEFT }|.

    CALL FUNCTION 'MASTER_IDOC_DISTRIBUTE'
      EXPORTING
        master_idoc_control            = ls_edidc
      TABLES
        communication_idoc_control     = lt_edidc
        master_idoc_data               = lt_edidd
      EXCEPTIONS
        error_in_idoc_control          = 1
        error_writing_idoc_status      = 2
        error_in_idoc_data             = 3
        sending_logical_system_unknown = 4
        OTHERS                         = 5.

    IF sy-subrc EQ 0.
      CALL FUNCTION 'DB_COMMIT'.
      CALL FUNCTION 'DEQUEUE_ALL'.
      COMMIT WORK.
    ENDIF.

  ENDIF.

ENDFUNCTION.
