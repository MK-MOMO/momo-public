*&---------------------------------------------------------------------*
*& Report ZCVI0010
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* Program Description: Conversion object common include
* Developer : LJ
* Date : 20 NOV 2021
*&----------------------------------------------------------------------*

 TYPES :
   BEGIN OF typ_excel ,
     row   TYPE  num9,
     col   TYPE  num9,
     value TYPE  char50,
   END OF typ_excel ,
   typ_t_excel TYPE STANDARD TABLE OF typ_excel.

 DATA  gt_excel     TYPE typ_t_excel .

*---LJ update 20240109 Start
 TYPES :
   BEGIN OF typ_alv_return.
     INCLUDE TYPE bapiret2.
 TYPES: t_color TYPE lvc_t_scol,
   END OF typ_alv_return.

*--
 DATA gt_alv_return TYPE STANDARD TABLE OF typ_alv_return. .
*---LJ update 20240109 End


*---LJ 20240212 Add Start
 TYPES:
   BEGIN OF typ_pro_no,
     err TYPE int4,
*↓20240229 ADD kawano
     war TYPE int4,
*↑20240229 ADD kawano
     suc TYPE int4,
     ttl TYPE int4,
   END OF typ_pro_no .

 DATA :
   gs_pro_no TYPE typ_pro_no .


DATA :
  gt_return LIKE STANDARD TABLE OF bapie1ret2,
  g_error   TYPE flag.




*---interace
 DATA :
   go_interface_factory TYPE REF TO ZCL_Interface_FACTORY .
*---LJ 20240212 Add End

*&---------------------------------------------------------------------*
*&   Selection screen
*&---------------------------------------------------------------------*

 SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-001.

   PARAMETERS prd_bg RADIOBUTTON GROUP g01 .
   PARAMETERS:
     p_sfile TYPE string LOWER CASE .


   SELECTION-SCREEN COMMENT /2(50) TEXT-s01 .

   SELECTION-SCREEN SKIP.


   PARAMETERS prd_fg RADIOBUTTON GROUP g01 DEFAULT 'X' .

   PARAMETERS:
     p_file  TYPE string,
     p_batch TYPE int4 DEFAULT '999'.


   SELECTION-SCREEN COMMENT /2(50) TEXT-s02 .


   SELECTION-SCREEN SKIP.


   PARAMETERS:
     p_test TYPE testrun DEFAULT 'X'.

 SELECTION-SCREEN END OF BLOCK blk1.


*&---------------------------------------------------------------------*
*&   Event AT SELECTION-SCREEN ON VALUE-REQUEST FOR DATASET
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_file.

   PERFORM frm_F4HELP_P_INFILE USING P_file.

**&---------------------------------------------------------------------*
**&   Event AT SELECTION-SCREEN ON VALUE-REQUEST FOR DATASET
**&---------------------------------------------------------------------*
 AT SELECTION-SCREEN .

   IF prd_bg IS NOT INITIAL
   AND p_sfile IS INITIAL .

     MESSAGE e003(zcv001).
* バックグランド実行ファイルを指定してください。
   ENDIF .


   IF prd_fg IS NOT INITIAL
   AND p_file IS INITIAL .

     MESSAGE e004(zcv001).
* アップロードファイル名を指定してください。
   ENDIF .


*&---------------------------------------------------------------------*
*&      Form  frm_f4help_p_infile
*&---------------------------------------------------------------------*
 FORM frm_f4help_p_infile  USING  i_file TYPE string .


   DATA:
     ltd_fname     TYPE filetable,
     l_subrc       TYPE i,
     l_directory   TYPE string VALUE 'C:\',
     l_file_filter TYPE string.

   l_file_filter = TEXT-002.  " 'Microsoft Excel Files (*.XLS;*.XLSX;*.XLSM)|*.XLS;*.XLSX;*.XLSM|'(001).

   REFRESH : ltd_fname.

   CALL METHOD cl_gui_frontend_services=>file_open_dialog
     EXPORTING
*      window_title            = window_title
*      default_filename        = l_path
       file_filter             = l_file_filter
       with_encoding           = abap_true
       initial_directory       = l_directory
       multiselection          = abap_false
     CHANGING
       file_table              = ltd_fname
       rc                      = l_subrc
*      file_encoding           = g_encod
     EXCEPTIONS
       file_open_dialog_failed = 1
       cntl_error              = 2
       error_no_gui            = 3
       OTHERS                  = 4.

   IF sy-subrc <> 0.

   ELSE.
     IF l_subrc = 1.
       READ TABLE ltd_fname INTO i_file INDEX 1.
     ENDIF.
   ENDIF.

 ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_UPLOAD_FILE_VIA_EXCLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM frm_upload_excle_file  USING i_file TYPE string
                                   i_batch TYPE int4
                             CHANGING ct_excel TYPE typ_t_excel .

   DATA l_paket TYPE i .
   DATA l_lines TYPE i .

   DATA :
     l_begin_row TYPE i,
     l_end_row   TYPE i.

   DATA ls_excel TYPE typ_excel .

   DATA :
     l_excel_fname TYPE rlgrap-filename,
     lt_raw_excel  TYPE issr_alsmex_tabline.

   l_excel_fname = i_file .


   l_begin_row = 1 .
   l_end_row = l_begin_row + i_batch .

   DO .

     CLEAR lt_raw_excel .

     CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
       EXPORTING
         filename                = l_excel_fname
         i_begin_col             = '1'
         i_begin_row             = l_begin_row
         i_end_col               = '256'
         i_end_row               = l_end_row
       TABLES
         intern                  = lt_raw_excel
       EXCEPTIONS
         inconsistent_parameters = 1
         upload_ole              = 2
         OTHERS                  = 3.

     IF sy-subrc <> 0 .
       g_error = abap_true .
       MESSAGE s001(zcv001) DISPLAY LIKE 'E'.
* EXCELファイルをSAPにアップロードできませんでした。
       EXIT.
     ENDIF .


     IF lt_raw_excel IS INITIAL .
       EXIT .
     ENDIF .


     CLEAR l_lines .
     LOOP AT lt_raw_excel ASSIGNING FIELD-SYMBOL(<lfs_raw_excel>) .
       CLEAR ls_excel .

       ls_excel-row = <lfs_raw_excel>-row + l_begin_row - 1 .
       ls_excel-col = <lfs_raw_excel>-col.
       ls_excel-value = <lfs_raw_excel>-value .

       APPEND ls_excel TO ct_excel .

       AT END OF row.
         l_lines = l_lines + 1 .
       ENDAT .

     ENDLOOP .


     l_paket =  l_end_row - l_begin_row .

     IF l_lines < l_paket  .
       EXIT .
     ELSE .

       l_begin_row = l_end_row + 1 .
       l_end_row = l_begin_row + i_batch .

     ENDIF .

   ENDDO.



   IF  ct_excel IS INITIAL  .
     g_error = abap_true .

     MESSAGE s002(zcv001) DISPLAY LIKE 'E' .
* アップロードしたEXCELファイルはブランクファイルです。
     RETURN .

   ENDIF .

 ENDFORM .
