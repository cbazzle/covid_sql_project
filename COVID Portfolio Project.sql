Select *
From CovidDeaths
Where continent is not null
Order by 3, 4

Select * 
From CovidVaccinations 
Order by 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in the United States
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
-- Where location like '%states%'
Order by 1, 2

-- Looking at Total Cases vs Population
-- Shows percentage of population that contracted COVID
Select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
From CovidDeaths
-- Where location like '%states%'
Order by 1, 2

-- Looking at Countries with Highest Infection Rate Compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as 
	PercentPopulationInfected
From CovidDeaths
-- Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc

-- Breakdown by Continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
-- Where location like '%states%'
Where continent is null
Group by location
Order by TotalDeathCount desc

-- Showing Countries with Highest Death Count per Population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- For above, switch out location for continent, or country for continent, etc. to drill down

-- Global Numbers
Select SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
-- Where location like '%states%'
Where continent is not null
-- Group by date
Order by 1, 2


-- Looking at Total Population vs Vaccinations
-- Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated FROM PopvsVac

-- Use Temp Table
DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100
From PercentPopulationVaccinated

-- Create View to store data for visualizations(GO BACK AND CREATE MORE VIEWS)
Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

-- Select all from view
Select *
From 

-- TABLEAU QUERIES
-- 1. Global Numbers
Select SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
-- Where location like '%states%'
Where continent is not null
-- Group by date
Order by 1, 2

-- 2. 
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3.
-- Looking at Countries with Highest Infection Rate Compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as 
	PercentPopulationInfected
From CovidDeaths
-- Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc

-- 4. 
Select location, population, date, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as 
	PercentPopulationInfected
From CovidDeaths
-- Where location like '%states%'
Group by location, population, date
Order by PercentPopulationInfected desc