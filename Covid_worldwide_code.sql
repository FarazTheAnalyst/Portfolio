/*
Pulled two spreadsheets from Kaggle. Both can be found here: https://www.kaggle.com/code/divyanshikapoor05/pandemic-analysis/input?select=covid_worldwide.csv
- Covid Worldwide
- Covid Data (data from the Mexican Goverment)

Questions i am answering:
-Which country had the highest infection/death/recovery rate?
-What is the average age of people that got infected?
-What are the Top 3 most common pre_existing condition of the tested population?
-What is the average age of death?
-Taking the data from Maxico, what would the estimated percentages for other countries?
-What can patients do to increae there to chances of survival?
*/

--Starting with covid_data. Reminder: This is data from Mexican Goverment
--Find total row counts and distinct values in spreadsheet
SELECT 
	COUNT(USMER)
FROM covidworlddata.dbo.covid_data; -- 1,048,575 unique rows. Per kaggle, this dataset is on all unique patients, no repeates

--Average age of infection
--
SELECT 
	ROUND(AVG(age),0) as avg_age_of_infection
FROM covidworlddata.dbo.covid_data
WHERE CLASIFFICATION_FINAL < 4; -- avg age is 45

--Average age of death
--'9999-99-99' mean alive
SELECT 
	ROUND(AVG(age), 0) as avg_age_of_death
FROM covidworlddata.dbo.covid_data
WHERE DATE_DIED != '9999-99-99'; -- avg age is 61

--Top 3 most common pre-existing condition
SELECT
	sum(CASE WHEN pneumonia =1 THEN 1 ELSE 0 END) as count_pneumonia
	,sum(case when diabetes = 1 then 1 else 0 end) as count_diabetes
	,sum(case when copd = 1 then 1 else 0 end) as count_copd
	,sum(case when asthma = 1 then 1 else 0 end) as count_asthama
	,sum(case when inmsupr = 1 then 1 else 0 end) as count_inmsupr
	,sum(case when hipertension = 1 then 1 else 0 end) as count_hypertension
	,sum(case when other_disease = 1 then 1 else 0 end) as count_other_disease
	,sum(case when cardiovascular = 1 then 1 else 0 end) as count_cardiovascular
	,sum(case when obesity = 1 then 1 else 0 end) as count_obesity
	,sum(case when renal_chronic = 1 then 1 else 0 end) as count_renal_chronic
FROM covidworlddata.dbo.covid_data
/*
1) hipertension with 162,729
2) obesity with 159,816
3) pneumonia with 140,038
*/

--What percentage of those who have died with hipertention, were obese, or had pneumonia, where they admitted to ICU and intubated?
SELECT
	concat(round(100 * sum(case when hipertension = 1 then 1 else 0 end) / count(hipertension), 2), ' %') as percent_hypertension
	,(SELECT
		concat(round(100 * sum(case when icu = 1 then 1 else 0 end) / count(icu), 2), ' %')
	FROM covidworlddata.dbo.covid_data
	WHERE date_died != '9999-99-99' AND hipertension = 1) as percent_hipertension_admitted
	,(SELECT
		concat(round(100 * sum(case when intubed = 1 then 1 else 0 end) / count(intubed), 2), ' %')
	FROM covidworlddata.dbo.covid_data
	WHERE date_died != '9999-99-99' AND hipertension = 1 AND icu = 1) as percent_hipertension_admitted_intubed
FROM covidworlddata.dbo.covid_data
WHERE date_died != '9999-99-99';

SELECT 
	concat(round(100 * sum(case when obesity = 1 then 1 else 0 end) / count(obesity), 2), ' %') as percent_obesity
	,(SELECT 
		concat(round(100 * sum(case when icu = 1 then 1 else 0 end) / count(icu), 2), ' %') 
	FROM covidworlddata.dbo.covid_data
	WHERE date_died != '9999-99-99' AND obesity = 1) as percent_obese_admitted
	,(SELECT
		concat(round(100 * sum(case when intubed = 1 then 1 else 0 end) / count(intubed), 2), ' %') 
	FROM covidworlddata.dbo.covid_data
	WHERE date_died != '9999-99-99' AND obesity = 1 AND icu = 1) as percent_obese_admitted_intubed
FROM covidworlddata.dbo.covid_data
WHERE date_died != '9999-99-99';

SELECT 
	concat(round(100 * sum(case when pneumonia = 1 then 1 else 0 end) / count(pneumonia), 2), ' %') as percent_pneumonia
	,(SELECT
		concat(round(100 * sum(case when icu = 1 then 1 else 0 end) / count(icu), 2), ' %')
	FROM covidworlddata.dbo.covid_data
	WHERE date_died != '9999-99-99' AND pneumonia = 1) as percent_pneumonia_admitted
	,(SELECT
		concat(round(100 * sum(case when intubed = 1 then 1 else 0 end) / count(intubed), 2), ' %')
	FROM covidworlddata.dbo.covid_data
	WHERE date_died != '9999-99-99' AND pneumonia = 1 AND icu = 1) as percent_pneumonia_admitted_intubed
FROM covidworlddata.dbo.covid_data
WHERE date_died != '9999-99-99';

--Conditions that effect the pulmonary system: asthma, pneumonia, copd, cardiovascular, tobacco
SELECT 
	concat(round(100 * sum(case when asthma = 1 then 1 else 0 end) / count(asthma), 2), ' %') as persent_asthmaic
	,concat(round(100 * sum(case when pneumonia = 1 then 1 else 0 end) / count(pneumonia), 2), ' %') as persent_w_pneumonia
	,concat(round(100 * sum(case when copd = 1 then 1 else 0 end) / count(copd), 2), ' %') as persent_w_copd
	,concat(round(100 * sum(case when cardiovascular = 1 then 1 else 0 end) / count(cardiovascular), 2), ' %') as persent_w_cardiovascular
	,concat(round(100 * sum(case when tobacco = 1 then 1 else 0 end) / count(tobacco), 2), ' %') as persent_tobacco_users
FROM covidworlddata.dbo.covid_data
WHERE date_died != '9999-99-99'; --of the patients who died, 70% had pnemonia

--immunosuppressed vs classification
SELECT 
	CASE 
		WHEN clasiffication_final = 1 then '1'
		WHEN clasiffication_final = 2 then '2'
		WHEN clasiffication_final = 3 then '3'
		ELSE '4+'
		END  classification
	,sum(case when inmsupr = 1 then 1 else 0 end) as immunosuppressed
	,sum(case when inmsupr = 2 then 1 else 0 end) as not_immunosuppressed
	,sum(case when inmsupr > 2 then 1 else 0 end) as not_provided
FROM covidworlddata.dbo.covid_data
GROUP BY
	CASE 
		WHEN clasiffication_final = 1 then '1'
		WHEN clasiffication_final = 2 then '2'
		WHEN clasiffication_final = 3 then '3'
		ELSE '4+' END
ORDER BY classification ASC;

/*
The highest count were in either grade 3 or 4+. This means that regardless of whether a person is immunosuppressed or not,
covid hit at a higher degree
*/

--Predictive analysis will be applied to the covid_worldwide dataset, but let's review this first
--Find total new counts and distinct values in the spreadsheet
SELECT
	count(serial_number)
FROM covidworlddata.dbo.covid_worldwide; -- 231 rows

SELECT
	count(distinct serial_number)
FROM covidworlddata.dbo.covid_worldwide; --231 unique rows, which means no repeat countries

--Exploring the world data. it appears that total cases = total deaths + total recovered + active cases.

SELECT 
    serial_number,
    CASE WHEN total_cases = 'N/A' THEN NULL ELSE CAST(REPLACE(total_cases, ',', '') AS INT) END AS total_cases,
    CASE WHEN total_deaths = 'N/A' THEN NULL ELSE CAST(REPLACE(total_deaths, ',', '') AS INT) END AS total_deaths,
    CASE WHEN total_recovered = 'N/A' THEN NULL ELSE CAST(REPLACE(total_recovered, ',', '') AS INT) END AS total_recovered,
    CASE WHEN active_cases = 'N/A' THEN NULL ELSE CAST(REPLACE(active_cases, ',', '') AS INT) END AS active_cases,
	CASE 
        WHEN total_cases = 'N/A' OR total_deaths = 'N/A' OR total_recovered = 'N/A' OR active_cases = 'N/A' THEN NULL 
       ELSE CAST(REPLACE(total_deaths, ',', '') AS INT) + CAST(REPLACE(total_recovered, ',', '') AS INT) + CAST(REPLACE(active_cases, ',', '') AS INT) 
    END AS sum
FROM covidworlddata.dbo.covid_worldwide
ORDER BY serial_number ASC; --sum of these colum is equal to total_cases

SELECT 
	country
	,total_cases
	,total_deaths
	,total_recovered
	,active_cases
FROM covidworlddata.dbo.covid_worldwide
WHERE Total_Deaths + Total_Recovered + Active_Cases is null -- there were no country where sum did not equal total_cases
ORDER BY serial_number ASC;

--top 5 highest death rates
SELECT TOP 5
    serial_number,
    country,
    CONCAT(
        CASE 
            WHEN total_deaths = 'N/A' OR total_cases = 'N/A' THEN NULL 
            ELSE round(CAST(REPLACE(total_deaths, ',', '') AS FLOAT) / CAST(REPLACE(total_cases, ',', '') AS FLOAT) * 100, 2)
        END, ' %'
    ) AS death_rate
FROM covidworlddata.dbo.covid_worldwide
ORDER BY 
    CASE 
        WHEN total_deaths = 'N/A' OR population = 'N/A' THEN NULL 
        ELSE CAST(REPLACE(total_deaths, ',', '') AS FLOAT) / CAST(REPLACE(population, ',', '') AS FLOAT)
    END DESC;

--Top 5 highest revocery rate
SELECT TOP 5 serial_number
	,country
	,concat(
		case
			when Total_Recovered = 'N/A'  OR total_cases = 'N/A' then null
			else round(cast(replace(Total_Recovered,',', '') as float) / cast(replace(total_cases, ',', '') as float), 3)
		end, ' %'
			) as recovery_rate
FROM covidworlddata.dbo.covid_worldwide
ORDER BY 
	case
		when Total_Recovered = 'N/A' OR population = 'N/A' then null
		else cast(replace(Total_Recovered, ',', '') as float) / cast(replace(population, ',', '') as float)
	end DESC; --rounding decimals to 3 points out as DPRK came out to 100%, though query below shows 84 deaths

SELECT * 
FROM covidworlddata.dbo.covid_worldwide
WHERE country IN('Vatican city', 'Falkland islands', 'DPRK')

--TOP 5 infection rate
SELECT TOP 5 serial_number
	,country
	,concat(
		case
			when total_cases = 'N/A' OR population = 'N/A' then null
			else round(cast(replace(total_cases, ',', '') as float) / cast(replace(Population, ',', '') as float), 2)
		end, ' %') as infection_rate
FROM covidworlddata.dbo.covid_worldwide
ORDER BY 
	case
			when total_cases = 'N/A' OR population = 'N/A' then null
			else cast(replace(total_cases, ',', '') as float) / cast(replace(Population, ',', '') as float) END DESC;

--Compare testing rate to death rate and recovery rate
--Higher testing rate
SELECT TOP 5 serial_number
	,country
	,concat(
		case
			when total_test = 'N/A' OR population = 'N/A' then null
			else round(cast(replace(total_test,',','') as float) / cast(replace(population,',','') as float), 2) 
		end, ' %') as testing_rate --compared to population as testing did not mean infection
	,concat(
		case
			when total_deaths = 'N/A' OR total_cases = 'N/A' then null
			else round(cast(replace(total_deaths,',','') as float) / cast(replace(total_cases,',','') as float), 2)
		end, ' %') as death_rate
	,concat(
		case
			when total_recovered = 'N/A' OR total_cases = 'N/A' then null
			else round(cast(replace(total_recovered,',','') as float) / cast(replace(total_cases,',','') as float), 3)
		end, ' %') as recovery_rate
FROM covidworlddata.dbo.covid_worldwide
ORDER BY 
	case
		when total_test = 'N/A' OR population = 'N/A' then null
		else cast(replace(total_test,',','') as float) / cast(replace(population,',','') as float) 
		end DESC; --higher testing rate show higher recovery rate and lower death rate

SELECT 
    CONCAT(
        ROUND(AVG(CAST(death_rate AS FLOAT) * 100), 2), ' %'
    ) AS avg_death_rate
