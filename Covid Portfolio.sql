-- Find Total Cases and Total Deaths
SELECT Location, date, population, total_cases, total_deaths 
FROM PortfolioProject.dbo.CovidDeaths

-- Show Likelihood of Dying from Covid
SELECT location, date, population, (total_deaths/total_cases) * 100 AS 'Likelihood of Dying from Covid'
FROM PortfolioProject.dbo.CovidDeaths
-- 'This shows the likelihood of dying if you contracted covid as the dates progress, by going to the last 
-- date for each location (country), you can see the current chance.'

-- List the countries with the HIGHEST INFECTION rate
SELECT location, population, MAX(total_Cases) AS 'Total Infected', MAX(total_cases/population) * 100 AS 'Infection Rate'
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY 'Infection Rate' DESC

-- From the above list, find your countries' infection rate
SELECT location, population, MAX(total_Cases) AS 'Total Infected', MAX(total_cases/population) * 100 AS 'Infection Rate'
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%States%'
GROUP BY location, population
ORDER BY 'Infection Rate' DESC
-- 'What this information shows is that the US has a population of about 337 million, of those, nearly 97 million have
-- been infected, resulting in a 28.7% infection rate.'

--Show the total death count from each country
SELECT location, MAX(cast(total_deaths AS INT)) AS 'Total Death Count'
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 'Total Death Count' DESC
--The total_deaths data type was NVARCHAR, we had to cast it as an INT to get the total death count.

--Show total death count by continent
SELECT continent, MAX(cast(total_deaths AS INT)) AS 'Total Death Count'
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 'Total Death Count' DESC

--Find death rate of covid GLOBALLY
SELECT SUM(cast(total_deaths AS BIGINT)) AS 'Total Death Count', SUM(total_cases) AS 'Total Covid Cases', SUM(cast(total_deaths AS BIGINT))/SUM(total_cases) * 100 AS 'Global Death Percentage'
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL
--Had to fact check the death rate and needed to change "IS NOT NULL" to "IS NULL". Found there were NULL continents in the table. Using "IS NULL" gives us the correct representation.

--Give a rolling count of vaccinations by date in each country
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(BIGINT,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS 'Vaccinated By Date'
FROM PortfolioProject.dbo.CovidDeaths d
 JOIN PortfolioProject.dbo.CovidVaccinations v
  ON d.location = v.location
  AND d.date = v.date
  WHERE d.continent IS NOT NULL

--USE A CTE
WITH PvV (Continent, Location, date, Population, New_Vaccinations, VaccinatedByDate)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(BIGINT,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS VaccinatedByDate
FROM PortfolioProject.dbo.CovidDeaths d
 JOIN PortfolioProject.dbo.CovidVaccinations v
  ON d.location = v.location
  AND d.date = v.date
  WHERE d.continent IS NOT NULL
)
 Select *
 FROM PvV

 --Create a Temp Table
 DROP TABLE IF EXISTS #PopPercentVac
 CREATE TABLE #PopPercentVac
 (
 Continent NVARCHAR(255),
 Location NVARCHAR(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 VaccinatedByDate numeric
 )

INSERT INTO #PopPercentVac
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(BIGINT,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS VaccinatedByDate
FROM PortfolioProject.dbo.CovidDeaths d
 JOIN PortfolioProject.dbo.CovidVaccinations v
  ON d.location = v.location
  AND d.date = v.date
  WHERE d.continent IS NOT NULL

--Create a VIEW
CREATE VIEW PopPercentVac AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(BIGINT,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS VaccinatedByDate
FROM PortfolioProject.dbo.CovidDeaths d
 JOIN PortfolioProject.dbo.CovidVaccinations v
  ON d.location = v.location
  AND d.date = v.date
  WHERE d.continent IS NOT NULL