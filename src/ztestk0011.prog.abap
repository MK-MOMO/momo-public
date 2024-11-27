*&---------------------------------------------------------------------*
*& Report ZCVR0070
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* Program Description: sales Order creation
* Developer : LJ
* Date : 11 APR 2023
* Detail : Sales Order creation
*  'BUS2030' => INQUIRY
*  'BUS2031' => QUOTATION
*  'BUS2032' => Sales Order
*  'BUS2034' => CONTRACT
*  'BUS2035' => Schedule agreement
*  'BUS2090' => ROUGH_GOODS_RECEIPT_IS_RETAIL
*  'BUS2094' => CREDIT_MEMO_REQ
*  'BUS2095' => MASTER_CONTRACT
*  'BUS2096' => DEBIT_MEMO_REQ
*  'BUS2102' => RETURNS
*  'BUS2015' => DELIVERY_SHIPPING_NOTIF
*&----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
REPORT ztestk0011.

*----------------------------------------------------------------------*
* Types
*----------------------------------------------------------------------*

TYPES :
  BEGIN OF typ_BAPIUSW01,
    objtype TYPE oj_name,
  END OF  typ_BAPIUSW01 .

TYPES :
 typ_t_BAPIINCOMP TYPE STANDARD TABLE OF bapiincomp .

*↓ADD 20241030 河野
TYPES :
  BEGIN OF typ_msg_vbeln,
    LOG_NO TYPE BAPIRET2-LOG_NO,
    vbeln  TYPE BAPIVBELN-vbeln,
  END OF  typ_msg_vbeln.
*↑ADD 20241030 河野

*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CONSTANTS :


*---header w/o update flag
  BEGIN OF cns_groupH1 ,
    str1 TYPE char50 VALUE 'BAPIVBELN',
    str2 TYPE char50 VALUE 'BAPIUSW01',

  END OF cns_groupH1,


*---header with update flag
  BEGIN OF cns_groupH2 ,
    str1 TYPE char50 VALUE 'BAPISDHD1',
    str2 TYPE char50 VALUE 'BAPISDH1',
  END OF cns_groupH2,


*---item w/o update flag
  BEGIN OF cns_groupI1 ,
    str1 TYPE char50 VALUE 'BAPIPARNR',
    str2 TYPE char50 VALUE 'BAPISDTEXT',
  END OF cns_groupI1 ,

*---item with update flag
  BEGIN OF cns_groupI2 ,
    str1 TYPE char50 VALUE 'BAPISDITM',
    str2 TYPE char50 VALUE 'BAPISCHDL',
    str3 TYPE char50 VALUE 'BAPICOND',
  END OF cns_groupI2 .


*----------------------------------------------------------------------*
*       Tables
*----------------------------------------------------------------------*

DATA:
  grt_grouph1 TYPE RANGE OF char50,
  grt_grouph2 TYPE RANGE OF char50,
  grt_groupi1 TYPE RANGE OF char50,
  grt_groupi2 TYPE RANGE OF char50.


DATA :
grd_input_addr TYPE RANGE OF char50.

DATA:
  gr_table     TYPE REF TO cl_salv_table.

****↓---ADD 20230421 Kawano
DATA :
  th_bapisdhd1   TYPE bapisdhd1,
  td_bapisditm   TYPE STANDARD TABLE OF bapisditm,
  td_bapischdl   TYPE STANDARD TABLE OF bapischdl,
  td_bapicond    TYPE STANDARD TABLE OF bapicond,
  td_bapiparnr   TYPE STANDARD TABLE OF bapiparnr,
  td_return      TYPE STANDARD TABLE OF bapiret2,
  th_return      LIKE LINE OF td_return,
  w_line         TYPE c LENGTH 10,
*  go_interface_factory TYPE REF TO zcl_interface_factory,
  rd_dummy_mtart TYPE RANGE OF mara-mtart,
  rd_debicre     TYPE RANGE OF vbak-auart,
  TD_RESULT      TYPE match_result_tab,
  TH_RESULT      LIKE LINE OF TD_RESULT,
  w_file         TYPE string,
  w_path         TYPE string,
  w_count        TYPE I.
****↑---ADD 20230421 Kawano

*↓ADD 20241030 河野
DATA :td_msg_vbeln TYPE STANDARD TABLE OF typ_msg_vbeln,
      th_msg_vbeln LIKE LINE OF td_msg_vbeln.
*↑ADD 20241030 河野

*&---------------------------------------------------------------------*
*& INCLUDE
*&---------------------------------------------------------------------*

INCLUDE ZTESTK0012 .

*---update mode
PARAMETERS P_UPdkz TYPE updkz_d .

*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
INITIALIZATION .
*--- オブジェクト生成
  CREATE OBJECT go_interface_factory.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*

START-OF-SELECTION.

****↓---ADD 20230421 Kawano

*--- TVARV定数取得
  go_interface_factory->get_tvarvc_value(
     EXPORTING
      i_name = 'S_SD_DUMMY_MTART'
     IMPORTING
      et_value = rd_dummy_mtart ) .

  IF rd_dummy_mtart IS INITIAL.
    RETURN.
  ENDIF.
****↑---ADD 20230421 Kawano

  go_interface_factory->get_tvarvc_value(
     EXPORTING
      i_name = 'S_SD_DEBICRE_AUART'
     IMPORTING
      et_value = rd_debicre ) .

  IF rd_debicre IS INITIAL.
    RETURN.
  ENDIF.


*---init condition
  PERFORM frm_init_processing_condtion .



  IF prd_fg IS NOT INITIAL .
*   ファイルパスとファイル名の分割処理
    FIND ALL OCCURRENCES OF '\' IN p_file RESULTS TD_RESULT.
    SORT TD_RESULT BY OFFSET DESCENDING.
    READ TABLE TD_RESULT INTO TH_RESULT INDEX 1.
    w_count = TH_RESULT-OFFSET + TH_RESULT-LENGTH.

    w_path = p_file(w_count).
    w_file = p_file+w_count.

*---read excel file
    PERFORM frm_upload_excle_file
                           USING p_file
                                 p_batch
                        CHANGING gt_excel.


  ELSE .

*   ファイルパスとファイル名の分割処理
    FIND ALL OCCURRENCES OF '/' IN p_sfile RESULTS TD_RESULT.
    SORT TD_RESULT BY OFFSET DESCENDING.
    READ TABLE TD_RESULT INTO TH_RESULT INDEX 1.
    w_count = TH_RESULT-OFFSET + TH_RESULT-LENGTH.

    w_path = p_sfile(w_count).
    w_file = p_sfile+w_count.

    MESSAGE S102(zsd001) WITH w_path. "ファイルパス：&1
    MESSAGE S103(zsd001) WITH w_file. "ファイル名：&1

*---read excel file
    PERFORM frm_read_flat_file
                           USING p_sfile
                        CHANGING gt_excel.


  ENDIF .

*---sales doc  create
  PERFORM frm_sales_order_create
                  USING gt_excel .


  IF sy-batch IS INITIAL  .
*---show the result
    PERFORM frm_SHOW_ALV_RESULT .

  ELSE .

*↓UPD 20241030 河野
*    PERFORM frm_output_job_list .
    PERFORM add_process_log_info.

    DATA:lw_log_no TYPE bapie1ret2-LOG_NO,
         lw_vbeln  TYPE BAPIVBELN-vbeln,
         lw_vbeln_wk TYPE BAPIVBELN-vbeln,
         lw_slen   TYPE i,
         lw_msg    TYPE c LENGTH 50,
         lw_msg_flg TYPE C LENGTH 1.

    LOOP AT gt_return ASSIGNING FIELD-SYMBOL(<lfs_return>) .

      READ TABLE td_msg_vbeln ASSIGNING FIELD-SYMBOL(<fs_vbeln>) WITH KEY log_no = <lfs_return>-log_no.

      IF SY-SUBRC = 0.
        IF lw_vbeln <> <fs_vbeln>-vbeln.
          lw_vbeln = <fs_vbeln>-vbeln.
          CLEAR lw_msg_flg.
        ENDIF.
      ENDIF.

      IF <lfs_return>-type = 'A' OR <lfs_return>-type = 'E' OR <lfs_return>-type = 'W'.
        IF lw_msg_flg IS INITIAL.

          lw_msg_flg = 'X'.
          LW_SLEN = STRLEN( lw_vbeln ).
          LW_SLEN = 6 - LW_SLEN.
          lw_vbeln_wk = lw_vbeln.

