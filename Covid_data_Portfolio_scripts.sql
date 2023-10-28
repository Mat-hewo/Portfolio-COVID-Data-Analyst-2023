SELECT *
From Covid_project_PORTFOLIO..CovidDeaths
WHERE continent is not null
order by 3, 4


SELECT *
From Covid_project_PORTFOLIO..CovidVactinations
WHERE continent is not null
ORDER BY 3,4


--Created View:
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_project_PORTFOLIO..CovidDeaths
WHERE continent is not null
ORDER BY location, date


-- Country COVID-19 data: Total cases, new cases, total deaths, and percentage of deaths.
-- Created View: PolandPercentageOfDeaths
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS Percentage_of_Deaths
FROM Covid_project_PORTFOLIO..CovidDeaths
WHERE location = 'Poland'
ORDER BY date


--Country COVID-19 infection statistics: Highest infection count and population percentage.
--Created View: PercentageOfInfection_byLocation
SELECT location, population, MAX(total_cases) AS  HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Covid_project_PORTFOLIO..CovidDeaths
WHERE continent is not null
GROUP BY location, population
order by PercentPopulationInfected DESC


-- Country COVID-19 death statistics: Highest total death count.
--Created View: TotalDeathCount_byLocation
SELECT location, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM Covid_project_PORTFOLIO..CovidDeaths
WHERE continent is not null
GROUP BY location
order by TotalDeathCount DESC


--Daily COVID-19 statistics: New cases, new deaths, and death percentage
--Created View: PercentageOfDeaths_byDate
SELECT date, SUM(new_cases) AS new_cases, SUM(cast(new_deaths as float)) AS new_deaths, 
SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 AS DeathPercentage
FROM Covid_project_PORTFOLIO..CovidDeaths
WHERE continent is not null 
and cast(new_deaths as float) > 0 
and cast(new_cases as float) > 0
GROUP BY date
ORDER BY 1, 2


--Total COVID-19 deaths statistics: total_cases, total_deaths, DeathPercentage
--Created View: PercentageOfDeaths_WORLD
SELECT
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS FLOAT)) AS total_deaths,
    CASE
        WHEN SUM(CAST(new_cases as float)) = 0 or SUM(CAST(new_deaths as float)) = 0 THEN 0
		ELSE SUM(CAST(new_deaths as float)) / SUM(CAST(new_cases as float)) *100
    END AS DeathPercentage
FROM Covid_project_PORTFOLIO..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


--Temporary table of Vacinated population
Create Table #PercentOfPopulationVacinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vacinated_population numeric)

INSERT INTO #PercentOfPopulationVacinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacinations.new_vaccinations
, SUM(CONVERT(float, vacinations.new_vaccinations)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) 
AS vacinated_population
FROM Covid_project_PORTFOLIO..CovidDeaths AS deaths
Join Covid_project_PORTFOLIO..CovidVactinations AS vacinations
	ON deaths.location = vacinations.location
	and deaths.date = vacinations.date
WHERE deaths.continent is not null

Select *
FROM #PercentOfPopulationVacinated


--Vacinated COVID-19 Statistics: deaths.continent, deaths.location, deaths.date, deaths.population, vacinations.new_vaccinations, vacinated_population
--Created View:PercentageOfVaccinated_byLocation
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacinations.new_vaccinations
, SUM(CONVERT(float, vacinations.new_vaccinations)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) 
AS vacinated_population
FROM Covid_project_PORTFOLIO..CovidDeaths AS deaths
Join Covid_project_PORTFOLIO..CovidVactinations AS vacinations
	ON deaths.location = vacinations.location
	and deaths.date = vacinations.date
WHERE deaths.continent is not null
order by 2, 3

