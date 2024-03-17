*&---------------------------------------------------------------------*
*& Report Z_TREINO_ENTREVISTA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_treino_entrevista.

TYPE-POOLS: slis.

*(1)*******************************************************************
*Variáveis básicas para gerar ALV
DATA: lo_grid_100   TYPE REF TO cl_gui_alv_grid,
      lv_okcode_100 TYPE sy-ucomm,
      lt_fieldcat   TYPE lvc_t_fcat,
      ls_layout     TYPE lvc_s_layo,
      ls_variant    TYPE disvariant.
********************************************************************

"Types para armazenar tabela onde serão armazenados os dados
TYPES: BEGIN OF ty_spfli,
         carrid    TYPE spfli-carrid,
         connid    TYPE spfli-connid,
         countryfr TYPE spfli-countryfr,
         countryto TYPE spfli-countryto.
TYPES: END OF ty_spfli.

DATA: lt_spfli TYPE STANDARD TABLE OF ty_spfli.

SELECT carrid connid countryfr countryto FROM spfli INTO TABLE lt_spfli WHERE carrid NE ''.

IF lt_spfli[] IS NOT INITIAL.
*(2)*******************************************************************
  CALL SCREEN 100.
*(2)*******************************************************************
ENDIF.
*(3)*******************************************************************
MODULE build_grid OUTPUT.
  "Ajusta o tamanho do ALV
  ls_layout-cwidth_opt = 'X'.
  "ALV zebrado ou não
  ls_layout-zebra = 'X'.

  PERFORM build_grid.
ENDMODULE.

FORM build_grid .

  PERFORM f_build_fieldcat USING:
          'CARRID' 'CARRID' 'SPFLI' 'Airline code' '' '' '' '' '' '' CHANGING lt_fieldcat[],
          'CONNID' 'CONNID' 'SPFLI' 'Flight connection number' '' '' '' '' '' '' CHANGING lt_fieldcat[],
          'COUNTRYFR' 'COUNTRYFR' 'SPFLI' 'Country from' '' '' '' '' 'X' '' CHANGING lt_fieldcat[],
          'COUNTRYTO' 'COUNTRYTO' 'SPFLI' 'Country to' '' '' '' '' '' '' CHANGING lt_fieldcat[].

  IF lo_grid_100 IS INITIAL.

    lo_grid_100   = NEW cl_gui_alv_grid( i_parent = cl_gui_custom_container=>default_screen ).

    "Permite que mais de uma linha seja selecionada(para fins visuais)
    lo_grid_100->set_ready_for_input( 1 ).

    lo_grid_100->set_table_for_first_display(
      EXPORTING

        is_variant                    =    ls_variant
        is_layout                     =    ls_layout

      CHANGING
        it_fieldcatalog               =     lt_fieldcat[]
        it_outtab                     =     lt_spfli[]
      ) .

    "Titulo do ALV
    lo_grid_100->set_gridtitle( 'Lista de VOOS' ).

  ELSE.
    "Refresh dos dados para não construir o objeto novamente
    lo_grid_100->refresh_table_display( ).
  ENDIF.

ENDFORM.

FORM f_build_fieldcat USING VALUE(p_fieldname)  TYPE c
                            VALUE(p_field)      TYPE c
                            VALUE(p_table)      TYPE c
                            VALUE(p_coltext)    TYPE c
                            VALUE(p_checkbox)   TYPE c
                            VALUE(p_icon)       TYPE c
                            VALUE(p_emphasize)  TYPE c
                            VALUE(p_edit)       TYPE c
                            VALUE(p_hotspot)    TYPE c
                            VALUE(p_do_sum)     TYPE c
                            CHANGING t_fieldcat TYPE lvc_t_fcat.
  DATA: ls_fieldcat LIKE LINE OF t_fieldcat[].

  "Nome do campo dado na tabela interna
  ls_fieldcat-fieldname = p_fieldname.
  "Nome do campo na tabela transparente
  ls_fieldcat-ref_field = p_field.
  "Tabela transparente
  ls_fieldcat-ref_table = p_table.
  "Descrição que daremos para o campo no ALV.
  ls_fieldcat-coltext   = p_coltext.
  "Existe ou nao checkbox
  ls_fieldcat-checkbox  = p_checkbox.
  "Existe ou nao icone
  ls_fieldcat-icon  = p_icon.
  "Estabelece a cor a ser colocada na coluna
  ls_fieldcat-emphasize  = p_emphasize.
  "Estabelece se coluna pode ser editada ou não
  ls_fieldcat-edit       = p_edit.
  "Permite criar o hotspot, ou seja, quando se clicar no campo, aprece um pop up com info. adicionais
  ls_fieldcat-hotspot    = p_hotspot.
  "Permite realizar a sumarização de uma coluna(somente se a coluna for numérica)
  ls_fieldcat-do_sum     = p_do_sum.

  APPEND ls_fieldcat TO t_fieldcat[].
ENDFORM.

MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS100'.
  SET TITLEBAR 'TITLE100'.
ENDMODULE.

MODULE user_command_0100 INPUT.
  lv_okcode_100 = sy-ucomm.
  IF lv_okcode_100 EQ 'BACK' OR lv_okcode_100 EQ 'LEAVE' OR lv_okcode_100 EQ 'EXIT'.
    LEAVE PROGRAM.
  ENDIF.
ENDMODULE.
*(3)*******************************************************************