*&---------------------------------------------------------------------*
*&      Form  FRM_UPLOAD_FILE_VIA_EXCLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
* FORM frm_upload_file_via_excle  USING i_file TYPE string
*                               CHANGING o_t_raw_excel TYPE issr_alsmex_tabline .
*
*
*   DATA : l_excel_fname TYPE rlgrap-filename .
*
*   DATA : l_col TYPE char04 .
*
*   FIELD-SYMBOLS
*      <lfs_raw_excel> LIKE LINE OF o_t_raw_excel .
*
*   l_excel_fname = i_file .
*
**
*   CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
*     EXPORTING
*       filename                = l_excel_fname
*       i_begin_col             = '1'
*       i_begin_row             = '1'
*       i_end_col               = '256'
*       i_end_row               = '65536'
*     TABLES
*       intern                  = o_t_raw_excel
*     EXCEPTIONS
*       inconsistent_parameters = 1
*       upload_ole              = 2
*       OTHERS                  = 3.
*
*
*
*   IF sy-subrc <> 0 .
*
*     g_error = abap_true .
*
*     MESSAGE s001(zcv001) DISPLAY LIKE 'E'.
** EXCELファイルをSAPにアップロードできませんでした。
*
*     RETURN .
*
*   ENDIF .
*
*
*   IF  o_t_raw_excel IS INITIAL  .
*     g_error = abap_true .
*
*     MESSAGE s002(zcv001) DISPLAY LIKE 'E' .
** アップロードしたEXCELファイルはブランクファイルです。
*     RETURN .
*
*   ENDIF .
*
* ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SHOW_ALV_RESULT
*&---------------------------------------------------------------------*
 FORM frm_show_alv_result .


   DATA:
     lr_columns    TYPE REF TO cl_salv_columns_table,
     lr_selections TYPE REF TO cl_salv_selections,
     lr_layout_top TYPE REF TO cl_salv_form_layout_grid,
     lr_events     TYPE REF TO cl_salv_events_table.


   CHECK g_error IS INITIAL .

*--LJ Update 20240109 Start

   DATA :
     ls_alv_return TYPE typ_alv_return,
     lt_color      TYPE lvc_t_scol,
     ls_color      TYPE lvc_s_scol.


*---
   PERFORM add_process_log_info .

*--
   CLEAR gt_alv_return .


   LOOP AT gt_return ASSIGNING FIELD-SYMBOL(<lfs_return>) .

     CLEAR ls_alv_return .

     MOVE-CORRESPONDING <lfs_return> TO ls_alv_return .

*---伝票不完全の場合はエラー
     IF ls_alv_return-id = 'V1'
     AND ls_alv_return-number = '555' .
       ls_alv_return-type = 'E' .
     ENDIF .
*--

     CLEAR lt_color.
     CLEAR ls_color.

     CASE  ls_alv_return-type.
*--Warning
       WHEN 'W' .

         ls_color-color-col = col_total .
         ls_color-color-int = 0.
         ls_color-color-inv = 0.
         APPEND ls_color TO lt_color.

*--Error
       WHEN 'E' OR 'A'.
         ls_color-color-col = col_negative.
         ls_color-color-int = 0.
         ls_color-color-inv = 0.
         APPEND ls_color TO lt_color.

*--OK
       WHEN 'S' .
         ls_color-color-col = col_positive.
         ls_color-color-int = 0.
         ls_color-color-inv = 0.
         APPEND ls_color TO lt_color.

     ENDCASE .

     ls_alv_return-t_color = lt_color.

     APPEND ls_alv_return  TO gt_alv_return .

   ENDLOOP.

*--LJ Update 20240109 End


*----Create ALV table
   TRY.
       cl_salv_table=>factory(
         IMPORTING
           r_salv_table = gr_table
         CHANGING
*           t_table      = gt_return ). "LJ Delete 20240109
            t_table      = gt_alv_return ). "LJ Add 20240109

     CATCH cx_salv_msg.                                 "#EC NO_HANDLER
   ENDTRY.


*----set the columns technical
   lr_columns = gr_table->get_columns( ).
   lr_columns->set_optimize( abap_true ).


*--LJ Update 20240109 Start
   TRY.
       lr_columns->set_color_column( 'T_COLOR' ).
     CATCH cx_salv_data_error.                          "#EC NO_HANDLER
   ENDTRY.
*--LJ Update 20240109 End



*----set up function button
   gr_table->set_screen_status(
    pfstatus      =  'SALV_STANDARD'
    report        =  'SALV_DEMO_METADATA'
    set_functions =  gr_table->c_functions_all ).


*----set up selections
   lr_selections = gr_table->get_selections( ).
   lr_selections->set_selection_mode( if_salv_c_selection_mode=>cell ).



*----show ALV
   gr_table->display( ).


 ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_read_flat_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_SFILE
