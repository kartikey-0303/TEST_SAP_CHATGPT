CLASS zcl_tlane_rule_engine DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             matnr                TYPE /ibp/matnr,
             locno_from           TYPE /ibp/locno,
             locno_to             TYPE /ibp/locno,
             mot                  TYPE /ibp/mot,
             priority             TYPE /ibp/priority,
             creation_mode        TYPE /ibp/creation_mode,
             order_unit           TYPE meins,
             available_from       TYPE dats,
             available_to         TYPE dats,
             trans_calendar       TYPE scal-fcalid,
             trans_cal_manual_fix TYPE abap_boolean,
             planned_deliv_time   TYPE /ibp/aplfz,
             ship_calendar        TYPE scal-fcalid,
             rec_calendar         TYPE scal-fcalid,
             cust_attr7           TYPE /ibp/cust_attr7,
             min_lot_size         TYPE /ibp/min_lot_size,
             rounding_value       TYPE /ibp/rounding_value,
           END OF ty_item.

    METHODS apply_rules
      CHANGING cs_item TYPE ty_item
      RAISING  cx_static_check.

    METHODS validate_only
      IMPORTING is_item TYPE ty_item
      RAISING   cx_static_check.

  PRIVATE SECTION.
    METHODS default_creation_mode CHANGING cs_item TYPE ty_item.
    METHODS default_order_unit    CHANGING cs_item TYPE ty_item.
    METHODS validate_master_data  IMPORTING is_item TYPE ty_item.
    METHODS validate_dates        IMPORTING is_item TYPE ty_item.
    METHODS validate_priority     IMPORTING is_item TYPE ty_item.
    METHODS apply_calendar_logic  CHANGING cs_item TYPE ty_item.
    METHODS apply_pdt_logic       CHANGING cs_item TYPE ty_item.
    METHODS apply_attr7_logic     CHANGING cs_item TYPE ty_item.
    METHODS apply_grpt_logic      CHANGING cs_item TYPE ty_item.

    METHODS get_lane_exists
      IMPORTING is_item        TYPE ty_item
      RETURNING VALUE(rv_yes)  TYPE abap_boolean.
ENDCLASS.