FROM (
    SELECT TOP 5
        serial_number,
        country,
        CASE
            WHEN total_test = 'N/A' OR population = 'N/A' THEN NULL
            ELSE CAST(REPLACE(total_test, ',', '') AS FLOAT) / CAST(REPLACE(population, ',', '') AS FLOAT)
        END AS testing_rate,
        CASE
            WHEN total_deaths = 'N/A' OR total_cases = 'N/A' THEN NULL
            ELSE CAST(REPLACE(total_deaths, ',', '') AS FLOAT) / CAST(REPLACE(total_cases, ',', '') AS FLOAT)
        END AS death_rate,
        CASE
            WHEN total_recovered = 'N/A' OR total_cases = 'N/A' THEN NULL
            ELSE CAST(REPLACE(total_recovered, ',', '') AS FLOAT) / CAST(REPLACE(total_cases, ',', '') AS FLOAT)
        END AS recovery_rate
    FROM covidworlddata.dbo.covid_worldwide
    WHERE 
        CASE
            WHEN total_test = 'N/A' OR population = 'N/A' THEN NULL
            ELSE CAST(REPLACE(total_test, ',', '') AS FLOAT) / CAST(REPLACE(population, ',', '') AS FLOAT)
        END IS NOT NULL
    ORDER BY 
        CASE
            WHEN total_test = 'N/A' OR population = 'N/A' THEN NULL
            ELSE CAST(REPLACE(total_test, ',', '') AS FLOAT) / CAST(REPLACE(population, ',', '') AS FLOAT)
        END ASC
) AS Top_five_testing; --Average death rate is 2.75%, six times higher than with more testing

--Predictive analysis (%) in order to apply predictive trends to the 'total_cases' country data (only for those confirmed with covid)
--Create a view where covid is actually is confirmed
CREATE VIEW dbo.covid_data_confirmed
AS
(
	SELECT * 
	FROM covidworlddata.dbo.covid_data
	WHERE CLASIFFICATION_FINAL < 4
);

--Starting point for predictive analysis
SELECT 
	country
	,CASE
		WHEN population = 'N/A' THEN NULL
		ELSE CAST(REPLACE(population, ',', '') AS INT) END AS population
	,CASE	
		WHEN total_cases = 'N/A' THEN NULL
		ELSE CAST(REPLACE(total_cases, ',', '') AS INT) END AS total_cases
	,CASE
		WHEN total_deaths = 'N/A' THEN NULL
		ELSE CAST(REPLACE(total_deaths, ',', '') AS INT) END AS total_deaths
	,CASE	
		WHEN total_recovered = 'N/A' THEN NULL
		ELSE CAST(REPLACE(total_recovered, ',', '') AS INT) END AS total_recovered
	,CASE	
		WHEN active_cases = 'N/A' THEN NULL
		ELSE CAST(REPLACE(active_cases, ',', '') AS INT) END AS active_cases
	,CASE	
		WHEN total_test = 'N/A' THEN NULL
		ELSE CAST(REPLACE(total_test, ',', '') AS INT) END AS total_test
INTO covidworlddata.dbo.worldwide_predictive
FROM covidworlddata.dbo.covid_worldwide;

--USMER levels
SELECT *
	,cast(total_cases *
	(SELECT 
		count(USMER) / cast((select count(USMER) from covidworlddata.dbo.covid_data_confirmed) as float)
	FROM covidworlddata.dbo.covid_data_confirmed
	WHERE USMER = 1) as int) as usmer_1
	,cast(total_cases * 
	(SELECT 
		count(USMER) / cast((SELECT count(USMER) from covidworlddata.dbo.covid_data_confirmed) as float)
	FROM covidworlddata.dbo.covid_data_confirmed
	WHERE USMER = 2) as int) as umer_2
INTO covidworlddata.dbo.worldwide_predictive_backup
FROM covidworlddata.dbo.worldwide_predictive;

--DROP existing  covidworlddata.dbo.worldwide_predictive table
DROP TABLE covidworlddata.dbo.worldwide_predictive;

--Replacing again to original
SELECT *
INTO covidworlddata.dbo.worldwide_predictive
FROM covidworlddata.dbo.worldwide_predictive_backup;

