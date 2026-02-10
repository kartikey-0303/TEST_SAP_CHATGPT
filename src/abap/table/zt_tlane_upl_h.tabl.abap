@EndUserText.label : 'T-Lane Upload Header Staging'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zt_tlane_upl_h {
  key client         : abap.clnt not null;
  key upload_uuid    : sysuuid_x16 not null;
  uploaded_by        : syuname;
  uploaded_at        : timestampl;
  source_file_name   : abap.char(255);
  total_records      : abap.int4;
  success_records    : abap.int4;
  error_records      : abap.int4;
  process_status     : abap.char(20);
  message_text       : abap.string(0);
}
