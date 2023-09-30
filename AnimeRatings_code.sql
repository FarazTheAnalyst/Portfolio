/* This dataset was pulled from Kaggle: https://www.kaggle.com/code/phalgunsanthapuri/anime-ratings/data?select=MALratings.csv
My goal for this analysis is to find out what an anime should have in order to increase it's chances of success.
*/

-- Check titles duplicates
SELECT 
	COUNT(title) AS row_count
	,COUNT(DISTINCT title) AS title_count
FROM AnimeRatings.dbo.ratings; --row_count is 2043, title_count is 20342

--Find the duplicates
SELECT 
	title
	,COUNT(title) AS count
FROM AnimeRatings.dbo.ratings
GROUP BY title
ORDER BY count DESC;

--Dakaretai Movie is the duplicates, will compare the rows to make sure they are actually duplicated rows
SELECT *
FROM AnimeRatings.dbo.ratings
WHERE title LIKE 'Dakaretai%Movie%' -- duplicate rows

--Creating new table to work on and clean.
SELECT 
	DISTINCT title
	,genres
	,rank
	,popularity
	,score
	,episodes
	,episode_length
	,release_date
INTO animeratings.dbo.anime_list
FROM AnimeRatings.dbo.ratings
ORDER BY title ASC;

--Check for Null values for all other columns
SELECT COUNT(genres) as genres
FROM animeratings.dbo.anime_list; --10015 non null values

SELECT COUNT(rank) as rank
FROM animeratings.dbo.anime_list; -- no null values

SELECT COUNT(popularity) as popularity
FROM animeratings.dbo.anime_list; -- no null values

SELECT COUNT(score) as score
FROM animeratings.dbo.anime_list; -- no null values

SELECT COUNT(episodes) as episodes
FROM animeratings.dbo.anime_list; -- no null values

SELECT COUNT(episode_length) as eposode_length
FROM animeratings.dbo.anime_list; -- no null values

SELECT COUNT(release_date) as release_date
FROM animeratings.dbo.anime_list; -- 5087 non null values

/* Over half the genres are NULL. This will effect the final output Noticed that 
some 'N/A', '/A' or 'Unknown' values in some column this is noticed for analysics
*/

--Averages

--Average episodes
SELECT AVG(CAST(episodes AS INT)) AS avg_episode_count
FROM animeratings.dbo.anime_list
WHERE episodes != 'Unknown'; -- 12.56 episodes, we'll say about 13

--Average score
SELECT AVG(CAST(score as FLOAT)) AS avg_score
FROM animeratings.dbo.anime_list
WHERE score != 'N/A'; -- 6.45

--Average popularity
SELECT AVG(CAST(popularity AS SMALLINT)) as avg_popularity
FROM animeratings.dbo.anime_list; -- 10,174.76 Subscribers, we'll say 10,175

--Distribution of release dates by season and by year

-- BY season
SELECT 
	LEFT(release_date, CHARINDEX(' ', release_date) -1) as release_date_season
	,COUNT(release_date) as distribution
FROM animeratings.dbo.anime_list
GROUP BY LEFT(release_date, CHARINDEX(' ' , release_date) -1)
ORDER BY distribution DESC; -- more anime came out in the spring

--BY year
SELECT 
	SUBSTRING(release_date, CHARINDEX(' ', release_date) + 1, LEN(release_date) - CHARINDEX(' ', release_date)) as release_date_year
	,COUNT(release_date) AS distribution
FROM animeratings.dbo.anime_list
GROUP BY SUBSTRING(release_date, CHARINDEX(' ', release_date) + 1, LEN(release_date) - CHARINDEX(' ', release_date))
ORDER BY distribution DESC; -- more anime came out in 2016

-- Anime came out in 'Spring 2016'
SELECT 
	COUNT(release_date) as count
FROM animeratings.dbo.anime_list
WHERE release_date = 'Spring 2016'
GROUP BY release_date; -- 76 anime came out in 'Spring 2016'

--Compare this to the normal max count of the release_date
SELECT 
	release_date
	,COUNT(release_date) as count
FROM animeratings.dbo.anime_list
GROUP BY release_date
ORDER BY count DESC; -- Spring 2017 had the most anime releases with 85. would be interesting to see genres and average ratings between this and spring 2016 when we get rid of all incomplete data

SELECT 
	release_date
	,COUNT(release_date) as anime_released
	,avg(cast(rank as int)) as avg_rank
	,avg(cast(popularity as int)) as avg_popularity
	,avg(cast(score as float)) as avg_score
	,avg(cast(episodes as int)) as avg_episodes
FROM animeratings.dbo.anime_list
WHERE 
	(release_date = 'Spring 2016' OR release_date = 'Spring 2017') 
	AND rank != '/A'
	AND score != 'N/A'
	AND episodes != 'Unknown'
GROUP BY release_date; 

/*averages are relatively the same. Popularity is the only thing that has a larger difference: avg_rank is 5649 in 2017
and 5188 in 2016. Ulitmately the spring seems to be when most animes are released
*/

-- Top 5 based on rank
SELECT 
	TOP 5 title
	,genres
	,cast(rank as int) as rank
	,cast(popularity as int) as popularity
	,score
	,episodes
	,episode_length
	,release_date
FROM animeratings.dbo.anime_list
WHERE rank != '/A'
ORDER BY rank ASC;

-- episode count distribution. There were 515 'Unknown', hence why i could not convert to int type
SELECT
	episodes
	,count(episodes) as episode_distribution
FROM animeratings.dbo.anime_list
GROUP BY episodes
ORDER BY episodes DESC; -- 515 are unknown

SELECT
	avg(cast(episodes as int)) as avg_episodes,
	CASE
		WHEN popularity <= 500 THEN '1 - 500 Subs'
		WHEN popularity >= 501 AND popularity <= 1000 THEN '501 - 1,000 Subs'
		WHEN popularity >= 1001 AND popularity <= 5000 THEN '1,001 - 5,000 Subs'
		WHEN popularity >= 5001 AND popularity <= 10000 THEN '5,001 - 10,000 Subs'
		WHEN popularity >= 10001 AND popularity <= 20000 THEN '10,001 - 20,000 Subs'
		ELSE 'more than 20,000 Subs'
	END AS popularity
FROM animeratings.dbo.anime_list
WHERE episodes != 'Unknown'
GROUP BY 
	CASE
		WHEN popularity <= 500 THEN '1 - 500 Subs'
		WHEN popularity >= 501 AND popularity <= 1000 THEN '501 - 1,000 Subs'
		WHEN popularity >= 1001 AND popularity <= 5000 THEN '1,001 - 5,000 Subs'
		WHEN popularity >= 5001 AND popularity <= 10000 THEN '5,001 - 10,000 Subs'
		WHEN popularity >= 10001 AND popularity <= 20000 THEN '10,001 - 20,000 Subs'
		ELSE 'more than 20,000 Subs'
	END
ORDER BY avg_episodes DESC;


/*
RESULTS
avg_episodes: popularity
30	more than 20,000 Subs
22	1 - 500 Subs
14	501 - 1,000 Subs
13	10,001 - 20,000 Subs
12	1,001 - 5,000 Subs
9	5,001 - 10,000 Subs
*/

--Rank count distribution. There were 1880 '/A', hence why i could not convert  to int datatype
SELECT
	rank
	,count(rank) as rank_count
FROM animeratings.dbo.anime_list
GROUP BY rank
ORDER BY rank_count DESC; --1880 are '/A'

--Genre vs rank average. Top 10 genres.
SELECT 
	TOP 10 genres
	,avg(cast(rank as int)) as avg_rank