--Drop existing covidworlddata.dbo.worldwide_predictive_backup table
DROP TABLE covidworlddata.dbo.worldwide_predictive_backup;

-- checking results
SELECT  *
FROM covidworlddata.dbo.worldwide_predictive

--Clasiffication
SELECT *
	,cast(total_cases *
	(SELECT 
		count(clasiffication_final) / cast((select count(clasiffication_final) from covidworlddata.dbo.covid_data_confirmed) as float)
	FROM covidworlddata.dbo.covid_data_confirmed
	WHERE CLASIFFICATION_FINAL = 1) as int) as class_1
	,cast(total_cases *
	(SELECT 
		count(clasiffication_final) / cast((select count(clasiffication_final) from covidworlddata.dbo.covid_data_confirmed) as float)
	FROM covidworlddata.dbo.covid_data_confirmed
	WHERE CLASIFFICATION_FINAL = 2) as int) as class_2
	,cast(total_cases * 
	(SELECT 
		count(clasiffication_final) / cast((select count(clasiffication_final) from covidworlddata.dbo.covid_data_confirmed) as float)
	FROM covidworlddata.dbo.covid_data_confirmed
	WHERE CLASIFFICATION_FINAL = 3) as int) as class_3
INTO covidworlddata.dbo.worldwide__predictive_backup
FROM covidworlddata.dbo.worldwide_predictive;

--Drop existing covidworlddata.dbo.worldwide_predictive
DROP TABLE covidworlddata.dbo.worldwide_predictive;

--Creating from covidworlddata.dbo.worldwide__predictive_backup table
SELECT *
INTO covidworlddata.dbo.worldwide_predictive
FROM covidworlddata.dbo.worldwide__predictive_backup;

--checking Results
SELECT *
FROM covidworlddata.dbo.worldwide_predictive;

--

--Gender and sent home vs hospitalized
SELECT *
	,cast(total_cases *
	(SELECT 
		count(sex) / cast((select count(sex) from covidworlddata.dbo.covid_data_confirmed) as float)
	FROM covidworlddata.dbo.covid_data_confirmed 
	WHERE  sex = 1) as int) as female
	,cast(total_cases *
	(SELECT 
		count(sex) / cast((select count(sex) from covidworlddata.dbo.covid_data_confirmed) as float)
	FROM covidworlddata.dbo.covid_data_confirmed 
	WHERE  sex = 2) as int) as male
	,cast(total_cases *
	(SELECT
		count(patient_type) / cast((select count(patient_type) from covidworlddata.dbo.covid_data_confirmed) as float)
	FROM covidworlddata.dbo.covid_data_confirmed
	WHERE patient_type = 1) as int) as sent_home
	,cast(total_cases *
	(SELECT
		count(patient_type) / cast((select count(patient_type) from covidworlddata.dbo.covid_data_confirmed) as float)
	FROM covidworlddata.dbo.covid_data_confirmed
	WHERE patient_type = 2) as int) as hospitilized
INTO covidworlddata.dbo.worldwide_predictive_backup
FROM covidworlddata.dbo.worldwide_predictive;

--Drop existing covidworlddata.dbo.worldwide_predictive
DROP TABLE covidworlddata.dbo.worldwide_predictive;

--Replace  table
SELECT *
INTO covidworlddata.dbo.worldwide_predictive
FROM covidworlddata.dbo.worldwide_predictive_backup;

--DROP existing covidworlddata.dbo.worldwide_predictive
DROP TABLE covidworlddata.dbo.worldwide_predictive_backup

--Check results
SELECT *
FROM covidworlddata.dbo.worldwide__predictive_backup;

