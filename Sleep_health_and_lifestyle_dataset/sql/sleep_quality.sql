/*
				SLEEP HEALTH & LIFESTYLE DATASET - END-TO-END SQL ANALYSIS
				Database Engine: PostgreSQL
				Author: Daniel Żebrowski
*/


-- 1.0 RAW DATA INGESTION & SETUP
drop table raw_sleep_quality;

create table if not exists raw_sleep_quality();
-- Note: Import raw CSV dataset into 'raw_sleep_quality' table before proceeding.

select * from raw_sleep_quality;

-- 2.0 DATA QUALITY CHECKS & ANOMALY DETECTION

-- 2.1 Total Record Count
select
	count(*)
from raw_sleep_quality rsq; 

-- 2.2 Primary Key Uniqueness Check
select
	rsq."Person ID",
	count(rsq."Person ID")
from raw_sleep_quality rsq
group by rsq."Person ID" 
having count(rsq."Person ID") > 1;

-- 2.3 NULL Values Audit Across All Attributes
select *
from raw_sleep_quality rsq 
where rsq."Person ID" is null
or rsq."Gender" is null
or rsq."Age" is null
or rsq."Occupation" is null
or rsq."Sleep Duration" is null
or rsq."Quality of Sleep" is null 
or rsq."Physical Activity Level" is null
or rsq."Stress Level" is null
or rsq."BMI Category" is null
or rsq."Blood Pressure" is null
or rsq."Heart Rate" is null
or rsq."Daily Steps" is null
or rsq."Sleep Disorder" is null;

-- 2.4 Categorical Distribution & Value Consistency Inspection
select
	'Occupation' as column_name,
	rsq."Occupation" as category_value,
	count(*)
from raw_sleep_quality rsq
group by rsq."Occupation" 
union all
select 
	'Gender' as column_name,
	rsq."Gender" as category_value,
	count(*)
from raw_sleep_quality rsq 
group by rsq."Gender"
union all
select 
	'BMI Category' as column_name,
	rsq."BMI Category" as category_value,
	count(*)
from raw_sleep_quality rsq 
group by rsq."BMI Category"
union all
select 
	'Sleep Disorder' as column_name,
	rsq."Sleep Disorder" as category_value,
	count(*)
from raw_sleep_quality rsq 
group by rsq."Sleep Disorder"

/* 
KEY FINDINGS & ACTION ITEMS:
- 'BMI Category' contains duplicate semantic values ('Normal' vs. 'Normal Weight').
	ACTION: Standardize to 'Normal' during Phase 2 (Data Cleaning).

- 'Sleep Disorder' contains string 'None' values representing absent disorders.
	ACTION: Replace string 'None' with true SQL NULL values to optimize conditional aggregation and standard NULL logic.
 */

-- 2.5 Summary Statistics & Numeric Range Check
select 
	min(rsq."Age"),
	max(rsq."Age"),
	round(avg(rsq."Age"::numeric),2)
from raw_sleep_quality rsq; -- ok

select 
	min(rsq."Sleep Duration"),
	max(rsq."Sleep Duration"),
	round(avg(rsq."Sleep Duration"::numeric),2)
from raw_sleep_quality rsq; -- ok

select 
	min(rsq."Quality of Sleep"),
	max(rsq."Quality of Sleep"),
	round(avg(rsq."Quality of Sleep"::numeric),2)
from raw_sleep_quality rsq -- ok

select 
	min(rsq."Physical Activity Level"),
	max(rsq."Physical Activity Level"),
	round(avg(rsq."Physical Activity Level"::numeric),2)
from raw_sleep_quality rsq -- ok

select 
	min(rsq."Stress Level"),
	max(rsq."Stress Level"),
	round(avg(rsq."Stress Level"::numeric),2)
from raw_sleep_quality rsq -- ok

select 
	min(rsq."Heart Rate"),
	max(rsq."Heart Rate"),
	round(avg(rsq."Heart Rate"::numeric),2)
from raw_sleep_quality rsq -- ok

select 
	min(rsq."Daily Steps"),
	max(rsq."Daily Steps"),
	round(avg(rsq."Daily Steps"::numeric),2)
from raw_sleep_quality rsq -- ok

-- 3.0 DATA CLEANING - TABLE CREATION & STANDARDIZATION
drop table sleep_quality;

-- 3.1 Create Production Table with Standardized Names & Parsed Metrics
create table if not exists sleep_quality as 
select
	"Person ID" as person_id, 
	"Gender" as  gender,
	"Age" as age,
	"Occupation" as occupation,
	"Sleep Duration" as sleep_duration,
	"Quality of Sleep" as quality_of_sleep,
	"Physical Activity Level" as physical_activity_level,
	"Stress Level" as stress_level,
	"Heart Rate" as heart_rate,
	"Daily Steps" as daily_steps,
	"Sleep Disorder" as sleep_disorder,
	case
		when "BMI Category" = 'Normal Weight' then 'Normal'
		else "BMI Category"
	end as bmi_category,
	split_part("Blood Pressure", '/', 1::integer) as systolic_bp,
	split_part("Blood Pressure", '/', 2::integer) as diastolic_bp
