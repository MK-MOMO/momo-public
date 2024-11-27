*&---------------------------------------------------------------------*
*& Report  ZS42102R1000                                                  *
*&---------------------------------------------------------------------*
*& Author............: LJ
*& Creation date.....: YYYY/MM/DD
*&----------------------------------------------------------------------
*& CHANGE HISTORY -
*& Revised by........: XXXXXXXXXXXXX
*& Change date.......: XXXXXXXXXXXXX
*& Change no.........: XXXXXXXXXXXXX
*& Description.......: Object to Maitain any Custom Table
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& All rights reserved with QUNIE CORPORATION .
*& No part of this Code may be copied or transmitted in any form or
*& for any purpose without the express permission of
*& QUNIE CORPORATION .
*&---------------------------------------------------------------------*

REPORT ztestk0013 MESSAGE-ID zut001 .

*---------------------------------------------------------------------*
*       CONSTANTS
*---------------------------------------------------------------------*
CONSTANTS :
  BEGIN OF cns_xml,
    sheet  TYPE i VALUE 2,
    shared TYPE i VALUE 3,
  END OF cns_xml.
*---------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
* §5.1 define a local class for handling events of cl_salv_table
*---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events_table
        IMPORTING e_salv_function.

*    METHODS:
*      on_double_click FOR EVENT double_click OF cl_salv_events_table
*        IMPORTING node_key columnname .

*
*    METHODS:
*      on_link_click FOR EVENT link_click OF cl_salv_events_table
*        IMPORTING  columnname node_key .


ENDCLASS.                    "lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
* §5.2 implement the events for handling the events of cl_salv_table
*---------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.

*--user command

  METHOD on_user_command.
    CASE e_salv_function .

      WHEN 'DOWN'.

        PERFORM download_to_local_xls .

      WHEN 'UPLOAD'.

        PERFORM upload_local_file .


      WHEN 'CHECK'.

        PERFORM check_update_mode  .


      WHEN 'POST'.

        PERFORM post_to_db  .


      WHEN 'REFRESH'.

        PERFORM refresh USING 'X' .


    ENDCASE .

  ENDMETHOD.                    "on_user_command


**--double click
*  METHOD on_double_click  .
*
*    PERFORM double_click_items USING node_key columnname .
*
*  ENDMETHOD.
*
**--double click
*  METHOD on_link_click  .
*
*    PERFORM link_click_items USING node_key columnname .
*
*  ENDMETHOD.

ENDCLASS.                    "lcl_handle_events IMPLEMENTATION

*&---------------------------------------------------------------------*
*&*Type Definition
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
*&*Data Definition
*&---------------------------------------------------------------------*


TABLES : sscrfields.


DATA :
  g_where_clauses TYPE string,
  gt_fields       TYPE STANDARD TABLE OF rsdsfields,
  g_slset         TYPE sy-slset,
  gflg_fack       TYPE flag,
  gflg_go         TYPE flag.


DATA :
  gt_table_key     TYPE string_table,
  gflg_check_error TYPE flag.


DATA:

  gr_table           TYPE REF TO cl_salv_table,
  gr_events          TYPE REF TO lcl_handle_events,
  gr_utility_factory TYPE REF TO zcl_S42102_utility_factory.


DATA : BEGIN OF gs_screen,
         s01 TYPE char50,
         s02 TYPE char50,
         s03 TYPE char50,
         s04 TYPE char50,
         s05 TYPE char50,
         s06 TYPE char50,
         s07 TYPE char50,
         s08 TYPE char50,
         s09 TYPE char50,
         s10 TYPE char50,
         s11 TYPE char50,
         s12 TYPE char50,
         s13 TYPE char50,
         s14 TYPE char50,
         s15 TYPE char50,
         s16 TYPE char50,
         s17 TYPE char50,
         s18 TYPE char50,
         s19 TYPE char50,
         s20 TYPE char50,
         s21 TYPE char50,
         s22 TYPE char50,
         s23 TYPE char50,
         s24 TYPE char50,
         s25 TYPE char50,
         s26 TYPE char50,
         s27 TYPE char50,
         s28 TYPE char50,
         s29 TYPE char50,
         s30 TYPE char50,
       END OF gs_screen .

FIELD-SYMBOLS :
  <gfs_t_alv>   TYPE STANDARD TABLE,
  <gfs_t_excel> TYPE STANDARD TABLE.




*&---------------------------------------------------------------------*
*&*Parameters
*&---------------------------------------------------------------------*
*---Execution mode
SELECTION-SCREEN: BEGIN OF BLOCK s10 WITH FRAME TITLE TEXT-s10.
*---disply and update
  PARAMETERS : p_disp RADIOBUTTON GROUP r01 DEFAULT 'X'.
  PARAMETERS : p_upda RADIOBUTTON GROUP r01 .

SELECTION-SCREEN END OF BLOCK s10 .


SELECTION-SCREEN BEGIN OF BLOCK s20 WITH FRAME TITLE TEXT-s20.
  PARAMETERS: p_tabnam TYPE tabname16 OBLIGATORY MODIF ID x01 .
SELECTION-SCREEN END OF BLOCK s20 .


SELECTION-SCREEN FUNCTION KEY 1 .


SELECTION-SCREEN FUNCTION KEY 3 .


*selection scree for dynamic feilds
SELECTION-SCREEN BEGIN OF BLOCK b30 WITH FRAME TITLE TEXT-s30 .
  SELECT-OPTIONS :
   so_01 FOR (gs_screen-s01) MODIF ID m01 ,
   so_02 FOR (gs_screen-s02) MODIF ID m02 ,
   so_03 FOR (gs_screen-s03) MODIF ID m03 ,
   so_04 FOR (gs_screen-s04) MODIF ID m04 ,
   so_05 FOR (gs_screen-s05) MODIF ID m05 ,
   so_06 FOR (gs_screen-s06) MODIF ID m06 ,
   so_07 FOR (gs_screen-s07) MODIF ID m07  ,
   so_08 FOR (gs_screen-s08) MODIF ID m08  ,
   so_09 FOR (gs_screen-s09) MODIF ID m09  ,
   so_10 FOR (gs_screen-s10) MODIF ID m10  ,
   so_11 FOR (gs_screen-s11) MODIF ID m11  ,
   so_12 FOR (gs_screen-s12) MODIF ID m12  ,
   so_13 FOR (gs_screen-s13) MODIF ID m13  ,
   so_14 FOR (gs_screen-s14) MODIF ID m14  ,
   so_15 FOR (gs_screen-s15) MODIF ID m15  ,
   so_16 FOR (gs_screen-s16) MODIF ID m16  ,
   so_17 FOR (gs_screen-s17) MODIF ID m17  ,
   so_18 FOR (gs_screen-s18) MODIF ID m18  ,
   so_19 FOR (gs_screen-s19) MODIF ID m19  ,
   so_20 FOR (gs_screen-s20) MODIF ID m20  ,
   so_21 FOR (gs_screen-s21) MODIF ID m21  ,
   so_22 FOR (gs_screen-s22) MODIF ID m22  ,
   so_23 FOR (gs_screen-s23) MODIF ID m23  ,
   so_24 FOR (gs_screen-s24) MODIF ID m24  ,
   so_25 FOR (gs_screen-s25) MODIF ID m25  ,
   so_26 FOR (gs_screen-s26) MODIF ID m26  ,
   so_27 FOR (gs_screen-s27) MODIF ID m27  ,
   so_28 FOR (gs_screen-s28) MODIF ID m28  ,
   so_29 FOR (gs_screen-s29) MODIF ID m29  ,
   so_30 FOR (gs_screen-s30) MODIF ID m30  .
