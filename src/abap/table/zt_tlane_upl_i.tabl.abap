@EndUserText.label : 'T-Lane Upload Item Staging'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zt_tlane_upl_i {
  key client               : abap.clnt not null;
  key upload_uuid          : sysuuid_x16 not null;
  key item_no              : abap.numc(6) not null;
  matnr                    : /ibp/matnr;
  locno_from               : /ibp/locno;
  locno_to                 : /ibp/locno;
  mot                      : /ibp/mot;
  priority                 : /ibp/priority;
  creation_mode            : /ibp/creation_mode;
  order_unit               : meins;
  available_from           : dats;
  available_to             : dats;
  min_lot_size             : /ibp/min_lot_size;
  rounding_value           : /ibp/rounding_value;
  trans_calendar           : scal_fcalid;
  trans_cal_manual_fix     : abap_boolean;
  planned_deliv_time       : /ibp/aplfz;
  ship_calendar            : scal_fcalid;
  rec_calendar             : scal_fcalid;
  cust_attr7               : /ibp/cust_attr7;
  process_status           : abap.char(20);
  message_severity         : abap.char(1);
  message_text             : abap.string(0);
  target_lane_exists       : abap_boolean;
}
