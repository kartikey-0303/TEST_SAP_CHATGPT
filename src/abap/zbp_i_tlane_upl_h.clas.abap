CLASS zbp_i_tlane_upl_h DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_abap_behavior_handler.

  PRIVATE SECTION.
    METHODS validate FOR MODIFY
      IMPORTING keys FOR ACTION zi_tlane_upl_h~Validate RESULT result.

    METHODS process FOR MODIFY
      IMPORTING keys FOR ACTION zi_tlane_upl_h~Process RESULT result.
ENDCLASS.

CLASS zbp_i_tlane_upl_h IMPLEMENTATION.

  METHOD validate.
    " Optional batch-level validation orchestration.
    result = VALUE #( FOR key IN keys ( %tky = key-%tky ) ).
  ENDMETHOD.

  METHOD process.
    " Optional batch-level process orchestration; delegate to item action/process engine.
    result = VALUE #( FOR key IN keys ( %tky = key-%tky ) ).
  ENDMETHOD.

ENDCLASS.
