@EndUserText.label: 'T-Lane Upload Item'
@AccessControl.authorizationCheck: #CHECK
define view entity ZI_TLANE_UPL_I
  as select from zt_tlane_upl_i
  association to parent ZI_TLANE_UPL_H as _Header
    on $projection.upload_uuid = _Header.upload_uuid
{
  key upload_uuid,
  key item_no,
      matnr,
      locno_from,
      locno_to,
      mot,
      priority,
      creation_mode,
      order_unit,
      available_from,
      available_to,
      min_lot_size,
      rounding_value,
      trans_calendar,
      trans_cal_manual_fix,
      planned_deliv_time,
      ship_calendar,
      rec_calendar,
      cust_attr7,
      process_status,
      message_severity,
      message_text,
      target_lane_exists,
      _Header
}
