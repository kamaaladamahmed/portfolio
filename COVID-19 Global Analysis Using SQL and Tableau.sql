Tableau Dashboard: https://public.tableau.com/views/COVID-19GlobalDashboard_16709826154170/Dashboard

-- Global Numbers as of June 30th, 2022

SELECT 
SUM(new_cases) AS total_cases, 
SUM(new_deaths) AS total_deaths, 
SUM(new_deaths)/SUM(new_cases) AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL AND date < '07-01-2022'

-- Monthly Global Cases

SELECT
EXTRACT(year FROM date) AS year,
EXTRACT(month FROM date) AS month,
SUM(new_cases) as new_cases
FROM covid_deaths
WHERE continent IS NOT NULL AND date < '07-01-2022'
GROUP BY year, month
ORDER BY year, month

-- Monthly Global Deaths

SELECT
EXTRACT(year FROM date) AS year,
EXTRACT(month FROM date) AS month,
SUM(new_deaths) as new_deaths
FROM covid_deaths
WHERE continent IS NOT NULL AND date < '07-01-2022'
GROUP BY year, month
ORDER BY year, month

-- Monthly Global Death Rate

SELECT
EXTRACT(year FROM date) AS year,
EXTRACT(month FROM date) AS month,
SUM(new_deaths)/SUM(new_cases)*100 as death_rate
FROM covid_deaths
WHERE continent IS NOT NULL AND date < '07-01-2022'
GROUP BY year, month
ORDER BY year, month

-- Global Numbers Broken Down by Country

SELECT location,
SUM(new_cases) AS total_cases, 
SUM(new_deaths) AS total_deaths, 
SUM(new_cases)/MAX(population) AS infection_rate,
SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL AND new_cases IS NOT NULL AND date < '07-01-2022'
GROUP BY location
ORDER BY total_cases DESC

-- United States

SELECT 
EXTRACT(year FROM date) AS year,
EXTRACT(month FROM date) AS month,
SUM(new_cases) AS new_cases,
SUM(new_deaths) AS new_deaths
FROM covid_deaths
WHERE continent IS NOT NULL AND location = 'United States' AND date < '07-01-2022'
GROUP BY year, month
ORDER BY 1,2
                     
                     