SELECTION-SCREEN END OF BLOCK b30 .



*---set up dummy parameters for catch up varient
PARAMETERS  :
  pa_01 TYPE string NO-DISPLAY,
  pa_02 TYPE string NO-DISPLAY,
  pa_03 TYPE string NO-DISPLAY,
  pa_04 TYPE string NO-DISPLAY,
  pa_05 TYPE string NO-DISPLAY,
  pa_06 TYPE string NO-DISPLAY,
  pa_07 TYPE string NO-DISPLAY,
  pa_08 TYPE string NO-DISPLAY,
  pa_09 TYPE string NO-DISPLAY,
  pa_10 TYPE string NO-DISPLAY,
  pa_11 TYPE string NO-DISPLAY,
  pa_12 TYPE string NO-DISPLAY,
  pa_13 TYPE string NO-DISPLAY,
  pa_14 TYPE string NO-DISPLAY,
  pa_15 TYPE string NO-DISPLAY,
  pa_16 TYPE string NO-DISPLAY,
  pa_17 TYPE string NO-DISPLAY,
  pa_18 TYPE string NO-DISPLAY,
  pa_19 TYPE string NO-DISPLAY,
  pa_20 TYPE string NO-DISPLAY,
  pa_21 TYPE string NO-DISPLAY,
  pa_22 TYPE string NO-DISPLAY,
  pa_23 TYPE string NO-DISPLAY,
  pa_24 TYPE string NO-DISPLAY,
  pa_25 TYPE string NO-DISPLAY,
  pa_26 TYPE string NO-DISPLAY,
  pa_27 TYPE string NO-DISPLAY,
  pa_28 TYPE string NO-DISPLAY,
  pa_29 TYPE string NO-DISPLAY,
  pa_30 TYPE string NO-DISPLAY.



*###############################################################
* AT SELECTION-SCREEN
*###############################################################
INITIALIZATION .

  sscrfields-functxt_01 = TEXT-s00.

  sscrfields-functxt_03 = TEXT-s01.

  IMPORT gt_fields FROM MEMORY ID 'FC01'.

  IF sy-subrc = 0 .
    FREE MEMORY ID 'FC01'.
  ENDIF .

  IMPORT g_slset FROM MEMORY ID 'FC02' .

  IF sy-subrc = 0 .

    sy-slset = g_slset.

    FREE MEMORY ID 'FC02' .
  ENDIF .


*###############################################################
* AT SELECTION-SCREEN OUTPUT
*###############################################################
AT SELECTION-SCREEN OUTPUT .

  DATA :
    lctr_nn  TYPE num2.

  DATA :
    lref TYPE REF TO data .

  DATA :
    1_sel_addr  TYPE string,
    l_par_addr  TYPE string,
    l_par_value TYPE string.

  FIELD-SYMBOLS :
        <lfs_par> TYPE any .

  DATA :
    ls_fields TYPE rsdsfields .
  DATA :
    lrd_sname TYPE RANGE OF  screen-name,
    lr_sname  LIKE LINE OF lrd_sname.

  FIELD-SYMBOLS :
    <lfs_fields> TYPE rsdsfields,
    <lfs_comp>   TYPE any.

*----
  LOOP AT SCREEN .
*----if variant comes then
    IF screen-group1 <> 'X01'
      AND  screen-group1 CP 'M*' .
*----hide all first
      screen-input = '0' .
      screen-output = '0' .
      screen-invisible = '1' .
      screen-active = '0' .
      MODIFY SCREEN .
    ENDIF .
  ENDLOOP .

  CLEAR :  lctr_nn .

*---when variant selected .
  IF sy-slset IS NOT INITIAL .
    CLEAR gt_fields .
    DO 30 TIMES .
      lctr_nn = lctr_nn + 1 .
*---set up to paramaters
      CONCATENATE 'PA_'
                 lctr_nn
             INTO l_par_addr .
      ASSIGN (l_par_addr) TO <lfs_par> .

      IF <lfs_par> IS NOT INITIAL .

        SPLIT <lfs_par>
           AT '-'
           INTO ls_fields-tablename
                ls_fields-fieldname .

        APPEND ls_fields TO gt_fields .
      ENDIF .

    ENDDO.

    IF g_slset <> sy-slset .

      CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
        EXPORTING
          functioncode           = '=FC02'
        EXCEPTIONS
          function_not_supported = 1
          OTHERS                 = 2.

      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      g_slset = sy-slset .
    ENDIF .


  ELSE .

*--new select had comming clear old parameter values
    IF gt_fields IS NOT INITIAL .
      DO 30 TIMES .
        lctr_nn = lctr_nn + 1 .
        CONCATENATE 'PA_'
                   lctr_nn
               INTO l_par_addr .
        ASSIGN (l_par_addr) TO <lfs_par> .
        CLEAR <lfs_par>.
      ENDDO .
    ENDIF .
  ENDIF .


  CHECK gt_fields IS NOT INITIAL .
  CLEAR lctr_nn .
  LOOP AT gt_fields ASSIGNING <lfs_fields> .

*---idoc segment assign
    CONCATENATE <lfs_fields>-tablename
                '-'
                <lfs_fields>-fieldname
           INTO  1_sel_addr   .

    lctr_nn = lctr_nn + 1 .

*---set up to paramaters
    CONCATENATE 'PA_'
               lctr_nn
           INTO l_par_addr .
    ASSIGN (l_par_addr) TO <lfs_par> .

    <lfs_par>  = 1_sel_addr .

    ASSIGN COMPONENT lctr_nn  OF STRUCTURE gs_screen TO <lfs_comp> .

    IF sy-subrc = 0 .

      <lfs_comp>  = <lfs_par> .
      CLEAR lr_sname.
      lr_sname-sign = 'I' .
      lr_sname-option = 'EQ' .
      CONCATENATE 'M'
                  lctr_nn
             INTO lr_sname-low .
      APPEND lr_sname TO lrd_sname .
    ELSE .
      EXIT .
    ENDIF .
  ENDLOOP.


  LOOP AT SCREEN .
*--keep blcok .
    IF  screen-group3 = 'BLK' .
      CONTINUE .
    ENDIF.

    IF screen-group1 <> 'X01'
      AND screen-group1 IN lrd_sname .
