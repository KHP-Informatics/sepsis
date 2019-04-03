---STEP 1: PREPARE THE FINAL OUTPUT, CALCULATING SOME OF THE RESULTS

set search_path to mimicfull; 
DROP MATERIALIZED VIEW IF EXISTS SEPSIS.dependent_variables2 CASCADE; 

CREATE MATERIALIZED VIEW SEPSIS.dependent_variables2 AS
(
SELECT SEPSIS.dependent_variables1.*,
			 --calculating stroke index when not available
					--SVI = Stroke Volume/ [0.20247 * (height (m)^0.725) * (weight (kg)^0.425)]			
				
	CASE WHEN STROKEINDEX_MIN IS NOT NULL THEN
		STROKEINDEX_MIN
		 WHEN STROKEVOLUME_MIN IS NOT NULL AND ADMISSIONWEIGHT IS NOT NULL
		 								 AND height_everywhere IS NOT NULL
								 		and ADMISSIONWEIGHT > 0 AND height_everywhere > 0  THEN
			STROKEVOLUME_MIN/(0.20247*POWER(height_everywhere,0.725)*POWER(ADMISSIONWEIGHT,0.425))
		ELSE null END as STROKEINDEX_MIN_EVERYWHERE
		,
		--SystemicVascularResistances_Min
	CASE WHEN SystemicVascularResistancesIndex_Min IS NOT NULL THEN
				SystemicVascularResistancesIndex_Min
		 WHEN SystemicVascularResistances_Min IS NOT NULL 
		 		AND ADMISSIONWEIGHT IS NOT NULL AND height_everywhere IS NOT NULL 
					 		and ADMISSIONWEIGHT > 0 AND height_everywhere > 0 THEN
			SystemicVascularResistances_Min/
					(0.20247*POWER(height_everywhere,0.725)*POWER(ADMISSIONWEIGHT,0.425))

		ELSE null END as SystemicVascularResistancesIndex_Min_Everywhere
		,
		--SystemicVascularResistances_Max
	CASE WHEN SystemicVascularResistancesIndex_Max IS NOT NULL THEN
			SystemicVascularResistancesIndex_Max
		 WHEN SystemicVascularResistances_Max IS NOT NULL AND
		 		 ADMISSIONWEIGHT IS NOT NULL AND height_everywhere IS NOT NULL 
				and ADMISSIONWEIGHT > 0 AND height_everywhere > 0 THEN
			SystemicVascularResistances_Max/
					(0.20247*POWER(height_everywhere,0.725)*POWER(ADMISSIONWEIGHT,0.425))
		ELSE null END as SystemicVascularResistancesIndex_Max_Everywhere
		
	, case when cardiacIndex_Min is not null then 
			cardiacIndex_Min
			when cardiacOutput_Min_everywhere is not null and
					height_everywhere is not null and
					admissionweight is not null then 
			cardiacOutput_Min_everywhere/
						(0.20247 * pow(height_everywhere,0.725) * pow(admissionweight,0.425))
			else null end as CardiacIndex_Min_Everywhere

	, case when cardiacIndex_Max is not null then 
			cardiacIndex_Max
			when cardiacOutput_Max_everywhere is not null and
					height_everywhere is not null and
					admissionweight is not null then 
			cardiacOutput_Max_everywhere/
						(0.20247 * pow(height_everywhere,0.725) * pow(admissionweight,0.425))
			else null end as CardiacIndex_Max_Everywhere
	, case when MeanBP_Min is not null then 
				MeanBP_Min
			when DiasBP_Min is not null and SysBP_Min is not null then 
				 (2*DiasBP_Min+SysBP_Min)/3
			when CardiacOutput_Min_Everywhere is not null and SystemicVascularResistances_Min is not null then 
					CardiacOutput_Min_Everywhere*SystemicVascularResistances_Min+CentralVenousPressure_Min

			else null end as MAP_MIN	
	, case when Troponin_Max is not null then 
				troponin_max
			when Notes.Troponinfreetext is not null then 
				Notes.Troponinfreetext
			else null end as Troponin_Max_Everywhere

	, case when Fibrinogen is not null then 
				Fibrinogen 
			when Notes.fibronogenfreetext is not null then 
				Notes.fibronogenfreetext
			else null end as Fibrinogen_Max_Everywhere

	, case when DDimer is not null then 
				DDimer 
			when Notes.ddimerfreetext is not null then 
				Notes.ddimerfreetext
			else null end as DDimer_Max_Everywhere
		
	, --p/f = pao2/inspired fraction of oxygen
		case when pfratiofreetext is not null then 
				pfratiofreetext
			when pao2_min is not null and fio2_min_final is not null 
										and fio2_min_final > 0 then		
				pao2_min/fio2_min_final
			else null end as pfratio
	
	,
		case when neutrophils_min is not null then
			neutrophils_min
			when notes.neutminfreetext is not null then
				notes.neutminfreetext 
			else null end as neutrophils_min_everywhere

	,
		case when neutrophils_max is not null then
			neutrophils_max
			when notes.neutmaxfreetext is not null then
				notes.neutmaxfreetext 
			else null end as neutrophils_max_everywhere
					
	,
		case when eosinophils_min is not null then
			eosinophils_min
			when notes.eosminfreetext is not null then
				notes.eosminfreetext 
			else null end as eosinophils_min_everywhere

	,
		case when eosinophils_max is not null then
			eosinophils_max
			when notes.eosmaxfreetext is not null then
				notes.eosmaxfreetext 
			else null end as eosinophils_max_everywhere

	,
		case when lymphocytes_min is not null then
			lymphocytes_min
			when notes.lymphminfreetext is not null then
				notes.lymphminfreetext 
			else null end as lymphocytes_min_eveywhere
	,
		case when lymphocytes_max is not null then
			lymphocytes_max
			when notes.lymphmaxfreetext is not null then
				notes.lymphmaxfreetext 
			else null end as lymphocytes_max_eveywhere

		, case when pvco2_max is not null and paco2_max_final is not null then
			pvco2_max - paco2_max_final
			else null end as deltaco2								
		
									
FROM SEPSIS.dependent_variables1 left join sepsis.Notes
		on dependent_variables1.hadm_id =  Notes.hadm_id

)
