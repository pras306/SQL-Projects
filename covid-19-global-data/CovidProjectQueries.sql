USE PortfolioProject
GO

--SELECT *
--FROM CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

/*

SELECT THE DATA THAT IS REQUIRED FOR THE PROJECT

*/

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

/*

GET DATA FOR TOTAL CASES v/s TOTAL DEATHS

*/

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/ total_cases) * 100, 2) AS death_percentage
FROM CovidDeaths
WHERE total_cases <> 0 
AND continent IS NOT NULL
--AND location IN ('India', 'canada', 'united states')
ORDER BY 1,2

/*

GET DATA FOR TOTAL CASES v/s POPULATION

*/

SELECT location, date, total_cases, population, ROUND((total_cases/ population) * 100, 2) AS infected_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%canada'
ORDER BY 1,2

/*

GET DATA FOR COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

*/

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases / population)) * 100 AS highest_infected_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_infected_percentage DESC

/*

GET DATA FOR COUNTRIES WITH HIGHEST DEATH COUNT

*/

SELECT location, MAX(total_deaths) AS highest_total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_total_deaths DESC

/*

GET DATA FOR CONTINENTS WITH TOTAL DEATH COUNTS

*/

SELECT location, MAX(total_deaths) AS highest_total_deaths
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY highest_total_deaths DESC


/*

GET DATA FOR GLOBAL NUMBERS BY DATE

*/

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths) / SUM(new_cases))*100 AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
AND new_cases <> 0
GROUP BY date
ORDER BY 1

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths) / SUM(new_cases))*100 AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
AND new_cases <> 0
ORDER BY 1

/*

VACCINATIONS

*/

SELECT *
FROM CovidVaccinations


/*

GET DATA FOR TOTAL POPULATION v/s TOTAL VACCINATIONS

*/


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

/*

GET DATA FOR NEW VACCINATIONS AS A ROLLING SUM

*/


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_rolling_sum
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


/*

GET DATA FOR PERCENTAGE OF TOTAL VACCINATIONS

*/

WITH PopulationvsVaccinations (continent, location, date, population, new_vaccinations, total_vaccinations_rolling_sum)
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_rolling_sum
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)

SELECT *, (total_vaccinations_rolling_sum / population) * 100 AS percentage_vaccinated
FROM PopulationvsVaccinations
ORDER BY 2,3

/*

CREATE VIEW TO STORE DATA FOR LATER VISUALIZATIONS

*/


CREATE VIEW PercentagePopulationVaccinated AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations_rolling_sum
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)



SELECT *
FROM PercentagePopulationVaccinated