*----show
      screen-input = '1' .
      screen-output = '1' .
      screen-invisible = '0' .
*      screen-INTENSIFIED = '1' .
      screen-active = '1' .
      MODIFY SCREEN .
    ENDIF .
  ENDLOOP .

*↓ADD 20240318 河野
* 置場マスタ限定ロジック-選択画面項目の参照先を専用の構造に変更
  IF p_tabnam = 'ZSDT0003'.
    DATA: LW_COUNT TYPE N LENGTH 2,
          LW_FIELD TYPE FIELDNAME.

    FIELD-SYMBOLS: <FS_FLD>  TYPE ANY.

    DO 30 TIMES.
      LW_COUNT = LW_COUNT + 1.
      LW_FIELD = 'GS_SCREEN-S' && LW_COUNT.

      ASSIGN (LW_FIELD) TO <FS_FLD>.

      IF <FS_FLD> IS ASSIGNED.
        REPLACE ALL OCCURRENCES OF 'ZSDT0003' IN <FS_FLD> WITH 'ZSDS0016'.
      ENDIF.
    ENDDO.
  ENDIF.
*↑ADD 20240318 河野


*&---------------------------------------------------------------------*
*&*AT SELECTION-SCREEN ..
*&---------------------------------------------------------------------*

AT SELECTION-SCREEN .

  CASE sscrfields-ucomm .
    WHEN 'FC01' .

*---no more variant
      CLEAR : sy-slset,
       g_slset .

      IF gt_fields IS NOT INITIAL .
        sscrfields-ucomm = 'ONLI' .
        gflg_fack = 'X' .

      ENDIF .

      PERFORM trigger_free_selection_dialog  .

    WHEN 'FC02' .

*---variant
      CLEAR gt_fields  .
      sscrfields-ucomm = 'ONLI' .
      gflg_fack = 'X' .


    WHEN 'FC03' .


      PERFORM download_template_excel .

    WHEN OTHERS .

  ENDCASE .


*---
  IF p_tabnam+0(1) <> 'Z' AND
     p_tabnam+0(1) <> 'Y' .

    MESSAGE e007.
*   only custom table can be maitained .
  ENDIF .


*---
  SELECT COUNT(*)
     FROM dd02l
     WHERE tabname = p_tabnam
      AND  as4local = 'A'
      AND tabclass =  'TRANSP' .

*--
  IF sy-dbcnt = 0 .
    MESSAGE e008.
*   Entry not exist, please check again .
  ENDIF.


*&---------------------------------------------------------------------*
*&*FORM routine
*&---------------------------------------------------------------------*
FORM trigger_free_selection_dialog  .

  DATA : l_selid   TYPE rsdynsel-selid,
         lt_tables TYPE STANDARD TABLE OF  rsdstabs,
         ls_tables TYPE  rsdstabs.

*---
  CLEAR ls_tables .
  ls_tables-prim_tab = p_tabnam .

*↓ADD 20240318 河野
* 置場マスタ限定ロジック-選択画面項目の参照先を専用の構造に変更
  IF p_tabnam = 'ZSDT0003'.
    ls_tables-prim_tab = 'ZSDS0016' .
  ENDIF.
*↑ADD 20240318 河野

  APPEND ls_tables TO lt_tables .

  CALL FUNCTION 'FREE_SELECTIONS_INIT'
    EXPORTING
      kind                     = 'T'
*     EXPRESSIONS              =
*     FIELD_RANGES_INT         =
*     FIELD_GROUPS_KEY         =
*     RESTRICTION              =
*     ALV                      =
*     CURR_QUAN_PROG           = SY-CPROG
*     CURR_QUAN_RELATION       =
    IMPORTING
      selection_id             = l_selid
*     WHERE_CLAUSES            =
*     EXPRESSIONS              =
*     FIELD_RANGES             =
*     NUMBER_OF_ACTIVE_FIELDS  =
    TABLES
      tables_tab               = lt_tables
*     TABFIELDS_NOT_DISPLAY    =
      fields_tab               = gt_fields
*     FIELD_DESC               =
*     FIELD_TEXTS              =
*     EVENTS                   =
*     EVENT_FIELDS             =
*     FIELDS_NOT_SELECTED      =
*     NO_INT_CHECK             =
*     ALV_QINFO                =
    EXCEPTIONS
      fields_incomplete        = 1
      fields_no_join           = 2
      field_not_found          = 3
      no_tables                = 4
      table_not_found          = 5
      expression_not_supported = 6
      incorrect_expression     = 7
      illegal_kind             = 8
      area_not_found           = 9
      inconsistent_area        = 10
      kind_f_no_fields_left    = 11
      kind_f_no_fields         = 12
      too_many_fields          = 13
      dup_field                = 14
      field_no_type            = 15
      field_ill_type           = 16
      dup_event_field          = 17
      node_not_in_ldb          = 18
      area_no_field            = 19
      OTHERS                   = 20.

  IF sy-subrc <> 0.
* Implement suitable error handling here
    RETURN .
  ENDIF.

  CLEAR gt_fields .

  CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
    EXPORTING
      selection_id    = l_selid
      title           = 'SelectFields'
*     FRAME_TEXT      = ' '
*     STATUS          =
      as_window       = 'X'
      start_row       = 3
      start_col       = 4
*     NO_INTERVALS    = ' '
*     JUST_DISPLAY    = ''
*     PFKEY           =
*     ALV             = ' '
*     TREE_VISIBLE    = 'X'
*     DIAG_TEXT_1     =
*     DIAG_TEXT_2     =
*     WARNING_TITLE   =
*     AS_SUBSCREEN    = ' '
*     NO_FRAME        =
*    IMPORTING
*     where_clauses   = g_where_clauses
*     EXPRESSIONS     =
*     FIELD_RANGES    =
*     NUMBER_OF_ACTIVE_FIELDS       =
    TABLES
      fields_tab      = gt_fields
*     FCODE_TAB       =
*     FIELDS_NOT_SELECTED        =
    EXCEPTIONS
      internal_error  = 1
      no_action       = 2
      selid_not_found = 3
      illegal_status  = 4
      OTHERS          = 5.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF .

ENDFORM .                    "trigger_free_selection_dialog
*&---------------------------------------------------------------------*
*&*start-of-selection.
*&---------------------------------------------------------------------*
START-OF-SELECTION .


  EXPORT gt_fields TO MEMORY ID 'FC01'.

  EXPORT g_slset TO MEMORY ID 'FC02' .

  IF  gflg_fack IS NOT  INITIAL .
    CLEAR  gflg_fack .
    RETURN .
  ENDIF .


  PERFORM init_proc .


  PERFORM build_output_data.


  PERFORM display_fullscreen .


  PERFORM end_proc.

*&---------------------------------------------------------------------*
*&      Form  BUILD_OUTPUT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_output_data .


  CHECK gflg_go IS NOT INITIAL .

*---
  PERFORM build_output_dynamic_table .


*---
  PERFORM build_where_clause .


