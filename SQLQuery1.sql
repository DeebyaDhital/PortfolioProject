select * from PortProject..CovidDeaths$
order by 3,4

--select * from PortProject..CovidDeaths$
--order by 3,4

--Select data that we are going to be using
select location,date,total_cases,new_cases,total_deaths,population
from PortProject..CovidDeaths$
Order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortProject..CovidDeaths$
--where location like'%states%'
Order by 1,2

--Looking at total cases vs population
select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortProject..CovidDeaths$
where location like'%states%'
Order by 1,2

--Looking at countries with highest infection rate compared to population
select location,population,MAX(total_cases) as HighestInfectioncount,MAX((total_cases/population))*100 as PercentPopulationInfected
from PortProject..CovidDeaths$
--where location like'%states%'
Group by location,population
Order by PercentPopulationInfected desc

--Looking at countries with highest death count
select location,MAX(cast(total_deaths as int)) as TotalDeathcount
from PortProject..CovidDeaths$
--where location like'%states%'
where continent is null
Group by location
Order by TotalDeathcount desc

--Showing continents with highest death count per population
select continent,MAX(cast(total_deaths as int)) as TotalDeathcount
from PortProject..CovidDeaths$
--where location like'%states%'
--where continent is not null
Group by continent
Order by TotalDeathcount desc

--GLobalNUmbers
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortProject..CovidDeaths$
--where location like'%states%'
where continent is not null
--group by date
Order by 1,2

select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated 
from PortProject..CovidDeaths$ dea
join PortProject..CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
Order by 2,3

With PopvsVac(Continent,location,date,population,New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated 
from PortProject..CovidDeaths$ dea
join PortProject..CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--Order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100 
from PopvsVac

--Temp Table
Drop Table if exists  #PercentPopulationVaccinated 
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated 
from PortProject..CovidDeaths$ dea
join PortProject..CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--Order by 2,3

select *,(RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated

--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated 
from PortProject..CovidDeaths$ dea
join PortProject..CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--Order by 2,3