FROM animeratings.dbo.anime_list
WHERE rank != '/A'
GROUP BY genres
ORDER BY avg_rank ASC;

/*
RESULTS
Rank:		Genres
36:		Adventure,Award Winning,Supernatural
55:		Drama,Sci-Fi,Suspense
75:		Adventure,Fantasy,Mystery,Slice of Life,Supernatural
84:		Comedy,Mystery,Romance
93:		Avant Garde,Drama,Sci-Fi
99:		Action,Drama,Mystery,Romance,Supernatural,Suspense
140:	Action,Adventure,Comedy,Drama,Mystery
145:	Action,Drama,Slice of Life,Sports
174:	Adventure,Drama,Fantasy,Mystery,Sci-Fi
219:	Drama,Fantasy,Romance,Slice of Life
*/

--Distribution of averages by season
SELECT 
	LEFT(release_date, CHARINDEX(' ', release_date) -1) as release_date_season
	,count(release_date) as anime_released
	,avg(cast(rank as int)) as avg_rank
	,avg(cast(popularity as int)) as avg_popularity
	,avg(cast(score as float)) as avg_score
	,avg(cast(episodes as int)) as avg_spisodes
FROM animeratings.dbo.anime_list
WHERE rank != '/A'
AND score != 'N/A'
AND episodes != 'Unknown'
GROUP BY LEFT(release_date, CHARINDEX(' ', release_date) -1)
ORDER BY avg_rank ASC;

/*Spring has the most anime releases, followed by Fall The highest ranking anime were released in Fall followed by Spring.
popularity on average is higer in Spring (not including the null) and second highest in Fall
*/

--583 Unknown episode lengths
SELECT 
	COUNT(episode_length) as count_of_UNK
FROM animeratings.dbo.anime_list
WHERE episode_length = 'Unknown'; --583 are Unknown

--476 episodes with only seconds as length as length
SELECT 
	COUNT(episode_length) as only_seconds
FROM animeratings.dbo.anime_list
WHERE episode_length LIKE '%sec%'
AND episode_length NOT LIKE '%min%'
AND episode_length NOT LIKE '%hr%'; --removing the 'hr' and 'min' conditions also gives 476

--Compare score and popularity with episode length
SELECT
  CASE
    WHEN episode_length LIKE '%hr%' THEN 'Greater than 1 hour long'
    WHEN episode_length NOT LIKE '%hr%' AND episode_length != 'Unknown' THEN 'Less than 1 hour long'
    ELSE 'Unknown length'
    END AS duration,
  count(episode_length) as count,
  avg(cast(rank as int)) as avg_rank,
  avg(cast(popularity as int)) as avg_popularity,
  avg(cast(score as float)) as avg_score
FROM animeratings.dbo.anime_list
WHERE
  episode_length NOT LIKE '%sec%'
  AND rank != '/A'
  AND score != 'N/A'
GROUP BY 
	CASE
    WHEN episode_length LIKE '%hr%' THEN 'Greater than 1 hour long'
    WHEN episode_length NOT LIKE '%hr%' AND episode_length != 'Unknown' THEN 'Less than 1 hour long'
    ELSE 'Unknown length'
    END;



/* More anime have episode that are shorter than an hour (10,928) than longer (1,332). anime with shorter episodes
are more popular (7241 to 6196) but ranked are lower than the anime with longer episodes (4432 to 6412).
thr popularity may be due to amount of animes with shorter episodes.

Things that were found:
--Anime with average 30 episodes have more subscribers
--Top average genres were adventure, award winning, supernatural
--Spring tends to have the most anime releases (highest popularity), followed by Fall.
--Anime with shorter episodes are most popular, but anime with the longer episodes are ranked higher

--To increase your chances of creating a successful anime, the anime should aim to have the following
--Minimum of 30 episodes.
--Fall under adventure, award winning, or supernatural genres.
--Aim for a release in Spring.
--Longer episodes for higher ranking.
*/