*         前0埋め
          DO LW_SLEN TIMES.
            CONCATENATE '0' lw_vbeln_wk INTO lw_vbeln_wk RESPECTING BLANKS.
          ENDDO.

          lw_msg = lw_vbeln_wk && TEXT-009.

          "&1 で警告又はエラーが発生しました
          MESSAGE E124(zsd001) WITH lw_msg INTO DATA(l_msg_dummy2).
          go_interface_factory->message_output( syst ) .

        ENDIF.
      ENDIF.

     MESSAGE ID <lfs_return>-id
           TYPE <lfs_return>-type
           NUMBER <lfs_return>-number
           WITH   <lfs_return>-message_v1
                  <lfs_return>-message_v2
                  <lfs_return>-message_v3
                  <lfs_return>-message_v4
         INTO DATA(l_msg_dummy).

     go_interface_factory->message_output( syst ) .
   ENDLOOP.
*↑UPD 20241030 河野

  ENDIF .

*&---------------------------------------------------------------------*
*&      Form  frm_f4help_p_infile
*&---------------------------------------------------------------------*
FORM frm_init_processing_condtion .


*-items
  DATA : lrs_grouph1 LIKE LINE OF grt_grouph1 .
  DATA : lrs_grouph2 LIKE LINE OF grt_grouph2 .



*-header
  DATA : lrs_groupi1 LIKE LINE OF grt_groupi1.
  DATA : lrs_groupi2 LIKE LINE OF grt_groupi2.




  FIELD-SYMBOLS <lfs_comp> TYPE char50 .


*--groupH1
  DO .

    ASSIGN COMPONENT sy-index OF STRUCTURE cns_groupH1 TO <lfs_comp> .

    IF sy-subrc <> 0 .
      EXIT .
    ELSE .

      lrs_grouph1-sign = 'I' .
      lrs_grouph1-option = 'EQ' .
      lrs_grouph1-low  = <lfs_comp>  .

      TRANSLATE  lrs_grouph1-low TO UPPER CASE .

      APPEND lrs_groupH1 TO grt_groupH1 .

    ENDIF .

  ENDDO .


*--groupH2
  DO .

    ASSIGN COMPONENT sy-index OF STRUCTURE cns_groupH2 TO <lfs_comp> .

    IF sy-subrc <> 0 .
      EXIT .
    ELSE .

      lrs_groupH2-sign = 'I' .
      lrs_groupH2-option = 'EQ' .
      lrs_groupH2-low  = <lfs_comp>  .

      TRANSLATE  lrs_groupH2-low TO UPPER CASE .

      APPEND lrs_groupH2 TO grt_groupH2 .

    ENDIF .

  ENDDO .


*--groupI1

  DO .

    ASSIGN COMPONENT sy-index OF STRUCTURE cns_groupI1 TO <lfs_comp> .

    IF sy-subrc <> 0 .
      EXIT .
    ELSE .

      lrs_groupI1-sign = 'I' .
      lrs_groupI1-option = 'EQ' .
      lrs_groupI1-low  = <lfs_comp>  .

      TRANSLATE  lrs_groupI1-low TO UPPER CASE .

      APPEND lrs_groupI1 TO grt_groupI1 .

    ENDIF .

  ENDDO .


*--groupI2

  DO .

    ASSIGN COMPONENT sy-index OF STRUCTURE cns_groupI2 TO <lfs_comp> .

    IF sy-subrc <> 0 .
      EXIT .
    ELSE .

      lrs_groupI2-sign = 'I' .
      lrs_groupI2-option = 'EQ' .
      lrs_groupI2-low  = <lfs_comp>  .

      TRANSLATE  lrs_groupI2-low TO UPPER CASE .

      APPEND lrs_groupI2 TO grt_groupI2 .

    ENDIF .

  ENDDO .


ENDFORM.

*----------------------------------------------------------------------*
*      Form  Sales Order Create                                        *
*----------------------------------------------------------------------*
FORM frm_sales_order_create
         USING i_t_raw_excel TYPE typ_t_excel  .


  DATA :
    lt_BAPIINCOMP TYPE STANDARD TABLE OF bapiincomp .

  DATA :
    ls_BAPIVBELN  TYPE bapivbeln,
    lt_BAPISDHD1  TYPE STANDARD TABLE OF bapisdhd1,
    ls_BAPISDHD1  TYPE bapisdhd1,
    ls_BAPISDHD1x TYPE BAPISDHD1x.

  DATA :
    ls_bapiusw01  TYPE typ_BAPIUSW01 .


  DATA :
    ls_BAPISDH1  TYPE bapisdh1,
    ls_BAPISDH1x TYPE BAPISDH1x.

  DATA :
    ls_BAPISDTEXT TYPE bapisdtext,
    lt_BAPISDTEXT TYPE STANDARD TABLE OF bapisdtext.


  DATA :
    lt_BAPISDITM  TYPE STANDARD TABLE OF bapisditm,
    lt_BAPISDITMx TYPE STANDARD TABLE OF BAPISDITMx.


  DATA :
    lt_BAPISCHDL  TYPE STANDARD TABLE OF bapischdl,
    lt_BAPISCHDLx TYPE STANDARD TABLE OF BAPISCHDLx.


  DATA :
    lt_BAPICOND  TYPE STANDARD TABLE OF bapicond,
    lt_BAPICONDx TYPE STANDARD TABLE OF BAPICONDx.



  DATA :
     lt_BAPIPARNR TYPE STANDARD TABLE OF bapiparnr .



  DATA:
    BEGIN OF ls_sp_fields,
      str TYPE string VALUE 'STR',
      tab TYPE string VALUE 'TAB',
    END OF ls_sp_fields.


  DATA :
    l_header_breakers TYPE bapimeoutheader .

  DATA :
    lw_dynamic_str  TYPE string,
    lw_dynamic_strx TYPE string.


  DATA :
    lt_return TYPE STANDARD TABLE OF bapiret2 .



  DATA :
    l_structure      TYPE char50,
    lw_dynamic_itab  TYPE string,
    lref             TYPE REF TO data,

    l_structurex     TYPE char50,
    lw_dynamic_itabx TYPE string,
    lref_x           TYPE REF TO data.


  DATA :
    l_STR TYPE  String,
    l_TAB TYPE  String.

  DATA :
    lt_structure TYPE STANDARD TABLE OF typ_excel,
    lt_fields    TYPE STANDARD TABLE OF typ_excel,
    lt_data      TYPE STANDARD TABLE OF typ_excel,
    lt_data2     TYPE STANDARD TABLE OF typ_excel.

*--header
  FIELD-SYMBOLS :
    <lfs_s_str>  TYPE any,
    <lfs_s_strx> TYPE any.


*--items
  FIELD-SYMBOLS :
    <lfs_t_itab>  TYPE STANDARD TABLE,
    <lfs_s_itab>  TYPE any,
    <lfs_comp>    TYPE any,

    <lfs_t_itabx> TYPE STANDARD TABLE,
    <lfs_s_itabx> TYPE any,
    <lfs_compx>   TYPE any.

  DATA :
    l_key_structure TYPE string,
    l_key_fields    TYPE string,
    l_key_val       TYPE string,
    l_key_col       TYPE num6,
    l_key_breaker   TYPE string.

*↓ADD 20240229 kawano
  DATA :
    lw_errflg TYPE FLAG,
    lw_line   TYPE I.
*↑ADD 20240229 kawano

*---
  l_key_structure = 'BAPIVBELN' .
  l_key_fields = 'VBELN' .



  CHECK g_error IS INITIAL .

*---
  LOOP AT i_t_raw_excel ASSIGNING FIELD-SYMBOL(<lfs_raw_excel>).

    CASE <lfs_raw_excel>-row .
*--structure
      WHEN 1 .
        APPEND <lfs_raw_excel> TO lt_structure .
*--fields
      WHEN 2 .

        APPEND <lfs_raw_excel> TO lt_fields  .

      WHEN 3 OR 4 OR 5 .

*--Just sikp
      WHEN OTHERS .

        APPEND <lfs_raw_excel> TO lt_data .
        APPEND <lfs_raw_excel> TO lt_data2 .


    ENDCASE .
  ENDLOOP.

*--get key structure
  LOOP AT  lt_structure ASSIGNING FIELD-SYMBOL(<lfs_key_structure>)
                             WHERE value = l_key_structure .

