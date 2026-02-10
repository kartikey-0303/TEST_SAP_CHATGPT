CLASS ltc_tlane_rule_engine DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS validate_date_range FOR TESTING.
ENDCLASS.

CLASS ltc_tlane_rule_engine IMPLEMENTATION.
  METHOD validate_date_range.
    DATA(lo_cut) = NEW zcl_tlane_rule_engine( ).
    DATA(ls_item) = VALUE zcl_tlane_rule_engine=>ty_item(
      available_from = '19690101'
      available_to   = '99991231' ).

    TRY.
        lo_cut->validate_only( ls_item ).
        cl_abap_unit_assert=>fail( msg = 'Expected exception was not raised' ).
      CATCH cx_static_check.
        cl_abap_unit_assert=>assert_true( abap_true ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
