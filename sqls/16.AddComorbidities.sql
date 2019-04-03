
drop materialized view if exists sepsis.Final;
create materialized view sepsis.Final as

select sepsis.AlmostFinal.*, mimicfull.elixhauser_quan_score.elixhauser_vanwalraven as comorbidity from sepsis.AlmostFinal,
									 mimicfull.elixhauser_quan_score 
				where sepsis.AlmostFinal.hadm_id = mimicfull.elixhauser_quan_score.hadm_id and 
						mimicfull.elixhauser_quan_score.elixhauser_sid30 > -12000; 
