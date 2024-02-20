SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select Data that we are going to be using:

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths in México using the comand like and %% 

SELECT location, date, total_cases, total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%xico%' 
AND continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Filtered by country (México)

SELECT location, date, total_cases, population,(cast(total_cases as float)/cast(population as float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%xico%'
ORDER BY 1,2 


-- Looking at countries with Highest Infection Rate compared to Population.

SELECT location, population, MAX(total_cases) as HighestInfectionCount ,(MAX(cast(total_cases as float))/MAX(cast(population as float)))*100 as PercentPopulationInfecte
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
-- WHERE location like '%xico%'
GROUP BY location,population
ORDER BY 4 DESC

-- Showing Countries with the highest death count per population:

SELECT 
  location, max(cast(total_deaths AS float)) AS TotalDeathCount
FROM
  PortfolioProject..CovidDeaths$
-- WHERE location like '%xico%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Lest's break thing down by continents

SELECT 
  continent, max(cast(total_deaths AS float)) AS TotalDeathCount
FROM
  PortfolioProject..CovidDeaths$
-- WHERE location like '%xico%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Showing continents with the highest death count per population

SELECT 
  location, max(cast(total_deaths AS float)) AS TotalDeathCount
FROM
  PortfolioProject..CovidDeaths$
-- WHERE location like '%xico%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT sum(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths , SUM(nullif(cast(new_deaths as int),0))/SUM(nullif(new_cases,0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
-- WHERE location like '%xico%'
WHERE continent is not NULL

ORDER BY 1 


-- Looking at Total Population vs Vaccinations

SELECT 
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
--  (RollingPeopleVaccinated/population)*100

FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 1,2, 3


-- Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
     as (
         SELECT 
           dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--  (RollingPeopleVaccinated/population)*100
         FROM PortfolioProject..CovidDeaths$ dea
           JOIN PortfolioProject..CovidVaccinations$ vac
         ON dea.location = vac.location
           and dea.date = vac.date
         WHERE dea.continent is not NULL
		 )

SELECT 
  *, (RollingPeopleVaccinated/population)*100
FROM 
  PopvsVac


  -- Temp Table

  DROP TABLE IF exists #PercenPopulationVaccinated

  CREATE TABLE #PercenPopulationVaccinated
  (
  Continent varchar(225),
  Location varchar(225),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )

  INSERT INTO #PercenPopulationVaccinated
		 SELECT 
           dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--  (RollingPeopleVaccinated/population)*100
         FROM PortfolioProject..CovidDeaths$ dea
           JOIN PortfolioProject..CovidVaccinations$ vac
         ON dea.location = vac.location
           and dea.date = vac.date
         --WHERE dea.continent is not NULL
		 --ORDER BY 2,3
SELECT 
  *, (RollingPeopleVaccinated/population)*100
FROM 
  #PercenPopulationVaccinated


-- Creating View to store data for later visualization

CREATE VIEW PercenPopulationVaccinated  as

 SELECT 
    dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--  (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject..CovidDeaths$ dea
      JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
      and dea.date = vac.date
WHERE dea.continent is not NULL
-- ORDER BY 2,3

