SELECT * 
FROM `Portfolio Project`.coviddeaths
WHERE continent is not null
ORDER BY 3,4;

/*
SELECT *
FROM `Portfolio Project`.covidvaccinations
ORDER BY 3,4;
*/

-- Select Data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM `Portfolio Project`.coviddeaths
WHERE continent is not null
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS DeathPercentage
FROM `Portfolio Project`.coviddeaths
WHERE location like '%states%'
AND continent is not null
ORDER BY 1,2;


-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, Population, (total_cases/Population) *100 AS PercentPopulationInfected
FROM `Portfolio Project`.coviddeaths
WHERE location like '%states%'
ORDER BY 1,2;


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) *100 AS PercentPopulationInfected
FROM `Portfolio Project`.coviddeaths
GROUP BY Location,population
ORDER BY PercentPopulationInfected DESC;


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths AS SIGNED)) AS TotalDeathCount
FROM `Portfolio Project`.coviddeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- Let's break things down by continent 


-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths AS SIGNED)) AS TotalDeathCount
FROM `Portfolio Project`.coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global numbers


SELECT  SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS SIGNED)) AS total_deaths, 
SUM(cast(New_deaths AS SIGNED))/SUM(new_cases)*100 AS DeathPercentage
FROM `Portfolio Project`.coviddeaths
-- WHERE location like '%states%'
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2;

-- Looking at Total Population vs vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM `Portfolio Project`.coviddeaths dea
JOIN `Portfolio Project`.covidvaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;


-- USE CTE 


WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM `Portfolio Project`.coviddeaths dea
JOIN `Portfolio Project`.covidvaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;


-- Temp Table

DROP TABLE IF exists PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
	Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population DECIMAL(18, 0),
    New_vaccinations DECIMAL(18, 0),
    RollingPeopleVaccinated DECIMAL(18, 0)
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM `Portfolio Project`.coviddeaths dea
JOIN `Portfolio Project`.covidvaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null;
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated;


-- Creating View to store

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM `Portfolio Project`.coviddeaths dea
JOIN `Portfolio Project`.covidvaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null;
-- ORDER BY 2,3


SELECT * 
FROM PercentPopulationVaccinated