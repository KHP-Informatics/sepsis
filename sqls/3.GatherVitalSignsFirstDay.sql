set search_path to mimicfull; 
drop materialized view if exists sepsis.vitalsfirstday cascade; 

create materialized view sepsis.vitalsfirstday as

select rv.hadm_id, rv.icustay_id, rv.subject_id

, min(case when vitalid = 58 then  --temperature in either celcius or fahrenheit
			 case when (valuenum < 60) then valuenum  --celcius
					else ((valuenum - 32)*5)/9 end
	else null end) as temperature_min

, max(case when vitalid = 58 then  --temperature in either celcius or fahrenheit
			 case when (valuenum < 60) then valuenum  --celcius
					else ((valuenum - 32)*5)/9 end
	else null end) as temperature_max
			 		 		   
		 	 		    		 		    			    
, min(case when vitalid = 1 or vitalid = 1000 then  --reflecting value preference set by andrea
	case when vitalid = 1 and valuenum is not null then valuenum  --(51,6701,220050) 
		 when vitalid = 1000 and valuenum is not null then valuenum --over (455, 224167, 227243,225309,220179)
		 else 500000 end --replacing null values 
		 end) as sysbp_min

, min(case when vitalid = 2 or vitalid = 2000 then  --reflecting value preference set by andrea
	case when vitalid = 2 and valuenum is not null then valuenum -- (8368,220051,227242) 
		 when vitalid = 2000 and valuenum is not null then valuenum --over (224643,220180,225310,8440,8441)
		 else 500000 end --replacing null values 
		 end) as diasbp_min
		 

, min(case when vitalid = 3 or vitalid = 3000 then  --reflecting value preference set by andrea
	case when vitalid = 3 and valuenum is not null then valuenum -- (52,6702,6927,220052,225312) 
		 when vitalid = 3000 and valuenum is not null then valuenum --over (456,220181)
		 else 500000 end --replacing null values 
		 end) as meanbp_min
	 
, min(case when vitalid = 4 then valuenum else null end) as heartrate_min
, max(case when vitalid = 4 then valuenum else null end) as heartrate_max
, avg(case when vitalid = 4 then valuenum else null end) as heartrate_mean


, max(case when vitalid = 5 then  
					 case when valuenum is not null then
						valuenum
						  when value is not null and value like '%CORRECTED RESULT%' then 
						  		cast(regexp_replace(substring(value,0,26), '[A-Za-z,/<>]+', '', 'g') as double precision) 		 
					      when value is not null and value ~* '[0-9]' then 
					 		cast(regexp_replace(value, '[A-Za-z,/<>]+', '', 'g') as double precision) 		 
					 	  else 0 end  --replacing null values 
		 end) as troponin_max

, max(case when vitalid = 6 then  
					case when valuenum is not null then 
							valuenum
						 when value ~*'\-' then
							 case when 
								 	cast(substring(regexp_replace(value, '[A-Za-z,/<>\*\s]+', '', 'g'), 0, 
						 					position('-' in value)) as double precision)  >= 0 
							 		and cast(substring(regexp_replace(value, '[A-Za-z,/<>\*\s]+', '', 'g'), 0, 
							 			position('-' in value)) as double precision)  <=31 
							 	  then 
									 cast(substring(regexp_replace(value, '[A-Za-z,/<>\*\s]+', '', 'g'), 0, 
									 							position('-' in value)) as double precision) 
						 		else
						 		0 end
						 when value ~* '[A-Za-z,/<>\*\s0-9]' then 
						 	case when regexp_replace(value, '[^0-9\.]+', '', 'g') like '' then 
							 		0 
						 		else
						 			case
						 			when cast(regexp_replace(value, '[^0-9\.]+', '', 'g') as double precision)  >=0 and
						 				 cast(regexp_replace(value, '[^0-9\.]+', '', 'g') as double precision)  <= 31 then
						 				 cast(regexp_replace(value, '[^0-9\.]+', '', 'g') as double precision) 
						 			else 0 end 
						 		end
						else 0 end 
		else null end) as lactate_max
