-- This script is customised from the official mimic repo for the septic
-- shock cluster use case.
-- [Datathon @London 2016 Dec]
--
-- This query pivots the vital signs for the first 24 hours of a patient's stay
-- Vital signs include heart rate, blood pressure, respiration rate, and temperature
-- Define which schema to work on
SET search_path TO mimiciii;

DROP MATERIALIZED VIEW IF EXISTS vitalsfirstday CASCADE;
create materialized view vitalsfirstday as
SELECT pvt.subject_id, pvt.hadm_id, pvt.icustay_id

-- Easier names
, min(case when VitalID = 1 then valuenum else null end) as HeartRate_Min
, max(case when VitalID = 1 then valuenum else null end) as HeartRate_Max
, avg(case when VitalID = 1 then valuenum else null end) as HeartRate_Mean
, min(case when VitalID = 2 then valuenum else null end) as SysBP_Min
, max(case when VitalID = 2 then valuenum else null end) as SysBP_Max
, avg(case when VitalID = 2 then valuenum else null end) as SysBP_Mean
, min(case when VitalID = 3 then valuenum else null end) as DiasBP_Min
, max(case when VitalID = 3 then valuenum else null end) as DiasBP_Max
, avg(case when VitalID = 3 then valuenum else null end) as DiasBP_Mean
, min(case when VitalID = 4 then valuenum else null end) as MeanBP_Min
, max(case when VitalID = 4 then valuenum else null end) as MeanBP_Max
, avg(case when VitalID = 4 then valuenum else null end) as MeanBP_Mean
-- , min(case when VitalID = 5 then valuenum else null end) as RespRate_Min
-- , max(case when VitalID = 5 then valuenum else null end) as RespRate_Max
-- , avg(case when VitalID = 5 then valuenum else null end) as RespRate_Mean
-- , min(case when VitalID = 6 then valuenum else null end) as TempC_Min
-- , max(case when VitalID = 6 then valuenum else null end) as TempC_Max
-- , avg(case when VitalID = 6 then valuenum else null end) as TempC_Mean
-- , min(case when VitalID = 7 then valuenum else null end) as SpO2_Min
-- , max(case when VitalID = 7 then valuenum else null end) as SpO2_Max
-- , avg(case when VitalID = 7 then valuenum else null end) as SpO2_Mean
-- , min(case when VitalID = 8 then valuenum else null end) as Glucose_Min
-- , max(case when VitalID = 8 then valuenum else null end) as Glucose_Max
-- , avg(case when VitalID = 8 then valuenum else null end) as Glucose_Mean
, min(case when VitalID = 5 then valuenum else null end) as CI_Min
, max(case when VitalID = 5 then valuenum else null end) as CI_Max
, avg(case when VitalID = 5 then valuenum else null end) as CI_Mean
, min(case when VitalID = 6 then valuenum else null end) as CO_Min
, max(case when VitalID = 6 then valuenum else null end) as CO_Max
, avg(case when VitalID = 6 then valuenum else null end) as CO_Mean
, min(case when VitalID = 7 then valuenum else null end) as CVP_Min
, max(case when VitalID = 7 then valuenum else null end) as CVP_Max
, avg(case when VitalID = 7 then valuenum else null end) as CVP_Mean
, min(case when VitalID = 8 then valuenum else null end) as PAPs_Min
, max(case when VitalID = 8 then valuenum else null end) as PAPs_Max
, avg(case when VitalID = 8 then valuenum else null end) as PAPs_Mean
, min(case when VitalID = 9 then valuenum else null end) as PAPd_Min
, max(case when VitalID = 9 then valuenum else null end) as PAPd_Max
, avg(case when VitalID = 9 then valuenum else null end) as PAPd_Mean
, min(case when VitalID = 10 then valuenum else null end) as PAPm_Min
, max(case when VitalID = 10 then valuenum else null end) as PAPm_Max
, avg(case when VitalID = 10 then valuenum else null end) as PAPm_Mean
, min(case when VitalID = 11 then valuenum else null end) as EF_Min
, max(case when VitalID = 11 then valuenum else null end) as EF_Max
, avg(case when VitalID = 11 then valuenum else null end) as EF_Mean
, min(case when VitalID = 12 then valuenum else null end) as SvO2_Min
, max(case when VitalID = 12 then valuenum else null end) as SvO2_Max
, avg(case when VitalID = 12 then valuenum else null end) as SvO2_Mean
, max(case when VitalID = 13 then valuenum else null end) as Troponin_Max
, min(case when VitalID = 14 then valuenum else null end) as SVV_Min
, max(case when VitalID = 14 then valuenum else null end) as SVV_Max
, avg(case when VitalID = 14 then valuenum else null end) as SVV_Mean
, min(case when VitalID = 15 then valuenum else null end) as SV_Min
, max(case when VitalID = 15 then valuenum else null end) as SV_Max
, avg(case when VitalID = 15 then valuenum else null end) as SV_Mean
, min(case when VitalID = 16 then valuenum else null end) as SVI_Min
, max(case when VitalID = 16 then valuenum else null end) as SVI_Max
, avg(case when VitalID = 16 then valuenum else null end) as SVI_Mean
, min(case when VitalID = 17 then valuenum else null end) as SVRI_Min
, max(case when VitalID = 17 then valuenum else null end) as SVRI_Max
, avg(case when VitalID = 17 then valuenum else null end) as SVRI_Mean