*---
  PERFORM extract_output_data .



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BUILD_OUTPUT_DYNAMIC_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_output_dynamic_table .

*--get table structure .
  DATA :
    l_name   TYPE ddobjname,
    lt_dd03p TYPE STANDARD TABLE OF dd03p.

  l_name = p_tabnam.

  DATA :
    lt_datatyp   TYPE string_table,
    lt_fieldname TYPE string_table.


  FIELD-SYMBOLS <lfs_dd03p> TYPE dd03p .

  DATA :
    lref_tab TYPE REF TO data,
    lref_str TYPE REF TO data.

  DATA :
    l_subrc TYPE sy-subrc .


*--check again for template down .
  SELECT COUNT(*)
      FROM dd02l
      WHERE tabname = p_tabnam
       AND  as4local = 'A'
       AND tabclass =  'TRANSP' .

*--
  IF sy-dbcnt = 0 .
    RETURN .
  ENDIF.


*---
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = l_name
*     STATE         = 'A'
*     LANGU         = ' '
* IMPORTING
*     GOTSTATE      =
*     DD02V_WA      =
*     DD09L_WA      =
    TABLES
      dd03p_tab     = lt_dd03p
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    RETURN .
  ENDIF.



*---add mode first .
  APPEND 'MODE' TO lt_fieldname .
  APPEND 'ZS42102EUPMOD' TO  lt_datatyp   .

*--
  LOOP AT lt_dd03p ASSIGNING <lfs_dd03p> .

*--no need MANDT .
    IF <lfs_dd03p>-fieldname = 'MANDT' .
      CONTINUE .
    ENDIF .

    IF <lfs_dd03p>-rollname IS NOT INITIAL .

      APPEND <lfs_dd03p>-fieldname TO lt_fieldname .
      APPEND <lfs_dd03p>-rollname TO lt_datatyp .
    ENDIF .

*--keep key field in global veriables
    IF <lfs_dd03p>-keyflag IS NOT INITIAL .

      APPEND <lfs_dd03p>-fieldname TO gt_table_key  .

    ENDIF .

  ENDLOOP.


*--
  IF gr_utility_factory IS INITIAL .
    CREATE OBJECT gr_utility_factory.
  ENDIF .

  CALL METHOD gr_utility_factory->create_dynamic_table
    EXPORTING
      i_t_datatype  = lt_datatyp
      i_t_fieldname = lt_fieldname
    IMPORTING
      o_ref_tab     = lref_tab
      o_ref_str     = lref_str
      o_subrc       = l_subrc.


*---
  IF l_subrc =  0 .

    ASSIGN lref_tab->* TO <gfs_t_excel> .

  ENDIF .


*---create ALV table .
*---add check flag and message field also .
*  APPEND 'ICON' TO lt_fieldname .
*  APPEND 'ICON_D' TO  lt_datatyp .

  insert 'ICON' into lt_fieldname INDEX 1 .
  insert 'ICON_D' inTO  lt_datatyp index 1 .


  CLEAR : lref_tab,
          lref_str,
          l_subrc .

  CALL METHOD gr_utility_factory->create_dynamic_table
    EXPORTING
      i_t_datatype  = lt_datatyp
      i_t_fieldname = lt_fieldname
    IMPORTING
      o_ref_tab     = lref_tab
      o_ref_str     = lref_str
      o_subrc       = l_subrc.

*--
  IF l_subrc =  0 .

    ASSIGN lref_tab->* TO <gfs_t_alv> .

  ENDIF .


ENDFORM.
*&---------------------------------------------------------------------*
*&      build_where_clause
*&---------------------------------------------------------------------*
FORM build_where_clause  .

  DATA lctr_nn TYPE num2 .


  DATA : l_tablename TYPE string,
         l_fieldname TYPE string.
*---
  DATA : l_par_addr TYPE string,
         l_sel_addr TYPE string.

  FIELD-SYMBOLS <lfs_par> TYPE any.

  CLEAR g_where_clauses  .


  DO 30 TIMES .

    lctr_nn = lctr_nn + 1 .
*---
    CONCATENATE 'PA_'
                lctr_nn
           INTO l_par_addr .

*---
    CONCATENATE 'SO_'
                lctr_nn
           INTO l_sel_addr .


    ASSIGN (l_par_addr) TO <lfs_par> .
*---
    IF <lfs_par> IS NOT INITIAL .

      CLEAR:  l_tablename,
              l_fieldname .
*---
      SPLIT <lfs_par>
        AT  '-'
        INTO l_tablename
             l_fieldname .



      IF g_where_clauses IS INITIAL .

        CONCATENATE  l_fieldname
                     'IN'
                     l_sel_addr
                INTO g_where_clauses SEPARATED BY space .

      ELSE .

        CONCATENATE g_where_clauses
                   'AND'
                   l_fieldname
                   'IN'
                   l_sel_addr
             INTO  g_where_clauses SEPARATED BY space .

      ENDIF .
    ELSE .

      EXIT .
    ENDIF .
  ENDDO .
ENDFORM .                    "build_where_clause
*&---------------------------------------------------------------------*
*&      Form  extract_output_data
*&---------------------------------------------------------------------*
FORM extract_output_data .

  FIELD-SYMBOLS :
    <lfs_table_data> TYPE STANDARD TABLE,
    <lfs_str_data>   TYPE any,
    <lfs_comp>       TYPE any.

  FIELD-SYMBOLS :
          <lfs_s_alv> TYPE any .


  DATA lref_table TYPE REF TO data.
  DATA lref_str TYPE REF TO data .
  DATA lref TYPE REF TO data .



  CREATE DATA lref_table TYPE STANDARD TABLE OF (p_tabnam) .
  CREATE DATA lref_str TYPE  (p_tabnam) .


*--
  ASSIGN lref_table->* TO <lfs_table_data> .
  ASSIGN lref_str->* TO <lfs_str_data> .



  SELECT *
    FROM (p_tabnam)
    INTO CORRESPONDING FIELDS OF TABLE <lfs_table_data>
    WHERE (g_where_clauses) .

*--
  IF sy-subrc <> 0 .

    IF p_disp IS NOT INITIAL .

      MESSAGE s004(zgg01).
*   No data found Error, Please check agian
      RETURN .

    ELSE .

*--add dummy blank line for update logic
      APPEND <lfs_str_data> TO <lfs_table_data> .

    ENDIF .

  ENDIF .




*--refresh .
  IF <gfs_t_alv> IS NOT INITIAL .
    CLEAR <gfs_t_alv> .


  ENDIF .


  CREATE DATA lref LIKE LINE OF <gfs_t_alv> .
  ASSIGN lref->* TO <lfs_s_alv> .


*---map to output alv table .
  LOOP AT <lfs_table_data>  ASSIGNING <lfs_str_data> .


    MOVE-CORRESPONDING <lfs_str_data> TO <lfs_s_alv> .

