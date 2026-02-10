@EndUserText.label: 'T-Lane Upload Header (Consumption)'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_TLANE_UPL_H
  provider contract transactional_query
  as projection on ZI_TLANE_UPL_H
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
      _Items : redirected to composition child ZC_TLANE_UPL_I
}
