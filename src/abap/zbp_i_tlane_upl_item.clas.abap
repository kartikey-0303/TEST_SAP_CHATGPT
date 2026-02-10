CLASS zbp_i_tlane_upl_item DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_abap_behavior_handler.

  PRIVATE SECTION.
    METHODS validate_item FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_tlane_upl_i~validate_item.

    METHODS determine_defaults FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_tlane_upl_i~determine_defaults.

    METHODS processupload FOR MODIFY
      IMPORTING keys FOR ACTION zi_tlane_upl_i~processUpload RESULT result.
ENDCLASS.

CLASS zbp_i_tlane_upl_item IMPLEMENTATION.

  METHOD validate_item.
    READ ENTITIES OF zi_tlane_upl_h IN LOCAL MODE
      ENTITY _Items
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    DATA(lo_engine) = NEW zcl_tlane_rule_engine( ).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).
      TRY.
          lo_engine->validate_only(
            VALUE zcl_tlane_rule_engine=>ty_item(
              matnr          = <item>-matnr
              locno_from     = <item>-locno_from
              locno_to       = <item>-locno_to
              mot            = <item>-mot
              priority       = <item>-priority
              available_from = <item>-available_from
              available_to   = <item>-available_to
              min_lot_size   = <item>-min_lot_size
              rounding_value = <item>-rounding_value ) ).
        CATCH cx_static_check INTO DATA(lx_err).
          APPEND VALUE #( %tky = <item>-%tky ) TO failed-_Items.
          APPEND VALUE #( %tky = <item>-%tky
                          %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text     = lx_err->get_text( ) ) ) TO reported-_Items.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD determine_defaults.
    READ ENTITIES OF zi_tlane_upl_h IN LOCAL MODE
      ENTITY _Items
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    DATA(lo_engine) = NEW zcl_tlane_rule_engine( ).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).
      DATA(ls_item) = VALUE zcl_tlane_rule_engine=>ty_item(
        matnr                = <item>-matnr
        locno_from           = <item>-locno_from
        locno_to             = <item>-locno_to
        mot                  = <item>-mot
        priority             = <item>-priority
        creation_mode        = <item>-creation_mode
        order_unit           = <item>-order_unit
        available_from       = <item>-available_from
        available_to         = <item>-available_to
        trans_calendar       = <item>-trans_calendar
        trans_cal_manual_fix = <item>-trans_cal_manual_fix
        planned_deliv_time   = <item>-planned_deliv_time
        ship_calendar        = <item>-ship_calendar
        rec_calendar         = <item>-rec_calendar
        cust_attr7           = <item>-cust_attr7
        min_lot_size         = <item>-min_lot_size
        rounding_value       = <item>-rounding_value ).

      TRY.
          lo_engine->apply_rules( CHANGING cs_item = ls_item ).
          <item>-creation_mode      = ls_item-creation_mode.
          <item>-order_unit         = ls_item-order_unit.
          <item>-trans_calendar     = ls_item-trans_calendar.
          <item>-planned_deliv_time = ls_item-planned_deliv_time.
          <item>-ship_calendar      = ls_item-ship_calendar.
          <item>-rec_calendar       = ls_item-rec_calendar.
          <item>-cust_attr7         = ls_item-cust_attr7.
        CATCH cx_static_check.
          " Error reporting is handled in validation and process action
      ENDTRY.
    ENDLOOP.

    MODIFY ENTITIES OF zi_tlane_upl_h IN LOCAL MODE
      ENTITY _Items
      UPDATE FIELDS ( creation_mode order_unit trans_calendar planned_deliv_time ship_calendar rec_calendar cust_attr7 )
      WITH CORRESPONDING #( items ).
  ENDMETHOD.

  METHOD processupload.
    " Integration point to call posting routine that performs UPSERT into /IBP/TLANE_EXT.
    " Recommended implementation:
    "  1) Read staging records for keys
    "  2) Run validation/defaulting once more for robustness
    "  3) Use MODIFY on /IBP/TLANE_EXT with mapped structure
    "  4) Update process_status and messages

    result = VALUE #( FOR key IN keys
                      ( %tky = key-%tky ) ).
  ENDMETHOD.

ENDCLASS.