*---
    ASSIGN COMPONENT 'MODE' OF STRUCTURE <lfs_s_alv> TO <lfs_comp> .

    IF sy-subrc = 0 .
      <lfs_comp> = 'N'.

    ENDIF .

    APPEND <lfs_s_alv> TO <gfs_t_alv> .


  ENDLOOP .



ENDFORM .                    "extract_output_data
*&---------------------------------------------------------------------*
*&      Form  INIT_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_proc .


  PERFORM initail_global_deliverables .


  PERFORM enqueue_master_table .


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  END_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM end_proc .

  PERFORM dequeue_master_table .

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  display_fullscreen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_fullscreen  .

*... set the columns technical

  DATA: lr_columns TYPE REF TO cl_salv_columns_table,
        lr_column  TYPE REF TO cl_salv_column_table.
*... 6 register to the events of cl_salv_table
  DATA: lr_events TYPE REF TO cl_salv_events_table.


*---
  CHECK gflg_go IS NOT INITIAL
  AND <gfs_t_alv>  IS ASSIGNED .



  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = gr_table
        CHANGING
          t_table      = <gfs_t_alv> ).
    CATCH cx_salv_msg.                                  "#EC NO_HANDLER
  ENDTRY.

*---

  IF p_disp IS NOT INITIAL .
    gr_table->set_screen_status(
      pfstatus      =  'D100'
      report        =  sy-repid
      set_functions = gr_table->c_functions_all ).

  ELSE .

    gr_table->set_screen_status(
      pfstatus      =  'U100'
      report        =  sy-repid
      set_functions = gr_table->c_functions_all ).

  ENDIF .


  lr_columns = gr_table->get_columns( ).
  lr_columns->set_optimize( abap_true ).

  PERFORM set_columns_technical USING lr_columns.


  lr_events = gr_table->get_event( ).
  CREATE OBJECT gr_events.

  SET HANDLER gr_events->on_user_command FOR lr_events.


  gr_table->display( ) .


ENDFORM .

*&---------------------------------------------------------------------*
*&      Form  set_columns_technical
*&---------------------------------------------------------------------*
FORM switch_check_cloumn_visibility  USING i_switch TYPE flag.

*--
  DATA: lr_columns TYPE REF TO cl_salv_columns_table,
        lr_column  TYPE REF TO cl_salv_column_table.


  TRY.
      lr_columns = gr_table->get_columns( ).
      lr_column ?= lr_columns->get_column( 'ICON').

      IF i_switch IS NOT INITIAL .

        lr_column->set_visible( if_salv_c_bool_sap=>true ).
      ELSE .

        lr_column->set_visible( if_salv_c_bool_sap=>false ).
      ENDIF .

    CATCH cx_salv_not_found.                            "#EC NO_HANDLER

  ENDTRY.


  gr_table->refresh( ) ."Change to refresh LJ 20240827


ENDFORM .
*&---------------------------------------------------------------------*
*&      Form  set_columns_technical
*&---------------------------------------------------------------------*
FORM set_columns_technical
      USING ir_columns TYPE REF TO cl_salv_columns_table .


  DATA: lr_column TYPE REF TO cl_salv_column_table .
  DATA ls_color TYPE lvc_s_colo .


  TRY.
*---set status as icon
      lr_column ?= ir_columns->get_column( 'ICON' ).
      lr_column->set_icon( if_salv_c_bool_sap=>true ).
      lr_column->set_short_text( 'Status' ).
      lr_column->set_visible( if_salv_c_bool_sap=>false ).


*--mark update mode as bold
      lr_column ?= ir_columns->get_column( 'MODE' ).
      lr_column->set_short_text( 'Mode' ).

      ls_color-col = 1 .
      ls_color-int = 1 .
      ls_color-inv = 0 .

      lr_column->set_color( ls_color ).

    CATCH cx_salv_not_found.                            "#EC NO_HANDLER

  ENDTRY.


ENDFORM .                    "set_columns_technical

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_TO_LOCAL
*&---------------------------------------------------------------------*
FORM download_to_local_xls  .

  DATA: l_title       TYPE string,
        l_filename    TYPE string,
        l_file_filter TYPE string,
        l_path        TYPE string,
        l_fullpath    TYPE string,
        l_user_action TYPE i.


*---
  CHECK <gfs_t_alv> IS ASSIGNED .



  DATA :
    l_subrc            TYPE sy-subrc.

  l_title       = 'Download'.

  CONCATENATE p_tabnam
              '_'
              sy-datum
              sy-uzeit
              '.XLSX'
         INTO l_filename   .


  CONCATENATE
*                cl_gui_frontend_services=>filetype_all
                cl_gui_frontend_services=>filetype_excel
*                cl_gui_frontend_services=>filetype_word
*                cl_gui_frontend_services=>filetype_text
*                cl_gui_frontend_services=>filetype_html
*                cl_gui_frontend_services=>filetype_rtf
              '|'
              INTO l_file_filter.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title      = l_title
      default_file_name = l_filename
      file_filter       = l_file_filter
    CHANGING
      filename          = l_filename
      path              = l_path
      fullpath          = l_fullpath
      user_action       = l_user_action
    EXCEPTIONS
      OTHERS            = 1.

  IF sy-subrc <> 0.

    MESSAGE s004 WITH l_filename DISPLAY LIKE 'E' .
*   download file error &1
    RETURN .
  ENDIF .

  IF l_user_action = cl_gui_frontend_services=>action_cancel.
    RETURN .
  ENDIF.



*----
  IF gr_utility_factory IS INITIAL .
    CREATE OBJECT gr_utility_factory.
  ENDIF .


  DATA lref TYPE REF TO data .
  FIELD-SYMBOLS :
    <lfs_s_alv>   TYPE any,
    <lfs_s_excel> TYPE any.



*--alv -> excel .
  CLEAR :
   <gfs_t_excel> .


  CREATE DATA lref LIKE LINE OF <gfs_t_excel> .
  ASSIGN lref->* TO <lfs_s_excel> .



  LOOP AT <gfs_t_alv> ASSIGNING <lfs_s_alv> .

    MOVE-CORRESPONDING <lfs_s_alv> TO <lfs_s_excel> .
    APPEND <lfs_s_excel> TO <gfs_t_excel> .

  ENDLOOP .



  gr_utility_factory->download_to_local_xls(
    EXPORTING
      i_tab = <gfs_t_excel>
      i_file = l_filename
     IMPORTING
      e_subrc = l_subrc  ).



  IF l_subrc  <> 0.
    MESSAGE e004 WITH l_filename.
*   download file error &1

  ELSE .
    MESSAGE s003 WITH l_filename.
