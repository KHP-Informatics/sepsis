--1. select all with an infection who do not have a diagnosis code - control group
select * from sepsis.final where hadm_id in (
select distinct sepsis.final.hadm_id from sepsis.final, mimicfull.diagnoses_icd where sepsis.final.hadm_id = mimicfull.diagnoses_icd.hadm_id and sofa >=2 and  lactate_max is not null and troponin_max is not null and  sepsis.final.hadm_id not in(
select sepsis.final.hadm_id from sepsis.Final, mimicfull.diagnoses_icd where sepsis.final.hadm_id = mimicfull.diagnoses_icd.hadm_id and (mimicfull.diagnoses_icd.icd9_code like '%99590%' or mimicfull.diagnoses_icd.icd9_code like '%99591%' or
mimicfull.diagnoses_icd.icd9_code like '%99592%' or mimicfull.diagnoses_icd.icd9_code like '%99593%' or
mimicfull.diagnoses_icd.icd9_code like '%99594%' )));

--2. select all that have been diagnosed with sepsis or septic shock - case group
select * from sepsis.final where hadm_id in(
select distinct sepsis.final.hadm_id from sepsis.Final, mimicfull.diagnoses_icd where sepsis.final.hadm_id = mimicfull.diagnoses_icd.hadm_id and (mimicfull.diagnoses_icd.icd9_code like '%99590%' or mimicfull.diagnoses_icd.icd9_code like '%99591%' or
mimicfull.diagnoses_icd.icd9_code like '%99592%' or mimicfull.diagnoses_icd.icd9_code like '%99593%' or
mimicfull.diagnoses_icd.icd9_code like '%99594%' ) and troponin_max is not null and lactate_max is not null);

