# Functional Specification (FS)
## SAP RAP-based Fiori App for T-Lane Upload & Maintenance

## 1) Objective
Build a SAP RAP based Fiori Elements application to upload, create, and update transportation lanes (`/IBP/TLANE_EXT`) with strict business validations, defaulting rules, and controlled update logic.

---

## 2) Scope
### In Scope
- File upload (CSV/XLSX) for mass create/update of T-Lane records.
- RAP BO for T-Lane staging + posting to `/IBP/TLANE_EXT`.
- Validation and determination logic as listed in this FS.
- Error log per row during upload processing.

### Out of Scope
- Changes to external master data governance process.
- Generic data migration framework.

---

## 3) Target Architecture (RAP)
- **Root Entity**: `ZI_TLANE_UPL` (upload header/batch)
- **Child Entity**: `ZI_TLANE_UPL_ITEM` (row-level payload)
- **Persistence/Staging tables**:
  - `ZT_TLANE_UPL_H`
  - `ZT_TLANE_UPL_I`
- **Processing class**: `ZCL_TLANE_RULE_ENGINE`
- **Final update target**: `/IBP/TLANE_EXT`
- **Fiori app type**: Fiori Elements (List Report + Object Page)

### RAP Behavior Recommendations
- Determinations on save for defaulting.
- Validations on save for business checks.
- Action `processUpload` to post valid rows into `/IBP/TLANE_EXT`.
- Row status fields: `process_status`, `message_text`, `message_severity`.

---

## 4) Field Rules and Validations

### 4.1 Creation Mode (`CREATION_MODE`)
1. Field must be **non-editable** in UI.
2. If creating a new T-Lane (record not existing in `/IBP/TLANE_EXT`), set `CREATION_MODE = 'M'`.
3. If T-Lane exists and is re-uploaded (with/without creation mode in file), preserve existing `CREATION_MODE` from current record.

### 4.2 Order Unit (`ORDER_UNIT`)
1. For existing records, `ORDER_UNIT` must be non-editable.
2. For new records, if empty/invalid, default from product base UoM: `/IBP/MARA_EXT-MEINS`.

### 4.3 Master Data Existence Checks
Validate uploaded values against reference tables:
- `MATNR` against `/IBP/MARA_EXT`
- `LOCNO_FROM`, `LOCNO_TO` against `/IBP/LOC_EXT`
- Material-Location combination against `/IBP/MARC_EXT`
- `MOT` against `/IBP/MOT_EXT`

### 4.4 Date Range
- `AVAILABLE_FROM` and `AVAILABLE_TO` must be between `19700101` and `99991231`.

### 4.5 Min Lot Size and Rounding Value
- Fields are editable.
- For primary lanes (`PRIORITY = 1`), values must **not** be updated from this app.
- For secondary lanes (`PRIORITY > 1`), update allowed.

---

## 5) Defaulting and Update Logic

### 5.1 Transportation Calendar (`TRANS_CALENDAR`)
1. If file value is blank:
   - Read `ZIBPT_MOT_RULE` where:
     - `ZLOCNO_TO = LOCNO_TO`
     - `ZLOCNO_FROM = LOCNO_FROM`
     - `ZMOT_ID = MOT`
   - Default `TRANS_CALENDAR = ZTRANS_CALENDAR`.
2. If file value is provided:
   - If `TRANS_CAL_MANUAL_FIX = 'X'`, keep file value.
   - Else ignore file value and apply default logic from `ZIBPT_MOT_RULE`.

### 5.2 Planned Delivery Time (`APLFZ`)
- If file has value in `PLANNED_DELIV_TIME`, update `/IBP/TLANE_EXT-APLFZ`.
- Else default from `ZIBP_MOT_RULE-TRANSPORT_DURATION`.

### 5.3 Shipping Calendar (`SHIP_CALENDAR`)
1. If file has value, use it.
2. Else use `ZIBP_MOT_RULE-SHIPPING_CALENDAR`.
3. If still blank, fallback from `T001W`:
   - `T001W-WERKS = Ship From Location`
   - `SHIP_CALENDAR = T001W-FABKL`