from raw_sleep_quality;

select * from sleep_quality sq;

-- 3.2 Standardize Missing Values to SQL NULL
update sleep_quality
set sleep_disorder = null
where sleep_disorder = 'None';

-- 3.3 Verify Transformations
select 
	sleep_disorder,
	count(*)
from sleep_quality
group by sleep_disorder;

/*
Summary of Work Completed in Stage 2
BMI Standardization: Consolidated the categorical values Normal Weight into the standardized Normal category.
Blood Pressure Parsing: Split blood pressure values into separate numerical fields: systolic_bp and diastolic_bp.
Missing Data Standardization: Replaced textual representations of missing/no-condition values (None) with SQL NULL values
*/

-- 4.0 EXPLORATORY DATA ANALYSIS (EDA)

-- 4.1 Demographic Analysis: Occupation vs. Sleep Metrics
select 
	sq.occupation,
	count(sq.occupation) as occupation_value,
	round(avg(sq.sleep_duration::numeric),2) as average_sleep_duration,
	round(avg(sq.quality_of_sleep),2) as average_quality_of_sleep
from sleep_quality sq
group by sq.occupation  	
order by average_sleep_duration desc;
	
-- 4.2 Demographic Analysis: Gender vs. Sleep Disorder Prevalence
select 
	sq.gender,
	count(sq.gender) as gender_value,
	count(sq.sleep_disorder) filter (where sq.sleep_disorder = 'Insomnia') as Insomnia_disorder,
	count(sq.sleep_disorder) filter (where sq.sleep_disorder = 'Sleep Apnea') as Sleep_Apnea_disorder,
	count(*) filter (where sq.sleep_disorder is NULL) as No_disorder
from sleep_quality sq 
group by gender;
	
-- 4.3 Lifestyle Analysis: Stress Level vs. Sleep Metrics & Physical Activity
select
	sq.stress_level,
	count(sq.stress_level) as population_value,
	round(avg(sq.sleep_duration::numeric),2) as average_sleep_duration_value,
	round(avg(sq.quality_of_sleep),2) as average_quality_of_sleep_value,
	round(avg(sq.daily_steps)) as average_daily_steps
from sleep_quality sq 
group by sq.stress_level
order by sq.stress_level asc
	
-- 4.4 Health Metrics: BMI Category vs. Cardiovascular Metrics
select
	sq.bmi_category,
	count(sq.bmi_category) as population_value,
	round(avg(sq.systolic_bp::numeric),1) as average_systolic_value,
	round(avg(sq.diastolic_bp::numeric),1) as average_diastolic_value,
	round(avg(sq.heart_rate::numeric), 1) as average_heart_beat
from sleep_quality sq 
group by sq.bmi_category 
order by population_value desc;	
	
-- 4.5 Health Metrics: BMI Category vs. Sleep Disorders
select
	sq.bmi_category,
	count(*) as Total_population,
	count(*) filter (where sq.sleep_disorder = 'Insomnia') as Insomnia_disorder,
	count(*) filter (where sq.sleep_disorder = 'Sleep Apnea') as Sleep_apnea_disorder,
	count(*) filter (where sq.sleep_disorder is Null) as No_disorder
from sleep_quality sq 
group by bmi_category 
	
-- 5.0 PRODUCTION VIEWS FOR BI REPORTING

-- 5.1 View: Occupational Sleep & Stress Metrics
create or replace view v_occupation_sleep_summary as
	select
		sq.occupation,
		count(sq.person_id) as total_employees,
		round(avg(sq.sleep_duration::numeric),2) as average_sleep_duration,
		round(avg(sq.quality_of_sleep::numeric),2) as average_quality_of_sleep,
		round(avg(sq.stress_level::numeric),2) as average_stress_level
	from sleep_quality sq 
	group by occupation;

select * from v_occupation_sleep_summary;

-- 5.2 View: Health Metrics & Sleep Disorders Breakdown
create or replace view v_health_sleep_disorders_summary as
	select 
		sq.bmi_category,
		sq.gender,
		count(*) as total_population,
		count(*) filter (where sq.sleep_disorder = 'Insomnia') as Insomnia_disorder,
		count(*) filter (where sq.sleep_disorder = 'Sleep Apnea') as Sleep_apnea_disorder,
		count(*) filter (where sq.sleep_disorder is Null) as No_disorder,
		round(avg(sq.systolic_bp::numeric),1) as average_systolic_value,
		round(avg(sq.diastolic_bp::numeric),1) as average_diastolic_value
	from sleep_quality sq
	group by bmi_category, gender
	order by bmi_category;
select * from sleep_quality sq 

select * from v_health_sleep_disorders_summary;
