*   data file Successfully created &1

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form upload_local_txt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_local_txt .


  DATA :
    lx_filedata    TYPE xstring,
    lref_itab_data TYPE REF TO data,
    lref_root      TYPE REF TO cx_root.


  FIELD-SYMBOLS <lfs_itab_data> TYPE STANDARD TABLE .


  DATA l_subrc TYPE sy-subrc .


  DATA :
    l_filename    TYPE string.


  PERFORM  file_open_dialog USING cl_gui_frontend_services=>filetype_text
                         CHANGING l_filename .

  CHECK l_filename IS NOT INITIAL .


  IF gr_utility_factory IS INITIAL .
    CREATE OBJECT gr_utility_factory.
  ENDIF .


  gr_utility_factory->upload_local_file(
    EXPORTING
      i_filename = l_filename
    IMPORTING
      o_x_filedata = lx_filedata
      o_ref_root  = lref_root  ).

*---
  IF lref_root IS NOT INITIAL .

    MESSAGE s005 WITH '' DISPLAY LIKE 'E'.
*   Upload file error &1

  ENDIF .


*----flat file to  itab . UTF-8 No BOM
  gr_utility_factory->convert_txt_to_itab(
    EXPORTING
      i_x_filedata = lx_filedata
      i_cp         = '4110'
    IMPORTING
      o_ref_itab_data = lref_itab_data
      o_ref_root  = lref_root
      o_subrc = l_subrc ).


*---
  IF lref_root IS NOT INITIAL .

    CASE l_subrc .

      WHEN   4 .

        MESSAGE s005 WITH l_filename DISPLAY LIKE 'E'.
*   Upload file error &1, pelase save file and reload again.

      WHEN 8  .

        MESSAGE s011 DISPLAY LIKE 'E' .
*   Upload file conversion error, pelase check overflow data in your file.

    ENDCASE .

    RETURN .

  ENDIF .



  ASSIGN lref_itab_data->* TO <lfs_itab_data> .

*--overwrite
  CLEAR : <gfs_t_excel> .

  APPEND LINES OF <lfs_itab_data> TO <gfs_t_excel> .

*--xls to alv

  CLEAR <gfs_t_alv> .

  data lref_s_alv type ref to data .
  FIELD-SYMBOLS <lfs_s_alv> type any .

  create data lref_s_alv like line of <gfs_t_alv> .
  ASSIGN lref_s_alv->* to <lfs_s_alv> .




  LOOP AT <gfs_t_excel> ASSIGNING FIELD-SYMBOL(<lfs_s_excel>) .

**--Check flag at last .
*    <gfs_s_alv> = <gfs_s_excel> .

     MOVE-CORRESPONDING <lfs_s_excel> to <lfs_s_alv> .
     APPEND <lfs_s_alv>  TO <gfs_t_alv> .

  ENDLOOP .


  PERFORM refresh USING space .






ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  Upload_local_xls_to_SAP
*&---------------------------------------------------------------------*
FORM upload_local_xls  .

  DATA :
    lx_filedata    TYPE xstring,
    lref_itab_data TYPE REF TO data,
    lref_root      TYPE REF TO cx_root.

  DATA l_subrc TYPE sy-subrc .


  FIELD-SYMBOLS <lfs_itab_data> TYPE STANDARD TABLE .


  DATA l_filename    TYPE string.

*--
  PERFORM  file_open_dialog USING cl_gui_frontend_services=>filetype_excel
                         CHANGING l_filename .


  CHECK l_filename IS NOT INITIAL .


  IF gr_utility_factory IS INITIAL .
    CREATE OBJECT gr_utility_factory.
  ENDIF .


  gr_utility_factory->upload_local_file(
    EXPORTING
      i_filename = l_filename
    IMPORTING
      o_x_filedata = lx_filedata
      o_ref_root  = lref_root  ).

*---
  IF lref_root IS NOT INITIAL .

    MESSAGE s005 WITH '' DISPLAY LIKE 'E'.
*   Upload file error &1

  ENDIF .


  gr_utility_factory->convert_xls_to_itab(
    EXPORTING
      i_x_filedata = lx_filedata
    IMPORTING
      o_ref_itab_data = lref_itab_data
      o_ref_root  = lref_root
      o_subrc = l_subrc ).


*---
  IF lref_root IS NOT INITIAL .

    CASE l_subrc .

      WHEN   4 .

        MESSAGE s005 WITH l_filename DISPLAY LIKE 'E'.
*   Upload file error &1, pelase save file and reload again.

      WHEN 8  .

        MESSAGE s011 DISPLAY LIKE 'E' .
*   Upload file conversion error, pelase check overflow data in your file.

    ENDCASE .

    RETURN .

  ENDIF .



  ASSIGN lref_itab_data->* TO <lfs_itab_data> .

*--overwrite
  CLEAR : <gfs_t_excel> .

  APPEND LINES OF <lfs_itab_data> TO <gfs_t_excel> .

*--xls to alv

  CLEAR <gfs_t_alv> .

  data lref_s_alv type ref to data .
  FIELD-SYMBOLS <lfs_s_alv> type any .

  create data lref_s_alv like line of <gfs_t_alv> .
  ASSIGN lref_s_alv->* to <lfs_s_alv> .


  LOOP AT <gfs_t_excel> ASSIGNING FIELD-SYMBOL(<lfs_s_excel>) .
**--Check flag at last .
*    <gfs_s_alv> = <gfs_s_excel> .

    MOVE-CORRESPONDING <lfs_s_excel> to <lfs_s_alv> .

    APPEND <lfs_s_alv> TO <gfs_t_alv> .


  ENDLOOP .


  PERFORM refresh USING space .


ENDFORM .
*&---------------------------------------------------------------------*
*&      Form  INITAIL_GLOBAL_DELIVERABLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initail_global_deliverables .


  gflg_go = 'X' .

  CLEAR :
    gr_events, gr_table , gr_utility_factory  .

  CLEAR :
  g_where_clauses,
  gt_fields ,
  g_slset ,
  gflg_fack  .


  IF <gfs_t_alv> IS ASSIGNED .

    UNASSIGN <gfs_t_alv> .

  ENDIF .


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_MASTER_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM enqueue_master_table .


  DATA :
    ls_parameter TYPE abap_func_parmbind,
    lt_parameter TYPE abap_func_parmbind_tab.

  DATA :
    ls_exception TYPE abap_func_excpbind,
    lt_exception TYPE abap_func_excpbind_tab.

  DATA ls_dd25l TYPE dd25l .

  DATA l_funcname TYPE funcname .


*--as table name for dynamic
  CHECK  p_upda IS NOT INITIAL .


*---check lock object maitained first .
  SELECT *  UP TO 1 ROWS
       FROM dd25l
       INTO ls_dd25l
      WHERE as4local = 'A'
      AND  as4vers = space
      AND roottab = p_tabnam  .
  ENDSELECT .


*---
  IF sy-subrc <> 0 .

    MESSAGE s012 DISPLAY LIKE 'W' .
*   Lock object not maintained yet, Pay attention for upadte process

    RETURN .
  ENDIF .



*--function name
  CONCATENATE 'ENQUEUE_'
              ls_dd25l-viewname
       INTO  l_funcname.


