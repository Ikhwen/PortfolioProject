Select *
From Portfolio..[Covid deaths]
Where continent is not null
Order by 3,4

--Select * 
--From Portfolio..['Covid vaccination]
--Order by 3,4

Select Location,date, total_cases, new_cases,total_deaths, population
From Portfolio..[Covid deaths]
Where continent is not null
Order by 1,2

-- Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

Select Location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..[Covid deaths]
Where location like '%Malaysia%'
and continent is not null
Order by 1,2

-- Looking at total cases vs population
-- shows what perccentage of population got covid

Select Location, date, total_cases,population, (total_cases/population)*100 as PercentPopulationInfected 
From Portfolio..[Covid deaths]
Where location like '%Malaysia%'
and continent is not null
Order by 1,2

-- Looking a countries with highest infections rate compare to population

Select Location, population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as DeathPercentagePercentPopulationInfected 
From Portfolio..[Covid deaths]
--Where location like '%Malaysia%'
Where continent is not null
Group by Location, population
Order by DeathPercentagePercentPopulationInfected desc

-- Looking at countries with the highest dath count per population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..[Covid deaths]
--Where location like '%Malaysia%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Breakdown by continent
-- Showing the continent with the highest death per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..[Covid deaths]
--Where location like '%Malaysia%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int)) / SUM(cast(new_cases as int))*100 as DeathPercentage
From Portfolio..[Covid deaths]
--Where location like '%Malaysia%'
Where continent is not null
Order by 1,2 


-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationCummulative
--, (VaccinationCummulative/population)*100 -- Need to use CTE or Temp Table
From Portfolio..[Covid deaths] dea
Join Portfolio..[Covid vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



-- Use CTE

With PopvsVac (Continent, location, date, population, new_vaccination, VaccinationCummulative)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationCummulative
--, (VaccinationCummulative/population)*100 -- Need to use CTE or Temp Table
From Portfolio..[Covid deaths] dea
Join Portfolio..[Covid vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select * , (VaccinationCummulative/population)*100 
From PopvsVac



-- Temp Table

Drop Table if exists #PercentPopulationVaccinated -- good when doing alterations to a table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinationCummulative numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationCummulative
--, (VaccinationCummulative/population)*100 -- Need to use CTE or Temp Table
From Portfolio..[Covid deaths] dea
Join Portfolio..[Covid vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * , (VaccinationCummulative/population)*100 
From #PercentPopulationVaccinated



-- Creating view to store data for visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationCummulative
--, (VaccinationCummulative/population)*100 -- Need to use CTE or Temp Table
From Portfolio..[Covid deaths] dea
Join Portfolio..[Covid vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated