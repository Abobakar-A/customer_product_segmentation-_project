use covide_project;

select location,
date,
total_cases,
new_cases,
total_deaths,
population
from
CovidDeaths;
-- looking at total cases vs total deaths
select location,
date,
total_cases,
total_deaths,
population,
round((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 ,3)AS Deathpercentage
from
CovidDeaths;
--where location like '%state%'
-- looking at total cases vs population 

select location,
date,
total_cases,
population,
round((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 ,3)AS Deathpercentage
from
CovidDeaths
--where location like '%state%'
order by 2,1;
-- looking at with countries with heighest infection rate compared to population 

select 
location,
max(total_cases) as heighestinfectioncount,
population,
max(round((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 ,3))AS percentpopulationinfected
from
CovidDeaths
group by location,population
--where location like '%state%'
order by percentpopulationinfected desc;

--- showing countries with heighest death count per population 

select 
location,
max(cast(total_deaths as int)) as totaldeathcount
from
CovidDeaths
where location not in ('World','Europe','North America','European Union','South America','Asia','Africa','Oceania','International') 
group by location
order by totaldeathcount  desc;



--- showing continent with heighest death count per population 
select 
location,
max(cast(total_deaths as int)) as totaldeathcount
from
CovidDeaths
where location in('World','Europe','North America','European Union','South America','Asia','Africa','Oceania','International') 
group by location
order by totaldeathcount  desc;

-- global numbers 
SELECT 
    date,
    SUM(CAST(new_cases AS float)) AS total_cases,
    SUM(CAST(new_deaths AS float)) AS total_deaths,
    (SUM(CAST(new_deaths AS float)) / NULLIF(SUM(CAST(new_cases AS float)), 0))*100 AS death_percent
FROM CovidDeaths
where location is not null
GROUP BY date
order by 2,1;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- looking at total population vs total vaccination 
select dea.continent,dea.date,dea.location,dea.population,
vac.new_vaccinations,
sum(convert (int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) rollingpepolevaccinated
from CovidDeaths dea
join  [covide_project].[dbo].[Vaccinations] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent <> ' '
order by 1,3



-- use CTE 
with PopVsVac as(
select dea.continent,dea.date,dea.location,dea.population,
vac.new_vaccinations,
sum(convert (int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) rollingpepolevaccinated
from CovidDeaths dea
join  [covide_project].[dbo].[Vaccinations] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent <> ' '
)

select*,(cast(rollingpepolevaccinated as float)/nullif (cast(population as float),0))*100
from PopVsVac

-- creating veiw to store data for later visualization
create view PercentPopulationVaccinated as
(
select dea.continent,dea.date,dea.location,dea.population,
vac.new_vaccinations,
sum(convert (int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) rollingpepolevaccinated
from CovidDeaths dea
join  [covide_project].[dbo].[Vaccinations] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent <> ' ')


select *
from [covide_project].[dbo].[PercentPopulationVaccinated]





