SELECT *
FROM [COVID 19 PROJECT]..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM [COVID 19 PROJECT]..CovidVaccinations$
--ORDER BY 3,4

--Select data that we are going to be using in our project

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [COVID 19 PROJECT]..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying people that contracted covid in your country
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [COVID 19 PROJECT]..CovidDeaths$
WHERE location like '%albania%'
AND continent is not null
ORDER BY 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date,population, new_cases, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM [COVID 19 PROJECT]..CovidDeaths$
--WHERE location like '%albania%'
WHERE continent is not null
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [COVID 19 PROJECT]..CovidDeaths$
--WHERE location like '%albania%'
WHERE continent is not null
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM [COVID 19 PROJECT]..CovidDeaths$
--WHERE location like '%albania%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Breaking things down by Continent
-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM [COVID 19 PROJECT]..CovidDeaths$
--WHERE location like '%albania%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

 
 -- Global Numbers
 -- Total Death Percentage
SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [COVID 19 PROJECT]..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Total Death Percentage by Date

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, ROUND(SUM(CAST(new_deaths AS int))/SUM(new_cases)*100,2) AS DeathPercentage
FROM [COVID 19 PROJECT]..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
-- What is Total Population in the World getting Vaccinated? 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER by dea.location,
dea.Date) AS RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
FROM [COVID 19 PROJECT]..CovidVaccinations$ vac
JOIN [COVID 19 PROJECT]..CovidDeaths$ dea
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	ORDER BY 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER by dea.location,
dea.Date) AS RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
FROM [COVID 19 PROJECT]..CovidVaccinations$ vac
JOIN [COVID 19 PROJECT]..CovidDeaths$ dea
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER by dea.location,
dea.Date) AS RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
FROM [COVID 19 PROJECT]..CovidVaccinations$ vac
JOIN [COVID 19 PROJECT]..CovidDeaths$ dea
	ON dea.location = vac.location
	and dea.date = vac.date
	--WHERE dea.continent is not null
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Crreating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER by dea.location,
dea.Date) AS RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
FROM [COVID 19 PROJECT]..CovidVaccinations$ vac
JOIN [COVID 19 PROJECT]..CovidDeaths$ dea
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated