set search_path to mimicfull; 
DROP materialized VIEW IF EXISTS sepsis.Notes cascade;
Create materialized view sepsis.Notes as
(
select freetext.subject_id, freetext.hadm_id
	, 	
	max(case when freetext.fibrinogenfreetext is not null then 
			 freetext.fibrinogenfreetext
			else null end) as fibronogenfreetext
	,
	max(case when freetext.neutfreetext is not null then 
			 freetext.neutfreetext
			else null end) as neutmaxfreetext
	, 	
	min(case when freetext.neutfreetext is not null then 
			 freetext.neutfreetext
			else null end) as neutminfreetext

	, 	
	max(case when freetext.eosfreetext is not null then 
			 freetext.eosfreetext
			else null end) as eosmaxfreetext
	, 	
	min(case when freetext.eosfreetext is not null then 
			 freetext.eosfreetext
			else null end) as eosminfreetext
	, 	
	max(case when freetext.lymphfreetext is not null then 
			 freetext.lymphfreetext
			else null end) as lymphmaxfreetext
	, 	
	min(case when freetext.lymphfreetext is not null then 
			 freetext.lymphfreetext
			else null end) as lymphminfreetext
			
	,
	max(case when freetext.heightfreetext is not null then 
			 freetext.heightfreetext
			else null end) as heightfreetext	
	,	
	max(case when freetext.troponinfreetext is not null then 
			 freetext.troponinfreetext
			else null end) as troponinfreetext
	,			
	max(case when freetext.DDimerFreeText is not null then 
			 freetext.DDimerFreeText
			else null end) as DDimerFreeText
			
	,
	min(case when freetext.pfratioFreeText is not null then 
			 freetext.pfratioFreeText
			else null end) as pfratioFreeText
from 
(
  select noteevents.subject_id,  noteevents.hadm_id, noteevents.charttime, text
  	, -- PFRatio
  	case when text ~* 'PaO2 / FiO2:'  then 

		case when 
		regexp_replace(regexp_replace(substring(text, strpos(text,'PaO2 / FiO2:'), 25), 
				'(PaO2 / FiO2:)','','g') , '[^0-9]','','g')
		not like '' then
		cast(
				regexp_replace(regexp_replace(substring(text, strpos(text,'PaO2 / FiO2:'), 25), 
				'(PaO2 / FiO2:)','','g') , '[^0-9]','','g')
		as double precision)
		else null end		
		else null end as pfratioFreeText
		,
	case when substring(text,'Eos:([0-9]+\.[0-9]+)') is not null then 
		cast
		(
		substring(text,'Eos:([0-9]+\.[0-9]+)')
		as double precision
		)
	else null end as eosfreetext
		,
		
	case when substring(text,'Lymph:([0-9]+\.[0-9]+)') is not null then 
		cast
		(
		substring(text,'Lymph:([0-9]+\.[0-9]+)')
		as double precision
		)
	else null end as lymphfreetext
	,		
	case when substring(text,'Differential-Neuts:([0-9]+\.[0-9]+)') is not null then 
		cast
		(
		substring(text,'Differential-Neuts:([0-9]+\.[0-9]+)')
		as double precision
		)
	else null end as neutfreetext
	,
	case when substring(text, 'Fibrinogen:([0-9]+) mg/dL') is not null then 
		cast
		(
		regexp_replace(substring(text, 'Fibrinogen:([0-9]+) mg/dL') ,
						 '[<,>,*, ,a-z,A-Z,\[,\],\,/,:]','','g') 
		as double precision
		)
		else null end as FibrinogenFreeText
	
	,
	 --Troponin-T
  	case when substring(text, 'Troponin-T:([0-9]+)/([0-9]+)/(<*)([0-9]*.[0-9]+)') is not null then 
  		cast
  		(
	  		substring(
				substring(text, strpos(text,'Troponin-T:'),26)
				,'([0-9]*\.[0-9]+)'
					) 
		as double precision)
		else null end as TroponinFreeText
	, --Height
	case when substring(text, 'height:%inch%') is not null then
		case when 
			regexp_replace(regexp_replace(substring(text, strpos(text,'Height:'), 25), 
				'(Height:)','','g') , '[^0-9]','','g') not like '' then
			cast(
				regexp_replace(regexp_replace(substring(text, strpos(text,'Height:'), 18), 
				'(Height:)','','g') , '[^0-9\.]','','g')  
				as double precision
			)*0.0254
			else null end
		else null end as heightfreetext
  	,  --DDimer
  	case when substring(text, 'D-dimer:\[\*\*Numeric Identifier (.*?)\*\*\] ng/mL') is not null then		
  		cast
  		(
			  regexp_replace(substring(text, 'D-dimer:\[\*\*Numeric Identifier (.*?)\*\*\] ng/mL'),
			  												 '[<,>,*, ,a-z,A-Z,\[,\],\,]','','g') 
			  as double precision
		)
		 when substring(text, 'D-dimer:(.*?) ') is not null then		
		 cast
		 (
				  regexp_replace(substring(text, 'D-dimer:(.*?) '), '[<,>,*, ,a-z,A-Z,\[,\],\,]','','g') 
				  as double precision
		 )
		  else null end as DDimerFreeText
		 
		  
	from noteevents left join admissions 
			on noteevents.hadm_id = admissions.hadm_id

				where noteevents.charttime between admissions.admittime and admissions.admittime + interval '1' day and noteevents.hadm_id in (select hadm_id from sepsis.vitalsfirstday)
) as FreeText

--where DDimerFreeText is not NULL or TroponinFreeText is not null or FibrinogenFreeText is not null
group by freetext.hadm_id, freetext.subject_id
order by freetext.hadm_id, freetext.subject_id
); 
