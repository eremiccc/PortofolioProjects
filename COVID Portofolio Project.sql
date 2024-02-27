select * from PortfolioProject..CovidDeaths$
order by 3,4

--select * from PortfolioProject..CovidVaccinations$
--order by 3,4


-- select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

-- Looking total cases vs total deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths$
Where Location like '%states%'
and continent is not null
order by 1,2

-- Looking total cases vs population
-- shows percentage of population got covid

select Location, Date, Population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected 
from PortfolioProject..CovidDeaths$
Where Location like '%states%'
order by 1,2

-- looking countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths$
--Where Location like '%states%'
Group By location, population
Order By PercentPopulationInfected desc

-- showing countries with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where Location like '%states%'
Where continent is not null
Group By Location
Order By TotalDeathCount desc

-- Lets break things down by continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where Location like '%states%'
Where continent is not null
Group By continent
Order By TotalDeathCount desc


-- Showing continents with HighestDeathCount per Population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where Location like '%states%'
Where continent is not null
Group By continent
Order By TotalDeathCount desc


-- Global Numbers

select SUM(new_cases)as total_cases,SUM(CAST(new_deaths as int))as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--Where Location like '%states%'
Where continent is not null
--Group By date
order by 1,2


--total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER(partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER(partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac


-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER(partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated


-- Creating View Store data for Visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER(partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


select * from PercentPopulationVaccinated