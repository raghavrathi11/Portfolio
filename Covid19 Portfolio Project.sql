/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From [portfolio project]..coviddeaths
Where continent is not null
Order by 3, 4

--Select *
--From [portfolio project]..covidvaccinations
--Order by 3, 4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From [portfolio project]..coviddeaths
Where continent is not null
Order by 1, 2


-- Total Cases vs Total deaths
-- Shows likelihood of dying if you contract COVID-19 in India

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [portfolio project]..coviddeaths
Where location = 'India' and continent is not null
Order by 1, 2


-- Total Cases vs Population
-- Shows what percentage of the Indian population has contracted COVID-19

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [portfolio project]..coviddeaths
Where location = 'India'
Order by 1, 2

-- Countries with Highest Infection Rate compared to Population

Select location, population, max(total_cases) as PeakInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From [portfolio project]..coviddeaths
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc

-- Countries with the Highest Death Count

Select location, max(cast (total_deaths as int)) as TotalDeathCount
From [portfolio project]..coviddeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Continents with Highest Death Count

Select continent, max(cast (total_deaths as int)) as TotalDeathCount
From [portfolio project]..coviddeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers

Select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [portfolio project]..coviddeaths
where continent is not null
-- Group by date
order by 1,2

--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
From [portfolio project]..coviddeaths dea
Join [portfolio project]..covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE to find Percentage of Population Vaccinated

With Pop_Vs_Vac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
From [portfolio project]..coviddeaths dea
Join [portfolio project]..covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)
Select*, (RollingPeopleVaccinated/Population)*100
from Pop_Vs_Vac


-- Creating Views to store data in for later visualizations

Create View TotalPopulationvsVaccination as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
From [portfolio project]..coviddeaths dea
Join [portfolio project]..covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Create View CountrieswithHighestDeathCount as
Select location, max(cast (total_deaths as int)) as TotalDeathCount
From [portfolio project]..coviddeaths
Where continent is not null
Group by location

-- Using View to to find Percentage of Population Vaccinated

Select *, (RollingPeopleVaccinated/population)*100
from TotalPopulationvsVaccination
