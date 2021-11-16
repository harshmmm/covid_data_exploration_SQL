
---------------------------------------------COVID19 DATA EXPLORATION---------------------------------------------

--(1)Selecting Table to work with
SELECT *
FROM portfolio_project..covid_deaths
WHERE continent is not null


--(2)Infection Rate over population for each country--
SELECT 
	location, MAX((total_cases/population))*100 AS infected_percent
FROM portfolio_project..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY infected_percent DESC


--(3)Death Rate over population for each country--
SELECT
	location, MAX((total_deaths/population))*100 AS death_percent
FROM portfolio_project..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY death_percent DESC


--(4)Deaths per Infected for each country--
SELECT
	location, MAX((CAST(total_deaths AS int)/total_cases))*100 AS deaths_per_infected
FROM portfolio_project..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY deaths_per_infected DESC

--(5) As per continents
SELECT
	continent, MAX(CAST(total_deaths AS int)) AS death_count
FROM portfolio_project..covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY death_count DESC


--(6) New Cases by Date
SELECT
	date,SUM(new_cases) AS new_cases_on_given_date, SUM(CAST(new_deaths AS int)) AS new_deaths_on_given_date, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percent_on_given_date
FROM portfolio_project..covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY date DESC
  

--(7) Total Population vs Total Vaccinations
SELECT
	dea.continent, dea.location, dea.date, population, vaxx.new_vaccinations, SUM(CONVERT(float, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) AS total_vaccinations_till_date
FROM portfolio_project..covid_deaths AS dea
JOIN portfolio_project..covid_vaccinations AS vaxx
ON
	dea.location = vaxx.location
	AND
	dea.date = vaxx.date
WHERE dea.continent is not null
ORDER BY dea.continent, dea.location

--USING CTE

WITH pops_vs_vaxx (continent, location, date, population, new_vaccinations, total_vaccinations_till_date)
AS
(
SELECT
	dea.continent, dea.location, dea.date, population, vaxx.new_vaccinations, SUM(CONVERT(float, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) AS total_vaccinations_till_date
FROM portfolio_project..covid_deaths AS dea
JOIN portfolio_project..covid_vaccinations AS vaxx
ON
	dea.location = vaxx.location
	AND
	dea.date = vaxx.date
WHERE dea.continent is not null

)
SELECT * , (total_vaccinations_till_date/population)*100 AS percent_vaccinated_till_date
FROM pops_vs_vaxx


--(8) Create View for later Vizzes
CREATE VIEW view_pops_vs_vaxx AS
SELECT
	dea.continent, dea.location, dea.date, population, vaxx.new_vaccinations, SUM(CONVERT(float, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) AS total_vaccinations_till_date
FROM portfolio_project..covid_deaths AS dea
JOIN portfolio_project..covid_vaccinations AS vaxx
ON
	dea.location = vaxx.location
	AND
	dea.date = vaxx.date
WHERE dea.continent is not null


SELECT *
FROM view_pops_vs_vaxx