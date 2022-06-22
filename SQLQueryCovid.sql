Select*
From Portfolioproject..CovidDeaths$
Where continent is not null
Order by 3,4

Select*
From Portfolioproject..CovidVaccination$
Order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population
From CovidDeaths$
Order by 1,2

--Total Cases vs total deaths 
--The chance of dying if you contract covid in your country 

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where location like '%togo%' and continent is not null
Order by 1,2

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where location like '%ghana%'
Order by 1,2

Select continent,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where continent is not null
Order by 1,2

-- Total cases vs percentage
--Shows what percentage of population got covid 

Select location,date,population,(total_cases/population)*100 as InfectionRate
From CovidDeaths$
Where location like '%states%'
Order by 1,2

-- Looking at the country with highet infection rate compared to population

Select continent,population, MAX(total_cases) as HighestInfecttion, MAX((total_cases/population))*100 as InfectionRate
From CovidDeaths$
Where continent is not null
Group by continent,population
Order by InfectionRate desc

-- Showing countries with Highest Death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Death count by continent 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is null
Group by location
Order by TotalDeathCount desc


Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Group by location
Order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--GLobal Numbers

/* per day */
Select date, SUM(new_cases)as totalCases, SUM(Cast(new_deaths as int))as totalDeaths,SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From CovidDeaths$
Where continent is not null
Group by date
Order by 1,2 

/*overall*/ 
Select SUM(new_cases)as totalCases, SUM(Cast(new_deaths as int))as totalDeaths,SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From CovidDeaths$
Where continent is not null
Order by 1,2 

-- join vaccination table and death table 

Select*
From CovidDeaths$ dea
Join CovidVaccination$ vac
On   dea.location = vac.location 
and  dea.date = vac.date

-- Total population vs total vaccination

/* per day */
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
From CovidDeaths$ dea
Join CovidVaccination$ vac
On   dea.location = vac.location 
and  dea.date = vac.date
Where dea.continent is not null
Order by 1,2

/* new vaccination with rolling count */

Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
Sum (Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccinated
--(RollingCountOfVaccinated/ population)*100
From CovidVaccination$ vac join CovidDeaths$ dea
  on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Creation of CTE to use the new column RollingCountOfVaccinated

With popvsvac (continent, location, date, population,new_vaccinations, RollingCountOfVaccinated) 
as
(
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
Sum (Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccinated
 --,(RollingCountOfVaccinated/ population)*100
From CovidVaccination$ vac join CovidDeaths$ dea
 on dea.location = vac.location 
 and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingCountOfVaccinated/ population)*100
From popvsvac


-- TEMP TABLE

DROP TABLE if exists #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated 
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingCountOfVaccinated numeric
)
Insert into #PercentpopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
Sum (Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccinated
 --,(RollingCountOfVaccinated/ population)*100
From CovidVaccination$ vac join CovidDeaths$ dea
 on dea.location = vac.location 
 and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingCountOfVaccinated/ population)*100
From #PercentpopulationVaccinated

-- Creating view to store data for later visualizations

CREATE VIEW PercentpopulationVaccinated as 
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
Sum (Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccinated
From CovidVaccination$ vac join CovidDeaths$ dea
 on dea.location = vac.location 
 and dea.date = vac.date
Where dea.continent is not null

Select *
From #PercentpopulationVaccinated


CREATE VIEW CovidDeathChance as 
Select continent,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where continent is not null

CREATE VIEW PeopleInfectedByCovid as 
Select location,date,population,(total_cases/population)*100 as InfectionRate
From CovidDeaths$
Where continent is not null

CREATE VIEW highInfectionRate as 
Select continent,population, MAX(total_cases) as HighestInfecttion, MAX((total_cases/population))*100 as InfectionRate
From CovidDeaths$
Where continent is not null
Group by continent,population

CREATE VIEW highestDeathCount as 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is not null
Group by continent
