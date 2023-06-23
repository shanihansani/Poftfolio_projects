SELECT *
FROM PorftfolioProject..CovidDeaths
Order by 3,4

--SELECT *
--FROM PorftfolioProject..CovidVaccinations
--Order by 3,4(columns)

--select data that we are going to be using
SELECT location, Date, total_cases, new_cases,total_deaths,population
FROM PorftfolioProject..CovidDeaths
order by 1,2

--Looking at Total cases vs Total deaths
SELECT location, Date, total_cases, total_deaths ,(100*total_deaths/total_cases) AS DeathPercentage
FROM PorftfolioProject..CovidDeaths
order by 1

-- shows the likelihood of dying if you contract covid in your country.
SELECT location, Date, total_cases, total_deaths ,(total_deaths/total_cases *100)AS DeathPercentage
FROM PorftfolioProject..CovidDeaths
where location like '%states%'
order by 1,2
 
-- shows what percentage of population got covid
SELECT location, Date, population,total_cases,(total_cases/population*100)AS percentpopulationInfected
FROM PorftfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS percentpopulationInfected
FROM PorftfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
Group by Location ,population
order by percentpopulationInfected DESC

--CHANGE COLUMN TYPE
ALTER TABLE PorftfolioProject..CovidDeaths
ALTER COLUMN total_cases float(50);

ALTER TABLE PorftfolioProject..CovidDeaths
ALTER COLUMN total_deaths float(50);

--showing the countries with the heighest death count per population
SELECT Location, MAX(cast(total_deaths as INT))AS TotalDeath 
FROM PorftfolioProject.dbo.CovidDeaths
Group by Location 
order by TotalDeath desc

-- in the result there is world, europe , theycannot be there so figure it out as
SELECT Location, MAX(cast(total_deaths as INT))AS TotalDeath 
FROM PorftfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
Group by Location
order by TotalDeath desc

--LET's break things by continent
SELECT continent, MAX(cast(total_deaths as INT))AS TotalDeath 
FROM PorftfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
Group by continent
order by TotalDeath desc

-- in the result there is world, europe , theycannot be there so figure it out as
SELECT Location, MAX(cast(total_deaths as INT))AS TotalDeath 
FROM PorftfolioProject.dbo.CovidDeaths
WHERE continent is NULL
Group by Location
order by TotalDeath desc

--showing continets with heighest death count per population
SELECT continent, MAX(cast(total_deaths as INT))AS TotalDeath 
FROM PorftfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
Group by continent
order by TotalDeath desc

--GLOBAL CASES
SELECT Date, SUM(new_cases) as TotalCases,SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM
(new_cases)*100 as DeathPercentage
FROM PorftfolioProject..CovidDeaths
Where continent is Not Null
GROUP BY DATE 
order by 1,2

SELECT SUM(new_cases) as TotalCases,SUM(new_deaths) as Total_deaths, 100*SUM(cast(new_deaths as float))/SUM
(cast(new_cases as float)) as DeathPercentage
FROM PorftfolioProject..CovidDeaths
Where continent is Not Null
--GROUP BY DATE 
order by 1,2

--looking at total populations vs vaccinations
Select *
FROM PorftfolioProject..CovidDeaths Dea
JOIN PorftfolioProject..CovidVaccinations Vac
  on Dea.location = Vac.location 
   and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, new_vaccinations)) OVER (partition by dea.Location 
ORDER by dea.location,dea.date) as RollingPeopleVaccinated--it add up every single second one in last column
FROM PorftfolioProject..CovidDeaths Dea
JOIN PorftfolioProject..CovidVaccinations Vac
  on Dea.location = Vac.location 
   and dea.date = vac.date
   where dea.continent is not NULL
   Order by 2,3

--use CTE FOR ABOVE 

WITH POPvsVAC (Continent,Location, date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, new_vaccinations)) OVER (partition by dea.Location 
ORDER by dea.location,dea.date) as RollingPeopleVaccinated--it add up every single second one in last column
FROM PorftfolioProject..CovidDeaths Dea
JOIN PorftfolioProject..CovidVaccinations Vac 
  on Dea.location = Vac.location 
   and dea.date = vac.date
   where dea.continent is not null
  --Order by 2,3
)
select * ,(RollingPeopleVaccinated/population)*100
From POPvsVAC 

-- Temp Table 
Drop Table if Exists #percentpopulationVaccinated
Create Table #percentpopulationVaccinated
( 
    continent nvarchar(225),
    Location nvarchar(225),
    date datetime,
    population numeric,
    New_vaccinations numeric,
    RollingpeopleVaccinated NUMERIC )

Insert INTO #percentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, new_vaccinations)) OVER (partition by dea.Location 
ORDER by dea.location,dea.date) as RollingPeopleVaccinated--it add up every single second one in last column
FROM PorftfolioProject..CovidDeaths Dea
JOIN PorftfolioProject..CovidVaccinations Vac 
  on Dea.location = Vac.location 
   and dea.date = vac.date
  -- where dea.continent is not null
  --Order by 2,3

select * ,(RollingPeopleVaccinated/population)*100
From #percentpopulationVaccinated

--Creating view to store data for later visualizations

Create view percentpopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, new_vaccinations)) OVER (partition by dea.Location 
ORDER by dea.location,dea.date) as RollingPeopleVaccinated--it add up every single second one in last column
FROM PorftfolioProject..CovidDeaths Dea
JOIN PorftfolioProject..CovidVaccinations Vac 
  on Dea.location = Vac.location 
   and dea.date = vac.date
  where dea.continent is not null
  --Order by 2,3

select *
From percentpopulationVaccinated