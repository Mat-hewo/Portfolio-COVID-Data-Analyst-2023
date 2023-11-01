--DASHBOARD 2--
--https://public.tableau.com/app/profile/mateusz.adamowicz/viz/COVID-19EUROPEStatisticsforOctober2023Dashboard/Dashboard1--

-- Total cases and Total deaths PLOT#1
-- Created View: COVID19_DeathsAndCases
-- Worksheet in Tableau: COVID19_DeathsAndCases	CUSTOM LINES
SELECT
    location, date,
    SUM(CAST(new_cases as float)) OVER (PARTITION BY location ORDER BY date) AS total_cases,
    SUM(CAST(new_deaths as float)) OVER (PARTITION BY location ORDER BY date) AS total_deaths
FROM Covid_project_PORTFOLIO..CovidDeaths
WHERE continent = 'Europe';
-------------------------------------------------------------------------------------------------------------

--Europe Population
WITH t1 AS (
    SELECT location, MAX(CAST(population as float)) AS max_pop_by_country
    FROM Covid_project_PORTFOLIO..CovidDeaths
	WHERE continent = 'Europe' and continent is not NULL
    GROUP BY location

),
t2 AS (
    SELECT SUM(CAST(max_pop_by_country as float)) as europe_population
    FROM t1
)
SELECT europe_population FROM t2
-------------------------------------------------------------------------------------------------------------

-- Map with Infection stats in Europe
-- Created View: COVID19_Infection_map_EU
-- Worksheet in Tableau: COVID19_Infection_map	MAP
SELECT location, population, MAX(total_cases) AS  HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Covid_project_PORTFOLIO..CovidDeaths
WHERE continent = 'Europe'
GROUP BY location, population
-------------------------------------------------------------------------------------------------------------

-- Created View: COVID19_Total_statistics_EU
-- Worksheet in Tableau: COVID19_Total_statistics_EU	HORIZONTAL BARS
SELECT 
	SUM(CONVERT(float, new_cases)) AS Total_case,
	SUM(CONVERT(float, new_people_vaccinated_smoothed)) AS total_vacinated,
	SUM(CONVERT(float, new_deaths)) AS Total_deaths,
	SUM(CONVERT(float, new_deaths)) / SUM(CONVERT(float, new_cases))*100 AS Percentage_of_death
FROM Covid_project_PORTFOLIO..CovidDeaths dea
JOIN Covid_project_PORTFOLIO..CovidVactinations vac
	ON (dea.location = vac.location 
	and dea.date = vac.date)
WHERE dea.continent = 'Europe'
GROUP BY dea.continent
-------------------------------------------------------------------------------------------------------------

-- Total_cases, vacinated people, patients in hospital due to Covid informations
-- Created View: COVID19_VAC_AND_HOSP
-- Worksheet in Tableau: COVID19_VAC_AND_HOSP	LINES
SELECT 
    dea.date,
	SUM(CONVERT(float, new_cases)) OVER (ORDER BY dea.date) AS Total_cases,
    SUM(CONVERT(float, new_people_vaccinated_smoothed)) OVER (ORDER BY dea.date) AS Vacinated_patients,
	SUM(CONVERT(float, hosp_patients)) OVER (ORDER BY dea.date) AS Patients_in_hospital_due_to_COVID
FROM Covid_project_PORTFOLIO..CovidDeaths dea
JOIN Covid_project_PORTFOLIO..CovidVactinations vac
    ON (dea.location = vac.location 
    and dea.date = vac.date)
WHERE dea.continent = 'Europe';
-------------------------------------------------------------------------------------------------------------

-- Total Deaths by Location in Europe
--Created View: Total_Deaths_byLocation
SELECT location, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM Covid_project_PORTFOLIO..CovidDeaths
WHERE continent = 'Europe'
GROUP BY location
-------------------------------------------------------------------------------------------------------------
