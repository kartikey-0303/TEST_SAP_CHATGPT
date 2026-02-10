@EndUserText.label: 'T-Lane Upload Header'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZI_TLANE_UPL_H
  as select from zt_tlane_upl_h
  composition [0..*] of ZI_TLANE_UPL_I as _Items
{
  key upload_uuid,
      uploaded_by,
      uploaded_at,
      source_file_name,
      total_records,
      success_records,
      error_records,
      process_status,
      message_text,
      _Items
}