*--get key fields
    LOOP AT  lt_fields ASSIGNING FIELD-SYMBOL(<lfs_key_fields>)
         WHERE value = l_key_fields
         AND col = <lfs_key_structure>-col .
      EXIT .
    ENDLOOP .

    IF sy-subrc = 0 .
      EXIT .
    ENDIF .

  ENDLOOP .


  IF sy-subrc = 0 .
    l_key_col = <lfs_key_structure>-col .
  ELSE .
    g_error = abap_true .
    MESSAGE s006(zcv001) DISPLAY LIKE 'E' .
    RETURN .
  ENDIF .

  CHECK sy-subrc = 0 .



*---LJ 20240212 Add Start
  CLEAR  gs_pro_no .
*---LJ 20240212 Add End

*  th_return-type   = 'S'.
*  th_return-id     = 'ZSD001'.
*  th_return-number = '103'.
*  MESSAGE ID 'ZSD001' TYPE 'S' NUMBER 103 WITH w_file INTO th_return-message. "ファイル名：&1
*  APPEND th_return TO gt_return.

  CLEAR th_return.
  LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data_wk>).
    AT NEW ROW.
     IF  <lfs_data_wk>-col <> '000000001'.
       READ TABLE lt_data WITH KEY row = <lfs_data_wk>-row
                                   value = '<EOL>'
                                   TRANSPORTING NO FIELDS.

       IF SY-SUBRC = 0.
         lw_line = <lfs_data_wk>-row - 5.
         th_return-type   = 'E'.
         th_return-id     = 'ZSD001'.
         th_return-number = '104'.
         th_return-log_no = TEXT-003 && lw_line.
         MESSAGE ID 'ZSD001' TYPE 'E' NUMBER 106 INTO th_return-message. "明細データがありません
         gs_pro_no-err = gs_pro_no-err + 1.
         APPEND th_return TO gt_return.

*↓ADD 20241030 河野
         th_msg_vbeln-log_no = th_return-log_no.
         th_msg_vbeln-vbeln = '000000'.
         APPEND th_msg_vbeln TO td_msg_vbeln.
*↑ADD 20241030 河野

       ENDIF.
       DELETE lt_data WHERE ROW = <lfs_data_wk>-row.
     ELSE.
*↓ADD 20241030 河野
         lw_line = <lfs_data_wk>-row - 5.
         th_msg_vbeln-log_no = TEXT-003 && lw_line.
         th_msg_vbeln-vbeln = <lfs_data_wk>-VALUE.
         APPEND th_msg_vbeln TO td_msg_vbeln.
*↑ADD 20241030 河野
     ENDIF.
    ENDAT.
  ENDLOOP.


  LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>) .

***↓---ADD 20230421 Kawano
    IF w_line IS INITIAL.
      w_line = <lfs_data>-row - 6.
    ENDIF.
***↑---ADD 20230421 Kawano
*---
    AT NEW row .

      READ TABLE lt_data2 ASSIGNING FIELD-SYMBOL(<lfs_data2>)
                             WITH KEY row = <lfs_data>-row
                                      col = l_key_col .

      IF l_key_breaker IS INITIAL .

        l_key_breaker = <lfs_data2>-value  .

      ELSE .
*-----
        IF l_key_breaker <> <lfs_data2>-value  .
*---
          CLEAR : lt_return ,
                  lt_BAPIINCOMP .


*---LJ 20240212 Add Start
          gs_pro_no-ttl = gs_pro_no-ttl + 1 .
*---LJ 20240212 Add End

*↓20240229 ADD kawano
          PERFORM FRM_CHK_KPEIN USING lt_BAPICOND
                                CHANGING lt_return
                                         lw_errflg.
*↑20240229 ADD kawano

*---if insert then clear .
          IF P_UPdkz = 'I' AND lw_errflg IS INITIAL.
            CLEAR ls_BAPIVBELN .

            CALL FUNCTION 'SD_SALESDOCUMENT_CREATE'
              EXPORTING
                salesdocument        = ls_BAPIVBELN
                sales_header_in      = ls_BAPISDHD1
                sales_header_inx     = ls_BAPISDHD1X
*               SENDER               =
*               BINARY_RELATIONSHIPTYPE       = ' '
*               INT_NUMBER_ASSIGNMENT         = ' '
*               BEHAVE_WHEN_ERROR    = ''
*               LOGIC_SWITCH         = ' '
                business_object      = ls_bapiusw01
                testrun              = P_test
*               CONVERT_PARVW_AUART  = ' '
*               STATUS_BUFFER_REFRESH         = 'X'
*               CALL_ACTIVE          = ' '
*               I_WITHOUT_INIT       = ' '
*               I_REFRESH_V45I       = 'X'
*               I_TESTRUN_EXTENDED   = P_test
*               I_CHECK_AG           = 'X'
*             IMPORTING
*               SALESDOCUMENT_EX     =
*               SALES_HEADER_OUT     =
*               SALES_HEADER_STATUS  =
              TABLES
                return               = lt_return
                sales_items_in       = lt_BAPISDITM
                sales_items_inx      = lt_BAPISDITMX
                sales_partners       = lt_BAPIPARNR
                sales_schedules_in   = lt_BAPISCHDL
                sales_schedules_inx  = lt_BAPISCHDLX
                sales_conditions_in  = lt_BAPICOND
                sales_conditions_inx = lt_BAPICONDX
*               SALES_CFGS_REF       =
*               SALES_CFGS_INST      =
*               SALES_CFGS_PART_OF   =
*               SALES_CFGS_VALUE     =
*               SALES_CFGS_BLOB      =
*               SALES_CFGS_VK        =
*               SALES_CFGS_REFINST   =
*               SALES_CCARD          =
                sales_text           = lt_BAPISDTEXT
*               SALES_KEYS           =
*               SALES_CONTRACT_IN    =
*               SALES_CONTRACT_INX   =
*               EXTENSIONIN          =
*               PARTNERADDRESSES     =
*               SALES_SCHED_CONF_IN  =
*               ITEMS_EX             =
*               SCHEDULE_EX          =
*               BUSINESS_EX          =
                incomplete_log       = lt_BAPIINCOMP
*               EXTENSIONEX          =
*               CONDITIONS_EX        =
*               PARTNERS_EX          =
*               TEXTHEADERS_EX       =
*               TEXTLINES_EX         =
*               BATCH_CHARC          =
*               CAMPAIGN_ASGN        =
              .

*---LJ ADD 20240110 Start
            PERFORM append_incomplet_log USING lt_BAPIINCOMP
                                   CHANGING lt_return .
*---LJ ADD 20240110 End .

          ELSEIF lw_errflg IS INITIAL.

            CALL FUNCTION 'SD_SALESDOCUMENT_CHANGE'
              EXPORTING
                salesdocument     = ls_BAPIVBELN
*↓MOD 20240911 河野
*                order_header_in   = ls_BAPISDH1
*                order_header_inx  = ls_BAPISDH1x
                order_header_in   = ls_BAPISDHD1
                order_header_inx  = ls_BAPISDHD1X
*↑MOD 20240911 河野
                simulation        = p_test
*               INT_NUMBER_ASSIGNMENT       = ' '
*               BEHAVE_WHEN_ERROR = ''
                business_object   = ls_bapiusw01
*               CONVERT_PARVW_AUART         = ' '
*↓MOD 20240911 河野
                CALL_FROM_BAPI    = 'X'
*↑MOD 20240911 河野
*               CALL_FROM_BAPI    = ' '
*               LOGIC_SWITCH      =
*               I_CRM_LOCK_MODE   = ' '
*               NO_STATUS_BUF_INIT          = ' '
*               CALL_ACTIVE       = ' '
*               I_WITHOUT_INIT    = ' '
*               I_TESTRUN_EXTENDED          = P_test
* IMPORTING
*               SALES_HEADER_OUT  =
*               SALES_HEADER_STATUS         =
              TABLES
                return            = lt_return
                item_in           = lt_BAPISDITM
                item_inx          = lt_BAPISDITMx
                schedule_in       = lt_BAPISCHDL
                schedule_inx      = lt_BAPISCHDLx
*↓DEL 20240911 河野
*                partners          = lt_BAPIPARNR
*↑DEL 20240911 河野
*               PARTNERCHANGES    =
*               PARTNERADDRESSES  =
*               SALES_CFGS_REF    =
*               SALES_CFGS_INST   =
*               SALES_CFGS_PART_OF          =
*               SALES_CFGS_VALUE  =
*               SALES_CFGS_BLOB   =
*               SALES_CFGS_VK     =
*               SALES_CFGS_REFINST          =
*               SALES_CCARD       =
                sales_text        = lt_BAPISDTEXT
*               SALES_KEYS        =
                conditions_in     = lt_BAPICOND
                conditions_inx    = lt_BAPICONDx
*               SALES_CONTRACT_IN =
*               SALES_CONTRACT_INX          =
*               EXTENSIONIN       =
*               ITEMS_EX          =
*               SCHEDULE_EX       =
*               BUSINESS_EX       =
                incomplete_log    = lt_BAPIINCOMP
*               EXTENSIONEX       =
*               CONDITIONS_EX     =
*               SALES_SCHED_CONF_IN         =
*               DEL_SCHEDULE_EX   =
*               DEL_SCHEDULE_IN   =
*               DEL_SCHEDULE_INX  =
*               CORR_CUMQTY_IN    =
*               CORR_CUMQTY_INX   =
*               CORR_CUMQTY_EX    =
*               PARTNERS_EX       =
*               TEXTHEADERS_EX    =
*               TEXTLINES_EX      =
*               BATCH_CHARC       =
*               CAMPAIGN_ASGN     =
*               CONDITIONS_KONV_EX          =
              EXCEPTIONS
                incov_not_in_item = 1
                OTHERS            = 2.


*---LJ ADD 20240110 Start
            PERFORM append_incomplet_log USING lt_BAPIINCOMP
                                   CHANGING lt_return .
*---LJ ADD 20240110 End .


          ENDIF .


***↓---ADD 20230421 Kawano
          PERFORM frm_chk_cond USING    ls_BAPISDHD1
                                        lt_BAPIPARNR
                                        lt_BAPISDITM
                                        lt_BAPICOND
                                        w_line
                               CHANGING lt_return.
          CLEAR w_line.
***↑---ADD 20230421 Kawano

*---LJ 20240212 Add Start
          LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<lfs_return>)
                                   WHERE type = 'S' .

            IF <lfs_return>-id = 'V1'
            AND <lfs_return>-number = '311' .
              CONTINUE .
            ELSE .
              DELETE lt_return .
            ENDIF .
          ENDLOOP.
*---LJ 20240212 Add End


          LOOP AT lt_return ASSIGNING <lfs_return>
                                   WHERE type = 'E' OR  type = 'A'.
            EXIT .
          ENDLOOP .

          IF sy-subrc <> 0 .

*---LJ 20240212 Add Start
            gs_pro_no-suc = gs_pro_no-suc + 1 .
*---LJ 20240212 Add End

            COMMIT WORK AND WAIT .

          ELSE .

*---LJ 20240212 Add Start
            gs_pro_no-err = gs_pro_no-err + 1 .
*---LJ 20240212 Add End


            ROLLBACK WORK .

          ENDIF .

          APPEND LINES OF lt_return TO gt_return .

          l_key_breaker = <lfs_data2>-value  .

          UNASSIGN : <lfs_s_str> , <lfs_s_strx> .

          CLEAR : ls_BAPISDHD1, ls_BAPISDH1x,
                  lt_BAPISDITM, lt_BAPISDITMx,
                  lt_BAPICONDx, lt_BAPICOND,
                  lt_BAPIPARNR, lt_BAPISCHDL,
                  lt_BAPISCHDLx,
                  ls_BAPISDTEXT,lt_BAPISDTEXT.


        ENDIF .
      ENDIF .

    ENDAT .


*--get structure
    READ TABLE lt_structure ASSIGNING FIELD-SYMBOL(<lfs_structure>)
                                WITH KEY col = <lfs_data>-col .


    IF <lfs_structure>-value <> '<EOL>' .

      IF l_structure IS NOT INITIAL
      AND  l_structure <> <lfs_structure>-value .

*--header
        IF l_structure IN grt_groupH1
        OR  l_structure IN grt_groupH2 .


          IF l_structure IN grt_groupH2 .

            PERFORM frm_mark_update_flag  USING    <lfs_s_str>
                                                   lt_structure
                                                   lt_fields
                                         CHANGING  <lfs_s_strx> .

            UNASSIGN : <lfs_s_strx>.

          ENDIF .

          UNASSIGN :   <lfs_s_str>.
          CLEAR l_structure .

*item .
        ELSEIF l_structure IN grt_groupi1
         OR l_structure IN grt_groupi2 .
*---if structure change then append to table .

          APPEND <lfs_s_itab> TO <lfs_t_itab> .
          SORT <lfs_t_itab> .

          DELETE ADJACENT DUPLICATES FROM <lfs_t_itab> COMPARING ALL FIELDS .

*---line break for partner funciton .

          IF l_structure IN grt_groupi1
          AND <lfs_structure>-value  = '<LB>' .
            CONTINUE .
          ENDIF .


*-- item add condition break for groupi2
          IF l_structure IN grt_groupi2 .

            PERFORM frm_mark_update_flag  USING    <lfs_s_itab>
                                                   lt_structure
                                                   lt_fields
                                        CHANGING  <lfs_s_itabx> .

            APPEND <lfs_s_itabx> TO <lfs_t_itabx> .

            SORT <lfs_t_itabx> .

            DELETE ADJACENT DUPLICATES FROM <lfs_t_itabx> COMPARING ALL FIELDS .

            UNASSIGN :  <lfs_s_itabx> , <lfs_t_itabx>.

          ENDIF .


          UNASSIGN : <lfs_s_itab> , <lfs_t_itab>.

        ENDIF .

      ENDIF .


      l_structure = <lfs_structure>-value .

*---generate bapi table as {LS_} + {Structure name }
      IF l_structure IN grt_grouph1
       OR l_structure IN grt_grouph2 .

        IF <lfs_s_str> IS NOT ASSIGNED .

          CONCATENATE 'LS_' <lfs_structure>-value INTO lw_dynamic_str .
          ASSIGN (lw_dynamic_str) TO <lfs_s_str> .

*--key structure not have update flag

          IF l_structure IN grt_grouph2 .
            CONCATENATE 'LS_' <lfs_structure>-value 'X' INTO lw_dynamic_strx .
            ASSIGN (lw_dynamic_strx) TO <lfs_s_strx> .

          ENDIF .


        ENDIF .

      ELSE .

        IF <lfs_s_itab> IS NOT ASSIGNED .

          CONCATENATE 'LT_' <lfs_structure>-value INTO lw_dynamic_itab .

          ASSIGN (lw_dynamic_itab) TO <lfs_t_itab> .

          CREATE DATA lref LIKE LINE OF <lfs_t_itab> .

          ASSIGN lref->* TO <lfs_s_itab> .
        ENDIF .
      ENDIF .

*---generate bapi table as {LT_} + {Structure name } + {X}
      IF l_structure IN grt_groupI2 .
        IF  <lfs_s_itabx> IS NOT ASSIGNED .

          CONCATENATE 'LT_' <lfs_structure>-value  'X' INTO  lw_dynamic_itabx .

          ASSIGN (lw_dynamic_itabx) TO <lfs_t_itabx> .

          CREATE DATA lref_x LIKE LINE OF <lfs_t_itabx> .

          ASSIGN lref_x->* TO <lfs_s_itabx> .

        ENDIF .

      ENDIF .


*---get fields to fillout structure fields .
      READ TABLE lt_fields ASSIGNING FIELD-SYMBOL(<lfs_fields>)
                                  WITH KEY col = <lfs_data>-col .

      IF l_structure IN grt_grouph1
      OR l_structure IN grt_grouph2 .

*---header strucrute
        ASSIGN COMPONENT <lfs_fields>-value OF STRUCTURE <lfs_s_str>  TO <lfs_comp> .

        IF sy-subrc = 0 .

          <lfs_comp> = <lfs_data>-value .

        ENDIF .


      ELSE .
*---items  strucrute

        ASSIGN COMPONENT <lfs_fields>-value OF STRUCTURE <lfs_s_itab>  TO <lfs_comp> .

        IF sy-subrc = 0 .

          <lfs_comp> = <lfs_data>-value .

        ENDIF .

      ENDIF .

    ENDIF .


*--last structure.
    IF <lfs_data>-value = '<EOL>' .

*---if structure change then append to table .
      IF <lfs_s_itab> IS NOT INITIAL .

        APPEND <lfs_s_itab> TO <lfs_t_itab> .

        SORT <lfs_t_itab> .

        DELETE ADJACENT DUPLICATES FROM <lfs_t_itab> COMPARING ALL FIELDS .

*-- item add condition break for group item 2
        IF l_structure IN grt_groupi2 .

          PERFORM frm_mark_update_flag  USING    <lfs_s_itab>
                                                 lt_structure
                                                 lt_fields
                                      CHANGING  <lfs_s_itabx> .


          APPEND <lfs_s_itabx> TO <lfs_t_itabx> .

          SORT <lfs_t_itabx> .

          DELETE ADJACENT DUPLICATES FROM <lfs_t_itabx> COMPARING ALL FIELDS .

          UNASSIGN :  <lfs_s_itabx> , <lfs_t_itabx>.

        ENDIF .

        UNASSIGN : <lfs_s_itab> , <lfs_t_itab>.

      ENDIF.

      CLEAR l_structure .

    ENDIF .


    AT LAST .

      CLEAR : lt_return ,
              lt_BAPIINCOMP .
*
*---LJ 20240212 Add Start
      gs_pro_no-ttl = gs_pro_no-ttl + 1 .
*---LJ 20240212 Add End

*↓20240229 ADD kawano
          PERFORM FRM_CHK_KPEIN USING lt_BAPICOND
                                CHANGING lt_return
                                         lw_errflg.
*↑20240229 ADD kawano

*---if insert then clear .
      IF P_UPdkz = 'I' AND lw_errflg IS INITIAL.
        CLEAR ls_BAPIVBELN .

        CALL FUNCTION 'SD_SALESDOCUMENT_CREATE'
          EXPORTING
            salesdocument        = ls_BAPIVBELN
            sales_header_in      = ls_BAPISDHD1
            sales_header_inx     = ls_BAPISDHD1X
*           SENDER               =
*           BINARY_RELATIONSHIPTYPE       = ' '
*           INT_NUMBER_ASSIGNMENT         = ' '
*           BEHAVE_WHEN_ERROR    = ' '
*           LOGIC_SWITCH         = ' '
            business_object      = ls_bapiusw01
            testrun              = P_test
*           CONVERT_PARVW_AUART  = ' '
*           STATUS_BUFFER_REFRESH         = 'X'
*           CALL_ACTIVE          = ' '
*           I_WITHOUT_INIT       = ' '
*           I_REFRESH_V45I       = 'X'
*           I_TESTRUN_EXTENDED   = ' '
*           I_CHECK_AG           = 'X'
*             IMPORTING
*           SALESDOCUMENT_EX     =
*           SALES_HEADER_OUT     =
*           SALES_HEADER_STATUS  =
          TABLES
            return               = lt_return
            sales_items_in       = lt_BAPISDITM
            sales_items_inx      = lt_BAPISDITMX
            sales_partners       = lt_BAPIPARNR
            sales_schedules_in   = lt_BAPISCHDL
            sales_schedules_inx  = lt_BAPISCHDLX
            sales_conditions_in  = lt_BAPICOND
            sales_conditions_inx = lt_BAPICONDX
*           SALES_CFGS_REF       =
*           SALES_CFGS_INST      =
*           SALES_CFGS_PART_OF   =
*           SALES_CFGS_VALUE     =
*           SALES_CFGS_BLOB      =
*           SALES_CFGS_VK        =
*           SALES_CFGS_REFINST   =
*           SALES_CCARD          =
            sales_text           = lt_BAPISDTEXT
*           SALES_KEYS           =
*           SALES_CONTRACT_IN    =
*           SALES_CONTRACT_INX   =
*           EXTENSIONIN          =
*           PARTNERADDRESSES     =
*           SALES_SCHED_CONF_IN  =
*           ITEMS_EX             =
*           SCHEDULE_EX          =
*           BUSINESS_EX          =
            incomplete_log       = lt_BAPIINCOMP
*           EXTENSIONEX          =
*           CONDITIONS_EX        =
*           PARTNERS_EX          =
*           TEXTHEADERS_EX       =
*           TEXTLINES_EX         =
*           BATCH_CHARC          =
*           CAMPAIGN_ASGN        =
          .

*---LJ ADD 20240110 Start
        PERFORM append_incomplet_log USING lt_BAPIINCOMP
                               CHANGING lt_return .
*---LJ ADD 20240110 End .



      ELSEIF lw_errflg IS INITIAL.

        CALL FUNCTION 'SD_SALESDOCUMENT_CHANGE'
          EXPORTING
            salesdocument     = ls_BAPIVBELN
*↓MOD 20240911 河野
*            order_header_in   = ls_BAPISDH1
*            order_header_inx  = ls_BAPISDH1x
            order_header_in   = ls_BAPISDHD1
            order_header_inx  = ls_BAPISDHD1X
*↑MOD 20240911 河野
            simulation        = p_test
*           INT_NUMBER_ASSIGNMENT       = ' '
*           BEHAVE_WHEN_ERROR = ' '
            business_object   = ls_bapiusw01
*           CONVERT_PARVW_AUART         = ' '
*↓MOD 20240911 河野
           CALL_FROM_BAPI    = 'X'
*↑MOD 20240911 河野
*           CALL_FROM_BAPI    = ' '
*           LOGIC_SWITCH      =
*           I_CRM_LOCK_MODE   = ' '
*           NO_STATUS_BUF_INIT          = ' '
*           CALL_ACTIVE       = ' '
*           I_WITHOUT_INIT    = ' '
*           I_TESTRUN_EXTENDED          = ' '
* IMPORTING
*           SALES_HEADER_OUT  =
*           SALES_HEADER_STATUS         =
          TABLES
            return            = lt_return
            item_in           = lt_BAPISDITM
            item_inx          = lt_BAPISDITMx
            schedule_in       = lt_BAPISCHDL
            schedule_inx      = lt_BAPISCHDLx
*↓DEL 20240911 河野
*            partners          = lt_BAPIPARNR
*↑DEL 20240911 河野
*           PARTNERCHANGES    =
*           PARTNERADDRESSES  =
*           SALES_CFGS_REF    =
*           SALES_CFGS_INST   =
*           SALES_CFGS_PART_OF          =
*           SALES_CFGS_VALUE  =
*           SALES_CFGS_BLOB   =
*           SALES_CFGS_VK     =
*           SALES_CFGS_REFINST          =
*           SALES_CCARD       =
            sales_text        = lt_BAPISDTEXT
*           SALES_KEYS        =
            conditions_in     = lt_BAPICOND
            conditions_inx    = lt_BAPICONDx
*           SALES_CONTRACT_IN =
*           SALES_CONTRACT_INX          =
*           EXTENSIONIN       =
*           ITEMS_EX          =
*           SCHEDULE_EX       =
*           BUSINESS_EX       =
            incomplete_log    = lt_BAPIINCOMP
*           EXTENSIONEX       =
*           CONDITIONS_EX     =
*           SALES_SCHED_CONF_IN         =
*           DEL_SCHEDULE_EX   =
*           DEL_SCHEDULE_IN   =
*           DEL_SCHEDULE_INX  =
*           CORR_CUMQTY_IN    =
*           CORR_CUMQTY_INX   =
*           CORR_CUMQTY_EX    =
*           PARTNERS_EX       =
*           TEXTHEADERS_EX    =
*           TEXTLINES_EX      =
*           BATCH_CHARC       =
*           CAMPAIGN_ASGN     =
*           CONDITIONS_KONV_EX          =
          EXCEPTIONS
            incov_not_in_item = 1
            OTHERS            = 2.

*---LJ ADD 20240110 Start
        PERFORM append_incomplet_log USING lt_BAPIINCOMP
                               CHANGING lt_return .
*---LJ ADD 20240110 End .

      ENDIF .


***↓---ADD 20230421 Kawano
      PERFORM frm_chk_cond USING    ls_BAPISDHD1
                                    lt_BAPIPARNR
                                    lt_BAPISDITM
                                    lt_BAPICOND
                                    w_line
                           CHANGING lt_return.
***↑---ADD 20230421 Kawano

*---LJ 20240212 Add Start
*---for success only remain V1(311)
      LOOP AT lt_return ASSIGNING <lfs_return>
                          WHERE type = 'S' .

        IF <lfs_return>-id = 'V1'
        AND <lfs_return>-number = '311' .
          CONTINUE .
        ELSE .
          DELETE lt_return .
        ENDIF .
      ENDLOOP.
