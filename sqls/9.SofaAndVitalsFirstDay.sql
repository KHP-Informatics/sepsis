--NEED TO SELECT APPROPRIATE VARIABLES

set search_path to mimicfull; 

DROP VIEW IF EXISTS sepsis.sepsis_vitals_sofa cascade;

CREATE VIEW sepsis.sepsis_vitals_sofa AS
(
SELECT sepsis.dependent_variables2.subject_id,
	   sepsis.dependent_variables2.hadm_id,
	   sepsis.dependent_variables2.icustay_id
   	   ,
	   	   case when sepsis.dependent_variables2.Troponin_Max_Everywhere is null then 
	   	    		sepsis.dependent_variables2.troponin_max
	   			else cast(sepsis.dependent_variables2.Troponin_Max_Everywhere as double precision) end as troponin_max
	   			
	   ,sepsis.dependent_variables2.heartrate_max
	   ,sepsis.dependent_variables2.heartrate_min
	   ,
	   	  case when sepsis.dependent_variables2.SodiumBicarbonate_Min is null then 
	   			sepsis.labsfirstday.BICARBONATE_min
	   	   else sepsis.dependent_variables2.SodiumBicarbonate_Min end as SodiumBicarbonate_Min
		, 
	   sepsis.dependent_variables2.Lactatedehydrogenase_max
	   /*
	   sepsis.dependent_variables2.BNatriureticPeptide_Max,
	   sepsis.dependent_variables2.CReactiveProtein_Max,
	   sepsis.dependent_variables2.Triglycerides_Min,
	   sepsis.dependent_variables2.Cholestrol_Min,
	   sepsis.dependent_variables2.cholesterolratio_min,
	   sepsis.dependent_variables2.HighDensityLipoprotein_Min, 
	   sepsis.dependent_variables2.LowDensityLipoprotein_Min
	   */
	   ,sepsis.dependent_variables2.Temperature_Min
	   ,sepsis.dependent_variables2.Temperature_Max
	   ,sepsis.dependent_variables2.SysBP_Min
	   ,sepsis.dependent_variables2.DiasBP_Min
	   ,sepsis.dependent_variables2.MeanBP_Min
	   ,sepsis.dependent_variables2.Spontaneous_respiratory_rate_Min
	   ,sepsis.dependent_variables2.Spontaneous_respiratory_rate_Max
	   ,MAP_MIN
	   ,CardiacIndex_Min_Everywhere as CardiacIndex_Min,
	   CardiacIndex_Max_Everywhere as CardiacIndex_Max,
	   STROKEINDEX_MIN_EVERYWHERE as StrokeIndex_Min,
	   systemicvascularresistancesindex_min_everywhere as SystemicVascularResistancesIndex_Min,
	   systemicvascularresistancesindex_max_everywhere as SystemicVascularResistancesIndex_Max,
	   sepsis.dependent_variables2.CentralVenousPressure_Min,
	   sepsis.dependent_variables2.CentralVenousPressure_Max,
	   sepsis.dependent_variables2.PeripheralSaturation_Min,
	   /*
	   sepsis.dependent_variables2.CentralVenousOxygenSaturation_Min,
	   sepsis.dependent_variables2.CentralVenousOxygenSaturation_Max,
	   */
	   	--case when fio2_min_final > 1 then 
		--fio2_min_final/100
		--else fio2_min_final end as fio2_min,
		fio2_min_final as fio2_min,
	   cao2_everywhere as cao2_min, 
	   paco2_max_final as paco2_max,
	   sepsis.dependent_variables2.PvCO2_Max,
	   case when sepsis.dependent_variables2.Creatinine_Max is null then 
	   			sepsis.labsfirstday.Creatinine_Max
	   		else sepsis.dependent_variables2.Creatinine_Max end as Creatinine_Max
	   ,
	   case when sepsis.dependent_variables2.WhiteBloodCellCount_Min is null or sepsis.dependent_variables2.WhiteBloodCellCount_Min= 0 then 
	   			sepsis.labsfirstday.wbc_min*1000000
	   		else sepsis.dependent_variables2.WhiteBloodCellCount_Min end as WhiteBloodCellCount_Min
	   ,
	   case when sepsis.dependent_variables2.WhiteBloodCellCount_Max is null or sepsis.dependent_variables2.WhiteBloodCellCount_Max = 0 then 
	   			sepsis.labsfirstday.wbc_max*1000000
	   		else sepsis.dependent_variables2.WhiteBloodCellCount_Max end as WhiteBloodCellCount_Max
	   ,
	   sepsis.dependent_variables2.Neutrophils_Min_everywhere as Neutrophils_Min,
	   sepsis.dependent_variables2.Neutrophils_Max_everywhere as Neutrophils_Max,
	   sepsis.dependent_variables2.Eosinophils_Min_everywhere as Eosinophils_Min,
	   sepsis.dependent_variables2.Eosinophils_Max_everywhere as Eosinophils_Max,
	   sepsis.dependent_variables2.lymphocytes_min_eveywhere as Lymphocytes_Min,
	   sepsis.dependent_variables2.lymphocytes_max_eveywhere as Lymphocytes_Max,
	   sepsis.dependent_variables2.AtypicalLeukocytes_Min,
	   sepsis.dependent_variables2.AtypicalLeukocytes_Max
	   ,
	   case when sepsis.dependent_variables2.Bandforms_Min is null then 
	   			sepsis.labsfirstday.Bands_Min
	   		else sepsis.dependent_variables2.Bandforms_Min end as Bandforms_Min
	   ,
	   case when sepsis.dependent_variables2.Bandforms_Max is null then 
	   			sepsis.labsfirstday.Bands_Max
	   		else sepsis.dependent_variables2.Bandforms_Max end as Bandforms_Max
	   ,
	   case when sepsis.dependent_variables2.Platelets is null then 
	   			sepsis.dependent_variables2.Platelets
	   		else sepsis.dependent_variables2.Platelets end as Platelets_Min		
	   ,
	   sepsis.dependent_variables2.DDimer_Max_Everywhere as DDimer_Max
	   ,INR_Max
	   ,PTT_Max
	   ,
	   sepsis.dependent_variables2.Fibrinogen as Fibrinogen_Max
	   ,sepsis.dependent_variables2.Glucose_Min
	   ,sepsis.dependent_variables2.Glucose_Max
	   ,
	   case when sepsis.dependent_variables2.Albumin is null then 
	   			sepsis.labsfirstday.Albumin_Min
	   		else sepsis.dependent_variables2.Albumin end as Albumin_Min
	   ,
	   case when sepsis.dependent_variables2.Sodium_Min is null then 
	   			sepsis.labsfirstday.Sodium_Min
	   		else sepsis.dependent_variables2.Sodium_Min end as Sodium_Min
	   ,
	   case when sepsis.dependent_variables2.Sodium_Max is null then 
	   			sepsis.labsfirstday.Sodium_Max
	   		else sepsis.dependent_variables2.Sodium_Max end as Sodium_Max
	   ,
	   case when sepsis.dependent_variables2.Potassium_Min is null then 
	   			sepsis.labsfirstday.Potassium_Min
	   		else sepsis.dependent_variables2.Potassium_Min end as Potassium_Min
	   ,
	   case when sepsis.dependent_variables2.Potassium_Max is null then 
	   			sepsis.labsfirstday.Potassium_Max
	   		else sepsis.dependent_variables2.Potassium_Max end as Potassium_Max
	   ,
	   case when sepsis.dependent_variables2.Chloride_Min is null then 
	   			sepsis.labsfirstday.Chloride_Min
	   		else sepsis.dependent_variables2.Chloride_Min end as Chloride_Min	   
	   ,
	   case when sepsis.dependent_variables2.Chloride_Max is null then 
	   			sepsis.labsfirstday.Chloride_Max
	   		else sepsis.dependent_variables2.Chloride_Max end as Chloride_Max
	   ,
	   sepsis.dependent_variables2.Magnesium_Min,
	   sepsis.dependent_variables2.Magnesium_Max,
	   case when sepsis.dependent_variables2.Bilirubin_Max is null then 
	   			sepsis.labsfirstday.Bilirubin_Max
	   		else sepsis.dependent_variables2.Bilirubin_Max end as Bilirubin_Max
	   ,
	   sepsis.dependent_variables2.AST as AST_Max,
	   sepsis.dependent_variables2.ALT as ALT_Max,
	   sepsis.dependent_variables2.Urea as Urea_Max, 
	   pfratio,
	   sepsis.dependent_variables2.AlkalinePhosphatase,
	   NEUTROPHILS_LYMPHOCYTE_RATIO_MIN,
	   NEUTROPHILS_LYMPHOCYTE_RATIO_Max,
	   DELTACO2 as DELTACO2_Max,	   
	   --Non-clustering variables
	   case when sepsis.dependent_variables2.lactate_max is null then 
	   			sepsis.labsfirstday.lactate_max
	   		else sepsis.dependent_variables2.lactate_max end as Lactate_Max
	   	,
	   	case when sepsis.dependent_variables2.haemoglobin is null then 
	   			sepsis.labsfirstday.hemoglobin_Min
	   		else sepsis.dependent_variables2.haemoglobin end as haemoglobin_Min
	   	
	   	,
		sepsis.dependent_variables2.ArterialpH_max,
		sepsis.dependent_variables2.ArterialpH_min
		,
		case when sepsis.dependent_variables2.Vaso = TRUE then 
			sepsis.dependent_variables2.Vaso
			--when (select count(*) from sepsis.vaso_ids where vaso_ids.icustay_id = sepsis.dependent_variables2.icustay_id
-- )> 0 then 
--			TRUE
			else FALSE end as Vaso
			
		, 
		--sepsis.dependent_variables2.vaso_mv,
		
		
		--useful variables
		sepsis.dependent_variables2.pao2_min as pao2,
		sepsis.dependent_variables2.sao2, 
		--sofa scores
		sofa, 
		respiration,
		coagulation,
		liver,
		cardiovascular,
		cns,
		renal
	  
	    FROM sepsis.sofa_distinct, sepsis.dependent_variables2,
	    	 sepsis.vitalsfirstday, sepsis.labsfirstday
	    WHERE sofa_distinct.hadm_id = sepsis.dependent_variables2.hadm_id  and
	    	  sepsis.dependent_variables2.hadm_id = sepsis.vitalsfirstday.hadm_id and
	    	  sepsis.dependent_variables2.hadm_id = sepsis.labsfirstday.hadm_id

);