### 5.4 Receiving Calendar (`REC_CALENDAR`)
1. If file has value, use it.
2. Else use `ZIBP_MOT_RULE-RECEIVING_CALENDAR`.
3. If still blank, fallback from `T001W`:
   - `T001W-WERKS = Ship To Location`
   - `REC_CALENDAR = T001W-FABKL`

### 5.5 Custom Attribute 7 (`CUST_ATTR7`)
1. If file has value, use it.
2. Else derive material type (`MTART`) from `/IBP/MARA_EXT` for `MATNR`.
3. Default from `ZIBP_MATTYPE_PARAM-ZTFREEZEHORIZON`.

### 5.6 GR Processing Time (`WEBAZ`)
- If procurement type is external:
  - Read `/IBP/MARC_EXT` with
    - `LOCNO = /IBP/TLANE_EXT-LOCNO_TO`
    - `MATNR = /IBP/TLANE_EXT-MATNR`
    - `BESKZ = 'F'`
  - Set `/IBP/TLANE_EXT-WEBAZ = /IBP/MARC_EXT-WEBAZ`.

---

## 6) Key Derivation for Existence Check
T-Lane existence should be checked with the technical/business key used in `/IBP/TLANE_EXT` (typically material + from location + to location + mode of transport + priority, as applicable in data model).

---

## 7) Error Handling
- Process each row independently.
- On validation failure:
  - Mark row as `Error`.
  - Persist detailed message(s).
  - Continue with other rows.
- On success:
  - Mark row as `Posted` with target key.

---

## 8) Fiori UI Requirements
- List report with upload batch, status counts, and action buttons:
  - `Upload File`
  - `Validate`
  - `Process`
  - `Download Error Log`
- Object page with row-level messages.
- Non-editable fields in UI for existing records:
  - `CREATION_MODE`
  - `ORDER_UNIT`

---

## 9) RAP Technical Build Items
1. CDS Views:
   - Interface + Projection for header/item.
2. Behavior Definitions:
   - Determinations: defaults.
   - Validations: business checks.
   - Action: `processUpload`.
3. ABAP Class:
   - `ZCL_TLANE_RULE_ENGINE` encapsulating all lookup/default logic.
4. Authorization:
   - Restrict process action to planner/admin roles.
5. Logging:
   - Application log object/subobject for run traceability.

---

## 10) Pseudocode for Processing Sequence
1. Parse upload file into item staging.
2. For each row:
   - Determine existence of target T-Lane.
   - Apply editability rules (`CREATION_MODE`, `ORDER_UNIT`).
   - Run master data/date validations.
   - Apply defaulting logic (calendar, PDT, attr7, WEBAZ).
   - Enforce primary-lane restriction for lot-size/rounding.
   - If valid, upsert `/IBP/TLANE_EXT`; else log error.
3. Return run summary.

---

## 11) Acceptance Criteria
- New lanes auto-set `CREATION_MODE = 'M'`.
- Existing lanes keep original `CREATION_MODE`.
- `ORDER_UNIT` defaults from base UoM when needed for new lanes.
- All table validation checks are enforced.
- Date limits enforced.
- Primary-lane lot-size/rounding update blocked.
- Calendar/PDT/Attr7/WEBAZ logic behaves exactly as specified.
- Batch processing provides complete error reporting without full-run abort.

---

## 12) Suggested Test Scenarios (Minimum)
1. New lane, blank creation mode => stored as `M`.
2. Existing lane, file mode differs => existing mode retained.
3. New lane, blank/invalid order unit => defaulted from `/IBP/MARA_EXT-MEINS`.
4. Invalid material/location/MOT => row error.
5. Date out of range => row error.
6. Priority 1 with changed min lot/rounding => blocked.
7. Transportation calendar blank => default from `ZIBPT_MOT_RULE`.
8. Transportation calendar provided + manual fix `X` => keep file value.
9. Shipping/Receiving fallback to `T001W-FABKL` when rule table blank.
10. `CUST_ATTR7` default by material type parameter.
11. GR processing time set when BESKZ = `F`.
