select *
from [portfolio project 1]..Coviddeaths
where continent is not null
order by 3,4

select *
from [portfolio project 1]..CovidVaccinations
where continent is not null
order by 3,4

--Data selection
select location, date, total_cases, new_cases, total_deaths, population
from [portfolio project 1]..CovidDeaths
where continent is not null
order by 1,2
 
--Total cases vs Total deaths

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [portfolio project 1]..CovidDeaths
where location ='Botswana'
order by 1,2

--Total cases vs Population

select location, date, total_cases, population, (total_cases/population)*100 as percentagepopulationinfected
from [portfolio project 1]..CovidDeaths
--where location ='states'
where continent is not null
order by 1,2

-- Countries with highest infection rate compared to population 

select location, population, MAX(total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 as PercentagePopulaionInfected
from [portfolio project 1]..CovidDeaths
--where location ='states'
where continent is not null
Group by Location, population
order by PercentagePopulaionInfected desc

--Countries with highest DeathCount

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [portfolio project 1]..CovidDeaths
--where location ='states'
where continent is not null
Group by location
order by TotalDeathCount desc

--Continet with Highest Death count per population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [portfolio project 1]..CovidDeaths
--where location ='states'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers

select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [portfolio project 1]..CovidDeaths
--where location = %states%
where continent is not null
Group by date
order by 1,2

--JOIN
Select *
From [portfolio project 1]..CovidDeaths dea
join [portfolio project 1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Looking at Total Populatin vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [portfolio project 1]..CovidDeaths dea
join [portfolio project 1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Rolling Count
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated,
from [portfolio project 1]..CovidDeaths dea
join [portfolio project 1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVacinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From [portfolio project 1]..CovidDeaths dea
join [portfolio project 1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVacinated/Population)*100
From PopvsVac

--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From [portfolio project 1]..CovidDeaths dea
join [portfolio project 1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVacinated/Population)*100
From #PercentPopulationVaccinated


-- creating VIEW to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From [portfolio project 1]..CovidDeaths dea
join [portfolio project 1]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated 