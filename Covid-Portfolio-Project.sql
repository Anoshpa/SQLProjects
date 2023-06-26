select * from PortfolioPtoject.dbo.CovidDeaths

select location,date,total_cases,new_cases, total_deaths, population 
from CovidDeaths
order by 1,2

-- Looking at the total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country
select location,date,total_cases, total_deaths, (total_deaths/total_cases) *100 as death_percentage
from CovidDeaths
where location like 'Pakistan' 
order by death_percentage desc

-- Looking at the total case vs population
--shows what percentage of population got Covid

select location, date, population,total_cases, (total_cases/population) * 100 as cases_percentage
from CovidDeaths
where location like 'Pakistan'


--Looking at Countries with highest infection rate compared to population

select location, population,MAX(total_cases) as highest_infection_count, MAX((total_cases/population)) * 100 as percentage_population_infected
from CovidDeaths
--where location like 'Pakistan'
group by location,population
order by percentage_population_infected desc



-- showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as total_death_count
from CovidDeaths
where continent is not null
group by location
order by total_death_count desc



-- LET'S BREAK THINGS DOWN BY CONTINENT

select continent, max(cast(total_deaths as int)) as total_death_count
from CovidDeaths
where continent is not null
group by continent
order by total_death_count desc

-- showing the continents with highest death counts

select continent,MAX(cast(total_deaths as int)) as max_deaths_per_continent
from CovidDeaths
group by continent
order by max_deaths_per_continent desc

-- global numbers
select date, sum(cast(new_cases as int)) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths
from CovidDeaths
where continent is not null
group by date
order by 1,2


--Looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER(partition by dea.location) as rolling_people_vaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE
with popvsvac  as (
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER(partition by dea.location) as rolling_people_vaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rolling_people_vaccinated/population)*100
from popvsvac



-- Temp table
Drop table if exists  #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER(partition by dea.location) as rolling_people_vaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



-- creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER(partition by dea.location) as rolling_people_vaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated