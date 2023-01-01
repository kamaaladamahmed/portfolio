-- Comparing total numbers in the United States

SELECT 
	MAX(population) AS population,
	MAX(total_cases) AS total_cases,
  	MAX(total_deaths) AS total_deaths
FROM covid_deaths
WHERE location = 'United States' AND continent IS NOT NULL
    
-- Breaking down total cases, deaths, infection rate, and death rate by year

SELECT 
	EXTRACT(year FROM date) AS year,
	SUM(new_cases) AS cases,
	SUM(new_deaths) AS deaths,
    	ROUND(SUM(new_cases)/MAX(population)*100,3) AS infection_rate,
    	ROUND(SUM(new_deaths)/SUM(new_cases)*100,3) AS death_rate
FROM covid_deaths
WHERE location = 'United States' AND continent IS NOT NULL
GROUP BY year

-- Total vaccination rate in the United States

SELECT
	MAX(dea.population) AS population,
   	MAX(vacc.people_fully_vaccinated) AS total_fully_vaccinated,
   	ROUND(MAX(vacc.people_fully_vaccinated)/MAX(dea.population)*100,4) AS vaccination_rate
FROM covid_deaths dea
JOIN covid_vaccinations vacc
	ON dea.location = vacc.location
   	AND dea.date = vacc.date
WHERE dea.location = 'United States' AND dea.continent iS NOT NULL
    
-- Looking at vaccination rate over time in the United States

SELECT
	EXTRACT(year FROM dea.date) AS year,
   	EXTRACT(month FROM dea.date) AS month,
    	MAX(vacc.people_fully_vaccinated) AS total_fully_vaccinated,
    	ROUND(MAX(vacc.people_fully_vaccinated)/MAX(dea.population)*100,4) AS vaccination_rate
FROM covid_deaths dea
JOIN covid_vaccinations vacc
	ON dea.location = vacc.location
    	AND dea.date = vacc.date
WHERE dea.location = 'United States' AND dea.continent iS NOT NULL
GROUP BY year, month
ORDER BY year, month

-- Comparing infection rate, death rate, and vaccination rate every year in the United States

SELECT
	EXTRACT(year FROM dea.date) AS year,
    	ROUND(SUM(new_cases)/MAX(population)*100,3) AS infection_rate,
    	ROUND(SUM(new_deaths)/SUM(new_cases)*100,3) AS death_rate,
    	ROUND(MAX(vacc.people_fully_vaccinated)/MAX(dea.population)*100,4) AS vaccination_rate
FROM covid_deaths dea
JOIN covid_vaccinations vacc
	ON dea.location = vacc.location
    	AND dea.date = vacc.date
WHERE dea.location = 'United States' AND dea.continent iS NOT NULL
GROUP BY year
ORDER BY year

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