FROM  (
  select ie.subject_id, ie.hadm_id, ie.icustay_id
  , case
    when itemid in (211,220045) and valuenum > 0 and valuenum < 300 then 1 -- HeartRate
    when itemid in (51,442,455,6701,220179,220050) and valuenum > 0 and valuenum < 400 then 2 -- SysBP
    when itemid in (8368,8440,8441,8555,220180,220051) and valuenum > 0 and valuenum < 300 then 3 -- DiasBP
    when itemid in (456,52,6702,443,220052,220181,225312) and valuenum > 0 and valuenum < 300 then 4 -- MeanBP
    --when itemid in (615,618,220210,224690) and valuenum > 0 and valuenum < 70 then 5 -- RespRate
    --when itemid in (223761,678) and valuenum > 70 and valuenum < 120  then 6 -- TempF, converted to degC in valuenum call
    --when itemid in (223762,676) and valuenum > 10 and valuenum < 50  then 6 -- TempC
    --when itemid in (646,220277) and valuenum > 0 and valuenum <= 100 then 7 -- SpO2
    -- when itemid in (807,811,1529,3745,3744,225664,220621,226537) and valuenum > 0 then 8 -- Glucose
    when itemid in (7610, 228177) and valuenum > 0 and valuenum < 15 then 5 -- CI
    when itemid in (40909, 41440, 220088) and valuenum > 0 and valuenum < 20 then 6 -- CO
    when itemid in (220074) and valuenum > 0 and valuenum < 30 then 7 -- CVP
    when itemid in (220059) and valuenum > 0 and valuenum < 120 then 8 -- PAP S
    when itemid in (220060) and valuenum > 0 and valuenum < 80 then 9 -- PAP D
    when itemid in (220061) and valuenum > 0 and valuenum < 100 then 10 -- PAP M
    when itemid in (226272) and valuenum > 0 and valuenum < 100 then 11 -- EF

    when itemid in (838) and valuenum > 0 and valuenum < 100 then 12 -- SvO2
    when itemid in (851) and valuenum > 0 and valuenum < 100000 then 13 -- Troponin
    when itemid in (227546) and valuenum > 0 and valuenum < 100 then 14 -- SVV (Arterial)
    when itemid in (227547) and valuenum > 10 and valuenum < 150 then 15 -- SV (Arterial)
    when itemid in (228182) and valuenum > 0 and valuenum < 150 then 16 -- SVI (PiCCO)
    when itemid in (228185) and valuenum > 100 and valuenum < 3000 then 17 -- SVRI (PiCCO)


    else null end as VitalID
      -- convert F to C
  , case when itemid in (223761,678) then (valuenum-32)/1.8 else valuenum end as valuenum

  from icustays ie
  left join chartevents ce
  on ie.subject_id = ce.subject_id and ie.hadm_id = ce.hadm_id and ie.icustay_id = ce.icustay_id
  and ce.charttime between ie.intime and ie.intime + interval '1' day
  -- exclude rows marked as error
  and ce.error IS DISTINCT FROM 1
  where ce.itemid in
  (
  -- HEART RATE
  211, --"Heart Rate"
  220045, --"Heart Rate"

  -- Systolic/diastolic

  51, --	Arterial BP [Systolic]
  442, --	Manual BP [Systolic]
  455, --	NBP [Systolic]
  6701, --	Arterial BP #2 [Systolic]
  220179, --	Non Invasive Blood Pressure systolic
  220050, --	Arterial Blood Pressure systolic

  8368, --	Arterial BP [Diastolic]
  8440, --	Manual BP [Diastolic]
  8441, --	NBP [Diastolic]
  8555, --	Arterial BP #2 [Diastolic]
  220180, --	Non Invasive Blood Pressure diastolic
  220051, --	Arterial Blood Pressure diastolic


  -- MEAN ARTERIAL PRESSURE
  456, --"NBP Mean"
  52, --"Arterial BP Mean"
  6702, --	Arterial BP Mean #2
  443, --	Manual BP Mean(calc)
  220052, --"Arterial Blood Pressure mean"
  220181, --"Non Invasive Blood Pressure mean"
  225312, --"ART BP mean"

  -- list added by HW
  -- co/ci
  7610, --cardiac index      o
  40909, --cardiac output
  41440, --cardiac output ml

  -- CVP
  220074, --Central Venous Pressure	CVP	metavision

  -- PAP
  220059, --Pulmonary Artery Pressure systolic
  220060, --Pulmonary Artery Pressure diastolic
  220061, --Pulmonary Artery Pressure mean

  -- EF
  226272, --EF (CCO)

  -- more
  838, --SvO2		carevue	chartevents	Mixed Venous Gases
  851, --	Troponin		carevue	chartevents	Enzymes
  220088, --	Cardiac Output (thermodilution)	CO (thermodilution)	metavision	chartevents	Hemodynamics	L/min	Numeric
  227546, --	SVV (Arterial)	SVV (Arterial)	metavision	chartevents	Hemodynamics	%	Numeric
  227547, --	SV (Arterial)	SV (Arterial)	metavision	chartevents	Hemodynamics	mL/beat	Numeric
  228177, --	CI (PiCCO)	CI (PiCCO)	metavision	chartevents	PiCCO	L/min/m2	Numeric
  228182, --	SVI (PiCCO)	SVI (PiCCO)	metavision	chartevents	PiCCO	mL/m2	Numeric
  228185 --	SVRI (PiCCO)	SVRI (PiCCO)	metavision	chartevents	PiCCO	dynes.sec.cm-5/m2	Numeric


  -- RESPIRATORY RATE
  -- 618,--	Respiratory Rate
  -- 615,--	Resp Rate (Total)
  -- 220210,--	Respiratory Rate
  -- 224690, --	Respiratory Rate (Total)


  -- SPO2, peripheral
  -- 646, 220277,

  -- GLUCOSE, both lab and fingerstick
  -- 807,--	Fingerstick Glucose
  -- 811,--	Glucose (70-105)
  -- 1529,--	Glucose
  -- 3745,--	BloodGlucose
  -- 3744,--	Blood Glucose
  -- 225664,--	Glucose finger stick
  -- 220621,--	Glucose (serum)
  -- 226537,--	Glucose (whole blood)

  -- TEMPERATURE
  -- 223762, -- "Temperature Celsius"
  -- 676,	-- "Temperature C"
  -- 223761, -- "Temperature Fahrenheit"
  -- 678 --	"Temperature F"

  )
) pvt
group by pvt.subject_id, pvt.hadm_id, pvt.icustay_id
order by pvt.subject_id, pvt.hadm_id, pvt.icustay_id;

commit;