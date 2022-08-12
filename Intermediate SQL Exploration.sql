-- Compute delta of new cases from previous day in the United States

SELECT
	new_cases - LAG(new_cases,1) OVER (PARTITION BY location ORDER BY date) AS new_cases_delta,
    new_cases,
    location,
    date
FROM covid_deaths
WHERE location = 'United States'
ORDER BY 4 DESC

--Compute smoothed rolling average for new cases in the United States

SELECT 
	AVG(new_cases) OVER (PARTITION BY location ORDER BY date ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) as cases_smoothed,
    new_cases,
    location,
    date
FROM covid_deaths
WHERE location = 'United States'

-- Fetch latest available data per country 

WITH latest_deaths_data as
	(SELECT location,
     		date,
     		new_deaths,
     		new_cases,
     		ROW_NUMBER() OVER (PARTITION BY location ORDER BY date DESC) as rn
     FROM covid_deaths)
SELECT
	location,
    date,
    new_deaths,
    new_cases,
    rn
FROM latest_deaths_data
WHERE rn=1