, min(case when vitalid = 7 then valuenum else null end) as sodiumbicarbonate_min
, max(case when vitalid = 8 then valuenum else null end) as arterialph_max
, min(case when vitalid = 8 then valuenum else null end) as arterialph_min
, max(case when vitalid = 9 then 
		case
			when valuenum is not null then 
					valuenum 
			else 
			case when value is not null and value ~*'[0-9]' then
					cast(regexp_replace(value, '[A-Za-z,/<>*\s-]+', '', 'g') as double precision) 
				else null end 				
			end
		end) as creactiveprotein_max
, min(case when vitalid = 10 then valuenum else null end) as triglycerides_min
, max(case when vitalid = 11 then valuenum else null end) as lactatedehydrogenase_max
, max(case when vitalid = 12 then valuenum else null end) as bnatriureticpeptide_max
, min(case when vitalid = 13 then valuenum else null end) as cholestrol_min
, min(case when vitalid = 14 then valuenum else null end) as highdensitylipoprotein_min
, min(case when vitalid = 15 then valuenum else null end) as lowdensitylipoprotein_min
, min(case when vitalid = 66 then valuenum else null end) as cholesterolratio_min
, min(case when vitalid = 16 then valuenum else null end) as strokevolume_min
, min(case when vitalid = 17 then valuenum else null end) as strokeindex_min
, max(case when vitalid = 16 then valuenum else null end) as strokevolume_max
, max(case when vitalid = 17 then valuenum else null end) as strokeindex_max
, min(case when vitalid = 18 then valuenum else null end) as systemicvascularresistances_min
, max(case when vitalid = 18 then valuenum else null end) as systemicvascularresistances_max
, min(case when vitalid = 19 then valuenum else null end) as systemicvascularresistancesindex_min
, max(case when vitalid = 19 then valuenum else null end) as systemicvascularresistancesindex_max
, min(case when vitalid = 20 then valuenum else null end) as centralvenouspressure_min
, max(case when vitalid = 20 then valuenum else null end) as centralvenouspressure_max
, min(case when vitalid = 21 then valuenum else null end) as peripheralsaturation_min
, min(case when vitalid = 22 then valuenum else null end) as centralvenousoxygensaturation_min
, max(case when vitalid = 22 then valuenum else null end) as centralvenousoxygensaturation_max
, max(case when vitalid = 23 then  
					case when valuenum is not null then 
							valuenum
						 when value ~*'\-' then
							 case when 
								 	cast(substring(regexp_replace(value, '[A-Za-z,/<>\*\s]+', '', 'g'), 0, 
						 					position('-' in value)) as double precision)  >= 0.2 
							 		and cast(substring(regexp_replace(value, '[A-Za-z,/<>\*\s]+', '', 'g'), 0, 
							 			position('-' in value)) as double precision)  <=20 
							 	  then 
									 cast(substring(regexp_replace(value, '[A-Za-z,/<>\*\s]+', '', 'g'), 0, 
									 							position('-' in value)) as double precision) 
						 		else
						 		0 end
						 when value ~* '[A-Za-z,/<>\*\s0-9]' then 
						 	case when regexp_replace(value, '[^0-9\.]+', '', 'g') like '' then 
							 		0 
						 		else
						 			case
						 			when cast(regexp_replace(value, '[^0-9\.]+', '', 'g') as double precision)  >=0.2 and
						 				 cast(regexp_replace(value, '[^0-9\.]+', '', 'g') as double precision)  <= 20 then
						 				 cast(regexp_replace(value, '[^0-9\.]+', '', 'g') as double precision) 
						 			else 0 end 
						 		end
						else 0 end 
		else null end) as creatinine_max
		
, min(case when (vitalid = 24 )then valuenum else null end) as spontaneous_respiratory_rate_min
, min(case when (vitalid = 2400) then valuenum else null end) as spontaneous_respiratory_rate_validation_min
, max(case when (vitalid = 24 )then valuenum else null end) as spontaneous_respiratory_rate_max
, max(case when (vitalid = 2400) then valuenum else null end) as spontaneous_respiratory_rate_validation_max
, min(case when vitalid = 25 then valuenum * 1000000 else null end) as whitebloodcellcount_min
, max(case when vitalid = 25 then valuenum * 1000000 else null end) as whitebloodcellcount_max
, min(case when vitalid = 26 then valuenum else null end) as neutrophils_min
, max(case when vitalid = 26 then valuenum else null end) as neutrophils_max
, min(case when vitalid = 27 then valuenum else null end) as eosinophils_min
, max(case when vitalid = 27 then valuenum else null end) as eosinophils_max
, min(case when vitalid = 28 then valuenum else null end) as lymphocytes_min
, max(case when vitalid = 28 then valuenum else null end) as lymphocytes_max
, min(case when vitalid = 29 then valuenum else null end) as atypicalleukocytes_min
, max(case when vitalid = 29 then valuenum else null end) as atypicalleukocytes_max
, min(case when vitalid = 30 then valuenum else null end) as bandforms_min
, max(case when vitalid = 30 then valuenum else null end) as bandforms_max
, min(case when vitalid = 31 then valuenum else null end) as platelets

, max(case when vitalid = 32 then  
					case when valuenum is not null then 
							valuenum
						 when value ~*'\-' then
							cast(substring(regexp_replace(value, '[A-Za-z,/<>\*\s]+', '', 'g'), 0, position('-' in value)) as double precision)
						 when value ~* '[A-Za-z,/<>\*\s0-9]' then 
						 	case when regexp_replace(value, '[^0-9\.]+', '', 'g') like '' then 
							 		0 
						 		else 
							 		cast(regexp_replace(value, '[^0-9\.]+', '', 'g') as double precision) end
						else 0 end 
		else null end) as ddimer
, max(case when vitalid = 33 then valuenum else null end) as inr
, max(case when vitalid = 34 then valuenum else null end) as ptt
, max(case when vitalid = 35 then valuenum else null end) as fibrinogen
, min(case when vitalid = 36 then valuenum else null end) as haemoglobin
, min(case when vitalid = 37 then valuenum else null end) as glucose_min
, max(case when vitalid = 37 then valuenum else null end) as glucose_max

, min(case when vitalid = 38 then  
					case when valuenum is not null then 
							valuenum
						 when value ~*'\-' then
							cast(substring(regexp_replace(value, '[A-Za-z,/<>\*\s]+', '', 'g'), 0, position('-' in value)) as double precision)
						 when value ~* '[A-Za-z,/<>\*\s0-9]' then 
						 	case when regexp_replace(value, '[^0-9\.]+', '', 'g') like '' then 
							 		0 
						 		else 
							 		cast(regexp_replace(value, '[^0-9\.]+', '', 'g') as double precision) end
						else 0 end 
		else null end) as albumin
		
, min(case when vitalid = 39 then valuenum else null end) as sodium_min
, max(case when vitalid = 39 then valuenum else null end) as sodium_max
, min(case when vitalid = 40 then valuenum else null end) as potassium_min
, max(case when vitalid = 40 then valuenum else null end) as potassium_max
, max(case when vitalid = 41 then  
					case when valuenum is not null then 
							valuenum
						 when value ~*'\-' then
							cast(substring(regexp_replace(value, '[A-Za-z,/<>\*\s]+', '', 'g'), 0, position('-' in value)) as double precision)
						 when value ~* '[A-Za-z,/<>\*\s0-9]' then 
						 	case when regexp_replace(value, '[^0-9\.]+', '', 'g') like '' then 
							 		0 
						 		else 
							 		cast(regexp_replace(value, '[^0-9\.]+', '', 'g') as double precision) end
						else 0 end 
		else null end) as bilirubin_max
		
, max(case when vitalid = 42 then  
					case when valuenum is not null then 
							valuenum
						 when value ~*'\-' then
							cast(substring(regexp_replace(value, '[A-Za-z,/<>\*\s]+', '', 'g'), 0, position('-' in value)) as double precision)
						 when value ~* '[A-Za-z,/<>\*\s0-9]' then 
						 	case when regexp_replace(value, '[^0-9\.]+', '', 'g') like '' then 
							 		0 
						 		else 
							 		cast(regexp_replace(value, '[^0-9\.]+', '', 'g') as double precision) end
						else 0 end 
		else null end) as ast


, max(case when vitalid = 43 then  
					case when valuenum is not null then 
							valuenum
						 when value ~*'\-' then
							cast(substring(regexp_replace(value, '[A-Za-z,/<>\*\s]+', '', 'g'), 0, position('-' in value)) as double precision)
						 when value ~* '[A-Za-z,/<>\*\s0-9]' then 
						 	case when regexp_replace(value, '[^0-9\.]+', '', 'g') like '' then 
							 		0 
						 		else 
							 		cast(regexp_replace(value, '[^0-9\.]+', '', 'g') as double precision) end
						else 0 end 
		else null end) as alt
, max(case when vitalid = 44 then valuenum*0.357 else null end) as urea
, min(case when vitalid = 45 then valuenum else null end) as alkalinephosphatase
, min(case when vitalid = 46 then valuenum else null end) as cao2
, min(case when vitalid = 47 then valuenum else null end) as cardiacoutput_min
, max(case when vitalid = 47 then valuenum else null end) as cardiacoutput_max
, min(case when vitalid = 48 then 
		case
			when valuenum is not null then 
				 valuenum 
			else 
			case when value is not null and value ~*'[0-9]' then
					cast(regexp_replace(value, '[A-Za-z,/<>* -]+', '', 'g') as double precision) 
				else null end 				
			end
		end) as cardiacindex_min
, max(case when vitalid = 48 then 
		case
			when valuenum is not null then 
				 valuenum 
			else 
			case when value is not null and value ~*'[0-9]' then
					cast(regexp_replace(value, '[A-Za-z,/<>* -]+', '', 'g') as double precision) 
				else null end 				
			end
		end) as cardiacindex_max		
--, min(case when vitalid = 49 then valuenum else null end) as ejectionfraction
, min(case when vitalid = 50 then valuenum else null end) as sao2
, min(case when vitalid = 51 then valuenum else null end) as chloride_min
, max(case when vitalid = 51 then valuenum else null end) as chloride_max
, min(case when vitalid = 52 then valuenum else null end) as ionizedcalcium_min
, max(case when vitalid = 52 then valuenum else null end) as ionizedcalcium_max
, min(case when vitalid = 53 then valuenum else null end) as magnesium_min
, max(case when vitalid = 53 then valuenum else null end) as magnesium_max
, min(case when vitalid = 54 then 
		case when valuenum is not null then 
				case when valuenum <= 1  and valuenum > 0 then
						 valuenum*100 
					 when valuenum > 1 then
					 	 valuenum 
					 else 600000 end
			else 
				case when value is not null and value ~*'[0-9]' then
						case when 
								cast(regexp_replace(value, '[A-Za-z,/<>* -]+', '', 'g') as double precision) 
										> 0 then
							cast(regexp_replace(value, '[A-Za-z,/<>* -]+', '', 'g') as double precision) 
							else null end
					else null end 		
			end 
		end)as pao2_min
, max(case when vitalid = 55 then 
		case when valuenum is not null then 
				case when valuenum <= 1 then valuenum*100 
						else valuenum end
			else 
				case when value is not null and value ~*'[0-9]' then
						cast(regexp_replace(value, '[A-Za-z,/<>* -]+', '', 'g') as double precision) 
					else null end 		
			end 
		end)as paco2_max
, max(case when vitalid = 56 then 
		case when valuenum is not null then 
				case when valuenum <= 1 then valuenum*100 
						else valuenum end
			else 
				case when value is not null and value ~*'[0-9]' then
						cast(regexp_replace(value, '[A-Za-z,/<>* -]+', '', 'g') as double precision) 
					else null end 		
			end 
		end)as pvco2_max
, min(case when vitalid = 57 then 
		case when valuenum is not null then 
				case when valuenum > 1 then valuenum/100
						else valuenum end
			else 
				case when value is not null and value ~*'[0-9]' then
					case when 
							cast(regexp_replace(value, '[A-Za-z,/<>* -]+', '', 'g') as double precision) > 1 then
						cast(regexp_replace(value, '[A-Za-z,/<>* -]+', '', 'g') as double precision)/100
						else cast(regexp_replace(value, '[A-Za-z,/<>* -]+', '', 'g') as double precision) end
						
					else null end 		
			end 
		end)as fio2_min
, min(case when vitalid = 59 or vitalid = 60 or vitalid = 61 then 
			case when vitalid = 59 and valuenum is not null then valuenum
				 when vitalid = 60 and valuenum is not null then valuenum 
				 when vitalid = 61 and valuenum is not null then valuenum*0.45 end
	  end) as admissionweight

,min(case when vitalid = 62 or vitalid = 63 then
			case when vitalid = 62 and valuenum is not null then valuenum*0.0254
				 when vitalid = 63 and valuenum is not null then valuenum*0.01
				 else 500000 end --replacing null values
		else null end) as height
	
