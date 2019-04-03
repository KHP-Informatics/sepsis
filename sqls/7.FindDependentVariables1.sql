set search_path to mimicfull; 
DROP VIEW IF EXISTS sepsis.VASO_IDs CASCADE; 
CREATE VIEW sepsis.VASO_IDS AS
(
	select distinct icustay_id from 
		(select distinct icustay_id from inputevents_mv
		  where itemid in(5752,30119,30309,30044,221289,3112,221906,30047,30120,30306,30042,221653,5329,30043,30307,221662,6752,221749)
		  and hadm_id in (select distinct icustay_id from sepsis.vitalsfirstday) 
		  
		  UNION 
		  select distinct icustay_id from inputevents_cv
		  where itemid in(5752,30119,30309,30044,221289,3112,221906,30047,30120,30306,30042,221653,5329,30043,30307,221662,6752,221749)
		  and icustay_id in (select distinct icustay_id from sepsis.vitalsfirstday) 
		 ) as inputcv
);

drop materialized view if exists sepsis.dependent_variables1 cascade; 

create materialized view sepsis.dependent_variables1 as
(
select blood_variables.* 				
	    , case when sepsis.blood_variables.height is not null then
	    		sepsis.blood_variables.height
	    		when heights.height is not null then
	    		sepsis.heights.height
	    		else null end as height_everywhere
	    , case when fio2_min is not null then 
	    		fio2_min 
	    		when fio2_min_everywhere is not null then 
	    		fio2_min_everywhere
	    		else null end as fio2_min_final
	    , case when paco2_max is not null then 
	    		paco2_max
	    		when paco2_max_everywhere is not null then
	    		paco2_max_everywhere
	    		else null end as paco2_max_final
	    
					
	from sepsis.blood_variables left join sepsis.heights 
		on sepsis.blood_variables.subject_id = sepsis.heights.subject_id
); 

