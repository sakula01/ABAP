*&----------------------------------------------------------------*
*&      Form  F_BEFORE_SAVE
*&----------------------------------------------------------------*
FORM f_before_save ##CALLED.
  TYPES: BEGIN OF ty_tcdrp,
           object     TYPE cdobjectcl,
           reportname TYPE cdreport,
         END OF   ty_tcdrp.
  DATA: lt_ptab  TYPE STANDARD TABLE OF string,
        lv_prog  TYPE string,
        lv_mess  TYPE string,
        lv_sid   TYPE string,
        lt_obj   TYPE STANDARD TABLE OF cdobjectcl,
        lt_tcdrp TYPE STANDARD TABLE OF ty_tcdrp,
        lv_fugn  TYPE funct_pool.
  " Objects for change document creation
  SELECT object
    FROM tcdob
    INTO TABLE lt_obj
    WHERE tabname EQ vim_view_name.
  IF sy-subrc IS NOT INITIAL.
    " No change document objects found
    MESSAGE i899(cd).
    RETURN.
  ENDIF.
  " Information on Include Reports Generated by RSSCD000
  SELECT object reportname
    FROM tcdrp
    INTO TABLE lt_tcdrp
    FOR ALL ENTRIES IN lt_obj
    WHERE object EQ lt_obj-table_line.
  IF sy-subrc IS NOT INITIAL.
    " Update program does not yet exist
    MESSAGE i446(m2).
    RETURN.
  ENDIF.
  " View Directory
  SELECT SINGLE area
    FROM tvdir
    INTO lv_fugn
    WHERE tabname EQ vim_view_name.
  "*-
  LOOP AT lt_obj ASSIGNING FIELD-SYMBOL(<lv_obj>).
    READ TABLE lt_tcdrp ASSIGNING FIELD-SYMBOL(<ls_tcdrp>)
                        WITH KEY object = <lv_obj>.
    IF sy-subrc IS NOT INITIAL.
      CONTINUE.
    ENDIF.
    " Subroutine pool
    APPEND ##NO_TEXT:
           `PROGRAM SUBPOOL.` TO lt_ptab,
           `  INCLUDE F` && <ls_tcdrp>-reportname && `CDT.` TO lt_ptab,
           `  INCLUDE F` && <ls_tcdrp>-reportname && `CDC.` TO lt_ptab,
           `  FORM f_process.` TO lt_ptab,
           `    TYPES:  BEGIN OF total.` TO lt_ptab,
           `            INCLUDE STRUCTURE ` && vim_view_name && `.` TO lt_ptab,
           `            INCLUDE STRUCTURE vimflagtab.` TO lt_ptab,
           `    TYPES:  END OF total.` TO lt_ptab,
           `    FIELD-SYMBOLS: <fs_total>       TYPE ANY TABLE,` TO lt_ptab,
           `                   <fs_total_wa>    TYPE total,` TO lt_ptab,
           `                   <fs_x_namtab>    TYPE ANY TABLE,` TO lt_ptab,
           `                   <fs_x_namtab_wa> TYPE vimnamtab,` TO lt_ptab,
           `                   <fs_field>       TYPE any.` TO lt_ptab,
           `    DATA: lv_tabname(40) TYPE c VALUE '(SAPL` && lv_fugn && `)TOTAL[]',` TO lt_ptab,
           `          lv_cond_line  TYPE string,` TO lt_ptab,
           `          lv_cond_line2 TYPE string.` TO lt_ptab,
           `    ASSIGN (lv_tabname) TO <fs_total>.` TO lt_ptab,
           `    LOOP AT <fs_total> ASSIGNING <fs_total_wa> CASTING.` TO lt_ptab,
           `      CASE <fs_total_wa>-action.` TO lt_ptab,
           `        WHEN 'U'. " Update` TO lt_ptab,
           `          lv_tabname = '(SAPL` && lv_fugn && `)X_NAMTAB[]'.` TO lt_ptab,
           `          ASSIGN (lv_tabname) TO <fs_x_namtab>.` TO lt_ptab,
           `          lv_cond_line2 = |keyflag EQ 'X' AND viewfield NE 'MANDT'|.` TO lt_ptab,
           `          LOOP AT <fs_x_namtab> ASSIGNING <fs_x_namtab_wa> WHERE (lv_cond_line2).` TO lt_ptab,
           `            ASSIGN COMPONENT <fs_x_namtab_wa>-viewfield OF STRUCTURE <fs_total_wa> TO <fs_field>.` TO lt_ptab,
           `            IF sy-subrc IS INITIAL.` TO lt_ptab,
           `              lv_cond_line = lv_cond_line && |AND | && ` TO lt_ptab,
           `                             <fs_x_namtab_wa>-viewfield && | EQ '| && <fs_field> && |' |.` TO lt_ptab,
           `              objectid = objectid && <fs_field>.` TO lt_ptab,
           `              UNASSIGN <fs_field>.` TO lt_ptab,
           `            ENDIF.` TO lt_ptab,
           `          ENDLOOP.` TO lt_ptab,
           `          IF sy-subrc IS INITIAL.` TO lt_ptab,
           `            SHIFT lv_cond_line LEFT BY 3 PLACES.` TO lt_ptab,
           `            SELECT SINGLE *` TO lt_ptab,
           `              FROM ` && vim_view_name TO lt_ptab,
           `              INTO *` && vim_view_name TO lt_ptab,
           `              WHERE (lv_cond_line).` TO lt_ptab,
           `            MOVE-CORRESPONDING <fs_total_wa> TO ` && vim_view_name && `.` TO lt_ptab,
           `            objectid        = objectid.` TO lt_ptab,
           `            tcode           = sy-tcode.` TO lt_ptab,
           `            udate           = sy-datum.` TO lt_ptab,
           `            utime           = sy-uzeit.` TO lt_ptab,
           `            username        = sy-uname.` TO lt_ptab,
           `            cdoc_upd_object = 'U'.` TO lt_ptab,
           `            upd_` && vim_view_name && ` = 'U'.` TO lt_ptab,
           `            PERFORM cd_call_` && <lv_obj> && `.` TO lt_ptab,
           `          ENDIF.` TO lt_ptab,
           `        WHEN 'N'. " New` TO lt_ptab,
           `          lv_tabname = '(SAPL` && lv_fugn && `)X_NAMTAB[]'.` TO lt_ptab,
           `          ASSIGN (lv_tabname) TO <fs_x_namtab>.` TO lt_ptab,
           `          lv_cond_line2 = |keyflag EQ 'X' AND viewfield NE 'MANDT'|.` TO lt_ptab,
           `          LOOP AT <fs_x_namtab> ASSIGNING <fs_x_namtab_wa> WHERE (lv_cond_line2).` TO lt_ptab,
           `            ASSIGN COMPONENT <fs_x_namtab_wa>-viewfield OF STRUCTURE <fs_total_wa> TO <fs_field>.` TO lt_ptab,
           `            IF sy-subrc IS INITIAL.` TO lt_ptab,
           `              objectid = objectid && <fs_field>.` TO lt_ptab,
           `              UNASSIGN <fs_field>.` TO lt_ptab,
           `            ENDIF.` TO lt_ptab,
           `          ENDLOOP.` TO lt_ptab,
           `          IF sy-subrc IS INITIAL.` TO lt_ptab,
           `            MOVE-CORRESPONDING <fs_total_wa> TO ` && vim_view_name && `.` TO lt_ptab,
           `            objectid        = objectid.` TO lt_ptab,
           `            tcode           = sy-tcode.` TO lt_ptab,
           `            udate           = sy-datum.` TO lt_ptab,
           `            utime           = sy-uzeit.` TO lt_ptab,
           `            username        = sy-uname.` TO lt_ptab,
           `            cdoc_upd_object = 'I'.` TO lt_ptab,
           `            upd_` && vim_view_name && ` = 'I'.` TO lt_ptab,
           `            PERFORM cd_call_` && <lv_obj> && `.` TO lt_ptab,
           `          ENDIF.` TO lt_ptab,
           `        WHEN 'D'. " Delete` TO lt_ptab,
           `          lv_tabname = '(SAPL` && lv_fugn && `)X_NAMTAB[]'.` TO lt_ptab,
           `          ASSIGN (lv_tabname) TO <fs_x_namtab>.` TO lt_ptab,
           `          lv_cond_line2 = |keyflag EQ 'X' AND viewfield NE 'MANDT'|.` TO lt_ptab,
           `          LOOP AT <fs_x_namtab> ASSIGNING <fs_x_namtab_wa> WHERE (lv_cond_line2).` TO lt_ptab,
           `            ASSIGN COMPONENT <fs_x_namtab_wa>-viewfield OF STRUCTURE <fs_total_wa> TO <fs_field>.` TO lt_ptab,
           `            IF sy-subrc IS INITIAL.` TO lt_ptab,
           `              objectid = objectid && <fs_field>.` TO lt_ptab,
           `              UNASSIGN <fs_field>.` TO lt_ptab,
           `            ENDIF.` TO lt_ptab,
           `          ENDLOOP.` TO lt_ptab,
           `          IF sy-subrc IS INITIAL.` TO lt_ptab,
           `            MOVE-CORRESPONDING <fs_total_wa> TO ` && vim_view_name && `.` TO lt_ptab,
           `            objectid        = objectid.` TO lt_ptab,
           `            tcode           = sy-tcode.` TO lt_ptab,
           `            udate           = sy-datum.` TO lt_ptab,
           `            utime           = sy-uzeit.` TO lt_ptab,
           `            username        = sy-uname.` TO lt_ptab,
           `            cdoc_upd_object = 'D'.` TO lt_ptab,
           `            upd_` && vim_view_name && ` = 'D'.` TO lt_ptab,
           `            PERFORM cd_call_` && <lv_obj> && `.` TO lt_ptab,
           `          ENDIF.` TO lt_ptab,
           `      ENDCASE.` TO lt_ptab,
           `      CLEAR: lv_cond_line, lv_cond_line2, objectid,` && vim_view_name && `,*` && vim_view_name && `.` TO lt_ptab,
           `    ENDLOOP.` TO lt_ptab,
           `  ENDFORM.` TO lt_ptab.
    "*-
    GENERATE SUBROUTINE POOL lt_ptab NAME lv_prog
             MESSAGE lv_mess
             SHORTDUMP-ID lv_sid.
    IF sy-subrc = 0.
      PERFORM ('F_PROCESS') IN PROGRAM (lv_prog) IF FOUND.
    ELSEIF sy-subrc = 4.
      MESSAGE lv_mess TYPE 'I'.
    ELSEIF sy-subrc = 8.
      MESSAGE lv_sid TYPE 'I'.
    ENDIF.
    CLEAR: lt_ptab.
  ENDLOOP.
ENDFORM.
*&----------------------------------------------------------------*
*&      Form  F_AFTER_SAVE
*&----------------------------------------------------------------*
FORM f_after_save ##CALLED.
  COMMIT WORK AND WAIT.
ENDFORM.