*-
  CLEAR ls_parameter .
  ls_parameter-name = 'MANDT'.
  ls_parameter-kind = abap_func_exporting.
  GET REFERENCE OF sy-mandt INTO ls_parameter-value.
  INSERT ls_parameter INTO TABLE lt_parameter .

  CLEAR ls_exception .
  ls_exception-name = 'FOREIGN_LOCK'.
  ls_exception-value = '1'.

  INSERT ls_exception INTO TABLE lt_exception .

  CLEAR ls_exception .
  ls_exception-name = 'SYSTEM_FAILURE'.
  ls_exception-value = '2'.
  INSERT ls_exception INTO TABLE lt_exception .


*--call function .
  CALL FUNCTION l_funcname
    PARAMETER-TABLE
    lt_parameter
    EXCEPTION-TABLE
    lt_exception.

*--
  IF sy-subrc <> 0 .

    CLEAR gflg_go .

    MESSAGE ID sy-msgid
          TYPE 'S'
          NUMBER sy-msgno
        WITH sy-msgv1
             sy-msgv2
             sy-msgv3
             sy-msgv4  DISPLAY LIKE 'E'.


  ENDIF .


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_MASTER_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dequeue_master_table .


  DATA l_funcname TYPE funcname .

*--as table name for dynamic
  CHECK p_upda IS NOT INITIAL
  AND gflg_go IS NOT INITIAL .


  TRY.
*--function name
      CONCATENATE 'DEQUEUE_E'
                  p_tabnam
           INTO  l_funcname.


*--call function .
      CALL FUNCTION l_funcname.

    CATCH cx_root .

  ENDTRY .


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_UPDATE_MODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_update_mode .


  DATA l_subrc TYPE sy-subrc .

  FIELD-SYMBOLS <lfs_s_alv>  TYPE any .

  FIELD-SYMBOLS : <lfs_mode> TYPE zs42102eupmod,
                  <lfs_icon> TYPE icon_d.


  CLEAR gflg_check_error  .

*---line by line .
  LOOP AT <gfs_t_alv> ASSIGNING <lfs_s_alv> .


    ASSIGN COMPONENT 'MODE' OF STRUCTURE <lfs_s_alv> TO <lfs_mode>.
    ASSIGN COMPONENT 'ICON' OF STRUCTURE <lfs_s_alv> TO <lfs_icon>.


*--
    CASE <lfs_mode> .

*--nothing .
      WHEN 'N' .

        <lfs_icon> = icon_led_inactive .
*--check
      WHEN 'U' .

        PERFORM check_key_exist USING  <lfs_s_alv>
                               CHANGING l_subrc .

        IF l_subrc = 0 .

          <lfs_icon> = icon_checked.

        ELSE .

          gflg_check_error =  'X' .


          <lfs_icon> = icon_incomplete.

        ENDIF .

      WHEN 'D' .

        PERFORM check_key_exist USING <lfs_s_alv>
                               CHANGING l_subrc .

        IF l_subrc = 0 .
          <lfs_icon> = icon_checked.
        ELSE .

          gflg_check_error =  'X' .

          <lfs_icon> = icon_incomplete.
        ENDIF .

      WHEN 'I' .

        PERFORM check_key_exist USING <lfs_s_alv>
                               CHANGING l_subrc .

        IF l_subrc <> 0 .
          <lfs_icon> = icon_checked.
        ELSE .

          gflg_check_error =  'X' .

          <lfs_icon> = icon_incomplete.
        ENDIF .

    ENDCASE .
  ENDLOOP .

*---set check field visible .
  PERFORM switch_check_cloumn_visibility USING 'X' .


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_KEY_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<GFS_A_ALV>  text
*      <--P_L_SUBRC  text
*----------------------------------------------------------------------*
FORM check_key_exist  USING    i_tab_line TYPE any
                      CHANGING o_subrc TYPE sy-subrc .


  DATA :
    l_key_fields   TYPE string,
    l_key_value    TYPE string,
    l_where_clause TYPE string.

  FIELD-SYMBOLS <lfs_key_value> TYPE any .


*-craete where clause .
  LOOP AT gt_table_key INTO l_key_fields .

    ASSIGN COMPONENT l_key_fields
           OF STRUCTURE i_tab_line TO <lfs_key_value> .  .


    IF sy-subrc = 0 .

*--add "'" value  "'" .
      CLEAR l_key_value .

      CONCATENATE ''''
                  <lfs_key_value>
                  ''''
               INTO l_key_value .


      IF l_where_clause IS INITIAL .

        CONCATENATE l_key_fields
                    '='

                    l_key_value
                INTO l_where_clause SEPARATED BY space .

      ELSE .
        CONCATENATE l_where_clause
                    'AND'
                    l_key_fields
                    '='
                    l_key_value
                INTO l_where_clause SEPARATED BY space .
      ENDIF .
    ENDIF .
  ENDLOOP.

*---
  SELECT SINGLE COUNT(*)
      FROM (p_tabnam)
      WHERE (l_where_clause).

*--
  IF sy-dbcnt = 0 .
    o_subrc = 4 .
  ELSE .

    o_subrc = 0 .
  ENDIF .

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  POST_TO_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM post_to_db .

  DATA l_subrc TYPE sy-subrc .

  FIELD-SYMBOLS : <lfs_mode> TYPE zs42102eupmod,
                  <lfs_icon> TYPE icon_d.

  FIELD-SYMBOLS <lfs_s_alv> TYPE any .

*--
  READ TABLE  <gfs_t_alv> ASSIGNING <lfs_s_alv> INDEX 1 ..
  ASSIGN COMPONENT 'ICON' OF STRUCTURE <lfs_s_alv> TO <lfs_icon>.

*--
  IF <lfs_icon> IS INITIAL .

    MESSAGE i010.
*   Please perfrom DB Consistensy Check first
    RETURN .
  ENDIF .


*---
  IF  gflg_check_error IS NOT INITIAL .
    MESSAGE i009.
*   DB Consistency check Imcomplete, Please fix error recode before post .

    RETURN  .
  ENDIF .


*---line by line .
  LOOP AT <gfs_t_alv> ASSIGNING <lfs_s_alv> .


    ASSIGN COMPONENT 'MODE' OF STRUCTURE <lfs_s_alv> TO <lfs_mode>.
    ASSIGN COMPONENT 'ICON' OF STRUCTURE <lfs_s_alv> TO <lfs_icon>.


*--
    CASE <lfs_mode> .

*--nothing .
      WHEN 'N' .

        <lfs_icon> = icon_led_inactive .

*--check
      WHEN 'U' .

        PERFORM post_update USING  <lfs_s_alv>
                               CHANGING l_subrc .

        IF l_subrc = 0 .
          <lfs_icon> = icon_led_green.

        ELSE .

          <lfs_icon> = icon_led_red.
        ENDIF .


      WHEN 'D' .

        PERFORM post_delete USING <lfs_s_alv>
                               CHANGING l_subrc .

        IF l_subrc = 0 .
          <lfs_icon> = icon_led_green.

        ELSE .

          <lfs_icon> = icon_led_red.
        ENDIF .


      WHEN 'I' .

        PERFORM post_insert USING <lfs_s_alv>
                               CHANGING l_subrc .

        IF l_subrc = 0 .
          <lfs_icon> = icon_led_green.
        ELSE .

          <lfs_icon> = icon_led_red.
        ENDIF .

    ENDCASE .
  ENDLOOP .


