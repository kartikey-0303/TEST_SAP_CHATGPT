@EndUserText.label: 'T-Lane Upload Item (Consumption)'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_TLANE_UPL_I
  provider contract transactional_query
  as projection on ZI_TLANE_UPL_I
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
      _Header : redirected to parent ZC_TLANE_UPL_H
}
