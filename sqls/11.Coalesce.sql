set search_path to mimicfull; 


drop materialized view if exists sepsis.Vitals_SS cascade; 
create materialized view sepsis.Vitals_SS as
(
select subject_id,
		hadm_id,
		icustay_id,
	   max(troponin_max) as troponin_max,
	   max(heartrate_max) as heartrate_max, 
	   min(heartrate_min) as heartrate_min,
	   min(SodiumBicarbonate_Min) as sodiumbicarb_min,
	   max(Lactatedehydrogenase_max) as lactatedehydrogenase_max,
	   /*
	   max(BNatriureticPeptide_Max) as bnatriureticpeptide_max,
	   max(CReactiveProtein_Max) as creactiveprotein_max,
	    min(Triglycerides_Min) as triglycerides_min,
	    min(Cholestrol_Min) as cholesterol_min,
	    min(cholesterolratio_min) as cholesterolratio_min,
	    min(HighDensityLipoprotein_Min) as highdenlipoprotein_min, 
	    min(LowDensityLipoprotein_Min) as lowdenlipoprotein_min,*/
	    min(Temperature_Min) as temp_min, 
	   max(Temperature_Max) as temp_max,
	    min(SysBP_Min) as sysbp_min,
	   min(DiasBP_Min) as diasbp_min,
	   min(MeanBP_Min) as meanbp_min,
	  	min(Spontaneous_respiratory_rate_Min) as respiratory_rate_Min, 
		max(Spontaneous_respiratory_rate_Max) as respiratory_rate_Max,
	   min(MAP_MIN) as MAP_MIN,
	   min(CardiacIndex_Min) as CardiacIndex_Min,
	   max(CardiacIndex_Max) as CardiacIndex_Max,
	   min(StrokeIndex_Min) as StrokeIndex_Min,
	   min( SystemicVascularResistancesIndex_Min) as SystemicVascularResistancesIndex_Min,
	    max(SystemicVascularResistancesIndex_Max) as SystemicVascularResistancesIndex_Max,
	    min(CentralVenousPressure_Min) as CentralVenousPressure_Min,
	   max(CentralVenousPressure_Max) as CentralVenousPressure_Max,
	    min(PeripheralSaturation_Min) as PeripheralSaturation_Min,
	 --   min(CentralVenousOxygenSaturation_Min) as CentralVenousOxygenSaturation_Min,
	   --max(CentralVenousOxygenSaturation_Max) as CentralVenousOxygenSaturation_Max,
	  -- max(PaCO2_Max) as PaCO2_Max,
	  -- max(PvCO2_Max) as PvCO2_Max,
       --min(fio2_min) as fio2_min,
 	    min(PFRatio) as pfratio_min,
	  --  min(pao2) as pao2_min,
       -- min(sao2) as sao2_min,
	   max(Creatinine_Max) as Creatinine_Max,
	   min(WhiteBloodCellCount_Min) as WhiteBloodCellCount_Min,
	   max(WhiteBloodCellCount_Max) as WhiteBloodCellCount_Max, 
	   min(Neutrophils_Min) as Neutrophils_Min,
	   max(Neutrophils_Max) as Neutrophils_Max,
	    min(Eosinophils_Min) as Eosinophils_Min,
	   max(Eosinophils_Max) as Eosinophils_Max,
	    min(Lymphocytes_Min) as Lymphocytes_Min,
	    min(Lymphocytes_Max) as Lymphocytes_Max,
	    min(AtypicalLeukocytes_Min) as AtypicalLeukocytes_Min,
	   max(AtypicalLeukocytes_Max) as AtypicalLeukocytes_Max,
	    min(Bandforms_Min) as Bandforms_Min,
	   max(Bandforms_Max) as Bandforms_Max, 
	    min(Platelets_Min) as Platelets_Min, 
	   max(DDimer_Max) as DDimer_Max,
	   max(INR_Max) as INR_Max,
	   max(PTT_Max) as PTT_Max,
	   max(Fibrinogen_Max) as Fibrinogen_Max,
	    min(Glucose_Min) as Glucose_Min,
	   max(Glucose_Max) as Glucose_Max,
	    min(Albumin_Min) as Albumin_Min, 
	    min(Sodium_Min) as Sodium_Min, 
	    max(Sodium_Max) as Sodium_Max, 
	     min(Potassium_Min) as Potassium_Min,
	    max(Potassium_Max) as Potassium_Max, 
	     min(Chloride_Min) as Chloride_Min, 
	    max(Chloride_Max) as Chloride_Max, 
	    min(Magnesium_Min) as Magnesium_Min,
	   max(Magnesium_Max) as Magnesium_Max,
	    max(Bilirubin_Max) as Bilirubin_Max, 
	   max(AST_Max) as AST_Max,
	   max(ALT_Max) as ALT_Max,
	   max(Urea_Max) as Urea_Max,
	    min(AlkalinePhosphatase) as AlkalinePhosphatase,
	    min(NEUTROPHILS_LYMPHOCYTE_RATIO_MIN) as NEUTROPHILS_LYMPHOCYTE_RATIO_MIN,
	   max(NEUTROPHILS_LYMPHOCYTE_RATIO_Max) as NEUTROPHILS_LYMPHOCYTE_RATIO_Max,
	    min(CAO2_Min) as CAO2_Min,
	   max(DELTACO2_Max) as DELTACO2_Max,
	   	   --Non-clustering variables
	    max(lactate_max) as lactate_max,
	     min(haemoglobin_Min) as haemoglobin_Min,
	    max(ArterialpH_max) as ArterialpH_max,
             min(ArterialpH_min) as ArterialpH_min,
             bool_or(vaso) as vaso,

		
		--sofa scores
		max(sofa) as sofa, 
		case when max(respiration) is not null then
			max(respiration) 
			else 0 end as respiration
		,
		case when max(coagulation) is not null then 
				max(coagulation)
			else 0 end as cogulation
		,
		case when max(liver) is not null then
				max(liver)
			else 0 end as liver
		,
		case when max(cardiovascular) is not null then 
					max(cardiovascular)
			else 0 end as cardiovascular
		,
		case when max(cns) is not null then 
			max(cns) 
			else 0 end as cns
		,
		case when max(renal) is not null then 
			max(renal) 
			else 0 end as renal
		
		from sepsis.clean 	
		
		group by icustay_id, hadm_id, subject_id
		order by icustay_id, hadm_id, subject_id

)