*---set check field visible .
  PERFORM switch_check_cloumn_visibility USING 'X' .


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh USING i_mode TYPE flag .

*---get data from db again .

  IF i_mode = 'X' .

    PERFORM extract_output_data  .

  ENDIF .


*---set back to initial . .
  PERFORM switch_check_cloumn_visibility USING space .


  gr_table->refresh( ).


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  POST_DELETE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM post_delete  USING   i_tab_line TYPE any
               CHANGING o_subrc TYPE sy-subrc .


  DATA lref TYPE REF TO data .
  FIELD-SYMBOLS :
    <lfs_wa>   TYPE any,
    <lfs_comp> TYPE any.


  CREATE DATA lref TYPE (p_tabnam) .
  ASSIGN lref->* TO <lfs_wa> .

  MOVE-CORRESPONDING i_tab_line TO <lfs_wa> .

*---
  ASSIGN COMPONENT 'MANDT' OF STRUCTURE <lfs_wa> TO <lfs_comp> .

  IF sy-subrc = 0 .

    <lfs_comp> = sy-mandt .

  ENDIF .


  DELETE (p_tabnam) FROM <lfs_wa> .


  o_subrc = sy-subrc .


ENDFORM.
.
*&---------------------------------------------------------------------*
*&      Form  POST_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM post_update      USING    i_tab_line TYPE any
                      CHANGING o_subrc TYPE sy-subrc .



  DATA lref TYPE REF TO data .
  FIELD-SYMBOLS :
    <lfs_wa>   TYPE any,
    <lfs_comp> TYPE any.


  CREATE DATA lref TYPE (p_tabnam) .
  ASSIGN lref->* TO <lfs_wa> .

  MOVE-CORRESPONDING i_tab_line TO <lfs_wa> .

*---
  ASSIGN COMPONENT 'MANDT' OF STRUCTURE <lfs_wa> TO <lfs_comp> .

  IF sy-subrc = 0 .
    <lfs_comp> = sy-mandt .
  ENDIF .


  UPDATE (p_tabnam) FROM <lfs_wa> .


  o_subrc = sy-subrc .


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  POST_INSERT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM post_insert    USING i_tab_line TYPE any
                  CHANGING o_subrc TYPE sy-subrc .


  DATA lref TYPE REF TO data .
  FIELD-SYMBOLS :
    <lfs_wa>   TYPE any,
    <lfs_comp> TYPE any.


  CREATE DATA lref TYPE (p_tabnam) .
  ASSIGN lref->* TO <lfs_wa> .

  MOVE-CORRESPONDING i_tab_line TO <lfs_wa> .

*---
  ASSIGN COMPONENT 'MANDT' OF STRUCTURE <lfs_wa> TO <lfs_comp> .

  IF sy-subrc = 0 .
    <lfs_comp> = sy-mandt .
  ENDIF .


  INSERT (p_tabnam) FROM <lfs_wa> .


  o_subrc = sy-subrc .


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_TEMPLATE_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download_template_excel .


*--perform dynamic table .
  PERFORM build_output_dynamic_table .

*--.
  PERFORM create_sample_data  .

*--.
  PERFORM download_to_local_xls .


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_SAMPLE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_sample_data .

*---


  FIELD-SYMBOLS <lfs_s_alv> TYPE any .

  DATA lref TYPE REF TO data  .

  CHECK <gfs_t_alv> IS ASSIGNED .



  CREATE DATA lref LIKE LINE OF <gfs_t_alv> .


  ASSIGN lref->* TO <lfs_s_alv> .

*---add 3 line of blank lines for sample

  DO 3 TIMES .

    APPEND <lfs_s_alv> TO <gfs_t_alv> .
  ENDDO .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form upload_local_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM upload_local_file .

*--popup to select text file or xls file .

  DATA:   selectlist LIKE spopli OCCURS 5 WITH HEADER LINE.
  DATA:   antwort   TYPE c.


  CLEAR   selectlist.
  REFRESH selectlist.

  selectlist-varoption = 'Excel - Office Open XML 書式'(002).
  selectlist-selflag   = 'X'.

  APPEND selectlist.

  selectlist-varoption = 'Text UTF-8 w/o BOM'(001).
  CLEAR selectlist-selflag   .

  APPEND selectlist.

*--
  CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
    EXPORTING
*     CURSORLINE         = 1
*     MARK_FLAG          = ' '
      mark_max           = 1
      start_col          = 30
      start_row          = 1
      textline1          = 'Select Upload File Format'(004)
      textline2          = 'Note: Date & Time Format must following User Default Setting'(005)
      titel              = 'File Format'(003)
    IMPORTING
      answer             = antwort
    TABLES
      t_spopli           = selectlist
    EXCEPTIONS
      not_enough_answers = 1
      too_much_answers   = 2
      too_much_marks     = 3
      OTHERS             = 4.


  IF antwort EQ 'A'.
    EXIT.
  ELSE .

*---
    LOOP AT selectlist WHERE selflag = 'X'.
*---text file
      IF selectlist-varoption = TEXT-001 .

        PERFORM upload_local_txt .

*---excel file
      ELSE .

        PERFORM upload_local_xls .

      ENDIF .

    ENDLOOP .


  ENDIF .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form file_open_dialog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> CL_GUI_FRONTEND_SERVICES=>FILE
*&      <-- L_FILENAME
*&---------------------------------------------------------------------*
FORM file_open_dialog  USING i_filter TYPE string
                       CHANGING c_filename TYPE string .



  DATA: l_title       TYPE string,
        l_filename    TYPE string,
        l_file_filter TYPE string,
        l_filetab     TYPE filetable,
        l_file        TYPE LINE OF filetable,
        l_rc          TYPE i,
        l_user_action TYPE i.



  l_title     = 'Upload'.
*  l_filename  = default_filename.

  CONCATENATE i_filter
              '|'
              INTO l_file_filter.


  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title     = l_title
      default_filename = l_filename
      file_filter      = l_file_filter
    CHANGING
      file_table       = l_filetab
      rc               = l_rc
      user_action      = l_user_action
    EXCEPTIONS
      OTHERS           = 1.

  IF sy-subrc <> 0.

    MESSAGE s005 WITH '' DISPLAY LIKE 'E'.
*   Upload file error &1

    RETURN .
  ENDIF.
  IF l_rc <> 1 OR
     l_user_action = cl_gui_frontend_services=>action_cancel.
    RETURN .
  ENDIF.


* Upload der Datei
  READ TABLE l_filetab INTO l_file INDEX 1.
  c_filename = l_file-filename.



ENDFORM.
