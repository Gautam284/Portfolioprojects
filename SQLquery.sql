Select *
From Porfolioproject..CovidDeaths
order by 3,4

--Select *
--From Porfolioproject..CovidVaccinations
--order by 3,4

select Location,date,total_cases,new_cases,total_deaths,population
from Porfolioproject..CovidDeaths
order by 1,2

--Looking at total cases vs tataol deaths

select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from Porfolioproject..CovidDeaths
order by 1,2

select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from Porfolioproject..CovidDeaths
where location like '%states%'
order by 1,2

--looking as total cases vs popolation
--shows what percentage of population got covid in unitedstates
select Location,date,total_cases,population, (total_deaths/population)*100 as percentpopulationinfected
from Porfolioproject..CovidDeaths
where location like '%states%'
order by 1,2


--shows what percentage of population got covid
select Location,date,total_cases,population, (total_deaths/population)*100 as percentpopulationinfected
from Porfolioproject..CovidDeaths
order by 1,2

--looking  at countries with highest infection rate compared to population

select Location,population,max(total_cases) as Highestinfectedcount, max((total_deaths/population))*100 as percentpopulationinfected
from Porfolioproject..CovidDeaths
Group by location,population
order by percentpopulationinfected  desc

--showing countries with Highest death counts per population

select Location,max(total_cases) as TotalDeathcounts
from Porfolioproject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathcounts  desc

-- breaking things by continent with highest death counts per population

select continent,max(total_cases) as TotalDeathcounts
from Porfolioproject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathcounts  desc

--global numbers

Select date,sum(total_cases)
from Porfolioproject..CovidDeaths
where continent is not null
group by date 
order by 1,2

Select date,sum(total_cases) as Totalcases,sum(cast(new_deaths as int)) as Newdeaths
from Porfolioproject..CovidDeaths
where continent is not null
group by date 
order by 1,2

-- global Death percentage

Select date,sum(new_cases) as Newcases,sum(cast(new_deaths as int)) as Newdeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from Porfolioproject..CovidDeaths
where continent is not null
group by date 
order by 1,2

--overall deathpercentage
Select sum(new_cases) as Newcases,sum(cast(new_deaths as int)) as Newdeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from Porfolioproject..CovidDeaths
where continent is not null
--group by date 
order by 1,2

--next data

select *
from Porfolioproject..CovidDeaths dea
join Porfolioproject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
 
 --total population vs vaccinations
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from Porfolioproject..CovidDeaths dea
join Porfolioproject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order  by 2,3

--summing up
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from Porfolioproject..CovidDeaths dea
join Porfolioproject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order  by 2,3

--with CTE

with popvsvac (continent ,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from Porfolioproject..CovidDeaths dea
join Porfolioproject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order  by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac

--TEMP TABLE
Drop table if exists percentpopulationvaccinated
create table percentpopulationvaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from Porfolioproject..CovidDeaths dea
join Porfolioproject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order  by 2,3

select *, (rollingpeoplevaccinated/population)*100
from percentpopulationvaccinated

--creating view to store data for later visualizations


Create View populationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from Porfolioproject..CovidDeaths dea
join Porfolioproject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *
from populationvaccinated