*&      <-- GT_EXCEL
*&---------------------------------------------------------------------*
 FORM frm_read_flat_file  USING   i_sfile TYPE string
                          CHANGING ct_excel TYPE typ_t_excel .


   DATA l_rc TYPE c.

   DATA l_message TYPE string .

   DATA : ls_file_line TYPE string,
          lt_file      TYPE string_table,
          lt_line_val  TYPE string_table.


   FIELD-SYMBOLS <lfs_comp> TYPE any .

   TRY.

       l_rc = '*' .

       OPEN DATASET i_sfile  FOR INPUT IN TEXT MODE
       ENCODING DEFAULT  IGNORING CONVERSION ERRORS REPLACEMENT CHARACTER l_rc MESSAGE l_message .


       DO .

         READ DATASET i_sfile INTO ls_file_line .

         IF sy-subrc <> 0 .
           EXIT .
         ELSE .
           APPEND ls_file_line TO lt_file .
         ENDIF .
       ENDDO .


     CATCH cx_root .


       g_error = abap_true .

       MESSAGE s005(zcv001) WITH  i_sfile   DISPLAY LIKE 'E' .
* ファイルオープンエラー &1
       RETURN .
   ENDTRY.


   CLOSE DATASET i_sfile .


   DATA ls_excel TYPE typ_excel .

*--move to excel file stracture .
   LOOP AT lt_file ASSIGNING FIELD-SYMBOL(<lfs_file>) .

     CLEAR : ls_excel ,
             lt_line_val.

     ls_excel-row = sy-tabix .


     SPLIT <lfs_file> AT cl_abap_char_utilities=>horizontal_tab
                     INTO TABLE lt_line_val .


     LOOP AT lt_line_val ASSIGNING <lfs_comp>.

       IF   <lfs_comp> IS NOT INITIAL .

         ls_excel-col = sy-tabix .


         ls_excel-value = <lfs_comp> .

*-----add end of line mark
         AT LAST .

           ls_excel-value = '<EOL>' .

         ENDAT .

         APPEND ls_excel TO ct_excel .

       ENDIF .

     ENDLOOP.

   ENDLOOP.

 ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_fields_calalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
 FORM get_fields_calalog USING i_vari TYPE slis_vari
                               i_str  TYPE dd02l-tabname
                        CHANGING o_t_fcat TYPE lvc_t_fcat .


*
*---get Layout variant information .
   DATA : ls_ltdx TYPE ltdx,
          lt_ltdx TYPE STANDARD TABLE OF ltdx.


   DATA : ls_varkey   TYPE ltdxkey,
          lt_fieldcat TYPE STANDARD TABLE OF ltdxdata.


*--
   SELECT *
     FROM ltdx
     INTO TABLE lt_ltdx
     WHERE report = sy-repid
      AND variant = i_vari.

   IF sy-subrc <> 0.
     RETURN .
   ENDIF .

   SORT lt_ltdx BY aedat DESCENDING .
   READ TABLE lt_ltdx INTO ls_ltdx INDEX 1 .


   MOVE-CORRESPONDING ls_ltdx TO ls_varkey .

   CALL FUNCTION 'LT_DBDATA_READ_FROM_LTDX'
     EXPORTING
*      I_TOOL       = 'LT'
       is_varkey    = ls_varkey
     TABLES
       t_dbfieldcat = lt_fieldcat
*      T_DBSORTINFO =
*      T_DBFILTER   =
*      T_DBLAYOUT   =
     EXCEPTIONS
       not_found    = 1
       wrong_relid  = 2
       OTHERS       = 3.

   IF sy-subrc <> 0.
     RETURN .
   ENDIF.



*--only no out space for output .
   LOOP AT lt_fieldcat ASSIGNING FIELD-SYMBOL(<lfs_fieldcat>).

     IF <lfs_fieldcat>-param <> 'NO_OUT'.
       DELETE lt_fieldcat .
     ELSE .
*---no out yes
       IF <lfs_fieldcat>-value = 'X'.
         DELETE lt_fieldcat .
       ENDIF .
     ENDIF .
   ENDLOOP.


