/* 
This dataset was pulled from Kaggle: https://www.kaggle.com/datasets/nursma/bellabeat-case-study-ii-google-capstone-project
7 out of 18 files have been uploaded to sqlserver. The files that have not been uploaded are the spreadsheets that
brekdown the data by minutes. per the PDF project , the data collected is from 30 users.
*/

--Verifying that there are 30 unique ID entries in the summary CSV spreadsheets
SELECT 
	COUNT(DISTINCT id)
FROM Bellabeat.dbo.dailyActivity_merged AS daily_activity; --33 unique IDs

SELECT 
	COUNT(DISTINCT id)
FROM Bellabeat.dbo.dailyCalories_merged as daily_calories; --33 unique IDs

SELECT 
	COUNT(DISTINCT id)
FROM Bellabeat.dbo.dailyIntensities_merged AS daily_intensities; --33 unique IDs

SELECT 
	COUNT(DISTINCT id)
FROM Bellabeat.dbo.dailySteps_merged AS daily_steps; --33 unique IDs

SELECT 
	COUNT(DISTINCT id)
FROM Bellabeat.dbo.heartrate_seconds_merged AS heartrate_seconds; --14 unique IDs

SELECT 
	COUNT(DISTINCT id)
FROM Bellabeat.dbo.sleepDay_merged AS sleep_day; --24 unique IDs

SELECT 
	COUNT(DISTINCT id)
FROM Bellabeat.dbo.weightLogInfo_merged AS wieght_log_info; --8 unique IDs

/*
More user data is not bad thing, just means i have more data to work with to get better results. it is time to make sure that
data across other spreadsheets is consistent
--'Calories' from daily_activity and daily _calories should be the same
--'TotalStep' from daily_activity should be the same as 'StepTotal' from daily_steps
--intensity readings should be the same from daily_activity and daily_intensities

These will be checked one by one. Zero output means data is consistent across spreadsheets.
*/

--verifying 'Calories'
SELECT 
	daily_activity.id
	,daily_activity.ActivityDate
	,daily_activity.Calories AS DAC
	,daily_calories.Calories AS DCC
FROM Bellabeat.dbo.dailyActivity_merged AS daily_activity
INNER JOIN Bellabeat.dbo.dailyCalories_merged AS daily_calories
ON daily_activity.Calories = daily_activity.Calories
WHERE daily_activity.Calories != daily_activity.Calories; --zero output

--Verifying Total Steps
SELECT 
	daily_activity.id
	,daily_activity.ActivityDate
	,daily_activity.TotalSteps
	,daily_steps.StepTotal
FROM Bellabeat.dbo.dailyActivity_merged AS daily_activity
INNER JOIN Bellabeat.dbo.dailySteps_merged AS daily_steps
ON daily_activity.TotalSteps = daily_steps.StepTotal
WHERE daily_activity.TotalSteps != daily_steps.StepTotal; --zero output

--Verifying intensities
SELECT *
FROM Bellabeat.dbo.dailyActivity_merged AS daily_activity
INNER JOIN Bellabeat.dbo.dailyIntensities_merged AS daily_intersities
ON 
	daily_activity.VeryActiveDistance = daily_intersities.VeryActiveDistance
	AND daily_activity.ModeratelyActiveDistance = daily_intersities.ModeratelyActiveDistance
	AND daily_activity.LightActiveDistance = daily_intersities.LightActiveDistance
	AND daily_activity.SedentaryActiveDistance = daily_intersities.SedentaryActiveDistance
	AND daily_activity.VeryActiveMinutes = daily_intersities.VeryActiveMinutes
	AND daily_activity.FairlyActiveMinutes = daily_intersities.FairlyActiveMinutes
	AND daily_activity.LightlyActiveMinutes = daily_intersities.LightlyActiveMinutes
	AND daily_activity.SedentaryMinutes = daily_intersities.SedentaryMinutes
WHERE 
	daily_activity.VeryActiveDistance != daily_intersities.VeryActiveDistance
	OR daily_activity.ModeratelyActiveDistance != daily_intersities.ModeratelyActiveDistance
	OR daily_activity.LightActiveDistance != daily_intersities.LightActiveDistance
	OR daily_activity.SedentaryActiveDistance != daily_intersities.SedentaryActiveDistance
	OR daily_activity.VeryActiveMinutes != daily_intersities.VeryActiveMinutes
	OR daily_activity.FairlyActiveMinutes != daily_intersities.FairlyActiveMinutes
	OR daily_activity.LightlyActiveMinutes != daily_intersities.LightlyActiveMinutes
	OR daily_activity.SedentaryMinutes != daily_intersities.SedentaryMinutes; --zero output