, min(case when vitalid = 64 then valuenum else null end) as resprate_min
, max(case when vitalid = 64 then valuenum else null end) as resprate_max
, avg(case when vitalid = 64 then valuenum else null end) as resprate_mean

,bool_or(case when vitalid = 65 then true else false end) as vaso

from (
			select subject_id, hadm_id, icustay_id, time, value, valuenum, valueuom 
			  , case
			    when itemid in (51,6701,220050) and value is not null 
			    						and valuenum > 0 and valuenum < 301 then 1 -- sysbp1
			    when itemid in (455, 224167, 227243,225309,220179) and value is not null and valuenum > 0 and valuenum < 301 then 1000 --sysbp2		 
			    
			    when itemid in (8368,220051,227242) and valuenum > 0 and value is not null and valuenum < 301 then 2 -- diasbp1
			    when itemid in (224643,220180,225310,8440,8441)  and value is not null and valuenum > 0 and valuenum < 301 then 2000 -- diasbp2
			    
			    when itemid in (52,6702,6927,220052,225312) and value is not null and valuenum > 0 and valuenum < 301 then 3 -- meanbp1
			    when itemid in (456,220181) and value is not null and valuenum > 0 and valuenum < 301 then 3000 -- meanbp2
			    
		        when itemid in (211,220045) and value is not null and valuenum > 0 and valuenum < 301 then 4 -- heartrate
			    when itemid in (851,227429,51002,51003) and value is not null then 5 -- troponin
			    when itemid in (818,1531,225668,50813) and value is not null then 6 -- lactate
			    when itemid in (227443) and value is not null  then 7  -- sodiumbicarbonate
			    when itemid in (1126,780) and value is not null and valuenum >= 6.7 and valuenum <= 7.8  then 8  -- arterialph
			    when itemid in (227444,220612,50889) and value is not null then 9  -- creactiveprotein
			    when itemid in (850,1540,225693,51000) and value is not null and valuenum >= 0  then 10  -- triglycerides
			    when itemid in (817,220632,50954) and value is not null and valuenum >= 0  then 11  -- lactatedehydrogenase
			    when itemid in (227446) and value is not null and valuenum >= 0  then 12  -- b-natriureticpeptide
			    when itemid in (3748,789,1524,220603,50907,51031) and value is not null then 13  -- cholestrol
			    when itemid in (220624,50904) and value is not null and valuenum >= 0  then 14  -- highdensitylipoprotein
			    when itemid in (225671,227441,227441,50905,50906) and value is not null and valuenum >= 0  then 15 -- lowdensitylipoprotein
			    when itemid in (50903) and value is not null and valuenum >=0 then 66 --cholestrolratio
			    when itemid in (662,227547,228374) and value is not null and valuenum >= 10 and valuenum <=150  then 16 -- strokevolume
			    when itemid in (625,228375) and value is not null and valuenum >= 5 and valuenum <=150  then 17 -- strokeindex
			    when itemid in (626) and value is not null and valuenum >= 200 and valuenum <=3000  then 18 -- systemicvascularresistances
			    when itemid in (627) and value is not null and valuenum >= 400 and valuenum <=8000  then 19 -- systemicvascularresistancesindex
			    when itemid in (113,220074) and value is not null and valuenum >= -5 and valuenum <=30  then 20 -- centralvenouspressure
			    when itemid in (220277,646) and value is not null and valuenum >= 50 and valuenum <=100  then 21 -- peripheraloxygensaturation
			    when itemid in (223772,227686) and value is not null and valuenum >= 20 and valuenum <=90  then 22 -- centralvenousoxygensaturation
			    when itemid in (791,1525,220615,50912) and value is not null  then 23 -- creatinine
			    when itemid in (614,224689) and (value is not null and valuenum >=0 and valuenum <=60) then 24--spontaneous respiratory rate item
			    when itemid in (615,224690) and (value is not null and valuenum >=0 and valuenum <=60) then 2400--sp. resp. rate validation item
			    when itemid in (1127,861,1542,220546,51300,51301)and value is not null  and valuenum >= 0  then 25 -- whitebloodcellcount
			    when itemid in (800,225643,51256) and value is not null and valuenum >= 0  then 26 -- netrophils
			    when itemid in (797,225640,51199,51200,51347,51368,51419,51444,51114,51474) and value is not null and valuenum >= 0  then 27 -- eosinophils
			    when itemid in (798,225641,51244) and value is not null and valuenum >= 0  then 28 -- lymphocytes
			    when itemid in (794,225637) and value is not null and valuenum >= 0  then 29 -- atypicalleukocytes
			    when itemid in (795,225638,51144) and value is not null and valuenum >= 0  then 30 -- bandforms
			    when itemid in (828,227457,51265) and value is not null and valuenum >= 0  then 31 -- platelets
			    when itemid in (1526,225636,793,51196,50915,228240) and value is not null then 32 -- ddimer
			    when itemid in (227467,815,1530) and value is not null and valuenum >= 0  then 33 -- inr
			    when itemid in (227466,825,1533) and value is not null and valuenum >= 0  then 34 -- ptt
			    when itemid in (806,1528,227468,51214) and value is not null and valuenum >= 0  then 35 -- fibrinogen
			    when itemid in (814,220228) and value is not null and valuenum >= 2 and valuenum <=25  then 36 -- haemoglobin
			    when itemid in (811,1529,220621,50931) and value is not null and valuenum >= 0  then 37 -- glucose
			    when itemid in (227456,772,1521,50862) and value is not null then 38 -- albumin
			    when itemid in (837,1536,220645) and value is not null and valuenum >= 100 and valuenum <=190  then 39 -- sodium
			    when itemid in (829,1535,227442) and value is not null and valuenum >= 0 and valuenum <=10  then 40 -- potassium
			    when itemid in (225690,848,1538,50883,50884,50885) and value is not null then 41 -- bilirubin
			    when itemid in (220587,770,50878) and value is not null then 42 -- ast
			    when itemid in (769,220644,50861) and value is not null then 43 -- alt
			    when itemid in (1162,781,225624,51006) and value is not null and valuenum >= 0  then 44 -- Urea
			    when itemid in (225612,773,50863) and value is not null and valuenum >= 0  then 45 -- alkalinephosphatase
			    when itemid in (114) and value is not null and valuenum >= 0  then 46 -- cao2
			    when itemid in (40909,41562,41440,44920, 44970, 41946,224842,228369) and value is not null  then 47 -- cardiacoutput

			    when itemid in (7610,116,228368) and value is not null and valuenum >= 0.5 and valuenum <=12  then 48 -- cardiacindex
			    when itemid in (3352,221255,225432) and value is not null and valuenum >= 5 and valuenum <=75  then 49 -- ejectionfraction
			    when itemid in (227008) and value is not null and valuenum >= 5 and valuenum <=75  then 49 -- diastolicdysfunction
			    when itemid in (834,220227) and value is not null and valuenum >= 50 and valuenum <=100 then 50 -- sao2
			    when itemid in (788,1523,220602) and value is not null and valuenum >= 50 and valuenum <=150 then 51 -- chloride
			    when itemid in (816,225667) and value is not null and valuenum >= 0 and valuenum <=5 then 52 -- ionizedcalcium
			    when itemid in (821,1532,220635) and value is not null and valuenum >= 0 and valuenum <=10 then 53 -- magnesium
			    when itemid in (779,220224) and value is not null then 54 --pao2
			    when itemid in (778,220235) and value is not null then 55 -- paco2
			    when itemid in (858,226062,859,857,3830,709,3061,3773,3774) and value is not null then 56 -- pvco2
			    when itemid in (189,223835,50816) and value is not null then 57 -- fio2  
			    when itemid in (223762,676,677,223761,678,679) and valuenum is not null then 58  --temperature
			    when itemid in (763) and value is not null then 59 --admissionweight
			    when itemid in (226512) and value is not null then 60 --weightkg
			    when itemid in (226531) and value is not null then 61 --weightlb
			    when itemid in (920,1394,226707) and value is not null then 62 --heightin
			    when itemid in (226730) and value is not null then 63 --heighcm
			    when itemid in (615,618,220210,224690) and valuenum > 0 and valuenum < 70 then 64 -- resprate
			    when itemid in (5752,30119,30309,30044,221289,3112,221906,30047,30120,30306,30042,221653,5329,30043,30307,221662,6752,221749) and value is not null then 65 --vaso
			    else null end as vitalid
		      -- convert f to c

			from sepsis.allevents order by time
	)rv
	group by rv.hadm_id, rv.icustay_id, rv.subject_id
	order by rv.hadm_id, rv.icustay_id, rv.subject_id
