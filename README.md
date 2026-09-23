# 💤 Sleep Health & Lifestyle Analytics (SQL + Power BI)

## 📌 Project Overview
This project presents an **end-to-end data analysis pipeline** exploring the relationship between sleep quality, occupation, and health metrics (BMI, stress levels, sleep disorders).

The goal was to transform raw tabular data into actionable business insights using **PostgreSQL** for data cleaning and aggregation, followed by an executive dashboard built in **Power BI** to visualize key dependencies.

---

## 📊 Key Insights & Business Findings
- **High Risk in Overweight/Obese Groups:** 100% stacked visual analysis revealed that obesity and overweight categories have a significantly higher prevalence of sleep disorders (Insomnia and Sleep Apnea) compared to the normal weight group.
- **Occupational Disparities:** **Engineers** enjoy the highest average sleep duration (~7.99 hours/day), whereas **Sales Representatives** suffer from the lowest sleep duration (~5.90 hours/day).
- **Stress Level Impact:** Higher self-reported stress levels strongly correlate with reduced sleep efficiency and increased sleep disorder rates.

---

## 🛠️ Tech Stack & Methodology
- **Database Engine:** PostgreSQL
- **BI & Visualization:** Power BI Desktop
- **Data Transformation:** Power Query, SQL Views
- **Concepts Applied:** SQL Aggregations, GROUP BY, Data Type Conversions, Relational Data Modeling, 100% Stacked Bar/Column Charts.

---

## 🗄️ Database Architecture & SQL Views

The analysis was performed using modular database views created in PostgreSQL to separate data preparation from visualization logic.

### 1. Occupation vs. Sleep Summary View
Calculates average sleep duration, physical activity, and stress metrics grouped by occupation.


```sql
create or replace view v_occupation_sleep_summary as
	select
		sq.occupation,
		count(sq.person_id) as total_employees,
		round(avg(sq.sleep_duration::numeric),2) as average_sleep_duration,
		round(avg(sq.quality_of_sleep::numeric),2) as average_quality_of_sleep,
		round(avg(sq.stress_level::numeric),2) as average_stress_level
	from sleep_quality sq 
	group by occupation;
```
2. BMI vs. Sleep Disorders View
Aggregates the occurrence of sleep disorders across different BMI categories.
```sql
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
```
📈 Power BI Dashboard Highlights
The interactive dashboard includes two primary visuals designed for executive reporting:

Average Sleep Duration by Occupation (Clustered Bar Chart): Sorted descending to quickly highlight best and worst performing professions.

Sleep Disorder Breakdown by BMI Category (100% Stacked Bar Chart): Normalized to show proportions and eliminate sample size bias across weight categories.

![Sleep Health Analytics Dashboard](Sleep_health_and_lifestyle_dataset/assets/powerbi_asset.png)
```
📁 Repository Structure
├── assets/
│   └── powerbi_asset.png
├── data/
│   └── sleep_quality_202609211732.csv
├── powerbi/
│   └── sleep_quality_bi.pbix
├── sql/
│   └── sleep_quality.sql
└── README.md
```
👨‍💻 Author
Daniel Żebrowski

Aspiring Data Analyst | SQL, Power BI & Python

LinkedIn: [Daniel Żebrowski](https://www.linkedin.com/in/daniel-%C5%BCebrowski-7a0937211/)

GitHub: @DanielZebrowski-Data