/*
Data fields are the same. This means that i can with just the daily_activity data Noticed TotalDistance and 
TrackerDistance in daily_activity do not match for 15 entries the entries are made up of distinct users. 
In future analysis, i will use TotalDistance, but i will note these as possible user error and present to stakeholders.
*/

--Showing count of errors and respective user IDs
SELECT 
	id
	,count(id) as errors
FROM Bellabeat.dbo.dailyActivity_merged 
WHERE TotalDistance != TrackerDistance
GROUP BY id; -- errors 15

--Creating distance_user_error table
SELECT *
INTO Bellabeat.dbo.distance_user_error
FROM Bellabeat.dbo.dailyActivity_merged
WHERE TotalDistance != TrackerDistance;

--Create a backup or copy of existing table
SELECT * 
INTO Bellabeat.dbo.dailyActivity_merged_backup
FROM Bellabeat.dbo.dailyActivity_merged;

--Drop the Existing Bellbeat.dbo.dailyActivity_merge table
DROP TABLE Bellabeat.dbo.dailyActivity_merged;


--Create column with activity minutes totals
SELECT 
	id
	,ActivityDate
	,TotalSteps
	,TotalDistance
	,TrackerDistance
	,LoggedActivitiesDistance
	,VeryActiveDistance
	,ModeratelyActiveDistance
	,LightActiveDistance
	,SedentaryActiveDistance
	,(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes) AS TotalActivityMinutes
	,VeryActiveMinutes
	,FairlyActiveMinutes
	,LightlyActiveMinutes
	,SedentaryMinutes
	,Calories
INTO Bellabeat.dbo.dailyActivity_merged
FROM Bellabeat.dbo.dailyActivity_merged_backup;

--Drop table Bellabeat.dbo.dailyActivity_merged_backup
DROP TABLE Bellabeat.dbo.dailyActivity_merged_backup;

/*
Last 3 spreadsheets will be reviewed cleaned
*/

----Create a backup or copy of existing table
SELECT *
INTO dbo.heartrate_seconds_merged_backup
FROM Bellabeat.dbo.heartrate_seconds_merged;

--Drop the existing Bellabeat.dbo.heartrate_seconds_merged table
DROP TABLE Bellabeat.dbo.heartrate_seconds_merged;

--In the heartrate_seconds, change column 'value' to 'BPM'
SELECT 
	Id
	,Time
	,Value AS BPM
INTO Bellabeat.dbo.heartrate_seconds_merged
FROM Bellabeat.dbo.heartrate_seconds_merged_backup;

--Drop table Bellabeat.dbo.heartrate_seconds_merged_backup
DROP TABLE Bellabeat.dbo.heartrate_seconds_merged_backup;

--In sleepDay, check to see if the time portions of the date string are different
SELECT *
FROM Bellabeat.dbo.sleepDay_merged
WHERE SleepDate NOT LIKE '%12:00:00%'; --zero output, so time will be removed

--Create a backup or copy of existing Table
SELECT *
INTO Bellabeat.dbo.sleepDay_merged_backup
FROM Bellabeat.dbo.sleepDay_merged;

--Drop the existing Bellabeat.dbo.sleepDay_merged table
DROP TABLE Bellabeat.dbo.sleepDay_merged;

SELECT 
	Id
	,LEFT(CAST(sleepDate AS date), CHARINDEX(' ', sleepDate) -1) AS sleepDate
	,TotalSleepRecords
	,TotalMinutesAsleep
	,TotalTimeInBed
INTO Bellabeat.dbo.sleepDay_merged
FROM Bellabeat.dbo.sleepDay_merged_backup;

--Drop table Bellabeat.dbo.sleepDay_merged_backup
DROP TABLE Bellabeat.dbo.sleepDay_merged_backup;

--Only two rows have values in Fat column, so column will not be used in analysis
SELECT *
FROM Bellabeat.dbo.weightLogInfo_merged
WHERE Fat IS NOT NULL; --2 rows have have values

/*
Now clean up has been completed, it is time to find some trends, such as
--Average total steps, total distance, active distance, active minutes, calories
--Average daily BPMs
--Average minutes asleep, Average time in bed
--Average weight kg and lbs, Average BMI
--Heartrate versus activity levels and calories
--Sleep versus activity levels
*/

--Create view From averages from Bellabeat.dbo.dailyActivity_merge spreadsheet. Dates are not importent here
CREATE VIEW dbo.dailyActivity_avgs
AS
(
	SELECT 
		Id
		,avg(TotalSteps) as avg_total_steps
		,avg(TotalDistance) as avg_total_dist
		,avg(VeryActiveDistance) as avg_very_active_dist
		,avg(ModeratelyActiveDistance) as avg_moderate_active_dist
		,avg(LightActiveDistance) as avg_light_active_dist
		,avg(SedentaryActiveDistance) as avg_sedentary_active_dist
		,avg(TotalActivityMinutes) as avg_total_activity_mins
		,avg(VeryActiveMinutes) as avg_very_active_mins
		,avg(FairlyActiveMinutes) as avg_fairly_active_mins
		,avg(LightlyActiveMinutes) as avg_lightly_active_mins
		,avg(SedentaryMinutes) as avg_sedentary_mins
		,avg(Calories) as avg_calories
	FROM dbo.dailyActivity_merged
	GROUP BY Id
);

--Created view for the average heartrates. Date are not important here
CREATE VIEW dbo.heartrate_avgs
AS
(
	SELECT 
		Id
		,avg(BPM) as avg_bpm
FROM heartrate_seconds_merged
GROUP BY Id
);

--Created averages of sleep averages. Dates are not important here
CREATE VIEW dbo.sleep_avgs
AS
(
	SELECT 
		Id
		,avg(TotalMinutesAsleep) as avg_time_sleeping
		,avg(TotalTimeInBed) as avg_bed_time
FROM Bellabeat.dbo.sleepDay_merged
GROUP BY Id
);

--Created view for weight averages. Dated are not important here
CREATE OR ALTER VIEW dbo.weight_avgs
AS
(
	SELECT 
		Id
		,avg(WeightKg) as avg_kg
		,avg(WeightPounds) as avg_lbs
		,avg(BMI) as avg_BMI ----body mass index
FROM Bellabeat.dbo.weightLogInfo_merged
GROUP BY Id
);

--Compare weight, calories, and activity time
SELECT 
	D.Id
	,D.avg_total_activity_mins
	,D.avg_calories
	,W.avg_lbs
	,W.avg_BMI ----body mass index, A high BMI can indicate high body fatness.
FROM Bellabeat.dbo.dailyActivity_avgs as D
INNER JOIN Bellabeat.dbo.wieght_avgs as W
ON D.Id = W.Id
ORDER BY D.avg_total_activity_mins DESC; --on average, the longer the activity minutes, the lower the BMI

--Compare heartrate to calories and wieght
SELECT 
	H.Id
	,H.avg_bpm --beats per minutes
	,D.avg_calories
	,W.avg_kg
    ,W.avg_lbs
    ,W.avg_BMI --body mass index, A high BMI can indicate high body fatness.
FROM dbo.heartrate_avgs as H
INNER JOIN Bellabeat.dbo.dailyActivity_avgs as D
ON H.Id = D.Id
INNER JOIN Bellabeat.dbo.weight_avgs as W
ON H.Id = W.Id
ORDER BY H.avg_bpm DESC; --not enough data to come to conclusion

--Look into time in bed vs sleeping time
SELECT AVG(avg_bed_time - avg_time_sleeping) as avg_time_awake
FROM Bellabeat.dbo.sleep_avgs; --avg time awake in bed about 42 mins

--Compare sleep to activity time
SELECT
	S.Id
	,S.avg_time_sleeping
	,(CAST(S.avg_time_sleeping AS FLOAT)/CAST(S.avg_bed_time AS FLOAT)) as sleeping_ratio
	,D.avg_total_activity_mins
FROM Bellabeat.dbo.sleep_avgs as S
INNER JOIN Bellabeat.dbo.dailyActivity_avgs as D
ON S.Id = D.Id
GROUP BY 
	S.Id
	,S.avg_time_sleeping
	,S.avg_bed_time
	,D.avg_total_activity_mins
ORDER BY sleeping_ratio DESC; --on average, more sleep means more activity time

/*
Look at the averages, there are some points worth noting.
1) There isn't nearly enough data for heartrate and weight comparisons. There were only 4 users
2) Average time spent in Bed awake is about 42 minutes
3) More sleep appears to lead to longer activity times
4) When high calories are combined with high intensity, weight is lower. There are only 8 entries in the weight averages
*/
