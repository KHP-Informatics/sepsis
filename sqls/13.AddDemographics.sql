set search_path to sepsis; 


drop materialized view if exists Almost_Final cascade; 
create materialized view Almost_Final as
(

select * 
	from VitalAndOutcomes
	left join 
	(
	select 
		subject_id as sbj
		, gender
--		, date_part('year',age(dob,current_date) )as age
		, dob
			
	from mimicfull.patients
	) demographics
	
	on VitalAndOutcomes.subject_id = demographics.sbj
	order by subject_id
	 
)