**---
   CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
     EXPORTING
       i_buffer_active        = space
       i_structure_name       = i_str
       i_client_never_display = 'X'
       i_bypassing_buffer     = space
     CHANGING
       ct_fieldcat            = o_t_fcat
     EXCEPTIONS
       inconsistent_interface = 1
       program_error          = 2
       OTHERS                 = 3.

   IF sy-subrc <> 0.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   ENDIF.


*---
   LOOP AT o_t_fcat ASSIGNING FIELD-SYMBOL(<lfs_fcat>) .
*--
     CLEAR <lfs_fcat>-col_pos  .

     <lfs_fcat>-no_out = 'X' .
*--
     READ TABLE  lt_fieldcat ASSIGNING <lfs_fieldcat>
                           WITH KEY key1 = <lfs_fcat>-fieldname .

     IF sy-subrc = 0.
       <lfs_fcat>-col_pos = sy-tabix .
       <lfs_fcat>-no_out = space  .
     ELSE .

       DELETE o_t_fcat.
     ENDIF .

   ENDLOOP.

*--
   SORT o_t_fcat BY col_pos ASCENDING .

 ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_output_job_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
 FORM frm_output_job_list .


*---
   PERFORM add_process_log_info .


*---
   LOOP AT gt_return ASSIGNING FIELD-SYMBOL(<lfs_return>) .


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




 ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_process_log_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
 FORM add_process_log_info .


   DATA :
     l_jobcount TYPE tbtcm-jobcount,
     l_jobname  TYPE tbtcm-jobname.

   DATA l_msg_dummy TYPE string .

*---processed number
   MESSAGE s015(zif001) WITH gs_pro_no-ttl
                         INTO l_msg_dummy .

   PERFORM append_to_return_log USING syst .


*--Success count
   MESSAGE s016(zif001) WITH gs_pro_no-suc
                       INTO l_msg_dummy .

   PERFORM append_to_return_log USING syst .

*↓ADD20240229 kawano
*--Warning count
   MESSAGE s054(zif001) WITH gs_pro_no-war
                       INTO l_msg_dummy .

   PERFORM append_to_return_log USING syst .
*↑ADD20240229 kawano

*--Error count

   MESSAGE s017(zif001) WITH gs_pro_no-err
                          INTO l_msg_dummy .
   PERFORM append_to_return_log USING syst .

*--
   IF gs_pro_no-err IS NOT INITIAL .

     CALL FUNCTION 'GET_JOB_RUNTIME_INFO'
       IMPORTING
         jobcount        = l_jobcount
         jobname         = l_jobname
       EXCEPTIONS
         no_runtime_info = 1
         OTHERS          = 2.

     MESSAGE e999(zif001) WITH TEXT-m01 l_jobcount INTO l_msg_dummy  .
* &1 処理にエラーが発生しました。処理ログを確認してください。&2

   ELSE .
     MESSAGE s998(zif001) WITH TEXT-m01 INTO  l_msg_dummy .
* &1 処理は正常に終了しました。
   ENDIF .


   PERFORM append_to_return_log USING syst .



 ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_to_return_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SYST
*&---------------------------------------------------------------------*
 FORM append_to_return_log  USING  i_syst TYPE syst .

   DATA ls_return TYPE bapiret2 .

   ls_return-type = i_syst-msgty.
   ls_return-id = i_syst-msgid.
   ls_return-number = i_syst-msgno.
   ls_return-message_v1 = i_syst-msgv1.
   ls_return-message_v2 = i_syst-msgv2.
   ls_return-message_v3 = i_syst-msgv3.
   ls_return-message_v4 = i_syst-msgv4.

   MESSAGE ID i_syst-msgid
           TYPE i_syst-msgty
           NUMBER i_syst-msgno
           WITH i_syst-msgv1
                i_syst-msgv2
                i_syst-msgv3
                i_syst-msgv4
     INTO ls_return-message .

   APPEND ls_return TO gt_return .


 ENDFORM.