CLASS zcl_tlane_rule_engine IMPLEMENTATION.

  METHOD apply_rules.
    default_creation_mode( CHANGING cs_item = cs_item ).
    default_order_unit(    CHANGING cs_item = cs_item ).

    validate_master_data( is_item = cs_item ).
    validate_dates(       is_item = cs_item ).
    validate_priority(    is_item = cs_item ).

    apply_calendar_logic( CHANGING cs_item = cs_item ).
    apply_pdt_logic(      CHANGING cs_item = cs_item ).
    apply_attr7_logic(    CHANGING cs_item = cs_item ).
    apply_grpt_logic(     CHANGING cs_item = cs_item ).
  ENDMETHOD.

  METHOD validate_only.
    validate_master_data( is_item = is_item ).
    validate_dates(       is_item = is_item ).
    validate_priority(    is_item = is_item ).
  ENDMETHOD.

  METHOD default_creation_mode.
    IF get_lane_exists( cs_item ) = abap_true.
      SELECT SINGLE creation_mode
        FROM /ibp/tlane_ext
        WHERE matnr      = @cs_item-matnr
          AND locno_from = @cs_item-locno_from
          AND locno_to   = @cs_item-locno_to
          AND mot        = @cs_item-mot
          AND priority   = @cs_item-priority
        INTO @cs_item-creation_mode.
    ELSE.
      cs_item-creation_mode = 'M'.
    ENDIF.
  ENDMETHOD.

  METHOD default_order_unit.
    IF get_lane_exists( cs_item ) = abap_true.
      SELECT SINGLE order_unit
        FROM /ibp/tlane_ext
        WHERE matnr      = @cs_item-matnr
          AND locno_from = @cs_item-locno_from
          AND locno_to   = @cs_item-locno_to
          AND mot        = @cs_item-mot
          AND priority   = @cs_item-priority
        INTO @cs_item-order_unit.
    ELSEIF cs_item-order_unit IS INITIAL.
      SELECT SINGLE meins
        FROM /ibp/mara_ext
        WHERE matnr = @cs_item-matnr
        INTO @cs_item-order_unit.
    ENDIF.
  ENDMETHOD.

  METHOD validate_master_data.
    SELECT SINGLE matnr FROM /ibp/mara_ext WHERE matnr = @is_item-matnr INTO @DATA(lv_matnr).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_static_check.
    ENDIF.

    SELECT SINGLE locno FROM /ibp/loc_ext WHERE locno = @is_item-locno_from INTO @DATA(lv_from).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_static_check.
    ENDIF.

    SELECT SINGLE locno FROM /ibp/loc_ext WHERE locno = @is_item-locno_to INTO @DATA(lv_to).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_static_check.
    ENDIF.

    SELECT SINGLE mot FROM /ibp/mot_ext WHERE mot = @is_item-mot INTO @DATA(lv_mot).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_static_check.
    ENDIF.

    SELECT SINGLE matnr
      FROM /ibp/marc_ext
      WHERE matnr = @is_item-matnr
        AND locno = @is_item-locno_to
      INTO @DATA(lv_marc).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_static_check.
    ENDIF.
  ENDMETHOD.

  METHOD validate_dates.
    IF is_item-available_from < '19700101' OR is_item-available_to > '99991231'.
      RAISE EXCEPTION TYPE cx_static_check.
    ENDIF.
  ENDMETHOD.

  METHOD validate_priority.
    IF is_item-priority = 1
       AND ( is_item-min_lot_size IS NOT INITIAL OR is_item-rounding_value IS NOT INITIAL ).
      RAISE EXCEPTION TYPE cx_static_check.
    ENDIF.
  ENDMETHOD.

  METHOD apply_calendar_logic.
    SELECT SINGLE ztrans_calendar, shipping_calendar, receiving_calendar, transport_duration
      FROM zibpt_mot_rule
      WHERE zlocno_to   = @cs_item-locno_to
        AND zlocno_from = @cs_item-locno_from
        AND zmot_id     = @cs_item-mot
      INTO @DATA(ls_rule).

    IF cs_item-trans_calendar IS INITIAL OR cs_item-trans_cal_manual_fix <> abap_true.
      cs_item-trans_calendar = ls_rule-ztrans_calendar.
    ENDIF.

    IF cs_item-ship_calendar IS INITIAL.
      cs_item-ship_calendar = ls_rule-shipping_calendar.
      IF cs_item-ship_calendar IS INITIAL.
        SELECT SINGLE fabkl FROM t001w WHERE werks = @cs_item-locno_from INTO @cs_item-ship_calendar.
      ENDIF.
    ENDIF.

    IF cs_item-rec_calendar IS INITIAL.
      cs_item-rec_calendar = ls_rule-receiving_calendar.
      IF cs_item-rec_calendar IS INITIAL.
        SELECT SINGLE fabkl FROM t001w WHERE werks = @cs_item-locno_to INTO @cs_item-rec_calendar.
      ENDIF.
    ENDIF.

    IF cs_item-planned_deliv_time IS INITIAL.
      cs_item-planned_deliv_time = ls_rule-transport_duration.
    ENDIF.
  ENDMETHOD.

  METHOD apply_pdt_logic.
    " Planned delivery time is defaulted in apply_calendar_logic from rule table when blank.
  ENDMETHOD.

  METHOD apply_attr7_logic.
    IF cs_item-cust_attr7 IS INITIAL.
      SELECT SINGLE mtart FROM /ibp/mara_ext WHERE matnr = @cs_item-matnr INTO @DATA(lv_mtart).
      IF sy-subrc = 0.
        SELECT SINGLE ztfreezehorizon
          FROM zibp_mattype_param
          WHERE mtart = @lv_mtart
          INTO @cs_item-cust_attr7.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD apply_grpt_logic.
    SELECT SINGLE webaz
      FROM /ibp/marc_ext
      WHERE matnr = @cs_item-matnr
        AND locno = @cs_item-locno_to
        AND beskz = 'F'
      INTO @DATA(lv_webaz).

    IF sy-subrc = 0.
      " In final posting map lv_webaz to /IBP/TLANE_EXT-WEBAZ
    ENDIF.
  ENDMETHOD.

  METHOD get_lane_exists.
    SELECT SINGLE @abap_true
      FROM /ibp/tlane_ext
      WHERE matnr      = @is_item-matnr
        AND locno_from = @is_item-locno_from
        AND locno_to   = @is_item-locno_to
        AND mot        = @is_item-mot
        AND priority   = @is_item-priority
      INTO @rv_yes.

    IF sy-subrc <> 0.
      rv_yes = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
