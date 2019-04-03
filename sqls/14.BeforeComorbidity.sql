set search_path to sepsis; 


drop materialized view if exists AlmostFinal; 
create materialized view AlmostFinal as
(

select * ,

	case when cast(date_part('year',age(admittime,dob) ) as double precision) > 299 then 
		90
		else
		cast(date_part('year',age(admittime,dob) ) as double precision) end  as age
 	from Almost_Final	
 	order by subject_id
	 
);


select *  from AlmostFinal where troponin_max is not null and bilirubin_max is not null order by subject_id, hadm_id, icustay_id; 
