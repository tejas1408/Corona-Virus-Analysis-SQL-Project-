select *
From Coronaanalysis..['covidDeaths']
where continent is not null
order by 3,4

--select *
--From Coronaanalysis..['covidVaccinations']
--order by 3,4

--select Daa that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
From Coronaanalysis..['covidDeaths']
where continent is not null
order by 1,2

--looking at total cases vs deaths
---shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, ( total_deaths/total_cases)*100 as DeathPercentage
From Coronaanalysis..['covidDeaths']
where location like '%India%'
and continent is not null
order by 1,2


--Looking at total cases vs population
---shows the percentage population got covid
select location, date,  population, total_cases, ( total_cases/population)*100 as DeathPercentage
From Coronaanalysis..['covidDeaths']
where location like '%India%'
order by 1,2

--Looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, ( MAX(total_cases)/population)*100 as PercentagePopulationInfected
From Coronaanalysis..['covidDeaths']
--where location like '%India%'
Group by location, population
order by PercentagePopulationInfected desc


--Showing countries with highest Death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Coronaanalysis..['covidDeaths']
--where location like '%India%'
where continent is null
Group by location
order by TotalDeathCount desc

--showing the continents with the highest deathcounts
--Lets break things down by continent
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Coronaanalysis..['covidDeaths']
--where location like '%India%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global Nmbers
select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeathes, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--, total_deaths, ( total_deaths/total_cases)*100 as DeathPercentage
From Coronaanalysis..['covidDeaths']
--where location like '%India%'
where continent is not null
Group By date
order by 1,2

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeathes, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--, total_deaths, ( total_deaths/total_cases)*100 as DeathPercentage
From Coronaanalysis..['covidDeaths']
--where location like '%India%'
where continent is not null
--Group By date
order by 1,2


--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Coronaanalysis..['covidDeaths'] dea
Join Coronaanalysis..['covidVaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Coronaanalysis..['covidDeaths'] dea
Join Coronaanalysis..['covidVaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

--DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Coronaanalysis..['covidDeaths'] dea
Join Coronaanalysis..['covidVaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated


--creating viev to store data for later visualizations

Create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Coronaanalysis..['covidDeaths'] dea
Join Coronaanalysis..['covidVaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
From PercentagePopulationVaccinated