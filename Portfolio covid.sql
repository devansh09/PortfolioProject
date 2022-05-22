select * 
from [PortfolioProject-Covid]..CovidDeaths
where continent is not null --Problem with data set: removing continents from the data as we are looking only at countries 
order by 3,4

select * 
from [PortfolioProject-Covid]..CovidVaccinations$
order by 3,4

--Looking at the complete data
select location, date, total_cases, new_cases, total_deaths, population
from [PortfolioProject-Covid]..CovidDeaths
where continent is not null
order by 1,2

--Looking at the death percentage in India(likely hood of dying if you contact covid)

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [PortfolioProject-Covid]..CovidDeaths
where location like '%India%' 
and continent is not null
order by 1,2

--Looking at what % of total population got covid

select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentageInfected
from [PortfolioProject-Covid]..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2

--looking at different countries with highest infection rate compare to population

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PopulationPercentageInfected
from [PortfolioProject-Covid]..CovidDeaths
where continent is not null
group by location, population
order by 4 Desc

--Different countries with total death count

select location, Max(cast(total_deaths as Int)) as TotalDeathCount
from [PortfolioProject-Covid]..CovidDeaths
where continent is not null
group by location, population
order by 2 Desc

--LET'S BREAK THE DATA BASED ON CONTINENTS

--continent with highest number of deaths

select continent, Max(cast(total_deaths as Int)) as TotalDeathCount
from [PortfolioProject-Covid]..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount Desc

select location, Max(cast(total_deaths as Int)) as TotalDeathCount
from [PortfolioProject-Covid]..CovidDeaths
where continent is null
group by location
order by TotalDeathCount Desc

--GLOBAL NUMBERS

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [PortfolioProject-Covid]..CovidDeaths
where continent is not null
group by date
order by 1,2

--Total global death percentage

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [PortfolioProject-Covid]..CovidDeaths 
where continent is not null
order by 1,2

--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [PortfolioProject-Covid]..CovidDeaths dea
join [PortfolioProject-Covid]..CovidVaccinations vac 
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE TEMP TABLE
drop table if exists #percentpopulationvacinated
create table #percentpopulationvacinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)	

insert into #percentpopulationvacinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [PortfolioProject-Covid]..CovidDeaths dea
join [PortfolioProject-Covid]..CovidVaccinations vac 
on dea.location=vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvacinated


--USE CTE

with popvsvac (continent, location, date, population, new_vaccination, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [PortfolioProject-Covid]..CovidDeaths dea
join [PortfolioProject-Covid]..CovidVaccinations vac 
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
)

select *, (rollingpeoplevaccinated/population)*100
from popvsvac 


--create view to store data for later visualisation

create view percentpopulationvacinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [PortfolioProject-Covid]..CovidDeaths dea
join [PortfolioProject-Covid]..CovidVaccinations vac 
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null

select * from percentpopulationvacinated

