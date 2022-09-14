
-- Part I: Exploratory Data Analysis with SQL on Public COVID-19 Datasets

-- Global Outlook on COVID Total Cases, Deaths and Death Rate

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Rate
From [SQL Data Exploration Project]..CovidDeaths
where continent is not null 
order by 1,2


-- Infection Rate by Country

Select Location, Population, MAX(total_cases) as Max_Total_Cases,  Max((total_cases/population))*100 as Infection_Rate
From [SQL Data Exploration Project]..CovidDeaths
Group by Location, Population
order by infection_rate desc


-- Using Common Table Expression to Perform Calculation on Partition By

With VaccinatedPopulation (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccinated_Population)
as
(
Select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
, SUM(CAST(vaccination.new_vaccinations as bigint)) OVER (Partition by death.Location Order by death.location, death.Date) as Rolling_Vaccinated_Population

From [SQL Data Exploration Project]..CovidDeaths death
Join [SQL Data Exploration Project]..CovidVaccinations vaccination
	On death.location = vaccination.location
	and death.date = vaccination.date
where death.continent is not null
)

Select *, (Rolling_Vaccinated_Population/Population)*100 as Rolling_Vaccination_Rate
From VaccinatedPopulation
order by 2,3


-- Using Temp Table instead

DROP Table if exists #VaccinationRate
Create Table #VaccinationRate
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vaccinated_Population numeric
)

Insert into #VaccinationRate
Select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
, SUM(CONVERT(bigint,vaccination.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as Rolling_Vaccinated_Population
From [SQL Data Exploration Project]..CovidDeaths death
Inner Join [SQL Data Exploration Project]..CovidVaccinations vaccination
	On death.location = vaccination.location
	and death.date = vaccination.date

Select *, (Rolling_Vaccinated_Population/Population)*100
From #VaccinationRate

-- Creating View for later visualizations

Create View Vaccinated_Population as
Select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
, SUM(CONVERT(bigint,vaccination.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as Rolling_Vaccinated_Population
From [SQL Data Exploration Project]..CovidDeaths death
Inner Join [SQL Data Exploration Project]..CovidVaccinations vaccination
	On death.location = vaccination.location
	and death.date = vaccination.date
where death.continent is not null

-- Part II: Preparing for Tableau visualizations

-- 1. 

Select SUM(new_cases) as total_cases, SUM(convert(int, new_deaths)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [SQL Data Exploration Project]..CovidDeaths
where continent is not null 
order by 1,2


-- 2.

Select date, sum(new_cases) , sum(cast(new_deaths as int))
From [SQL Data Exploration Project]..CovidDeaths
where continent is not null
Group by date
Order by date

-- 3.

Select location, SUM(cast(new_deaths as int)) as TotalDeaths
From [SQL Data Exploration Project]..CovidDeaths
Where continent is not null 
Group by location
order by TotalDeaths desc

-- 4.

Select Location, MAX(total_cases) as TotalCases,  Max((total_cases/population)) as InfectionRate
From [SQL Data Exploration Project]..CovidDeaths
where continent is not null
Group by Location
order by InfectionRate desc