--For the following, i will be including the only yes responses. Split into 3 sets to prevent overload on system
--First set: Intubated, Pneumonia, Pregnent, Diabetes
SELECT *
	,cast(total_cases * 
		(SELECT
		count(intubed) / cast((select count(intubed) from covidworlddata.dbo.covid_data_confirmed) as float)
		FROM covidworlddata.dbo.covid_data_confirmed
		WHERE intubed = 1) as int) as intubated
	,cast(total_cases *
		(SELECT
		count(pneumonia) / cast((select count(pneumonia) from covidworlddata.dbo.covid_data_confirmed) as float)
		FROM covidworlddata.dbo.covid_data_confirmed
		WHERE pneumonia = 1) as int) as pneumonia
	,cast(total_cases *
		(SELECT
		count(pregnant) / cast((select count(pregnant) from covidworlddata.dbo.covid_data_confirmed) as float)
		FROM covidworlddata.dbo.covid_data_confirmed 
		WHERE pregnant = 1) as int) as pregnant
	,cast(total_cases * 
		(SELECT
		count(diabetes) / cast((select count(diabetes) from covidworlddata.dbo.covid_data_confirmed) as float)
		FROM covidworlddata.dbo.covid_data_confirmed
		WHERE diabetes = 1) as int) as diabetes
INTO covidworlddata.dbo.worldwide_predictive_backup
FROM covidworlddata.dbo.worldwide_predictive;

--Drop a existing covidworlddata.dbo.worldwide_predictive table
DROP TABLE covidworlddata.dbo.worldwide_predictive;

--Replacing a data into covidworlddata.dbo.worldwide_predictive table
SELECT *
INTO covidworlddata.dbo.worldwide_predictive
FROM covidworlddata.dbo.worldwide_predictive_backup;

--Drop a existing covidworlddata.dbo.worldwide_predictive_backup table
DROP TABLE covidworlddata.dbo.worldwide_predictive_backup;

--Check results
SELECT *
FROM covidworlddata.dbo.worldwide_predictive;

--Second set: COPD, Asthma, Immunosuppressed, hipertension
--Creating a backup table or copy
SELECT *
	,cast(total_cases * 
		(SELECT
			count(copd) / cast((select count(copd) from covidworlddata.dbo.covid_data_confirmed) as float)
			FROM covidworlddata.dbo.covid_data_confirmed
			WHERE copd = 1) as int) as copd
	,cast(total_cases *
		(SELECT
			count(asthma) / cast((select count(asthma) from covidworlddata.dbo.covid_data_confirmed) as float)
			FROM covidworlddata.dbo.covid_data_confirmed
			WHERE asthma = 1) as int) as asthma
	,cast(total_cases *
		(SELECT
			count(inmsupr) / cast((select count(inmsupr) from covidworlddata.dbo.covid_data_confirmed) as float)
			FROM covidworlddata.dbo.covid_data_confirmed
			WHERE inmsupr = 1) as int) as immunosuppressed
	,cast(total_cases * 
		(SELECT 
			count(hipertension) / cast((select count(hipertension) from covidworlddata.dbo.covid_data_confirmed) as float)
			FROM covidworlddata.dbo.covid_data_confirmed
			WHERE hipertension = 1) as int) as hypertention
INTO covidworlddata.dbo.worldwide_predictive_backup
FROM covidworlddata.dbo.worldwide_predictive;

--Drop existing covidworlddata.dbo.worldwide_predictive table
DROP TABLE covidworlddata.dbo.worldwide_predictive;

--Replacing a table
SELECT *
INTO covidworlddata.dbo.worldwide_predictive
FROM covidworlddata.dbo.worldwide_predictive_backup;

--Drop backup table or copy of covidworlddata.dbo.worldwide_predictive
DROP TABLE covidworlddata.dbo.worldwide_predictive_backup;

--Check results
SELECT * 
FROM covidworlddata.dbo.worldwide_predictive;

