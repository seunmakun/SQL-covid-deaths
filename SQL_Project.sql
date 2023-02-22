select *
from PortfolioProjects..coviddeaths$


--select *
--from PortfolioProjects..covidvaccinations$


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..coviddeaths$
order by 1,2

--looking at total cases vs total deaths

-- shows likelihood of dying if one contracts covid
select location, date, total_cases, total_deaths, round((total_deaths/total_cases*100),2)as DeathPercentage
from PortfolioProjects..coviddeaths$
where location like '%states%'

--total cases vs population

select location, date, total_cases, population,  round((total_cases/population*100),2)as CasePopPercentage
from PortfolioProjects..coviddeaths$
where round((total_cases/population*100),2) > 20
order by 1,2
--where location like '%states%'

--Country with highest infection rate

select location, sum(total_cases) as Sumtotalcase 
from PortfolioProjects..coviddeaths$
group by location
order by sum(total_cases) desc

-- Country with highest infection rate vs population

select location, MAX(total_cases) as Highest_infection_count, population, ROUND(MAX((total_cases/population*100)),2)as percent_population_infected
from PortfolioProjects..coviddeaths$
group by location, population
order by percent_population_infected desc


-- Country with highest death count per population


select location, MAX(cast(total_deaths as int)) as Highest_death_count
from PortfolioProjects..coviddeaths$
where continent is NOT NULL
group by location
order by Highest_death_count desc

--BY Continent

select continent, MAX(cast(total_deaths as int)) as Highest_death_count
from PortfolioProjects..coviddeaths$
where continent is NOT NULL
group by continent
order by Highest_death_count desc



-- create a view to store data for visualization







-- Global Numbers

select date, total_cases, total_deaths, round((total_deaths/total_cases*100),2)as DeathPercentage
from PortfolioProjects..coviddeaths$
where continent is not null

select sum(new_cases) as total_cases, sum(cast(new_deaths as int))as total_deaths, round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as DeathPercentage
from PortfolioProjects..coviddeaths$
where continent is not null


--Join tables for coviddeaths and covidvaccinations
-- total population vs vaccinations


-- CTES
With PopvsVac (continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)as Rolling_people_vaccinated
from PortfolioProjects..coviddeaths$ dea
Join PortfolioProjects..covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, round((Rolling_people_vaccinated/population )*100,2) as percent_vac_pop
from PopvsVac


-- use TEMP TABLES

DROP Table if exists ppv
create Table ppv
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric
)

Insert into ppv

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)as Rolling_people_vaccinated
from PortfolioProjects..coviddeaths$ dea
Join PortfolioProjects..covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (Rolling_people_vaccinated/population *100)as roll_pop
from ppv


-- CTE 2

With p_vac (continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)as Rolling_people_vaccinated
from PortfolioProjects..coviddeaths$ dea
Join PortfolioProjects..covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, round((Rolling_people_vaccinated/population )*100,2) as percent_vac_pop
from p_vac


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)as Rolling_people_vaccinated
from PortfolioProjects..coviddeaths$ dea
Join PortfolioProjects..covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



Create View p_vac as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)as Rolling_people_vaccinated
from PortfolioProjects..coviddeaths$ dea
Join PortfolioProjects..covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null




-- Tableau data


--1
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as death_percentage
from PortfolioProjects..coviddeaths$
where continent is NOT NULL

--2
select location, sum(cast(new_deaths as int)) as total_death_count
from PortfolioProjects..coviddeaths$
where continent is NULL
and location not in ('low income', 'upper middle income', 'high income', 'European Union', 'Lower middle income', 'World', 'International')
group by location
order by total_death_count desc

--3
select location, population, max(total_cases) as highest_infection_count, round(max((total_cases/population)*100),2) as percent_population_infected
from PortfolioProjects..coviddeaths$
group by location, population
order by percent_population_infected desc


--4
select location, population, date, max(total_cases) as highest_infection_count, round(max((total_cases/population))*100,2) as percent_population_infected
from PortfolioProjects..coviddeaths$
group by location, population, date
order by percent_population_infected desc