*---LJ 20240212 Add End

      LOOP AT lt_return ASSIGNING <lfs_return>
                               WHERE type = 'E'
                                 OR  type = 'A'.
        EXIT .
      ENDLOOP .

      IF sy-subrc <> 0 .
*---LJ 20240212 Add Start
        gs_pro_no-suc = gs_pro_no-suc + 1 .

*---LJ 20240212 Add End
        COMMIT WORK AND WAIT .

      ELSE .

*---LJ 20240212 Add Start
        gs_pro_no-err = gs_pro_no-err + 1 .
*---LJ 20240212 Add End

        ROLLBACK WORK .

      ENDIF .


      APPEND LINES OF lt_return TO gt_return .


    ENDAT .
  ENDLOOP .

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FRM_MARK_UPDATE_FLAG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM frm_mark_update_flag  USING    i_s_in TYPE any
                                    it_structure TYPE typ_t_excel
                                    it_fields TYPE typ_t_excel
                           CHANGING o_s_inx TYPE any .


  DATA :
    lref  TYPE REF TO data,
    lrefx TYPE REF TO data.

  DATA :
    l_comp_name   TYPE string,
    l_help_name1  TYPE string,
    l_help_name2  TYPE string,
    l_comp_type   TYPE string,
    l_help_domain TYPE domname.


  DATA :
    l_TABNAME TYPE ddobjname,
    lt_dfies  TYPE STANDARD TABLE OF dfies.


  FIELD-SYMBOLS :
    <lfs_in>  TYPE any,
    <lfs_inx> TYPE any.

  FIELD-SYMBOLS :
    <lfs_comp>  TYPE any,
    <lfs_compx> TYPE any.

  DATA:
    lr_input_addr LIKE LINE OF grd_input_addr .


*---
  IF grd_input_addr IS INITIAL .
    LOOP AT it_structure ASSIGNING FIELD-SYMBOL(<lfs_str>).
      LOOP AT it_fields ASSIGNING FIELD-SYMBOL(<lfs_fields>)
                    WHERE col = <lfs_str>-col .

        CLEAR lr_input_addr .
        lr_input_addr-sign  = 'I' .
        lr_input_addr-option = 'EQ'.
        lr_input_addr-low = |{ <lfs_str>-value }-{ <lfs_fields>-value }| .

        APPEND lr_input_addr TO grd_input_addr .
      ENDLOOP.
    ENDLOOP.
  ENDIF .


*--
  CREATE DATA lref LIKE i_s_in .

  ASSIGN lref->* TO <lfs_in> .

  <lfs_in> = i_s_in .

  CREATE DATA lrefx LIKE o_s_inx .
  ASSIGN lrefx->* TO <lfs_inx> .

*---
  MOVE-CORRESPONDING <lfs_in> TO <lfs_inx> .

*--clear component type as 'BAPIUPDATE' fields .

  DESCRIBE FIELD <lfs_inx> HELP-ID l_TABNAME .


  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = l_TABNAME
*     FIELDNAME      = ' '
*     LANGU          = SY-LANGU
*     LFIELDNAME     = ' '
*     ALL_TYPES      = ' '
*     GROUP_NAMES    = ' '
*     UCLEN          =
*     DO_NOT_WRITE   = ' '
*   IMPORTING
*     X030L_WA       =
*     DDOBJTYPE      =
*     DFIES_WA       =
*     LINES_DESCR    =
    TABLES
      dfies_tab      = lt_dfies
*     FIXED_VALUES   =
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

*--
  LOOP AT lt_dfies ASSIGNING FIELD-SYMBOL(<lfs_dfies>) .

    ASSIGN COMPONENT sy-tabix OF STRUCTURE <lfs_inx> TO <lfs_comp> .

    IF <lfs_dfies>-rollname = 'BAPIUPDATE'.

      CLEAR <lfs_comp> .

    ENDIF .
*---
  ENDLOOP .


  DO .

    ASSIGN COMPONENT sy-index OF STRUCTURE <lfs_in> TO <lfs_comp> .

    IF sy-subrc = 0 .
*
*
      DESCRIBE FIELD <lfs_comp> HELP-ID l_comp_name .


      SPLIT l_comp_name AT '-' INTO : l_help_name1
                                      l_help_name2 .
*----
      PERFORM get_fields_domain USING l_help_name1
                                      l_help_name2
                             CHANGING l_help_domain .
*---if input value exit
      IF  <lfs_comp> IS NOT INITIAL
*---or specifed as space in input file and which is flag value
        OR ( l_comp_name IN grd_input_addr AND l_help_domain = 'XFELD') .


        READ TABLE lt_dfies ASSIGNING <lfs_dfies> WITH KEY fieldname = l_help_name2 .

        IF sy-subrc = 0 .

          ASSIGN COMPONENT l_help_name2 OF STRUCTURE <lfs_inx> TO <lfs_compx> .

*--flag update
          IF <lfs_dfies>-rollname = 'BAPIUPDATE'.

            <lfs_compx> = abap_true .

*--other value
          ELSE .

            <lfs_compx> = <lfs_comp> .

          ENDIF .

        ENDIF .

      ENDIF .
    ELSE .
      EXIT .
    ENDIF .

  ENDDO .


*--flag updatemode
  IF <lfs_inx>  IS NOT INITIAL .
    ASSIGN COMPONENT 'UPDATEFLAG' OF STRUCTURE <lfs_inx> TO <lfs_compx> .

    IF sy-subrc = 0 .
      <lfs_compx>  = P_UPdkz.
    ENDIF .

  ENDIF .


*--
  o_s_inx  = <lfs_inx> .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form read_line_break_keyvalue
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM read_line_break_keyvalue  USING   i_key_col TYPE num6
                                       i_s_data TYPE typ_excel
                             CHANGING o_key_breaker TYPE string .


  FIELD-SYMBOLS <lfs_comp> TYPE any.


  ASSIGN COMPONENT i_key_col OF STRUCTURE i_s_data TO <lfs_comp> .

  IF sy-subrc = 0 .

    o_key_breaker = i_s_data-value .

  ENDIF .


ENDFORM.
****↓---ADD 20230421 Kawano
**&---------------------------------------------------------------------*
**& Form FRM_CHK_COND
**&---------------------------------------------------------------------*
**& BAPIエラー時の行数設定、単価チェック
**& ダミー品目チェック & 品目会計期間チェック
**&---------------------------------------------------------------------*
FORM frm_chk_cond USING ith_bapisdhd1   LIKE th_bapisdhd1
                        itd_bapiparnr   LIKE td_bapiparnr
                        itd_bapisditm   LIKE td_bapisditm
                        itd_bapicond    LIKE td_bapicond
                        iw_line         LIKE w_line
                   CHANGING  otd_return LIKE td_return.

  DATA:lw_kbetr   TYPE konp-kbetr,
       lw_kbetr_c TYPE c LENGTH 50,
       lw_kbetr1  TYPE p LENGTH 13 DECIMALS 2,
       lw_kbetr2  TYPE p LENGTH 13 DECIMALS 2,
       lw_kpein   TYPE konp-kpein,
       lw_konwa   TYPE konp-konwa,
       lw_kunnr   TYPE knvv-kunnr,
       lw_line    TYPE i,
       lw_kunwe   TYPE knvv-kunnr,
       lw_count   TYPE i,
       lw_mtart   TYPE i,
       lw_kalks   TYPE knvv-kalks,
       lw_kschl   TYPE konp-kschl,
       lw_str     TYPE string,
       lw_bukrs   TYPE tvko-bukrs,
       lw_year    TYPE BAPI0002_4-FISCAL_YEAR,
       lw_period  TYPE BAPI0002_4-FISCAL_PERIOD,
       lw_flg_w   TYPE FLAG.

* 出荷先コードの取得
  READ TABLE itd_bapiparnr ASSIGNING FIELD-SYMBOL(<fs_partnr>) WITH KEY partn_role = 'WE'
                                                                        itm_number = '000000'.
  IF sy-subrc = 0.
    lw_kunwe = <fs_partnr>-partn_numb.
  ELSE.
    CLEAR lw_kunwe.
  ENDIF.

* 受注先コードの取得
  SELECT
    FROM knvp
   FIELDS kunnr
   WHERE kunnr <> @<fs_partnr>-partn_numb
     AND vkorg =  @ith_bapisdhd1-sales_org
     AND vtweg =  @ith_bapisdhd1-distr_chan
     AND spart =  @ith_bapisdhd1-division
     AND parvw =  'WE'
     AND kunn2 =  @<fs_partnr>-partn_numb
    INTO @lw_kunnr.
  ENDSELECT.

* 条件タイプの決定
  SELECT
    FROM knvv
  FIELDS kalks
   WHERE kunnr = @lw_kunnr
     AND vkorg = @ith_bapisdhd1-sales_org
     AND vtweg = @ith_bapisdhd1-distr_chan
     AND spart = @ith_bapisdhd1-division
    INTO @lw_kalks
      UP TO 1 ROWS.
  ENDSELECT.

  IF lw_kalks IS NOT INITIAL.
    lw_str = substring( val = lw_kalks off = strlen( lw_kalks ) - 1 len = 1 ).
  ENDIF.

  lw_kschl = 'ZPR' && lw_str.

  LOOP AT itd_bapisditm ASSIGNING FIELD-SYMBOL(<fs_item>).

    lw_count = lw_count + 1.
    lw_line = iw_line + lw_count.

*   BAPIエラー時の行数設定
    LOOP AT otd_return ASSIGNING FIELD-SYMBOL(<fs_return>) WHERE type = 'E'
                                                              OR type = 'A'.
      IF lw_count = 1 AND <fs_return>-row = '0'.
        <fs_return>-log_no = TEXT-003 && lw_line.
      ELSEIF lw_count = <fs_return>-row.
        <fs_return>-log_no = TEXT-003 && lw_line.
      ENDIF.
    ENDLOOP.

    CLEAR:lw_kbetr,lw_kpein,lw_konwa,th_return,lw_mtart.

*   ダミー品目の検索
    SELECT
      FROM mara
      FIELDS
           COUNT(*)
      WHERE matnr = @<fs_item>-material
        AND mtart IN @rd_dummy_mtart
       INTO @lw_mtart.

    IF sy-subrc = 0.
*     ダミー品目且つ、受注明細テキストが未入力の場合はワーニング
      IF <fs_item>-SHORT_TEXT IS INITIAL.
        th_return-type   = 'W'.
        th_return-id     = 'ZSD001'.
        th_return-number = '105'.
        th_return-log_no = TEXT-003 && lw_line.
        MESSAGE ID 'ZSD001' TYPE 'W' NUMBER 105 INTO th_return-message. "ダミー品目の明細に対し、受注明細テキスト(品名)が未入力です
        gs_pro_no-war = gs_pro_no-war + 1.
        APPEND th_return TO otd_return.

        LOOP AT otd_return ASSIGNING FIELD-SYMBOL(<fs_err_chk>) WHERE type = 'E'
                                                                   OR type = 'A'.
          EXIT.
        ENDLOOP.

        IF SY-SUBRC <> 0.
          lw_flg_w = 'X'.
          gs_pro_no-suc = gs_pro_no-suc - 1.
        ENDIF.
      ENDIF.

*     ダミー品目は単価チェック対象外
      CONTINUE.
    ENDIF.

*   販売伝票タイプがデビクレの場合、単価チェック対象外
    IF ith_bapisdhd1-doc_type IN rd_debicre.
      CONTINUE.
    ENDIF.

    READ TABLE itd_bapicond ASSIGNING FIELD-SYMBOL(<fs_cond>) WITH KEY itm_number = <fs_item>-itm_number.

    IF sy-subrc = 0.
*     単価マスタA920の取得
      SELECT
        FROM a920
       INNER JOIN konp
          ON konp~knumh = a920~knumh
       FIELDS
             konp~kbetr,  "金額
             konp~kpein,  "価格設定単位
             konp~konwa   "通貨
       WHERE a920~kappl = 'V'                        "アプリケーション
         AND a920~kschl =  @lw_kschl                 "条件タイプ
         AND a920~vkorg =  @ith_bapisdhd1-sales_org  "販売組織
         AND a920~vtweg =  @ith_bapisdhd1-distr_chan "流通チャネル
         AND a920~spart =  @ith_bapisdhd1-division   "製品部門
         AND a920~kunnr =  @lw_kunnr                 "受注先
         AND a920~kunwe =  @<fs_partnr>-partn_numb   "出荷先
         AND a920~vkaus =  @<fs_item>-dlvschduse     "用途
         AND a920~matnr =  @<fs_item>-material       "品目
         AND a920~datab <= @ith_bapisdhd1-req_date_h "有効開始日
         AND a920~datbi >= @ith_bapisdhd1-req_date_h "有効終了日
         AND konp~loevm_ko = @space
       ORDER BY konp~kopos DESCENDING
        INTO ( @lw_kbetr, @lw_kpein, @lw_konwa ).
      ENDSELECT.

      IF sy-subrc <> 0.
*       単価マスタA921の取得
        SELECT
          FROM a921
         INNER JOIN konp
            ON konp~knumh = a921~knumh
         FIELDS
               konp~kbetr,  "金額
               konp~kpein,  "価格設定単位
               konp~konwa   "通貨
         WHERE a921~kappl = 'V'                        "アプリケーション
           AND a921~kschl =  @lw_kschl                 "条件タイプ
           AND a921~vkorg =  @ith_bapisdhd1-sales_org  "販売組織
           AND a921~vtweg =  @ith_bapisdhd1-distr_chan "流通チャネル
           AND a921~spart =  @ith_bapisdhd1-division   "製品部門
           AND a921~kunnr =  @lw_kunnr                 "受注先
           AND a921~kunwe =  @<fs_partnr>-partn_numb   "出荷先
           AND a921~matnr =  @<fs_item>-material       "品目
           AND a921~datab <= @ith_bapisdhd1-req_date_h "有効開始日
           AND a921~datbi >= @ith_bapisdhd1-req_date_h "有効終了日
           AND konp~loevm_ko = @space
         ORDER BY konp~kopos DESCENDING
          INTO ( @lw_kbetr, @lw_kpein, @lw_konwa ).
        ENDSELECT.

        IF sy-subrc <> 0.
*         単価マスタA922の取得
          SELECT
            FROM a922
           INNER JOIN konp
              ON konp~knumh = a922~knumh
           FIELDS
                 konp~kbetr,  "金額
                 konp~kpein,  "価格設定単位
                 konp~konwa   "通貨
           WHERE a922~kappl = 'V'                        "アプリケーション
             AND a922~kschl =  @lw_kschl                 "条件タイプ
             AND a922~vkorg =  @ith_bapisdhd1-sales_org  "販売組織
             AND a922~vtweg =  @ith_bapisdhd1-distr_chan "流通チャネル
             AND a922~spart =  @ith_bapisdhd1-division   "製品部門
             AND a922~kunnr =  @lw_kunnr                 "受注先
             AND a922~vkaus =  @<fs_item>-dlvschduse     "用途
             AND a922~matnr =  @<fs_item>-material       "品目
             AND a922~datab <= @ith_bapisdhd1-req_date_h "有効開始日
             AND a922~datbi >= @ith_bapisdhd1-req_date_h "有効終了日
             AND konp~loevm_ko = @space
           ORDER BY konp~kopos DESCENDING
            INTO ( @lw_kbetr, @lw_kpein, @lw_konwa ).
          ENDSELECT.
        ENDIF.
      ENDIF.

      IF lw_kbetr IS NOT INITIAL AND
         lw_kpein IS NOT INITIAL AND
         lw_konwa IS NOT INITIAL.
*      単価マスタ有りの場合
*      取込みファイルの単価とマスタの単価を比較し差異がある場合は警告メッセージを設定

        WRITE lw_kbetr CURRENCY lw_konwa TO lw_kbetr_c.
        REPLACE ALL OCCURRENCES OF ',' IN lw_kbetr_c WITH ''.
        lw_kbetr1 = lw_kbetr_c.
        lw_kbetr2 = <fs_cond>-cond_value.

        IF lw_kbetr1 <> lw_kbetr2 OR
           lw_kpein  <> <fs_cond>-cond_p_unt OR
           lw_konwa  <> <fs_cond>-currency.

          th_return-type   = 'W'.
          th_return-id     = 'ZSD001'.
          th_return-number = '042'.
          th_return-log_no = TEXT-003 && lw_line.
          MESSAGE ID 'ZSD001' TYPE 'W' NUMBER 042 INTO th_return-message. "条件マスタと登録単価に差異があります
*↓20240229 ADD kawano
          gs_pro_no-war = gs_pro_no-war + 1.
*↑20240229 ADD kawano
          th_return-message_v1   = TEXT-004 && TEXT-007 && lw_kbetr1 && TEXT-008 && lw_kbetr2.
          th_return-message_v2   = TEXT-005 && TEXT-007 && lw_kpein && TEXT-008 && <fs_cond>-cond_p_unt.
          th_return-message_v3   = TEXT-006 && TEXT-007 && lw_konwa && TEXT-008 && <fs_cond>-currency.
          APPEND th_return TO otd_return.

          LOOP AT otd_return ASSIGNING FIELD-SYMBOL(<fs_err_chk1>) WHERE type = 'E'
                                                                     OR type = 'A'.
            EXIT.
          ENDLOOP.

          IF SY-SUBRC <> 0 AND lw_flg_w IS INITIAL.
            lw_flg_w = 'X'.
            gs_pro_no-suc = gs_pro_no-suc - 1.
          ENDIF.

        ENDIF.
      ELSE.
*       単価マスタ無しの場合
        th_return-type   = 'W'.
        th_return-id     = 'ZSD001'.
        th_return-number = '043'.
        th_return-log_no = TEXT-003 && lw_line.
        MESSAGE ID 'ZSD001' TYPE 'W' NUMBER 043 INTO th_return-message. "条件マスタが存在しません
*↓20240229 ADD kawano
        gs_pro_no-war = gs_pro_no-war + 1.
*↑20240229 ADD kawano
        APPEND th_return TO otd_return.

        LOOP AT otd_return ASSIGNING FIELD-SYMBOL(<fs_err_chk2>) WHERE type = 'E'
                                                                   OR type = 'A'.
          EXIT.
        ENDLOOP.

        IF SY-SUBRC <> 0 AND lw_flg_w IS INITIAL.
          lw_flg_w = 'X'..
          gs_pro_no-suc = gs_pro_no-suc - 1.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDLOOP.

*--- 請求日チェック
* 会社コード取得
  SELECT
    FROM TVKO
  FIELDS bukrs
   WHERE vkorg = @ith_bapisdhd1-SALES_ORG
    INTO @lw_bukrs
      UP TO 1 ROWS.
  ENDSELECT.

* 請求日から会計期間取得
  CALL FUNCTION 'BAPI_COMPANYCODE_GET_PERIOD'
    EXPORTING
      companycodeid       = lw_bukrs
      posting_date        = ith_bapisdhd1-REQ_DATE_H
    IMPORTING
      FISCAL_YEAR         = lw_year
      FISCAL_PERIOD       = lw_period.

* 請求日が品目会計期間内かチェック
  SELECT
    FROM MARV
  FIELDS COUNT(*)
   WHERE bukrs = @lw_bukrs
     AND ( ( LFGJA = @lw_year AND LFMON = @lw_period AND XRUEM IS INITIAL  )
         OR ( ( ( LFGJA > @lw_year ) OR ( LFGJA = @lw_year AND LFMON >= @lw_period ) )
              AND ( ( VMGJA < @lw_year ) OR ( VMGJA = @lw_year AND VMMON <= @lw_period ) )
              AND XRUEM IS NOT INITIAL ) )
    INTO @lw_count.

  IF SY-SUBRC <> 0.
*    lw_line = iw_line + 1.
    CLEAR th_return.
    th_return-type   = 'W'.
    th_return-id     = 'ZSD001'.
    th_return-number = '104'.
    th_return-log_no = TEXT-003 && lw_line.
    th_return-MESSAGE_V1 = ith_bapisdhd1-REQ_DATE_H.
    MESSAGE ID 'ZSD001' TYPE 'W' NUMBER 104 WITH ith_bapisdhd1-REQ_DATE_H INTO th_return-message. "指定納期が品目会計期間外です 指定納期:&1
    gs_pro_no-war = gs_pro_no-war + 1.
    APPEND th_return TO otd_return.

    LOOP AT otd_return ASSIGNING FIELD-SYMBOL(<fs_err_chk3>) WHERE type = 'E'
                                                                OR type = 'A'.
      EXIT.
    ENDLOOP.

    IF SY-SUBRC <> 0.
      IF lw_flg_w IS INITIAL AND lw_flg_w IS INITIAL.
        lw_flg_w = 'X'..
        gs_pro_no-suc = gs_pro_no-suc - 1.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
****↑---ADD 20230421 Kawano
*&---------------------------------------------------------------------*
*& Form get_fields_domain
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> L_HELP_NAME1
*&      --> L_HELP_NAME2
*&      <-- L_HELP_DOMAIN
*&---------------------------------------------------------------------*
FORM get_fields_domain  USING    i_tabname  TYPE string
                                 i_FIELDNAME TYPE string
                        CHANGING o_domain TYPE domname .


  DATA : l_tabname   TYPE ddobjname,
         l_FIELDNAME TYPE dfies-fieldname.

  DATA : lt_DFIES TYPE STANDARD TABLE OF dfies .

  CLEAR o_domain .

  l_tabname  = i_tabname  .
  l_FIELDNAME = i_FIELDNAME .


  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = l_tabname
      fieldname      = l_FIELDNAME
      langu          = sy-langu
*     LFIELDNAME     = ' '
*     ALL_TYPES      = ' '
*     GROUP_NAMES    = ' '
*     UCLEN          =
*     DO_NOT_WRITE   = ' '
* IMPORTING
*     X030L_WA       =
*     DDOBJTYPE      =
*     DFIES_WA       =
*     LINES_DESCR    =
    TABLES
      dfies_tab      = lt_DFIES
*     FIXED_VALUES   =
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.

  IF sy-subrc <> 0.
* Implement suitble error handling here
  ELSE .

    READ TABLE lt_DFIES ASSIGNING FIELD-SYMBOL(<lfs_dfies>) INDEX 1 .

    o_domain = <lfs_dfies>-domname .

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_incomplet_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_BAPIINCOMP
*&      <-- LT_RETURN
*&---------------------------------------------------------------------*
FORM append_incomplet_log  USING    it_bapiincomp TYPE typ_t_BAPIINCOMP
                           CHANGING ct_return TYPE bapiret2_tt .


  DATA ls_return  TYPE bapiret2 .

  IF it_bapiincomp IS NOT INITIAL .
    LOOP AT it_bapiincomp ASSIGNING FIELD-SYMBOL(<lfs_incomp>) .

      CLEAR ls_return .

      ls_return-type = 'E' .
      ls_return-id = 'ZCV001' .
      ls_return-number = '014' .
*--
      MESSAGE e014(zcv001)
               INTO ls_return-message .
* 受注伝票不完全 &1 &2 &3 &4

      ls_return-message_v1  = <lfs_incomp>-itm_number .
      ls_return-message_v2 = <lfs_incomp>-table_name .
      ls_return-message_v3 = <lfs_incomp>-field_name .
      ls_return-message_v4 = <lfs_incomp>-field_text .

*----******* read row number
      read TABLE ct_return ASSIGNING FIELD-SYMBOL(<lfs_return>)
                               with key message_v2 = <lfs_incomp>-itm_number
                                        parameter = 'SALES_ITEM_IN'.

       if sy-subrc = 0 .
        ls_return-row =  <lfs_return>-row .
       endif .

      APPEND ls_return TO ct_return .

    ENDLOOP.

  ENDIF .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_CHK_KPEIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_BAPICOND
*&      <-- LT_RETURN
*&      <-- LW_ERRFLG
*&---------------------------------------------------------------------*
FORM frm_chk_kpein  USING    itd_bapicond LIKE td_bapicond
                    CHANGING otd_return LIKE td_return
                             ow_errflg TYPE FLAG.

  DATA:lw_line    TYPE i,
       lth_return TYPE bapiret2 .

  CLEAR ow_errflg.

  LOOP AT itd_bapicond ASSIGNING FIELD-SYMBOL(<FS_COND>).

    lw_line = lw_line + 1.

    IF <FS_COND>-COND_P_UNT <> 100.
      ow_errflg = 'X'.

      lth_return-type   = 'E' .
      lth_return-id     = 'ZCV001' .
      lth_return-number = '015' .
      lth_return-row    = lw_line.

      MESSAGE e015(zcv001)
               INTO lth_return-message .

      APPEND lth_return TO otd_return .

    ENDIF.

  ENDLOOP.

ENDFORM.