--Third set: Other Disease, Cardiovascular, Renal Chronic, Obesity, Tobacco, ICU admission
--Create a backup or copy of table
SELECT *
	,cast(total_cases *
		(SELECT
			count(other_disease) / cast((select count(other_disease) from covidworlddata.dbo.covid_data_confirmed) as float)
			FROM covidworlddata.dbo.covid_data_confirmed
			WHERE other_disease =1) as int) as other_disease
	,cast(total_cases * 
		(SELECT
			count(cardiovascular) / cast((select count(cardiovascular) from covidworlddata.dbo.covid_data_confirmed) as float)
			FROM covidworlddata.dbo.covid_data_confirmed
			WHERE cardiovascular = 1) as int) as cardiovascular
	,cast(total_cases * 
		(SELECT 
			count(renal_chronic) / cast((select count(renal_chronic) from covidworlddata.dbo.covid_data_confirmed) as float)
			FROM covidworlddata.dbo.covid_data_confirmed
			WHERE renal_chronic = 1) as int) as renal_chronic
	,cast(total_cases*
		(SELECT 
			cast(count(obesity) as float) / cast((select count(obesity) from covidworlddata.dbo.covid_data_confirmed) as float)
			FROM covidworlddata.dbo.covid_data_confirmed
			WHERE obesity = 1) as int) as obese
	,cast(total_cases *
		(SELECT 
			count(tobacco) / cast((select count(tobacco) from covidworlddata.dbo.covid_data_confirmed) as float)
			FROM covidworlddata.dbo.covid_data_confirmed
			WHERE tobacco = 1) as int) as tobacco
	,cast(total_cases *
        (SELECT
        count(icu) / cast((select count(icu) from covidworlddata.dbo.covid_data_confirmed) as float)
        from covidworlddata.dbo.covid_data_confirmed where icu = 1) as int) as icu
INTO covidworlddata.dbo.worldwide_predictive_backup
FROM covidworlddata.dbo.worldwide_predictive;

--Drop existing covidworlddata.dbo.worldwide_predictive table
DROP TABLE covidworlddata.dbo.worldwide_predictive;

--Replace a table
SELECT * 
INTO covidworlddata.dbo.worldwide_predictive
FROM covidworlddata.dbo.worldwide_predictive_backup;

--Drop backup covidworlddata.dbo.worldwide_predictive_backup table
DROP TABLE covidworlddata.dbo.worldwide_predictive_backup;

--check results
SELECT * 
FROM covidworlddata.dbo.worldwide_predictive;

--Creating a death_rate column and inserting into covidworlddata.dbo.worldwide_predictive table
--Create a backup or copy of covidworlddata.dbo.worldwide_predictive
SELECT 
    *,
    CONCAT(
        ROUND(total_deaths / cast(total_cases as float) * 100, 2), ' %'
    ) AS death_rate
INTO covidworlddata.dbo.worldwide_predictive_backup
FROM covidworlddata.dbo.worldwide_predictive;

--DROP  a existing covidworlddata.dbo.worldwide_predictive
DROP TABLE covidworlddata.dbo.worldwide_predictive;

--Replacing a existing covidworlddata.dbo.worldwide_predictive_backup table
SELECT *
INTO covidworlddata.dbo.worldwide_predictive
FROM covidworlddata.dbo.worldwide_predictive_backup;

--Drop covidworlddata.dbo.worldwide_predictive_backup table
DROP TABLE covidworlddata.dbo.worldwide_predictive_backup;

--creating and inserting recovery_rate column in covidworlddata.dbo.worldwide_predictive
SELECT *
	,CONCAT(
		round(Total_Recovered / CAST(total_cases as float) * 100, 3), ' %') as recovery_rate
INTO covidworlddata.dbo.worldwide_predictive_backup
FROM covidworlddata.dbo.worldwide_predictive;

--Drop a existing covidworlddata.dbo.worldwide_predictive table
DROP TABLE covidworlddata.dbo.worldwide_predictive;

--Replace to original
SELECT *
INTO covidworlddata.dbo.worldwide_predictive
FROM covidworlddata.dbo.worldwide_predictive_backup;

--Drop a existing covidworlddata.dbo.worldwide_predictive_backup
DROP TABLE covidworlddata.dbo.worldwide_predictive_backup;

--Creating a testing_rate column in covidworlddata.dbo.worldwide_predictive
SELECT *
	,concat(
		round((total_test / cast(population as float)), 2), ' %') as testing_rate
INTO covidworlddata.dbo.worldwide_predictive_backup
FROM covidworlddata.dbo.worldwide_predictive;

--Drop a existing covidworlddata.dbo.worldwide_predictiv
DROP TABLE covidworlddata.dbo.worldwide_predictive;

--Replace a table
SELECT *
INTO covidworlddata.dbo.worldwide_predictive
FROM covidworlddata.dbo.worldwide_predictive_backup;

--Drop a existing covidworlddata.dbo.worldwide_predictive_backup table
DROP TABLE covidworlddata.dbo.worldwide_predictive_backup;



		

















    


















